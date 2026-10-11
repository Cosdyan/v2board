FROM php:8.1-fpm-bookworm
RUN apt-get update && apt-get install -y --no-install-recommends nginx supervisor git unzip curl ca-certificates libzip-dev libpng-dev libjpeg62-turbo-dev libfreetype6-dev libonig-dev libicu-dev libxml2-dev \
 && docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j"$(nproc)" bcmath gd intl mbstring pcntl pdo_mysql zip opcache \
 && pecl install redis-5.3.7 && docker-php-ext-enable redis \
 && rm -rf /var/lib/apt/lists/* /tmp/pear
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer
WORKDIR /var/www/html
COPY . .
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader --no-progress \
 && mkdir -p storage/logs storage/framework/{cache/data,sessions,views} bootstrap/cache \
 && chown -R www-data:www-data storage bootstrap/cache \
 && chmod -R ug+rwX storage bootstrap/cache \
 && rm -f /etc/nginx/sites-enabled/default
COPY docker/nginx.conf /etc/nginx/conf.d/v2board.conf
COPY docker/supervisord.conf /etc/supervisor/conf.d/v2board.conf
EXPOSE 8080
CMD ["/usr/bin/supervisord","-n","-c","/etc/supervisor/conf.d/v2board.conf"]
