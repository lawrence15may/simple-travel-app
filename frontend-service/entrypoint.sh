#!/bin/sh
set -e

# Default API_URL if not provided
if [ -z "$API_URL" ]; then
  API_URL="http://${HOSTNAME}:8080/api"
fi

# Inject API_URL into the template
echo "Injecting API_URL: $API_URL"
envsubst '${API_URL}' < /usr/share/nginx/html/index.html.template > /usr/share/nginx/html/index.html

# Start nginx
nginx -g 'daemon off;'

