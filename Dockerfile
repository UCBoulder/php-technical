FROM php:8.3-cli-alpine

WORKDIR /app

COPY index.php .

RUN php -l index.php

CMD ["php", "index.php"]
