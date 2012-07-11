# this method converts a ruby hash to a valid logstash configuration
def hash_to_stash(blocks)
  stanza = ""
  blocks.each do |block|
    block.each do |name,hash|
      stanza << "\t#{name} {\n"
      hash.each do |k,v|
        if v.class.to_s == "String"
          stanza << "\t\t#{k} => \"#{v}\"\n"
        else
          stanza << "\t\t#{k} => #{v.inspect} \n"
        end
      end
      stanza << "\t}\n"
    end
  end
  stanza
end
