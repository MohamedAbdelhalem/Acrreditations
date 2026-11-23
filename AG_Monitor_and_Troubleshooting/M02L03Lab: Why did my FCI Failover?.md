SQL Server was stopped using

To simulation failure to test automatic `failover`

### 1. In this scenario you are failing the SQL Server agent to attempt to start it after disable the Agent XPs and when it failed to bring it online it will trigger the automatic failover for the other resource
```powershell
SQLCMD -S .\INST1 -E
EXEC sp_configure 'show advanced options',1;recofigure;
GO
EXEC sp_configure 'Agent XPs',0;recofigure;
GO
Exit
Stop-Service -Name SQLAgent$INST1
Start-Service -Name SQLAgent$INST1
```

![alt text](https://github.com/MohamedAbdelhalem/Acrreditations/blob/main/AG_Monitor_and_Troubleshooting/media/if_restart_is_unsuccessful_fail_over_all_resources_in_the_role.png)


### 2. In this scenario you are restarting the SQL Server to trigger the automatic failover
```powershell
NET STOP MSSQL$INST1 /Y
#Or
Stop-Process -Name sqlservr -Force
#Or
Stop-Service -Name 'MSSQL$INST1' -Force
```

Or

```powershell
$loop = 0
$service = (get-service -name "*sql*" | where {$_.DispalyName -like "*SQL Server (*"}).name
$status = (get-service -name $service).status
while ($status -eq "Running") {
  Stop-Service -Name $service -Force
  Start-Sleep -Seconds 20
  $status = (get-service -name $service).status
  $loop++
  "Attempted no" $loop
}
```
