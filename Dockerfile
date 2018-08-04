FROM alpine:latest

ADD ./ /opt/src
WORKDIR /opt/src

RUN apk update && \
	apk add bash perl perl-io-socket-ssl perl-net-ssleay netcat-openbsd

CMD while sleep 3600; do :; done
