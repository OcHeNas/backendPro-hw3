SELECT t.name, t.tag,
       COUNT(DISTINCT tm.player_id) AS players_now,
       COUNT(DISTINCT s.player_id) AS streamers_now
FROM teams AS t
LEFT JOIN team_members AS tm ON tm.team_id = t.team_id AND tm.left_at IS NULL
LEFT JOIN streamers AS s ON s.player_id = tm.player_id
GROUP BY t.team_id, t.name, t.tag
ORDER BY players_now DESC, t.name;
