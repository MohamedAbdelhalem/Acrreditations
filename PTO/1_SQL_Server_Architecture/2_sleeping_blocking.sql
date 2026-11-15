BEGIN TRANSACTION;

UPDATE sales.SalesOrderHeader
SET Status =7
WHERE SalesOrderID = 43662;

UPDATE sales.SalesOrderHeader
SET Status =7
WHERE SalesOrderID = 43663;

UPDATE sales.SalesOrderHeader
SET Status =7
WHERE SalesOrderID = 43664;

UPDATE sales.SalesOrderHeader
SET Status =7
WHERE SalesOrderID = 43665;

commit
