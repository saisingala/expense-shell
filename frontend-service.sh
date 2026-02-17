#!bin/bash

vim /etc/nginx/default.d/expense.conf

proxy_http_version 1.1;

location /api/ { proxy_pass http://frontend-1.khaleja.fun:8080/; }

location /health {
  stub_status on;
  access_log off;
}