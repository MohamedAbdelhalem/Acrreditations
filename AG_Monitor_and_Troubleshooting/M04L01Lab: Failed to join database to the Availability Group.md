The problem presents 3 steps:

### 1- Node 3 doesn't have domain service account `corpnet\SQLSvc` but `Local System` 

  Change it, however, you may have an issue after changing the service account with this error **`"Cannot generate SSPI context"`**

  To fix it:
  
### 2- Go to `AlwaysOnDC` node to Set `SPN`

#### There are 2 approaches to fix it

a. Delete the exist SPN 

```powershell
SETSPN -D MSSQLSvc/AlwaysOnN3.corpnet.Contoso.com AlwaysOnN3
SETSPN -D MSSQLSvc/AlwaysOnN3.corpnet.Contoso.com:1433 AlwaysOnN3
```

b. Add SPN

```powershell
#query SPN
SETSPN -L AlwaysOnN3

#delete duplicate
SETSPN -D MSSQLSvc/AlwaysOnN3.corpnet.Contoso.com AlwaysOnN3
SETSPN -D MSSQLSvc/AlwaysOnN3.corpnet.Contoso.com:1433 AlwaysOnN3

#add SPN
SETSPN -A MSSQLSvc/AlwaysOnN3.corpnet.Contoso.com corpnet\SQLSvc
SETSPN -A MSSQLSvc/AlwaysOnN3.corpnet.Contoso.com:1433 corpnet\SQLSvc
```
**Then**

![alt text](https://github.com/MohamedAbdelhalem/Acrreditations/blob/main/AG_Monitor_and_Troubleshooting/media/Trust_Encrypt.png)

### 3- Add in each node in the firewall inbound port **`5022`**

![alt text](https://github.com/MohamedAbdelhalem/Acrreditations/blob/main/AG_Monitor_and_Troubleshooting/media/Port_5022.png)

Then create the availability group normally.
