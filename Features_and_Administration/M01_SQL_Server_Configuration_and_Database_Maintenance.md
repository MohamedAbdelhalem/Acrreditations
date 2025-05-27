

<summary><b>Slide#07: Security and Permissions.</b></summary>

Permissions, <mark>such as</mark> : 

#### <ins>Mandatory permissions are necessary if the service account is not part of the administrator's local group.</ins>

*	<mark>**Log on as a service.**</mark>
	- Enables a service to log onto the operating system as a service, which is essential for services that must run continuously in the background.
*	<mark>**Replace a process-level token.**</mark>
	- Allows a process to start another process with a different security access token.
*	<mark>**Bypass traverse checking.**</mark>
	- Allows a user or a process acting on behalf of the user to navigate an object path in the NTFS file system or in the registry without being checked for the Traverse Folder special access permission.
*	<mark>**Adjust memory quotas for a process.**</mark> 
	- Allows a process to change the maximum amount of memory that can be consumed by a process. 
*	<mark>**Permission to start SQL Writer.**</mark>
*	<mark>**Permission to read the Event Log service.**</mark>
*	<mark>**Permission to read the Remote Procedure Call service.**</mark>

#### <ins>Optional permissions (later on the workshop)</ins>

*	<mark>**Lock pages in memory.**</mark>
*	<mark>**Perform volume maintenance tasks.**</mark>

<summary><b>SLIDE 8: Antivirus excluding paths and extensions. </b></summary>

#### <mark>Types of Files:</mark>

1. Data files
2. Log files
3. Backup files
4. Trace files (.trc and .xel)
5. SQL Server executables (.exe) 
6. SSAS data directories

<summary><b>SLIDE 9: OS power management. </b></summary>

- Adjust the settings to High Performance.

<summary><b>SLIDE 10: Windows Page File (SWAP file in Linux). </b></summary>

* <mark>SQL prospective</mark> 
	- It should not allow SQL to page out as much as it can, however, SQL doesn't have the control on that this is why we allow policy **LOCK PAGES IN MEMORY (LPIM)**.

* <mark>Windows perspective</mark>
	- Moving less frequently used data to disk.
	- Freeing up RAM for more active processes.
	- It's mandatory and should be sufficient. 
	- Enable the kernel memory dump on server crash.

<summary><b><mark>SLIDE 11: Windows Core.</b></summary>

- only installs necessary server components, benefits:
	- Reduce servicing
	- reduce management
	- reduce attach surface area
	- less disk space required for the OS binaries
	- reduce patching and maintenance

<summary><b><mark>SLIDE 16: SQL Server configuration tools.</b></summary>
	
	a. SSMS.
	b. sqlservermanager15.msc (SQL Server Configuration Manager).
	c. sp_configure.
	d. Alter Server Configuration (T-SQL).
	e. Registry.

<summary><b><mark>SLIDE 17: Processor configuration best practices </b></summary>

a. <mark>**Affinity Mask**
- Default and recommended is **AUTO**.
- In case of multi-instances and you want to assign a specific CPUs or NUMA nodes. 

b. <mark>**MAXDOP** 
- Set the best practices.

c. <mark>**Cost threshold for parallelism**
- Set the best practices based on your environment.
- Default value is `5` *too old*.

d. <mark>**MAX Worker Threads**
- Best practice to leave it with the default `0`.
- For systems with up to 4 logical CPUs = `512`
- For systems more than 4 logical CPUs = The formula is: `512 + ((logical CPUs - 4) x 16)`

e.g., **`12 logical CPUs`** = 512 + ((12 - 4) x 16) = `640` **`worker threads`**

<summary><b><mark>SLIDE 18: MAXDOP Settings </b></summary>

- From the slide

<summary><b><mark>SLIDE 19: memory min and max configuration </b></summary>

a. **Min default 0 MB.**
- In the case of multiple instances, ensure guaranteed memory allocation.
- It helps maintain performance stability by ensuring that each instance has enough memory to handle its workload without being starved by other instances.  
- That typically for multi-instance and OS or other application.

b. **Max set to 85% if the 15% is not too high for OS.**

c. **Standard edition limited to 64GB max.**

d.  **Lock Pages in Memory**
- Only works if the service account has the `grant on the same policy`.
- It prevents the OS for `not paging out memory` of the SQL into the paging.sys file.
- it's suitable for single-instance and multi-instance.
- Set an appropriate value for max server memory to ensure there is enough memory for the OS and other applications. This is crucial when using `LPIM` to avoid starving system for memory.
- The recommended value for **`min server memory`** in SQL Server depends on your server's total available memory and whether SQL Server is running on a **dedicated** or **shared** environment.

### ✅ General Recommendations

#### 🔹 For Dedicated SQL Server Instances:
- Set `min server memory` to **75–90%** of the total physical memory.
- Example: If your server has 64 GB RAM, you might set:
  ```sql
  min server memory = 48 GB (49152 MB)
  max server memory = 56 GB (57344 MB)
  ```
- This ensures SQL Server retains memory once it’s allocated and avoids releasing it unnecessarily.

#### 🔹 For Shared Servers (with other applications or services):
- Set `min server memory` to a **conservative baseline**, such as **25–50%** of total memory.
- Example: On a 64 GB server shared with other services:
  ```sql
  min server memory = 16 GB (16384 MB)
  max server memory = 40 GB (40960 MB)
  ```

### 🧠 Key Considerations
- `min server memory` does **not pre-allocate** memory at startup—it only guarantees that SQL Server won’t release memory once it reaches that threshold.
- Always leave **at least 4–6 GB** for the OS and other background processes.
- Monitor memory usage over time using tools like `sys.dm_os_memory_clerks`, `DBCC MEMORYSTATUS`, and Performance Monitor to fine-tune these settings.

<summary><b><mark>SLIDE 20- Dynamic Memory Management </b></summary>

- In situations where there is memory pressure, it is important to consider the minimum server memory setting:
	- It will release this min value to the OS or the other instance
	- Or if you configure the min = max then SQL Server will not give back any.
- To monitor the memory components and which one has the most usage use the below query to view of memory usage by different components **`clerks`** inside SQL Server:

```sql
SELECT 
    type, 
    name, 
    pages_kb, 
    virtual_memory_committed_kb, 
    awe_allocated_kb
FROM sys.dm_os_memory_clerks
ORDER BY pages_kb DESC;
```
- **`type`**: Identifies the memory clerk (e.g., `MEMORYCLERK_SQLBUFFERPOOL`, `CACHESTORE_SQLCP`).
- **`pages_kb`**: Shows how much memory (in KB) is allocated.
- Use this to identify which components are consuming the most memory.


<summary><b><mark>SLIDE 21- other important configuration settings </b></summary>

1. <b><mark>Backup Compression</mark></b>
- If it's enabled all backups will be compressed by default, whether you mentioned it or not. 
2. <b><mark>Priority Boost</mark></b>
- It changes the scheduling priority from **`8 = Normal`** to **`13 = High`**.
- For a specific structure from Microsoft support.
- Raises the priority to `sqlservr.exe` at the OS.
- Recommendation leave it at **`0`**.
3. <b><mark>Lightweight Pooling</b> **`Fiber Mode`**
- A single thread can serve multiple work requests.
- Decreases the `context switch` when it is a bottleneck.
4. <b><mark>Recovery Interval </mark></b>
- Set to **`60 seconds`** to avoid checkpoint `bottleneck`.
5. <b><mark>Optimizes for ad-hoc workloads</mark></b>
- Reduce `single plans`.
- Save space in the procedure cache.

<summary><b><mark>SLIDE 22- Changes for service account using sqlservermanager15.msc </mark></b></summary>

a. <b><mark>Changing the service account</b>
- Using `Services.msc` or `CMD` will change the user and the password, but it will not set the permissions as the previous account.
- However, if you used `sqlservermanagerXX.msc` it will set permissions in the Windows Registry without restarting the service.

b. <b><mark>Change startup parameter</b>
- Using `sqlservermanagerXX.msc` with `upper T`.
- It must restart the instance to take the effect.

c. <b><mark>Enable Availability Group and Filestream features</b>
- Using `sqlservermanagerXX.msc`
- It must restart the instance to take the effect.

d. <b><mark>Managing server & client Network Protocol</b>

- Using `sqlservermanagerXX.msc` to change:
	- **Disable/Enable or Add/Remove:** 	
		- certificate (to secure communications with SSL/TLS).
		- Force protocol encryption (ensures all client-server communications are encrypted. It’s a good practice for enhancing security)
		- SQL Port
		- Alias
		- Protocol
		- Connection parameters
		- Hide Instance 
	- **Use this PowerShell to browse:**
```powershell 
[System.Data.Sql.SqlDataSourceEnumerator]::Instance.GetDataSources()
```

<summary><b><mark>SLIDE 23- alter server configuration </b></summary>

a. DIAGNOSTICS LOG (2012)
```sql
select * from sys.dm_os_server_diagnostics_log_configurations
```
- ON 
- OFF
- Path
- Max_size
- Max_files

https://learn.microsoft.com/en-us/sql/sql-server/failover-clusters/windows/view-and-read-failover-cluster-instance-diagnostics-log?view=sql-server-ver16

b. FAILOVE CLUSTER PROPERTY (2012)
- FailureConditionLevel default 3
- HealthCheckTimeout default 60,000 (60 sec)

c. BUFFER POOL EXTENSION (2014)

d. PROCESS AFFINITY (2016)

e. MEMORY_OPTIMIZED (2019)
- TEMPDB_METADATA (using the default resource pool)

<summary><b><mark>SLIDE 24- Demo - alter server configuration </b></summary>
	a. PROCESS AFFINITY CPU
	b. DIAGNOSTICS LOG
	ON by default
	c. MEMORY_OPTIMIZED TEMPDB_METADATA
	https://learn.microsoft.com/en-us/sql/relational-databases/databases/tempdb-database?view=sql-server-ver16#memory-optimized-tempdb-metadata
	
<summary><b><mark>SLIDE 30- database files </b></summary>

<summary><b><mark>SLIDE 31- database configuration </b></summary>

a. collation
- how character data is sorted and compared
  
b. recovery model
- full
- simple
- bulk-logged
	- minimal logging for bulk operations to reduce log space usage.
	- it is not recommended for: 
	  - Always-on
	  - Logshipping
	  - Replication

c. compatibility level

d. containment type (2012)
- contained logins and users

<summary><b><mark>SLIDE 32- Database AUTO configuration </b></summary>

a. AUTO Close
- remove all objects in memory when all sessions are closed

b. Auto Shrink
- increase the fragmentation

c. Auto Create statistics
- always true

d. Auto Create incremental statistics
- very efficient with large table with a lot of partitions.
- instead of update statistics of all partitions.
- it will update stats for the changed partitions only.

  ```sql
  ALTER DATABASE [AdventureWorks2019] SET AUTO_CREATE_STATISTICS ON(INCREMENTAL = ON)
  ```
  
e. Auto update statistics

f. Auto update statistics AYNC
- SYNC - trigger then update stats then generate execution plan.
- ASYNC- trigger then generate execution plan then update stats.
- use case: if you have a limited query time out then use this option to avoid the timeout queries, by update states after query execution
 
formula:
rows in sys.dm_db_stats_properties()
before 2016 = (rows x 20) / 100 + 500
starts 2016 = SQRT(1000 * (rows + modification_counter)

https://github.com/MohamedAbdelhalem/dbatools/blob/main/Features_and_Administration/Update_Stats_Status.sql
 
<summary><b><mark>SLIDE 33- Database State </b></summary>

a. state
- online
- offline
- restoring
	- during the restore 
	- or restoration was done but with NoRecovery
- recovery pending
	- main problems will be on the transaction log file
	- post restore
	- startup while database is doing online recovery
- suspect
	- database was unable to complete the recovery process
- emergency
	- it made by the DBA to bypass recovery when database is suspect
	- database will be on read only state
	- single user mode
	- logging disabled

b. restricted access
- multi_user
- singel_user

c. encryption enabled
- enable database with TDE

d. read only

<summary><b><mark>SLIDE 34- Other Database Configuration Options </b></summary>

a. parameterization
- simple
	- sql server will add parameters where need it if your execution without parameters
- force
	- it will parameterize any literal value that appears in select, insert, update, or delete

b. page verify 
- checksum is the recommended option

c. delayed durability 
- lazy commit instead of write ahead

d. target recovery time
- recommended value is 60 sec

<summary><b><mark>SLIDE 35- DATABASE SCOPED CONFIGURATION (2016) </b></summary>

a. clear procedure_cache
b. maxdop
c. parameter_sniffing
d. verbose_truncation_warnings (2019)

CLEAR PROCEDURE_CACHE

MAXDOP

LEGACY_CARDINALITY_ESTIMATION -- in case of estimated rows in old version is more accurate 

PARAMETER_SNIFFING

QUERY_OPTIMIZER_HOTFIXES

IDENTITY_CACHE

VERBOSE_TRUNCATION_WARNINGS

LAST_QUERY_PLAN_STATS

**
The LAST_QUERY_PLAN_STATS option in SQL Server is a database-scoped configuration that allows you to enable or disable the collection of the last query plan statistics. This feature is available starting with SQL Server 2019 and can be very useful for performance tuning and troubleshooting.

When LAST_QUERY_PLAN_STATS is enabled, SQL Server retains the actual execution plan metrics for the last executed query plan. This means you can view the actual runtime metrics without having to re-run the query, which can be particularly helpful for understanding the performance characteristics of your queries. The metrics collected include:

Actual number of rows per operator

Total CPU time

Total execution time

Actual maximum degree of parallelism

Memory granted and subsequently used12.

To enable this option, you can use the following command:

ALTER DATABASE SCOPED CONFIGURATION SET LAST_QUERY_PLAN_STATS = ON;
This setting can be applied globally with trace flag 2451 or on each individual database. Note that enabling this feature may introduce a slight increase in overhead, but it is generally minimal.
**

<summary><b><mark>SLIDE 38- "Hands-free" tempdb </b></summary>

a. page allocation contention was gone by caching the temp tables and table variables.

b. adding allocation page latching protocol to reduce the number of update latches that are used.

c. logging for tempdb is now reduced to reduce disk I/O.

d. setup adds multiple tempdb data files during a new instance installation.

e. no more depending on Trace flag 1117 to allow autogrow at the same time by the same amount.

f. no more depending on Trace flag 1118 to make sure the allocations do not use mix extents and now using uniform extents by default for tempdb.

g. primary filegroup using AUTOGROW_ALL_FILES property and can't be modified.

h. on 2016 till 2017 SQL Server using multiple data files to round-robin between then to decrease the PSF page contention.

i. on 2019 SQL Server the round robin of the PSF within the files.

https://github.com/MohamedAbdelhalem/dbatools/blob/main/Execution%20Plan/GAM_SGAM_Contention.md
https://github.com/MohamedAbdelhalem/dbatools/blob/main/Execution%20Plan/PSF_Contention.md


<summary><b><mark>SLIDE 45- clustered and non-clustered indexes </b></summary>

<summary><b><mark>SLIDE 46- i want to demonstrate the differences between C and NC indexes</b>

- dbcc page
 
<summary><b><mark>SLIDE 47- Fragmentation </b></summary>

a. Logical Fragmentation (physical or external or extend)
b. Page Density (space or internal)

<summary><b><mark>SLIDE 48- rebuild vs reorganize </b></summary>

a. Rebuild `> 30%`
b. Reorganize `> 5% and <= 30%`
c. Online
d. Resumable online index `2017`

<summary><b><mark>SLIDE 51- Statistics Maintenance </b></summary>

- **Sampled** is the default behavior.
- If you manually update statistics using the  `UPDATE STATISTICS`  command, you can specify:
    -   `FULLSCAN`  — to scan all rows (most accurate, but slower).
    -   `SAMPLE n PERCENT`  or  `SAMPLE n ROWS`  — to scan a portion of the data.
    -   If you don’t specify anything, SQL Server chooses a sample size automatically based on the table size and other heuristics.
- So, unless you explicitly use `FULLSCAN`, SQL Server does **not** default to a full scan.
- Auto update statistics: 
  - `Before 2016` = ((Rows x 20) / 100) + 500
  - `Starts 2016` = **SQRT**(1000 * (Rows + modification_counter)


<summary><b><mark>SLIDE 53- Integrity Checks </b></summary>

a. <mark>DBCC CHECKALLOC
 - It checks the allocation of all pages in the database.
 - It validates the internal structures that track these pages (`IAM`, `GAM`, `SGAM`, `PFS`, and `BOOT`).
 - It uses an internal database snapshot to provide transactional consistency during the checks. If a snapshot can't be created, it tries to acquire an exclusive lock on the database

b. <mark>DBCC CHECKCATALOG
- It performs various consistency checks between system metadata tables.
- It uses an internal database snapshot to provide the transactional consistency needed to perform these checks. If a snapshot can't be created, DBCC CHECKCATALOG acquires an exclusive database lock to obtain the required consistency.
- If any inconsistencies are detected, they cannot be repaired, and the database must be restored from a backup.
- Running DBCC CHECKCATALOG against tempdb does not perform any checks because database snapshots are not available on tempdb for performance reasons

c. <mark>DBCC CHECKTABLE
 - **Index and Data Page Linkage:** Ensures that index, in-row, LOB (Large Object), and row-overflow data pages are correctly linked.
 - **Index Order:** Verifies that indexes are in their correct sort order.
 - **Pointer Consistency:** Checks that pointers are consistent.
 - **Data Reasonableness:** Ensures that the data on each page is reasonable, including computed columns.
 - **Page Offsets:** Verifies that page offsets are reasonable.
 - **Row Matching:** Ensures that every row in the base table has a matching row in each non-clustered index, and vice versa.
 - **Partition Consistency:** Checks that every row in a partitioned table or index is in the correct partition.

d. <mark>DBCC CHECKDB do all above steps

- <mark><b>Repair Options</b>
  - <mark>REPAIR_FAST:
    - This option does not perform any actual repair actions. 
    - It is maintained for backward compatibility and does not fix any errors.

  - <mark>REPAIR_REBUILD:
    - This option performs repairs that do not result in data loss.
    - It primarily focuses on rebuilding indexes and performing other maintenance tasks that ensure the database's physical consistency without losing any data.

  - <mark>REPAIR_ALLOW_DATA_LOSS:
    - This option attempts to repair all reported errors, but it may result in data loss. 
    - It is the most aggressive repair option and should be used as a last resort when restoring from a backup is not possible. 
    - This option can delete corrupted data to bring the database to a physically consistent state.
    - This functionality is designed to handle corrupted pages by removing them entirely, which the result in data loss. Consequently, all records on the affected pages will be eliminated.
    - <b><mark>Example:</mark></b> If corruption occurs within a page containing 100 records, and only one record is corrupted, the repair option will delete the entire page of 100 records to fix the issue.
