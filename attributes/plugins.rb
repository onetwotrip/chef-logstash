
default['logstash']['inputs']['default'][:input] = {
  _type: 'tcp',
  codec: 'json',
  port: 5959
}

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

default['logstash']['outputs']['default'][:output] = {_type: 'elasticsearch'}
default['logstash']['outputs']['default'][:stdout] = {
  _type: 'stdout',
  debug: true,
  codec: 'plain'
}
