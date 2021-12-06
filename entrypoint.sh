#!/bin/sh

TS_FORMAT="%Y-%m-%dT%H:%M:%S%z "

if [[ -e /conf/logrotate.conf ]]; then
  cp /conf/logrotate.conf /etc/logrotate.conf
  echo "Using mounted /conf/logrotate.conf:" | ts "${TS_FORMAT}"
  inotifyd /conf-watch.sh /conf/logrotate.conf:w &
else
  echo "Using templated /etc/logrotate.conf:" | ts "${TS_FORMAT}"
  {
    echo "/logs/${LOGROTATE_FILE_PATTERN:-*.log} {"
    echo "  ${LOGROTATE_TRUNCATE:-copytruncate}"
    echo "  ${LOGROTATE_COMPRESS:-nocompress}"
    echo "  rotate ${LOGROTATE_ROTATE:-5}"
    echo "  size ${LOGROTATE_SIZE:-50M}"
    [[ -n $LOGROTATE_SU ]] && echo "  ${LOGROTATE_SU}"
    echo "}"
  } > /etc/logrotate.conf
fi
ts "${TS_FORMAT}" < /etc/logrotate.conf

if [ -d "/etc/periodic/${LOGROTATE_CRON:-15min}" ]; then
  echo "using /etc/periodic/${LOGROTATE_CRON:-15min} cron schedule" | ts "${TS_FORMAT}"
  mv /etc/.logrotate.cronjob "/etc/periodic/${LOGROTATE_CRON:-15min}/logrotate"
else
  echo "assuming \"${LOGROTATE_CRON:-15min}\" is a cron expression; appending to root's crontab" | ts "${TS_FORMAT}"
  echo "${LOGROTATE_CRON:-15min} /etc/.logrotate.cronjob" >> /var/spool/cron/crontabs/root
fi

# shellcheck disable=SC2086
exec crond -d ${CROND_LOGLEVEL:-7} -f 2>&1 | ts "${TS_FORMAT}"
echo "test"
