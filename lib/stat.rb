class Stat < Sequel::Model
  many_to_one :game
  many_to_one :team
end

