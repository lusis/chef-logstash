#!/usr/bin/env ruby
#
# Deletes indices older than "days to keep"
#
require 'json'

class IndexCleaner
  SECONDS_PER_DAY = 60 * 60 * 24
  def initialize
    raise ArgumentError.new("Days to keep and host must be provided") if ARGV.length != 2
    @days_to_keep, @host = ARGV
    @days_to_keep = @days_to_keep.to_i
  end

  def indices
    indices_json = JSON.parse(`curl http://#{@host}:9200/_aliases`)
    indices_json.keys.select { |k| k =~ /^logstash/ }
  end

  def clean!
    days_ago = Time.now - (@days_to_keep * SECONDS_PER_DAY)

    indices.each do |index|
      date = Time.new(*index.split('-').last.split('.'))
      if days_ago > date
        `curl -XDELETE http://#{@host}:9200/#{index}`
      end
    end
  end
end

IndexCleaner.new.clean!
