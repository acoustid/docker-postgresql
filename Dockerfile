ARG PG_VERSION=latest

FROM postgres:$PG_VERSION as builder

ARG PATRONI_VERSION
ARG WAL_G_VERSION
ARG POSTGRES_EXPORTER_VERSION

RUN apt-get update && \
    apt-get install -y \
        python \
        python3 \
        python-pip \
        python-virtualenv \
        libpq-dev \
        git \
        wget \
        postgresql-server-dev-$PG_MAJOR

RUN virtualenv /opt/patroni
RUN /opt/patroni/bin/pip install requests psycopg2 six
RUN /opt/patroni/bin/pip install "patroni[kubernetes]==$PATRONI_VERSION"

RUN virtualenv -p python3 /opt/yacron
RUN /opt/yacron/bin/pip install yacron

RUN git clone https://github.com/acoustid/pg_acoustid.git /opt/pg_acoustid && \
    cd /opt/pg_acoustid && \
    make && \
    make install

RUN mkdir -p /opt/wal-g/bin && \
    cd /opt/wal-g/bin && \
    wget https://github.com/wal-g/wal-g/releases/download/v$WAL_G_VERSION/wal-g.linux-amd64.tar.gz && \
    tar xvf wal-g.linux-amd64.tar.gz && \
    rm *.tar.gz

RUN mkdir -p /opt/postgres_exporter/bin && \
    cd /opt/postgres_exporter/bin && \
    wget https://github.com/wrouesnel/postgres_exporter/releases/download/${POSTGRES_EXPORTER_VERSION}/postgres_exporter_${POSTGRES_EXPORTER_VERSION}_linux-amd64.tar.gz && \
    tar xvf postgres_exporter_${POSTGRES_EXPORTER_VERSION}_linux-amd64.tar.gz && \
    mv postgres_exporter_${POSTGRES_EXPORTER_VERSION}_linux-amd64/postgres_exporter . && \
    rmdir postgres_exporter_${POSTGRES_EXPORTER_VERSION}_linux-amd64 && \
    rm *.tar.gz

FROM postgres:$PG_VERSION

RUN apt-get update && \
    apt-get install -y \
        python \
        python3 \
        python3-yaml \
        postgresql-$PG_MAJOR-slony1-2 \
        barman \
        pgbackrest \
        slony1-2-bin \
        dumb-init \
        curl \
        daemontools \
        liblz4-tool \
        less \
        vim \
        lzop \
        sshpass \
        pv

COPY setup_db.sh /docker-entrypoint-initdb.d/setup_db.sh

COPY psql pg_dump wal-g postgres_exporter pg_k8s_util /usr/local/bin/

COPY --from=builder /usr/lib/postgresql/$PG_MAJOR/lib/acoustid.so /usr/lib/postgresql/$PG_MAJOR/lib/
COPY --from=builder /usr/share/postgresql/$PG_MAJOR/extension/acoustid* /usr/share/postgresql/$PG_MAJOR/extension/
COPY --from=builder /usr/lib/postgresql/$PG_MAJOR/lib/bitcode/acoustid /usr/lib/postgresql/$PG_MAJOR/lib/bitcode/

COPY --from=builder /opt/wal-g/ /opt/wal-g/

COPY --from=builder /opt/patroni/ /opt/patroni/

RUN ln -s /opt/patroni/bin/patroni /usr/local/bin && \
    ln -s /opt/patroni/bin/patronictl /usr/local/bin && \
    ln -s /opt/patroni/bin/patroni_wale_restore /usr/local/bin

COPY --from=builder /opt/yacron/ /opt/yacron/

RUN ln -s /opt/yacron/bin/yacron /usr/local/bin

COPY --from=builder /opt/postgres_exporter/bin/ /opt/postgres_exporter/bin/
