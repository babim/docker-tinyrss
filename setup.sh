#!/usr/bin/with-contenv sh

if [ -z "`ls /etc/php`" ]; then 
	cp -R /www-start/* /var/www
fi
    
if [ ! -e /var/www/config.php ];  then
    cat > /var/www/config.php <<EOF
<?php
// See config.php-dist for an example config file
define('DB_TYPE', '${DB_TYPE}');
define('DB_HOST', '${DB_HOST}');
define('DB_NAME', '${DB_NAME}');
define('DB_USER', '${DB_USER}');
define('DB_PASS', '${DB_PASS}');
define('DB_PORT', '${DB_PORT}');
define('MYSQL_CHARSET', 'UTF8');
define('SELF_URL_PATH', '${BASE_URL}');
define('_SKIP_SELF_URL_PATH_CHECKS', true);
define('FEED_CRYPT_KEY', '${FEED_CRYPT_KEY}');
define('SINGLE_USER_MODE', false);
define('SIMPLE_UPDATE_MODE', false);
define('PHP_EXECUTABLE', '/usr/bin/php5');
define('LOCK_DIRECTORY', 'lock');
define('CACHE_DIR', 'cache');
define('ICONS_DIR', 'feed-icons');
define('ICONS_URL', 'feed-icons');
define('AUTH_AUTO_CREATE', true);
define('AUTH_AUTO_LOGIN', true);
define('FORCE_ARTICLE_PURGE', 0);
define('SPHINX_SERVER', 'localhost:9312');
define('SPHINX_INDEX', 'ttrss, delta');
define('ENABLE_REGISTRATION', false);
define('REG_NOTIFY_ADDRESS', '${MAIL_REGISTRATIONS}');
define('REG_MAX_USERS', 1);
define('SESSION_COOKIE_LIFETIME', 86400);
define('SMTP_FROM_NAME', '${MAIL_SENDER}');
define('SMTP_FROM_ADDRESS', '${MAIL_FROM}');
define('DIGEST_SUBJECT', '[tt-rss] New news for the past 24h');
define('SMTP_SERVER', '${MAIL_HOST}');
define('SMTP_LOGIN', '${MAIL_USER}');
define('SMTP_PASSWORD', '${MAIL_PASS}');
define('SMTP_SECURE', '${MAIL_SECURE}');
define('CHECK_FOR_UPDATES', true);
define('ENABLE_GZIP_OUTPUT', false);
define('PLUGINS', 'auth_internal, note');
define('LOG_DESTINATION', 'sql');
define('CONFIG_VERSION', 26);
?>
EOF
fi

# set ID docker run
agid=${agid:-$auid}
auser=${auser:-www-data}

if [[ -z "${auid}" ]]; then
  echo "start"
elif [[ "$auid" = "0" ]] || [[ "$aguid" == "0" ]]; then
	echo "run in user root"
	auser=root
	#export APACHE_RUN_USER=$auser
	#export APACHE_RUN_GROUP=$auser
	sed -i -e "/^user = .*/cuser = $auser" /etc/php5/php-fpm.conf
	sed -i -e "/^group = .*/cgroup = $auser" /etc/php5/php-fpm.conf
	sed -i -e "/^user .*/cuser  $auser;" /etc/nginx/nginx.conf
	sed -i -e "/^#user .*/cuser  $auser;" /etc/nginx/nginx.conf
elif id $auid >/dev/null 2>&1; then
        echo "UID exists. Please change UID"
else
if id $auser >/dev/null 2>&1; then
        echo "user exists"
	sed -i -e "/^user = .*/cuser = $auser" /etc/php5/php-fpm.conf
	sed -i -e "/^group = .*/cgroup = $auser" /etc/php5/php-fpm.conf
	sed -i -e "/^user .*/cuser  $auser;" /etc/nginx/nginx.conf
	sed -i -e "/^#user .*/cuser  $auser;" /etc/nginx/nginx.conf
	#export APACHE_RUN_USER=$auser
	#export APACHE_RUN_GROUP=$auser
	# usermod alpine
		deluser $auser && delgroup $auser
		addgroup -g $agid $auser && adduser -D -H -G $auser -s /bin/false -u $auid $auser
	# usermod ubuntu/debian
		#usermod -u $auid $auser
		#groupmod -g $agid $auser
else
        echo "user does not exist"
	#export APACHE_RUN_USER=$auser
	#export APACHE_RUN_GROUP=$auser
	# create user alpine
	addgroup -g $agid $auser && adduser -D -H -G $auser -s /bin/false -u $auid $auser
	# create user ubuntu/debian
	#groupadd -g $agid $auser && useradd --system --uid $auid --shell /usr/sbin/nologin -g $auser $auser
	sed -i -e "/^user = .*/cuser = $auser" /etc/php5/php-fpm.conf
	sed -i -e "/^group = .*/cgroup = $auser" /etc/php5/php-fpm.conf
	sed -i -e "/^user .*/cuser  $auser;" /etc/nginx/nginx.conf
	sed -i -e "/^#user .*/cuser  $auser;" /etc/nginx/nginx.conf
fi

fi
