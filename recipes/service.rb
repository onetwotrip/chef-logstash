#
# Author:: Denis Barishev <dennybaa@gmail.com>
# Copyright 2013, Denis Barishev
#
# License: Apache 2.0
# Cookbook Name:: logstash
# Recipe:: service
#

# Setup default configuration files
node['logstash']['default_configs'].each {|c| logstash_conf c}

init = node['logstash']['init_method']
init = 'runit' if platform?('ubuntu') && node['platform_version'].to_f < 12.04

case init
when 'runit'
  include_recipe 'runit'

  runit_service 'logstash' do
    cookbook node['logstash']['init_template_cookbook']
  end
when 'native'
  case node['platform_family']
  when 'debian'
    template '/etc/init/logstash.conf' do
      source 'logstash.conf.erb'
      mode  0644
      owner 'root' and group 'root'
      cookbook node['logstash']['init_template_cookbook']
      notifies :restart, 'service[logstash]'
    end

    service 'logstash' do
      provider Chef::Provider::Service::Upstart
      action [ :enable, :start ]
    end
  when 'rhel', 'fedora'
    template '/etc/init.d/logstash' do
      source 'init.erb'
      mode  0755
      owner 'root' and group 'root'
      cookbook node['logstash']['init_template_cookbook']
      notifies :restart, 'service[logstash]'
    end

    service 'logstash' do
      supports :restart => true, :reload => true, :status => true
      action [:enable, :start]
    end
  end
else
  ::Chef::Log.error("Unsupported init method: #{node[:logstash][:init_method]}")
end
