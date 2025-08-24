The problem presents 3 steps:

1- Node 3 doesn't have domain service account `corpnet\SQLSvc` but `Local System` 

  Change it, however, you may have an issue after changing the service account with this error **`"Cannot generate SSPI context"`**

  To fix it:

![alt text](https://github.com/MohamedAbdelhalem/Acrreditations/blob/main/AG_Monitor_and_Troubleshooting/media/Trust_Encrypt.png)

2. Add in each node in the firewall inbound port **`5022`**

![alt text](https://github.com/MohamedAbdelhalem/Acrreditations/blob/main/AG_Monitor_and_Troubleshooting/media/Port_5022.png)

3. Then create the availability group normally.
