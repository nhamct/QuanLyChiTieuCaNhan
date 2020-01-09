/*
1.	Khi xóa d? li?u trong b?ng account, hãy th?c hi?n thao tác c?p nh?t tr?ng thái tài kho?n là 9 (không dùng n?a) thay vì xóa.
2.	Khi thêm m?i d? li?u trong b?ng transactions hãy th?c hi?n các công vi?c sau:
a.	Ki?m tra tr?ng thái tài kho?n c?a giao d?ch hi?n hành. N?u tr?ng thái tài kho?n ac_type = 9 thì ??a ra thông báo ‘tài kho?n ?ã b? xóa’ và h?y thao tác ?ã th?c hi?n. Ng??c l?i:  
i.	N?u là giao d?ch g?i: s? d? = s? d? + ti?n g?i. 
ii.	N?u là giao d?ch rút: s? d? = s? d? – ti?n rút. N?u s? d? sau khi th?c hi?n giao d?ch < 50.000 thì ??a ra thông báo ‘không ?? ti?n’ và h?y thao tác ?ã th?c hi?n.
3.	Khi s?a d? li?u trong b?ng transactions hãy tính l?i s? d?:
S? d? = s? d? c? + (s? d? m?i – s? d? c?)
4.	Sau khi xóa d? li?u trong transactions hãy tính l?i s? d?:
a.	N?u là giao d?ch rút
S? d? = s? d? c? + t_amount
b.	N?u là giao d?ch g?i
S? d? = s? d? c? – t_amount
5.	Khi c?p nh?t ho?c s?a d? li?u tên khách hàng, hãy ??m b?o tên khách không nh? h?n 5 kí t?. 
6.	Khi tác ??ng ??n b?ng account (thêm, s?a, xóa), hãy ki?m tra lo?i tài kho?n. N?u ac_type = 9 (?ã b? xóa) thì ??a ra thông báo ‘tài kho?n ?ã b? xóa’ và h?y các thao tác v?a th?c hi?n.
7.	Khi thêm m?i d? li?u vào b?ng customer, ki?m tra n?u h? tên và s? ?i?n tho?i ?ã t?n t?i trong b?ng thì ??a ra thông báo ‘?ã t?n t?i khách hàng’ và h?y toàn b? thao tác.
8.	Khi thêm m?i d? li?u vào b?ng account, hãy ki?n tra mã khách hàng. N?u mã khách hàng ch?a t?n t?i trong b?ng customer thì ??a ra thông báo ‘khách hàng ch?a t?n t?i, hãy t?o m?i khách hàng tr??c’ và h?y toàn b? thao tác. 
*/
--1.	Khi xóa d? li?u trong b?ng account, hãy th?c hi?n thao tác c?p nh?t tr?ng thái tài kho?n là 9 (không dùng n?a) thay vì xóa.
CREATE TRIGGER tAccount
ON Account
INSTEAD OF Delete
AS
BEGIN
	update account
	set Ac_type=9
	where ac_no=(select Ac_no from deleted)
	
END
select*from account
delete account where Ac_no='1000000001'
--2.	Khi thêm m?i d? li?u trong b?ng transactions hãy th?c hi?n các công vi?c sau:
--a.	Ki?m tra tr?ng thái tài kho?n c?a giao d?ch hi?n hành. N?u tr?ng thái tài kho?n ac_type = 9 thì ??a ra thông báo ‘tài kho?n ?ã b? xóa’ và h?y thao tác ?ã th?c hi?n. Ng??c l?i:  
--i.	N?u là giao d?ch g?i: s? d? = s? d? + ti?n g?i. 
--ii.	N?u là giao d?ch rút: s? d? = s? d? – ti?n rút. N?u s? d? sau khi th?c hi?n giao d?ch < 50.000 thì ??a ra thông báo ‘không ?? ti?n’ và h?y thao tác ?ã th?c hi?n.
CREATE TRIGGER tg2
ON transactions
AFTER insert
AS
BEGIN
	declare @loai char(1)
	select @loai= (Select t_type from inserted)
	If @loai=9
		print 'Tai khoan da bi xoa'
	Else If @loai=1
		Begin
			update account
			set ac_balance=ac_balance+(select t_amount from inserted)
			Where Ac_no=(select Ac_no from inserted)
		end
	Else
		Begin
			Declare @SoDu varchar(50)
			update account
			set @SoDu=(ac_balance-(select t_amount from inserted))
			Where Ac_no=(select Ac_no from inserted)
			if @SoDu<50000
				print 'Khong Du Tien'
			Else
				commit
		End
END
--3.	Khi s?a d? li?u trong b?ng transactions hãy tính l?i s? d?:
--S? d? = s? d? c? + (s? d? m?i – s? d? c?)
CREATE TRIGGER tg3
ON Transactions
FOR update
AS
BEGIN
	Declare @Sodu varchar(50), @loai char(1)
	if @loai=1
		set @Sodu= (select ac_balance from account Where ac_no=(select Ac_no from inserted))+
		(select t_amount from inserted Where t_id=(select t_id from inserted))
	Else
		set @Sodu= (select ac_balance from account Where ac_no=(select Ac_no from inserted))-
		(select t_amount from inserted Where t_id=(select t_id from inserted))
	update account
	set ac_balance=ac_balance+(@Sodu-ac_balance) Where ac_no=(select ac_no from inserted)
END
--4.	Sau khi xóa d? li?u trong transactions hãy tính l?i s? d?:
--a.	N?u là giao d?ch rút
--S? d? = s? d? c? + t_amount
--b.	N?u là giao d?ch g?i
--S? d? = s? d? c? – t_amount
CREATE TRIGGER tg4
ON transactions
AFTER DELETE
AS
BEGIN
	declare @loai char(1)
	select @loai= (Select t_type from inserted)
	If @loai=1
		Begin
			update account
			set ac_balance=ac_balance+(select t_amount from deleted)
			Where Ac_no=(select ac_no from deleted)
		end
	Else
		Begin
			update account
			set ac_balance=ac_balance-(select t_amount from deleted)
			Where Ac_no=(select ac_no from deleted)
		End
END
--5.	Khi c?p nh?t ho?c s?a d? li?u tên khách hàng, hãy ??m b?o tên khách không nh? h?n 5 kí t?.
ALTER TRIGGER tg5
ON Customer
instead of Update
AS
BEGIN
	Declare @ten varchar(50), @a varchar(50)
	set @ten=(select cust_name from inserted)
	if len(@ten)>5
	begin
		update customer
		set Cust_name=(select Cust_name from inserted) 
		where Cust_id =(Select Cust_id from inserted)
	end
	else
		update customer
		set Cust_name='-----'+(select Cust_name from inserted) 
		where Cust_id =(Select Cust_id from inserted)
END

--test
update customer set Cust_name='tttttttta'
where Cust_id='000001'
select *from customer
--6.	Khi tác ??ng ??n b?ng account (thêm, s?a, xóa), hãy ki?m tra lo?i tài kho?n. 
--N?u ac_type = 9 (?ã b? xóa) thì ??a ra thông báo ‘tài kho?n ?ã b? xóa’ và h?y các thao tác v?a th?c hi?n.
ALTER TRIGGER tg6
ON Account
FOR Delete, Insert, Update
AS
BEGIN
	Declare @loai1 char(1), @loai2 char(1)
	select @loai1= (Select ac_type from deleted)
	select @loai2= (Select ac_type from inserted)
	If @loai1='9' or @loai2='9'
	begin
		print'Tai khoan da bi xoa'
		rollback
	end
		
END
select*from account
UPDATE account
SET ac_type='1'
WHERE aC_NO='1000000002'
--7.	Khi thêm mới dữ liệu vào bảng customer, kiểm tra nếu họ tên và số điện thoại đã tồn tại trong bảng 
--thì đưa ra thông báo ‘đã tồn tại khách hàng’ và hủy toàn bộ thao tác.
ALTER TRIGGER tg7
ON Customer
AFTER INSERT
AS
BEGIN
	declare @ten varchar(50), @sdt varchar(15)
	select @ten=Cust_name, @sdt=Cust_phone
	from inserted
	if not exists (select cust_name, Cust_phone from customer where Cust_name=@ten and Cust_phone=@sdt)
		begin
			print 'Da ton tai khach hang'
			rollback
		end
	
END

insert into customer(Cust_id,Cust_name,Cust_phone) values ('500001',N'Hà Công Lực', '01283388103')
insert into customer(cust_id,Cust_name,Cust_phone) values ('123996',N'nguyễn Công Lực', '01283378907')
--8.	Khi thêm mới dữ liệu vào bảng account, hãy kiển tra mã khách hàng. 
--Nếu mã khách hàng chưa tồn tại trong bảng customer thì đưa ra thông báo ‘khách hàng chưa tồn tại, hãy tạo mới khách hàng trước’ 
--và hủy toàn bộ thao tác.

CREATE TRIGGER tg8
on account
for insert
as
begin
	declare @ma varchar(50)
	select @ma=Cust_id
	from inserted
	if not exists (select cust_id from customer where Cust_id=@ma)
	begin
		print N'khách hàng chưa tồn tại, hãy tạo mới khách hàng trước'
		rollback
	end
end

insert into account(ac_no, cust_id) values ('1009007001','030051')
select*from account



--Khi thêm mới dữ liệu trong bảng Branch, hãy đảm bảo rằng tên chi nhánh chưa tồn tại trong bảng. Nếu đã tồn tại, hãy đưa ra thông báo "Duplicate" và hủy toàn bộ thao tác



----

insert into Branch ( Br_name) values (' Vietcombank Nghe An')

select * from Branch


/*
1.	Khi thêm m?i dl T n?u s? ti?n <0 h?y b? gd
2.	Khi thêm m?i dl b?ng T hãy c?p nh?t s? d? trong tài kho?n t??ng ?ng
3.	Khi c?p nh?t dl b?ng kh n?u kí t? h? tên <3 h?y gd
4.	Khi xóa dl trên b?ng c hãy ??m b?o m?i gd liên quan ac ?ó ph?i xóa tr??c m?i xóa dl liên quan
5.	Khi thêm m?i dl trên b?ng cust ktra n?u mã chi nhánh không t?n t?i trong b?ng br thì h?y b? và thông báo l?i
*/
--1.	Khi thêm m?i dl T n?u s? ti?n <0 h?y b? gd
ALTER trigger tgCheckAmout
on Transactions
FOR insert
AS
BEGIN 
	declare @amount numeric(15)
	set @amount = (Select t_amount from inserted)
	if @amount<0 
	begin
		print 'So tien khong hop le'
	end
	rollback
End
insert into transactions(t_id,t_amount) values ('100000000',-100000)
select * from transactions where t_id = '100000000'
--2.	Khi thêm m?i dl b?ng T hãy c?p nh?t s? d? trong tài kho?n t??ng ?ng
CREATE trigger tgCau2
on Transactions 
for insert
AS
BEGIN
	declare @loai char(1)
	select @loai= (Select t_type from inserted)
	If @loai=1
		Begin
			update account
			set ac_balance=ac_balance+(select t_amount from inserted)
			Where Ac_no=(select Ac_no from inserted)
		end
	Else
		Begin
			update account
			set ac_balance=ac_balance-(select t_amount from inserted)
			Where Ac_no=(select Ac_no from inserted)
		End
END
--3.	Khi c?p nh?t dl b?ng kh n?u kí t? h? tên <3 h?y gd
ALTER TRIGGER tgCau3
ON Customer
for UPDATE
AS
BEGIN
	Declare @ten varchar(50)
	set @ten=(Select Cust_name from inserted)
	If len(@ten)<3
	begin
		Print 'Huy Giao Dich'
		rollback
	end
	Else
		commit
END
--
update customer
set Cust_name='a'
where Cust_id='000001'
select*from customer
--4.	Khi xóa dl trên bảng c hãy đảm bảo mọi gd liên quan ac đó phải xóa trước mới xóa dl liên quan
CREATE TRIGGER tg4
ON Customer
instead of Delete
AS
BEGIN

END

ALTER TRIGGER tgTransacyions

ON transactions

FOR Insert

AS
BEGIN
	Declare @ngay date
	set @ngay=(select t_date from inserted)
	if @ngay < (select getdate())
	rollback
END

Create  Trigger Tgdl

On Branch

for insert

As

Begin

Declare @Namebr nvarchar(50) 

Set @NameBr=(Select Br_name from inserted)

if exists (select Br_name from branch where Br_name = @NameBr) 

	Begin

	Print 'Duplicate'

	rollback 

	end

END 



--Khi thêm mới dữ liệu trong bảng Branch, hãy đảm bảo rằng tên chi nhánh chưa tồn tại trong bảng. 
--Nếu đã tồn tại, hãy đưa ra thông báo "Duplicate" và hủy toàn bộ thao tác

CREATE TRIGGER tgDuLieu
ON Branch
for insert
AS
BEGIN
	Declare @ten varchar(50)
	set @ten=(Select BR_name from inserted)
	if exists (select Br_name from branch where Br_name = @ten)
	begin
		Print 'Duplicate'
		rollback
	end
END