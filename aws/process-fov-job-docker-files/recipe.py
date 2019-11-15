from starfish import Codebook, FieldOfView
from starfish.image import ApplyTransform, Filter, LearnTransform
from starfish.spots import DecodeSpots, FindSpots
from starfish.types import Axes, FunctionSource


def process_fov(fov: FieldOfView, codebook: Codebook) -> DecodedIntensityTable:
    """Process a single field of view of ISS data
    Parameters
    ----------
    fov : FieldOfView
        the field of view to process
    codebook : Codebook
        the Codebook to use for decoding

    Returns
    -------
    DecodedSpots :
        tabular object containing the locations of detected spots.
    """

    # note the structure of the 5D tensor containing the raw imaging data
    imgs = fov.get_image(FieldOfView.PRIMARY_IMAGES)
    dots = fov.get_image("dots")
    nuclei = fov.get_image("nuclei")

    print("Learning Transform")
    learn_translation = LearnTransform.Translation(reference_stack=dots, axes=Axes.ROUND, upsampling=1000)
    transforms_list = learn_translation.run(imgs.reduce({Axes.CH, Axes.ZPLANE}, func="max"))

    print("Applying transform")
    warp = ApplyTransform.Warp()
    registered_imgs = warp.run(imgs, transforms_list=transforms_list, verbose=True)

    print("Filter WhiteTophat")
    filt = Filter.WhiteTophat(masking_radius=15, is_volume=False)

    filtered_imgs = filt.run(registered_imgs, verbose=True)
    filt.run(dots, verbose=True, in_place=True)
    filt.run(nuclei, verbose=True, in_place=True)

    print("Detecting")
    detector = FindSpots.BlobDetector(
        min_sigma=1,
        max_sigma=10,
        num_sigma=30,
        threshold=0.01,
        measurement_type='mean',
    )
    dots_max = dots.reduce((Axes.ROUND, Axes.ZPLANE), func="max", module=FunctionSource.np)
    spots = detector.run(image_stack=filtered_imgs, reference_image=dots_max)

    print("Decoding")
    decoder = DecodeSpots.PerRoundMaxChannel(codebook=codebook)
    decoded = decoder.run(spots=spots)
    return decoded
