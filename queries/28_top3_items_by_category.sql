-- 28. Три самых дорогих предмета в каждой категории лавки.
-- Категория: 'recipe' при is_recipe, иначе 'assembled' при строках в item_recipe.item_id,
-- иначе 'basic'; place 1-3 по cost убыв., при равной цене по name; purchases — строк match_items, иначе 0.
--
-- Колонки: category, place, name, cost, purchases
-- Порядок: category по возрастанию, затем place по возрастанию
-- Строк:   9
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
)
SELECT i.category, i.place, i.name, i.cost,
       (SELECT COUNT(*) FROM match_items AS mi
        WHERE mi.item_id = i.item_id) AS purchases
FROM ranked_items AS i
WHERE i.place <= 3
ORDER BY i.category, i.place;
