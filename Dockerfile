ARG BASE_IMAGE=riscv64/eclipse-temurin:25-jre
FROM ${BASE_IMAGE}

# hook into docker BuildKit --platform support
# see https://docs.docker.com/engine/reference/builder/#automatic-platform-args-in-the-global-scope
ARG TARGETOS=linux
ARG TARGETARCH=riscv64
ARG TARGETVARIANT=

# The following three arg/env vars get used by the platform specific "install-packages" script
ARG EXTRA_DEB_PACKAGES=""
ARG EXTRA_DNF_PACKAGES=""
ARG EXTRA_ALPINE_PACKAGES=""
ARG FORCE_INSTALL_PACKAGES=1
ARG SKIP_KNOCKD=true
COPY build /build
RUN chmod +x /build/run.sh /build/ubuntu/*.sh /build/alpine/*.sh /build/ol/*.sh \
    && TARGET=${TARGETARCH}${TARGETVARIANT} \
    SKIP_KNOCKD=${SKIP_KNOCKD} \
    /build/run.sh install-packages

RUN /build/run.sh setup-user

EXPOSE 25565

ARG APPS_REV=1
ARG GITHUB_BASEURL=https://github.com

# RISC-V bootstrap: upstream uses prebuilt Go tools here. Until those tools are
# published for linux/riscv64, install conservative shims so the vanilla path can
# run and unsupported operational features fail explicitly.
COPY files/riscv64-tools/* /usr/local/bin/
RUN chmod 0755 /usr/local/bin/mc-server-runner /usr/local/bin/mc-monitor /usr/local/bin/rcon-cli /usr/local/bin/restify

# renovate: datasource=github-releases packageName=itzg/mc-image-helper versioning=loose
ARG MC_HELPER_VERSION=1.60.1
ARG MC_HELPER_BASE_URL=${GITHUB_BASEURL}/itzg/mc-image-helper/releases/download/${MC_HELPER_VERSION}
# used for cache busting local copy of mc-image-helper
ARG MC_HELPER_REV=1
RUN curl -fsSL ${MC_HELPER_BASE_URL}/mc-image-helper-${MC_HELPER_VERSION}.tgz \
  | tar -C /usr/share -zxf - \
    && ln -s /usr/share/mc-image-helper-${MC_HELPER_VERSION}/ /usr/share/mc-image-helper \
    && ln -s /usr/share/mc-image-helper/bin/mc-image-helper /usr/bin

VOLUME ["/data"]
WORKDIR /data

STOPSIGNAL SIGTERM

# End user MUST set EULA and change RCON_PASSWORD
ENV TYPE=VANILLA VERSION=LATEST EULA="" UID=1000 GID=1000 LC_ALL=en_US.UTF-8

COPY scripts/start* /image/scripts/

# Backward compatible shim for those with legacy entrypoint
RUN printf '%s\n' '#!/bin/bash' 'exec /image/scripts/start "$@"' > /start \
  && chmod 0755 /start

COPY scripts/auto/* /image/scripts/auto/
COPY scripts/shims/* /image/scripts/shims/
COPY files/* /image/
RUN chmod 0755 /image/scripts/start* /image/scripts/auto/* /image/scripts/shims/* \
  && ln -s /image/scripts/shims/* /usr/local/bin/

RUN curl -fsSL -o /image/Log4jPatcher.jar https://github.com/CreeperHost/Log4jPatcher/releases/download/v1.0.1/Log4jPatcher-1.0.1.jar

RUN dos2unix /image/scripts/start* /image/scripts/auto/*

ENTRYPOINT [ "/image/scripts/start" ]
HEALTHCHECK --start-period=2m --retries=2 --interval=30s CMD mc-health

ARG BUILDTIME=local
ARG VERSION=local
ARG REVISION=local
RUN printf 'buildtime=%s\nversion=%s\nrevision=%s\n' \
  "$BUILDTIME" "$VERSION" "$REVISION" > /etc/image.properties
