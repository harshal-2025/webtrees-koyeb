FROM php:8.0-apache

# Install necessary packages using apt (Debian/Ubuntu)
RUN apt-get update && apt-get install -y \
    apache2 \
    sqlite3 \
    libsqlite3-dev \
    libonig-dev \
    libzip-dev \
    libcurl4-openssl-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    unzip \
    wget \
    bash \
    && docker-php-ext-install pdo_sqlite mbstring zip curl gd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download and install webtrees
RUN wget https://github.com/fisharebest/webtrees/releases/download/2.1.16/webtrees-2.1.16.zip \
    && unzip webtrees-2.1.16.zip -d /var/www/html/ \
    && rm webtrees-2.1.16.zip \
    && mv /var/www/html/webtrees /var/www/html/webtrees-app \
    && chown -R www-data:www-data /var/www/html/webtrees-app

# Enable Apache rewrite module
RUN a2enmod rewrite

# Configure Apache for webtrees
COPY apache-config.conf /etc/apache2/sites-available/000-default.conf

# Expose port 80
EXPOSE 80

# Start Apache in foreground
CMD ["apache2-foreground"]
