FROM postgis/postgis:16-3.4

COPY init/ /docker-entrypoint-initdb.d/
COPY metabase.dump /docker-entrypoint-initdb.d/metabase.dump
COPY restore.sh /docker-entrypoint-initdb.d/restore.sh

RUN sed -i 's/\r$//' /docker-entrypoint-initdb.d/restore.sh

RUN chmod +x /docker-entrypoint-initdb.d/restore.sh