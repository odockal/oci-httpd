#!/bin/sh

### Install HTTPD
### Source and other details can be found at https://wiki.centos.org/HowTos/Https

yum install -y httpd

systemctl enable httpd

systemctl start httpd

### Prepare web content
cat /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<title>Let me run in container</title>
<body>

<h1>Local apache server from within the container</h1>
<p>Apache serving html page via https</p>

</body>
</html>
EOF

# Check for content on localhost
curl -Is localhost/index.html | head -n 1 | cut -d$' ' -f2
# 200

### Adding SSL to your web server
# Install SSL and start using SSL for web server
yum install -y mod_ssl openssl

# Prepare self-signed certificate
# Generate private key 
openssl genrsa -out ca.key 2048 

# Generate CSR 
openssl req -new -key ca.key -out ca.csr

# Generate Self Signed Key
openssl x509 -req -days 365 -in ca.csr -signkey ca.key -out ca.crt

# Copy the files to the correct locations
cp ca.crt /etc/pki/tls/certs
cp ca.key /etc/pki/tls/private/ca.key
cp ca.csr /etc/pki/tls/private/ca.csr

# possible selinux reneval for /etc/pki folder with new certificates
restorecon -RvF /etc/pki

### Update httpd config to use ssl
# Then we need to update the Apache SSL configuration file
vi +/SSLCertificateFile /etc/httpd/conf.d/ssl.conf

# Change the paths to match where the Key file is stored. If you've used the method above it will be
SSLCertificateFile /etc/pki/tls/certs/ca.crt

#Then set the correct path for the Certificate Key File a few lines below. If you've followed the instructions above it is:
SSLCertificateKeyFile /etc/pki/tls/private/ca.key

# Quit and save the file and then restart Apache
systemctl restart httpd

# All being well you should now be able to connect over https to your server and see a default Centos page. As the certificate is self signed 
# browsers will generally ask you whether you want to accept the certificate.

### Setting up the virtual host
# Just as you set VirtualHosts for http on port 80 so you do for https on port 443. A typical VirtualHost for a site on port 80 looks like this
<VirtualHost *:80>
        <Directory /var/www/vhosts/yoursite.com/httpdocs>
        AllowOverride All
        </Directory>
        DocumentRoot /var/www/vhosts/yoursite.com/httpdocs
        ServerName yoursite.com
</VirtualHost>

# To add a sister site on port 443 you need to add the following at the top of your file

NameVirtualHost *:443

# and then a VirtualHost record something like this:

<VirtualHost *:443>
        SSLEngine on
        SSLCertificateFile /etc/pki/tls/certs/ca.crt
        SSLCertificateKeyFile /etc/pki/tls/private/ca.key
        <Directory /var/www/vhosts/yoursite.com/httpsdocs>
        AllowOverride All
        </Directory>
        DocumentRoot /var/www/vhosts/yoursite.com/httpsdocs
        ServerName yoursite.com
</VirtualHost>

# Restart Apache again using
systemctl restart httpd

# You should now have a site working over https using a self-signed certificate. If you can't connect you may need to open the port on your firewall. 
# To do this amend your iptables rules:


#iptables -A INPUT -p tcp --dport 443 -j ACCEPT
#/sbin/service iptables save
#iptables -L -v
