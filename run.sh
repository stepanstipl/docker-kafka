#!/usr/bin/env bash
[ "${DEBUG}" == 'true' ] && set -x

# Generate config file by default
if [ ! -f "${KAFKA_CONF}" ]; then
  # Check mandatory variables are set
  KAFKA_BROKER_ID=${KAFKA_BROKER_ID:?'KAFKA_BROKER_ID is not set'}
  KAFKA_ZOOKEEPER_CONNECT=${KAFKA_ZOOKEEPER_CONNECT:?'KAFKA_ZOOKEEPER_CONNECT is not set'}

  eval "echo \"$(< ${KAFKA_CONF_TEMPLATE})\"" > "${KAFKA_CONF}"
  [ $? -ne 0 ] && echo 'Failed to generate Zookeeper config!' && exit 1
fi

exec "${KAFKA_HOME}/bin/kafka-server-start.sh" "${KAFKA_CONF}"
