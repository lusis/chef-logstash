# Encoding: utf-8

def enable_runit_service(resource_name)
  ChefSpec::Matchers::ResourceMatcher.new(:runit_service, :enable, resource_name)
end

def start_runit_service(resource_name)
  ChefSpec::Matchers::ResourceMatcher.new(:runit_service, :start, resource_name)
end
