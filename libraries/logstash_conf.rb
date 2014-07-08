# Encoding: utf-8
# rubocop:disable RedundantReturn
require 'rubygems'

# Evaluate objects for logstash config file.
class Erubis::RubyEvaluator::LogstashConf
  def self.key_to_str(k)
    case k.class.to_s
    when 'String'
      return "'#{k}'"
    when 'Fixnum', 'Float'
      return k.to_s
    when 'Regex'
      return k.inspect
    end
    return k
  end

  def self.hash_to_str(h, indent = 0)
    result = []
    h.each do |k, v|
      case v
      when Hash, Mash
        result << k + ' {'
        result << hash_to_str(v, indent)
      else
        indent += 4
        result << indent(indent) + key_value_to_str(k, v, indent)
        indent -= 4
      end
    end
    result.join("\n")
  end

  def self.value_to_str(v, indent = 0)
    case v
    when String, Symbol, Fixnum, Float
      "\"#{v}\""
    when Array
      "[#{v.map { |e| value_to_str(e, indent) }.join(', ')}]"
    when Hash, Mash
      hash_to_str(v, indent) + "\n" + indent(indent + 4) + '}'
    when TrueClass, FalseClass
      v.to_s
    else
      v.inspect
    end
  end

  def self.key_value_to_str(k, v, indent = 0)
    if v.nil?
      key_to_str(k)
    else
      # k.inspect + " => " + v.inspect
      key_to_str(k) + ' => ' + value_to_str(v, indent)
    end
  end

  def self.plugin_to_arr(plugin, patterns_dir_plugins = nil, patterns_dir = nil, indent = 0) # , type_to_condition)
    result = []
    plugin.each do |name, hash|
      indent += 4
      result << indent(indent) + name.to_s + ' {'
      result << indent(indent) + key_value_to_str('patterns_dir', patterns_dir, indent) if patterns_dir_plugins.include?(name.to_s) && patterns_dir && !hash.key?('patterns_dir')
      hash.sort.each do |k, v|
        indent += 4
        result << indent(indent) + key_value_to_str(k, v, indent)
        indent -= 4
      end
      result << indent(indent) + '}'
      indent -= 4
    end
    return result.join("\n")
  end

  def self.section_to_str(section, version = nil, patterns_dir = nil, indent = 0)
    result = []
    patterns_dir_plugins = ['grok']
    patterns_dir_plugins << 'multiline' if Gem::Version.new(version) >= Gem::Version.new('1.1.2') unless version.nil?
    section.each do |segment|
      result << ''
      if segment.key?('condition') || segment.key?('block')
        indent += 4
        result << indent(indent) + segment['condition'] + ' {' if segment['condition']
        result << plugin_to_arr(segment['block'], patterns_dir_plugins, patterns_dir, indent)
        result << indent(indent) + '}' if segment['condition']
        indent -= 4
      else
        indent += 4
        result << plugin_to_arr(segment, patterns_dir_plugins, patterns_dir, indent) # , type_to_condition)
        indent -= 4
      end
    end
    return result.join("\n")
  end
end

def indent(i)
  res = ''
  i.times { res << ' ' }
  res
end
