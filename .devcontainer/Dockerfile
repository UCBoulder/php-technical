ARG VARIANT=8.5-bookworm
FROM mcr.microsoft.com/devcontainers/php:4-${VARIANT}

RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends libsqlite3-dev \
    && docker-php-ext-install pdo_sqlite \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY php-memory-limit.ini /usr/local/etc/php/conf.d/php-memory-limit.ini
