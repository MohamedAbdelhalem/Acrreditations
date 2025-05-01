### Availability Group Database in Recovery Pending / Not Synchronizing

In case of the AG was configured as automatic failover or not?

#### If not configure with Allow automatic failover (manual failover):

Dashboard for the 3 node and the primary is the node 2


Initiate the issue

Now, we have lost the primary node (AlwaysOn2) because the public network card went down

So, the cluster service (ClusSvc) goes down either

Turn on the public card

Try to start the cluster service normally
```powershell
Net Start ClusSvc

```

If it refuse to come up normally, then start it using force quorum

```powershell
Net Start ClusSvc /FQ

```

try to bring up the database and check the Always-On status


If you restarted the service of the SQL, databases in the current node will turn into recovery pendingn


to resolve it force failover allow data loss on the previous primary node (AlwaysOn2)

```SQL
CONNECT: AlwaysOn2
go
Alter Availability Group [AOCorp] Force_Failover_Allow_Data_Loss
go
```

then bring databases online to start recover the databases

```SQL
CONNECT: AlwaysOn2
go
Alter Database AdventureWork Set Online
go
Alter Database AdventureWorkDW Set Online
go
```

then bring databases resume the sync from the secondary nodes

#### Approach 1 HADR RESUME
```SQL
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
#### Approach 2 Restart SQL Server services on the secondary nodes


#### If Always-On configured with Allow automatic failover:

then after producing the issue one of the nodes will be the primary role, and node AlwaysOn2 will be on the `Quarantine` state

so, do the same fix steps as it shows above and then add the below step to start the node with `Clear Quarantine`

```powershell
Get-ClusterNode -Name "AlwaysOn2" | Format-List -Property Quarantine
Start-ClusterNode -Name "AlwaysOn2" -ClearQuarantine
```
then restart the sql server

