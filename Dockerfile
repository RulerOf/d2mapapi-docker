FROM tianon/wine

# D2 - Use a bind mount for this
VOLUME ["/game"]

# S6
ADD https://github.com/just-containers/s6-overlay/releases/download/v2.2.0.3/s6-overlay-amd64.tar.gz /tmp/
RUN gunzip -c /tmp/s6-overlay-amd64.tar.gz | tar -xf - -C /
ENTRYPOINT ["/init"]

# Wine
ENV WINEARCH=win32
ENV WINEDEBUG=-all
ENV WINEPREFIX=/wine
RUN useradd -M --uid 10000 web \
 && mkdir /wine \
 && chown web:web /wine
USER web
RUN winecfg
USER root

# d2mapapi
COPY ./root /
WORKDIR /app
EXPOSE 8080

# Faster cleanup — we're not keeping state
ENV S6_SERVICES_GRACETIME=100
ENV S6_KILL_FINISH_MAXTIME=100
ENV S6_KILL_GRACETIME=100

# stderr STFU (for debugging)
#ENV S6_LOGGING=1

# Health Checker
RUN apt-get update; apt-get -y install \
  jq \
  curl

HEALTHCHECK \
  --start-period=30s \
  CMD ["/bin/bash", "/healthcheck.sh"]
