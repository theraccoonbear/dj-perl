FROM alpine:latest

ADD ./ /opt/src
WORKDIR /opt/src

RUN apk update && \
	apk add curl bash perl perl-io-socket-ssl perl-net-ssleay netcat-openbsd \
		build-base gcc abuild binutils binutils-doc gcc-doc \
		yaml-dev perl-dev

#RUN ./build/setup-perl-env.sh

CMD while sleep 3600; do: echo '.'; done
