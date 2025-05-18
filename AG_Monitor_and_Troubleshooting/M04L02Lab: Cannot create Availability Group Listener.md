The issue is a leak of permission on the CNO to create computer object.

1. Go to the `AlwaysOnDC` machine and open `Active Directory Users and Computers`, and then search on the `OU` that contains the windows cluster `AlwaysOnCluster`.
2. Right click on the OU `AlwaysOnOU` and go to the `security` tab, then click Advanced.
3. Add or Edit if the CNO exists

4. Select a principall and check these permissions.
5. then try to create the Listener again.
