if (select count(*) from sys.tables where object_id = object_id('dbo.DBA_monitor_memory')) = 0
begin
create table dbo.DBA_monitor_memory(rid int identity(1,1),
PhysicalMemoryMB float,
CommittedMemoryMB float,
MemoryUtilizationPercent int,
LockedPagesMB float,
PageFaultCount bigint,
PhysicalMemoryLow int,
VirtualMemoryLow int)
end

set nocount on
while 1=1
begin
insert into dbo.DBA_monitor_memory(
PhysicalMemoryMB,CommittedMemoryMB,MemoryUtilizationPercent,LockedPagesMB,PageFaultCount,PhysicalMemoryLow,VirtualMemoryLow)
SELECT
    physical_memory_in_use_kb / 1024.0 AS PhysicalMemoryMB,
    virtual_address_space_committed_kb / 1024.0 AS CommittedMemoryMB,
    memory_utilization_percentage AS MemoryUtilizationPercent,
    locked_page_allocations_kb / 1024.0 AS LockedPagesMB,
    page_fault_count AS PageFaultCount,
    process_physical_memory_low AS PhysicalMemoryLow,
    process_virtual_memory_low AS VirtualMemoryLow
FROM sys.dm_os_process_memory;
WAITFOR Delay '00:00:05'
end
set nocount off

--run the below query afterward
select 
master.dbo.numbersize(PhysicalMemoryMB,'m') PhysicalMemory,
master.dbo.numbersize(CommittedMemoryMB,'m') CommittedMemory,
cast((PhysicalMemoryMB/CommittedMemoryMB) * 100 as int) pct_of_PhysicalMemory,
master.dbo.numbersize(CommittedMemoryMB,'m') CommittedMemory,
(
	SELECT 
	case sql_memory_model_desc 
	when 'CONVENTIONAL' then 0
	when 'LOCK_PAGES' then 1
	when 'LARGE_PAGES' then 1
	end is_LPIM_enabled
	FROM sys.dm_os_sys_info info cross apply sys.dm_server_services s
	where s.servicename like 'SQL Server ('+isnull(cast(SERVERPROPERTY('InstanceName') as varchar(100)),'MSSQLSERVER')+'%') is_LPIM_enabled,
MemoryUtilizationPercent,
LockedPagesMB,
PageFaultCount,
case when rid = 1 then 0 else PageFaultCount-LAG(PageFaultCount,1,1)over(order by rid) end PageFaultCount_diff,
PhysicalMemoryLow,VirtualMemoryLow
from dbo.DBA_monitor_memory
