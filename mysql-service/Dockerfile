FROM mysql:8

ENV MYSQL_ROOT_PASSWORD=root
ENV MYSQL_DATABASE=travel

COPY my.cnf /etc/mysql/conf.d/my.cnf
COPY init /docker-entrypoint-initdb.d/

EXPOSE 3306

