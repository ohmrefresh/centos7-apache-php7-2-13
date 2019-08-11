FROM centos:7

ENV PHP_VERSION 72
ENV ORACLE_OCI8 2.2.0


RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm && \
    yum install -y http://mirror.centos.org/centos/7/os/x86_64/Packages/libaio-0.3.109-13.el7.x86_64.rpm \
    yum groupinstall -y "Development tools" \
    yum install -y systemtap-sdt-devel \
    yum install -y yum-utils && \
    yum-config-manager --enable remi-php$CHROME_VERSION && \
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
    httpd-devel.x86_64 \
    wget \
    php-pear \
    make \
    unzip

RUN mkdir -p /var/www/html/ && mkdir -p /tmp/ && mkdir -p /etc/httpd/sites-enabled && mkdir -p /var/run/php-fpm

#copy config
COPY config/mod_deflate.conf /etc/httpd/conf.d/mod_deflate.conf
COPY config/oracle/* /tmp/
COPY config/php.conf /etc/httpd/conf.d/php.conf
COPY config/www.conf /etc/php-fpm.d/www.conf
COPY config/httpd.conf /etc/httpd/conf/httpd.conf

RUN usermod -u 1000 apache && ln -sf /dev/stdout /var/log/httpd/access_log && ln -sf /dev/stderr /var/log/httpd/error_log

#install oracle client
RUN rpm -ivh /tmp/*.rpm
RUN cd /tmp/ && pear download pecl/oci8-$ORACLE_OCI8 && tar -xvzf oci8-$ORACLE_OCI8.tgz && cd oci8-$ORACLE_OCI8 && phpize
RUN export PHP_DTRACE=yes && pecl install oci8 && echo "extension=oci8.so" >> /etc/php.ini


RUN rm /etc/httpd/conf.d/welcome.conf \
    && sed -i -e "s/expose_php\ =\ On/expose_php\ =\ Off/g" /etc/php.ini \
    && sed -i -e "s/\;error_log\ =\ php_errors\.log/error_log\ =\ \/var\/log\/php_errors\.log/g" /etc/php.ini \
    && sed -i -e "s/#LoadModule mpm_event_module modules\/mod_mpm_event.so/LoadModule mpm_event_module modules\/mod_mpm_event.so/g" /etc/httpd/conf.modules.d/00-mpm.conf \
    && sed -i -e "s/LoadModule mpm_prefork_module modules\/mod_mpm_prefork.so/#LoadModule mpm_prefork_module modules\/mod_mpm_prefork.so/g" /etc/httpd/conf.modules.d/00-mpm.conf

RUN rm -rf /tmp

WORKDIR /var/www/html/