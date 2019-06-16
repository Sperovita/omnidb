# Omnidb Docker For Traefik
Can run omnidb in this docker container within your docker Traefik network

## Requirements
- Docker
- Docker Compose
    - For Traefik Setup

## Linux Setup
- Clone into your project folder `git clone https://github.com/Sperovita/omnidb.git project-folder`
- Enter project folder
- Create .env file `nano .env`
- Copy the example and paste, edit for your configuration and save
- Spin up container `docker-compose up -d`
- Go to your the address you set in host name
- Use user `admin` pass `admin`
- Change login, setup connections, enjoy
    - The server name will be the container name of your db

## DotEnv Example
.env
```
OMNIDB_VERSION=2.16.0
TRAEFIK_NETWORK=my-traefik-network-name
HOST_NAME=omnidb.mydomain.com
DB_NETWORK=my-docker-database-network-name
COMPOSE_PROJECT_NAME=project-name
```

## Traefik Example
### Basic Traefik setup with auto certs for https  

docker-compose.yml
```
version: '3.7'

services:
  web:
    image: traefik
    command: --docker --docker.domain=docker.localhost
    ports:
      - "80:80"
      - "443:443"
    networks:
      - web
    restart: unless-stopped
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./traefik.toml:/traefik.toml
      - ./acme:/acme
networks:
  web:
    driver: bridge
```
Depending on where this is launched the default network name would be `directoryname_web`. if you use the `COMPOSE_PROJECT_NAME` env var it will use that name as a prefix instead. Either way `docker network ls` will show you all your networks.  

traefik.toml
```
debug = false

logLevel = "ERROR"
defaultEntryPoints = ["https","http"]

[entryPoints]
  [entryPoints.http]
  address = ":80"
  [entryPoints.https]
  address = ":443"
  [entryPoints.https.tls]

[retry]

[docker]
exposedByDefault = false

[acme]
email = "your@email.here"
storage = "acme/certs.json"
entryPoint = "https"
onHostRule = true
[acme.httpChallenge]
entryPoint = "http"
```
Make sure not to add an redirect in this config so http defaults to https. The acme.httpChallenge requires http to validate certs. You can use dns if your dns provider supports it, can checkout the traefik docs for more on that. You can restrict https in the traefik labels in your compose files.