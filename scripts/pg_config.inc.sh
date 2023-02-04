if test -n "$PATRONI_KUBERNETES_POD_IP" && test -z "$PGHOST"
then
    export PGHOST=$PATRONI_KUBERNETES_POD_IP
fi

if test -n "$PATRONI_SUPERUSER_USERNAME" && test -z "$PGUSER"
then
    export PGUSER=$PATRONI_SUPERUSER_USERNAME
fi

if test -n "$PATRONI_SUPERUSER_PASSWORD" && test -z "$PGPASSWORD"
then
    export PGPASSWORD=$PATRONI_SUPERUSER_PASSWORD
fi

if test -n "$PATRONI_POSTGRESQL_DATA_DIR" && test -z "$PGDATA"
then
    export PGDATA=$PATRONI_POSTGRESQL_DATA_DIR
fi