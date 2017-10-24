sed '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride all/' /etc/apache2/apache2.conf > /tmp/apache2.conf
cp /tmp/apache2.conf /etc/apache2/apache2.conf

