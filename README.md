# d2mapapi-docker

This is a docker container for running the [D2MapAPI project](https://github.com/jcageman/d2mapapi) on Linux.

## Usage

### Docker Run

Download the repo and build the container:
```shell
docker build -t d2mapapi https://github.com/RulerOf/d2mapapi-docker.git
```

Then supply a copy of Diablo II 1.13c as a bind mount at `/game` inside of the container when you run it.

For exmaple, if you have a copy of D2 at `/srv/d2`:

```shell
docker run -d --rm -v /srv/d2:/game --name d2mapapi d2mapapi:latest
```

### Docker Compose

Again, assuming you have a copy of d2 at `/srv/d2`, create your compose file:

```yml
version: "3.3"
services:
  d2mapapi:
    build: https://github.com/RulerOf/d2mapapi-docker.git
    volumes:
      - /srv/d2:/game
```

Then build and start your container:
```shell
docker-compose up -d --build
```

## Notes

This container uses the excellent [s6 overlay](https://github.com/just-containers/s6-overlay) to manage the filesystem and processes. The [healthcheck script](root/healthcheck.sh) runs every 30 seconds. It selects a random map seed queries the API for the map data for 5 random areas from that seed. If any of the steps fail, the healthcheck script will restart the d2mapapi server.
