FROM centos:latest

RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm && \
    yum install -y yum-utils && \
    yum-config-manager --enable remi-php72 && \
    yum update -y && \
    yum install -y \
    php.x86_64 \
    php-bcmath.x86_64 \
    php-cli.x86_64 \
    php-common.x86_64 \
    php-devel.x86_64 \
    php-gd.x86_64 \
    php-intl.x86_64 \
    php-json.x86_64 \
    php-mbstring.x86_64 \
    php-mcrypt.x86_64 \
    php-mysqlnd.x86_64 \
    php-pdo.x86_64 \
    php-pear.noarch \
    php-xml.x86_64 \
    php-ast.x86_64 \
    php-opcache.x86_64 \
    php-pecl-zip.x86_64 \
    php-fpm.x86_64 \
    libmcrypt-devel.x86_64 \
    php-pecl-memcached.x86_64


RUN yum install -y httpd-devel.x86_64 wget memcached unzip

RUN mkdir -p /var/www/html/

COPY mod_deflate.conf /etc/httpd/conf.d/mod_deflate.conf

RUN usermod -u 1000 apache && ln -sf /dev/stdout /var/log/httpd/access_log && ln -sf /dev/stderr /var/log/httpd/error_log

RUN unlink /etc/localtime && ln -s /usr/share/zoneinfo/Asia/Bangkok /etc/localtime


RUN rm /etc/httpd/conf.d/welcome.conf \
    && sed -i -e "s/Options\ Indexes\ FollowSymLinks/Options\ -Indexes\ +FollowSymLinks/g" /etc/httpd/conf/httpd.conf \
    && sed -i "s/\/var\/www\/html/\/var\/www/g" /etc/httpd/conf/httpd.conf \
    && echo "FileETag None" >> /etc/httpd/conf/httpd.conf \
    && sed -i -e "s/expose_php\ =\ On/expose_php\ =\ Off/g" /etc/php.ini \
    && sed -i -e "s/\;error_log\ =\ php_errors\.log/error_log\ =\ \/var\/log\/php_errors\.log/g" /etc/php.ini \
    && echo "ServerTokens Prod" >> /etc/httpd/conf/httpd.conf \
    && echo "ServerSignature Off" >> /etc/httpd/conf/httpd.conf \
    && echo "ErrorDocument 400 /error_msg" >> /etc/httpd/conf/httpd.conf \
    && echo "IncludeOptional sites-enabled/*.conf" >> /etc/httpd/conf/httpd.conf \
    && sed -i -e "s/#LoadModule mpm_event_module modules\/mod_mpm_event.so/LoadModule mpm_event_module modules\/mod_mpm_event.so/g" /etc/httpd/conf.modules.d/00-mpm.conf \
    && sed -i -e "s/LoadModule mpm_prefork_module modules\/mod_mpm_prefork.so/#LoadModule mpm_prefork_module modules\/mod_mpm_prefork.so/g" /etc/httpd/conf.modules.d/00-mpm.conf


COPY php.conf /etc/httpd/conf.d/php.conf
COPY www.conf /etc/php-fpm.d/www.conf
RUN  mkdir /etc/httpd/sites-enabled && mkdir /var/run/php-fpm