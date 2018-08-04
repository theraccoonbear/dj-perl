FROM alpine:latest

ADD ./src /opt/src
WORKDIR /opt/src

RUN apk update && \
	apk add bash perl perl-io-socket-ssl perl-net-ssleay

CMD while sleep 3600; do :; done
