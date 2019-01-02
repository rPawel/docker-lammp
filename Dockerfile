# runnable base
FROM rpawel/ubuntu:bionic

RUN apt-get -q -y update \
 && apt-get dist-upgrade -y --no-install-recommends \
# Packages
 && DEBIAN_FRONTEND=noninteractive apt-get install -y -q apache2 libapache2-mod-php \
  php php-cli php-dev php-pear php-common php-apcu \
  php-gd php-mysql php-curl php-json php-intl php-xsl php-ssh2 php-mbstring \
  php-zip php-memcached php-memcache php-imap \
  imagemagick graphicsmagick graphicsmagick-libmagick-dev-compat php-imagick trimage \
  libmcrypt-dev libmcrypt4 \
  exim4 git subversion \
 && pecl install mcrypt-1.0.1 \
 && phpenmod imap && phpdismod xdebug

# Config
ADD ./config /etc/
RUN update-exim4.conf \
 && phpenmod mcrypt \
 && a2enmod actions alias headers deflate rewrite remoteip \
 && a2dismod -f autoindex \
 && a2disconf other-vhosts-access-log \
 && useradd -d /var/www/app --no-create-home --shell /bin/bash -g www-data -G adm user \
 && mkdir -p /var/log/php; chmod 775 /var/log/php; chown www-data:www-data /var/log/php/ \
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
