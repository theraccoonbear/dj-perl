#!/bin/bash

openssl req -config /opt/src/app/ssl/openssl.conf -nodes -new -x509 -newkey rsa:2048 -subj "/C=US/ST=Wisconsin/L=Madison/O=TRB Technology Services, LLC/OU=Org/CN=hanglight.test" -out /opt/src/app/ssl/server.cert -keyout /opt/src/app/ssl/server.key
