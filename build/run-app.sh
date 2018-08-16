#!/usr/bin/env bash

cd /opt/src

SSL_CERT_FILE=/opt/src/app/ssl/server.cert
SSL_KEY_FILE=/opt/src/app/ssl/server.key

echo "Looking for certificates"

ls -l $SSL_CERT_FILE
ls -l $SSL_KEY_FILE

if [ ! -f $SSL_CERT_FILE ] || [ ! -f $SSL_KEY_FILE ]; then
	echo "Generating and installing SSL certificate...";
	./build/install-ssl
fi

if [ "$DISABLE_SSL" = "true" ]; then
	plackup --server Twiggy \
    -R /opt/src/app \
    -r /opt/src/app/bin/app.psgi
else
	plackup --server Twiggy::TLS \
    --tls-key $SSL_KEY_FILE \
    --tls-cert $SSL_CERT_FILE \
    -R /opt/src/app \
    -r /opt/src/app/bin/app.psgi
fi
