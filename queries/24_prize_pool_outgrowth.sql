WITH prize_history AS (
    SELECT tournament_id, name, started_at, prize_pool,
           COALESCE(SUM(prize_pool) OVER prior_dates, 0) AS prev_total,
           COUNT(*) OVER prior_dates AS prev_count
    FROM tournaments
    WINDOW prior_dates AS (
        ORDER BY started_at GROUPS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
    )
), match_counts AS (
    SELECT tournament_id, COUNT(*) AS matches_played
    FROM matches
    WHERE tournament_id IS NOT NULL
    GROUP BY tournament_id
)
SELECT t.name AS tournament, t.started_at, t.prize_pool, t.prev_total, t.prev_count,
       COALESCE(mc.matches_played, 0) AS matches_played
FROM prize_history AS t
LEFT JOIN match_counts AS mc ON mc.tournament_id = t.tournament_id
WHERE t.prize_pool > t.prev_total
ORDER BY t.started_at, t.tournament_id;
