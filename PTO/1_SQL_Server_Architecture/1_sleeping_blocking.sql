BEGIN TRANSACTION;

UPDATE sales.SalesOrderHeader
SET Status =6
WHERE SalesOrderID = 43662;

UPDATE sales.SalesOrderHeader
SET Status =3
WHERE SalesOrderID = 43663;
