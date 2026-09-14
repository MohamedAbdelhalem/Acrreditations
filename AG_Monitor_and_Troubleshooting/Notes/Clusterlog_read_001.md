Yes. The cluster.log is one of the best places to determine:

How many restart attempts occurred.
Whether each restart succeeded or failed.
Whether WSFC eventually failed over the AG role to another node.
Why the restart/failover decision was made.
Step 1: Generate the cluster log

On any cluster node:

Get-ClusterLog -UseLocalTime -Destination C:\Temp


or

cluster log /g


This creates a log file similar to:

Cluster.log

Step 2: Search for AG resource events

Look for your AG name or resource name:

findstr /i "AGName" Cluster.log


or

findstr /i "Online Offline Restart" Cluster.log


Typical entries look like:

Resource AG1: IsAlive failed
Resource AG1: LooksAlive failed
Resource AG1: Resource failed


Then:

rhs.exe: Resource AG1 failed
Rcm::RestartResource


indicates WSFC initiated a restart attempt.

Step 3: Find the restart count

Search for:

Restart
Maximum restarts
Rcm
RestartResource


Examples:

Rcm::RestartResource: Restarting resource AG1

Resource AG1 failed 1 time(s) in the current period

Resource AG1 failed 2 time(s) in the current period

Resource AG1 exceeded maximum restart threshold


That tells you:

Attempt #1 failed
Attempt #2 failed
Restart threshold exceeded
Step 4: Determine whether the restart succeeded

A successful restart usually shows:

Offline --> OnlinePending
OnlinePending --> Online


For example:

Resource AG1 entering OnlinePending state
Resource AG1 Online successful


or

AG1 state changed to Online


Meaning:

Restart attempted
+
Resource came online
=
Success

Step 5: Determine whether the restart failed

You'll see a pattern like:

OnlinePending


followed by:

Resource AG1 failed


or

Online operation failed


or

Resource AG1 entered Failed state


Meaning:

Restart attempted
+
Online failed
=
Failed restart

Step 6: Check whether the cluster moved the role

Look for:

MoveGroup
MoveClusterGroup
Failover


Example:

Group AG1 is moving from node NODE1 to NODE2


or

Initiating failover of group AG1


or

Group AG1 ownership changed to NODE2


This means all restart attempts failed and WSFC decided to move the AG.

Faster Method (PowerShell)

You can query recent cluster events:

Get-WinEvent -LogName Microsoft-Windows-FailoverClustering/Operational |
Where-Object {$_.Message -match "AG1"} |
Select TimeCreated, Id, Message


Useful event IDs:

Event ID	Meaning1069	Resource failed
1205	Cluster service moved a resource/group
1254	Resource restart attempted
1641	AG role state change
1652	AG failover
My Preferred Investigation Flow

When troubleshooting an AG failover:

1. SQL ERRORLOG
       ↓
2. Failover Clustering Operational Log
       ↓
3. Cluster.log
       ↓
4. System Event Log


The Failover Clustering Operational log is often easier to read than the raw cluster.log and usually shows:

Resource failed
Restart attempt 1
Restart attempt 2
Restart threshold exceeded
Group moved to NODE2


much more clearly.

For Always On AGs, Event ID 1069 and 1205 are usually the first events I check to determine whether WSFC attempted a restart and whether it ultimately failed over the availability group.
