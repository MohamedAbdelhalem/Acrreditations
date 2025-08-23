1st reason: NIC card on node 2 was disabled.

2nd reason: System user `NT AUTHORITY\SYSTEM` has `Deny` permission on `ALTER ANY AVAILABILITY GROUP`

To find out the missing permissions, run the below query:

```sql

select 
case id when 1 then login_name  else '~~~' end login_name,
case id when 1 then deny_login  else '~~~' end deny_login,
case id when 1 then has_access  else '~~~' end has_access,
case id when 1 then is_disabled else '~~~' end is_disabled,
currnet_permission, all_permission, state_desc, case  
when state_desc = 'DENY' then 'GRANT '+all_permission collate SQL_Latin1_General_CP1_CI_AS+' TO ['+login_name+']' 
when state_desc is NULL then 'GRANT '+all_permission collate SQL_Latin1_General_CP1_CI_AS+' TO ['+login_name+']' 
else ''
end hot_fix
from (
select id,
d.login_name, deny_login, has_access, is_disabled, isnull([permission_name],'NA') currnet_permission,
permissions all_permission, state_desc
from (values 
('NT AUTHORITY\SYSTEM','ALTER ANY AVAILABILITY GROUP'), --mandatory
('NT AUTHORITY\SYSTEM','CREATE AVAILABILITY GROUP'),    --best practice
('NT AUTHORITY\SYSTEM','CONNECT SQL'),                  --mandatory
('NT AUTHORITY\SYSTEM','VIEW ANY DATABASE'),            --best practice
('NT AUTHORITY\SYSTEM','VIEW SERVER STATE')             --mandatory
) d([login_name],[permissions]) left outer join
(
select row_number() over(order by l.name) id,
l.name login_name,
cast(l.denylogin as char(1)) deny_login,
cast(l.hasaccess as char(1)) has_access,
cast(l.is_disabled as char(1)) is_disabled,
sp.permission_name, sp.state_desc
from sys.server_permissions sp inner join (select sp.name, sl.denylogin, sl.hasaccess, sp.principal_id, sp.is_disabled
from sys.server_principals sp inner join sys.syslogins sl
on sp.sid = sl.sid
where sp.name = 'NT AUTHORITY\SYSTEM')l
on sp.grantee_principal_id = l.principal_id)t
on d.[permissions] = t.permission_name) fr
```

After Enable the NIC and Grant permissions, start the AG

```PowerShell

Start-ClusterResource -name "AOCorp"

```
