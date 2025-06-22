To configure a **Windows Failover Cluster with 4 nodes across two domains**—`stcProd.com` and `stcDR.com`—and enable **SQL Server Always On Availability Groups**, here’s a step-by-step guide tailored to your setup:

---

### **1. Prerequisites**
- **Domains**: Ensure `stcProd.com` and `stcDR.com` have a **two-way trust** relationship.
- **Nodes**: 
  - `DC1SQLSERVERDB01` and `DC1SQLSERVERDB02` in `stcProd.com`
  - `DC2SQLSERVERDB01` and `DC2SQLSERVERDB02` in `stcDR.com`
- **Windows Server**: All nodes must be running a supported version of Windows Server with Failover Clustering feature installed.
- **SQL Server**: Use SQL Server Enterprise Edition for Always On AG support.

---

### **2. Configure Networking and DNS**
- Ensure all nodes can resolve each other’s FQDNs across domains.
- Configure firewall rules to allow clustering and SQL Server ports (e.g., 1433, 5022).

---

### **3. Create the Windows Server Failover Cluster (WSFC)**
- On one node, run:
  ```powershell
  New-Cluster -Name SQLCLUSTER -Node DC1SQLSERVERDB01,DC1SQLSERVERDB02,DC2SQLSERVERDB01,DC2SQLSERVERDB02 -StaticAddress <ClusterIP>
  ```
- Validate the cluster using:
  ```powershell
  Test-Cluster
  ```
- Ensure quorum is configured properly (e.g., **Node Majority** or **File Share Witness** for multi-site).

---

### **4. Enable Always On Availability Groups**
- On each SQL Server instance:
  - Open SQL Server Configuration Manager.
  - Enable **Always On Availability Groups** under SQL Server Services → Properties → Always On High Availability tab.
  - Restart the SQL Server service.

---

### **5. Create the Availability Group**
- In SQL Server Management Studio (SSMS):
  - Right-click **Always On High Availability** → **New Availability Group Wizard**.
  - Define the AG name.
  - Select the databases (must be in full recovery mode and backed up).
  - Add replicas: one from each node.
  - Configure automatic failover (if desired), readable secondaries, and endpoints.
  - Set up the listener (optional but recommended).
  - Validate and deploy.

---

### **6. Test Failover and Connectivity**
- Use SSMS or PowerShell to test failover between nodes.
- Ensure applications can connect via the AG listener.

---

### **7. Monitor and Maintain**
- Use **SQL Server Management Studio**, **Failover Cluster Manager**, and **Windows Event Logs** to monitor health.
- Regularly back up databases and test DR scenarios.

---


To ensure that `stcProd.com` and `stcDR.com` have a **two-way trust relationship**, follow these key steps. This setup allows users and services in both domains to authenticate and access resources across the domains—essential for your SQL Server Always On configuration across multiple domains.

---

### **Step-by-Step: Configure Two-Way Trust Between Domains**

#### **1. Prerequisites**
- Both domains must be in **separate Active Directory forests**.
- Ensure **network connectivity** between Domain Controllers (DCs) in both domains.
- Open required **firewall ports** for Active Directory trust and replication.

---

#### **2. Configure DNS Conditional Forwarders**
This allows each domain to resolve names in the other domain.

**Using PowerShell:**
On `stcProd.com` DC:
```powershell
Add-DnsServerConditionalForwarderZone -Name "stcDR.com" -MasterServers "<IP_of_DC_in_stcDR>"
```

On `stcDR.com` DC:
```powershell
Add-DnsServerConditionalForwarderZone -Name "stcProd.com" -MasterServers "<IP_of_DC_in_stcProd>"
```

**Or via GUI:**
- Open **DNS Manager** → Right-click **Conditional Forwarders** → **New Conditional Forwarder**
- Enter the other domain name and its DC IP address
- Check the box to store in Active Directory and replicate as needed

---

#### **3. Create the Two-Way Trust**
On a Domain Controller in `stcProd.com`:
1. Open **Active Directory Domains and Trusts**
2. Right-click the domain → **Properties** → **Trusts** tab → **New Trust**
3. Enter the name of the other domain (`stcDR.com`)
4. Choose **Two-way** trust
5. Select **Forest trust** (if applicable)
6. Choose **Both this domain and the specified domain**
7. Provide credentials for the other domain
8. Confirm and validate the trust

Repeat the same steps on a DC in `stcDR.com` to ensure bidirectional setup.

---

#### **4. Validate the Trust**
- Use the **"Validate"** button in the Trusts tab to confirm both sides are working.
- You can also use:
```powershell
nltest /domain_trusts
```
