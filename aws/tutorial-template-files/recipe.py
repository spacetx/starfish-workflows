from starfish import Codebook, DecodedIntensityTable, FieldOfView


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

    # TODO ADD STARFISH SINGLE FIELD OF VIEW PIPELINE HERE
    return