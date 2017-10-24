FROM ubuntu:16.04

RUN apt-get update

# Apache2/PHP7.0
RUN apt-get install -y apache2 php7.0 libapache2-mod-php7.0
RUN a2enmod php7.0 proxy proxy_http rewrite
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf
COPY enable_htaccess.sh /root
RUN bash /root/enable_htaccess.sh
EXPOSE 80

# GRASS
RUN apt-get install -y software-properties-common tzdata
RUN dpkg-reconfigure -f noninteractive tzdata
RUN add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable
RUN apt-get update
RUN apt-get install -y grass

# Need Later
RUN apt-get install -y default-jre curl

