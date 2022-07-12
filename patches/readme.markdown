Scalar Patches
--------------

Previously, we've been using a fork of Scalar with some local patches as the base
for our Docker container. Rather than maintain this fork in addition to this container,
I'd like to try keeping the local patches (which are mostly container related) local
to this project and `COPY` them on top of the submodule'd source at build time.

In order for the `COPY` instructions to work properly, files in this directory should
be set up as if they were in Scalar's hierarchy. As such, all paths below are relative
to Scalar base (`/var/www/html` in our configuration).

## `codeigniter.php`

Modifying the main Code Igniter file to allow setting the `ENVIRONMENT` constant
via environment variable (`SCALAR_ENVIRONMENT`).


## `system/application/config/local_settings_custom.php`

Adds the ability to update storage, registration key, and email settings
using environment variables. `system/application/config/local_settings.php`
checks for this file and includes it after the initial setup. 


## `system/libraries/MY_Log.php`

Custom logger that writes to STDOUT (and Docker's logs). The threshold is configurable
via the environment variable `SCALAR_LOG_THRESHOLD`, which takes the following values:

values           | what is logged
-----------------|---------------------
`OFF` or `NONE`  | Nothing is logged
`ERROR`          | Scalar and PHP errors, the latter are logged as `ERROR (PHP)` to allow for filtering
`DEBUG`          | Scalar debugging messages


## `system/application/config/development/config.php` and `system/application/config/production/config.php`

Converts text values for `SCALAR_LOG_THRESHOLD` into their numerical equivalents.
In order to be able to override the site config values (which are different than
the `local_settings.php` and `local_settings_custom.php` files, it turns out),
we place config files into environment subdirectories. These files are the same,
content-wise, but need to be duplicated to match both dev and prod environments.
Config values from `system/application/config/config.php` are included first
before being overridden. 
