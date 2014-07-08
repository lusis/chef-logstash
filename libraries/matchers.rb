# Encoding: utf-8
# used by ChefSpec for LWRPs

if defined?(ChefSpec)
  # LWRP - Instance
  def create_logstash_instance(name)
    ChefSpec::Matchers::ResourceMatcher.new(:logstash_instance, :create, name)
  end

  def delete_logstash_instance(name)
    ChefSpec::Matchers::ResourceMatcher.new(:logstash_instance, :delete, name)
  end

  # LWRP - Config
  def create_logstash_config(name)
    ChefSpec::Matchers::ResourceMatcher.new(:logstash_config, :create, name)
  end

  # LWRP - Pattern
  def create_logstash_pattern(name)
    ChefSpec::Matchers::ResourceMatcher.new(:logstash_pattern, :create, name)
  end

  # LWRP - Plugins
  def create_logstash_plugins(name)
    ChefSpec::Matchers::ResourceMatcher.new(:logstash_plugins, :create, name)
  end

  # LWRP - Service
  def enable_logstash_service(name)
    ChefSpec::Matchers::ResourceMatcher.new(:logstash_service, :enable, name)
  end

  def restart_logstash_service(name)
    ChefSpec::Matchers::ResourceMatcher.new(:logstash_service, :restart, name)
  end

  def start_logstash_service(name)
    ChefSpec::Matchers::ResourceMatcher.new(:logstash_service, :start, name)
  end

  def reload_logstash_service(name)
    ChefSpec::Matchers::ResourceMatcher.new(:logstash_service, :reload, name)
  end

  def stop_logstash_service(name)
    ChefSpec::Matchers::ResourceMatcher.new(:logstash_service, :stop, name)
  end

  def create_logstash_curator(name)
    ChefSpec::Matchers::ResourceMatcher.new(:logstash_curator, :create, name)
  end

end
