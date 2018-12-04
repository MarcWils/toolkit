SELECT w.session_id
     , w.wait_duration_ms
     , w.wait_type
     , w.blocking_session_id
     , w.resource_description
     , s.program_name
     , t.text
     , [statement_text]=SUBSTRING(t.text, (r.statement_start_offset/2)+1,
                        ((CASE r.statement_end_offset
                            WHEN -1 THEN DATALENGTH(t.text)
                                ELSE r.statement_end_offset
                            END - r.statement_start_offset)/2) + 1)
     , t.dbid
 FROM sys.dm_os_waiting_tasks as w
      INNER JOIN sys.dm_exec_sessions as s
         ON w.session_id = s.session_id
      INNER JOIN sys.dm_exec_requests as r 
         ON s.session_id = r.session_id
      OUTER APPLY sys.dm_exec_sql_text (r.sql_handle) as t
  WHERE (s.is_user_process = 1)
  ORDER BY w.wait_duration_ms desc
