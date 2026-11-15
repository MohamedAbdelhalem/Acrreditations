select es.session_id, case 
when isnull(r.status ,es.status) = 'suspended' and isnull(r.blocking_session_id,0) < 0                           then 0
when isnull(r.status ,es.status) = 'suspended' and isnull(r.blocking_session_id,0) > 0                           then 1
when isnull(r.status ,es.status) = 'suspended' and isnull(r.blocking_session_id,0) = 0                           then 2
when isnull(r.status ,es.status) = 'sleeping' and isnull(r.open_transaction_count,es.open_transaction_count) > 0 then 3
when isnull(r.status ,es.status) = 'runnable'                                                                    then 4
when isnull(r.status ,es.status) = 'running'                                                                     then 5
when isnull(r.status ,es.status) = 'sleeping' and isnull(r.open_transaction_count,es.open_transaction_count) = 0 then 6
when isnull(r.status ,es.status) = 'background'                                                                  then 7
end flag,
isnull(request_id,0) request_id, 
isnull(mar.MARS,0) MARS,
isnull(r.status ,es.status) status, command,
es.login_name, db_name(r.database_id) database_name, 
isnull(r.blocking_session_id,0) blocked, 
isnull(r.open_transaction_count,es.open_transaction_count) open_trans,
s.text sql_text, m.text most_recent_sql,
last_wait_type, 
program_name, host_name, 
client_net_address,
substring(s.text,(statement_start_offset/2)+1, case when statement_end_offset < 0 then len(s.text)*2 else ((statement_end_offset-statement_start_offset)/2)-1 end) current_sql
from sys.dm_exec_sessions es left outer join sys.dm_exec_requests r 
on r.session_id = es.session_id
outer apply sys.dm_exec_sql_text(r.sql_handle)s
left outer join sys.dm_exec_connections c
on r.session_id = c.session_id
left outer join (select count(*)-1 MARS, session_id from sys.dm_exec_requests group by session_id having count(*) > 1) mar
on es.session_id = mar.session_id
left outer join (select session_id, text from sys.dm_exec_connections cc cross apply sys.dm_exec_sql_text(cc.most_recent_sql_handle)ss) m
on es.session_id = m.session_id
order by flag
