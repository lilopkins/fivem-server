FROM alpine:latest

ARG PACKAGE_URL

WORKDIR /srv

RUN apk --no-cache add curl
RUN mkdir /data
RUN curl -Lo fx.tar.xz $PACKAGE_URL
RUN tar xvf fx.tar.xz
RUN rm fx.tar.xz

WORKDIR /data

VOLUME [ "/data" ]
EXPOSE 30120/tcp
EXPOSE 30120/udp
CMD [ "/bin/sh", "/srv/run.sh", "+exec", "server.cfg" ]
