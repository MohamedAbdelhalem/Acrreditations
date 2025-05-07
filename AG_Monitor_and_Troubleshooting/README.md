**WorkshopPLUS - SQL Server: AlwaysOn Availability Groups and Failover Cluster Instances** - *Monitoring and Troubleshooting* `20240528` [**link**](https://mslearningcampus.com/LabSeries/19855)


**SQL Server 2016 Always On Availability Groups Guide** `Architectural Overview and Best Practices` [**document**](https://microsoft.sharepoint.com/:w:/r/teams/CampusIPLibraries/Campus/Community%20Shared%20IP/2017/11/SQL%20Server%202016%20Always%20On%20Availability%20Groups%20Guide_V01.01.docx?d=w7427a596bebf4d8bace052d7944c3841&csf=1&web=1&e=1PDX7t)


**Using Force Quorum and Force Failover to recover from a Catastrophic Failure** `SQL Server 2012 Availability Group` [**document**](https://microsoft.sharepoint.com/:w:/r/teams/CampusIPLibraries/Campus/_layouts/15/Doc.aspx?sourcedoc=%7B7E599E1B-DEDF-4C25-88DE-0860DCA92080%7D&file=Force%20Quorum%20for%20a%20SQL%20Server%202012%20Availability%20Group_new.docx&action=default&mobileredirect=true&DefaultItemOpen=1)

> [!Note]
> SQL Server Failover Cluster Instances **`FCIs` do not support automatic failover by availability groups**, so any availability replica that is hosted by an FCI can only be configured for manual failover.

```sql
SELECT database_name, is_failover_ready, case is_failover_ready 
when 0 then ':CONNECT '+replica_server_name+' ALTER AVAILABILITY GROUP ['+ag.name+'] FORCE_FAILOVER_ALLOW_DATA_LOSS' 
when 1 then ':CONNECT '+replica_server_name+' ALTER AVAILABILITY GROUP ['+ag.name+'] FAILOVER'
end 
FROM sys.dm_hadr_database_replica_cluster_states dbr inner join sys.dm_hadr_availability_replica_states r
on dbr.replica_id = r.replica_id
inner join sys.dm_hadr_availability_replica_cluster_states arc
on arc.replica_id = r.replica_id
inner join sys.availability_groups ag
on r.group_id = ag.group_id
where r.is_local = 1
```
