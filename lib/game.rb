class Game < Sequel::Model
  many_to_many :teams
  one_to_many :stats
  many_to_one :home_team, :class=>:Team
  many_to_one :away_team, :class=>:Team
  
  def home_score
    Stat.where(:team_id => home_team_id, :game_id => game_id).first.goals
  end
  def away_score
    Stat.where(:team_id => away_team_id, :game_id => game_id).first.goals
  end

  def home_win?
    return home_score > away_score
  end

  def away_win?
    return home_score > away_score
  end

  def draw?
     return home_score == away_score
   end
end
