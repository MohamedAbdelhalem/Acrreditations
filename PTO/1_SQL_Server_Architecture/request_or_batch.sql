--8 batches or requests
--one sql statement for each batch or request
insert into tableA values (1, 'mohamed', 5000, 'Riyadh', '+966533333333')
go
insert into tableA values (2, 'fawzy', 2000, 'Riyadh', '+966532222222')
go
insert into tableA values (3, 'ismail', 1000, 'Riyadh', '+966534444444')
go
insert into tableA values (4, 'abdelhalem', 3000, 'Riyadh', '+966531111111')
go
insert into tableA values (5, 'sayed', 7000, 'Riyadh', '+966530000000')
go
insert into tableA values (6, 'mohamed', 5500, 'Riyadh', '+966537777777')
go
insert into tableA values (7, 'salem', 9000, 'Riyadh', '+966531234567')
go
insert into tableA values (8, 'ahmed', 4000, 'Riyadh', '+966539999999')
go



--total 3 batches or requests
--3 sql statements = 1 batch or request
insert into tableA values (1, 'mohamed', 5000, 'Riyadh', '+966533333333')
insert into tableA values (2, 'fawzy', 2000, 'Riyadh', '+966532222222')
insert into tableA values (3, 'ismail', 1000, 'Riyadh', '+966534444444')
go
--3 sql statements = 1 batch or request
insert into tableA values (4, 'abdelhalem', 3000, 'Riyadh', '+966531111111')
insert into tableA values (5, 'sayed', 7000, 'Riyadh', '+966530000000')
insert into tableA values (6, 'mohamed', 5500, 'Riyadh', '+966537777777')
go
--2 sql statements = 1 batch or request
insert into tableA values (7, 'salem', 9000, 'Riyadh', '+966531234567')
insert into tableA values (8, 'ahmed', 4000, 'Riyadh', '+966539999999')
go
