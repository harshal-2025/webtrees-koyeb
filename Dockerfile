# Use official PHP 8.3 Apache image (current stable)
FROM php:8.3-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libzip-dev \
    libonig-dev \
    libxml2-dev \
    libsqlite3-dev \
    sqlite3 \
    unzip \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Configure and install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    exif \
    gd \
    intl \
    mbstring \
    opcache \
    pdo_sqlite \
    soap \
    xml \
    zip

# PHP configuration
RUN echo "memory_limit = 256M" > /usr/local/etc/php/conf.d/memory.ini && \
    echo "upload_max_filesize = 20M" > /usr/local/etc/php/conf.d/uploads.ini && \
    echo "post_max_size = 20M" >> /usr/local/etc/php/conf.d/uploads.ini && \
    echo "max_execution_time = 90" > /usr/local/etc/php/conf.d/timeouts.ini

# Apache configuration
RUN a2enmod rewrite && \
    echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Install webtrees
RUN wget -q https://github.com/fisharebest/webtrees/releases/download/2.1.16/webtrees-2.1.16.zip -O /tmp/webtrees.zip && \
    unzip -q /tmp/webtrees.zip -d /var/www/html/ && \
    mv /var/www/html/webtrees /var/www/html/webtrees-app && \
    rm /tmp/webtrees.zip && \
    chown -R www-data:www-data /var/www/html/webtrees-app

# Copy Apache virtual host config
COPY apache-config.conf /etc/apache2/sites-available/000-default.conf

EXPOSE 80
CMD ["apache2-foreground"]
