CHANGELOG
=========

#### Changes in version 2.1.0:

* Added <-f> optional LAST argument to ./sfdocker logs command to simulate the "tail -f" behaviour. 
* Improvements into README file.

#### Changes in version 2.0.1:

* Added remove command

#### Changes in version 2.0.0:

* Added support for Symfony 3.* && Symfony 4.*

#### Changes in version 1.0.3:

* Fixed bug in multi-project shared services. Removed the COMPOSE-FILE directive.

#### Changes in version 1.0.2:

* Changes to ./sfdocker config, not it doesn't allow blank values.
* Changes in README.md.

#### Changes in version 1.0.1:

* Renamed "./sfdocker start -b" to "./sfdocker build"
* Added "./sfdocker create" command to decouple container creation from building process.

#### Changes in version 1.0.0:

* Added sfdocker.conf file for default-container and default-user configuration.
* Added config command to rebuild the configuration. Command: "./sfdocker config"
* Changes in help command, now it prints the README.md file. Command changed to: "./sfdocker help"
* Changed version command behaviour. The command now is: "./sfdocker version"
* Changes in self-update to preserve the conf folder.
* Documentation improvements, added docs for mysql, gulp, bower. Corrections.




