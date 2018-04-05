# sfdocker

Installation
============

Install bpkg:
-----------------

```
$ sudo -s
$ curl -Lo- "https://raw.githubusercontent.com/bpkg/bpkg/master/setup.sh" | bash
```

Install sfdocker package for the first time (if you are updating, goto point 5):
--------------------------------------------------------------------------------

Symfony 2/3:
```
$ cd app
$ bpkg install lopezator/sfdocker
```

Symfony 4:
```
$ mkdir app
$ cd app
$ bpkg install lopezator/sfdocker
```

Link library:
-------------
```
$ cd ..
$ ln -s app/deps/bin/sfdocker sfdocker
```

First run:
----------

The first time you run ./sfdocker (with whatever arguments) if it doesn't detect the sfdocker.conf it will ask you to provide two parameters, default user and default container.<br/>

Note: if you provided wrong values and want to fix them, run: 
```
$ ./sfdocker config
```

Commands inside the docker wrapper
==================================

1.- Docker containers handling:
------------------------------

#### Start docker containers:
```
$ ./sfdocker start
```
#### Create docker containers:
```
$ ./sfdocker create
```
#### Remove docker containers:
```
$ ./sfdocker remove
```
#### Stop docker:
```
$ ./sfdocker stop
```
#### Restart docker:
```
$ ./sfdocker restart
```
#### Build docker:
```
$ ./sfdocker build
```
#### Destroy docker:
```
$ ./sfdocker destroy
```
#### Enter in docker containers
```
# Enter into the default container with the default user

$ ./sfdocker enter

# Enter into the default container (as privileged user, root):

$ ./sfdocker enter -p

# Enter into default container specifing an user:

$ ./sfdocker enter -u <user_name>

# Enter into other container with the default user

$ ./sfdocker enter <container_name>

# Enter into other container (as privileged user, root):

$ ./sfdocker enter <container_name> -p

# Enter into other container specifing an user:

$ ./sfdocker enter <container_name> -u <user_name>

```
#### Show running containers:
```
$ ./sfdocker ps
```
#### Docker logs:
```

# Show logs for the default container only:

$ ./sfdocker logs <-f>

# Show logs for all containers:

$ ./sfdocker logs all <-f>

# Show logs for the specified container:

$ ./sfdocker logs <container_name> <-f>

Note: All ./sfdocker logs commands accepts an optional LAST argument -f to simulate tail -f behaviour

```
2.- Sfdocker handling:
------------------------------

#### Configure sfdocker
```
$ ./sfdocker config
```
#### Update sfdocker:
```
$ ./sfdocker self-update
```
3.- Symfony handling & code tools:
----------------------------------

#### Execute symfony console:
```
$ ./sfdocker console <args>
```
#### Clear symfony cache (default value: dev):
```
$ ./sfdocker cache <dev/prod/test/all>
```
#### Check code compliance:
```
$ ./sfdocker ccode
```
Note: Only checks code added to git staging area (git add file).

#### Run composer:
```
$ ./sfdocker composer <args>
```
Note: Starts composer inside the container, so you can send any other composer parameter, if it's wrong, composer itself will return the error.

4.- Other tools handling (if installed):
----------------------------------------

#### Execute gulp:
```
$ ./sfdocker gulp <args>
```
Note: Starts gulp inside the container, so you can send any other gulp parameter, if it's wrong, gulp itself will return the error.

#### Execute bower:
```
$ ./sfdocker bower <args>
```
Note: Starts bower inside the container, so you can send any other bower parameter, if it's wrong, bower itself will return the error.

5.- Mysql handling:
------------------

#### Dump your database to "data/dumps" folder:
```
$ ./sfdocker mysql dump
```
#### Restore your database:
```
$ ./sfdocker mysql restore
```
Note: Restores the latest file by modified date inside the "data/dumps" folder.

#### Clear your dumps folder:
```
$ ./sfdocker mysql clear
```
6.- Help / Command list:
------------------------

#### Ask for this same page within sfdocker:
```
$ ./sfdocker help
```