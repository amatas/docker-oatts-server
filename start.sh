#!/bin/bash

DBUSER=${DBUSER:-"oatts"}
DBPASSWORD=${DBPASSWORD:-"oatts"}
DBHOST=${DBHOST:-"database"}
DBDB=${DBDB:-"oatts"}
BASEIP=${BASEIP:-"127.0.0.1"}
BASEDIR=${BASEDIR:-""}
SQL_SECURE=${SQL_SECURE:-"false"}
HTTP_SECURE=${HTTP_SECURE:-"false"}
DEBUG=${DEBUG:-"false"}
SERVER_NAME=${SERVER_NAME:-"localhost"}

if [ ! -z $LOADDB ]; then
    /usr/bin/mysql -u$DBUSER -p$DBPASSWORD -h $DBHOST $DBDB < /var/www/schema.sql
    exit 0
fi

rm -f /var/www/etc/oattsincludes/config/server_config*.php
cat >/var/www/etc/oattsincludes/config/server_config.php<<EOF
<?php
\$globalDebug = false;   // if set, setting will override local settings

define("SECURE", $HTTP_SECURE);   // for HTTPS
define("SQL_SECURE", $SQL_SECURE);   //for mysql over ssl
define("BASEIP", '$BASEIP');
define("BASEDIR", '$BASEDIR');   // what goes after BASEIP - include leading slash if not empty
define("HOST", "$DBHOST");   // the host you want to connect to
define("USER", "$DBUSER");   // the database username
define("PASSWORD", '$DBPASSWORD');   // the database password
define("DATABASE", "$DBDB");   // the database name
?>
EOF

rm -f /var/www/html/oatts/includes/path*.php
cat >/var/www/html/oatts/includes/path.php<<EOF
<?php
defined('SERVER_CONTEXT_LABEL') or define('SERVER_CONTEXT_LABEL', 'RtF');   // also used as part of an OATTS App version / variant text suffix
defined('ROOT_PATH') or define('ROOT_PATH','/var/www/etc/oattsincludes');
?>
EOF

chown nginx:nginx /var/www -R

cat >/etc/nginx/conf.d/oatts-server.conf<<EOF
server {
    server_name $SERVER_NAME;
    root /var/www/html/oatts;
    client_max_body_size 5m;
    client_body_timeout 60;
    location ~ [^/]\.php(/|\$) {
            fastcgi_split_path_info ^(.+?\.php)(/.*)$;
            if (!-f \$document_root\$fastcgi_script_name) {
                    return 404;
            }
            fastcgi_pass 127.0.0.1:9000;
            fastcgi_index index.php;
            include fastcgi_params;
    }
    location ~ (\.xml|\.json) {
        return 403;
    }
}
EOF

supervisord -c /etc/supervisord.conf
