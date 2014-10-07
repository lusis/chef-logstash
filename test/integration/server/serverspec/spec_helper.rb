# Encoding: utf-8
require 'serverspec'

# Required by serverspec
set :backend, :exec

RSpec.configure do |c|
  c.before :all do
    c.path = '/sbin:/usr/bin'
  end
end
