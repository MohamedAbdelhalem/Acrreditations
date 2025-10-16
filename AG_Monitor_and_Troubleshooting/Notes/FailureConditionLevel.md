Here’s what I found regarding **simulating FailoverConditionLevel in SQL Server Always On**:

***

### ✅ **Official Guidance**

*   The `FailureConditionLevel` property is **documented** and can be configured using:
    *   **PowerShell**:
        ```powershell
        Import-Module FailoverClusters
        $fci = "SQL Server (INST1)"
        Get-ClusterResource $fci | Set-ClusterParameter FailureConditionLevel 3
        ```
        This sets the level to **3 (Critical Server Errors)**. Levels range from **1 (least aggressive)** to **5 (most aggressive)**. [\[learn.microsoft.com\]](https://learn.microsoft.com/en-us/sql/sql-server/failover-clusters/windows/configure-failureconditionlevel-property-settings?view=sql-server-ver17)
    *   **Failover Cluster Manager** (GUI).
    *   **Transact-SQL** for Availability Groups:
        ```sql
        ALTER AVAILABILITY GROUP [YourAGName]
        SET (FAILURE_CONDITION_LEVEL = 3);
        ```
        This applies immediately without restarting WSFC or SQL Server. [\[learn.microsoft.com\]](https://learn.microsoft.com/en-us/sql/database-engine/availability-groups/windows/configure-flexible-automatic-failover-policy?view=sql-server-ver17)

***

### ✅ **Simulating Failures**

There is **no official “simulate FailureConditionLevel” command**, but you can **trigger conditions that correspond to each level**:

*   **Level 1 (Server Down)**  
    Stop SQL Server service:
    ```powershell
    Stop-Service MSSQLSERVER
    ```

*   **Level 2 (Unresponsive)**  
    Simulate CPU starvation or block SQL threads (e.g., using `DBCC FREEPROCCACHE` repeatedly or stress tools).

*   **Level 3–5 (Critical/Moderate Errors)**  
    Use `DBCC STACKDUMP` or inject errors via:
    ```sql
    DBCC WRITEPAGE -- (dangerous, only in lab)
    ```
    Or force health check failure:
    ```sql
    ALTER DATABASE [YourDB] SET OFFLINE;
    ```
    This will make `sp_server_diagnostics` report unhealthy state, triggering failover if policy allows. [\[learn.microsoft.com\]](https://learn.microsoft.com/en-us/sql/sql-server/failover-clusters/windows/failover-policy-for-failover-cluster-instances?view=sql-server-ver17)

***

### ✅ **Unofficial / Lab Scripts**

*   Community scripts exist for **automated failover testing** using PowerShell and `dbatools`:
    ```powershell
    .\SQLAGFailovers.ps1 -Environment LAB -Destination Secondary
    ```
    These scripts cycle AG roles to simulate failover scenarios for patching or DR drills. [\[landonfowler.com\]](https://landonfowler.com/2024/05/automate-failover-of-sql-server-always-on-availability-groups-with-powershell/)

***

### ⚠️ **Important Notes**

*   These methods are **for test environments only**—never use undocumented commands like `DBCC WRITEPAGE` in production.
*   Always ensure replicas are **synchronized** before forcing failover to avoid data loss.

***

Would you like me to **prepare a quick reference table mapping FailureConditionLevel values to practical simulation steps (safe for lab)**, or **create a PowerShell script that automates failover tests for different levels**?
