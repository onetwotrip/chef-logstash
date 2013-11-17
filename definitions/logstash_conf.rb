#
# Author:: Denis Barishev <dennybaa@gmail.com>
# Copyright 2013, Denis Barishev
#
# License: Apache 2.0
#

# Creates logstash server configuration file either from a template or a file.
#
define :logstash_conf, :source => nil, :enable => true, :timing => :delayed do
  attrs_from_hash = lambda do |hash, attrs|
    attrs.each {|a| self.send(a) if not hash[a].nil?}
  end
  config =  case params[:source]
            when true
              params[:config] || params[:name]
            else
              ::File.basename(params[:name])
            end.sub(/\.erb$/,'') # strip unnecessary erb extension
  source = params[:source] || params[:name]
  timing = params[:timing] || :none

  method = ::File.extname(source) == '.erb' ? :template : :cookbook_file
  file_pass = [:backup, :cookbook]
  tpl_pass  = [:local, :variables]

  config_path = ::File.join(node['logstash']['config_dir'], config)
  file_block = Proc.new do
    action(params[:enable] ? :create : :delete)
    path   config_path
    source source
    owner node['logstash']['user']
    group node['logstash']['group']
    mode  0644
    # will pass specified attributes if any of them are given
    attrs_from_hash.call(params, file_pass)
    attrs_from_hash.call(params, tpl_pass) if method == :template
    notifies(:restart, 'service[logstash]', params[:timing]) unless params[:timing] == :none
  end
  self.send(method, config_path, &file_block)
end
