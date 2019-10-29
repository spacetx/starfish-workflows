import starfish


def process_fov(field_num: int, experiment_str: str):
    """Process a single field of view of data
    Parameters
    ----------
    field_num : int
        the field of view to process
    experiment_str : int
        path of experiment json file

    Returns
    -------
    DecodedSpots :
        tabular object containing the locations of detected spots.
    """

    # TODO ADD RECIPE STEPS HERE, END WITH DECODED INTENSITY TABLE NAMES DECODED

    df = decoded.to_decoded_dataframe()
    return df

