Check below 
## 1- Ensure that SQL Server clustered role is configured to failover if restarts are unsuccessful on current node:

![alt text](https://github.com/MohamedAbdelhalem/Acrreditations/blob/main/AG_Monitor_and_Troubleshooting/media/if_restart_is_unsuccessful_fail_over_all_resources_in_the_role.png)

## 2- Review the **Maximum failures in the specified period** setting for SQL Server clustered Role:

To configure the **Maximum Failures in the Failover Cluster Manager** for a SQL Server clustered role, you can follow these steps:

1. **Open Failover Cluster Manager**:
   - Navigate to **Roles** in the left-hand pane.
   - Right-click on the SQL Server clustered role you want to configure and select **Properties**.

2. **Set Maximum Failures**:
   - Go to the **Failover** tab.
   - In the **Maximum Failures in the Specified Period** section, set the value to **N-1**, where N is the number of nodes in your cluster. For example, if you have 3 nodes, set this value to 2.

### Explanation of N-1 Configuration

**N-1** means the number of nodes in the cluster minus one. This configuration is beneficial because it ensures that the clustered role can failover to all available nodes except one before it is left in a failed state. This setting helps to balance between high availability and avoiding unnecessary failovers that could lead to instability.

### Why N-1 is a Good Configuration

1. **High Availability**: By setting the maximum failures to N-1, you ensure that the clustered role can failover to all but one of the nodes, maximizing the availability of the service.
2. **Stability**: It prevents the cluster from continuously failing over between nodes, which could lead to performance degradation and instability.
3. **Resource Management**: It helps in managing resources efficiently by not overloading the cluster with continuous failovers.

### Why Not Set the Number to 10

Setting the maximum failures to a high number like 10, especially when you have only 3 nodes, is not advisable because:

1. **Unnecessary Failovers**: It could lead to excessive failovers, which might not resolve the underlying issue and could cause further instability.
2. **Resource Strain**: Continuous failovers can strain the cluster resources and impact the performance of other services running on the cluster.
3. **Complexity in Troubleshooting**: It makes it harder to identify and troubleshoot the root cause of the failures, as the service keeps failing over without resolving the issue.

### Example Scenario

If you have a 3-node cluster and set the maximum failures to 2 (N-1), the clustered role can failover to two other nodes before it is left in a failed state. This ensures that the service remains available while avoiding unnecessary failovers that could lead to instability.

## 3- Ensure all the possible owners are checked for all clustered resources in the role

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
### To fix it and add the missing `Possible Owner Nodes`
>[!Note]
>*Run the above script again then execute the below*
>
>**$nodes = @("ALWAYSONN1","ALWAYSONN2","ALWAYSONN3")**
>
> Add in `$nodes` parameter all machine names you want to be a possible owners for the below `$OwnerGroup`
>
>**$OwnerGroup = "SQL Server (INST1)"**
>
>place here the group name, e.g. SQL Server (INST1) "SQL Server FCI Name" or Cluster group
>
>**$ResourceType = "Physical Disk" #or "*"**
>
>here you have 2 options,
>
>1. to place the ResourceType, e.g. "Physical Disk" in case your FCI is installed in 2 nodes and the cluster disks are shared in all nodes (3 nodes)
> 
>2. put "*" in case of all resources in the above group you want to add these nodes ($nodes) as a possible owner nodes


```powershell
$nodes = @("ALWAYSONN1","ALWAYSONN2","ALWAYSONN3")
$OwnerGroup = "SQL Server (INST1)"
$ResourceType = "Physical Disk" #or "*"

if ($type -eq "*") {
    $result = $table | where {$_.OwnerGroup -eq $OwnerGroup} | select ResourceName
    foreach ($fix in $result){
         Set-ClusterOwnerNode -Resource $fix.ResourceName -Owner $nodes
    }
}else{
    $result = $table | where {$_.OwnerGroup -eq $OwnerGroup -and $_.ResourceType -eq $ResourceType} | select ResourceName
    foreach ($fix in $result){
         Set-ClusterOwnerNode -Resource $fix.ResourceName -Owner $nodes
    }
}

```
## 4- Ensure that SQL Server is installed on the passive node/s.

