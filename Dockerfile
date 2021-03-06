FROM alpine:3.7

ENV KAFKA_HOME=/opt/kafka \
    KAFKA_VERSION=1.1.0 \
    KAFKA_USER=kafka \
    KAFKA_UID=10000 \
    KAFKA_GROUP=kafka \
    KAFKA_GID=10000 \
    KAFKA_URL=http://mirror.ox.ac.uk/sites/rsync.apache.org/kafka \
    KAFKA_SHA=057cc111d354d2c20f0125d8e43b44682c69b381 \
    KAFKA_LOG_DIRS=/data/kafka-logs \
    LANG=C.UTF-8 \
    JAVA_VERSION_ALPINE=8.171.11-r0 \
    JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk \
    JAVA_VERSION=8u171 \
    SCALA_VERSION=2.12 \
    JMX_DIR=/opt/jmx \
    JMX_EXPORTER_URL=https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent \
    JMX_EXPORTER_VERSION=0.3.1 \
    JMX_CONFIG_URL=https://raw.githubusercontent.com/prometheus/jmx_exporter/parent \
    KAFKA_OPTS=-javaagent:/opt/jmx/jmx_prometheus.jar=8080:/opt/jmx/kafka.yml

ENV PATH=${PATH}:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin:${KAFKA_HOME}/bin \
    KAFKA_CONF=${KAFKA_HOME}/config/server.properties \
    KAFKA_CONF_TEMPLATE=${KAFKA_HOME}/config/server.properties.template \
    KAFKA_TGZ=kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz

RUN apk add --update --no-cache \
      openjdk8="${JAVA_VERSION_ALPINE}" \
      tini \
      openssl \
      bash \
      wget \
      su-exec \
    && wget "${KAFKA_URL}/${KAFKA_VERSION}/${KAFKA_TGZ}" \
    && echo "${KAFKA_SHA}  ${KAFKA_TGZ}" > kafka.sha \
    && sha1sum -c kafka.sha \
    && mkdir /opt \
    && tar -xzf "${KAFKA_TGZ}" -C /opt \
    && rm "${KAFKA_TGZ}" kafka.sha \
    && mv /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} ${KAFKA_HOME} \
    && rm -rf ${KAFKA_HOME}/bin/windows \
    && rm ${KAFKA_CONF} \
    && mkdir ${KAFKA_HOME}/data ${KAFKA_HOME}/logs \
    && addgroup -g ${KAFKA_GID} ${KAFKA_GROUP} \
    && adduser -g "Kafka user" -D -h ${KAFKA_HOME} -G ${KAFKA_GROUP} -s /sbin/nologin -u ${KAFKA_UID} ${KAFKA_USER} \
    && chown -R "${KAFKA_USER}:${KAFKA_GROUP}" "${KAFKA_HOME}" \
    && mkdir "${JMX_DIR}" \
    && wget "${JMX_EXPORTER_URL}/${JMX_EXPORTER_VERSION}/jmx_prometheus_javaagent-${JMX_EXPORTER_VERSION}.jar" -O "${JMX_DIR}/jmx_prometheus.jar" \
    && wget "${JMX_CONFIG_URL}-${JMX_EXPORTER_VERSION}/example_configs/kafka-0-8-2.yml" -O "/${JMX_DIR}/kafka.yml"

COPY run.sh ${KAFKA_HOME}/bin/
COPY server.properties.template ${KAFKA_CONF_TEMPLATE}

USER ${KAFKA_USER}
WORKDIR ${KAFKA_HOME}

VOLUME ${KAFKA_LOG_DIRS}

EXPOSE 9092
EXPOSE 8080

CMD ["/opt/kafka/bin/run.sh"]
