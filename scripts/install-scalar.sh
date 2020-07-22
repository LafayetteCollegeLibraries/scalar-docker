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
sed -i'' -e 's/^#\(.*\%{DOCUMENT_ROOT}\/uploads\/.*\)/\1/g' "$install_directory/.htaccess"

echo "Installed Scalar $VERSION to $install_directory"
