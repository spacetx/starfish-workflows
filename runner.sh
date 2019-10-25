#!/bin/bash

wget -O recipe.py https://raw.githubusercontent.com/spacetx/starfish-workflows/saxelrod-testing-aws/recipe.py
python recipe.py 0 https://s3.amazonaws.com/spacetx.starfish.data.public/browse/formatted/iss/20190506/experiment.json
