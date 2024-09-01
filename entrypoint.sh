#!/bin/bash
pandoc /usr/share/nginx/html/README.md -s --metadata charset=utf-8 --metadata title="个人脚本管理系统" -o /usr/share/nginx/html/index.html
nginx -g "daemon off;"
