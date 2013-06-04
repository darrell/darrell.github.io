require 'nokogiri'
require 'csv'
require 'open-uri'

module Scraper
  class Generic

    attr_reader :html, :headers, :content

    def initialize(id)
      @html||=fetch_html(id)
      parse(@html)
    end
    
    def fetch_html(id)
      raise "Implement Me! Don't call Generic"
    end

    def parse(html)
      raise "Implement Me! Don't call Generic"
    end

    def as_hash
      ret={}
      @content.each_index do |r|
          ret[r] = Hash[@headers.zip(@content[r])]
        end
      return ret
    end
      
    def as_csv
      CSV.generate(:write_headers => true, :headers => @headers) do |csv|
      # CSV.generate do |csv|
        @content.each do |row|
          csv << row
        end
      end
    end
  end
end