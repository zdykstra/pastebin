FROM ghcr.io/void-linux/void-linux:latest-full-x86_64
MAINTAINER dykstra.zachary@gmail.com

WORKDIR /usr/local/pastebin

COPY cpanfile .
RUN xbps-install -Syu xbps && \
    xbps-install -Syu && \
    xbps-install -y perl cpanminus make gcc openssl-devel file && \
    cpanm --installdeps --notest . && \
    xbps-remove -Ry gcc make openssl-devel

COPY pastebin/ /usr/local/pastebin

VOLUME /config
VOLUME /files

CMD ["/usr/local/pastebin/pastebin.sh"]
