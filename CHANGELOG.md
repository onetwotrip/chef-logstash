# CHANGELOG for chef-logstash

This file is used to list changes made in each version of chef-logstash.

## 0.9.0 (Nov 17, 2013)

### Refactored ###

* either agent or server recipe is used, but not both at the same time.
* same code for logstash service bringing up.
* logstash_conf definition to manage configuration files (under conf.d directory)
* removed weird way of logstash config files generation, it's too much...
* removed all that beaver, kibana, zmq, rabbitmq code overloading cookbook.
* attribute values are NOT passed through variables, since it's a bad practice for reusability.

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
