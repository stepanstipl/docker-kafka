FROM busybox:1.28.4-glibc

ENV HC_URL=https://github.com/andreas-schroeder/kafka-health-check/releases/download \
    HC_VERSION=0.0.3 \
    HC_HOME=/opt/bin

ENV PATH=${PATH}:${HC_HOME}

RUN mkdir -p "${HC_HOME}" \
    && wget -O- "${HC_URL}/v${HC_VERSION}/kafka-health-check_${HC_VERSION}_linux_amd64.tar.gz" | tar -xzf- -C "${HC_HOME}"

EXPOSE 8000
