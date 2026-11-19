WITH categorized_items AS (
    SELECT i.item_id, i.name, i.cost,
           CASE
               WHEN i.is_recipe THEN 'recipe'
               WHEN EXISTS (
                   SELECT 1 FROM item_recipe AS r WHERE r.item_id = i.item_id
               ) THEN 'assembled'
               ELSE 'basic'
           END AS category
    FROM items AS i
), ranked_items AS (
    SELECT item_id, name, cost, category,
           ROW_NUMBER() OVER (
               PARTITION BY category ORDER BY cost DESC, name
           ) AS place
    FROM categorized_items
), top_items AS (
    SELECT item_id, category, place, name, cost
    FROM ranked_items
    WHERE place <= 3
), purchase_counts AS (
    SELECT mi.item_id, COUNT(*) AS purchases
    FROM match_items AS mi
    JOIN top_items AS i ON i.item_id = mi.item_id
    GROUP BY mi.item_id
)
SELECT i.category, i.place, i.name, i.cost, COALESCE(pc.purchases, 0) AS purchases
FROM top_items AS i
LEFT JOIN purchase_counts AS pc ON pc.item_id = i.item_id
ORDER BY i.category, i.place;
