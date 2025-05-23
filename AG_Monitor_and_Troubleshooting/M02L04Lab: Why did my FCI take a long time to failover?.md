### Because of there are more than 20,000 VLF in the database ProdDB.

lets break down what is going on.

you can see what is the number of `VLF`s from the below queries:

if your version is older than **SQL Server 2016 Service Pack 2 (SP2)** use this query:

```sql
use ProdDB
go
create table #loginfo (RecoveryUnitId int, FileId int, FileSize bigint,
StartOffset bigint, FSeqNo int, Status int, Parity int, CreateLSN varchar(100))

insert into #loginfo
exec ('DBCC loginfo (ProdDB)')

select db_id() database_id,
fileid file_id, StartOffset vlf_begin_offset,
cast(filesize/1024.0/1024.0 as decimal(10,2)) vlf_size_mb,
FSeqNo vlf_sequence_number,
case when status > 0 then 1 else 0 end vlf_active,
status vlf_status, parity vlf_parity
from #loginfo
```
if your SQL Server version is equal of higher then just use this DMF `sys.dm_db_log_info`

So, for `VLF analysis`, run the below query:

```sql
declare @db_log_info table (database_id int, file_id int, space_used bigint)
insert into @db_log_info
exec sp_MSforeachDB 'use [?]
select db_id(''?'') database_id, file_id, fileproperty(name, 'spaceused')
from sys.database_files
where type = 1'

select db_name(mf.database_id) database_name, mf.name, mf.physical_name,
cast((size * 8.0) / 1024.0 / 1024.0 as decimal(10,2)) size_gb,
cast((growth * 8.0) / 1024.0 / 1024.0 as decimal(10,2)) growth_gb,
cast((lu.space_used * 8.0) / 1024.0 / 1024.0 as decimal(10,2)) space_used_gb,
cast(((size - lu.space_used) * 8.0) / 1024.0 / 1024.0 as decimal(10,2)) free_size_gb,
format(vlf_count,'###,###,###') vlf_count,
min_vlf_size_mb, avg_vlf_size_mb, max_vlf_size_mb
from sys.master_files mf cross apply (select count(*) vlf_count, database_id, file_id,
cast(min(i.vlf_size_mb) as decimal(10,2)) min_vlf_size_mb,
cast(avg(i.vlf_size_mb) as decimal(10,2)) avg_vlf_size_mb,
cast(max(i.vlf_size_mb) as decimal(10,2)) max_vlf_size_mb
from sys.dm_db_log_info(mf.database_id) i
group byy database_id, file_id) info
inner join @db_log_info lu
on mf.database_id = lu.database_id
where mf.database_id > 4
and mf.database_id = info.database_id
and mf.type = 1
```




create this function to convert `LSN`

```sql
Create or Alter Function dbo.fn_convert_lsn (
@lsn varbinary(25) = 0x00000C000001DDF0000A
)
returns nvarchar(25)
as
begin
declare
@lsn_char nvarchar(25)

select @lsn_char = 
cast(convert(int,substring(@lsn,1,4)) as varchar(10))+':'+
cast(convert(int,substring(@lsn,5,4)) as varchar(10))+':'+
cast(convert(smallint,substring(@lsn,9,2)) as varchar(10))

return @lsn_char
end
```

Then execute this script to get the avrage records that fell the vlf

by the way run this script to get the current file growth of the transaction log file

```sql
USE ProdDB
go
select name, physical_name, type_desc,
(size * 8.0) / 1024.0 / 1024.0 size_gb,
(growth * 8.0) / 1024.0 growth_mb
from sys.database_files
go
```
In our case the file growth is `1MB` then VLF rule, 

For `SQL Server 2014 and later versions`, the following rules apply:

If the growth increment is less than 64MB, 

SQL Server creates 4 VLFs, 

each roughly 1/4 the size of the growth increment.

Therefore, if the file growth is set to 1MB, 

SQL Server will create 4 VLFs,

each approximately 256KB in size.

So, run this script to know how many records inside the Transaction log file in each 1MB:

```sql
use proddb
go
declare @records table (records int)
declare
@f_lsn varbinary(25),
@l_lsn varbinary(25)
declare vlf_cursor cursor fast_forward
for
select
convert(varbinary(25),replace(vlf_first_lsn,':',''),2),
LEAD(convert(varbinary(25),replace(vlf_first_lsn,':',''),2),1,1) over(order by vlf_first_lsn)
from sys.dm_db_log_info(db_id())
where vlf_first_lsn != '00000000:00000000:0000'
order by vlf_first_lsn

open vlf_cursor
fetch next from vlf_cursor into @f_lsn, @l_lsn
while @@fetch_status = 0
begin

insert into @records
select count(*)
from sys.fn_dblog(
dbo.fn_convert_lsn(@f_lsn),
dbo.fn_convert_lsn(@l_lsn))

fetch next from vlf_cursor into @f_lsn, @l_lsn
end
close vlf_cursor
deallocate vlf_cursor

select avg(records) from @records

```

When you failover to the next available node, you'll notice that the database remains in the `In Recovery` state for an extended period. To monitor the recovery process effectively, use the following script:

```sql
declare @table table (id int identity(1,1), logDate datetime, ProcessInfo varchar(200), Text varchar(max))
insert into @table
exec [sys].[sp_readerrorlog] 0

select 
database_name, state_desc, log_reuse_wait_desc, user_access_desc,
convert(varchar(10),dateadd(s,cast(substring(remaining_time,1, charindex(' ',remaining_time)-1) as bigint),'2000-01-01'),108) remain_formatted, 
substring(remaining_time,1,len(remaining_time)-1) remaining_time, 
full_Text
from (
select replace(substring(Text,1,charindex(' ',Text)-1),'''','') database_name,
ltrim(rtrim(substring(Text,charindex('approximately',Text)+14,len(Text)))) remaining_time, full_Text
from (
select ltrim(rtrim(substring(Text,1, charindex('.',Text)-1))) Text, full_Text
from (
select substring(Text,charindex('database',Text)+9, len(Text)) Text, Text full_Text
from @table
where text like 'Recovery%approximately%'
and id in (select max(id) from @table where text like 'Recovery%approximately%'))a)b)c
inner join sys.databases db
on c.database_name = db.name

select session_id, percent_complete, command, status, start_time,
convert(varchar(10),dateadd(datediff(s, start_time, getedate()),'2000-01-01'),108) duration
from sys.dm_exec_requests
where command = 'db startup'

select count(*), object_name from sys.dm_os_performance_counters
group by object_name
order by object_name

```

To fix this issue, you have to reduce the number of `VLF`s, by:

1. clear out or truncate the transaction log file, by taking log backups, this process could you initiate it more than 1 time.
2. shrink the log file until you reach a smallest `VLF`, e.g. 2 MB.
3. add space to the transaction log file and modify the file growth to a reseanble size e.g. 64MB, 128MB, 512MB, 1GB = (all these are = 16 VLFs)

```sql
Backup log [ProdDB] to disk = 'F:\SQLBackup\Backup\ProdDB_log.bak' WITH NOFORMAT, NOINIT,
NAME = 'ProdDB-Log', SKIP, NOREWIND< NOUNLOUD, COMPRESSION, STATS = 1
GO
DBCC SHRINKFILE (ProdDB_log, 2)
GO
Alter database ProdDB modify file (name ='ProdDB_log', size = 4GB, filegrowth = 512MB)
```

Execute the `VLF analysis` script at each step of the fix steps above.






