FROM ubuntu:wily

MAINTAINER Fábio Luciano <fabioluciano@php.net>

ENV TIMEZONE            America/Sao_Paulo
ENV PHP_MEMORY_LIMIT    512M
ENV MAX_UPLOAD          50M
ENV PHP_MAX_FILE_UPLOAD 200
ENV PHP_MAX_POST        100M

ADD files/instantclient.zip /opt/

RUN sed -i 's/http:\/\//http:\/\/br./g' /etc/apt/sources.list
RUN apt-get update --fix-missing \
  && apt-get dist-upgrade -y \
  && apt-get install --no-install-recommends -y curl autoconf g++ gcc curl git \
  make apache2 libapache2-mod-php5 unzip supervisor ca-certificates libaio1 libaio-dev\
  && apt-get install --no-install-recommends -y php5 php5-dev php5-gd \
    php5-geoip php5-mcrypt php5-memcache php5-xsl php5-memcached php5-pgsql \
    php5-curl php5-mongo php5-mysql php5-imagick php5-cli php-pear \
    php5-dev php5-ldap \
  && unzip -q /opt/instantclient.zip -d /opt ; rm  /opt/instantclient.zip \
  && ln -s /opt/instantclient/libclntsh.so.12.1 /opt/instantclient/libclntsh.so \
  && ln -s /opt/instantclient/libocci.so.12.1 /opt/instantclient/libocci.so \
  && printf 'instantclient,/opt/instantclient' | pecl install oci8-2.0.10 \
  && echo 'extension=oci8.so' > /etc/php5/mods-available/oci8.ini \
  && ln -s /etc/php5/mods-available/oci8.ini /etc/php5/cli/conf.d/ \
  && apt-get remove --purge -y software-properties-common \
  && apt-get autoremove -y && apt-get clean && apt-get autoclean \
  && echo -n > /var/lib/apt/extended_states \
  && rm -rf /var/lib/apt/lists/* /usr/share/man/?? /usr/share/man/??_*

COPY files/supervisord.conf /etc/supervisor/supervisord.conf

VOLUME ["/var/www"]

EXPOSE 80 443

ENTRYPOINT ["supervisord", "--nodaemon", "-c", "/etc/supervisor/supervisord.conf", "-j", "/tmp/supervisord.pid", "-l", "/var/log/supervisord.log"]
