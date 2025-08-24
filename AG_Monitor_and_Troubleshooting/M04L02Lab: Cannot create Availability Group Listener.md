### The issue is a leak of permission on the CNO of having Create Computer Object permission on the AD.

1. Go to the `AlwaysOnDC` machine and open `Active Directory Users and Computers`, and then search on the `OU` that contains the windows cluster `AlwaysOnCluster`.
2. Right click on the OU `AlwaysOnOU` and go to the `security` tab, then click Advanced.
   
   ![alt text](https://github.com/MohamedAbdelhalem/Acrreditations/blob/main/AG_Monitor_and_Troubleshooting/media/CNO_OU.png)
   
    
3. `Add` or `Edit` if the Cluster Name Object `CNO` exists:
   
   ![alt text](https://github.com/MohamedAbdelhalem/Acrreditations/blob/main/AG_Monitor_and_Troubleshooting/media/Add_or_edit_CNO.png)

4. `Select a principal` and add the CNO `AlwaysOnCluster$` from `Computers`, the add these permissions.

   ![alt text](https://github.com/MohamedAbdelhalem/Acrreditations/blob/main/AG_Monitor_and_Troubleshooting/media/CNO_Computer_object.png)

5. Then try to `create the Listener` again.
