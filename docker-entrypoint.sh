#!/usr/bin/env bash
set -xe

upshost="${UPS_HOST:-127.0.0.1}"
upsport="${UPS_PORT:-3493}"
upsuser="${UPS_USER:-monuser}"
upspassword="${UPS_PASSWORD:-secret}"

if [[ ! -f /etc/nut/ups.conf ]]; then
  cat >/etc/nut/ups.conf <<EOF
[$NAME]
  desc = "$DESCRIPTION"
  driver = $DRIVER
  port = $PORT
EOF
fi

if [[ ! -f /etc/nut/upsd.conf ]]; then
  cat >/etc/nut/upsd.conf <<EOF
LISTEN 0.0.0.0 3493
EOF
fi

if [[ ! -f /etc/nut/upsd.users ]]; then
  cat >/etc/nut/upsd.users <<EOF
[$upsuser]
  password = $upspassword
  upsmon master
EOF
fi

if [[ ! -f /etc/nut/upsmon.conf ]]; then
  cat >/etc/nut/upsmon.conf <<EOF
MONITOR $NAME@localhost 1 $upsuser $upspassword master
RUN_AS_USER $USER
EOF
fi

if [[ ! -f /etc/nut/nut.conf ]]; then
  cat >/etc/nut/nut.conf <<EOF
MODE=standalone
EOF
fi



echo "server = '$upshost'" > /app/webNUT/webnut/config.py
echo "port = '$upsport'" >> /app/webNUT/webnut/config.py
echo "username = '$upsuser'" >> /app/webNUT/webnut/config.py
echo "password = '$upspassword'" >> /app/webNUT/webnut/config.py

cat /app/webNUT/webnut/config.py

cd /app/webNUT && python setup.py install

chgrp -R nut /etc/nut
chmod -R o-rwx /etc/nut

/sbin/upsdrvctl -u root start
/sbin/upsd -u $USER
/sbin/upsmon

cd webnut
exec pserve ../production.ini
