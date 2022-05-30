if [ -z "`id -u unbound 2> /dev/null`" ]; then
/usr/sbin/adduser --system  --home /var/lib/unbound --gecos "Unbound" \
        --no-create-home --disabled-password \
        --quiet unbound || true

/usr/sbin/unbound-control-setup
/usr/bin/chown unbound unbound_control.pem unbound_control.key unbound_server.pem unbound_server.key
fi
