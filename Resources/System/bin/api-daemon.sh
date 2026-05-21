#!/system/bin/sh
API_DAEMON_DIR=/data/local/service/api-daemon
if [ ! -d ${API_DAEMON_DIR} ]; then
  mkdir -p ${API_DAEMON_DIR}
  cp -rf /system/kaios/http_root ${API_DAEMON_DIR}
  cp -f /system/kaios/api-daemon ${API_DAEMON_DIR}
  cp -f /system/kaios/config.toml ${API_DAEMON_DIR}
fi

exec ${API_DAEMON_DIR}/api-daemon ${API_DAEMON_DIR}/config.toml
