FROM babim/alpinebase

RUN apk --no-cache add curl tar php5-fpm php5-json php5-iconv php5-pgsql php5-pdo php5-dom php5-curl php5-mcrypt openssl supervisor nginx

# enable the mcrypt module
#RUN php5enmod mcrypt

# add ttrss as the only nginx site
ADD ttrss.nginx.conf /etc/nginx/conf.d/ttrss
#RUN rm /etc/nginx/conf.d/default

# fix user
RUN deluser xfs && delgroup www-data && \
    addgroup -g 33 www-data && adduser -D -H -G www-data -s /bin/false -u 33 www-data

# install ttrss and patch configuration
WORKDIR /var/www
RUN curl -SL https://git.tt-rss.org/git/tt-rss/archive/master.tar.gz | tar xzC /var/www --strip-components 1 \
    && chown www-data:www-data -R /var/www
RUN cp config.php-dist config.php

# expose only nginx HTTP port
EXPOSE 80

# complete path to ttrss
ENV SELF_URL_PATH http://localhost

# expose default database credentials via ENV in order to ease overwriting
ENV DB_NAME ttrss
ENV DB_USER ttrss
ENV DB_PASS ttrss

# always re-configure database with current ENV when RUNning container, then monitor all services
ADD configure-db.php /configure-db.php
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD php /configure-db.php && supervisord -c /etc/supervisor/conf.d/supervisord.conf
