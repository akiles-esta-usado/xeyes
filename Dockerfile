ARG BASE_IMAGE=ubuntu:22.04

FROM ${BASE_IMAGE} as xeyes
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Europe/Vienna \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    TOOLS=/opt \
    PDK_ROOT=/opt/pdks

RUN apt update && \
    apt install -y --no-install-recommends x11-apps && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    apt -y autoremove --purge && \
    apt -y clean

CMD ["xeyes"]