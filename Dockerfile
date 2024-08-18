FROM debian:12-slim

ENV PUBLIC_IP=""
ENV RUN_ARGS="-o -Y 2 -A -J HIGH -E -j"
ENV PORT_RANGE="30000:30059"

RUN echo "deb-src http://http.us.debian.org/debian bookworm main" >> /etc/apt/sources.list
ENV DEBIAN_FRONTEND="noninteractive"
RUN apt-get update &&  apt-get -y dist-upgrade && \
    apt-get -y --force-yes install curl unzip openssl dpkg-dev debhelper syslog-ng-core syslog-ng && \
    apt-get -y build-dep pure-ftpd-mysql && \
    mkdir /tmp/pure-ftpd-mysql && \
    cd /tmp/pure-ftpd-mysql && \
    apt-get source pure-ftpd-mysql && \
    cd pure-ftpd-* && \
    sed -i '/^optflags=/ s/$/ --without-capabilities/g' ./debian/rules && \
    dpkg-buildpackage -b -uc && \
    dpkg -i /tmp/pure-ftpd-mysql/pure-ftpd-common*.deb && \
    apt-get -y install openbsd-inetd \
    default-mysql-client && \
    dpkg -i /tmp/pure-ftpd-mysql/pure-ftpd-mysql*.deb && \
    apt-mark hold pure-ftpd pure-ftpd-mysql pure-ftpd-common

COPY entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh

HEALTHCHECK --interval=2m CMD curl -v -k --ssl ftp://localhost:21 2>&1 | grep -q 'Welcome to Pure-FTPd \[privsep\] \[TLS\]' && exit 0 || exit 1
ENTRYPOINT ["./entrypoint.sh"]