# runnable base
FROM rpawel/ubuntu:trusty

RUN apt-get -q -y update \
 && apt-get dist-upgrade -y --no-install-recommends \
# Packages
 && DEBIAN_FRONTEND=noninteractive apt-get install -y -q apache2 libapache2-mod-php5 \
  php5 php5-cli php5-dev php-pear php5-common php5-apcu \
  php5-mcrypt php5-gd php5-mysql php5-curl php5-json php5-intl php5-xsl libssh2-php \
  php5-memcached php5-memcache \
  imagemagick graphicsmagick graphicsmagick-libmagick-dev-compat php5-imagick trimage \
  exim4 git subversion \
 && php5enmod mcrypt

# Config
ADD ./config /etc/
RUN update-exim4.conf \
 && a2enmod actions alias headers deflate rewrite remoteip \
 && a2dismod autoindex \
 && a2disconf other-vhosts-access-log \
 && useradd -d /var/www/app --no-create-home --shell /bin/bash -g www-data -G adm user \
 && mkdir -p /var/log/app; chmod 775 /var/log/app/; chown user:www-data /var/log/app/ \
 && mkdir -p /var/log/php5; chmod 775 /var/log/php5; chown www-data:www-data /var/log/php5/ \
 && mkdir -p /var/log/supervisor \
 && DEBIAN_FRONTEND=newt

ADD build.sh /
ADD run.sh /

RUN chmod +x /build.sh /run.sh \
 && bash /build.sh && rm -f /build.sh

# PORTS
EXPOSE 80

HEALTHCHECK --interval=30s --timeout=10s CMD curl --fail http://localhost/ || exit 1

ENTRYPOINT ["/run.sh"]
