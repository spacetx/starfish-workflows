#!/bin/bash

field_of_view=$AWS_BATCH_JOB_ARRAY_INDEX
experiment=https://s3.amazonaws.com/spacetx.starfish.data.public/browse/formatted/iss/20190506/experiment.json

python - << EOF
import starfish
recipe = __import__('recipe')

decoded_spots = recipe.process_fov(${field_of_view}, "${experiment}")
filename = f"fov_{int(${field_of_view}):03d}"+"_decoded.nc"
print(filename)
decoded_spots.to_netcdf(filename)
EOF

aws s3 cp .  s3://starfish.data.output-warehouse/batch-job-outputs/iss-published/ --recursive  --exclude "*" --include "*decoded.nc"