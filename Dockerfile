FROM alpine:latest

WORKDIR /srv

RUN apk --no-cache add curl
RUN mkdir /data
RUN curl -Lo fx.tar.xz https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/1971-fbd5c11df14693e9be8a9b86b02689abfc790f69/fx.tar.xz
RUN tar xvf fx.tar.xz
RUN rm fx.tar.xz

WORKDIR /data

VOLUME [ "/data" ]
EXPOSE 30120/tcp
EXPOSE 30120/udp
CMD [ "/bin/sh", "/srv/run.sh", "+exec", "server.cfg" ]
