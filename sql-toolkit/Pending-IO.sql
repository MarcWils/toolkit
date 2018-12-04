select
   db_name(vfs.database_id) as database_name,
   mf.name as logical_file_name,
   pr.io_type,
   sum(pr.io_pending_ms_ticks) as sum_io_pending_ms_ticks,
   count(*) as [count]
from
   sys.dm_io_pending_io_requests pr
      left join sys.dm_io_virtual_file_stats(null, null) vfs on vfs.file_handle = pr.io_handle
         left join sys.master_files mf on mf.database_id = vfs.database_id
                               and mf.file_id = vfs.file_id
where
   pr.io_pending = 1 
group by
   db_name(vfs.database_id),
   mf.name,
   pr.io_type;
   