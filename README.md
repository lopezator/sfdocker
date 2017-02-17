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

* Commands inside the docker wrapper

* Start docker:

./docker start

* Enter in docker (default value: <sfdocker_default_container>):

./docker enter <contenedor>

* Stop docker:

./docker stop

* Restart docker:

./docker restart

* Destroy docker:

./docker destroy

* Docker logs (default value: <sfdocker_default_container>):

./docker log <contenedor/all>

* Clear symfony cache (default value: dev):

./docker cache <dev/prod/test/all>

* Check code compliance:

./docker ccode

* Run composer:

./docker composer <install/update/require>

(Starts composer inside the container, so you can send any other composer parameter 
, if it's wrong, composer itself will return the error)