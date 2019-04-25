ARG PG_VERSION=latest

FROM postgres:${PG_VERSION} as builder

RUN apt-get update && \
    apt-get install -y \
        python \
        python-pip \
        python-virtualenv \
        libpq-dev \
        git \
        postgresql-server-dev-$PG_MAJOR

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

ARG SLONY_VERSION
RUN apt-get update && \
    apt-get install -y \
        python \
        postgresql-$PG_MAJOR-slony1-2=$SLONY_VERSION-\* \
        slony1-2-bin=$SLONY_VERSION-\*

COPY --from=builder /opt/patroni/ /opt/patroni/
COPY --from=builder /usr/lib/postgresql/$PG_MAJOR/lib/acoustid.so /usr/lib/postgresql/$PG_MAJOR/lib/
COPY --from=builder /usr/share/postgresql/$PG_MAJOR/extension/acoustid--*.sql /usr/share/postgresql/$PG_MAJOR/extension/
COPY --from=builder /usr/lib/postgresql/$PG_MAJOR/lib/bitcode/acoustid /usr/lib/postgresql/$PG_MAJOR/lib/bitcode/
