WITH RECURSIVE component_tree AS (
    SELECT root.name AS root_item, 1 AS lvl, c.item_id AS component_id,
           c.name AS component, r.quantity AS qty,
           r.quantity::numeric AS qty_total,
           root.name || ' > ' || c.name AS path,
           ARRAY[root.item_id, c.item_id] AS visited
    FROM items AS root
    JOIN item_recipe AS r ON r.item_id = root.item_id
    JOIN items AS c ON c.item_id = r.component_id
    WHERE root.name IN ('Guardian Greaves', 'Bloodthorn', 'Harpoon', 'Hurricane Pike')

    UNION ALL

    SELECT tree.root_item, tree.lvl + 1, c.item_id, c.name, r.quantity,
           tree.qty_total * r.quantity,
           tree.path || ' > ' || c.name,
           tree.visited || c.item_id
    FROM component_tree AS tree
    JOIN item_recipe AS r ON r.item_id = tree.component_id
    JOIN items AS c ON c.item_id = r.component_id
    WHERE NOT c.item_id = ANY(tree.visited)
)
SELECT root_item, lvl, component, qty, qty_total, path
FROM component_tree
ORDER BY root_item, path;
