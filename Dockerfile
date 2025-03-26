ARG PG_VERSION=latest

FROM postgres:$PG_VERSION as builder

ARG WAL_G_VERSION
ARG PG_ACOUSTID_VERSION
ARG PATRONI_VERSION

RUN apt-get update && \
    apt-get install -y \
        python3 \
        python3-venv \
        python3-yaml \
        python3-requests \
        python3-psycopg2 \
        libpq-dev \
        git \
        wget \
        make \
        gcc \
        postgresql-server-dev-$PG_MAJOR

RUN python3 -m venv --system-site-packages /opt/patroni
RUN /opt/patroni/bin/pip install "patroni[kubernetes]==$PATRONI_VERSION"

RUN python3 -m venv --system-site-packages /opt/yacron
RUN /opt/yacron/bin/pip install yacron

RUN git clone -b v${PG_ACOUSTID_VERSION} https://github.com/acoustid/pg_acoustid.git /opt/pg_acoustid && \
    cd /opt/pg_acoustid && \
    make && \
    make install

RUN mkdir -p /opt/wal-g/bin && \
    cd /opt/wal-g/bin && \
    wget https://github.com/wal-g/wal-g/releases/download/v$WAL_G_VERSION/wal-g-pg-ubuntu-20.04-amd64.tar.gz && \
    tar xvf wal-g-pg-ubuntu-20.04-amd64.tar.gz && \
    mv wal-g-pg-ubuntu-20.04-amd64 wal-g && \
    rm *.tar.gz

FROM postgres:$PG_VERSION

RUN apt-get update && \
    apt-get install -y \
        python3 \
        python3-venv \
        python3-yaml \
        python3-requests \
        python3-psycopg2 \
        pgbackrest \
        barman \
        dumb-init \
        curl \
        daemontools \
        liblz4-tool \
        less \
        vim \
        lzop \
        sshpass \
        pv \
        gettext-base \
        postgresql-$PG_MAJOR-wal2json

COPY setup_db.sh /docker-entrypoint-initdb.d/setup_db.sh

COPY psql pg_dump pg_dumpall wal-g /usr/local/bin/

COPY scripts/ /postgresql-scripts/

COPY --from=builder /usr/lib/postgresql/$PG_MAJOR/lib/acoustid.so /usr/lib/postgresql/$PG_MAJOR/lib/
COPY --from=builder /usr/share/postgresql/$PG_MAJOR/extension/acoustid* /usr/share/postgresql/$PG_MAJOR/extension/
COPY --from=builder /usr/lib/postgresql/$PG_MAJOR/lib/bitcode/acoustid /usr/lib/postgresql/$PG_MAJOR/lib/bitcode/

COPY --from=builder /opt/wal-g/ /opt/wal-g/

COPY --from=builder /opt/patroni/ /opt/patroni/

RUN ln -s /opt/patroni/bin/patroni /usr/local/bin && \
    ln -s /opt/patroni/bin/patronictl /usr/local/bin

COPY --from=builder /opt/yacron/ /opt/yacron/

RUN ln -s /opt/yacron/bin/yacron /usr/local/bin

RUN curl -L https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -o /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq
