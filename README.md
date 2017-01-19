# sfdocker

* Install bpkg:

sudo -s
curl -Lo- "https://raw.githubusercontent.com/bpkg/bpkg/master/setup.sh" | bash

* Download/Update package:

cd app/
bpkg install lopezator/sfdocker

* Link library within composer.json (post-install && post-update):

ln -s app/deps/bin/sfdocker docker

* Set  default container name value in your Symfony's parameters.yml (php-fpm container) like this:

sfdocker_default_container: myproject-php-fpm

