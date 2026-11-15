select r.session_id, case 
when r.status = 'suspended' and blocking_session_id < 0     then 0
when r.status = 'suspended' and blocking_session_id > 0     then 1
when r.status = 'suspended' and blocking_session_id = 0     then 2
when r.status = 'sleeping' and r.open_transaction_count > 0 then 3
when r.status = 'runnable'                                  then 4
when r.status = 'running'                                   then 5
when r.status = 'sleeping' and r.open_transaction_count = 0 then 6
when r.status = 'background'                                then 7
end flag,
request_id, count(*)over(partition by r.session_id)-1 MARS, r.status, command,
l.name loginame, db_name(r.database_id) database_name, s.text sql_text, last_wait_type, r.blocking_session_id, program_name, host_name, client_net_address,
substring(s.text,(statement_start_offset/2)+1, case when statement_end_offset < 0 then len(s.text)*2 else ((statement_end_offset-statement_start_offset)/2)-1 end) current_sql
from sys.dm_exec_requests r cross apply sys.dm_exec_sql_text(r.sql_handle)s
inner join sys.dm_exec_sessions es
on r.session_id = es.session_id
left outer join sys.syslogins l
on es.security_id = l.sid 
inner join sys.dm_exec_connections c
on r.session_id = c.session_id
order by flag
