FROM amazonlinux:2018.03

# File Author / Maintainer
MAINTAINER ljay

# update amazon software repo
RUN yum -y update && yum -y install shadow-utils

#
# All installed packages via YUM are amazon linux maintained and prepared to run best on amazon-linux distro
#

# nginx 1.12.x
# Check if really required to install following mods
RUN yum install nginx -y \
	&& yum install -y nginx-mod-http-geoip \
	nginx-mod-http-image-filter \
	nginx-mod-http-perl \
	nginx-mod-http-xslt-filter \
	nginx-mod-mail \
	nginx-mod-stream

RUN yum install -y php56-cli php56-common php56-fpm php56-gd php56-gmp php56-intl \
	php56-mbstring php56-mcrypt php56-mysqlnd php56-opcache php56-pdo php56-pear \
	php56-pecl-igbinary php56-pecl-jsonc php56-pecl-redis php56-process \
	php56-soap php56-xml

# docker container usually wont add that file which is required by some init scripts
RUN echo "" >> /etc/sysconfig/network

## Add NGINX and PHP-FPM service start to boot sequence
RUN chkconfig nginx on && chkconfig php-fpm on

# nginx base config
COPY ./etc/*.conf /tmp/
RUN mv -f /tmp/nginx.conf /etc/nginx/ \
	&& mv /tmp/status.conf /etc/nginx/conf.d/ \
	&& mv /tmp/virtual.conf /etc/nginx/conf.d/ \
	&& mv -f /tmp/php-fpm_www.conf /etc/php-fpm.d/www.conf

# cleanup
RUN yum clean all && rm -rf /tmp/* /var/tmp/*

EXPOSE 80

#CMD ["nginx", "-g", "daemon off;"]
COPY services.sh /services.sh

WORKDIR /var/www/html

# Sample index files
COPY ./index.php /var/www/html

CMD /services.sh
