#
# Author:: Denis Barishev <dennybaa@gmail.com>
# Copyright 2013, Denis Barishev
#
# License: Apache 2.0
# Cookbook Name:: logstash
# Recipe:: agent
#

include_recipe 'logstash::default'
include_recipe 'logstash::service'

# the difference of "agent" is only that that it has no default input and output
node.default['logstash']['inputs']['default'].delete(:input)
node.default['logstash']['outputs']['default'].delete(:output)
