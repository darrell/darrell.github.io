require 'rubygems'
require "bundler/setup" 
$:<<File.dirname(__FILE__)+'/../lib'
require 'sequel'
require 'scraper/team_log'
require 'nwsl'
require 'pry'
require 'csv'
require 'logger'

DB.loggers << ::Logger.new('load_games.log')

def wld(game,is_home)

  if game.home_score == game.away_score
    return nil
  end
  if game.home_score > game.away_score
    return is_home
  else
    return !is_home
  end
end

def team_link_text(s)
  case s
  when 'BOS' then '[[Boston Breakers (WPS)|Boston Breakers]]'
  when 'CHI' then '[[Chicago Red Stars]]'
  when 'KC' then '[[FC Kansas City]]'
  when 'POR' then '[[Portland Thorns FC]]'
  when 'SEA' then '[[Seattle Reign FC]]'
  when 'NJ' then '[[Sky Blue FC]]'
  when 'WAS' then '[[Washington Spirit]]'
  when 'WNY' then '[[Western New York Flash]]'
  end
end


Team.all.sort_by{|t| t.name}.each do |t|
  # matches is a hash of four arrays:
  # opponent (short name)
  # home_flag (bool)
  # score (home-away)
  # wld (win, lose, draw)

  matches={}
  matches[:opponent]=[]
  matches[:home_flag]=[]
  matches[:score]=[]
  matches[:wld]=[]

  home_style='style="background:silver;"'
  win_style='style="background:#dfe7ff;"'
  draw_style='style="background:#fffdd0;"'
  loss_style='style="background:#ffdfdf;"'

  t.games.sort_by{|g| g.game_day}.each do |g|
    if g.home_team == t
      matches[:opponent] << "#{home_style}|#{g.away_team.shortname}"
      matches[:home_flag] << true
      if g.played
        match_style=case wld(g,true)
          when true
            win_style
          when false
            loss_style
          when nil
            draw_style
          end
        matches[:wld] << wld(g,true)
        matches[:score] << "#{match_style} | #{g.home_score}-#{g.away_score} "
      else
        matches[:wld] << ' '
        matches[:score] << ' '
      end
    else
      matches[:opponent] << g.home_team.shortname
      matches[:home_flag] << false
      if g.played
        match_style=case wld(g,false)
          when true
            win_style
          when false
            loss_style
          when nil
            draw_style
          end
        matches[:wld] << wld(g,false)
        matches[:score] << " #{match_style} | #{g.home_score}-#{g.away_score} "
      else
        matches[:wld] << ' '
        matches[:score] << ' '
      end
    end
  end
  
  puts %Q{|- style="font-size: 75%"\n|rowspan="2"|#{team_link_text(t.shortname)} || } + matches[:opponent].join('||')
  # puts matches[:home_flag]=
  puts %Q{|- style="font-size: 75%"\n|} + matches[:score].join('||')
  # puts matches[:wld].join('||')
end
    
  

  
