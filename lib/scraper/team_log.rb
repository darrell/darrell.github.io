require 'nokogiri'
require 'csv'
require 'open-uri'
require 'scraper/generic'

module Scraper
  class TeamLog < Generic
    attr_reader :name
    private 

    def fetch_html(id)
      open("http://stats.fckansascity.com/Stats/TeamLog?teamId=#{id}").read
        # http://stats.fckansascity.com/Stats/TeamStats?teamId=26583
        # http://stats.fckansascity.com/Stats/TeamLog?teamId=26583
        # http://stats.fckansascity.com/Stats/PlayerStats?teamId=11270
    end

    def parse(html)
      @parsed||=Nokogiri::HTML(@html)
      table=@parsed.xpath('//table')
      @headers=extract_header(table)
      @content=extract_content(table)
    end

    # =======
    # CONTENT
    # =======

    # returns an array of rows
    # corresponding to the headers
    def extract_content(table)
      content=[]
      table.xpath('//tr').each do |tr|
        row=[]
        tr.children.each do |td|
          next unless td.name=='td'
          next if td.content.empty?
          row<<clean_content(td.text)
        end
        content<<row unless row.empty?
      end
      @content = content
    end
    
    def clean_content(c)
      c.gsub(/(\r|\n|\s)/,'')
    end

    # =======
    # HEADERS
    # =======
    def extract_header(table)
      prefix='home_'
      # our data has four blank header columns
      headers=%w{match_date opponent location outcome}
      table.xpath('//tr/th').each do |th|
        if th.attributes['class'] && th.attributes['class'].value == 'tableSeperator'
          prefix='opponent_'
        end
        next unless th.attributes.empty?
        next if th.content.empty?
        headers << "#{prefix}#{clean_header(th.content)}"
      end
      @headers=headers.map(&:to_sym)
    end
    
    def clean_header(h)
      expansions={ 'P' => 'Games Played',
        'GS' => 'Games Started',
        'MP' => 'Minutes Played',
        'G' => 'Goals',
        'GWG' => 'Game Winning Goals',
        'A' => 'Assists',
        'SH' => 'Shots',
        'SOG' => 'Shots on Goal',
        'CR' => 'Crosses',
        'CK' => 'Corner Kicks',
        'OFF' => 'Offsides',
        'FC' => 'Fouls Committed',
        'FS' => 'Fouls Suffered',
        'YC' => 'Yellow Cards',
        'RC' => 'Red Cards',
        'W' => 'Wins',
        'L' => 'Losses',
        'T' => 'Ties',
        'SV' => 'Saves',
        'GA' => 'Goals Against',
        'PKM' => 'Penalty Kicks Made',
        'PKG' => 'Penalty Kicks Made',
        'PK' => 'Penalty Kicks'}
        
        h = expansions[h] =  expansions[h].nil? ? h : expansions[h]
        h.gsub!(' ','_')
        h.downcase!
      return h
    end
    
  end
end
