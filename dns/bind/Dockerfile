FROM ubuntu/bind9:latest 

RUN apt update -y && apt install dnsutils -y 

RUN mkdir -p /etc/bind_templates
VOLUME /etc/bind_templates

COPY ./kokan.sh /usr/local/bin/kokan.sh
CMD /usr/local/bin/kokan.sh /etc/bind_templates /etc/bind && /usr/local/bin/docker-entrypoint.sh $@
