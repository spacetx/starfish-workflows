FROM spacetx/starfish:latest

ADD runner.sh /usr/local/bin/runner.sh
RUN pip install awscli
WORKDIR /tmp
USER starfish
ENTRYPOINT ["/usr/local/bin/runner.sh"]