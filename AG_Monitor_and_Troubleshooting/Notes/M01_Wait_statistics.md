## Wait statistics

### HADR_SYNC_COMMIT  

This wait type is part of SQL Server's **Always On Availability Groups** infrastructure. It measures the time a transaction on the **primary replica** waits until **all synchronous secondary replicas** have acknowledged that the transaction's **commit log sequence number (LSN)** has been hardened (written to disk).

- It reflects the **latency** between the primary and secondary replicas.
- It is expected in **synchronous commit mode** and is a sign of **data safety**, ensuring that secondaries are up-to-date for seamless failover.
  
### 📈 What Does a High `HADR_SYNC_COMMIT` Value Indicate?

A high value means the primary replica is **waiting longer than usual** for secondaries to confirm log hardening. This can be caused by:

- **Slow log hardening** on one or more secondary replicas.
- **Network latency** between primary and secondary nodes.
- **Disk I/O bottlenecks** on secondary replicas.
- **Small transactions** causing inefficient log block usage (group commit issues).
- **Auto-commit mode** inefficiencies—each transaction requires a round trip and log hardening on all replicas.
- 
### 🧭 Where Does It Appear? Primary or Secondary Node?

- **Primarily on the Primary Node**: This wait type is recorded on the **primary replica**, because it is the one waiting for acknowledgments from secondaries before completing the commit.
- **Not on Secondary Nodes**: Secondary replicas do not wait for commit acknowledgments—they only receive and harden logs.

### 🛠️ How to Monitor and Troubleshoot

Use the following tools and counters:

- **DMV**: `sys.dm_os_wait_stats` to track `HADR_SYNC_COMMIT` wait time and count.
- **Performance Counters**:
  - `Log Bytes Flushed/sec`
  - `Write Transactions/sec`
  - `Transaction Delay`
  - `Bytes Sent to Replica/sec`
  - `Flow Control/sec`
- **Extended Events**: `hadr_log_block_group_commit` for group commit behavior.
  
---

### HADR_CLUSAPI_CALL 

The `HADR_CLUSAPI_CALL` wait type is part of the **AlwaysOn Availability Groups** infrastructure in SQL Server. It occurs when a SQL Server thread needs to **switch from non-preemptive to preemptive mode** in order to **invoke Windows Server Failover Clustering (WSFC) APIs**.

This wait type is triggered during operations that require SQL Server to interact with the underlying cluster infrastructure, such as:
- Opening cluster resources
- Enumerating cluster nodes or networks
- Reading cluster network properties
- Validating cluster health and configuration.

These operations are handled by external Windows APIs, which SQL Server must call in preemptive mode, meaning the OS—not SQL Server—controls the scheduling of the thread during that time.

### 📈 What Does a High Number of `HADR_CLUSAPI_CALL` Waits Indicate?

While this wait type is **typically benign**, a **high accumulation** may signal:
- **Cluster communication delays** (e.g., DNS resolution issues, slow network adapters, or misconfigured IPs/subnets)
- **Resource contention** in the cluster (e.g., disk latency or overloaded cluster nodes)
- **Frequent querying of cluster metadata** (e.g., from system views like `sys.availability_databases_cluster` or `sys.availability_replicas`).

If you observe high values, it's recommended to:
- Run **Cluster Validation** (outside SQL Server uptime)
- Check **network health**, including cables, adapters, and DNS
- Review **cluster logs** and **event viewer** for anomalies

### 🧭 Where Does It Typically Appear — Primary or Secondary Node?

This wait type is **most commonly observed on the primary node**, because:
- The primary node is responsible for **coordinating cluster-level operations**, such as failover decisions, replica health checks, and listener updates.
- These operations often involve **calls to WSFC APIs**, which trigger the `HADR_CLUSAPI_CALL` wait.

However, it can also appear on secondary nodes if they are involved in cluster metadata queries or health checks, but this is less frequent.

### 🛠️ Monitoring and Troubleshooting Tips

To monitor this wait type:
- Use the DMV: `sys.dm_os_wait_stats`
- Filter for `HADR_CLUSAPI_CALL` and track its **wait_time_ms** and **waiting_tasks_count**
- Correlate with other AlwaysOn wait types like `HADR_SYNC_COMMIT`, `HADR_LOGCAPTURE_WAIT`, and `WRITELOG` for a full picture.

---

### HADR_LOGCAPTURE_WAIT (on the primary replica)

The wait type **`HADR_LOGCAPTURE_WAIT`** in SQL Server is specific to **Always On Availability Groups** and relates to the log capture process on the **primary replica**. Here’s what it means and what it could indicate:

### ✅ **What It Is?**
- This wait occurs when the **log capture mechanism** (responsible for reading transaction log records and sending them to secondary replicas) is **waiting for new log records to become available**.
- It can also happen when the log capture thread is **reading from disk** because the required log records are not in the log cache.

### ✅ **Is It Normal?**
- **Yes, it’s an expected wait** when:
  - The log capture thread has caught up to the end of the log.
  - There is no new transaction activity.
- In these cases, the wait is benign and can usually be ignored.
  
### ✅ **When to Investigate**
If you see **high or sustained values** for `HADR_LOGCAPTURE_WAIT`, it might indicate:
1. **Transaction Log Issues**  
   - Slow log generation or delays in flushing log records to disk.
2. **I/O Bottlenecks**  
   - Disk latency on the primary replica can delay log capture.
3. **High Transaction Rate**  
   - Heavy workload generating logs faster than they can be processed.
4. **Secondary Replica Sync Problems**  
   - If secondaries frequently lose synchronization, this wait may correlate with other HADR waits like `HADR_SYNC_COMMIT`.
   
### ✅ **Troubleshooting Steps**
- Check **PerfMon counters** for Availability Groups (e.g., `Log Send Queue Size`, `Log Bytes Flushed/sec`).
- Review **SQL Server error logs** for I/O or Always On warnings.
- Use **DMVs** like `sys.dm_os_wait_stats` and `sys.dm_hadr_database_replica_states` to correlate with other waits.
- Investigate **disk performance** and **network latency** between replicas.
  
---

### HADR_SYNCHRONIZING_THROTTLE 

Waiting for transaction commit processing to allow a synchronizing secondary database to catch up to the primary end of log in order to transition to the synchronized state. This is an expected wait when a secondary database is catching up. 

### WRITELOG 

Occurs while waiting for a log flush to complete. Common operations that cause log flushes are checkpoints and transaction commits.


---


### **Key Wait Types <mark>on Secondary Nodes</mark> and Their Meaning**

#### 1. **HADR_DATABASE_FLOW_CONTROL**
- **What it means**: This wait occurs when the secondary replica is throttling the flow of log blocks from the primary due to resource pressure (e.g., CPU, memory, or disk I/O).
- **Why it matters**: Indicates that the secondary is unable to keep up with the incoming log stream, which can lead to synchronization lag.
- **Typical causes**: Disk latency, insufficient CPU, or memory bottlenecks on the secondary.

#### 2. **HADR_WORK_QUEUE**
- **What it means**: The secondary is waiting for a worker thread to process incoming log blocks.
- **Why it matters**: High values suggest thread starvation or scheduling delays.
- **Typical causes**: Under-provisioned secondary node or excessive workload.

#### 3. **HADR_TRANSPORT_FLOW_CONTROL**
- **What it means**: SQL Server is throttling the transport layer due to congestion or slow acknowledgment from the secondary.
- **Why it matters**: Can lead to delays in log block delivery from primary to secondary.
- **Typical causes**: Network latency, packet loss, or slow disk writes on the secondary.

#### 4. **HADR_LOGCAPTURE_WAIT**
- **What it means**: Although more common on the primary, this can appear on secondaries during seeding or catch-up operations.
- **Why it matters**: Indicates delays in capturing log blocks for replication.
- **Typical causes**: Disk I/O bottlenecks or contention on the transaction log.

#### 5. **RESOURCE_SEMAPHORE_QUERY_COMPILE**
- **What it means**: Waits due to memory pressure during query compilation.
- **Why it matters**: Can affect read-only workloads on secondary replicas.
- **Typical causes**: Large or complex queries running on secondary, especially in read-intent scenarios.

#### 6. **PAGEIOLATCH_SH / PAGEIOLATCH_EX**
- **What it means**: Waits for pages to be read from disk into memory.
- **Why it matters**: Indicates slow disk I/O on secondary during read operations.
- **Typical causes**: Poor disk performance or high read workload.

#### 7. **SOS_SCHEDULER_YIELD**
- **What it means**: A thread voluntarily yields the scheduler to allow other threads to run.
- **Why it matters**: High values suggest CPU pressure or inefficient query plans.
- **Typical causes**: Overloaded secondary node or skewed parallelism.

### 🧪 **Real-World Observations from Internal Diagnostics**
From recent internal AzureMonitor diagnostics:
- Secondary nodes often show **low CPU usage** but **high wait times** on I/O-related waits like `PAGEIOLATCH_SH`, `WRITELOG`, and `SOS_SCHEDULER_YIELD`.
- **SeedingGroup workloads** on secondaries may show **zero user cores**, indicating idle or blocked replication.
- **RedoGroup workloads** are common on secondaries and can be bottlenecked by disk or memory pressure.

---

### 🔍 **What Is Sent and When?**

In synchronous commit mode, SQL Server sends **log blocks** from the primary to the secondary replica. These blocks contain transaction log records that must be **hardened (written to disk)** on the secondary before the primary can consider the transaction committed.

- **Default Log Block Size**: SQL Server does not use a fixed size for each log block. Instead, it uses **group commit** logic to batch multiple transactions into a single log block.
- **Group Commit Delay**: By default, SQL Server waits **10 milliseconds** to accumulate multiple commits into a single log block before sending it to the secondary.
- **Customization**: This delay can be adjusted using the **Availability Group Commit Time** configuration option. Setting it lower can reduce latency but may increase overhead.

---

### 🧠 Best Practices and Mitigation Index Rebuild to avoid overwhelming challenges:

- **Avoid Unnecessary Rebuilds**  
  Many environments don’t need frequent index rebuilds. Often, **updating statistics** with a full scan provides the same benefit without the overhead.
  
- **Use Fragmentation Thresholds**  
  Rebuild only when fragmentation exceeds a meaningful threshold (e.g., >30%). Below that, consider reorganizing instead.
  
- **Pre-Grow Transaction Logs**  
  Ensure your transaction log is large enough to handle the rebuild. Consider pre-growing it to avoid interruptions.
  
- **Schedule During Maintenance Windows**  
  Index rebuilds should be scheduled during off-peak hours to minimize impact on production workloads.
  
- **Monitor TempDB Usage**  
  If using `SORT_IN_TEMPDB`, ensure TempDB has sufficient space. Rebuilds can consume significant TempDB resources.

---

### Can I adjust the Group Commit Wait Time in SQL Server Always On Availability Groups?

`Yes`, but only indirectly.

### 🔧 Default Behavior
By default, SQL Server waits **up to 10 milliseconds** to group multiple transaction commits into a single log block before sending it to synchronous secondary replicas. This batching helps optimize performance and reduce overhead.

### ⚙️ How to Adjust It
You can modify this behavior using the **Availability Group commit time setting**:

- **Trace Flag 3463**: Enables advanced diagnostics for group commit behavior.
- **Availability Group Commit Time (AGCT)**: This internal setting can be adjusted via undocumented methods or trace flags, but **Microsoft does not officially support changing it directly** in most environments.

---
