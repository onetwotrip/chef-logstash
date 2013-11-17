#
# Author:: Denis Barishev <dennybaa@gmail.com>
# Author:: John E. Vincent
# Author:: Bryan W. Berry (<bryan.berry@gmail.com>)
# Copyright 2013, Denis Barishev
# Copyright 2012, John E. Vincent
# Copyright 2012, Bryan W. Berry
# License: Apache 2.0
# Cookbook Name:: logstash
# Recipe:: server
#

include_recipe 'logstash::default'
include_recipe 'logstash::service'

# Addresses specified via attributes are preferrable
es_server_ip = node['logstash']['elasticsearch_ip']
graphite_server_ip = node['logstash']['graphite_ip']
if not Chef::Config[:solo]
  es_node = search(:node, node['logstash']['elasticsearch_query']).first || {}
  graphite_node = search(:node, node['logstash']['graphite_query']).first || {}
  es_server_ip ||= es_node['ipaddress']
  graphite_server_ip ||= graphite_node['ipaddress']
end
es_server_ip and node.default['logstash']['elasticsearch_ip'] = es_server_ip
graphite_server_ip and node.default['logstash']['graphite_ip'] = graphite_server_ip

# Default elasticsearch output plugin configuration
elastic = node.default['logstash']['outputs']['default']['elasticsearch']
if node['logstash']['elasticsearch_ip']
  elastic[:host] = node['logstash']['elasticsearch_ip']
  elastic[:cluster] = node['logstash']['elasticsearch_cluster']
  elastic[:node_name] = node['hostname']
elsif node['logstash']['agent']['enable_embedded_es']
  elastic[:embedded] = true
else
  node.default['logstash']['outputs']['default'].delete('elasticsearch')
  Chef::Log.error("Logstash elasticsearch output configuration failed.")
  Chef::Log.error("Specify elasticsearch_ip or set enable_embedded_es.")
end
