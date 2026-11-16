BEGIN TRANSACTION;

UPDATE sales.SalesOrderHeader
SET Status =6
WHERE SalesOrderID = 43662;

UPDATE sales.SalesOrderHeader
SET Status =3
WHERE SalesOrderID = 43663;

--or

BEGIN TRANSACTION;

UPDATE sales.SalesOrderHeader
SET Status =6
WHERE SalesOrderID = 43662;
go
select * from sales.SalesOrderHeader
WHERE SalesOrderID = 43662;

