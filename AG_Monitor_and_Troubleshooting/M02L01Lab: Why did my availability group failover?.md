### in a case of Manaual failover

when we have a situation of a disaster like network connection has been broken on the primary node (AlwaysonN2), immediatly the always-On on the other nodes will turn off in a Resolving status, and all databases in the availability replica will turn into Not synchronizing state also, and also after a few seconds of trying to join the effected node to rejoin into the Cluster the node will turn into QUARANTINE state, so, here are some of the actions and how to mitigate them.

A1. you can failover the AG in any node in the cluster

```sql
CONNECT: AlwaysOnN1 
--or 
CONNECT: AlwaysOnN3
GO
Alter Availability Group [AOCorp] Failover
```
or
```powershell
Switch-SqlAvailabilityGroup -Path SQLSERVER:\Sql\AlwaysOnN1\MSSQLSERVER\AvailabilityGroups\AOCorp
```


After the failover the AG will come again and your application will connect to the cluster with no issues.

1. if the node was in a Quarantine state then:

After you fix the issue you have to clear the Quarantine node state first.

```powershell
Start-ClusterNode -Name "AlwaysOn2" -ClearQuarantine
```

then everything will work fine.
if the node didn't join normally, then start and stop the cluster service:

```powershell
NET STOP ClusSvc

NET START ClusSvc
```
2. if the node didn't exceed the time to be in the Quarantine state

```powershell
NET STOP ClusSvc

NET START ClusSvc
```
## what if you tried to restart SQL Server or the whole node was restarted after the issue 

### Databases will be in a RECOVERY Pending state

To fix that restart SQL Server

### If SQL Server didn't restart after the issue, then databases will be synchronized/synchronizing state again.


# BUT what will happened if you tried to FORCE start the cluster service on the effected node (AlwaysOnN2) while it still in QUARANTINE state

```powershell
NET START ClusSvc /FQ
```

the Availability group/s will be in a RESOLVING state again in all nodes and you can't failover because you started the cluster with no quorum, so, you have to forcing failover with data loss option.

```powershell
#Quarantine per hour
(get-cluster).QuarantineDuration/60.0/60.0

#Quarantine threshold how many times to attempt to rejoin the node
(get-cluster).QuarantineThreshold
```

if you tried to restart the SQL Server on node (AlwaysOnN2) after the issue or the whole node was restarted then you will find all databases in state (Not Synchronizing / Recovery Pending)

if you choose to failover to the effected node (AlwaysOnN2), these are the steps:

1- failover to node (AlwaysOnN2)

```sql
CONNECT: AlwaysOnN2
GO
Alter Availability Group [AOCorp] Force_Failover_Allow_Data_Loss
GO

---2. restart the SQL Server then:

CONNECT: AlwaysOn2
go
Alter Database AdventureWork Set Online
go
Alter Database AdventureWorkDW Set Online
go
```

2- restart the SQL Server on the other nodes

3- resume the Availability databases

```sql
CONNECT: AlwaysOn1
go
Alter Database AdventureWork Set HADR RESUME;
go
Alter Database AdventureWorkDW Set HADR RESUME
go

CONNECT: AlwaysOn3
go
Alter Database AdventureWork Set HADR RESUME;
go
Alter Database AdventureWorkDW Set HADR RESUME
go
```
