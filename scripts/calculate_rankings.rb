require 'rubygems'
require "bundler/setup" 
$:<<File.dirname(__FILE__)+'/../lib'
require 'sequel'
require 'nwsl'
require 'pry'
require 'csv'
require 'logger'
require 'glicko2'

teams=[]

Game.where(:played => true).sort_by{|g| g.game_day}.each do |g|
  teams[g.home_team.team_id]||=g.home_team
  teams[g.away_team.team_id]||=g.away_team
  
  home_team=teams[g.home_team.team_id]
  away_team=teams[g.away_team.team_id]
  home_team.ranking ||= Glicko2.new
  away_team.ranking ||= Glicko2.new
  
  home_rank=home_team.ranking
  away_rank=away_team.ranking
  if g.draw?
    home_rank.add_draw(away_rank)
    away_rank.add_draw(home_rank)
  elsif g.home_win?
    home_rank.add_win(away_rank)
    away_rank.add_loss(home_rank)
  else
    home_rank.add_loss(away_rank)
    away_rank.add_win(home_rank)
  end
  home_rank.update
  away_rank.update
end

teams.compact.sort_by{|t| t.ranking.rating}.each do |t|
  puts "#{t.name}:\t#{t.ranking.rating.round}\t#{t.ranking.deviation.round}\t#{t.ranking.volatility.round(6)}"
end
  
