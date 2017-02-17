#!/bin/bash

parse_yaml() {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

eval $(parse_yaml app/config/parameters.yml "yml_")


CONTAINER=$yml_parameters__sfdocker_default_container
CACHE_ENV="dev"
COMPOSE="docker-compose"
EXEC="$COMPOSE exec --user www-data $CONTAINER"
EXEC_PRIVILEGED="$COMPOSE exec --user root $CONTAINER"
BASH_C="bash -c"
ERROR_PREFIX="ERROR ::"

if [[ $# < 1 ]]; then
    echo "$ERROR_PREFIX Dame un argumento madafaka! (start/stop/restart/destroy/enter/cache/composer)";
    exit 1;
fi

# Docker handling
if [[ $1 == "start" ]]; then
    $COMPOSE up -d --build
fi

if [[ $1 == "stop" ]]; then
    $COMPOSE kill
fi

if [[ $1 == "restart" ]]; then
    $COMPOSE kill
    $COMPOSE up -d --build
fi

if [[ $1 == "enter" ]]; then
    if [[ $# > 1 ]]; then
      CONTAINER=$2
    fi
    $EXEC bash
fi

if [[ $1 == "logs" ]]; then
    if [[ $# > 0 && $2 != "all" ]]; then
        if [[ $# > 1 ]]; then
            CONTAINER=$2
        fi
      $COMPOSE logs | grep $CONTAINER
    else
      $COMPOSE logs
    fi
fi

# Code handling (pre-commit hook)
if [[ $1 == "ccode" ]]; then
    $COMPOSE exec -T $CONTAINER $BASH_C "php app/hooks/pre-commit.php"
fi

# Cache handling
if [[ $1 == "cache" ]]; then
    if [[ $# > 1 ]]; then
      CACHE_ENV=$2
    fi
    if [[ $2 == "all" ]]; then
        $EXEC $BASH_C "php app/console ca:cl --env=dev;php app/console ca:cl --env=test;php app/console ca:cl --env=prod";
    else
        $EXEC $BASH_C "php app/console ca:cl --env=$CACHE_ENV";
    fi
fi

# Destroy handling
if [[ $1 == "destroy" ]]; then
    read -p "Te vas a cepillar todos los contenedores docker que tengas en tu equipo. ¿Estás seguro? [Y/n]" -n 1 -r
    response=${response,,}
    if [[ $response =~ ^(yes|y| ) ]] | [ -z $response ]; then
        # Levantar los contenedores, por si no estuvieran todos levantados
        $COMPOSE up -d --remove-orphans
        # Parar todos los contenedores y después eliminarlos
        docker stop $(docker ps -a -q)
        docker rm $(docker ps -a -q)
    fi
fi

# Composer handling
if [[ $1 == "composer" ]]; then
    if [[ $# < 2 ]]; then
        echo "$ERROR_PREFIX ¡Necesito un segundo un argumento madafaka! (install/update/require/...)";
        exit 1;
    fi
    $EXEC_PRIVILEGED $BASH_C "mv /etc/php/7.0/cli/conf.d/20-xdebug.ini /etc/php/7.0/cli/conf.d/20-xdebug.ini.bak";
    $EXEC $BASH_C "$1 $2 $3 $4";
    $EXEC_PRIVILEGED $BASH_C "mv /etc/php/7.0/cli/conf.d/20-xdebug.ini.bak /etc/php/7.0/cli/conf.d/20-xdebug.ini";
fi