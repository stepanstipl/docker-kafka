FROM quay.io/stepanstipl/kafka

USER root

ENV LD_LIBRARY_PATH=/usr/lib/jvm/java-1.8-openjdk/jre/lib/amd64/server \
    PATH=${PATH}:/root/go/bin:/opt/terraform

RUN apk add --update --no-cache \
      build-base \
      python2 \
      python2-dev \
      py-pip \
      go \
      git \
    && pip install --upgrade pip setuptools \
    && pip install kafka-tools \
    && mkdir -p /export/apps/jdk/JDK-1_8_0_72/jre/lib/amd64/server \
    && ln -s /usr/lib/jvm/java-1.8-openjdk/jre/lib/amd64/server/libjvm.so /export/apps/jdk/JDK-1_8_0_72/jre/lib/amd64/server/libjvm.so \
    && go get github.com/mhausenblas/burry.sh

CMD ["/bin/bash"]
