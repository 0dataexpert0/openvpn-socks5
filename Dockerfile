# OpenVPN client + SOCKS proxy
# Usage:
# Create configuration (.ovpn), mount it in a volume
# docker run --volume=something.ovpn:/ovpn.conf:ro --device=/dev/net/tun --cap-add=NET_ADMIN
# Connect to (container):1080
# Note that the config must have embedded certs
# See `start` in same repo for more ideas

FROM alpine:edge

ADD sockd.sh /usr/local/bin/

RUN true \
    && apk add --update-cache dante-server openvpn iptables nano curl net-tools \
    && rm -rf /var/cache/apk/* \
    && chmod a+x /usr/local/bin/sockd.sh \
    && true

ARG user=anton
ARG password=pardon02

ENV PROXY_USER $user
ENV PROXY_PASSWORD $password

RUN adduser -S -H ${PROXY_USER} \
    && echo "${PROXY_USER}:${PROXY_PASSWORD}" | chpasswd


ADD sockd.conf /etc/
ADD up.sh /etc/openvpn/
ADD down.sh /etc/openvpn/
ADD pass.txt /etc/openvpn/
ADD ./ovpn.conf /
ENTRYPOINT [ \
    "openvpn", \
    "--up", "/usr/local/bin/sockd.sh", \
    "--script-security", "2", \
    "--config", "/ovpn.conf"]
