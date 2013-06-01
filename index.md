---
layout: page
title: NWSL Statistics
---
<style>
table {
  border-collapse:collapse;
}
table, th, td {
border: 1px solid black;
font-size: 90%;
padding: 5px;
}
</style>
## Scoreboard
[As CSV](scoreboard.csv)

game_day|home team|away team|home score|away score|winner|draw
--------|---------|---------|:--------:|:--------:|------|----
{% include scoreboard.md %}

## Current Overall Record
[As CSV](team_record.csv)

team|win|lose|draw|games played|pts
----|:-:|:--:|:--:|:----------:|:-:
{% include team_record.md %}
