FROM spacetx/starfish:latest

ADD merge_tables.sh /usr/local/bin/merge_tables.sh
ADD merge_tables.py /tmp/merge_tables.py
RUN pip install awscli
WORKDIR /tmp
USER starfish
ENTRYPOINT ["/usr/local/bin/merge_tables.sh"]