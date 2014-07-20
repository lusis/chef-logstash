
actions :create, :delete
default_action :create if defined?(default_action)

attribute :name,              :kind_of => [String], :name_attribute => true
attribute :type,              :regex => /^([a-z]|[A-Z]|[0-9]|_|-)+$/
attribute :path,              :kind_of => [String, Array, NilClass]
attribute :exclude,           :kind_of => String
attribute :tags,              :kind_of => Array
attribute :multiline_regex_before,  :kind_of => [String, NilClass]
attribute :multiline_regex_after,   :kind_of => [String, NilClass]