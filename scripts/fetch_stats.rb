require 'rubygems'
require "bundler/setup" 
$:<<'lib'
require 'sequel'
require 'scraper/team_log'
require 'nwsl'
require 'pry'
# DB.loggers << ::Logger.new('fetch_stats.log')


def create_game(home,away,game)
  if game[:location] == "Home"
    g= Game.find_or_create(
      :home_team_id => home.team_id,
      :away_team_id => away.team_id,
      :game_day => Date.strptime(game[:match_date], '%m/%d/%Y')
      )
    g.played=true
    g.save
    begin
      home.add_game g
      away.add_game g
    rescue Sequel::UniqueConstraintViolation
      # nothing
    end
    return g
  end
end

def add_stats(team,game,data,home)
  if home
    prefix='home'
  else
    prefix='opponent'
  end
    
  keys = %w{ goals assists shots shots_on_goal saves crosses 
            corner_kicks penalty_kicks penalty_kicks_made offsides
            fouls_committed yellow_cards red_cards}

  s=Stat.find_or_create(
    :team_id => team.team_id,
    :game_id => game.game_id
  )
  keys.each do |k|
    s[k.to_sym]=data["#{prefix}_#{k}".to_sym]
  end
  s.save
  puts s.inspect
  return s
end

Team.each do |home_team|
  games=Scraper::TeamLog.new(home_team.scraper_id).as_hash.values
  games.each do |data|
    next unless data[:location] == "Home"

    away_team = Team.find(:shortname => data[:opponent])

    game=create_game(home_team,away_team,data)

    add_stats(home_team,game,data, true)
    add_stats(away_team,game,data, false)
  end
end

