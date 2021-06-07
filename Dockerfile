FROM ghcr.io/void-linux/void-linux:latest-full-x86_64
MAINTAINER dykstra.zachary@gmail.com

WORKDIR /usr/local/pastebin

COPY cpanfile .
RUN xbps-install -Su && \
    xbps-install -y cpanminus make gcc openssl-devel file && \
    cpanm --installdeps --notest .

COPY pastebin/ /usr/local/pastebin

VOLUME /config
VOLUME /files

CMD ["/usr/local/pastebin/pastebin.sh"]
