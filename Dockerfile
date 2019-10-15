ARG PG_VERSION=latest

FROM golang:latest as stolon

ARG STOLON_VERSION=master

RUN git clone https://github.com/sorintlab/stolon.git /opt/stolon && \
    cd /opt/stolon && \
    git checkout $STOLON_VERSION && \
    ./build

FROM postgres:$PG_VERSION as builder

ARG WAL_G_VERSION=
ARG POSTGRES_EXPORTER_VERSION=

RUN apt-get update && \
    apt-get install -y \
        python \
        python3 \
        python-pip \
        python-virtualenv \
        libpq-dev \
        git \
        wget \
        postgresql-server-dev-all

RUN virtualenv /opt/patroni
RUN /opt/patroni/bin/pip install requests psycopg2
RUN /opt/patroni/bin/pip install patroni[etcd]

RUN virtualenv -p python3 /opt/wal-e
RUN /opt/wal-e/bin/pip install wal-e[aws]
RUN sed -i 's/encrypt_key=True/encrypt_key=False/' /opt/wal-e/lib/python3.5/site-packages/wal_e/blobstore/s3/s3_util.py

RUN git clone https://github.com/acoustid/pg_acoustid.git /opt/pg_acoustid && \
    cd /opt/pg_acoustid && \
    make && \
    make install

RUN mkdir -p /opt/wal-g/bin && \
    cd /opt/wal-g/bin && \
    wget https://github.com/wal-g/wal-g/releases/download/$WAL_G_VERSION/wal-g.linux-amd64.tar.gz && \
    tar xvf wal-g.linux-amd64.tar.gz

RUN mkdir -p /opt/postgres_exporter/bin && \
    cd /opt/postgres_exporter/bin && \
    wget https://github.com/wrouesnel/postgres_exporter/releases/download/${POSTGRES_EXPORTER_VERSION}/postgres_exporter_${POSTGRES_EXPORTER_VERSION}_linux-amd64.tar.gz && \
    tar xvf postgres_exporter_${POSTGRES_EXPORTER_VERSION}_linux-amd64.tar.gz

FROM postgres:$PG_VERSION

RUN apt-get update && \
    apt-get install -y \
        python \
        postgresql-$PG_MAJOR-slony1-2 \
        slony1-2-bin \
        dumb-init \
        curl \
        daemontools \
        liblz4-tool \
        less \
        vim \
        lzop \
        pv

COPY setup_db.sh /docker-entrypoint-initdb.d/setup_db.sh

COPY psql pg_dump postgres_exporter /usr/local/bin/

COPY --from=builder /usr/lib/postgresql/$PG_MAJOR/lib/acoustid.so /usr/lib/postgresql/$PG_MAJOR/lib/
COPY --from=builder /usr/share/postgresql/$PG_MAJOR/extension/acoustid* /usr/share/postgresql/$PG_MAJOR/extension/
COPY --from=builder /usr/lib/postgresql/$PG_MAJOR/lib/bitcode/acoustid /usr/lib/postgresql/$PG_MAJOR/lib/bitcode/

COPY --from=builder /opt/wal-e/ /opt/wal-e/

RUN ln -s /opt/wal-e/bin/wal-e /usr/local/bin

COPY --from=builder /opt/wal-g/ /opt/wal-g/

RUN ln -s /opt/wal-g/bin/wal-g /usr/local/bin

COPY --from=builder /opt/patroni/ /opt/patroni/

RUN ln -s /opt/patroni/bin/patroni /usr/local/bin && \
    ln -s /opt/patroni/bin/patronictl /usr/local/bin && \
    ln -s /opt/patroni/bin/patroni_wale_restore /usr/local/bin

COPY --from=builder /opt/postgres_exporter/bin/ /opt/postgres_exporter/bin/

COPY --from=stolon /opt/stolon/bin/ /opt/stolon/bin/

RUN ln -s /opt/stolon/bin/stolon-keeper /usr/local/bin && \
    ln -s /opt/stolon/bin/stolon-sentinel /usr/local/bin && \
    ln -s /opt/stolon/bin/stolon-proxy /usr/local/bin && \
    ln -s /opt/stolon/bin/stolonctl /usr/local/bin
