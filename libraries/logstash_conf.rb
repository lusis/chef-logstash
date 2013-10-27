
require 'rubygems'

class Erubis::RubyEvaluator::LogstashConf

  private

  def self.key_to_str(k)
    case k.class.to_s
    when "String"
      return "'#{k}'"
    when "Fixnum", "Float"
      return k.to_s
    when "Regex"
      return k.inspect
    end
    return k
  end

  def self.value_to_str(v)
    case v
    when String, Symbol, Fixnum, Float
      "'#{v}'"
    when Array
      "[#{v.map{|e| value_to_str e}.join(", ")}]"
    when Hash, Mash
      value_to_str(v.to_a.flatten)
    when TrueClass, FalseClass
      v.to_s
    else
      v.inspect
    end
  end

  def self.key_value_to_str(k, v)
    unless v.nil?
      key_to_str(k) + " => " + value_to_str(v)
    else
      key_to_str(k)
    end
  end

  def self.plugin_to_arr(plugin, patterns_dir_plugins=nil, patterns_dir=nil) #, type_to_condition)
      result = []
      plugin.each do |name, hash|
#        result << ''
#        result << "  if [type] == \"#{hash['type']}\" {" if hash.has_key?('type') and type_to_condition
        result << '      ' + name.to_s + ' {'
        if patterns_dir_plugins.include?(name.to_s) and not patterns_dir.nil? and not hash.has_key?('patterns_dir')
          result << '        ' + key_value_to_str('patterns_dir', patterns_dir)
        end
        hash.sort.each do |k,v|
#          next if k == 'type' and type_to_condition
          result << '        ' + key_value_to_str(k, v)
        end
        result << '      }'
#        result << '  }' if hash.has_key?('type') and type_to_condition
      end
    return result.join("\n")
  end    

  public
  
  def self.section_to_str(section, version=nil, patterns_dir=nil)
    result = []
    patterns_dir_plugins = [ 'grok' ]
    unless version.nil?
      patterns_dir_plugins << 'multiline' if Gem::Version.new(version) >= Gem::Version.new('1.1.2')
    end
#    type_to_condition = Gem::Version.new(version) >= Gem::Version.new('1.2.0')
    section.each do |segment|
      result << ''
      if segment.has_key?('condition') or segment.has_key?('block')
        result << '    ' + segment['condition'] + ' {' if segment['condition']
        result << plugin_to_arr(segment['block'], patterns_dir_plugins, patterns_dir)
        result << '    }' if segment['condition']
      else
        result << plugin_to_arr(segment, patterns_dir_plugins, patterns_dir) #, type_to_condition)
      end
    end
    return result.join("\n")
  end

end

