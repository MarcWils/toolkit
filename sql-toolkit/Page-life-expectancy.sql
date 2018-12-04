SELECT cntr_value AS [Page Life Expectancy], *
FROM sys.dm_os_performance_counters
WHERE counter_name = N'Page life expectancy'
AND object_name like '%:Buffer Manager%'; 