SQL Server was stopped using

```cmd
NET STOP MSSQL$INST1 /Y
```

Simulation

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
