#!/bin/bash

cat << EOF > /etc/td-agent/td-agent.conf
<source>
  type tail
  format apache
  path /var/log/td-agent/dummy_access_log
  pos_file /var/log/td-agent/access.pos
  tag dummy.apache.access
</source>

<match *.apache.*>
  type elasticsearch
  logstash_format true
  index_name fluentd
  type_name apache
  include_tag_key true
  tag_key @log_name
  flush_interval 3 # For testing
  host $ES_PORT_9200_TCP_ADDR
  port $ES_PORT_9200_TCP_PORT
</match>
EOF

rbenv exec ruby /usr/local/bin/daemon.rb
/etc/init.d/td-agent start
tail -n 10000 -f /var/log/td-agent/td-agent.log
