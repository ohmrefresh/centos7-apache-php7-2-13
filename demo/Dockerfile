FROM ohmrefresh/centos7-apache-php7-2-13:0.6

#copy web resource
RUN mkdir -p /var/www/html/web
# ADD web/ /var/www/html/web/

WORKDIR /var/www/html/web/


#copy config
ADD web.conf /etc/httpd/sites-available/web.conf
RUN  ln -s /etc/httpd/sites-available/web.conf /etc/httpd/sites-enabled/web.conf

#start service
RUN  systemctl enable php-fpm && systemctl enable httpd
CMD  php-fpm -R; apachectl stop; httpd -D FOREGROUND