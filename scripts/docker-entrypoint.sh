#!/bin/bash
cd /var/www/html && php /scripts/setup-db.php

exec "$@"
