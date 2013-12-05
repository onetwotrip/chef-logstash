# <a name="title"></a> chef-logstash [![Build Status](https://secure.travis-ci.org/lusis/chef-logstash.png?branch=master)](http://travis-ci.org/lusis/chef-logstash)

Description
===========

This is the Logstash cookbook.

This branch is to start building towards solid support for logstash 1.2.x and the new conditionals system

Attributes
==========

## Default

* `node['logstash']['user']` - the owner for all Logstash components; `logstash` by default
* `node['logstash']['group']` - the group for all Logstash components; `logstash` by default

* `node['logstash']['log_file']` - the path for Logstash agent logfile
* `node['logstash']['basedir']` - the base directory for all the
  Logstash components
* `node['logstash']['pid_dir']` - the path for Logstash pid file
* `node['logstash']['user_home']` - the path for Logstash directory '/var/lib/logstash'
* `node['logstash']['patterns_dir']` - the pattern directory for Logstash
* `node['logstash']['config_dir']` - the config directory for Logstash

* `node['logstash']['init_method']` - the init method for Logstash `runit` or `native`
* `node['logstash']['init_template_cookbook']` - the init template for Logstash

* `node['logstash']['create_account']` - create the account info from
  `user` and `group`; this is `true` by default. Disable it to use an existing account!
* `node['logstash']['join_groups']` - An array of Operative System groups to join. Usefull to gain read privileges on some logfiles.

* `node['logstash']['graphite_role']` - the Chef role to search for discovering your preexisting Graphite server
* `node['logstash']['graphite_query']` - the search query used for discovering your preexisting Graphite server. Defaults to
* `node['logstash']['elasticsearch_role']` - the Chef role to search for discovering your preexisting ElasticSearch cluster.
* `node['logstash']['elasticsearch_query']` - the search query used for discovering your preexisting ElasticSearch cluster. Defaults to node['logstash']['elasticsearch_role'] in the current node environment
* `node['logstash']['elasticsearch_cluster']` - the cluster name assigned to your preexisting ElasticSearch cluster. Only applies to external ES clusters.
* `node['logstash']['elasticsearch_ip']` - the IP address that will be
  used for your elasticsearch server in case you are using Chef-solo
* `node['logstash']['elasticsearch_port']` - the port of ES; `nil` by default
* `node['logstash']['graphite_ip']` - the IP address that will be used
  for your graphite server in case you are using Chef-solo
* `node['logstash']['debug_stdout']` - debug mode; `false` by default
* `node['logstash']['plugin_paths']` - the path for Logstash plugins
* `node['logstash']['patterns']` - the patterns for Logstash
* `node['logstash']['default_configs']` - list of configuration templates for Logstash


## Agent
* `node['logstash']['agent']['version']` - Logstash agent version; `1.2.2` by default
* `node['logstash']['agent']['source_url']` - source url of Logstash
* `node['logstash']['agent']['checksum']` - checksum of source file

* `node['logstash']['server']['enable_embedded_es']` - Should Logstash run with the embedded ElasticSearch server or not?

* `node['logstash']['agent']['xms']` - The minimum memory to assign the JVM.
* `node['logstash']['agent']['xmx']` - The maximum memory to assign the JVM.
* `node['logstash']['agent']['java_opts']` - Additional params you want to pass to the JVM
* `node['logstash']['agent']['gc_opts']` - Specify your garbage collection options to pass to the JVM
* `node['logstash']['agent']['ipv4_only']` - Add jvm option preferIPv4Stack?
* `node['logstash']['agent']['verbosity']` - Set agent to verbose mode, migh be `v` or `vv`; `nil` by default

* `node['logstash']['agent']['server_role']` - The role of the node behaving as a Logstash `server`/`indexer`
* `node['logstash']['agent']['server_ipaddress']` - ip address of logstash server; `nil` by default

## Plugins

* `node['logstash']['inputs']['default'][:input]` - Specify input plugin: type, codec and port; `tcp` `json` `5959` by default.
* `node['logstash']['filters'][:syslog]` - Specify syslog filters plugin.
* `node['logstash']['outputs']['default'][:output]` - Specify output type; `elasticsearch` by default.
* `node['logstash']['outputs']['default'][:stdout]` - Specify output `stdout` type, debug and codec; `stdout` `true` `plain` by default.

## Index Cleaner

* `node['logstash']['index_cleaner']['days_to_keep']` - Integer number of days from today of Logstash index to keep. `31` by default
* `node['logstash']['index_cleaner']['cron']` - Scheduled index_cleaner cron task. Every `0` minute by default

## Strainer

```
export COOKBOOK_PATH=`pwd`
export BUNDLE_GEMFILE=$COOKBOOK_PATH/test/support/Gemfile
bundle install
bundle exec berks install
bundle exec strainer test
```

Usage
==========

Cookbook install logstash into the system.
You can use recipe `logstash:server` or recipe `logstash:agent` for appropriate role.
You should not use `logstash:server` and `logstash:agent` on the one node.
The difference of `agent` is only that it has no default input and output plugins. 

Index-cleaner recipe create python script and crontask which execute it.

Configuration
==========

## Agent and Server configuration

First of all cookbook create runit conf file from template. 
After that cookbook create pluging files using .erb templates.
List of template files get from `node['logstash']['default_configs']` attribute.
All plugin configuration files locate in `node['logstash']['config_dir']`
For the correct order we use number at the beginning of the templates file names.
Logstash:server recipe create input, filter and output files.
Logstasg:agent recipe create only filter file.

## Using logstash_conf

From version 1.2.2 logstash have conditionals in plugins. With this feature automatization of generate plugint is too difficult. So in this case we decided not to make full automatic plugin produce.
You can add your own plugins from attributes, using `plugin_pp` helper which generate configuration from hash in logstash fromat, and add it into logstash configuration.
Logstash_conf is wrapper for template and cookbook files. Each template has collect with `logstash_conf` definition which inject variables from attribute `node['logstash']['input/filter/output']`


## Default plugin (Example)

Our default filter for syslog, specified in default attributes:

```
default['logstash']['filters'][:syslog] = {
  grok: {
    _type: 'grok',
    match: { "message" => "%{SYSLOGLINE}" },
    overwrite: [ "message" ]
  },
  date: {
    _type: 'date',
    match: [ "timestamp", "MMM  d HH:mm:ss", "MMM dd HH:mm:ss" ]
  },
  mutate: {
    _type: 'mutate',
    remove_field: ["timestamp"]
  }
}
```
And template, for it:

```
<% syslog = node['logstash']['filters']['syslog'] -%>
filter {
  if [type] == "syslog" {
  <% [:grok, :date, :mutate].each do |k| -%>
    <%= logstash.plugin_pp(syslog[k], 4) %>
  <% end -%>
  }
}
```

Also you can use already used plugin in other plugins. 
For example this way to use syslog timestamp filter: `['logstash']['filters'][:syslog][:date]`


# Vagrant

## Requirements
* Vagrant 1.2.1+
* Vagrant Berkshelf Plugin `vagrant plugin install vagrant-berkshelf`
* Vagrant Omnibus Plugin   `vagrant plugin install vagrant-omnibus`

Uses the Box Name to determine the run list ( based on whether its Debian or RHEL based ).

See chef_json and chef_run_list variables to change recipe behavior.

## Usage:

Run Logstash on Ubuntu Lucid   : `vagrant up lucid32` or `vagrant up lucid64`

Run Logstash on Centos 6 32bit : `vagrant up centos6_32`

Logstash will listen for syslog messages on tcp/5140


# BIG WARNING

* Currently only tested on Ubuntu Natty, Precise, and RHEL 6.2.

## License and Author

- Author:    Denis Barishev (<dennybaa@gmail.com>)
- Author:    John E. Vincent
- Author:    Bryan W. Berry (<bryan.berry@gmail.com>)
- Author:    Richard Clamp (@richardc)
- Author:    Juanje Ojeda (@juanje)
- Author:    @benattar
- Copyright: 2013, Denis Barishev
- Copyright: 2012, John E. Vincent
- Copyright: 2012, Bryan W. Berry
- Copyright: 2012, Richard Clamp
- Copyright: 2012, Juanje Ojeda
- Copyright: 2012, @benattar

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
