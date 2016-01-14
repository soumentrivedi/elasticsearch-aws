FROM ubuntu:trusty
MAINTAINER Soumen Trivedi

RUN apt-get update && \
	apt-get install -y wget curl && \
	curl https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add - && \
    echo 'deb http://packages.elastic.co/elasticsearch/2.x/debian stable main' >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y elasticsearch openjdk-7-jre-headless && \
    apt-get install -y nginx supervisor apache2-utils && \    
    apt-get clean && \
    rm -rf /var/lib/apt/lists 

ENV ELASTICSEARCH_USER **None**
ENV ELASTICSEARCH_PASS **None**
ENV CLUSTER_NAME **REQUIRED**
ENV ES_OPTS ""
ENV ES_S3_BUCKET_NAME **REQUIRED**
ENV AWS_ACCESS_KEY_ID **REQUIRED**
ENV AWS_SECRET_KEY **REQUIRED**
ENV EC2_NODE_NAME **REQUIRED**
ENV ELASTICSEARCH_NODE_NAME ${TUTUM_CONTAINER_HOSTNAME}
ENV NETWORK_BIND_HOST 0.0.0.0
ENV NETWORK_PUBLISH_HOST _ec2:privateIp_

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD run.sh /run.sh
ADD nginx_default /etc/nginx/sites-enabled/default

# Define mountable directories.
# Mount elasticsearch.yml config
ADD config/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml

RUN /usr/share/elasticsearch/bin/plugin install cloud-aws && \    
    /usr/share/elasticsearch/bin/plugin install lmenezes/elasticsearch-kopf/v2.1.1 && \
    echo "daemon off;" >> /etc/nginx/nginx.conf && \
    chmod +x /*.sh && \
    chown -R elasticsearch: /usr/share/elasticsearch
USER elasticsearch

CMD ["/run.sh", "${ES_OPTS}"]

# Expose ports.
#   - 9200: HTTP
#   - 9300: transport
EXPOSE 9200
EXPOSE 9300