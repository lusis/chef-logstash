# CHANGELOG for chef-logstash

This file is used to list changes made in each version of chef-logstash.


## 0.9.2:
* fix PAX headers on community site

## 0.9.1:

* curator LWRP

## 0.9.0:

_this will almost certainly break backwards compatibility_

* support for Logstash 1.4
* major refactor towards being a library cookbook
  * instance LWRP
  * service LWRP
  * pattern LWP
  * config LWP  

## 0.7.7:

* Support for new beaver config [#239](https://github.com/lusis/chef-logstash/pull/239)
* Support for multiline codec [#240](https://github.com/lusis/chef-logstash/pull/240)
* Parameterize /var/lib/logstash [#242](https://github.com/lusis/chef-logstash/pull/242)
* Fix parameter spacing option [#244](https://github.com/lusis/chef-logstash/pull/244)

## 0.7.6:

* introduced more testing
  * Strainer: rubocop, knife test, foodcritic, chefspec
  * lots of style fixes for rubocop
  * skeleton spec files for each recipe
  * testkitchen + server spec

## 0.7.5:

* added fedora systemd support
* moved zeromq repos to own recipe

## 0.7.4:
* bump logstash version to 1.3.2

## 0.7.3:
* support for sudo with upstart for agent and server

## 0.7.2:
* embedded kibana support

## 0.7.1:
* various bugfixes
* support for multiple logstash workers via attribute.

## 0.7.0:

### New features ###
* settable gid when using runit or upstart as supervisor
* default logstash version 1.2.2
* attributes to specify: config_dir, home, config_file for both agent and server.
* don't install rabbit by default
* allow for conditionals to be set in the filters and outputs hashes.
* allow for disabling data driven templates.
* attributes to enable regular(ish) style chef templates.

### Bug fixes ###
* Vagrantfile cleanup, support more OS
* Cookbook Dependency cleanup

## 0.2.1 (June 26, 2012)

New features
	* Use ruby hashes supplied by roles to populate inputs, filters,
	and outputs
	* redhat-family support
	* change default version of logstash to 1.1.1preview
	* add in Travis-CI support

Bug fixes
	* keep apache default site from obscuring kibana
