-- 27. Пик онлайна против пика предыдущего эфира того же стримера.
-- Только площадка 'VK Play Live'; prev_peak — пик предыдущего по started_at эфира того
-- же стримера, delta — их разность; первый эфир каждого стримера не выводится.
--
-- Колонки: streamer, followers, started_at, title, peak_viewers, prev_peak, delta
-- Порядок: followers по убыванию, внутри стримера started_at по возрастанию
-- Строк:   592
WITH stream_peaks AS (
    SELECT s.nickname AS streamer, s.followers, st.stream_id,
           st.started_at, st.title, st.peak_viewers,
           LAG(st.peak_viewers) OVER (
               PARTITION BY s.streamer_id ORDER BY st.started_at, st.stream_id
           ) AS prev_peak
    FROM streamers AS s
    JOIN platforms AS pl ON pl.platform_id = s.platform_id
    JOIN streams AS st ON st.streamer_id = s.streamer_id
    WHERE pl.name = 'VK Play Live'
)
SELECT streamer, followers, started_at, title, peak_viewers, prev_peak,
       peak_viewers - prev_peak AS delta
FROM stream_peaks
WHERE prev_peak IS NOT NULL
ORDER BY followers DESC, started_at, streamer, stream_id;
