FROM python:2.7
MAINTAINER Carl Allen <github@allenofmn.com>


ENV API_USER=monuser \
    DESCRIPTION=UPS \
    NAME=ups \
    DRIVER=usbhid-ups \
    PORT=auto \
    USER=nut \
    GROUP=nut \
    DRIVER=usbhid-ups

RUN apt-get clean
RUN apt-get update
RUN apt-get -qy install nut
RUN apt-get -qy autoremove

RUN mkdir /app && \
    cd /app && \
    git clone https://github.com/rshipp/python-nut2.git && \
    cd python-nut2 && \
    python setup.py install && \
    cd .. && \
    git clone https://github.com/rshipp/webNUT.git && cd webNUT && \
    pip install -e .



COPY /docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

WORKDIR /app/webNUT

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 6543 3493
