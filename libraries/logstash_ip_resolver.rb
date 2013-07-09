module LogstashIpResolver
  # Fetches the ip address of a node, based on the 'path' given by node['logstash]['ipaddress_path']
  def self.ipaddress_of(node)
    obj = node

    node['logstash']['ipaddress_path'].each do |selector|
      obj = obj[selector]
    end

    obj
  end
end
