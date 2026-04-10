Excellent ✅ — now you are entering **SQLOS scheduling internals**, and this is exactly where many mysterious CPU / hangs / dumps in SQL Server come from.

You mentioned:

> Scheduler Monitor thread: Monitors scheduler health and detects issues such as **non‑yielding scenarios**

So…

***

# 🎯 First — How SQL Server Scheduling REALLY works

Unlike Windows…

SQL Server does **NOT** use fully preemptive scheduling inside the engine.

Instead:

    SQL Server uses Cooperative Scheduling (SQLOS)

Meaning:

*   Windows schedules the SQL Server process
*   BUT SQL Server schedules its **own workers internally**

Microsoft explains:

> SQL Server uses its own co‑operative thread scheduling mechanism called SQLOS [\[techcommun...rosoft.com\]](https://techcommunity.microsoft.com/blog/sqlserversupport/troubleshooting-sql-server-scheduling-and-yielding/319148)

***

# 🧠 What is "Yielding"?

Inside SQLOS:

Each worker thread runs on a scheduler (mapped to CPU).

BUT:

SQL Server says:

> Every worker must periodically **voluntarily give up the CPU**

This is called:

    Yielding

So the worker says:

> “I did enough work, let someone else run now”

This happens by calling internally:

    YieldAndCheckForAbort()

***

# 🎯 Why is this required?

Because SQLOS is:

    Non‑preemptive scheduling

Meaning:

❌ The scheduler cannot forcefully stop a worker  
✅ The worker must cooperate

So:

Workers must behave like:

    Good citizens

And share CPU voluntarily.

If not:

➡️ Other workers **cannot run**

As Microsoft states:

> If a SQL Server worker thread does not voluntarily yield, it will likely prevent other threads from running on the same scheduler [\[techcommun...rosoft.com\]](https://techcommunity.microsoft.com/blog/sqlserversupport/troubleshooting-sql-server-scheduling-and-yielding/319148)

***

# 🚨 Now — What is a NON‑YIELDING scenario?

A **Non‑Yielding Worker** means:

    Worker is running continuously
    AND
    Not giving up CPU voluntarily

Even after its allowed CPU time (called the **quantum**) expires.

That quantum is:

    ~4 milliseconds

Paul Randal explains:

> This is where a thread is using the processor and doesn’t voluntarily yield after using more than the thread quantum (4 milliseconds) [\[sqlskills.com\]](https://www.sqlskills.com/blogs/paul/the-curious-case-of-the-un-killable-thread/)

***

# 🎯 What happens internally then?

Imagine this:

CPU 4 has:

    Scheduler 4

Workers waiting:

    Worker A
    Worker B
    Worker C

Now:

Worker A starts running…

But:

❌ It never calls Yield  
❌ It loops endlessly  
❌ It waits on something internally  
❌ It enters bad code path

So:

Worker A:

    Monopolizes CPU

Now:

*   Worker B cannot run
*   Worker C cannot run
*   Task queue grows
*   Scheduler stalls

➡️ SQL Server appears hung

***

# 🎯 This is where Scheduler Monitor Thread comes in

SQL Server runs an internal watchdog:

    Scheduler Monitor

It periodically checks:

    Is work progressing?
    Are workers yielding?
    Is scheduler making progress?

If:

A worker has not yielded for:

    ~60–70 seconds

SQL Server logs:

    Non‑Yielding Scheduler

As documented:

> When the owner of the scheduler has not yielded within 70 seconds SQL Server will log non‑yielding scheduler error [\[techcommun...rosoft.com\]](https://techcommunity.microsoft.com/blog/sqlserversupport/troubleshooting-sql-server-scheduling-and-yielding/319148)

And you will see:

    Error 17883
    Error 17884
    Error 17887
    Error 17888

And:

✅ A memory dump is generated

***

# 🎯 Why this is VERY dangerous

Because:

In SQLOS:

    Scheduler cannot preempt worker

Meaning:

Even if you run:

```sql
KILL 52
```

The worker may:

❌ Ignore it  
❌ Not terminate

Paul Randal explains:

> There’s no way to force a thread to terminate from within SQL Server. The thread has to check whether it’s been asked to terminate [\[sqlskills.com\]](https://www.sqlskills.com/blogs/paul/the-curious-case-of-the-un-killable-thread/)

And guess where termination check happens?

➡️ At the yield point!

So:

If worker never yields:

    It never checks for kill

➡️ Unkillable SPID  
➡️ Hung scheduler  
➡️ SQL freeze  
➡️ Instance restart required

***

# 🎯 Common causes of Non‑Yielding scenarios

From real production cases:

| Cause                   | Description             |
| ----------------------- | ----------------------- |
| Infinite loop in engine | Bug                     |
| Spinlock contention     | CPU starvation          |
| Slow I/O subsystem      | Worker stuck waiting    |
| Memory pressure         | Allocation stuck        |
| Bad parallel rollback   | Long undo               |
| Windows API call        | Preemptive call blocked |
| CLR code                | External code stuck     |
| Linked server call      | Network hang            |

***

# 🧠 Related to your earlier CPU question

Remember you asked:

> Queries < 1 sec but CPU high?

Sometimes:

A non‑yielding worker:

*   Burns CPU
*   Does not show long query
*   But blocks scheduler progress

➡️ Classic:

    High CPU
    Low query duration
    System appears stuck

***

# ✅ One‑sentence DBA takeaway

> **A non‑yielding scenario occurs when a SQL Server worker thread fails to voluntarily give up CPU in SQLOS cooperative scheduling, causing the scheduler to stall and potentially freezing the entire instance until the scheduler monitor detects it and generates a dump.**

***

If you want next, I can show:

✅ How to detect non‑yielding schedulers via DMVs  
✅ How SOS\_SCHEDULER\_YIELD relates  
✅ Dump analysis basics  
✅ XE session for scheduler health

Just tell me 👍
