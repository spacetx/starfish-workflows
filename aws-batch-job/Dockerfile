FROM spacetx/starfish:latest

ADD recipe.py /tmp/recipe.py
WORKDIR /tmp
ENTRYPOINT ["/usr/bin/env"]
CMD [ "python", "./recipe.py" ]