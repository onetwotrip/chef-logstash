
default['logstash']['agent']['enable_embedded_es'] = true

default['logstash']['agent']['xms'] = '1024M'
default['logstash']['agent']['xmx'] = '1024M'
default['logstash']['agent']['java_opts'] = ''
default['logstash']['agent']['gc_opts'] = '-XX:+UseParallelOldGC'
default['logstash']['agent']['ipv4_only'] = false
default['logstash']['agent']['verbosity'] = nil # might be: v or vv
