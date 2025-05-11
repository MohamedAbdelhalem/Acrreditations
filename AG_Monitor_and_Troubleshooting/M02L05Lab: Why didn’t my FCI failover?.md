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
4. Ensure that SQL Server is installed on the passive node/s

