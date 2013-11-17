
default['logstash']['inputs']['default'][:tcp] = {
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

default['logstash']['outputs']['default'] = {
  elasticsearch: { _type: 'elasticsearch' },
  stdout: {
    _type: 'stdout',
    debug: true,
    codec: 'plain'
  }
}
