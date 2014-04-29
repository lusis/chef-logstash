module Logstash
  def self.es_server_ip(node)
    if Chef::Config[:solo]
      node['logstash']['elasticsearch_ip']
    else
      es_results = []
      Chef::Search::Query.new.search(:node, node['logstash']['elasticsearch_query']) { |o| es_results << o }

      if !es_results.empty?
        return es_results[0]['ipaddress']
      else
        es_server_ip = node['logstash']['elasticsearch_ip']
      end
    end
  end

  def self.graphite_server_ip(node)
    if Chef::Config[:solo]
      node['logstash']['graphite_ip']
    else
      graphite_results = []
      Chef::Search::Query.new.search(:node, node['logstash']['graphite_query']) { |o| graphite_results << o }
      if !graphite_results.empty?
        graphite_results[0]['ipaddress']
      else
        node['logstash']['graphite_ip']
      end
    end
  end
end
