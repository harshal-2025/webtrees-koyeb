# Use official PHP 8.2 Apache image (LTS supported until 2025)
FROM php:8.2-apache

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libonig-dev \
    libxml2-dev \
    libsqlite3-dev \
    sqlite3 \
    unzip \
    wget \
    pkg-config \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure pdo_sqlite --with-sqlite3 \
    && docker-php-ext-install -j$(nproc) \
    exif \
    gd \
    intl \
    mbstring \
    opcache \
    pdo_sqlite \
    soap \
    xml \
    zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure PHP settings
RUN echo "memory_limit = 256M" > /usr/local/etc/php/conf.d/memory-limit.ini && \
    echo "upload_max_filesize = 20M" >> /usr/local/etc/php/conf.d/uploads.ini && \
    echo "post_max_size = 20M" >> /usr/local/etc/php/conf.d/uploads.ini && \
    echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/opcache.ini && \
    echo "opcache.memory_consumption=128" >> /usr/local/etc/php/conf.d/opcache.ini

# Enable Apache modules
RUN a2enmod rewrite headers

# Download and install webtrees
RUN wget -q https://github.com/fisharebest/webtrees/releases/download/2.1.16/webtrees-2.1.16.zip -O /tmp/webtrees.zip && \
    unzip -q /tmp/webtrees.zip -d /var/www/html/ && \
    mv /var/www/html/webtrees /var/www/html/webtrees-app && \
    rm /tmp/webtrees.zip && \
    chown -R www-data:www-data /var/www/html/webtrees-app

# Copy Apache config
COPY apache-config.conf /etc/apache2/sites-available/000-default.conf

# Health check (for Koyeb monitoring)
HEALTHCHECK --interval=30s --timeout=3s \
    CMD curl -f http://localhost/ || exit 1

EXPOSE 80
CMD ["apache2-foreground"]
