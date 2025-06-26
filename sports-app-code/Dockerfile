# Dockerfile.mysql
FROM mysql:5.7
# copy new schema into the directory where MySQL runs init scripts
COPY init-sports.sql /docker-entrypoint-initdb.d/