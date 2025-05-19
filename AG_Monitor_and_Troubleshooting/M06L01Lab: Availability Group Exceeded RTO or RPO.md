

```sql
select db.name database_name, ag.name ag_name, r.replica_server_name, dbrs.is_local,
case dbrs.is_primary when 1 then 'Primary' else 'Secondary' end Role, dbrs.database_state_desc,
cast(dbrs.log_send_queue_size/1024.0 as decimal(10,2)) [log send queue MB (RPO)],
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
