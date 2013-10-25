# CHANGELOG for chef-logstash

This file is used to list changes made in each version of chef-logstash.

## 0.7.0:

### New features ###
* settable gid when using runit or upstart as supervisor
* default logstash version 1.2.2
* attributes to specify: config_dir, home, config_file for both agent and server.
* don't install rabbit by default
* use `if` conditional if logstash version >= 1.2.x

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
