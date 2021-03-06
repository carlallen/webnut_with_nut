#! /bin/sh -e

NUT_USER="${API_USER:-monuser}"
API_PASSWORD="${UPS_PASSWORD:-secret}"

echo "server = '127.0.0.1'" > /app/webNUT/webnut/config.py
echo "port = '3493'" >> /app/webNUT/webnut/config.py
echo "username = '$NUT_USER'" >> /app/webNUT/webnut/config.py
echo "password = '$API_PASSWORD'" >> /app/webNUT/webnut/config.py

if [ ! -e /etc/nut/.setup ]; then
  if [ -e /etc/nut/local/ups.conf ]; then
    cp /etc/nut/local/ups.conf /etc/nut/ups.conf
  else
    if [ -z "$SERIAL" ]; then
      echo "** This container may not work without setting for SERIAL **"
    fi
    cat <<EOF >>/etc/nut/ups.conf
[$NAME]
        driver = $DRIVER
        port = $PORT
        serial = "$SERIAL"
        desc = "$DESCRIPTION"
EOF
    if [ ! -z "$POLLINTERVAL" ]; then
      echo "        pollinterval = $POLLINTERVAL" >> /etc/nut/ups.conf
    fi
    if [ ! -z "$VENDORID" ]; then
      echo "        vendorid = $VENDORID" >> /etc/nut/ups.conf
    fi
  fi
  if [ -e /etc/nut/local/ups.conf ]; then
    cp /etc/nut/local/ups.conf /etc/nut/ups.conf
  else
    cat <<EOF >>/etc/nut/upsd.conf
LISTEN 0.0.0.0 3493
EOF
  fi
  if [ -e /etc/nut/local/upsd.users ]; then
    cp /etc/nut/local/upsd.users /etc/nut/upsd.users
  else
    cat <<EOF >>/etc/nut/upsd.users
[$API_USER]
        password = $API_PASSWORD


        upsmon $SERVER
EOF
  fi
  if [ -e /etc/nut/local/upsmon.conf ]; then
    cp /etc/nut/local/upsmon.conf /etc/nut/upsmon.conf
  else
    cat <<EOF >>/etc/nut/upsmon.conf
MONITOR $NAME@localhost 1 $API_USER $API_PASSWORD $SERVER


RUN_AS_USER $USER
EOF
  fi
  touch /etc/nut/.setup
fi

mkdir -m 2750 /dev/shm/nut
chown $USER.$GROUP /dev/shm/nut
[ -e /var/run/nut ] || ln -s /dev/shm/nut /var/run
# Issue #15 - change pid warning message from "No such file" to "Ignoring"
echo 0 > /var/run/nut/upsd.pid && chown $USER.$GROUP /var/run/nut/upsd.pid
echo 0 > /var/run/upsmon.pid

/usr/sbin/upsdrvctl -u root start
/usr/sbin/upsd -u $USER
/usr/sbin/upsmon

cd /app/webNUT && python setup.py install

cd webnut
exec pserve ../production.ini


