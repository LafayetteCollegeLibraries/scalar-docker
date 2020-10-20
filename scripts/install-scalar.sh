#!/bin/bash
set -euo pipefail

install_directory="/var/www/html"
# uncomment rows of the scalar .htaccess file:
# 1. serve files in %{DOCUMENT_ROOT}/uploads if they exist
# 2-5: "To protect against malicious file uploads (e.g., PHP files) uncomment these lines
#       and make sure to set '/scalar' in the second line to the path to your Scalar install"
sed -i'' \
    -e 's/^#\(.*\%{DOCUMENT_ROOT}\/uploads\/.*\)/\1/g' \
    -e 's/^#\(RewriteCond \%{REQUEST_FILENAME} -f\)/\1/' \
    -e 's/^#\(RewriteCond \%{REQUEST_URI}.*\)\/scalar\/system\(.*\)/\1\/var\/www\/html\/system\2/' \
    -e 's/^#\(RewriteCond \%{REQUEST_FILENAME} !codeigniter\.php \[NC\]\)/\1/' \
    -e 's/^#\(RewriteCond \%{REQUEST_FILENAME} (\\\.php)\$ \[NC\]\)/\1/' \
    -e 's/^#\(RewriteRule \^(\.\*)\$ - \[R=404,L\]\)/\1/' \
    "$install_directory/.htaccess"

echo "Installed Scalar to $install_directory"
