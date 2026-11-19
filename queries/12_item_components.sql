-- 12. Сборные предметы внутри сборных предметов.
-- Пары «предмет — непосредственный компонент», где компонент сам встречается
-- в item_recipe.item_id; каждая пара один раз, component_cost — цена штуки.
--
-- Колонки: item_name, component_name, quantity, component_cost
-- Порядок: item_name по возрастанию, внутри предмета component_name по возрастанию
-- Строк:   36
SELECT i.name AS item_name, c.name AS component_name, r.quantity,
       c.cost AS component_cost
FROM item_recipe AS r
JOIN items AS i ON i.item_id = r.item_id
JOIN items AS c ON c.item_id = r.component_id
WHERE EXISTS (
    SELECT 1 FROM item_recipe AS child WHERE child.item_id = c.item_id
)
ORDER BY item_name, component_name;
