FROM ubuntu:18.04
LABEL maintainer="docker@public.swineson.me"

ARG KNOT_RESOLVER_RELEASE_KEY_URL=https://download.opensuse.org/repositories/home:CZ-NIC:knot-resolver-latest/xUbuntu_18.04/Release.key
ARG KNOT_RESOLVER_REPOSITORY_CONFIG="deb http://download.opensuse.org/repositories/home:/CZ-NIC:/knot-resolver-latest/xUbuntu_18.04/ /"
ARG GOPATH=/tmp/gopath
WORKDIR /tmp

RUN apt-get update -f && \
    apt-get full-upgrade -f && \
    apt-get install curl gnupg2 && \
    echo '$KNOT_RESOLVER_REPOSITORY_CONFIG' > /etc/apt/sources.list.d/knot-resolver.list && \
    curl $KNOT_RESOLVER_RELEASE_KEY_URL | apt-key add - && \
    apt-get update -f && \
    apt-get install -f make knot-resolver lua-filesystem supervisor golang-1.10-go git-core dnsutils && \
    mkdir "$GOPATH" && \
    git clone https://github.com/m13253/dns-over-https.git && \
    cd dns-over-https && \
    make && \
    make install && \
    rm -rf * && \
    apt-get purge -f curl make golang-1.10-go git-core && \
    rm -r /var/lib/apt/lists/*

COPY config /
COPY entrypoint.sh /entrypoint.sh
COPY supervisor.conf /etc/supervisor/supervisor.conf

EXPOSE 9001
ENTRYPOINT ["/entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisor/supervisor.conf", "-n"]
HEALTHCHECK none