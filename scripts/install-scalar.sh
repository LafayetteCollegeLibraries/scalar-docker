#!/bin/bash
set -euo pipefail

# default to the most recent tagged version if no version provided
if [[ -z ${VERSION+x} || "$VERSION" = "latest" ]]; then
  VERSION=$(curl -s "https://api.github.com/repos/anvc/scalar/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
fi

install_directory="/var/www/html"
archive_url="https://github.com/anvc/scalar/archive/$VERSION.tar.gz"

if ! curl -Lfs --output /dev/null "$archive_url";
then
  echo "Requested Scalar version $VERSION doesn't exist"
  exit 1
fi

rm -rf "$install_directory/*"
curl -sL "$archive_url" | tar -xz -C "$install_directory" --strip-components=1

chown -R "${APACHE_RUN_USER:-www-data}:${APACHE_RUN_GROUP:-www-data}" "$install_directory"

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

echo "Installed Scalar $VERSION to $install_directory"
