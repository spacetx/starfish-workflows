#!/usr/bin/env bash

## copy decoded intensity tables
aws s3 sync --exclude "*" --include "*decoded.nc" $RESULTS_LOCATION .

## load and concat tables
python merge_tables.py

## copy merged table back to s3 bucket
aws s3 cp merged_decoded_fovs.nc $RESULTS_LOCATION

