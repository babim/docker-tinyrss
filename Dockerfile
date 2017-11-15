FROM babim/alpinebase

RUN apk --no-cache add curl tar php5-fpm php5-json php5-iconv php5-opcache php5-sqlite3 php5-pgsql php5-pdo php5-mysql \
    php5-mysqli php5-dom php5-gd php5-curl php5-mcrypt php5-pdo_dblib php5-pdo_sqlite php5-pdo_pgsql php5-pdo_mysql \
    php5-xml php5-xmlrpc php5-imap openssl supervisor nginx sphinx

# enable the mcrypt module
#RUN php5enmod mcrypt

# add ttrss as the only nginx site
ADD ttrss.nginx.conf /etc/nginx/conf.d/ttrss.conf
RUN rm /etc/nginx/conf.d/default.conf

# fix user
RUN deluser xfs && delgroup www-data && \
    addgroup -g 33 www-data && adduser -D -H -G www-data -s /bin/false -u 33 www-data

# install ttrss and patch configuration
WORKDIR /var/www
RUN curl -SL https://git.tt-rss.org/git/tt-rss/archive/master.tar.gz | tar xzC /var/www --strip-components 1 \
    && chown www-data:www-data -R /var/www
RUN mv /var/www /www-start && mkdir -p /var/www && \
    mkdir /run/nginx && touch /run/nginx/nginx.pid && \
    auser=www-data && \
    sed -i -e "/^user .*/cuser  $auser;" /etc/nginx/nginx.conf && \
    sed -i -e "/^#user .*/cuser  $auser;" /etc/nginx/nginx.conf

# expose only nginx HTTP port
EXPOSE 80

# complete path to ttrss
ENV SELF_URL_PATH http://localhost

# expose default database credentials via ENV in order to ease overwriting
ENV DB_HOST db
ENV DB_TYPE pgsql
ENV DB_PORT 5432
ENV DB_NAME ttrss
ENV DB_USER ttrss
ENV DB_PASS ttrss

# always re-configure database with current ENV when RUNning container, then monitor all services
ADD setup.sh /
RUN chmod +x /setup.sh
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

VOLUME ["/var/www"]
CMD sh /setup.sh && supervisord -c /etc/supervisor/conf.d/supervisord.conf
