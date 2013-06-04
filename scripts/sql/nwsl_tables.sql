drop table if exists team;
drop table if exists teams cascade;
create table teams(
  team_id serial primary key,
  scraper_id integer,
  name varchar(50), 
  shortname varchar(3));

drop table if exists games cascade;
create table games(
  game_id serial primary key, 
  home_team_id  integer not null references teams (team_id) on delete cascade,
  away_team_id integer not null  references teams (team_id) on delete cascade,
  home_stat_id integer references stats (stat_id) on delete set null, 
  away_stat_id integer references stats (stat_id) on delete set null,
  played boolean default false,
  game_day date not null);
create unique index games_unique_idx on games(home_team_id,away_team_id,game_day);
\copy teams (team_id, scraper_id, name, shortname) FROM 'teams.db';
SELECT pg_catalog.setval('teams_team_id_seq', 9, false);

drop table if exists team_games;
drop table if exists games_teams;

create table games_teams (
  team_id integer references teams (team_id) on delete cascade,
  game_id integer references games (game_id) on delete cascade,
  CONSTRAINT team_games_pkey PRIMARY KEY(team_id,game_id)
  ) ;

drop table if exists stats cascade;
create table stats(
  stat_id serial primary key, 
  game_id integer not null references games (game_id) on delete cascade,
  team_id integer not null references teams (team_id) on delete cascade,
  goals integer,
  assists integer,
  shots integer,
  shots_on_goal integer,
  saves integer,
  crosses integer,
  corner_kicks integer,
  penalty_kicks integer,
  penalty_kicks_made integer,
  offsides integer,
  fouls_committed integer,
  yellow_cards integer,
  red_cards integer);
create unique index stats_unique_idx on stats(game_id,team_id);
  
drop view if exists score_board cascade;
create view score_board as
  select
  games.game_day,
  home.team_id as home_team_id,
  home.name as home_team,
  home_stats.goals as home_score,
  away.team_id as away_team_id,
  away.name as away_team,
  away_stats.goals as away_score,
  case 
    when home_stats.goals > away_stats.goals then home.name
    when away_stats.goals > home_stats.goals then away.name
    when home_stats.goals = away_stats.goals then NULL
    end as winner,
  case 
    when home_stats.goals > away_stats.goals then home.team_id
    when away_stats.goals > home_stats.goals then away.team_id
    when home_stats.goals = away_stats.goals then NULL
    end as winner_team_id,
  case 
    when home_stats.goals < away_stats.goals then home.team_id
    when away_stats.goals < home_stats.goals then away.team_id
    when home_stats.goals = away_stats.goals then NULL
    end as loser_team_id,
  case when home_stats.goals = away_stats.goals
    then true 
    else false 
    end as draw
  from games 
    JOIN teams as home on home.team_id=games.home_team_id
    JOIN teams as away on away.team_id=games.away_team_id
    join stats as home_stats on (home_stats.game_id=games.game_id and games.home_team_id=home_stats.team_id)
    join stats as away_stats on (away_stats.game_id=games.game_id and games.away_team_id=away_stats.team_id)
  order by game_day,home_team
  ;

drop view if exists wins_count;
create or replace view wins_count as
  select teams.team_id,count(sb.winner_team_id) as wins
  FROM teams
  LEFT OUTER JOIN score_board sb ON (sb.winner_team_id=teams.team_id)
  GROUP by teams.team_id;



drop view if exists draw_count;
create  or replace view draw_count as
select teams.team_id,count(*) as draws
FROM teams
 LEFT OUTER JOIN score_board sb ON (teams.team_id in (home_team_id, away_team_id))
 where sb.draw = true
 GROUP BY teams.team_id;
 

drop view if exists loss_count;
create view loss_count as
  select loser_team_id as team_id,
          count(loser_team_id) as losses
    from score_board
    where loser_team_id is not null
    group by team_id
    ;
  
create or replace view loss_count as
  select teams.team_id,count(sb.loser_team_id) as losses
  FROM teams
  LEFT OUTER JOIN score_board sb ON (sb.loser_team_id=teams.team_id)
  GROUP by teams.team_id;


drop view if exists team_record;
create or replace view team_record as
select teams.team_id,teams.name,
  w.wins,
  l.losses,
  d.draws,
  w.wins + l.losses + d.draws as games_played,
  (w.wins * 3) + d.draws as points_earned
  from teams
  LEFT OUTER JOIN wins_count w ON (teams.team_id = w.team_id)
  LEFT OUTER JOIN loss_count l ON (teams.team_id = l.team_id)
  LEFT OUTER JOIN draw_count d ON (teams.team_id = d.team_id)
  order by points_earned desc;


select *,count(*) from (
SELECT h.name,a.name as opp,played
  FROM games g
  JOIN teams h ON (g.home_team_id=h.team_id)
  JOIN teams a ON (g.away_team_id=a.team_id)
UNION ALL
SELECT a.name,h.name,played
  FROM games g
  JOIN teams h ON (g.home_team_id=h.team_id)
  JOIN teams a ON (g.away_team_id=a.team_id)
) a

group by name,opp,played
order by name,opp
  
  