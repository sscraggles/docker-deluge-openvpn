#FROM lsiobase/mono:xenial
FROM ubuntu:xenial-20210114
MAINTAINER Craig Richardson

VOLUME /data
VOLUME /config

# Update packages and install software
RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install software-properties-common wget git \
    && echo "***** add deluge repository *****" \
    && add-apt-repository -y ppa:deluge-team/ppa \
    && echo "***** add openvpn repository *****" \
    && wget -O - https://swupdate.openvpn.net/repos/repo-public.gpg | apt-key add - \
    && echo "deb http://build.openvpn.net/debian/openvpn/stable xenial main" > /etc/apt/sources.list.d/openvpn-aptrepo.list \
    && apt-get update \
    && apt-get install -qy sudo deluged deluge-web curl rar unrar zip unzip ufw iputils-ping openvpn bc \
    python2.7 python2.7-pysqlite2 \
    && ln -sf /usr/bin/python2.7 /usr/bin/python2 \
    && apt-get install -y tinyproxy telnet \
    && wget https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64.deb \
    && dpkg -i dumb-init_1.2.0_amd64.deb \
    && rm -rf dumb-init_1.2.0_amd64.deb \
    && echo "***** install dockerize *****" \
    && curl -L https://github.com/jwilder/dockerize/releases/download/v0.5.0/dockerize-linux-amd64-v0.5.0.tar.gz | tar -C /usr/local/bin -xzv \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && groupmod -g 1000 users \
    && useradd -u 911 -U -d /config -s /bin/false abc \
    && usermod -G users abc

ADD openvpn/ /etc/openvpn/
ADD deluge/ /etc/deluge/
ADD tinyproxy/ /opt/tinyproxy/

ENV OPENVPN_USERNAME=**None** \
    OPENVPN_PASSWORD=**None** \
    OPENVPN_PROVIDER=**None** \
    DELUGE_PASSWORD=password \
    DELUGE_USERNAME=username \
    DELUGE_PEER_PORT=51413 \
    DELUGE_PEER_PORT_RANDOM_HIGH=65535 \
    DELUGE_PEER_PORT_RANDOM_LOW=49152 \
    DELUGE_PEER_PORT_RANDOM_ON_START=false \
    DELUGE_RPC_PASSWORD=password \
    DELUGE_DOWNLOAD_DIR=/download/torrents/complete \
    DELUGE_INCOMPLETE_DIR=/download/torrents/incomplete \
    DELUGE_WATCH_DIR=/download/torrents/torrents-watch \
    DELUGE_HOME=/config \
    DELUGE_RPC_PORT=9091 \
    ENABLE_UFW=false \
    UFW_ALLOW_GW_NET=false \
    UFW_EXTRA_PORTS= \
    PUID= \
    PGID= \
    DROP_DEFAULT_ROUTE= \
    WEBPROXY_ENABLED=false \
    WEBPROXY_PORT=8888

VOLUME ["/data"]
# Torrent port
#EXPOSE 53160
#EXPOSE 53160/udp
# WebUI
EXPOSE 8112
# Daemon
#EXPOSE 58846
# tinyproxy
EXPOSE 8888

CMD ["dumb-init", "/etc/openvpn/start.sh"]
#CMD ["/etc/openvpn/start.sh"]
