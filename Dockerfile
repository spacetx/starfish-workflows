FROM spacetx/starfish:latest

ADD runner.sh /usr/local/bin/runner.sh
ADD recipe.py /tmp/recipe.py
WORKDIR /tmp
USER starfish
ENTRYPOINT ["/usr/local/bin/runner.sh"]