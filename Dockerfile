ARG PG_VERSION=latest

FROM postgres:${PG_VERSION} as builder

RUN apt-get update && apt-get install -y python python-pip python-virtualenv libpq-dev git

RUN virtualenv /opt/patroni
RUN /opt/patroni/bin/pip install requests psycopg2

ARG PATRONI_VERSION
RUN /opt/patroni/bin/pip install patroni[etcd]==${PATRONI_VERSION}

ARG PG_ACOUSTID_VERSION
RUN git clone https://github.com/acoustid/pg_acoustid.git /opt/pg_acoustid && \
    cd /opt/pg_acoustid && \
    make && \
    make install

FROM postgres:${PG_VERSION}

RUN apt-get update && apt-get install -y python
COPY --from=builder /opt/patroni/ /opt/patroni/
