WITH RECURSIVE components AS (
    SELECT r.item_id AS root_id, r.component_id,
           r.quantity::numeric AS qty_total,
           ARRAY[r.item_id, r.component_id] AS visited,
           false AS is_cycle
    FROM item_recipe AS r

    UNION ALL

    SELECT c.root_id, r.component_id, c.qty_total * r.quantity,
           c.visited || r.component_id,
           r.component_id = ANY(c.visited) AS is_cycle
    FROM components AS c
    JOIN item_recipe AS r ON r.item_id = c.component_id
    WHERE NOT c.is_cycle
), cyclic_roots AS (
    SELECT DISTINCT root_id
    FROM components
    WHERE is_cycle
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
WHERE NOT EXISTS (
    SELECT 1 FROM cyclic_roots AS cr WHERE cr.root_id = lt.root_id
)
ORDER BY diff DESC, i.name;
