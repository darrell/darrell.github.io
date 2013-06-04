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
# 
# def   outcome_as_predicted?(g,prob,home_rank,away_rank)
#   # right now, we treat a tie as a win
#   # but we should improve this.
# 
#   if g.away_win? && prob > 0.5 ? false : true
#   end
# end

# Game.where(:played => true).sort_by{|g| g.game_day}.each do |g|
Game.where.sort_by{|g| g.game_day}.each do |g|
  teams[g.home_team.team_id]||=g.home_team
  teams[g.away_team.team_id]||=g.away_team
  
  home_team=teams[g.home_team.team_id]
  away_team=teams[g.away_team.team_id]
  home_team.rating ||= Glicko2.new
  away_team.rating ||= Glicko2.new
  
  home_rank=home_team.rating
  away_rank=away_team.rating
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
  prev_home_rank=home_rank.clone
  prev_away_rank=away_rank.clone
  
  home_rank.update
  away_rank.update

  pre_prob=prev_home_rank.p(prev_away_rank,false)
  post_prob=home_rank.p(away_rank,false)

  # puts [ g.game_day,
  #       g.home_team.shortname,g.away_team.shortname,
  #       g.home_score, g.away_score,
  #       prev_home_rank.rating.round,prev_away_rank.rating.round, 
  #       home_rank.rating.round,away_rank.rating.round, 
  #       pre_prob[:win], pre_prob[:lose], pre_prob[:tie],
  #       post_prob[:win], post_prob[:lose], post_prob[:tie]
  #       ].join("\t")
  puts [ g.game_day,
        g.home_team.shortname,g.away_team.shortname,
        g.home_score, g.away_score,
        ].join(",")
end

thorns=teams[5].rating
chi=teams[2].rating
sb=teams[3].rating
teams.compact.sort_by{|t| t.rating.rating}.each do |t|
  puts "#{t.name}:\t#{t.rating.rating.round}\t#{t.rating.deviation.round}\t#{t.rating.volatility.round(6)}"
end

p thorns.p(chi).inspect
p thorns.p(chi, true).inspect