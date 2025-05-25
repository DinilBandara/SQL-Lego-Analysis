--Which parts are most frequently used as spares?
SELECT
    ip.part_num,
    p.name,
    COUNT(*) AS spare_count
FROM analysis.inventory_parts ip
JOIN analysis.parts p ON p.part_num = ip.part_num
WHERE ip.is_spare = 't'
GROUP BY ip.part_num, p.name
ORDER BY spare_count DESC
LIMIT 20;


--Which themes rely heavily on reused vs. unique parts?
SELECT
    t.name AS theme_name,
    COUNT(DISTINCT ip.part_num) AS total_parts,
    COUNT(DISTINCT up.part_num) AS unique_parts,
    ROUND(COUNT(DISTINCT up.part_num)::numeric / NULLIF(COUNT(DISTINCT ip.part_num), 0), 3) AS uniqueness_ratio
FROM analysis.themes t
JOIN analysis.sets s ON s.theme_id = t.id
JOIN analysis.inventories i ON s.set_num = i.set_num
JOIN analysis.inventory_parts ip ON ip.inventory_id = i.id
LEFT JOIN (
    SELECT part_num
    FROM analysis.inventory_parts
    GROUP BY part_num
    HAVING COUNT(DISTINCT inventory_id) = 1
) up ON up.part_num = ip.part_num
GROUP BY t.name
ORDER BY uniqueness_ratio DESC
LIMIT 15;

