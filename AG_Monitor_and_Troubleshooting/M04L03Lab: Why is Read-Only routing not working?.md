The issue in the Routing Port `1433` instead of `1435`

Check read-only routing configuration by using the below query:

```sql
select
r1.replica_server_name if_primary, ro.rounting_priority, r2.replica_server_name secondary_replica,
r2.read_only_routing_url,
substring(r2.read_only_routing_url, charindex(':', r2.read_only_routing_url, 10) + 1, 100) ReadOnlyRouting_Port
from sys.availiability_read_only_routing_lists ro
inner join sys.availiability_replicas r1
on ro.replica_id = r1.replica_id
inner join sys.availiability_replicas r2
on ro.read_only_replica_id = r2.replica_id
```

