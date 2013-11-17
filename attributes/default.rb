
default['logstash']['user'] = 'logstash'
default['logstash']['group'] = 'logstash'

default['logstash']['log_file'] = '/var/log/logstash/agent.log'
default['logstash']['basedir'] = '/opt/logstash'
default['logstash']['pid_dir'] = '/var/run/logstash'
default['logstash']['user_home'] = '/var/lib/logstash'
default['logstash']['patterns_dir'] = "#{node[:logstash][:basedir]}/etc/patterns"
default['logstash']['config_dir'] = "#{node[:logstash][:basedir]}/etc/conf.d"

default['logstash']['init_method'] = 'native' # native or runit
default['logstash']['init_template_cookbook'] = 'logstash'

default['logstash']['create_account'] = true
default['logstash']['join_groups'] = []

# roles/flags for various search/discovery
default['logstash']['graphite_role'] = 'graphite_server'
default['logstash']['graphite_query'] = "roles:#{node['logstash']['graphite_role']} AND chef_environment:#{node.chef_environment}"
default['logstash']['elasticsearch_role'] = 'elasticsearch_server'
default['logstash']['elasticsearch_query'] = "roles:#{node['logstash']['elasticsearch_role']} AND chef_environment:#{node.chef_environment}"
default['logstash']['elasticsearch_cluster'] = 'logstash'
default['logstash']['elasticsearch_ip'] = nil
default['logstash']['elasticsearch_port'] = nil
default['logstash']['graphite_ip'] = nil

default['logstash']['debug_stdout'] = false
default['logstash']['plugin_paths'] = []
default['logstash']['patterns'] = {}
default['logstash']['default_configs'] = %w(10-input.conf.erb 40-filter.conf.erb 80-output.conf.erb)
