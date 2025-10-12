Here’s a detailed breakdown of **RHS.exe in SQL Server Always On**, its role, and common issues:

***

### ✅ **What is RHS.exe and What Does It Do?**

*   **RHS.exe** stands for **Resource Hosting Subsystem**, a Windows Failover Cluster process.
*   It hosts cluster resources (like SQL Server Always On Availability Group resources) and manages their health.
*   In an Always On setup, RHS.exe:
    *   Loads resource DLLs (e.g., `hadrres.dll`) that interact with SQL Server.
    *   Performs health checks and manages failover decisions.
    *   Creates diagnostic logs (via `xe.dll`) for troubleshooting cluster and AG issues. [\[techcommun...rosoft.com\]](https://techcommunity.microsoft.com/blog/sqlserversupport/sql-server-alwayson-primary-replica-failed-to-create-diagnostics-log-/1229920)
*   Communication between SQL Server and RHS.exe uses **Windows Event objects** to maintain a lease mechanism. If this lease expires, failover is triggered. [\[learn.microsoft.com\]](https://learn.microsoft.com/en-us/sql/relational-databases/errors-events/mssqlserver-19407-database-engine-error?view=sql-server-ver17)

***

### 🔍 **Use Cases**

*   **High Availability & Disaster Recovery (HADR):**
    *   RHS.exe ensures cluster consistency and initiates failover when SQL Server becomes unresponsive.
*   **Diagnostics:**
    *   Generates Always On diagnostic logs for troubleshooting (`sp_server_diagnostics` output saved in `.xel` files).
*   **Resource Management:**
    *   Monitors SQL Server health and restarts resources if needed. [\[techcommun...rosoft.com\]](https://techcommunity.microsoft.com/blog/sqlserversupport/sql-server-alwayson-primary-replica-failed-to-create-diagnostics-log-/1229920), [\[joshthecoder.com\]](https://joshthecoder.com/2018/12/03/always-run-rhs-in-separate-process.html)

***

### ⚠️ **Known Issues and Common Problems**

1.  **Lease Timeout (Error 19407):**
    *   Occurs when SQL Server and RHS.exe fail to communicate within the lease period.
    *   Causes: High CPU usage, memory pressure, VM throttling, WSFC quorum loss.
    *   Impact: AG failover or resource restart. [\[learn.microsoft.com\]](https://learn.microsoft.com/en-us/sql/relational-databases/errors-events/mssqlserver-19407-database-engine-error?view=sql-server-ver17)

2.  **Lost Heartbeat & Failover Failures:**
    *   RHS.exe may lose heartbeat with AG, triggering failover attempts.
    *   Often linked to:
        *   Network instability.
        *   Disk I/O latency.
        *   Storage stress (e.g., long sync I/O > 15s).
    *   Symptoms: AG goes into **RESOLVING** state, then returns to PRIMARY after a blip. [\[dba.stacke...change.com\]](https://dba.stackexchange.com/questions/280307/sql-server-alwayson-lost-of-heartbeat-and-connection-with-secondary-replica), [\[joshthecoder.com\]](https://joshthecoder.com/2018/12/03/always-run-rhs-in-separate-process.html)

3.  **RHS Crash:**
    *   If RHS.exe crashes or restarts (e.g., due to File Share Witness issues), all resources hosted in that process restart.
    *   Can cause unexpected downtime. [\[sqlservercentral.com\]](https://www.sqlservercentral.com/forums/topic/rhs-crash)

4.  **DLL Version Conflicts:**
    *   Multiple SQL Server versions on the same node can cause RHS.exe to load incorrect `hadrres.dll` or `xe.dll`.
    *   Leads to diagnostic log failures or resource misbehavior. [\[techcommun...rosoft.com\]](https://techcommunity.microsoft.com/blog/sqlserversupport/sql-server-alwayson-primary-replica-failed-to-create-diagnostics-log-/1229920)

***

### 🛠 **Best Practices to Avoid Issues**

*   Keep **SQL Server Cumulative Updates (CUs)** current to prevent known bugs. [\[learn.microsoft.com\]](https://learn.microsoft.com/en-us/troubleshoot/sql/database-engine/availability-groups/troubleshooting-alwayson-issues)
*   Monitor **CPU, memory, and disk latency** to avoid resource starvation.
*   Configure **quorum and failover policies** properly for WSFC.
*   Separate critical resources into different RHS processes to reduce blast radius during crashes. [\[joshthecoder.com\]](https://joshthecoder.com/2018/12/03/always-run-rhs-in-separate-process.html)
*   Validate DLL versions when multiple SQL Server instances exist on the same node.

