#!/bin/bash
pandoc /usr/share/nginx/html/README.md -s --metadata charset=utf-8 --metadata title="bash" -o /usr/share/nginx/html/index.html
nginx -g "daemon off;"
