FROM python:2.7-alpine
MAINTAINER Carl Allen "github@allenofmn.com"
ARG BUILD_DATE
ARG VCS_REF
LABEL org.label-schema.name=webnut_with_nut

ARG NUT_VERSION=2.7.4-r6
ENV API_USER=upsmon \
    DESCRIPTION=UPS \
    DRIVER=usbhid-ups \
    GROUP=nut \
    NAME=ups \
    POLLINTERVAL= \
    PORT=auto \
    SERIAL= \
    SERVER=master \
    USER=nut \
    VENDORID=

RUN echo '@edge http://dl-cdn.alpinelinux.org/alpine/edge/main' \
      >>/etc/apk/repositories && \
    echo '@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing' \
      >>/etc/apk/repositories && \
    apk add --update nut@testing=$NUT_VERSION \
      libcrypto1.1@edge libssl1.1@edge net-snmp-libs@edge


RUN apk add git

RUN mkdir /app && \
cd /app && \
git clone https://github.com/rshipp/python-nut2.git && \
cd python-nut2 && \
python setup.py install && \
cd .. && \
git clone https://github.com/rshipp/webNUT.git && cd webNUT && \
pip install -e .

WORKDIR /app/webNUT

EXPOSE 3493 6543
COPY entrypoint.sh /usr/local/bin/
ENTRYPOINT /usr/local/bin/entrypoint.sh
