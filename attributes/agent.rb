
default['logstash']['agent']['version']    = '1.2.2'
default['logstash']['agent']['source_url'] = 'https://download.elasticsearch.org/logstash/logstash/logstash-1.2.2-flatjar.jar'
default['logstash']['agent']['checksum'] = '6b0974eed6814f479b68259b690e8c27ecbca2817b708c8ef2a11ce082b1183c'

default['logstash']['agent']['enable_embedded_es'] = true

default['logstash']['agent']['xms'] = '1024M'
default['logstash']['agent']['xmx'] = '1024M'
default['logstash']['agent']['java_opts'] = ''
default['logstash']['agent']['gc_opts'] = '-XX:+UseParallelOldGC'
default['logstash']['agent']['ipv4_only'] = false
default['logstash']['agent']['verbosity'] = nil # might be: v or vv

default['logstash']['agent']['server_role'] = 'logstash_server'
default['logstash']['agent']['server_ipaddress'] = nil
