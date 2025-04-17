# Alpine-based Apache + PHP + SQLite for Webtrees
FROM php:8.1-apache-alpine

# Install necessary packages
RUN apk add --no-cache \
    apache2 \
    sqlite \
    php8-common php8-session php8-sqlite3 php8-dom php8-mbstring \
    php8-openssl php8-json php8-gd php8-zlib php8-curl \
    unzip wget bash

# Enable Apache mod_rewrite and basic config
RUN sed -i '/^#LoadModule rewrite_module/s/^#//' /etc/apache2/httpd.conf && \
    echo "ServerName localhost" >> /etc/apache2/httpd.conf && \
    echo '<Directory "/var/www/localhost/htdocs">' >> /etc/apache2/httpd.conf && \
    echo 'AllowOverride All' >> /etc/apache2/httpd.conf && \
    echo '</Directory>' >> /etc/apache2/httpd.conf

# Download latest Webtrees release
WORKDIR /var/www/localhost/htdocs
RUN wget -O webtrees.zip https://github.com/fisharebest/webtrees/releases/latest/download/webtrees.zip && \
    unzip webtrees.zip && \
    rm webtrees.zip && \
    chown -R apache:apache /var/www/localhost/htdocs

# Expose port
EXPOSE 80

# Start Apache in foreground
CMD ["/usr/sbin/httpd", "-D", "
