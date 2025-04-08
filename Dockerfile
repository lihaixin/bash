FROM nginx:stable-alpine
ARG TARGETARCH
LABEL vendor="15099.net" \
      release-date="2025-4-8" \
      version="0.1.2" \
      maintainer=noreply@15099.net
      
EXPOSE 80
RUN apk update && apk add pandoc bash
COPY --chmod=755 ./sh /usr/share/nginx/html/
COPY --chmod=755 ./README.md /usr/share/nginx/html/
COPY --chmod=755 ./index.sh /usr/share/nginx/html/
COPY --chmod=755 ./portainer.png /usr/share/nginx/html/
COPY --chmod=755 ./entrypoint.sh /entrypoint.sh
COPY --chmod=644 ./default.conf /etc/nginx/conf.d/default.conf

ENTRYPOINT ["/entrypoint.sh"]
