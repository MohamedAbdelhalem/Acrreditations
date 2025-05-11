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

