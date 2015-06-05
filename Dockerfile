FROM justcontainers/base-alpine
MAINTAINER Alex Goh <alex.goh@commercecraft.com.my>

ENV CONSUL_TEMPLATE_VERSION 0.9.0

ADD https://github.com/hashicorp/consul-template/releases/download/v${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.tar.gz /

RUN tar zxvf consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.tar.gz && \
    mv consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64/consul-template /usr/local/bin/consul-template &&\
    rm -rf /consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.tar.gz && \
    rm -rf /consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64 && \
    mkdir -p /consul-template /consul-template/config.d /consul-template/templates

ENV CONSUL_URL=172.17.42.1:8500

# Alpine Linux didn't publish HAProxy 1.5.x in main repos yet
RUN echo http://dl-4.alpinelinux.org/alpine/edge/main > /tmp/new_repo
RUN apk update --repositories-file /tmp/new_repo
RUN apk add --repositories-file /tmp/new_repo haproxy openssl-dev

ADD haproxy.cfg.tmpl /consul-template/

ADD reload-config /usr/local/bin/

ADD cont-init.d /etc/cont-init.d/

ADD haproxy /etc/services.d/haproxy/

ADD router /etc/services.d/router/

EXPOSE 80

ENTRYPOINT ["/init"]
