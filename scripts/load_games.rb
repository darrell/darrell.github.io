require 'rubygems'
require "bundler/setup" 
$:<<'lib'
require 'sequel'
require 'scraper/team_log'
require 'nwsl'
require 'pry'
require 'csv'
require 'logger'

DB.loggers << ::Logger.new('load_games.log')


CSV.readlines('games2', :col_sep=>"\t").each do |row|
  row.map!(&:strip)
  match_date=Date.parse(row[0])
  home=Team.find(:name => row[2])
  away=Team.find(:name => row[4])
  g= Game.find_or_create(
    :home_team_id => home.team_id,
    :away_team_id => away.team_id,
    :game_day => match_date
    )
  g.played=false
  begin
     home.add_game g
     away.add_game g
   rescue Sequel::UniqueConstraintViolation
     # nothing
   end
end