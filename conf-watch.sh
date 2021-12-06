#!/bin/sh
TS_FORMAT="%Y-%m-%dT%H:%M:%S%z "

if [ -e /conf/logrotate.conf ]; then
  cp /conf/logrotate.conf /etc/logrotate.conf
  echo "Mounted /conf/logrotate.conf changed:" | ts "${TS_FORMAT}"
fi
ts "${TS_FORMAT}" < /etc/logrotate.conf
