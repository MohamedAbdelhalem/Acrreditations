SQL Server was stopped using

```cmd
NET STOP MSSQL$INST1 /Y
```

Simulation

```powershell
$loop = 0
$status = (get-service -name "*sql*" | where {$_.DispalyName -like "*SQL Server (*"}).status
while ($status -eq "Running") {
  Stop-Process -Name sqlservr -Force
  Start-Sleep -Seconds 10
  $status = (get-service -name "*sql*" | where {$_.DispalyName -like "*SQL Server (*"}).status
  $loop++
  "Attempted no" $loop
}
```
