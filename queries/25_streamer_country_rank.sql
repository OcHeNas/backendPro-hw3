WITH ranked_players AS (
    SELECT player_id, nickname, country, mmr,
           RANK() OVER (PARTITION BY country ORDER BY mmr DESC) AS country_rank,
           COUNT(*) OVER (PARTITION BY country) AS country_players
    FROM players
), current_team AS (
    SELECT DISTINCT ON (player_id) player_id, team_id
    FROM team_members
    WHERE left_at IS NULL
    ORDER BY player_id, joined_at DESC, team_id
)
SELECT p.nickname AS player, p.country, p.mmr, p.country_rank,
       p.country_players, t.tag AS team_tag, pl.name AS platform
FROM ranked_players AS p
JOIN streamers AS s ON s.player_id = p.player_id
JOIN current_team AS tm ON tm.player_id = p.player_id
JOIN teams AS t ON t.team_id = tm.team_id
JOIN platforms AS pl ON pl.platform_id = s.platform_id
ORDER BY p.country, p.country_rank, p.nickname;
