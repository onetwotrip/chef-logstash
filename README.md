Description
===========

This is the Logstash cookbook.

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
* `node['logstash']['default_configs']` - list of Logstash configuration files enabled by default.
* `node['logstash']['version']` - Logstash version; `1.2.2` by default
* `node['logstash']['source_url']` - source url of Logstash
* `node['logstash']['checksum']` - checksum of source file


## Logstash service configuration

These attributes configure logstash **service** they have nothing in common with the _<u>client</u>_ installation way. Logstash jar contains *agent* and *web* options to run specific logstash service inside the jar. We also stick to this term.

* `node['logstash']['agent']['enable_embedded_es']` - Should Logstash run with the embedded ElasticSearch server or not?

* `node['logstash']['agent']['xms']` - The minimum memory to assign the JVM.
* `node['logstash']['agent']['xmx']` - The maximum memory to assign the JVM.
* `node['logstash']['agent']['java_opts']` - Additional params you want to pass to the JVM
* `node['logstash']['agent']['gc_opts']` - Specify your garbage collection options to pass to the JVM
* `node['logstash']['agent']['ipv4_only']` - Add jvm option preferIPv4Stack?
* `node['logstash']['agent']['verbosity']` - Set agent to verbose mode, migh be `v` or `vv`; `nil` by default


## Logstash default inputs, filters, outputs configuration

* `node['logstash']['inputs']['default']` - default inputs configuration. Logstash is configured to listen **tcp** on port 5959.
* `node['logstash']['filters'][:syslog]` - Syslog filters.
* `node['logstash']['outputs']['default'] - default outputs configuration Logstash is configured to output to the elasticsearch (in server recipe).

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

Cookbook installs **logstash** into the system and configures the service. Basically there are two recipes which install Logstash they are `logstash::server` and `logstash::client`. Both install logstash jar-package into the system and setup the Logstash agent service. They run exactly the same install and setup code, the only difference is that that **client** recipe disables attributes which generate default input and default elasticsearch output.

Index-cleaner recipe create python script and crontask which execute it.

Configuration
==========

## Logstash configuration

The set of default configuration files is defined in `node['logstash']['default_configs']` attribute. These files are *10-input.conf.erb, 40-filter.conf.erb, 80-output.conf.erb* and they are populated into `node['logstash']['config_dir']` directory.

On the node provisioned with `logstash::client` input and output configuration files will be empty. However both **client** and **server** ship with **Syslog** filtering by default.


## Using logstash_conf

Logstash configuration files can be generated with the help of **logstash_conf** definition. The upstream cookbook [lusis/chef-logstash](https://github.com/lusis/chef-logstash/tree/0.7.0) writes all the configs automatically based on the configuration given in the attributes. We don't do that way!

Staring from the version 1.2 Logstash configuration language uses conditionals. So far it's the best way to generate configs  is not clear. This cookbook uses **logstash_conf** definition and a small template helper `logstash.plugin_pp(data, spacing=2)` for simplifying configs generation.

**plugin_pp** can output plugin configuration data in the Logstash format. Given approach allows you to create configuration "library" by storing needed plugins in the node attributes. Later just output these data in the template using `logstash.plugin_pp` method.


## Syslog filters configuration example

Our cookbook provides syslog filtering out of box, let's have a look at it.

The following attributes setup basic logstash syslog filterring.
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

Inside the template we use `logstash.plugin_pp` method to output the plugin data. The code bellow shows that plugin_pp might useful to create conditional layout.

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

In the end you've got predefined filters in the node attributes, so if your custom application log format requires syslog date filter it's easy to use it again with **plugin_pp**. Talking about real life scenarios I don't know if the library approach along with **plugin_pp** is a good way to do.


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
