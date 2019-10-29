#!/usr/bin/env bash

## process fov
python recipe.py

## upload results to s3
aws s3 cp . s3://starfish.data.output-warehouse/batch-job-outputs/iss-published/ --recursive  --exclude "*" --include "*decoded.nc"
