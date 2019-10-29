#!/bin/bash

field_of_view=$AWS_BATCH_JOB_ARRAY_INDEX
experiment=REPLACE_WITH_URL_TO_EXPERIEMENT

python - << EOF
import starfish
recipe = __import__('recipe')
decoded_spots = recipe.process_fov(${field_of_view}, "${experiment}")
filename = f"fov_{int(${field_of_view}):03d}"+"_decoded.csv"
print(filename)
decoded_spots.save_csv(filename)
EOF

aws s3 cp .  REPLACE_WITH_PATH_TO_S3_BUCKET_FOR_RESULTS --recursive  --exclude "*" --include "*decoded.csv"