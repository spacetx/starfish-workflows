#!/bin/bash

field_of_view=$AWS_BATCH_JOB_ARRAY_INDEX
experiment=https://s3.amazonaws.com/spacetx.starfish.data.public/browse/formatted/iss/20190506/experiment.json

python - << EOF
import starfish
recipe = __import__('recipe')

decoded_spots = recipe.process_fov(${field_of_view}, "${experiment}")
decoded_spots.save_csv("decoded.csv")

EOF