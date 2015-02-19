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

rm -f /var/www/etc/oattsincludes/config/*
cat >/var/www/etc/oattsincludes/config/server.php<<EOF
<?php
//if set, setting will override local settings
\$globalDebug = $DEBUG;

define("SECURE", $HTTP_SECURE);    // FOR HTTPS
define("SQL_SECURE",$SQL_SECURE);  //for mysql over ssl
define("BASEIP",'$BASEIP');

define("HOST", "$DBHOST");   // The host you want to connect to.
define("USER", "$DBUSER"); // The database username. 
define("PASSWORD", '$DBPASSWORD');// The database password. 
define("DATABASE", "$DBDB");    // The database name.


define("BASEDIR",'$BASEDIR');
define("WIDGETSDIR", 'widgets');
define("WIDGET_ABS_PATH", \$_SERVER["DOCUMENT_ROOT"] . "/" . BASEDIR . "/" . WIDGETSDIR);


//---###//---###//---###//---###//---###
define("BOOKMARKICONSDIR", 'bookmark_icons');
define("BOOKMARKICONS_ABS_PATH", \$_SERVER["DOCUMENT_ROOT"] . "/" . BASEDIR . "/" . BOOKMARKICONSDIR);
//---###//---###//---###//---###//---###


if (SECURE === false) {
    define("PROTOCOL",'http');
} else {
    define("PROTOCOL",'https');
}

\$baseURL = PROTOCOL."://". BASEIP. "/" . BASEDIR;
define('REGISTERED',10);
define('DATA_SIZE_LIMIT', 40000);
define("MAX_SESSION_IDLETIME", 3600* 15); //seconds-> hours
define("MAX_COOKIE_LIFETIME", 3600* 16); //seconds-> hours
define("HEART_BEAT_RATE", 1000* 60); //milliseconds-> seconds

define("DEFAULT_USER_AGENT","OATTS_CLIENT_v2_0"); //until we come up with something better

define('MAX_LOGIN_ATTEMPTS', 5);
define('MIN_LOGIN_WAIT', 60*2);
EOF

rm -f /var/www/html/oatts/includes/path*.php
cat >/var/www/html/oatts/includes/path.php<<EOF
<?php
    defined('ROOT_PATH') or define('ROOT_PATH','/var/www/etc/oattsincludes');
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
}
EOF

supervisord -c /etc/supervisord.conf
