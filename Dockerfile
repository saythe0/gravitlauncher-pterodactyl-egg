FROM azul/zulu-openjdk-debian:25-latest

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        lsof \
        curl \
        ca-certificates \
        openssl \
        git \
        tar \
        sqlite3 \
        fontconfig \
        libfreetype6 \
        tzdata \
        iproute2 \
        libstdc++6 \
        osslsigncode \
        nano \
        vim \
        rsync \
        socat \
        unzip \
        wget \
    && rm -rf /var/lib/apt/lists/*

RUN wget -O /tmp/openjfx-jmods.zip \
        https://download2.gluonhq.com/openjfx/25/openjfx-25_linux-x64_bin-jmods.zip \
    && unzip /tmp/openjfx-jmods.zip -d /tmp/openjfx \
    && cp /tmp/openjfx/javafx-jmods-25/* "${JAVA_HOME}/jmods/" \
    && rm -rf /tmp/openjfx /tmp/openjfx-jmods.zip

RUN useradd -d /home/container -m container \
    && curl -fsSL \
        https://raw.githubusercontent.com/pterodactyl/yolks/master/java/entrypoint.sh \
        -o /entrypoint.sh \
    && chmod +x /entrypoint.sh

USER container

ENV USER=container \
    HOME=/home/container

WORKDIR /home/container

CMD ["/bin/bash", "/entrypoint.sh"]