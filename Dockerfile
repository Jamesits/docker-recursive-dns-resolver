FROM ubuntu:18.04
LABEL maintainer="docker@public.swineson.me"

ARG DEBIAN_FRONTEND=noninteractive
ARG KNOT_RESOLVER_RELEASE_KEY_URL=https://download.opensuse.org/repositories/home:CZ-NIC:knot-resolver-latest/xUbuntu_18.04/Release.key
ARG KNOT_RESOLVER_REPOSITORY_CONFIG="deb http://download.opensuse.org/repositories/home:/CZ-NIC:/knot-resolver-latest/xUbuntu_18.04/ /"
ARG GOPATH=/tmp/gopath

ENV BOOTSTRAP_DNS_SERVER=2001:470:20::2,74.82.42.42,101.6.6.6

WORKDIR /tmp

RUN apt-get update -y && \
    apt-get full-upgrade -y && \
    apt-get install -y curl gnupg2 && \
    echo $KNOT_RESOLVER_REPOSITORY_CONFIG > /etc/apt/sources.list.d/knot-resolver.list && \
    curl -sSL "$KNOT_RESOLVER_RELEASE_KEY_URL" | apt-key add - && \
    apt-get update -y && \
    apt-get install -y make knot-resolver lua-filesystem supervisor golang-1.10-go git-core dnsutils ca-certificates && \
    ln -s /usr/lib/go-1.10/bin/go /bin/go && \
    mkdir "$GOPATH" && \
    git clone https://github.com/m13253/dns-over-https.git && \
    cd dns-over-https && \
    make && \
    make install && \
    rm -rf * && \
    apt-get purge -y curl make golang-1.10-go git-core && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

COPY config /
COPY entrypoint.sh /entrypoint.sh
COPY supervisor.conf /etc/supervisor/supervisor.conf

EXPOSE 53/udp 53/tcp 80/tcp
ENTRYPOINT ["/entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisor/supervisor.conf", "-n"]
HEALTHCHECK none
