SELECT a.object_name, (a.cntr_value * 1.0 / b.cntr_value) * 100.0 AS [Buffer Cache Hit Ratio]
FROM sys.dm_os_performance_counters AS a
INNER JOIN (SELECT cntr_value, pc.[object_name]
            FROM sys.dm_os_performance_counters pc
            WHERE counter_name = N'Buffer cache hit ratio base'
            ) AS b
ON a.[object_name] = b.[object_name]
WHERE a.counter_name = N'Buffer cache hit ratio'
GROUP BY a.object_name, a.cntr_value, b.cntr_value;