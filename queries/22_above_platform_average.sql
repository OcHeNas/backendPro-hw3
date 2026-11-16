-- 22. Стримеры с подписчиками выше среднего по своей площадке.
-- Строго больше среднего по всем стримерам площадки, сам стример в среднее входит;
-- platform_avg до 2 знаков; team — тег действующей команды, иначе NULL.
--
-- Колонки: streamer, platform, followers, platform_avg, team
-- Порядок: followers по убыванию, при равенстве streamer по возрастанию
-- Строк:   16
WITH platform_averages AS (
    SELECT platform_id, AVG(followers) AS platform_avg
    FROM streamers
    GROUP BY platform_id
)
SELECT s.nickname AS streamer, pl.name AS platform, s.followers,
       ROUND(pa.platform_avg, 2) AS platform_avg, t.tag AS team
FROM streamers AS s
JOIN platforms AS pl ON pl.platform_id = s.platform_id
JOIN platform_averages AS pa ON pa.platform_id = s.platform_id
LEFT JOIN team_members AS tm ON tm.player_id = s.player_id AND tm.left_at IS NULL
LEFT JOIN teams AS t ON t.team_id = tm.team_id
WHERE s.followers > pa.platform_avg
ORDER BY s.followers DESC, streamer;
