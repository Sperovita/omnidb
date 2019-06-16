FROM debian:stable-slim

# Install Packages
RUN apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y wget supervisor && \
  if [ ! -e '/bin/systemctl' ]; then ln -s /bin/echo /bin/systemctl; fi && \
  rm -rf /var/lib/apt/lists/* 

# Perms
RUN  adduser --system --home /omnidb --no-create-home omnidb && \
  mkdir -p /omnidb && \
  mkdir -p /omnidb-config && \
  chown -R omnidb.root /omnidb && \
  chown -R omnidb.root /omnidb-config && \
  chown -R omnidb.root /run 

WORKDIR /omnidb

ARG OMNIDB_VERSION=2.15.0
ENV OMNIDB_VERSION=$OMNIDB_VERSION

# Install Omnidb
RUN wget -q https://github.com/OmniDB/OmniDB/releases/download/${OMNIDB_VERSION}/omnidb-server_${OMNIDB_VERSION}-debian-amd64.deb && \
  dpkg -i omnidb-server_${OMNIDB_VERSION}-debian-amd64.deb && \
  rm -rf omnidb-server_${OMNIDB_VERSION}-debian-amd64.deb
  
# Configs
COPY ./docker-config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./docker-config/omnidb.conf /omnidb-config/omnidb.conf

USER omnidb
  
EXPOSE 8081 25482

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
