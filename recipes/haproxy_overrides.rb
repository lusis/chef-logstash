# Create pattern_file  for haproxy with overrides for capturing request
# and response headers
cookbook_file "/opt/logstash/server/etc/patterns/haproxy" do
    source "haproxy"
    owner node['logstash']['user']
    group node['logstash']['group']
    mode "0774"
end
