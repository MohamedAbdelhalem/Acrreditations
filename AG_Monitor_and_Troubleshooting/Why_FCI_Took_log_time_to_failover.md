Because of there are more than 20,000 VLF in the database ProdDB.

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

then execute this code to get the avrage records that fell the vlf

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

so, run this code to know how many records inside the Transaction log file in each 1MB:

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


