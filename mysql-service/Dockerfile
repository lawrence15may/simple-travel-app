FROM mysql:8

# Set MySQL root password
ENV MYSQL_ROOT_PASSWORD=root

# This creates the database BEFORE running your SQL scripts
ENV MYSQL_DATABASE=travel

# MySQL config (optional, if you have custom config)
#COPY my.cnf /etc/mysql/conf.d/
# Ensures MySQL loads the config
#RUN chmod 0444 /etc/mysql/conf.d/my.cnf

# Copy ALL initialization SQL scripts into MySQL's init directory
# These run ONLY when the database directory is empty
COPY init/*.sql /docker-entrypoint-initdb.d/

# Ensure SQL scripts have correct permissions
RUN chmod 644 /docker-entrypoint-initdb.d/*.sql

EXPOSE 3306

