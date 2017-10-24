FROM cahokia:base

COPY map/ /var/www/html/
COPY cahokia/ /var/www/html/cahokia
COPY .htaccess /var/www/html/

RUN mkdir -p /var/www/html/cahokia/data
RUN touch /var/www/html/cahokia/data/ready

CMD bash -c '/usr/sbin/apache2ctl -D FOREGROUND & /var/www/html/cahokia/bin/queue serve & cd /var/www/html/cahokia/geoserver && java -jar start.jar & wait'
