FROM inclusivedesign/php

ADD data /var/www
ADD start.sh /usr/local/sbin/start.sh
    
RUN yum -y install mariadb && \
    	chmod +x /usr/local/sbin/start.sh

EXPOSE 80

CMD ["/usr/local/sbin/start.sh"]
