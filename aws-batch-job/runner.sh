#!/usr/bin/env bash

# download recipe file
aws s3 cp $RECIPE_LOCATION recipe.py

field_of_view=$AWS_BATCH_JOB_ARRAY_INDEX
experiment=$EXPERIMENT_URL

# process fov
python - << EOF
import starfish

recipe = __import__('recipe')

fov_str: str = f"fov_{int(${field_of_view}):03d}"

# load experiment
print("${experiment}")
experiment = starfish.Experiment.from_json("${experiment}")

print(f"loading fov: {fov_str}")
fov = experiment[fov_str]

decoded_spots = recipe.process_fov(fov, experiment.codebook)
filename = f"fov_{int(${field_of_view}):03d}"+"_decoded.nc"
decoded_spots.to_netcdf(filename)

EOF

## upload results to s3
aws s3 cp . $RESULTS_LOCATION --recursive  --exclude "*" --include "*decoded.nc"
