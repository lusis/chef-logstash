
action :create do
  defaults   = node['logstash']['instance']['default']
  attributes = node['logstash']['beaver']

  basedir = "#{attributes['basedir'] || defaults['basedir']}/beaver"  

  tp = template "#{basedir}/etc/conf.d/#{new_resource.name}" do
    source      "beaver/input_config.erb"
    cookbook    "logstash"
    owner       attributes['user'] || defaults['user']
    group       attributes['group'] || defaults['group']
    mode        '0644'
    variables   resource: new_resource
    notifies    :restart, "service[logstash_beaver]"
    action      :create
  end
  new_resource.updated_by_last_action(tp.updated_by_last_action?)
end
