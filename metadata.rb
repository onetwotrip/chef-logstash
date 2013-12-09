name             "logstash"
maintainer       "Denis Barishev"
maintainer_email "dennybaa@gmail.com"
license          "Apache 2.0"
description      "Installs/Configures logstash"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.9.2"

%w{ ubuntu debian redhat centos scientific amazon fedora }.each do |os|
  supports os
end

%w{ build-essential runit java python }.each do |ckbk|
  depends ckbk
end

%w{ rabbitmq yumrepo apt }.each do |ckbk|
  recommends ckbk
end
