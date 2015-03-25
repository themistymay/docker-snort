FROM  phusion/baseimage:0.9.9
MAINTAINER Mike May <themistymay@gmail.com>

ENV VERSION_DAQ 2.0.4
ENV VERSION_SNORT 2.9.7.2

RUN apt-get update
RUN apt-get install -y -q build-essential git-core tar curl wget git libxml2-dev libxslt1-dev wkhtmltopdf
RUN apt-get install -y -q libpcap-dev libpcre3-dev libdumbnet-dev
RUN apt-get install -y -q bison flex
RUN apt-get install -y -q zlib1g zlib1g-dev

RUN mkdir /build

WORKDIR /build

RUN wget https://www.snort.org/downloads/snort/daq-$VERSION_DAQ.tar.gz
RUN wget https://www.snort.org/downloads/snort/snort-$VERSION_SNORT.tar.gz

RUN tar -zxvf daq-$VERSION_DAQ.tar.gz
WORKDIR /build/daq-$VERSION_DAQ
RUN ./configure; make; make install

WORKDIR /build
RUN tar -zxvf snort-$VERSION_SNORT.tar.gz
WORKDIR /build/snort-$VERSION_SNORT
RUN ./configure --enable-sourcefire; make; make install

RUN mkdir /usr/local/lib/snort_dynamicrules

RUN ln -s /usr/local/bin/snort /usr/sbin/snort
RUN ldconfig

RUN mkdir -p /etc/snort/rules
RUN cp etc/*.conf* /etc/snort
RUN cp etc/*.map* /etc/snort

ADD files/snort.conf /etc/snort/snort.conf

WORKDIR /build
RUN wget https://www.snort.org/downloads/community/community-rules.tar.gz
RUN tar -zxvf community-rules.tar.gz -C /etc/snort/rules --strip-components=1
RUN rm community-rules.tar.gz

WORKDIR /etc/snort
RUN touch rules/white_list.rules
RUN touch rules/black_list.rules

RUN rm -rf /build
RUN apt-get autoclean -y
RUN apt-get clean -y
RUN apt-get autoremove -y -q

RUN sed -i 's/include \$RULE\_PATH/#include \$RULE\_PATH/' /etc/snort/snort.conf
