WITH donation_totals AS (
    SELECT st.streamer_id, COUNT(*) AS donations, SUM(d.amount) AS total_amount
    FROM streams AS st
    JOIN stream_donations AS d ON d.stream_id = st.stream_id
    GROUP BY st.streamer_id
), current_team AS (
    SELECT DISTINCT ON (player_id) player_id, team_id
    FROM team_members
    WHERE left_at IS NULL
    ORDER BY player_id, joined_at DESC, team_id
)
SELECT s.nickname AS streamer, pl.name AS platform, t.name AS team,
       COALESCE(dt.donations, 0) AS donations,
       ROUND(COALESCE(dt.total_amount, 0), 2) AS total_amount
FROM streamers AS s
JOIN platforms AS pl ON pl.platform_id = s.platform_id
LEFT JOIN donation_totals AS dt ON dt.streamer_id = s.streamer_id
LEFT JOIN current_team AS tm ON tm.player_id = s.player_id
LEFT JOIN teams AS t ON t.team_id = tm.team_id
ORDER BY total_amount DESC, streamer;
