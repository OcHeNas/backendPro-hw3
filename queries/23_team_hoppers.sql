WITH team_counts AS (
    SELECT player_id, COUNT(DISTINCT team_id) AS teams_count
    FROM team_members
    GROUP BY player_id
    HAVING COUNT(DISTINCT team_id) > 1
), current_team AS (
    SELECT DISTINCT ON (player_id) player_id, team_id
    FROM team_members
    WHERE left_at IS NULL
    ORDER BY player_id, joined_at DESC, team_id
)
SELECT p.nickname AS player, p.country, tc.teams_count,
       t.name AS current_team, s.nickname AS streamer
FROM team_counts AS tc
JOIN players AS p ON p.player_id = tc.player_id
LEFT JOIN current_team AS tm ON tm.player_id = p.player_id
LEFT JOIN teams AS t ON t.team_id = tm.team_id
LEFT JOIN streamers AS s ON s.player_id = p.player_id
ORDER BY tc.teams_count DESC, player;
