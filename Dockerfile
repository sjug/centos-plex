FROM centos:7

RUN \
# Update and get dependencies
    yum update -y && \

# Add user
    groupadd -g 1000 plex && \
    useradd -u 1000 -g 1000 -d /config -s /bin/false plex \
    && \

# Setup directories
    mkdir -p \
      /config \
      /transcode \
      /data \
    && \

# Cleanup
    yum clean all && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*

EXPOSE 32400/tcp 3005/tcp 8324/tcp 32469/tcp 1900/udp 32410/udp 32412/udp 32413/udp 32414/udp
VOLUME /config /transcode

ENV HOME="/config"

ARG TAG=plexpass
ARG URL=

COPY root/ /

RUN \
# Save version and install
    /installBinary.sh

CMD ["/usr/sbin/init"]