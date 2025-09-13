To combine two SQL Server replicas from **different domains**—like `STCProd.com` and `STCDR.com`—into a single **Windows Server Failover Cluster (WSFC)** for an **Always On Availability Group**, you’ll need to use a **Domain-Independent Availability Group**. This is a specialized setup introduced in **Windows Server 2016 and SQL Server 2016+** that allows clustering across:

- Different domains  
- Workgroup servers  
- Mixed domain/workgroup environments  

---

### 🧱 Key Requirements

#### ✅ Windows Server 2016 or later  
Supports **Workgroup Clusters**, which are domain-independent.

#### ✅ SQL Server 2016 or later  
Supports **Domain-Independent Availability Groups** using **certificate-based authentication**.

#### ✅ DNS Configuration  
All nodes must have consistent **DNS suffixes** and be able to resolve each other by FQDN.

#### ✅ Certificates for Endpoint Authentication  
Since Kerberos isn’t supported in this setup, you’ll use **SSL certificates** to secure communication between replicas.

---

### 🛠️ Step-by-Step Overview

#### 1. **Configure DNS Suffixes**
Ensure each node has a proper DNS suffix so they can resolve each other:
```powershell
Set-DnsClientGlobalSetting -SuffixSearchList @("stcprod.com", "stcdr.com")
```

#### 2. **Create a Workgroup Cluster**
Use PowerShell to create the WSFC:
```powershell
New-Cluster -Name STCCluster -Node STCNode1, STCNode2 -StaticAddress "10.0.0.100"
```

> You cannot use Failover Cluster Manager to create this type of cluster—it must be done via PowerShell.

#### 3. **Configure Certificates**
Generate and install certificates on each node for endpoint authentication:
```sql
CREATE CERTIFICATE AGCert WITH SUBJECT = 'AlwaysOnCert';
CREATE ENDPOINT HadrEndpoint
    STATE = STARTED
    AS TCP (LISTENER_PORT = 5022)
    FOR DATABASE_MIRRORING (ROLE = ALL, AUTHENTICATION = CERTIFICATE AGCert, ENCRYPTION = REQUIRED);
```

#### 4. **Create the Availability Group**
Use T-SQL to create the AG with the appropriate endpoints and replicas.

#### 5. **Configure Listener (Optional)**
You can create a listener, but it must be registered manually in DNS. **Kerberos is not supported**, so use **SQL Authentication** for client connections.

---

### ⚠️ Limitations to Keep in Mind

- **No Kerberos support**: Only SQL authentication is supported.
- **No FCI support**: Failover Cluster Instances cannot be used in domain-independent clusters.
- **Manual listener registration**: You must manually configure DNS entries for AG listeners.



If you're planning to deploy this in production, I can help you sketch out the certificate strategy, DNS setup, and failover logic. Just let me know how deep you want to go.
