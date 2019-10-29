FROM spacetx/starfish:latest

ADD runner.sh /usr/local/bin/runner.sh
ADD recipe.py /tmp/recipe.py

RUN pip install awscli

WORKDIR /tmp
ENTRYPOINT ["/usr/local/bin/runner.sh"]
