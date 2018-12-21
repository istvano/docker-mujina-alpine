FROM maven:3.6.0-jdk-8-alpine

ENV PYTHON_VERSION=2.7.15-r1
ENV PY_PIP_VERSION=10.0.1-r0
ENV SUPERVISOR_VERSION=3.3.0
ENV MUJINA_VERSION=mujina-7.1.0

RUN apk add --no-cache git python=$PYTHON_VERSION py2-pip=$PY_PIP_VERSION && \
    pip install supervisor==$SUPERVISOR_VERSION



RUN mkdir -p /usr/local/etc && \
    cd /usr/local/etc && \
    git clone https://github.com/OpenConext/Mujina.git && \
    cd Mujina && \
    git checkout tags/$MUJINA_VERSION && \
    mvn clean install

COPY supervisord.conf /etc/supervisord.conf
COPY mujina-load.sh /usr/local/etc/mujina-load.sh
RUN chmod +x /usr/local/etc/mujina-load.sh

EXPOSE 8080 9090

ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]
