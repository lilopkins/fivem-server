FROM ghcr.io/lilopkins/fivem-utility:main AS fetch
RUN apt update && apt install -y curl && rm -rf /var/lib/apt/lists/*
WORKDIR /usr/src/fivem
COPY pull_server.sh .
RUN bash pull_server.sh

FROM alpine:latest
WORKDIR /srv
RUN mkdir /data
COPY --from=fetch /usr/src/fivem/fx.tar.xz .
RUN tar xvf fx.tar.xz
RUN rm fx.tar.xz
WORKDIR /data

VOLUME [ "/data" ]
EXPOSE 30120/tcp
EXPOSE 30120/udp
EXPOSE 40120/udp
CMD [ "/bin/sh", "/srv/run.sh", "+set", "txDataPath", "/data/txData" ]
