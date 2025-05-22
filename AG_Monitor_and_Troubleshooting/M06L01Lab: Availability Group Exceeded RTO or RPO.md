
To effectively monitor both `RTO` and `RPO`, please use the script provided below.

```sql
select db.name database_name, ag.name ag_name, r.replica_server_name, dbrs.is_local,
case dbrs.is_primary when 1 then 'Primary' else 'Secondary' end Role, dbrs.database_state_desc,
cast(dbrs.log_send_queue_size/1024.0 as decimal(10,2)) [log send queue MB (RPO)],
convert(varchar(10),dateadd(s,dbrs.log_send_queue_size/dbrs.log_send_rate,'2000-01-01'),108) RPO,
cast(dbrs.redo_queue_size/1024.0 as decimal(10,2)) [redo queue MB (RTO)],
convert(varchar(10),dateadd(s,dbrs.redo_queue_size/dbrs.redo_rate,'2000-01-01'),108) RTO,
dbrs.synchronization_state_desc
from sys.dm_hadr_database_replica_states dbrs inner join sys.databases db
on dbrs.database_id = db.database_id
inner join sys.availability_groups ag
on dbrs.group_id = ag.group_id
inner join sys.availability_replicas r
on dbrs.replica_id = r.replica_id
where is_local = 1
```

You can monitor background sessions for any `head blockers`, `blocking`, or `locking` using the script provided below.

```sql

declare @sessions int
declare @blocking_sessions table (spid int, blocking_session_id int, level int)
declare @maxrecursion int = 100
declare @dynamic_sql nvarchar(max)

select @sessions = count(*) from sys.sysprocesses

exec sp_executesql @dynamic_sql, N'@num_sessions int output', @num_sessions = @sessions output
set @maxrecursion = @sessions/2

set @dynamic_sql = 'declare @recusive_sessions table (spid int, blocking_session_id int, level int)
;with recusive_sessions (spid, blocking_session_id, level)
as
(
select spid, blocking_session_id, 0 level
from (
select spid, case when spid in (select blocked from sys.sysprocesses) and blocked = 0 then NULL else blocked end blocking_session_id
from sys.sysprocesses)a
where blocking_session_id is null
union all
select sp.spid, sp.blocked, level + 1
from recusive_sessions rs inner join sys.sysprocesses sp
on rs.spid = sp.blocked
)
INSERT INTO @recusive_sessions
SELECT * FROM recusive_sessions 
OPTION (MAXRECURSION '+cast(@maxrecursion as nvarchar(100))+')

select *
from @recusive_sessions
order by level'

insert into @blocking_sessions
exec sp_executesql @dynamic_sql

select p.spid, isnull(bs.level,100000) level, p.loginame, db_name(p.dbid) database_name, 
case p.status 
when 'suspended' then 1
when 'runnable'  then 2
when 'running'   then 3
when 'sleeping'  then 4
else 5
end flag,
p.status,lastwaittype, p.cmd, s.text, s.current_sql, 
convert(varchar(10), dateadd(s, datediff(s, r.start_time, getdate()), '2000-01-01'), 108) duration,
waittime, blocked, bs.blocking_session_id, hostname, c.client_net_address, program_name
from sys.sysprocesses p left outer join @blocking_sessions bs
on p.spid = bs.spid
left outer join (select pp.spid, ss.text, substring(ss.text, (stmt_start/2)+1, case when stmt_end < 0 then len(ss.text) else ((stmt_end - stmt_start)/2)+1 end) current_sql
                 from sys.sysprocesses pp cross apply sys.dm_exec_sql_text(pp.sql_handle)ss
                )s
on p.spid = s.spid
left outer join sys.dm_exec_requests r
on p.spid = r.session_id
inner join sys.dm_exec_connections c
on p.spid = c.session_id
order by bs.level, flag

```
