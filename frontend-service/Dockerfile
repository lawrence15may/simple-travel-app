FROM nginx:alpine

RUN apk add --no-cache gettext


# Remove default Nginx index to avoid conflicts
RUN rm -f /usr/share/nginx/html/index.html

COPY index.html.template /usr/share/nginx/html/index.html.template
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]

