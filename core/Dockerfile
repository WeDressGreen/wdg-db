FROM postgres:15-alpine

RUN apk add --no-cache postgresql-contrib

COPY ./init.sql /docker-entrypoint-initdb.d/