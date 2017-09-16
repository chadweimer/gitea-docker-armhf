FROM multiarch/alpine:armhf-v3.5

EXPOSE 22 3000

RUN apk --no-cache add \
    su-exec \
    ca-certificates \
    sqlite \
    bash \
    git \
    linux-pam \
    s6 \
    curl \
    openssh \
    tzdata \
    wget
RUN addgroup \
    -S -g 1000 \
    git && \
  adduser \
    -S -H -D \
    -h /data/git \
    -s /bin/bash \
    -u 1000 \
    -G git \
    git && \
  echo "git:$(date +%s | sha256sum | base64 | head -c 32)" | chpasswd

ENV GITEA_VERSION 1.1.4
ENV USER git
ENV GITEA_CUSTOM /data/gitea
ENV GODEBUG=netdns=go

VOLUME ["/data"]

ENTRYPOINT ["/usr/bin/entrypoint"]
CMD ["/bin/s6-svscan", "/etc/s6"]

# COPY docker /
RUN wget -O gitea_src.tar.gz https://github.com/go-gitea/gitea/archive/v$GITEA_VERSION.tar.gz && \
    tar -xzf gitea_src.tar.gz && \
    rm gitea_src.tar.gz && \
    cp --verbose -r gitea-$GITEA_VERSION/docker/. / && \
    rm -rf gitea-$GITEA_VERSION
# COPY gitea /app/gitea/gitea
RUN mkdir -p /app/gitea && \
    wget -O /app/gitea/gitea https://github.com/go-gitea/gitea/releases/download/v$GITEA_VERSION/gitea-$GITEA_VERSION-linux-arm-7 && \
    chmod +x /app/gitea/gitea
