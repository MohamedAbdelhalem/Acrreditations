The problem  contans 3 issues:
1. Node 3 doesn't have domain service account `Local System` not `corpnet\SQLSvc`

Change it, and you may have an issue to after changing the service account with this error **`"Cannot generate SSPI context"`**

To fix it:

![alt text](https://github.com/MohamedAbdelhalem/Acrreditations/blob/main/AG_Monitor_and_Troubleshooting/media/Trust_Encrypt.png)

2. Add in each node in the firewall inbound port **`5022`**

![alt text](https://github.com/MohamedAbdelhalem/Acrreditations/blob/main/AG_Monitor_and_Troubleshooting/media/port_5022.png)
