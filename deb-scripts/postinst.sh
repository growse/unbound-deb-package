if [ -z "`id -u unbound 2> /dev/null`" ]; then
adduser --system  --home /var/lib/unbound --gecos "dnsmasq" \
        --no-create-home --disabled-password \
        --quiet unbound || true
fi
