Process.daemon
exec "rbenv exec apache-loggen --rate=10 /var/log/td-agent/dummy_access_log"
