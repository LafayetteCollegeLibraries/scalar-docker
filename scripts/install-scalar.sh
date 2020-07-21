#!/bin/bash
set -euo pipefail

install_directory="/var/www/html"

fetch_latest_tag () {
  curl -s "https://api.github.com/repos/anvc/scalar/releases/latest" \
    | grep '"tag_name":' \
    | sed -E 's/.*"([^"]+)".*/\1/'
}

install_scalar () {
  local version="$1"
  local install_directory="/var/www/html"
  local archive_url_template="https://github.com/anvc/scalar/archive/%s.tar.gz"

  if ! curl -Lfs --output /dev/null $(printf "$archive_url_template" "$version"); then
    echo "Requested Scalar version $version doesn't exist"
    exit 1
  fi

  curl -sL -o /tmp/scalar.tar.gz $(printf "$archive_url_template" "$version")
  rm -rf "$install_directory/*"

  tar -xvzf /tmp/scalar.tar.gz -C "$install_directory" --strip-components=1
  chown -R ${APACHE_RUN_USER:-www-data}:${APACHE_RUN_GROUP:-www-data} "$install_directory"

  echo "Installed Scalar $version to $install_directory"
}

if [[ -z ${VERSION+x} || "$VERSION" = "latest" ]]; then
  VERSION=$(fetch_latest_tag)
fi

install_scalar "$VERSION"
