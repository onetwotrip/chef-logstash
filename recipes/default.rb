#
# Cookbook Name:: logstash
# Recipe:: default
#

include_recipe 'java'

logstash_base = node['logstash']['basedir']

if node['logstash']['create_account']
  group node['logstash']['group'] do
    system true
  end

  user node['logstash']['user'] do
    group node['logstash']['group']
    home  node['logstash']['user_home']
    system true
    action :create
    manage_home true
  end
end

directory node['logstash']['basedir'] do
  action :create
  owner 'root'
  group 'root'
  mode  0755
end

node['logstash']['join_groups'].each do |grp|
  group grp do
    members node['logstash']['user']
    action :modify
    append true
    only_if "grep -q '^#{grp}:' /etc/group"
  end
end

%w(etc lib tmp log data).each do |ldir|
  directory "#{logstash_base}/#{ldir}" do
    mode  0755
    owner node['logstash']['user'] and group node['logstash']['group']
  end
end

[
  ::File.dirname(node['logstash']['log_file']),
  node['logstash']['config_dir'],
  node['logstash']['patterns_dir']
].each do |ldir|
  directory ldir do
    mode  0755
    owner node['logstash']['user'] and group node['logstash']['group']
  end
end

remote_file "#{logstash_base}/lib/logstash-#{node['logstash']['agent']['version']}.jar" do
  action :create_if_missing
  mode  0755
  owner 'root' and group 'root'
  source node['logstash']['agent']['source_url']
  checksum node['logstash']['agent']['checksum']
end

link "#{logstash_base}/lib/logstash.jar" do
  to "#{logstash_base}/lib/logstash-#{node['logstash']['agent']['version']}.jar"
  notifies :restart, 'service[logstash]'
end

node['logstash']['patterns'].each do |file, hash|
  template "#{node[:logstash][:patterns_dir]}/#{file}" do
    source 'patterns.erb'
    mode  0644
    owner node['logstash']['user'] and group node['logstash']['group']
    variables( :patterns => hash )
    notifies :restart, 'service[logstash]'
  end
end
