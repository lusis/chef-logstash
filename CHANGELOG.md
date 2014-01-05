# CHANGELOG for chef-logstash

This file is used to list changes made in each version of chef-logstash.

## 0.7.6:
* introduced more testing
** Strainer: rubocop, knife test, foodcritic, chefspec
** lots of style fixes for rubocop
** skeleton spec files for each recipe

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
