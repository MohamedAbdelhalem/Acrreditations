The issue in the Routing Port `1433` instead of `1435`

Check read-only routing configuration by using the below query:

```sql
select
ag.name ag_name,
r1.replica_server_name if_primary, ro.rounting_priority, r2.replica_server_name secondary_replica,
r2.read_only_routing_url,
substring(r2.read_only_routing_url, charindex(':', r2.read_only_routing_url, 10) + 1, 100) ReadOnlyRouting_Port,
r2.secondary_role_allow_connections_desc
from sys.availiability_read_only_routing_lists ro
inner join sys.availiability_replicas r1
on ro.replica_id = r1.replica_id
inner join sys.availiability_replicas r2
on ro.read_only_replica_id = r2.replica_id
inner join sys.availability_groups ag
on ag.group_id = r1.group_id
```

Alter it with the correct configuration

```sql

ALTER AVAILABILITY GROUP [AGCorp] MODIFY REPLICA ON N'AlwaysOnN1' WITH (SECONDARY_ROLE (ALLOW_CONNECTIONS = ALL));
GO
ALTER AVAILABILITY GROUP [AGCorp] MODIFY REPLICA ON N'AlwaysOnN1' WITH (SECONDARY_ROLE (READ_ONLY_ROUTING_URL = N'TCP://AlwaysOnN1:1433'));
GO
ALTER AVAILABILITY GROUP [AGCorp] MODIFY REPLICA ON N'AlwaysOnN1' WITH (PRIMARY_ROLE (READ_ONLY_ROUTING_LIST=('AlwaysOnN2','AlwaysOnN3')));
GO
ALTER AVAILABILITY GROUP [AGCorp] MODIFY REPLICA ON N'AlwaysOnN2' WITH (SECONDARY_ROLE (ALLOW_CONNECTIONS = ALL));
GO
ALTER AVAILABILITY GROUP [AGCorp] MODIFY REPLICA ON N'AlwaysOnN2' WITH (SECONDARY_ROLE (READ_ONLY_ROUTING_URL = N'TCP://AlwaysOnN2:1433'));
GO
ALTER AVAILABILITY GROUP [AGCorp] MODIFY REPLICA ON N'AlwaysOnN2' WITH (PRIMARY_ROLE (READ_ONLY_ROUTING_LIST=('AlwaysOnN1','AlwaysOnN3')));
GO
ALTER AVAILABILITY GROUP [AGCorp] MODIFY REPLICA ON N'AlwaysOnN3' WITH (SECONDARY_ROLE (ALLOW_CONNECTIONS = ALL));
GO
ALTER AVAILABILITY GROUP [AGCorp] MODIFY REPLICA ON N'AlwaysOnN3' WITH (SECONDARY_ROLE (READ_ONLY_ROUTING_URL = N'TCP://AlwaysOnN2:1433'));
GO
ALTER AVAILABILITY GROUP [AGCorp] MODIFY REPLICA ON N'AlwaysOnN3' WITH (PRIMARY_ROLE (READ_ONLY_ROUTING_LIST=('AlwaysOnN1','AlwaysOnN2')));
GO
```

```
