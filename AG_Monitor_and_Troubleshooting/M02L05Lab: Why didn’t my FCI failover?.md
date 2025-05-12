Check below 

3. Ensure all the possible owners are checked for all clustered resources in the role

Run the below powershell script:

```powershell
$resource = Get-ClusterResource | Select Name, State, ResourceType, OwnerGroup, OwnerNode
$table = New-Object System.Collections.ArrayList;
$loop = 0
ForEach ($resource in $resources)
{
      $poss = Get-ClusterResource -Name $resource.Name | Get-ClusterOwnerNode
      $table += [psCustomObject]@{
          ResourceName = $resource[$loop].Name;
          ResourceType = $resource[$loop].ResourceType;
          State = $resource[$loop].State;
          OwnerNode = $resource[$loop].OwnerNode;
          OwnerGroup = $resource[$loop].OwnerGroup;
          PossibleOwnerNodes = $resource[$loop].OwnerNodes
          }
      $loop++
}

$table | Format-Table
```
To fix it and add the missing `Possible Owner Nodes`
>[!Note]
> fill these parameters $nodes to put all machine names you want to be a possible owners for the below group
>
>$nodes = @("ALWAYSONN1","ALWAYSONN2","ALWAYSONN3")
>place here the group name, e.g. SQL Server (INST1) "SQL Server FCI Name" or Cluster group
>$group = "SQL Server (INST1)"
>here you have 2 options,
>1. to place the ResourceType, e.g. "Physical Disk" in case your FCI is installed in 2 nodes and the cluster disks are shared in all nodes (3 nodes)
>2. put "*" in case of all resources in the above group you want to add these nodes ($nodes) as a possible owner nodes 
>$type = "Physical Disk" #or "*"

```powershell
$nodes = @("ALWAYSONN1","ALWAYSONN2","ALWAYSONN3")
$group = "SQL Server (INST1)"
$type = "Physical Disk" #or "*"

if ($type -eq "*") {
    $result = $table | where {$_.OwnerGroup -eq $group} | select ResourceName
    foreach ($fix in $result){
         Set-ClusterOwnerNode -Resource $fix.ResourceName -Owner $nodes
    }
}else{
    $result = $table | where {$_.OwnerGroup -eq $group -and $_.ResourceType -eq $type} | select ResourceName
    foreach ($fix in $result){
         Set-ClusterOwnerNode -Resource $fix.ResourceName -Owner $nodes
    }
}

```
4. Ensure that SQL Server is installed on the passive node/s

