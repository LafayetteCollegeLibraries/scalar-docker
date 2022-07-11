#!/bin/bash
cd /var/www/html && php /scripts/setup-db.php

# Set our PHP upload + memory defaults within an .ini file
cat <<-EOINI > /usr/local/etc/php/conf.d/scalar-uploads.ini
  upload_max_filesize = ${PHP_MAX_UPLOAD_SIZE}
  post_max_size = ${PHP_MAX_UPLOAD_SIZE}
  memory_limit = ${PHP_MEMORY_LIMIT}
EOINI

# uncomment rows of the scalar .htaccess file:
# 1. serve files in %{DOCUMENT_ROOT}/uploads if they exist
# 2-5: "To protect against malicious file uploads (e.g., PHP files) uncomment these lines
#       and make sure to set '/scalar' in the second line to the path to your Scalar install"
sed \
  -e "s/^#\(.*\%{DOCUMENT_ROOT}\/uploads\/.*\)/\1/g" \
  -e "s/^#\(RewriteCond \%{REQUEST_FILENAME} -f\)/\1/" \
  -e "s/^#\(RewriteCond \%{REQUEST_URI}.*\)\/scalar\/system\(.*\)/\1\/var\/www\/html\/system\2/" \
  -e "s/^#\(RewriteCond \%{REQUEST_FILENAME} !codeigniter\.php \[NC\]\)/\1/" \
  -e "s/^#\(RewriteCond \%{REQUEST_FILENAME} (\\\.php)\$ \[NC\]\)/\1/" \
  -e "s/^#\(RewriteRule \^(\.\*)\$ - \[R=404,L\]\)/\1/" \
  --in-place="" \
  "/var/www/html/.htaccess"

exec "$@"
