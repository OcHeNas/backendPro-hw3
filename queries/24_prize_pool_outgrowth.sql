-- 24. Турниры, чей призовой фонд больше суммы призовых всех предыдущих.
-- Предыдущие — со строго меньшим started_at, сравнение строгое; у первого турнира
-- prev_total и prev_count нули, не NULL; matches_played — число матчей турнира.
--
-- Колонки: tournament, started_at, prize_pool, prev_total, prev_count, matches_played
-- Порядок: started_at по возрастанию
-- Строк:   2
SELECT t.name AS tournament, t.started_at, t.prize_pool,
       prev.prev_total, prev.prev_count,
       (SELECT COUNT(*) FROM matches AS m
        WHERE m.tournament_id = t.tournament_id) AS matches_played
FROM tournaments AS t
CROSS JOIN LATERAL (
    SELECT COALESCE(SUM(earlier.prize_pool), 0) AS prev_total,
           COUNT(*) AS prev_count
    FROM tournaments AS earlier
    WHERE earlier.started_at < t.started_at
) AS prev
WHERE t.prize_pool > prev.prev_total
ORDER BY t.started_at, t.tournament_id;
