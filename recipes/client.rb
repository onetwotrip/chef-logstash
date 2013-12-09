#
# Author:: Denis Barishev <dennybaa@gmail.com>
# Copyright 2013, Denis Barishev
#
# License: Apache 2.0
# Cookbook Name:: logstash
# Recipe:: client
#

include_recipe 'logstash::default'
include_recipe 'logstash::service'

node.default['logstash']['agent']['enable_embedded_es'] = false

# the difference of "client" is only that that it has no default input and output
# TODO: actually the output should point to the logstash server
node.default['logstash']['inputs']['default'].delete(:input)
node.default['logstash']['outputs']['default'].delete(:output)
