#!/usr/bin/env bash

## process fov
python recipe.py

## upload results to s3
aws s3 cp . $RESULTS_LOCATION --recursive  --exclude "*" --include "*decoded.nc"
