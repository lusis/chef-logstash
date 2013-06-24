require 'rubygems'

class Erubis::RubyEvaluator::KibanaConf

  private

  def self.config_to_human(config)
    new_config = Hash.new

    config.each do |key, value|
      if value.class.to_s == "Array"
         value = "[#{value.map{|e| e}.join(", ")}]" 
      end

      new_config[key.slice(0,1).capitalize + key.slice(1..-1)] = value.inspect
    end

  return new_config
  end
end
