--from primary database
:CONNECT SQLSERVERVM01
USE master
GO
select database_id, db_name(database_id) database_name, case
encryption_state
when 0 then 'No database encryption key present, no encryption'
when 1 then 'Unencrypted'
when 2 then 'Encryption in progress'
when 3 then 'Encrypted'
when 4 then 'Key change in progress'
when 5 then 'Decryption in progress'
when 6 then 'Protection change in progress'
end status,
cer.certificate_id, 
cer.name encryptor_type, percent_complete, 
encryption_scan_state_desc, encryptor_thumbprint
from sys.dm_database_encryption_keys ek inner join sys.certificates cer
on ek.encryptor_thumbprint = cer.thumbprint
GO
ALTER DATABASE AdventureWorks2019 SET ENCRYPTION OFF;
GO
-- Then it recommended to take a backup log after you disable the TDE and not just wait for the Transaction log backup schedule job.
BACKUP LOG [AdventureWorks2019] 
TO DISK = N'\\192.168.100.101\share\AdventureWorks2019_TDE2.bak' WITH NOFORMAT, NOINIT,  
NAME = N'AdventureWorks2019-Log Database Backup', SKIP, NOREWIND, NOUNLOAD, COMPRESSION, STATS = 10
GO
USE AdventureWorks2019
GO
DROP DATABASE ENCRYPTION KEY;
GO

-- Check the secondaries that there is no record on the below query
--:CONNECT SQLSERVERVM02
:CONNECT SQLSERVERVM03

select database_id, db_name(database_id) database_name, case
encryption_state
when 0 then 'No database encryption key present, no encryption'
when 1 then 'Unencrypted'
when 2 then 'Encryption in progress'
when 3 then 'Encrypted'
when 4 then 'Key change in progress'
when 5 then 'Decryption in progress'
when 6 then 'Protection change in progress'
end status,
cer.certificate_id, 
cer.name encryptor_type, percent_complete, 
encryption_scan_state_desc, encryptor_thumbprint
from sys.dm_database_encryption_keys ek inner join sys.certificates cer
on ek.encryptor_thumbprint = cer.thumbprint
GO

