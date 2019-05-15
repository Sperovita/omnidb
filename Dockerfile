FROM debian:stable-slim

ARG OMNIDB_VERSION_OVERRIDE=2.15.0
ARG SERVICE_USER_OVERRIDE=omnidb

ENV OMNIDB_VERSION=$OMNIDB_VERSION_OVERRIDE
ENV SERVICE_USER=$SERVICE_USER_OVERRIDE

WORKDIR /${SERVICE_USER}

RUN  adduser --system --home /${SERVICE_USER} --no-create-home ${SERVICE_USER} \
  && mkdir -p /${SERVICE_USER} \
  && chown -R ${SERVICE_USER}.root /${SERVICE_USER} \
  && chmod -R g+w /${SERVICE_USER} \
  && apt-get update \
  && apt-get -y upgrade \
  && apt-get install -y wget dumb-init \
  && if [ ! -e '/bin/systemctl' ]; then ln -s /bin/echo /bin/systemctl; fi \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /etc/omnidb \
  && chown -R ${SERVICE_USER}:${SERVICE_USER} /etc/omnidb

RUN wget -q https://github.com/OmniDB/OmniDB/releases/download/${OMNIDB_VERSION}/omnidb-server_${OMNIDB_VERSION}-debian-amd64.deb \
  && dpkg -i omnidb-server_${OMNIDB_VERSION}-debian-amd64.deb \
  && rm -rf omnidb-server_${OMNIDB_VERSION}-debian-amd64.deb
  

USER ${SERVICE_USER}
  
EXPOSE 8000
EXPOSE 25482

ENTRYPOINT [ "/usr/bin/dumb-init", "--" ]
CMD ["omnidb-server", "-H", "127.0.0.1", "-e", "443", "-d", "/etc/omnidb"]
