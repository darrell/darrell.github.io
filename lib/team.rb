require 'glicko2'
class Team < Sequel::Model
  many_to_many :games
  one_to_many :stats
  one_to_many :home_games, :class => :Game, :key => :home_team_id
  one_to_many :away_games, :class => :Game, :key => :away_team_id

  attr_accessor :ranking

  def initialize()
    @ranking = Glicko2.new()
    super()
  end

end
