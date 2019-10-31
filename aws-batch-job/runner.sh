#!/usr/bin/env bash

# download recipe file
aws s3 cp $RECIPE_LOCATION recipe.py

field_of_view=$AWS_BATCH_JOB_ARRAY_INDEX
experiment=$EXPERIMENT_URL

# process fov
python - << EOF
recipe = __import__('recipe')

decoded_spots = recipe.process_fov(${field_of_view}, "${experiment}")
filename = f"fov_{int(FOV_NUM):03d}"+"_decoded.nc"
decoded_spots.to_netcdf(filename)

EOF

## upload results to s3
aws s3 cp . $RESULTS_LOCATION --recursive  --exclude "*" --include "*decoded.nc"
