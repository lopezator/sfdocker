#!/bin/bash

# Funciones ##########################################################
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

require_clean_work_tree () {
    # Update the index
    git update-index -q --ignore-submodules --refresh
    err=0

    # check for unstaged changes in the working tree
    if [[ $(check_unstaged_files) > 0 ]]; then
        err=1
    fi

    # Check untracked files in the working tree
    if [[ $(check_untracked_files) > 0 ]]; then
        err=1
    fi

    echo "$err"
}

function check_unstaged_files {
    git diff --no-ext-diff --quiet --exit-code
    echo $?
}

function check_untracked_files {
   expr `git status --porcelain 2>/dev/null| grep "^??" | wc -l`
}

confirm() {
    read -r -p "${1:-Are you sure? [Y/n]} " response
    case "$response" in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            if [ -z $response ]; then
                true
            else
                false
            fi
            ;;
    esac
}
# Funciones END #######################################################

eval $(parse_yaml app/config/parameters.yml "yml_")

CONTAINER=$yml_parameters__sfdocker_default_container
CACHE_ENV="dev"
COMPOSE="docker-compose"
EXEC="$COMPOSE exec --user www-data"
EXEC_PRIVILEGED="$COMPOSE exec --user root"
BASH_C="bash -c"
ERROR_PREFIX="ERROR ::"
WARNING_PREFIX="WARNING ::"
HOOK=1

if [[ $# < 1 ]]; then
    echo "$ERROR_PREFIX Dame un argumento madafaka! (start/stop/restart/enter/logs/console/ccode/cache/destroy/composer)";
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
    if [[ $# > 1 && $2 != "-p" ]]; then
      CONTAINER=$2
    fi
    if [[ "${@: -1}" == "-p" ]]; then
      $EXEC_PRIVILEGED $CONTAINER bash
    else
      $EXEC $CONTAINER bash
    fi
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

# Symfony console handling
if [[ $1 == "console" ]]; then
     $EXEC $CONTAINER $BASH_C "php app/console $2 $3 $4";
fi

# Code handling (pre-commit hook)
if [[ $1 == "ccode" ]]; then
    if [[ $(require_clean_work_tree) == 1 ]]; then
      echo "#########################################################################"
      echo "# $WARNING_PREFIX Tienes ficheros sin añadir a staging que no se comprobarán #"
      echo "#########################################################################"
    fi
    if [[ $HOOK == 1 ]]; then
      $COMPOSE exec -T $CONTAINER $BASH_C "php app/hooks/pre-commit.php"
    fi
fi

# Cache handling
if [[ $1 == "cache" ]]; then
    if [[ $# > 1 ]]; then
      CACHE_ENV=$2
    fi
    if [[ $2 == "all" ]]; then
        $EXEC $CONTAINER $BASH_C "php app/console ca:cl --env=dev;php app/console ca:cl --env=test;php app/console ca:cl --env=prod";
    else
        $EXEC $CONTAINER $BASH_C "php app/console ca:cl --env=$CACHE_ENV";
    fi
fi

# Destroy handling
if [[ $1 == "destroy" ]]; then
    if confirm "Te vas a cepillar todos los contenedores docker que tengas en tu equipo. ¿Estás seguro? [Y/n] "; then
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
    $EXEC_PRIVILEGED $CONTAINER $BASH_C "mv /etc/php/7.1/cli/conf.d/20-xdebug.ini /etc/php/7.1/cli/conf.d/20-xdebug.ini.bak";
    $EXEC $CONTAINER $BASH_C "$1 $2 $3 $4";
    $EXEC_PRIVILEGED $CONTAINER $BASH_C "mv /etc/php/7.1/cli/conf.d/20-xdebug.ini.bak /etc/php/7.1/cli/conf.d/20-xdebug.ini";
fi