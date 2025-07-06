FROM  lihaixin/shc AS build
COPY --chmod=755 sh/ikuai/ui.sh /asset/usr/bin/ui.sh
RUN shc -B -r -s -o /asset/usr/bin/ui -f /asset/usr/bin/ui.sh

FROM nginx:stable-alpine
ARG TARGETARCH
LABEL vendor="15099.net" \
      release-date="2025-7-7" \
      version="0.1.3" \
      maintainer=noreply@15099.net
      
EXPOSE 80
RUN apk update && apk add pandoc bash
COPY --chmod=755 ./sh /usr/share/nginx/html/
COPY --from=build --chmod=755 /asset/usr/bin/ui  /usr/share/nginx/html/ikuai/
COPY --chmod=755 ./README.md /usr/share/nginx/html/
COPY --chmod=755 ./index.sh /usr/share/nginx/html/
COPY --chmod=755 ./portainer.png /usr/share/nginx/html/
COPY --chmod=755 ./entrypoint.sh /entrypoint.sh
COPY --chmod=644 ./default.conf /etc/nginx/conf.d/default.conf

ENTRYPOINT ["/entrypoint.sh"]
