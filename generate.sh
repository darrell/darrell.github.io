export PGDATABASE=nwsl
# scoreboard
psql -c "\copy (SELECT game_day  , home_team, away_team,home_score, away_score, winner, draw  from score_board) to '_includes/scoreboard.md' csv DELIMITER '|' NULL ' '" 
psql -c "\copy (select * from score_board) to 'tables/scoreboard.csv' csv header"

# team_record
psql -c "\copy (SELECT name,wins,losses,draws,games_played,points_earned from team_record) to '_includes/team_record.md' csv DELIMITER '|' NULL ' '" 
psql -c "\copy (select * from team_record) to 'tables/team_record.csv' csv header"


R CMD BATCH rankings.r || cat rankings.r.Rout
