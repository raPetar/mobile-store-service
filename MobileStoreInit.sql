USE [master]
GO
CREATE DATABASE [MobileStore]
GO
USE [MobileStore]
GO

CREATE TABLE [dbo].[Categories](
	[CategoryID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NULL
) 
GO

CREATE TABLE [dbo].[Images](
	[ImageID] [int] IDENTITY(1,1) NOT NULL,
	[ProductID] [int] NOT NULL,
	[url] [nvarchar](max) NULL,
)
GO

CREATE TABLE [dbo].[OrderProducts](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[OrderID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[Quantity] [int] NOT NULL
)
GO

CREATE TABLE [dbo].[Orders](
	[OrderID] [int] IDENTITY(1,1) NOT NULL,
	[OrderNumber] [uniqueidentifier] NOT NULL,
	[UserID] [int] NOT NULL,
	[DateOfPurchase] [datetime] NOT NULL,
	[TotalSum] [money] NOT NULL,
)
GO

CREATE TABLE [dbo].[Passwords](
	[UserID] [int] NOT NULL,
	[Password] [binary](64) NULL,
	[Salt] [nvarchar](36) NULL,
)
GO

CREATE TABLE [dbo].[Products](
	[ProductID] [int] IDENTITY(1,1) NOT NULL,
	[CategoryID] [int] NULL,
	[MainImage] [nvarchar](max) NULL,
	[Name] [nvarchar](50) NULL,
	[Description] [nvarchar](500) NULL,
	[Price] [money] NULL,
)
GO

CREATE TABLE [dbo].[Status](
	[StatusID] [int] NOT NULL,
	[Status] [nvarchar](50) NULL,
)
GO

CREATE TABLE [dbo].[UserQuestions](
	[QuestionID] [int] IDENTITY(1,1) NOT NULL,
	[MainThread] [int] NULL,
	[ProductID] [int] NULL,
	[UserID] [int] NULL,
	[Text] [nvarchar](500) NULL,
	[Posted] [datetime] NULL,
)
GO

CREATE TABLE [dbo].[UserReviews](
	[ReviewID] [int] IDENTITY(1,1) NOT NULL,
	[MainThread] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[Text] [nvarchar](250) NOT NULL,
	[Posted] [datetime] NOT NULL,
)
GO

CREATE TABLE [dbo].[Users](
	[UserID] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [nvarchar](15) NULL,
	[FirstName] [nvarchar](15) NULL,
	[LastName] [nvarchar](15) NULL,
	[PhoneNumber] [nvarchar](15) NULL,
	[Email] [nvarchar](320) NULL,
)
GO

ALTER TABLE [dbo].[Users]
ADD PRIMARY KEY ([UserID])
GO

ALTER TABLE [dbo].[Categories]
ADD PRIMARY KEY ([CategoryID])
GO

ALTER TABLE [dbo].[Products]
ADD PRIMARY KEY ([ProductID])
ALTER TABLE [dbo].[Products]
ADD CONSTRAINT FK_Products_Category FOREIGN KEY ([CategoryID]) REFERENCES Categories([CategoryID])
GO

ALTER TABLE [dbo].[Images]
ADD PRIMARY KEY ([ImageID])
GO
ALTER TABLE [dbo].[Images]
ADD CONSTRAINT FK_Images_Products FOREIGN KEY ([ProductID]) REFERENCES Products([ProductID])
GO

ALTER TABLE [dbo].[OrderProducts]
ADD PRIMARY KEY ([ID])
GO

ALTER TABLE [dbo].[Orders]
ADD PRIMARY KEY ([OrderID])
ALTER TABLE [dbo].[Orders]
ADD CONSTRAINT FK_Orders_Users FOREIGN KEY ([UserID]) REFERENCES Users([UserID])
GO

ALTER TABLE [dbo].[Passwords]
ADD PRIMARY KEY ([UserID])
GO

ALTER TABLE [dbo].[Status]
ADD PRIMARY KEY ([StatusID])
GO

ALTER TABLE [dbo].[UserQuestions]
ADD PRIMARY KEY ([QuestionID])
ALTER TABLE [dbo].[UserQuestions]
ADD CONSTRAINT FK_Questions_Product FOREIGN KEY ([ProductID]) REFERENCES Products([ProductID])
ALTER TABLE [dbo].[UserQuestions]
ADD CONSTRAINT FK_Questions_Users FOREIGN KEY ([UserID]) REFERENCES Users([UserID])
GO

ALTER TABLE [dbo].[UserReviews]
ADD PRIMARY KEY ([ReviewID])
ALTER TABLE [dbo].[UserReviews]
ADD CONSTRAINT FK_Reviews_Product FOREIGN KEY ([ProductID]) REFERENCES Products([ProductID])
ALTER TABLE [dbo].[UserReviews]
ADD CONSTRAINT FK_Reviews_Users FOREIGN KEY ([UserID]) REFERENCES Users([UserID])
GO

-----------------------------------
-----------------------------------
-----------------------------------
-----------------------------------

CREATE proc [dbo].[GetProductByName]
@ProductName nvarchar(50)
as
Select * from Products as p where p.Name like + '%'+@ProductName+'%'
GO

create proc [dbo].[InsertQuestions]
@MainThread int,
@ProductID int,
@UserID int,
@Text nvarchar(500)
as
begin
Insert into UserQuestions (MainThread, ProductID, UserID, Text, Posted)
values (@MainThread, @ProductID, @UserID, @Text, GETDATE())
end
GO


create proc [dbo].[InsertReviews]
@MainThread int,
@ProductID int,
@UserID int,
@Text nvarchar(500)
as
begin
Insert into UserReviews (MainThread, ProductID, UserID, Text, Posted)
values (@MainThread, @ProductID, @UserID, @Text, GETDATE())
end
GO

CREATE proc [dbo].[PostOrder] 
@UserName nvarchar(50),
@TotalSum money,
@OrderID int output,
@OrderNumber uniqueidentifier output
as
begin

Declare @UserID int
set @UserID = (select UserID from Users where @UserName = UserName)
insert into Orders(OrderNumber, UserID, DateOfPurchase, TotalSum)
values (NEWID(), @UserID, GETDATE(),@TotalSum)
set @OrderID = @@IDENTITY
set @OrderNumber = (select OrderNumber from Orders where @OrderID = OrderID)
end
GO

CREATE proc [dbo].[PostOrderProducts] 
@OrderID int,
@ProductID int,
@Quantity int
as
begin
insert into OrderProducts(OrderID, ProductID, Quantity)
values (@OrderID, @ProductID, @Quantity)
end

GO
CREATE PROCEDURE [dbo].[RegisterUser]
@UserName nvarchar(15),
@FirstName nvarchar(15),
@LastName nvarchar(15),
@PhoneNumber nvarchar(10),
@Email nvarchar(320),
@Password nvarchar(20)
as

Declare @Salt Uniqueidentifier = newid()

if not exists (
Select u.UserName from Users as u where u.UserName = @UserName 
)
begin
Insert into Users(UserName, FirstName, LastName,PhoneNumber, Email)
values (@UserName, @FirstName, @LastName, @PhoneNumber, @Email)


Insert into Passwords(UserID, Password, Salt)
values(@@IDENTITY, HASHBYTES('SHA2_512', @Password+CAST(@Salt as nvarchar(36))), @Salt)

Select  u.UserName, u.FirstName, u.LastName, u.PhoneNumber, u.Email from Users as u where @UserName = u.UserName
end
GO

create proc [dbo].[RetreiveProductByID]
@ProductID int
as
Select * from Products where ProductID = @ProductID
GO

create proc [dbo].[RetreiveProducts]
as
Select * from Products 
GO

CREATE proc [dbo].[RetrieveBrowseProducts]
@GetNextBrowseProducts int
as
begin
select top 4 * from Products
where ProductID >  @GetNextBrowseProducts
end
GO

create proc [dbo].[RetrieveCategories]
as 
select * from Categories
GO

CREATE proc [dbo].[RetrieveOrderDetails]
@OrderNumber nvarchar(36) 
as
begin

Declare @OrderID int
set @OrderID = (select OrderID from Orders where OrderNumber = @OrderNumber)
Declare @DateOfPurchase datetime 
set @DateOfPurchase = (select DateOfPurchase from Orders where @OrderID = OrderID)
select p.ProductID, p.CategoryID, p.MainImage, p.Name, p.Description, p.Price,o.Quantity, @DateOfPurchase, (select TotalSum from Orders where OrderNumber = @OrderNumber) as TotalSum from Products as p
inner join
OrderProducts as o  on o.ProductID = p.ProductID 
where o.OrderID = @OrderID
end
GO

CREATE proc [dbo].[RetrieveOrders]
@UserName nvarchar(50)

as
begin

Declare @UserID int 
set @UserID = (Select UserID from Users where UserName = @UserName)

Select OrderNumber, DateOfPurchase from Orders  
where UserID = @UserID

end
GO

create proc [dbo].[RetrieveProductImages] 
@ProductID int
as
select url from Images where ProductID = @ProductID
GO

create proc [dbo].[RetrieveProductsByCategory]
@CategoryID int
as

select * from Products as p where p.CategoryID = @CategoryID
GO


CREATE proc [dbo].[RetrieveQuestions]
@ProductID int
as
Select  q.QuestionID, q.MainThread, u.UserName, q.Text from UserQuestions as
q inner join Users as u on q.UserID = u.UserID where q.ProductID = @ProductID
GO

create proc [dbo].[RetrieveReviews]
@ProductID int
as
begin
Select  r.ReviewID, r.MainThread, u.UserName, r.Text from UserReviews as
r inner join Users as u on r.UserID = u.UserID where r.ProductID = @ProductID

end
GO

CREATE proc [dbo].[RetrieveTopPick]
as
select top 5  * from Products order by newid()
GO

CREATE proc [dbo].[UpdateUser]
@Username nvarchar(15),
@PhoneNumber nvarchar(15),
@Email nvarchar(320)

as
begin
Update Users 
set Email = @Email, PhoneNumber = @PhoneNumber
where Username = @Username

select * from Users where UserName = @Username
end
GO

CREATE PROC [dbo].[ValidateUser] 
@UserName nvarchar(20),
@Password nvarchar(20)
as
Select  u.UserName, u.FirstName, u.LastName, u.PhoneNumber, u.Email from Users as u, Passwords as p where u.UserName = @UserName and 
p.Password = HASHBYTES('SHA2_512', @Password + CAST(p.Salt as nvarchar(36)))
GO

-----------------------------------
-----------------------------------
-----------------------------------
-----------------------------------



GO
INSERT [dbo].[Categories] ( [Name]) VALUES (N'Technology')
GO
INSERT [dbo].[Categories] ( [Name]) VALUES (N'Furniture')
GO
INSERT [dbo].[Categories] ( [Name]) VALUES (N'Clothing')
GO
INSERT [dbo].[Categories] ([Name]) VALUES (N'Other')
GO





GO
INSERT [dbo].[Products] (  [CategoryID], [MainImage], [Name], [Description], [Price]) VALUES ( 1, N'https://image.shutterstock.com/image-photo/gaming-pc-rgb-led-lights-600w-1621672105.jpg', N'PC', N'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris semper nec turpis vel volutpat. Vestibulum vestibulum lectus eget orci cursus consectetur. Sed sed tortor dui. Nullam non urna in metus sagittis dapibus vel id velit. Aliquam dictum odio non metus porttitor, vitae ultrices nisi imperdiet. In placerat viverra diam vitae aliquet.', 600.0000)
GO
INSERT [dbo].[Products] (  [CategoryID], [MainImage], [Name], [Description], [Price]) VALUES ( 1, N'https://image.freepik.com/free-photo/close-up-soft-focus-laptop-computer-keyboard_31965-1753.jpg', N'PC Keyboard', N'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris semper nec turpis vel volutpat. Vestibulum vestibulum lectus eget orci cursus consectetur. Sed sed tortor dui. Nullam non urna in metus sagittis dapibus vel id velit. Aliquam dictum odio non metus porttitor, vitae ultrices nisi imperdiet. In placerat viverra diam vitae aliquet.', 20.0000)
GO
INSERT [dbo].[Products] (  [CategoryID], [MainImage], [Name], [Description], [Price]) VALUES ( 2, N'https://image.shutterstock.com/image-photo/front-side-view-modern-black-600w-1640239183.jpg', N'Gaming Chair', N'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris semper nec turpis vel volutpat. Vestibulum vestibulum lectus eget orci cursus consectetur. Sed sed tortor dui. Nullam non urna in metus sagittis dapibus vel id velit. Aliquam dictum odio non metus porttitor, vitae ultrices nisi imperdiet. In placerat viverra diam vitae aliquet.', 250.0000)
GO
INSERT [dbo].[Products] (  [CategoryID], [MainImage], [Name], [Description], [Price]) VALUES ( 2, N'https://image.shutterstock.com/image-photo/wooden-table-dark-blurred-background-600w-1013242189.jpg', N'Table', N'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris semper nec turpis vel volutpat. Vestibulum vestibulum lectus eget orci cursus consectetur. Sed sed tortor dui. Nullam non urna in metus sagittis dapibus vel id velit. Aliquam dictum odio non metus porttitor, vitae ultrices nisi imperdiet. In placerat viverra diam vitae aliquet.', 150.0000)
GO
INSERT [dbo].[Products] (  [CategoryID], [MainImage], [Name], [Description], [Price]) VALUES ( 2, N'https://image.shutterstock.com/image-photo/big-round-mirror-table-jewelry-260nw-1443950414.jpg', N'Mirror', N'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris semper nec turpis vel volutpat. Vestibulum vestibulum lectus eget orci cursus consectetur. Sed sed tortor dui. Nullam non urna in metus sagittis dapibus vel id velit. Aliquam dictum odio non metus porttitor, vitae ultrices nisi imperdiet. In placerat viverra diam vitae aliquet.', 75.0000)
GO
INSERT [dbo].[Products] (  [CategoryID], [MainImage], [Name], [Description], [Price]) VALUES ( 2, N'https://image.freepik.com/free-photo/hanging-light-lamp_1339-101493.jpg', N'Lamp', N'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris semper nec turpis vel volutpat. Vestibulum vestibulum lectus eget orci cursus consectetur. Sed sed tortor dui. Nullam non urna in metus sagittis dapibus vel id velit. Aliquam dictum odio non metus porttitor, vitae ultrices nisi imperdiet. In placerat viverra diam vitae aliquet.', 350.0000)
GO
INSERT [dbo].[Products] (  [CategoryID], [MainImage], [Name], [Description], [Price]) VALUES ( 3, N'https://image.shutterstock.com/image-photo/woman-man-body-black-polo-260nw-1664388946.jpg', N'T-Shirt', N'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris semper nec turpis vel volutpat. Vestibulum vestibulum lectus eget orci cursus consectetur. Sed sed tortor dui. Nullam non urna in metus sagittis dapibus vel id velit. Aliquam dictum odio non metus porttitor, vitae ultrices nisi imperdiet. In placerat viverra diam vitae aliquet.', 50.0000)
GO
INSERT [dbo].[Products] (  [CategoryID], [MainImage], [Name], [Description], [Price]) VALUES ( 3, N'https://image.shutterstock.com/image-photo/woman-red-pants-shirt-600w-588567899.jpg', N'Pants', N'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris semper nec turpis vel volutpat. Vestibulum vestibulum lectus eget orci cursus consectetur. Sed sed tortor dui. Nullam non urna in metus sagittis dapibus vel id velit. Aliquam dictum odio non metus porttitor, vitae ultrices nisi imperdiet. In placerat viverra diam vitae aliquet.', 25.0000)
GO
INSERT [dbo].[Products] (  [CategoryID], [MainImage], [Name], [Description], [Price]) VALUES ( 3, N'https://image.shutterstock.com/image-photo/vintage-red-shoes-on-white-600w-92008067.jpg', N'Shoes', N'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris semper nec turpis vel volutpat. Vestibulum vestibulum lectus eget orci cursus consectetur. Sed sed tortor dui. Nullam non urna in metus sagittis dapibus vel id velit. Aliquam dictum odio non metus porttitor, vitae ultrices nisi imperdiet. In placerat viverra diam vitae aliquet.', 45.0000)
GO
INSERT [dbo].[Products] (  [CategoryID], [MainImage], [Name], [Description], [Price]) VALUES (4, N'https://image.shutterstock.com/image-illustration/glass-water-isolated-illustration-260nw-185433806.jpg', N'Drinking Glass', N'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris semper nec turpis vel volutpat. Vestibulum vestibulum lectus eget orci cursus consectetur. Sed sed tortor dui. Nullam non urna in metus sagittis dapibus vel id velit. Aliquam dictum odio non metus porttitor, vitae ultrices nisi imperdiet. In placerat viverra diam vitae aliquet.', 15.0000)
GO
INSERT [dbo].[Products] (  [CategoryID], [MainImage], [Name], [Description], [Price]) VALUES ( 4, N'https://image.shutterstock.com/image-photo/urban-biker-260nw-98638544.jpg', N'Bicycle', N'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris semper nec turpis vel volutpat. Vestibulum vestibulum lectus eget orci cursus consectetur. Sed sed tortor dui. Nullam non urna in metus sagittis dapibus vel id velit. Aliquam dictum odio non metus porttitor, vitae ultrices nisi imperdiet. In placerat viverra diam vitae aliquet.', 270.0000)
GO

INSERT [dbo].[Images] (   [ProductID], [url]) VALUES ( 1, N'https://image.shutterstock.com/image-photo/gaming-pc-rgb-led-lights-600w-1618645462.jpg')
GO
INSERT [dbo].[Images] (  [ProductID],  [url]) VALUES ( 1, N'https://image.shutterstock.com/image-photo/gaming-pc-desk-pictures-shows-260nw-1799094649.jpg')
GO
INSERT [dbo].[Images] (  [ProductID],  [url]) VALUES ( 1, N'https://image.shutterstock.com/image-photo/powerful-personal-computer-gamer-rig-260nw-1430140061.jpg')
GO
INSERT [dbo].[Images] (  [ProductID],  [url]) VALUES ( 1, N'https://image.shutterstock.com/image-photo/powerful-personal-computer-gamer-rig-260nw-1430140061.jpg')
GO
INSERT [dbo].[Images] (  [ProductID],  [url]) VALUES ( 1, N'https://image.shutterstock.com/image-photo/powerful-personal-computer-gamer-rig-600w-1430140058.jpg')
GO
INSERT [dbo].[Images] (  [ProductID],  [url]) VALUES ( 2, N'https://image.freepik.com/free-vector/exquisite-keyboard_72884.jpg')
GO
INSERT [dbo].[Images] (  [ProductID],  [url]) VALUES ( 2, N'https://image.freepik.com/free-photo/work-space-set-internet-keyboard_1172-261.jpg')
GO
INSERT [dbo].[Images] (  [ProductID],  [url]) VALUES ( 3, N'https://image.shutterstock.com/image-photo/office-chair-on-white-background-260nw-1246650910.jpg')
GO
INSERT [dbo].[Images] (  [ProductID],  [url]) VALUES ( 3, N'https://image.shutterstock.com/image-photo/office-chair-on-white-background-260nw-716912695.jpg')
GO
INSERT [dbo].[Images] ( [ProductID],   [url]) VALUES ( 3, N'https://image.shutterstock.com/image-photo/office-chair-on-white-background-260nw-1227675490.jpg')
GO
INSERT [dbo].[Images] (  [ProductID],  [url]) VALUES ( 4, N'https://image.shutterstock.com/image-photo/brown-wooden-round-dining-table-260nw-588358085.jpg')
GO
INSERT [dbo].[Images] (  [ProductID],  [url]) VALUES ( 4, N'https://image.shutterstock.com/image-photo/three-legged-table-known-cricket-600w-352442909.jpg')
GO
INSERT [dbo].[Images] ( [ProductID],   [url]) VALUES ( 5, N'https://image.shutterstock.com/image-photo/sunny-boho-interiors-apartment-mirror-260nw-1483205495.jpg')
GO
INSERT [dbo].[Images] (  [ProductID],  [url]) VALUES ( 5, N'https://image.shutterstock.com/image-photo/body-care-cosmetics-accessories-near-600w-1607161978.jpg')
GO
INSERT [dbo].[Images] ( [ProductID],   [url]) VALUES ( 5, N'https://image.shutterstock.com/image-illustration/double-sink-on-wooden-countertop-260nw-1187723713.jpg')
GO
INSERT [dbo].[Images] ( [ProductID],   [url]) VALUES ( 5, N'https://image.shutterstock.com/image-illustration/double-sink-on-wooden-countertop-260nw-1181309428.jpg')
GO
INSERT [dbo].[Images] ( [ProductID],  [url]) VALUES ( 6, N'https://image.freepik.com/free-photo/light-lamp-decoration-interior-room_74190-11946.jpg')
GO
INSERT [dbo].[Images] (  [ProductID],  [url]) VALUES ( 6, N'https://image.freepik.com/free-photo/often-inclusion-chandeliers-with-crystals-fabric-lampshade-ceiling_156139-977.jpg')
GO
INSERT [dbo].[Images] (  [ProductID],  [url]) VALUES ( 6, N'https://image.freepik.com/free-photo/rustic-chandelier-made-bulbs-ropes-dining-table-vintage-kitchen_181624-9173.jpg')
GO
INSERT [dbo].[Images] (  [ProductID],  [url]) VALUES ( 6, N'https://image.freepik.com/free-photo/interior-living-room_252025-3989.jpg')
GO
INSERT [dbo].[Images] (  [ProductID],  [url]) VALUES ( 7, N'https://image.shutterstock.com/image-photo/young-male-blank-black-tshirt-260nw-776178196.jpg')
GO
INSERT [dbo].[Images] (  [ProductID],  [url]) VALUES ( 7, N'https://image.shutterstock.com/image-photo/young-male-blank-gray-tshirt-260nw-763234405.jpg')
GO
INSERT [dbo].[Images] (  [ProductID],  [url]) VALUES ( 7, N'https://image.shutterstock.com/image-photo/khaki-t-shirt-on-young-260nw-184897586.jpg')
GO
INSERT [dbo].[Images] (  [ProductID],  [url]) VALUES ( 8, N'https://image.shutterstock.com/image-photo/portrait-beautiful-asian-woman-260nw-94139164.jpg')
GO
INSERT [dbo].[Images] (  [ProductID],  [url]) VALUES ( 8, N'https://image.shutterstock.com/image-photo/red-leather-pants-high-heel-260nw-791256112.jpg')
GO
INSERT [dbo].[Images] (  [ProductID],  [url]) VALUES ( 8, N'https://image.shutterstock.com/image-photo/hipster-girl-wearing-blank-gray-260nw-602669993.jpg')
GO
INSERT [dbo].[Images] (  [ProductID],  [url]) VALUES ( 9, N'https://image.shutterstock.com/image-photo/red-sneakers-on-isolated-white-260nw-1447518617.jpg')
GO
INSERT [dbo].[Images] ( [ProductID],   [url]) VALUES (9, N'https://image.shutterstock.com/image-photo/puebla-mexico-july-15-2019-260nw-1451826320.jpg')
GO
INSERT [dbo].[Images] (  [ProductID],  [url]) VALUES ( 9, N'https://image.shutterstock.com/image-photo/new-unbranded-running-shoe-sneaker-260nw-185621117.jpg')
GO
INSERT [dbo].[Images] (  [ProductID],  [url]) VALUES ( 10, N'https://image.shutterstock.com/image-photo/glass-fresh-clear-water-600w-28964737.jpg')
GO
INSERT [dbo].[Images] (  [ProductID],  [url]) VALUES ( 10, N'https://image.shutterstock.com/image-photo/pouring-bubbling-water-into-glass-260nw-405405601.jpg')
GO
INSERT [dbo].[Images] ( [ProductID],   [url]) VALUES (11, N'https://image.shutterstock.com/image-photo/woman-bicycle-walks-city-260nw-153656267.jpg')
GO
INSERT [dbo].[Images] (  [ProductID],  [url]) VALUES ( 11, N'https://image.shutterstock.com/image-photo/old-bicycle-stands-parked-near-260nw-1219231864.jpg')
GO
INSERT [dbo].[Images] ( [ProductID],   [url]) VALUES (11, N'https://image.shutterstock.com/image-photo/locked-black-bicycle-parked-on-600w-1458007466.jpg')
GO

INSERT [dbo].[Users] ( [UserName], [FirstName], [LastName], [PhoneNumber], [Email]) VALUES (N'admin', N'Lorem', N'Ipsum', N'+381 61 1234567', N'lorem@ipsum.com')
GO

exec InsertQuestions 0, 1, 1,'This is my first question of this product'
exec InsertQuestions 0, 1, 1,'This is my second question of this product'
exec InsertQuestions 0, 1, 1,'This is my third question of this product'
exec InsertQuestions 0, 1, 1,'This is my fourth question of this product'
exec InsertQuestions 0, 1, 1,'This is my fifth question of this product'
exec InsertQuestions 0, 1, 1,'This is my sixth question of this product'
exec InsertQuestions 0, 1, 1,'This is my seventh question of this product'
exec InsertQuestions 0, 1, 1,'This is my eigth question of this product'
exec InsertQuestions 0, 1, 1,'This is my nineth question of this product'
exec InsertQuestions 0, 1, 1,'This is my tenth question of this product'
exec InsertQuestions 0, 1, 1,'This is my elevnth question of this product'
exec InsertQuestions 0, 1, 1,'This is my twelfth question of this product'
exec InsertQuestions 0, 1, 1,'This is my thirteenth question of this product'
exec InsertQuestions 0, 1, 1,'This is my fourteenth question of this product'
exec InsertQuestions 0, 1, 1,'This is my fifteenth question of this product'
GO
exec InsertQuestions 0, 2, 1,'This is my first question of this product'
exec InsertQuestions 0, 2, 1,'This is my second question of this product'
exec InsertQuestions 0, 2, 1,'This is my third question of this product'
exec InsertQuestions 0, 2, 1,'This is my fourth question of this product'
exec InsertQuestions 0, 2, 1,'This is my fifth question of this product'
exec InsertQuestions 0, 2, 1,'This is my sixth question of this product'
exec InsertQuestions 0, 2, 1,'This is my seventh question of this product'
exec InsertQuestions 0, 2, 1,'This is my eigth question of this product'
exec InsertQuestions 0, 2, 1,'This is my nineth question of this product'
exec InsertQuestions 0, 2, 1,'This is my tenth question of this product'
exec InsertQuestions 0, 2, 1,'This is my elevnth question of this product'
exec InsertQuestions 0, 2, 1,'This is my twelfth question of this product'
exec InsertQuestions 0, 2, 1,'This is my thirteenth question of this product'
exec InsertQuestions 0, 2, 1,'This is my fourteenth question of this product'
exec InsertQuestions 0, 2, 1,'This is my fifteenth question of this product'
GO

exec InsertQuestions 0, 3, 1,'This is my first question of this product'
exec InsertQuestions 0, 3, 1,'This is my second question of this product'
exec InsertQuestions 0, 3, 1,'This is my third question of this product'
exec InsertQuestions 0, 3, 1,'This is my fourth question of this product'
exec InsertQuestions 0, 3, 1,'This is my fifth question of this product'
exec InsertQuestions 0, 3, 1,'This is my sixth question of this product'
exec InsertQuestions 0, 3, 1,'This is my seventh question of this product'
exec InsertQuestions 0, 3, 1,'This is my eigth question of this product'
exec InsertQuestions 0, 3, 1,'This is my nineth question of this product'
exec InsertQuestions 0, 3, 1,'This is my tenth question of this product'
exec InsertQuestions 0, 3, 1,'This is my elevnth question of this product'
exec InsertQuestions 0, 3, 1,'This is my twelfth question of this product'
exec InsertQuestions 0, 3, 1,'This is my thirteenth question of this product'
exec InsertQuestions 0, 3, 1,'This is my fourteenth question of this product'
exec InsertQuestions 0, 3, 1,'This is my fifteenth question of this product'
GO
exec InsertQuestions 0, 4, 1,'This is my first question of this product'
exec InsertQuestions 0, 4, 1,'This is my second question of this product'
exec InsertQuestions 0, 4, 1,'This is my third question of this product'
exec InsertQuestions 0, 4, 1,'This is my fourth question of this product'
exec InsertQuestions 0, 4, 1,'This is my fifth question of this product'
exec InsertQuestions 0, 4, 1,'This is my sixth question of this product'
exec InsertQuestions 0, 4, 1,'This is my seventh question of this product'
exec InsertQuestions 0, 4, 1,'This is my eigth question of this product'
exec InsertQuestions 0, 4, 1,'This is my nineth question of this product'
exec InsertQuestions 0, 4, 1,'This is my tenth question of this product'
exec InsertQuestions 0, 4, 1,'This is my elevnth question of this product'
exec InsertQuestions 0, 4, 1,'This is my twelfth question of this product'
exec InsertQuestions 0, 4, 1,'This is my thirteenth question of this product'
exec InsertQuestions 0, 4, 1,'This is my fourteenth question of this product'
exec InsertQuestions 0, 4, 1,'This is my fifteenth question of this product'
GO

exec InsertQuestions 0, 5, 1,'This is my first question of this product'
exec InsertQuestions 0, 5, 1,'This is my second question of this product'
exec InsertQuestions 0, 5, 1,'This is my third question of this product'
exec InsertQuestions 0, 5, 1,'This is my fourth question of this product'
exec InsertQuestions 0, 5, 1,'This is my fifth question of this product'
exec InsertQuestions 0, 5, 1,'This is my sixth question of this product'
exec InsertQuestions 0, 5, 1,'This is my seventh question of this product'
exec InsertQuestions 0, 5, 1,'This is my eigth question of this product'
exec InsertQuestions 0, 5, 1,'This is my nineth question of this product'
exec InsertQuestions 0, 5, 1,'This is my tenth question of this product'
exec InsertQuestions 0, 5, 1,'This is my elevnth question of this product'
exec InsertQuestions 0, 5, 1,'This is my twelfth question of this product'
exec InsertQuestions 0, 5, 1,'This is my thirteenth question of this product'
exec InsertQuestions 0, 5, 1,'This is my fourteenth question of this product'
exec InsertQuestions 0, 5, 1,'This is my fifteenth question of this product'
GO

exec InsertQuestions 0, 6, 1,'This is my first question of this product'
exec InsertQuestions 0, 6, 1,'This is my second question of this product'
exec InsertQuestions 0, 6, 1,'This is my third question of this product'
exec InsertQuestions 0, 6, 1,'This is my fourth question of this product'
exec InsertQuestions 0, 6, 1,'This is my fifth question of this product'
exec InsertQuestions 0, 6, 1,'This is my sixth question of this product'
exec InsertQuestions 0, 6, 1,'This is my seventh question of this product'
exec InsertQuestions 0, 6, 1,'This is my eigth question of this product'
exec InsertQuestions 0, 6, 1,'This is my nineth question of this product'
exec InsertQuestions 0, 6, 1,'This is my tenth question of this product'
exec InsertQuestions 0, 6, 1,'This is my elevnth question of this product'
exec InsertQuestions 0, 6, 1,'This is my twelfth question of this product'
exec InsertQuestions 0, 6, 1,'This is my thirteenth question of this product'
exec InsertQuestions 0, 6, 1,'This is my fourteenth question of this product'
exec InsertQuestions 0, 6, 1,'This is my fifteenth question of this product'
GO

exec InsertQuestions 0, 7, 1,'This is my first question of this product'
exec InsertQuestions 0, 7, 1,'This is my second question of this product'
exec InsertQuestions 0, 7, 1,'This is my third question of this product'
exec InsertQuestions 0, 7, 1,'This is my fourth question of this product'
exec InsertQuestions 0, 7, 1,'This is my fifth question of this product'
exec InsertQuestions 0, 7, 1,'This is my sixth question of this product'
exec InsertQuestions 0, 7, 1,'This is my seventh question of this product'
exec InsertQuestions 0, 7, 1,'This is my eigth question of this product'
exec InsertQuestions 0, 7, 1,'This is my nineth question of this product'
exec InsertQuestions 0, 7, 1,'This is my tenth question of this product'
exec InsertQuestions 0, 7, 1,'This is my elevnth question of this product'
exec InsertQuestions 0, 7, 1,'This is my twelfth question of this product'
exec InsertQuestions 0, 7, 1,'This is my thirteenth question of this product'
exec InsertQuestions 0, 7, 1,'This is my fourteenth question of this product'
exec InsertQuestions 0, 7, 1,'This is my fifteenth question of this product'
GO

exec InsertQuestions 0, 8, 1,'This is my first question of this product'
exec InsertQuestions 0, 8, 1,'This is my second question of this product'
exec InsertQuestions 0, 8, 1,'This is my third question of this product'
exec InsertQuestions 0, 8, 1,'This is my fourth question of this product'
exec InsertQuestions 0, 8, 1,'This is my fifth question of this product'
exec InsertQuestions 0, 8, 1,'This is my sixth question of this product'
exec InsertQuestions 0, 8, 1,'This is my seventh question of this product'
exec InsertQuestions 0, 8, 1,'This is my eigth question of this product'
exec InsertQuestions 0, 8, 1,'This is my nineth question of this product'
exec InsertQuestions 0, 8, 1,'This is my tenth question of this product'
exec InsertQuestions 0, 8, 1,'This is my elevnth question of this product'
exec InsertQuestions 0, 8, 1,'This is my twelfth question of this product'
exec InsertQuestions 0, 8, 1,'This is my thirteenth question of this product'
exec InsertQuestions 0, 8, 1,'This is my fourteenth question of this product'
exec InsertQuestions 0, 8, 1,'This is my fifteenth question of this product'
GO

exec InsertQuestions 0, 9, 1,'This is my first question of this product'
exec InsertQuestions 0, 9, 1,'This is my second question of this product'
exec InsertQuestions 0, 9, 1,'This is my third question of this product'
exec InsertQuestions 0, 9, 1,'This is my fourth question of this product'
exec InsertQuestions 0, 9, 1,'This is my fifth question of this product'
exec InsertQuestions 0, 9, 1,'This is my sixth question of this product'
exec InsertQuestions 0, 9, 1,'This is my seventh question of this product'
exec InsertQuestions 0, 9, 1,'This is my eigth question of this product'
exec InsertQuestions 0, 9, 1,'This is my nineth question of this product'
exec InsertQuestions 0, 9, 1,'This is my tenth question of this product'
exec InsertQuestions 0, 9, 1,'This is my elevnth question of this product'
exec InsertQuestions 0, 9, 1,'This is my twelfth question of this product'
exec InsertQuestions 0, 9, 1,'This is my thirteenth question of this product'
exec InsertQuestions 0, 9, 1,'This is my fourteenth question of this product'
exec InsertQuestions 0, 9, 1,'This is my fifteenth question of this product'
GO

exec InsertQuestions 0, 10, 1,'This is my first question of this product'
exec InsertQuestions 0, 10, 1,'This is my second question of this product'
exec InsertQuestions 0, 10, 1,'This is my third question of this product'
exec InsertQuestions 0, 10, 1,'This is my fourth question of this product'
exec InsertQuestions 0, 10, 1,'This is my fifth question of this product'
exec InsertQuestions 0, 10, 1,'This is my sixth question of this product'
exec InsertQuestions 0, 10, 1,'This is my seventh question of this product'
exec InsertQuestions 0, 10, 1,'This is my eigth question of this product'
exec InsertQuestions 0, 10, 1,'This is my nineth question of this product'
exec InsertQuestions 0, 10, 1,'This is my tenth question of this product'
exec InsertQuestions 0, 10, 1,'This is my elevnth question of this product'
exec InsertQuestions 0, 10, 1,'This is my twelfth question of this product'
exec InsertQuestions 0, 10, 1,'This is my thirteenth question of this product'
exec InsertQuestions 0, 10, 1,'This is my fourteenth question of this product'
exec InsertQuestions 0, 10, 1,'This is my fifteenth question of this product'
GO

exec InsertQuestions 0, 11, 1,'This is my first question of this product'
exec InsertQuestions 0, 11, 1,'This is my second question of this product'
exec InsertQuestions 0, 11, 1,'This is my third question of this product'
exec InsertQuestions 0, 11, 1,'This is my fourth question of this product'
exec InsertQuestions 0, 11, 1,'This is my fifth question of this product'
exec InsertQuestions 0, 11, 1,'This is my sixth question of this product'
exec InsertQuestions 0, 11, 1,'This is my seventh question of this product'
exec InsertQuestions 0, 11, 1,'This is my eigth question of this product'
exec InsertQuestions 0, 11, 1,'This is my nineth question of this product'
exec InsertQuestions 0, 11, 1,'This is my tenth question of this product'
exec InsertQuestions 0, 11, 1,'This is my elevnth question of this product'
exec InsertQuestions 0, 11, 1,'This is my twelfth question of this product'
exec InsertQuestions 0, 11, 1,'This is my thirteenth question of this product'
exec InsertQuestions 0, 11, 1,'This is my fourteenth question of this product'
exec InsertQuestions 0, 11, 1,'This is my fifteenth question of this product'
GO


exec InsertReviews 0, 1, 1,'This is my first review of this product'
exec InsertReviews 0, 1, 1,'This is my second review of this product'
exec InsertReviews 0, 1, 1,'This is my third review of this product'
exec InsertReviews 0, 1, 1,'This is my fourth review of this product'
exec InsertReviews 0, 1, 1,'This is my fifth review of this product'
exec InsertReviews 0, 1, 1,'This is my sixth review of this product'
exec InsertReviews 0, 1, 1,'This is my seventh review of this product'
exec InsertReviews 0, 1, 1,'This is my eigth review of this product'
exec InsertReviews 0, 1, 1,'This is my nineth review of this product'
exec InsertReviews 0, 1, 1,'This is my tenth review of this product'
exec InsertReviews 0, 1, 1,'This is my elevnth review of this product'
exec InsertReviews 0, 1, 1,'This is my twelfth review of this product'
exec InsertReviews 0, 1, 1,'This is my thirteenth review of this product'
exec InsertReviews 0, 1, 1,'This is my fourteenth review of this product'
exec InsertReviews 0, 1, 1,'This is my fifteenth review of this product'
GO


exec InsertReviews 0, 2, 1,'This is my first review of this product'
exec InsertReviews 0, 2, 1,'This is my second review of this product'
exec InsertReviews 0, 2, 1,'This is my third review of this product'
exec InsertReviews 0, 2, 1,'This is my fourth review of this product'
exec InsertReviews 0, 2, 1,'This is my fifth review of this product'
exec InsertReviews 0, 2, 1,'This is my sixth review of this product'
exec InsertReviews 0, 2, 1,'This is my seventh review of this product'
exec InsertReviews 0, 2, 1,'This is my eigth review of this product'
exec InsertReviews 0, 2, 1,'This is my nineth review of this product'
exec InsertReviews 0, 2, 1,'This is my tenth review of this product'
exec InsertReviews 0, 2, 1,'This is my elevnth review of this product'
exec InsertReviews 0, 2, 1,'This is my twelfth review of this product'
exec InsertReviews 0, 2, 1,'This is my thirteenth review of this product'
exec InsertReviews 0, 2, 1,'This is my fourteenth review of this product'
exec InsertReviews 0, 2, 1,'This is my fifteenth review of this product'
GO

exec InsertReviews 0, 3, 1,'This is my first review of this product'
exec InsertReviews 0, 3, 1,'This is my second review of this product'
exec InsertReviews 0, 3, 1,'This is my third review of this product'
exec InsertReviews 0, 3, 1,'This is my fourth review of this product'
exec InsertReviews 0, 3, 1,'This is my fifth review of this product'
exec InsertReviews 0, 3, 1,'This is my sixth review of this product'
exec InsertReviews 0, 3, 1,'This is my seventh review of this product'
exec InsertReviews 0, 3, 1,'This is my eigth review of this product'
exec InsertReviews 0, 3, 1,'This is my nineth review of this product'
exec InsertReviews 0, 3, 1,'This is my tenth review of this product'
exec InsertReviews 0, 3, 1,'This is my elevnth review of this product'
exec InsertReviews 0, 3, 1,'This is my twelfth review of this product'
exec InsertReviews 0, 3, 1,'This is my thirteenth review of this product'
exec InsertReviews 0, 3, 1,'This is my fourteenth review of this product'
exec InsertReviews 0, 3, 1,'This is my fifteenth review of this product'
GO

exec InsertReviews 0, 3, 1,'This is my first review of this product'
exec InsertReviews 0, 3, 1,'This is my second review of this product'
exec InsertReviews 0, 3, 1,'This is my third review of this product'
exec InsertReviews 0, 3, 1,'This is my fourth review of this product'
exec InsertReviews 0, 3, 1,'This is my fifth review of this product'
exec InsertReviews 0, 3, 1,'This is my sixth review of this product'
exec InsertReviews 0, 3, 1,'This is my seventh review of this product'
exec InsertReviews 0, 3, 1,'This is my eigth review of this product'
exec InsertReviews 0, 3, 1,'This is my nineth review of this product'
exec InsertReviews 0, 3, 1,'This is my tenth review of this product'
exec InsertReviews 0, 3, 1,'This is my elevnth review of this product'
exec InsertReviews 0, 3, 1,'This is my twelfth review of this product'
exec InsertReviews 0, 3, 1,'This is my thirteenth review of this product'
exec InsertReviews 0, 3, 1,'This is my fourteenth review of this product'
exec InsertReviews 0, 3, 1,'This is my fifteenth review of this product'
GO


exec InsertReviews 0, 4, 1,'This is my first review of this product'
exec InsertReviews 0, 4, 1,'This is my second review of this product'
exec InsertReviews 0, 4, 1,'This is my third review of this product'
exec InsertReviews 0, 4, 1,'This is my fourth review of this product'
exec InsertReviews 0, 4, 1,'This is my fifth review of this product'
exec InsertReviews 0, 4, 1,'This is my sixth review of this product'
exec InsertReviews 0, 4, 1,'This is my seventh review of this product'
exec InsertReviews 0, 4, 1,'This is my eigth review of this product'
exec InsertReviews 0, 4, 1,'This is my nineth review of this product'
exec InsertReviews 0, 4, 1,'This is my tenth review of this product'
exec InsertReviews 0, 4, 1,'This is my elevnth review of this product'
exec InsertReviews 0, 4, 1,'This is my twelfth review of this product'
exec InsertReviews 0, 4, 1,'This is my thirteenth review of this product'
exec InsertReviews 0, 4, 1,'This is my fourteenth review of this product'
exec InsertReviews 0, 4, 1,'This is my fifteenth review of this product'
GO

exec InsertReviews 0, 5, 1,'This is my first review of this product'
exec InsertReviews 0, 5, 1,'This is my second review of this product'
exec InsertReviews 0, 5, 1,'This is my third review of this product'
exec InsertReviews 0, 5, 1,'This is my fourth review of this product'
exec InsertReviews 0, 5, 1,'This is my fifth review of this product'
exec InsertReviews 0, 5, 1,'This is my sixth review of this product'
exec InsertReviews 0, 5, 1,'This is my seventh review of this product'
exec InsertReviews 0, 5, 1,'This is my eigth review of this product'
exec InsertReviews 0, 5, 1,'This is my nineth review of this product'
exec InsertReviews 0, 5, 1,'This is my tenth review of this product'
exec InsertReviews 0, 5, 1,'This is my elevnth review of this product'
exec InsertReviews 0, 5, 1,'This is my twelfth review of this product'
exec InsertReviews 0, 5, 1,'This is my thirteenth review of this product'
exec InsertReviews 0, 5, 1,'This is my fourteenth review of this product'
exec InsertReviews 0, 5, 1,'This is my fifteenth review of this product'
GO

exec InsertReviews 0, 6, 1,'This is my first review of this product'
exec InsertReviews 0, 6, 1,'This is my second review of this product'
exec InsertReviews 0, 6, 1,'This is my third review of this product'
exec InsertReviews 0, 6, 1,'This is my fourth review of this product'
exec InsertReviews 0, 6, 1,'This is my fifth review of this product'
exec InsertReviews 0, 6, 1,'This is my sixth review of this product'
exec InsertReviews 0, 6, 1,'This is my seventh review of this product'
exec InsertReviews 0, 6, 1,'This is my eigth review of this product'
exec InsertReviews 0, 6, 1,'This is my nineth review of this product'
exec InsertReviews 0, 6, 1,'This is my tenth review of this product'
exec InsertReviews 0, 6, 1,'This is my elevnth review of this product'
exec InsertReviews 0, 6, 1,'This is my twelfth review of this product'
exec InsertReviews 0, 6, 1,'This is my thirteenth review of this product'
exec InsertReviews 0, 6, 1,'This is my fourteenth review of this product'
exec InsertReviews 0, 6, 1,'This is my fifteenth review of this product'
GO


exec InsertReviews 0, 7, 1,'This is my first review of this product'
exec InsertReviews 0, 7, 1,'This is my second review of this product'
exec InsertReviews 0, 7, 1,'This is my third review of this product'
exec InsertReviews 0, 7, 1,'This is my fourth review of this product'
exec InsertReviews 0, 7, 1,'This is my fifth review of this product'
exec InsertReviews 0, 7, 1,'This is my sixth review of this product'
exec InsertReviews 0, 7, 1,'This is my seventh review of this product'
exec InsertReviews 0, 7, 1,'This is my eigth review of this product'
exec InsertReviews 0, 7, 1,'This is my nineth review of this product'
exec InsertReviews 0, 7, 1,'This is my tenth review of this product'
exec InsertReviews 0, 7, 1,'This is my elevnth review of this product'
exec InsertReviews 0, 7, 1,'This is my twelfth review of this product'
exec InsertReviews 0, 7, 1,'This is my thirteenth review of this product'
exec InsertReviews 0, 7, 1,'This is my fourteenth review of this product'
exec InsertReviews 0, 7, 1,'This is my fifteenth review of this product'
GO

exec InsertReviews 0, 8, 1,'This is my first review of this product'
exec InsertReviews 0, 8, 1,'This is my second review of this product'
exec InsertReviews 0, 8, 1,'This is my third review of this product'
exec InsertReviews 0, 8, 1,'This is my fourth review of this product'
exec InsertReviews 0, 8, 1,'This is my fifth review of this product'
exec InsertReviews 0, 8, 1,'This is my sixth review of this product'
exec InsertReviews 0, 8, 1,'This is my seventh review of this product'
exec InsertReviews 0, 8, 1,'This is my eigth review of this product'
exec InsertReviews 0, 8, 1,'This is my nineth review of this product'
exec InsertReviews 0, 8, 1,'This is my tenth review of this product'
exec InsertReviews 0, 8, 1,'This is my elevnth review of this product'
exec InsertReviews 0, 8, 1,'This is my twelfth review of this product'
exec InsertReviews 0, 8, 1,'This is my thirteenth review of this product'
exec InsertReviews 0, 8, 1,'This is my fourteenth review of this product'
exec InsertReviews 0, 8, 1,'This is my fifteenth review of this product'
GO


exec InsertReviews 0, 9, 1,'This is my first review of this product'
exec InsertReviews 0, 9, 1,'This is my second review of this product'
exec InsertReviews 0, 9, 1,'This is my third review of this product'
exec InsertReviews 0, 9, 1,'This is my fourth review of this product'
exec InsertReviews 0, 9, 1,'This is my fifth review of this product'
exec InsertReviews 0, 9, 1,'This is my sixth review of this product'
exec InsertReviews 0, 9, 1,'This is my seventh review of this product'
exec InsertReviews 0, 9, 1,'This is my eigth review of this product'
exec InsertReviews 0, 9, 1,'This is my nineth review of this product'
exec InsertReviews 0, 9, 1,'This is my tenth review of this product'
exec InsertReviews 0, 9, 1,'This is my elevnth review of this product'
exec InsertReviews 0, 9, 1,'This is my twelfth review of this product'
exec InsertReviews 0, 9, 1,'This is my thirteenth review of this product'
exec InsertReviews 0, 9, 1,'This is my fourteenth review of this product'
exec InsertReviews 0, 9, 1,'This is my fifteenth review of this product'
GO

exec InsertReviews 0, 10, 1,'This is my first review of this product'
exec InsertReviews 0, 10, 1,'This is my second review of this product'
exec InsertReviews 0, 10, 1,'This is my third review of this product'
exec InsertReviews 0, 10, 1,'This is my fourth review of this product'
exec InsertReviews 0, 10, 1,'This is my fifth review of this product'
exec InsertReviews 0, 10, 1,'This is my sixth review of this product'
exec InsertReviews 0, 10, 1,'This is my seventh review of this product'
exec InsertReviews 0, 10, 1,'This is my eigth review of this product'
exec InsertReviews 0, 10, 1,'This is my nineth review of this product'
exec InsertReviews 0, 10, 1,'This is my tenth review of this product'
exec InsertReviews 0, 10, 1,'This is my elevnth review of this product'
exec InsertReviews 0, 10, 1,'This is my twelfth review of this product'
exec InsertReviews 0, 10, 1,'This is my thirteenth review of this product'
exec InsertReviews 0, 10, 1,'This is my fourteenth review of this product'
exec InsertReviews 0, 10, 1,'This is my fifteenth review of this product'
GO

exec InsertReviews 0, 11, 1,'This is my first review of this product'
exec InsertReviews 0, 11, 1,'This is my second review of this product'
exec InsertReviews 0, 11, 1,'This is my third review of this product'
exec InsertReviews 0, 11, 1,'This is my fourth review of this product'
exec InsertReviews 0, 11, 1,'This is my fifth review of this product'
exec InsertReviews 0, 11, 1,'This is my sixth review of this product'
exec InsertReviews 0, 11, 1,'This is my seventh review of this product'
exec InsertReviews 0, 11, 1,'This is my eigth review of this product'
exec InsertReviews 0, 11, 1,'This is my nineth review of this product'
exec InsertReviews 0, 11, 1,'This is my tenth review of this product'
exec InsertReviews 0, 11, 1,'This is my elevnth review of this product'
exec InsertReviews 0, 11, 1,'This is my twelfth review of this product'
exec InsertReviews 0, 11, 1,'This is my thirteenth review of this product'
exec InsertReviews 0, 11, 1,'This is my fourteenth review of this product'
exec InsertReviews 0, 11, 1,'This is my fifteenth review of this product'
GO