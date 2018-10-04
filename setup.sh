##############################
# Installation
##############################
sudo apt-get -y install mongodb python-pymongo python-crypto python-future python-bottle apache2 libapache2-mod-wsgi dokuwiki
git clone https://github.com/cea-sec/ivre
cd ivre
python setup.py build
sudo python setup.py install

##############################
# Setup
##############################
$ sudo -s
cd /var/www/html ## or depending on your version /var/www
rm index.html
ln -s /usr/local/share/ivre/web/static/* .
cd /var/lib/dokuwiki/data/pages
ln -s /usr/local/share/ivre/dokuwiki/doc
cd /var/lib/dokuwiki/data/media
ln -s /usr/local/share/ivre/dokuwiki/media/logo.png
ln -s /usr/local/share/ivre/dokuwiki/media/doc
cd /usr/share/dokuwiki
patch -p0 < /usr/local/share/ivre/dokuwiki/backlinks.patch
cd /etc/apache2/mods-enabled
for m in rewrite.load wsgi.conf wsgi.load ; do [ -L $m ] || ln -s ../mods-available/$m ; done
cd ../
# replace /usr/share/ivre/web/wsgi/app.wsgi with the actual location if needed:
echo 'Alias /cgi "/usr/share/ivre/web/wsgi/app.wsgi"' > conf-enabled/ivre.conf
echo '<Location /cgi>' >> conf-enabled/ivre.conf
echo 'SetHandler wsgi-script' >> conf-enabled/ivre.conf
echo 'Options +ExecCGI' >> conf-enabled/ivre.conf
echo 'Require all granted' >> conf-enabled/ivre.conf
echo '</Location>' >> conf-enabled/ivre.conf
sed -i 's/^\(\s*\)#Rewrite/\1Rewrite/' /etc/dokuwiki/apache.conf
echo 'WEB_GET_NOTEPAD_PAGES = "localdokuwiki"' >> /etc/ivre.conf
service apache2 reload  # or start
exit