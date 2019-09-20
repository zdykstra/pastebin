FROM registry.servercentral.com/hannibal/baseimage:latest
MAINTAINER ServerCentral

WORKDIR /usr/local/pastebin

RUN apt-get update && \
  apt-get --no-install-recommends -y install file 

COPY cpanfile .
RUN cpm install -v --mirror=https://darkpan.servercentral.com/combined -g -w 8

RUN  apt-get -y remove build-essential && \
  apt-get -y autoremove && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cpanm/*

COPY bin /usr/local/pastebin/bin
COPY lib /usr/local/pastebin/lib
COPY templates /usr/local/pastebin/templates

RUN mkdir /usr/local/pastebin/log

RUN mkdir /etc/service/pastebin 
COPY install/pastebin.sh /etc/service/pastebin/run
RUN chmod +x /etc/service/pastebin/run

VOLUME /config
VOLUME /files

CMD ["/sbin/my_init"]
