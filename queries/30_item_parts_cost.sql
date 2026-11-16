-- 30. Стоимость сборки из базовых составляющих против собственной цены предмета.
-- Берутся предметы со строками в item_recipe, сборка раскрывается до базовых (тех, у кого
-- строк в item_recipe нет, свитки тоже), количества по пути перемножаются; diff = parts_cost - cost.
--
-- Колонки: name, cost, parts_cost, base_parts, diff
-- Порядок: diff по убыванию, при равенстве name по возрастанию
-- Строк:   77
WITH RECURSIVE components AS (
    SELECT r.item_id AS root_id, r.component_id,
           r.quantity::bigint AS qty_total,
           ARRAY[r.item_id, r.component_id] AS visited
    FROM item_recipe AS r

    UNION ALL

    SELECT c.root_id, r.component_id, c.qty_total * r.quantity,
           c.visited || r.component_id
    FROM components AS c
    JOIN item_recipe AS r ON r.item_id = c.component_id
    WHERE NOT r.component_id = ANY(c.visited)
), leaf_totals AS (
    SELECT c.root_id, SUM(i.cost * c.qty_total) AS parts_cost,
           SUM(c.qty_total) AS base_parts
    FROM components AS c
    JOIN items AS i ON i.item_id = c.component_id
    WHERE NOT EXISTS (
        SELECT 1 FROM item_recipe AS r WHERE r.item_id = c.component_id
    )
    GROUP BY c.root_id
)
SELECT i.name, i.cost, lt.parts_cost, lt.base_parts,
       lt.parts_cost - i.cost AS diff
FROM leaf_totals AS lt
JOIN items AS i ON i.item_id = lt.root_id
ORDER BY diff DESC, i.name;
