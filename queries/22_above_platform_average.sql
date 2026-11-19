WITH platform_averages AS (
    SELECT platform_id, AVG(followers) AS platform_avg
    FROM streamers
    GROUP BY platform_id
), current_team AS (
    SELECT DISTINCT ON (player_id) player_id, team_id
    FROM team_members
    WHERE left_at IS NULL
    ORDER BY player_id, joined_at DESC, team_id
)
SELECT s.nickname AS streamer, pl.name AS platform, s.followers,
       ROUND(pa.platform_avg, 2) AS platform_avg, t.tag AS team
FROM streamers AS s
JOIN platforms AS pl ON pl.platform_id = s.platform_id
JOIN platform_averages AS pa ON pa.platform_id = s.platform_id
LEFT JOIN current_team AS tm ON tm.player_id = s.player_id
LEFT JOIN teams AS t ON t.team_id = tm.team_id
WHERE s.followers > pa.platform_avg
ORDER BY s.followers DESC, streamer;
