WITH player_games AS (
    SELECT mp.player_id, COUNT(*) AS games,
           COUNT(*) FILTER (WHERE h.name = 'Pudge') AS pudge_games
    FROM match_players AS mp
    JOIN heroes AS h ON h.hero_id = mp.hero_id
    GROUP BY mp.player_id
), current_team AS (
    SELECT DISTINCT ON (player_id) player_id, team_id
    FROM team_members
    WHERE left_at IS NULL
    ORDER BY player_id, joined_at DESC, team_id
)
SELECT s.nickname AS streamer, pl.name AS platform, t.tag AS team, s.followers,
       COALESCE(pg.games, 0) AS games
FROM streamers AS s
JOIN platforms AS pl ON pl.platform_id = s.platform_id
LEFT JOIN player_games AS pg ON pg.player_id = s.player_id
LEFT JOIN current_team AS tm ON tm.player_id = s.player_id
LEFT JOIN teams AS t ON t.team_id = tm.team_id
WHERE s.player_id IS NOT NULL AND COALESCE(pg.pudge_games, 0) = 0
ORDER BY s.followers DESC, streamer;
