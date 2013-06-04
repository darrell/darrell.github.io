class Game < Sequel::Model
  many_to_many :teams
  one_to_many :stats
  many_to_one :home_team, :class=>:Team
  many_to_one :away_team, :class=>:Team
  
  def home_score
    x=Stat.where(:team_id => home_team_id, :game_id => game_id).first
    x.nil? ? nil : x.goals
  end
  def away_score
    x=Stat.where(:team_id => away_team_id, :game_id => game_id).first
    x.nil? ? nil : x.goals
  end

  def home_win?
    return nil unless home_score && away_score
    return home_score > away_score
  end

  def away_win?
    return nil unless home_score && away_score
    return home_score < away_score
  end

  def draw?
      return nil unless home_score && away_score
     return home_score == away_score
   end
end
