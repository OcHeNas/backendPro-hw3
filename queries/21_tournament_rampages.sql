WITH performances AS (
    SELECT match_id, slot, player_id, hero_id,
           (kills::numeric + assists) / GREATEST(deaths, 1) AS raw_kda
    FROM match_players
)
SELECT mp.match_id, t.name AS tournament, p.nickname AS player,
       h.name AS hero, ROUND(mp.raw_kda, 2) AS kda
FROM performances AS mp
JOIN matches AS m ON m.match_id = mp.match_id
JOIN tournaments AS t ON t.tournament_id = m.tournament_id
JOIN players AS p ON p.player_id = mp.player_id
JOIN heroes AS h ON h.hero_id = mp.hero_id
WHERE mp.raw_kda > (SELECT 6 * AVG(raw_kda) FROM performances)
ORDER BY kda DESC, mp.match_id, mp.slot;
