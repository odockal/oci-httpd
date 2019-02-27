FROM fedora:latest
MAINTAINER Ondrej Dockal email: odockal@redhat.com

RUN yum install -y httpd mod_ssl openssl procps hostname; yum clean all

COPY html var/www/html/
COPY conf.d /etc/httpd/conf.d/

COPY keys/*.crt /etc/pki/tls/certs/
COPY keys/*.key /etc/pki/tls/private/

# works only during build, not persistent
# RUN echo "127.0.0.1 www.mysec.com" >> /etc/hosts

RUN "/usr/libexec/httpd-ssl-gencerts"

CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]

EXPOSE 80
EXPOSE 443
