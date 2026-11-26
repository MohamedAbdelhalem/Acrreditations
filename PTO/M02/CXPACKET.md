Why does the workshop mention OLTP?

OLTP workloads typically execute many short transactions.

For example:
- INSERT
- UPDATE
- DELETE
- Small SELECT queries

These workloads often benefit from efficient serial execution.

If many small OLTP queries execute using parallel plans, the overhead of coordinating multiple workers may outweigh the performance benefits.

Microsoft specifically recognizes that excessive parallelism can negatively affect OLTP workloads.

C. What does the 20% mean?

The workshop most likely means:

If parallelism-related waits account for more than 20% of the total relevant wait time, investigate potential parallelism issues.

The formula would be:

## $Parallelism Wait\\% = \frac{Total Relevant Wait Time}{Parallelism Wait Time} x 100$

For example:

|Wait type|	Wait time (ms)|
|----------|---------------|
|CXPACKET	|20,000|
|PAGEIOLATCH_SH|	30,000|
|LCK_M_X|	10,000|
|WRITELOG|	40,000|
|Total|	100,000|

Here:

## $CXPACKET\\% = \frac{20000}{100000} x 100 \= 20\\% $ 

Interpretation: CXPACKET represents 20% of the selected wait time.

However, this does not mean:

- CPU utilization is 20%.
- 20% of queries are executing in parallel.
- Parallelism is consuming 20% of CPU resources.

It only means that CXPACKET accounts for 20% of the wait time included in the calculation.


### 2. How can you calculate this percentage in SQL Server?

You can use sys.dm_os_wait_stats.

The following query calculates the percentage of CXPACKET and CXCONSUMER waits relative to a selected set of non-idle waits.

```SQL
WITH WaitStats AS
(
SELECT
wait_type,
wait_time_ms
FROM sys.dm_os_wait_stats
WHERE wait_type NOT IN
(
'SLEEP_TASK',
'SLEEP_SYSTEMTASK',
'LAZYWRITER_SLEEP',
'SQLTRACE_BUFFER_FLUSH',
'WAITFOR',
'LOGMGR_QUEUE',
'CHECKPOINT_QUEUE',
'REQUEST_FOR_DEADLOCK_SEARCH',
'XE_TIMER_EVENT',
'XE_DISPATCHER_WAIT',
'BROKER_TASK_STOP',
'BROKER_TO_FLUSH',
'BROKER_EVENTHANDLER'
)
AND wait_type NOT LIKE 'PREEMPTIVE%'
),
TotalWaits AS
(
SELECT SUM(wait_time_ms) AS TotalWaitTime
FROM WaitStats
)
SELECT
w.wait_type,
w.wait_time_ms,
CAST(
100.0 * w.wait_time_ms /
NULLIF(t.TotalWaitTime, 0)
AS DECIMAL(10,2)
) AS WaitPercentage
FROM WaitStats w
CROSS JOIN TotalWaits t
WHERE w.wait_type IN
(
'CXPACKET',
'CXCONSUMER'
)
ORDER BY WaitPercentage DESC;
```

Example output:
|Wait type	Wait time (ms)|	Wait percentage|
|-----|-----|
|CXPACKET	250,000	|25.00%|
|CXCONSUMER	150,000	|15.00%|

Interpretation:

- CXPACKET represents 25% of the selected total wait time.
- CXCONSUMER represents 15%.
- CXPACKET exceeds the workshop's suggested 20% investigation threshold.

Important: This query uses an illustrative exclusion list, not a definitive list of all benign waits. The percentages depend on which waits you exclude.

Also, sys.dm_os_wait_stats contains cumulative statistics since SQL Server startup or the last manual reset. For meaningful performance analysis, compare two snapshots taken during the workload you want to investigate.

### 3. Does CXPACKET above 20% mean there is a problem?

No. Not necessarily.

Consider these scenarios:

|Scenario|	CXPACKET %|	Interpretation|
|----|-----|----|
|OLTP, CPU 90%, slow queries|	35%|	Investigate parallelism|
|OLTP, CPU 15%, fast queries|	35%|	Not necessarily problematic|
|OLAP, CPU 85%, large analytical queries|	40%|	Parallelism may be expected|
|OLTP, CPU 95%, CXPACKET 2%|	2%|	Investigate other CPU-related indicators|

The important point is that wait percentages alone cannot establish whether parallelism is excessive.

I would investigate:

1. MAXDOP: Is the configuration appropriate for the server?
2. Cost Threshold for Parallelism: Are relatively inexpensive queries receiving parallel execution plans?
3. Query execution plans: Which queries are executing in parallel?
4. CPU pressure: Are there sustained runnable queues or high CPU utilization?
5. Worker distribution: Are parallel branches experiencing skew or waiting on other resources?
