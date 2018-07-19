#!/usr/bin/env bash
[ "${DEBUG}" == 'true' ] && set -x

[ "$$" -eq 1 ] && exec /sbin/tini -- "$0" "$@"

# If we're started as root - fix directory ownership and drop privileges
if [ "${EUID}" -eq 0 ]; then
  for dir in ${KAFKA_LOG_DIRS//,/ }; do
    chown -R "${KAFKA_USER}:${KAFKA_GROUP}" "${dir}"
  done

  # Drop to non-root user
  exec su-exec "${KAFKA_USER}" "$0" "$@"
fi

# Generate config file by default
if [ ! -f "${KAFKA_CONF}" ]; then
  # Check mandatory variables are set
  KAFKA_BROKER_ID=${KAFKA_BROKER_ID:?'KAFKA_BROKER_ID is not set'}
  KAFKA_ZOOKEEPER_CONNECT=${KAFKA_ZOOKEEPER_CONNECT:?'KAFKA_ZOOKEEPER_CONNECT is not set'}

  eval "echo \"$(< ${KAFKA_CONF_TEMPLATE})\"" > "${KAFKA_CONF}"
  [ $? -ne 0 ] && echo 'Failed to generate Zookeeper config!' && exit 1
fi

exec "${KAFKA_HOME}/bin/kafka-server-start.sh" "${KAFKA_CONF}"
