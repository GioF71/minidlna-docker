ARG IMAGE_TAG="${IMAGE_TAG:-bullseye}"
FROM debian:${IMAGE_TAG} AS base
ARG USE_APT_PROXY

RUN mkdir -p /app
RUN mkdir -p /app/conf

COPY app/conf/01-apt-proxy /app/conf/

RUN if [ "${USE_APT_PROXY}" = "Y" ]; then \
  echo "Builind using apt proxy"; \
  cp /app/conf/01-apt-proxy /etc/apt/apt.conf.d/01-apt-proxy; \
  cat /etc/apt/apt.conf.d/01-apt-proxy; \
  else \
  echo "Building without apt proxy"; \
  fi

RUN apt-get update &&\
  DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
  apt-get install minidlna -y && \
  rm -rf /var/lib/apt/lists/*

FROM scratch
COPY --from=base / /
LABEL maintainer="GioF71 <https://github.com/GioF71>"
CMD ["bash"]

