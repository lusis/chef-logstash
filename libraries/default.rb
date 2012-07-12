# this method converts a ruby hash to a valid logstash configuration
def hash_to_stash(blocks)
  stanza = ""
  blocks.each do |block|
    block.each do |name,hash|
      stanza << "\t#{name} {\n"
      hash.each do |k,v|
        stanza << "\t\t#{k} => " 
        stanza << case v
                  when String
                    "'#{v}'"
                  when TrueClass, FalseClass, Hash, Numeric, Array
                    v.to_s
                  end
        stanza << "\n"
      end
      stanza << "\t}\n"
    end
  end
  stanza
end
