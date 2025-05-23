The Transaction Log disk was `offline`. bring it online again and then alter the affected database.

Go to the effected node, in our case `AlwaysOnN2`:

Open `cmd` as administrator

```cmd
DISKPART
LIST DISK
SELECT DISK 4
ONLLINE
EXIT
```

Open `sqlcmd` or `SSMS` and then alter database online on the `Primary` node, in our case `AlwaysOnN2`:

```sql
:CONNECT AlwaysOnN2
GO
ALTER DATABASE [AdventureWorks] SET ONLINE;
GO
```

If database in the other nodes still `Not Synchronizing`, then: 
1. Try to `resume` database if it is `paused`.
2. If it was `not paused` then `restart` the SQL Server on the secondary node/s.

