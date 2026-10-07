SELECT
  t.name AS TableName,
  SUM(p.rows) AS RowCount
FROM sys.tables t
INNER JOIN sys.partitions p
ON t.object_id = p.object_id
WHERE p.index_id IN (0,1) -- Heap 或 Clustered Index
GROUP BY t.name
ORDER BY t.name;
