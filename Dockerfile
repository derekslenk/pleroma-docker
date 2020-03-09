FROM alpine:latest

RUN awk 'NR==2' /etc/apk/repositories | sed 's/main/community/' | tee -a /etc/apk/repositories

RUN apk update && apk upgrade && apk add git build-base openrc erlang erlang-runtime-tools erlang-xmerl elixir --no-cache && apk add postgresql postgresql-contrib --no-cache

RUN /bin/sh /etc/init.d/postgresql start

RUN rc-update add postgresql

RUN addgroup pleroma && adduser -S -s /bin/false -h /opt/pleroma -H -G pleroma pleroma

RUN mkdir -p /opt/pleroma && chown -R pleroma:pleroma /opt/pleroma

RUN su -l pleroma -s /bin/sh -c 'git clone -b stable https://git.pleroma.social/pleroma/pleroma /opt/pleroma'

RUN cd /opt/pleroma && su -l pleroma -s /bin/sh -c 'mix local.hex --force' && su -l pleroma -s /bin/sh -c 'mix local.rebar --force' && su -l pleroma -s /bin/sh -c 'mix deps.get' &&  su -l pleroma -s /bin/sh -c 'mix pleroma.instance gen'

ENTRYPOINT [ "/bin/sh" ]
