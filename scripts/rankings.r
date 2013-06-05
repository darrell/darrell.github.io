require(fbRanks)
library("RPostgreSQL")
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="nwsl", user="darrell", host="localhost")

scores=dbGetQuery(con,'
SELECT games.game_day as date,  home.name AS "home.team", 
    home_stats.goals AS "home.score",
    away.name AS "away.team", 
    away_stats.goals AS "away.score"
   FROM games
   JOIN teams home ON home.team_id = games.home_team_id
   JOIN teams away ON away.team_id = games.away_team_id
   LEFT OUTER JOIN stats home_stats ON home_stats.game_id = games.game_id AND games.home_team_id = home_stats.team_id
   LEFT OUTER JOIN stats away_stats ON away_stats.game_id = games.game_id AND games.away_team_id = away_stats.team_id
  ORDER BY games.game_day, home.name;
  
');

# scores=read.csv('games.csv', na = NaN,colClasses=c("Date","character","character","integer","integer"))
# 
scores$home.adv="home"
scores$away.adv="away"


played=subset(scores, home.score >= 0)
unplayed=subset(scores,is.na(home.score))
unplayed$home.score=NaN
unplayed$away.score=NaN

nsim=100000

# rank based on played games
ranks=rank.teams(scores=played,max.date=Sys.Date(),add=c("adv"))

# simulate the unplayed ones
sims=simulate(ranks,newdata=unplayed,points.rule="league3pt",nsim=nsim)

# generating predictions for played and unplayed games
unplayed_predictions=predict(ranks,newdata=unplayed)
played_predictions=predict(ranks,newdata=played)

#standings
#Set up the matrix that will hold the standings
bteams=rownames(sims)
pstandings=matrix(0,8,8)
rownames(pstandings)=rownames(sims)
#column names will the 1st-nth
colnames(pstandings)=paste(1:length(bteams),c("st","nd","rd",rep("th",length(bteams)-3)),sep="")

# from fbStats code
for(team in bteams){
  #need to wrap standings in factor so I can set levels.  Otherwise won't get the 0s when say a team is never 4th
  pstandings[team,]=table(factor(sims[team,],levels=1:length(bteams))) /nsim
}
   
# write out the standings
write.table(round(pstandings*100,digits=0), file="/Users/darrell/nwsl/_includes/predicted_standings.md", col.names=FALSE, sep = "|", quote=FALSE,row.names=FALSE,na=" ")
write.csv(round(pstandings*100,digits=0), file="/Users/darrell/nwsl/tables/predicted_standings.csv",na="")

# Rankings
x=print(ranks, silent=TRUE,scaling=0)
write.table(x$ranks, file="/Users/darrell/nwsl/_includes/rankings.md",col.names=FALSE, sep = "|",quote=FALSE,row.names=FALSE,na=" ")
write.csv(x$ranks, file="/Users/darrell/nwsl/tables/rankings.csv",na="")

# predictions
# only want some columns
pred_cols=c("date",
            "home.team","away.team", 
            "home.attack", "home.defend",
            "away.attack", "away.defend",
            "pred.home.score","pred.away.score",
            "home.win","away.win","tie", "home.shutout","away.shutout")

# unplayed games predictions
write.table(unplayed_predictions$scores[,pred_cols], 
            file="/Users/darrell/nwsl/_includes/predicted_results_games_unplayed.md", 
            sep = "|", quote=FALSE, row.names=FALSE, col.names=FALSE, na=" ")
write.csv(unplayed_predictions$scores, 
          file="/Users/darrell/nwsl/tables/predicted_results_games_unplayed.csv",
          row.names=FALSE, na="")

# played games predictions
write.table(played_predictions$scores[,pred_cols], 
            file="/Users/darrell/nwsl/_includes/predicted_results_games_played.md", 
            sep = "|", quote=FALSE, row.names=FALSE, col.names=FALSE, na=" ")
write.csv(played_predictions$scores, 
          file="/Users/darrell/nwsl/tables/predicted_results_games_played.csv",
          row.names=FALSE, na="")

