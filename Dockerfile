ARG PG_VERSION=latest

FROM postgres:${PG_VERSION} as builder

RUN apt-get update && apt-get install -y python python-pip python-virtualenv libpq-dev

RUN virtualenv /opt/patroni
RUN /opt/patroni/bin/pip install requests psycopg2

ARG PATRONI_VERSION
RUN /opt/patroni/bin/pip install patroni[etcd]==${PATRONI_VERSION}

FROM postgres:${PG_VERSION}

RUN apt-get update && apt-get install -y python
COPY --from=builder /opt/patroni/ /opt/patroni/
