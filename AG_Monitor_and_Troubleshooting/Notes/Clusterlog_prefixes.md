These prefixes are extremely important when reading a WSFC Cluster.log and understanding AG failovers. Microsoft doesn't officially publish a complete glossary of every component, but after years of cluster troubleshooting, these are the most commonly encountered meanings.

Think of Cluster.log as showing messages from various cluster subsystems:

Prefix	Meaning	Purpose[TM]	Topology Manager	Tracks cluster membership and node state changes
[DCM]	Distributed Configuration Manager	Replicates cluster database updates across nodes
[SiteM]	Site Manager	Multi-site / fault-domain awareness
[IM]	Interface Manager	Manages cluster network interfaces and connectivity
[GUM]	Global Update Manager	Ensures cluster-wide configuration consistency
[ClNet]	Cluster Network	Network communication layer and heartbeats
[TM] = Topology Manager

This is one of the most important components during failovers.

Responsibilities:

Tracks which nodes belong to the cluster.
Detects node joins and removals.
Participates in quorum decisions.
Detects when a node becomes unreachable.

Typical messages:

[TM] Node 2 removed from active membership
[TM] Processing membership change
[TM] New cluster view established


When investigating:

Unexpected AG failover
Node eviction
Lost quorum


I almost always start with TM entries.

[DCM] = Distributed Configuration Manager

The cluster database is stored on all nodes.

DCM is responsible for:

Cluster registry replication.
Synchronizing cluster configuration.
Propagating resource changes.

Example:

[DCM] Sending configuration update
[DCM] Received update sequence


Think:

DCM = Cluster configuration replication


Not AG data replication.

[SiteM] = Site Manager

Introduced for site-aware clustering.

Responsibilities:

Datacenter awareness.
Fault domains.
Preferred site decisions.
Cross-site failover decisions.

Typical entries:

[SiteM] Site information updated
[SiteM] Node assigned to site Riyadh


Very useful in:

Primary DC
Secondary DR site
Multi-subnet AGs

[IM] = Interface Manager

This component manages network interfaces used by the cluster.

Responsibilities:

Detect NIC status.
Monitor adapter changes.
Manage cluster network routes.
Track interface health.

Typical log entries:

[IM] Interface disconnected
[IM] Interface state changed


When troubleshooting:

NIC failures
Driver issues
Network cable pull tests


IM entries are gold.

[GUM] = Global Update Manager

One of the most important clustering components.

Think of it as:

"The cluster's distributed transaction coordinator for cluster configuration."

Whenever a cluster-wide change occurs:

Resource move
Node join
Node leave
IP change
AG role ownership change


GUM coordinates and ensures every node agrees.

Typical entries:

[GUM] Initiating update
[GUM] Update completed
[GUM] Update committed


If GUM cannot obtain agreement from enough nodes:

Quorum issues
Membership instability


often appear.

[ClNet] = Cluster Network

This is the cluster networking stack.

Responsibilities:

Heartbeat traffic.
Inter-node communication.
Routing cluster packets.
Detecting communication failures.

Example entries:

[ClNet] Sending heartbeat
[ClNet] Route unavailable
[ClNet] Connection lost


When diagnosing:

NIC failures
Firewall issues
Packet loss
Network partitions
Heartbeat failures


ClNet is usually your best friend.

For an AG failover due to NIC failure

If you're investigating:

NodeA was Primary
NodeA NIC failed
AG failed over to NodeB


The important sequence usually looks like:

[ClNet]
  Heartbeats stop

[IM]
  Interface becomes unavailable

[TM]
  Membership change detected

[GUM]
  New cluster state committed

[RCM]
  Resource ownership moved

[SQL AG Resource]
  Availability Group brought online


So for AG troubleshooting, the highest-value prefixes are:

[ClNet]
[IM]
[TM]
[GUM]
[RCM]

Bonus: RCM

You'll see this constantly:

[RCM]


It means:

Resource Control Manager

This is the component that actually moves the AG role between nodes.

Example:

[RCM] Moving resource
[RCM] Resource Online
[RCM] Resource Offline


For SQL Server Always On failovers, RCM + TM + ClNet are usually the three most revealing components in the log.

If you have a few actual Cluster.log lines from a failover event, paste 20-50 lines around the timestamp and I can walk through them line-by-line like a cluster engineer would.
