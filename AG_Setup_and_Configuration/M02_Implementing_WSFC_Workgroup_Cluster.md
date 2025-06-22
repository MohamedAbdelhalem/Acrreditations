To implement a **Windows Server Failover Cluster in a workgroup environment** (i.e., without Active Directory domain membership), you can follow these steps. This is known as a **Workgroup Cluster**, supported starting with **Windows Server 2016**.

---

### ✅ **Prerequisites**
- All nodes must run **Windows Server 2016 or later**.
- Nodes must be in the **same subnet** and have **static IP addresses**.
- Use **identical local administrator accounts** on all nodes (same username and password).
- Ensure **DNS resolution** or use the `hosts` file for name resolution.

---

### 🔧 **Step-by-Step Configuration**

#### **1. Install Failover Clustering Feature**
On each node, run:
```powershell
Install-WindowsFeature -Name Failover-Clustering -IncludeManagementTools
```

#### **2. Create Local Admin Account**
On each node:
```powershell
net user clustadm Sup33P@ssw0Rd! /add
net localgroup administrators clustadm /add
```
Ensure the same username and password on all nodes.

#### **3. Enable Remote Access for Local Accounts**
Run this on each node:
```powershell
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name LocalAccountTokenFilterPolicy -Value 1 -PropertyType DWord
```

#### **4. Set Primary DNS Suffix**
- Go to **System Properties** → **Computer Name** → **Change** → **More…**
- Set the same **Primary DNS suffix** on all nodes (e.g., `workgroup.local`)

#### **5. Update Hosts File**
Edit `C:\Windows\System32\drivers\etc\hosts` on each node:
```
192.168.1.21 node1
192.168.1.22 node2
192.168.1.20 cluster1
```

#### **6. Validate Cluster Configuration**
```powershell
Test-Cluster -Node node1, node2
```

#### **7. Create the Cluster**
```powershell
New-Cluster -Name cluster1 -Node node1, node2 -AdministrativeAccessPoint DNS -StaticAddress 192.168.1.20
```

#### **8. Verify Cluster**
```powershell
Get-Cluster
Get-ClusterNode
```

---

### ⚠️ Limitations of Workgroup Clusters
- **Kerberos authentication** is not available.
- **Live Migration** is not supported (only Quick Migration).
- **File Server roles** are supported but not recommended.
- **SQL Server Always On Availability Groups** are supported, but you must use **certificate-based authentication** instead of Windows Authentication.

