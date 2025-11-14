SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Dropping constraints from [Operation].[InventoryAudit] - Safe approach'
GO
-- Drop constraint only if it exists
IF EXISTS(SELECT * FROM sys.default_constraints WHERE parent_object_id = OBJECT_ID('[Operation].[InventoryAudit]') AND name LIKE 'DF__Inventory__Chang%')
BEGIN
    DECLARE @ConstraintName NVARCHAR(200)
    SELECT @ConstraintName = name FROM sys.default_constraints WHERE parent_object_id = OBJECT_ID('[Operation].[InventoryAudit]') AND name LIKE 'DF__Inventory__Chang%'
    EXEC('ALTER TABLE [Operation].[InventoryAudit] DROP CONSTRAINT [' + @ConstraintName + ']')
    PRINT 'Dropped constraint: ' + @ConstraintName
END
GO
PRINT N'Dropping constraints from [Operation].[ProductReviews] - Safe approach'
GO
-- Drop ReviewDate constraint if exists
IF EXISTS(SELECT * FROM sys.default_constraints WHERE parent_object_id = OBJECT_ID('[Operation].[ProductReviews]') AND name LIKE 'DF__ProductRe__Revie%')
BEGIN
    DECLARE @ConstraintName NVARCHAR(200)
    SELECT @ConstraintName = name FROM sys.default_constraints WHERE parent_object_id = OBJECT_ID('[Operation].[ProductReviews]') AND name LIKE 'DF__ProductRe__Revie%'
    EXEC('ALTER TABLE [Operation].[ProductReviews] DROP CONSTRAINT [' + @ConstraintName + ']')
    PRINT 'Dropped constraint: ' + @ConstraintName
END
GO
-- Drop IsVerified constraint if exists
IF EXISTS(SELECT * FROM sys.default_constraints WHERE parent_object_id = OBJECT_ID('[Operation].[ProductReviews]') AND name LIKE 'DF__ProductRe__IsVer%')
BEGIN
    DECLARE @ConstraintName NVARCHAR(200)
    SELECT @ConstraintName = name FROM sys.default_constraints WHERE parent_object_id = OBJECT_ID('[Operation].[ProductReviews]') AND name LIKE 'DF__ProductRe__IsVer%'
    EXEC('ALTER TABLE [Operation].[ProductReviews] DROP CONSTRAINT [' + @ConstraintName + ']')
    PRINT 'Dropped constraint: ' + @ConstraintName
END
GO
PRINT N'Dropping constraints from [Sales].[CustomerLoyalty] - Safe approach'
GO
-- Drop TotalPoints constraint if exists
IF EXISTS(SELECT * FROM sys.default_constraints WHERE parent_object_id = OBJECT_ID('[Sales].[CustomerLoyalty]') AND name LIKE 'DF__CustomerL__Total%')
BEGIN
    DECLARE @ConstraintName NVARCHAR(200)
    SELECT @ConstraintName = name FROM sys.default_constraints WHERE parent_object_id = OBJECT_ID('[Sales].[CustomerLoyalty]') AND name LIKE 'DF__CustomerL__Total%'
    EXEC('ALTER TABLE [Sales].[CustomerLoyalty] DROP CONSTRAINT [' + @ConstraintName + ']')
    PRINT 'Dropped constraint: ' + @ConstraintName
END
GO
-- Drop LoyaltyLevel constraint if exists
IF EXISTS(SELECT * FROM sys.default_constraints WHERE parent_object_id = OBJECT_ID('[Sales].[CustomerLoyalty]') AND name LIKE 'DF__CustomerL__Loyal%')
BEGIN
    DECLARE @ConstraintName NVARCHAR(200)
    SELECT @ConstraintName = name FROM sys.default_constraints WHERE parent_object_id = OBJECT_ID('[Sales].[CustomerLoyalty]') AND name LIKE 'DF__CustomerL__Loyal%'
    EXEC('ALTER TABLE [Sales].[CustomerLoyalty] DROP CONSTRAINT [' + @ConstraintName + ']')
    PRINT 'Dropped constraint: ' + @ConstraintName
END
GO
-- Drop JoinDate constraint if exists
IF EXISTS(SELECT * FROM sys.default_constraints WHERE parent_object_id = OBJECT_ID('[Sales].[CustomerLoyalty]') AND name LIKE 'DF__CustomerL__JoinD%')
BEGIN
    DECLARE @ConstraintName NVARCHAR(200)
    SELECT @ConstraintName = name FROM sys.default_constraints WHERE parent_object_id = OBJECT_ID('[Sales].[CustomerLoyalty]') AND name LIKE 'DF__CustomerL__JoinD%'
    EXEC('ALTER TABLE [Sales].[CustomerLoyalty] DROP CONSTRAINT [' + @ConstraintName + ']')
    PRINT 'Dropped constraint: ' + @ConstraintName
END
GO
PRINT N'Creating [Sales].[CustomerWishlists]'
GO
CREATE TABLE [Sales].[CustomerWishlists]
(
[WishlistID] [int] NOT NULL IDENTITY(1, 1),
[CustomerID] [nchar] (5) NOT NULL,
[WishlistName] [nvarchar] (100) NOT NULL CONSTRAINT [DF__CustomerW__Wishl__2EDAF651] DEFAULT ('My Wishlist'),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__CustomerW__Creat__2FCF1A8A] DEFAULT (getdate()),
[IsActive] [bit] NOT NULL CONSTRAINT [DF__CustomerW__IsAct__30C33EC3] DEFAULT ((1))
)
GO
PRINT N'Creating primary key [PK_CustomerWishlists] on [Sales].[CustomerWishlists]'
GO
ALTER TABLE [Sales].[CustomerWishlists] ADD CONSTRAINT [PK_CustomerWishlists] PRIMARY KEY CLUSTERED ([WishlistID])
GO
PRINT N'Creating [Sales].[WishlistItems]'
GO
CREATE TABLE [Sales].[WishlistItems]
(
[WishlistItemID] [int] NOT NULL IDENTITY(1, 1),
[WishlistID] [int] NOT NULL,
[ProductID] [int] NOT NULL,
[AddedDate] [datetime] NOT NULL CONSTRAINT [DF__WishlistI__Added__3493CFA7] DEFAULT (getdate()),
[Priority] [int] NOT NULL CONSTRAINT [DF__WishlistI__Prior__3587F3E0] DEFAULT ((3)),
[Notes] [nvarchar] (500) NULL
)
GO
PRINT N'Creating primary key [PK_WishlistItems] on [Sales].[WishlistItems]'
GO
ALTER TABLE [Sales].[WishlistItems] ADD CONSTRAINT [PK_WishlistItems] PRIMARY KEY CLUSTERED ([WishlistItemID])
GO
PRINT N'Creating [Sales].[CustomerWishlistAnalytics]'
GO
-- Create a view for wishlist analytics
CREATE VIEW [Sales].[CustomerWishlistAnalytics]
AS
SELECT
    cw.WishlistID,
    cw.CustomerID,
    c.CompanyName,
    cw.WishlistName,
    COUNT(wi.WishlistItemID) as ItemCount,
    AVG(CAST(p.UnitPrice AS FLOAT)) as AvgWishlistValue,
    SUM(p.UnitPrice) as TotalWishlistValue,
    MAX(wi.AddedDate) as LastAddedDate,
    cw.CreatedDate
FROM [Sales].[CustomerWishlists] cw
INNER JOIN [Sales].[Customers] c ON cw.CustomerID = c.CustomerID
LEFT JOIN [Sales].[WishlistItems] wi ON cw.WishlistID = wi.WishlistID
LEFT JOIN [Operation].[Products] p ON wi.ProductID = p.ProductID
WHERE cw.IsActive = 1
GROUP BY cw.WishlistID, cw.CustomerID, c.CompanyName, cw.WishlistName, cw.CreatedDate
GO
PRINT N'Adding constraints to [Sales].[WishlistItems]'
GO
ALTER TABLE [Sales].[WishlistItems] ADD CONSTRAINT [CK_WishlistItems_Priority] CHECK (([Priority]>=(1) AND [Priority]<=(3)))
GO
PRINT N'Adding foreign keys to [Sales].[WishlistItems]'
GO
ALTER TABLE [Sales].[WishlistItems] ADD CONSTRAINT [FK_WishlistItems_Wishlists] FOREIGN KEY ([WishlistID]) REFERENCES [Sales].[CustomerWishlists] ([WishlistID])
GO
ALTER TABLE [Sales].[WishlistItems] ADD CONSTRAINT [FK_WishlistItems_Products] FOREIGN KEY ([ProductID]) REFERENCES [Operation].[Products] ([ProductID])
GO
PRINT N'Adding foreign keys to [Sales].[CustomerWishlists]'
GO
ALTER TABLE [Sales].[CustomerWishlists] ADD CONSTRAINT [FK_CustomerWishlists_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [Sales].[Customers] ([CustomerID])
GO
PRINT N'Adding constraints to [Operation].[InventoryAudit]'
GO
ALTER TABLE [Operation].[InventoryAudit] ADD CONSTRAINT [DF__Inventory__Chang__2B0A656D] DEFAULT (getdate()) FOR [ChangeDate]
GO
PRINT N'Adding constraints to [Operation].[ProductReviews]'
GO
ALTER TABLE [Operation].[ProductReviews] ADD CONSTRAINT [DF__ProductRe__Revie__245D67DE] DEFAULT (getdate()) FOR [ReviewDate]
GO
ALTER TABLE [Operation].[ProductReviews] ADD CONSTRAINT [DF__ProductRe__IsVer__25518C17] DEFAULT ((0)) FOR [IsVerifiedPurchase]
GO
PRINT N'Adding constraints to [Sales].[CustomerLoyalty]'
GO
ALTER TABLE [Sales].[CustomerLoyalty] ADD CONSTRAINT [DF__CustomerL__Total__1EA48E88] DEFAULT ((0)) FOR [TotalPoints]
GO
ALTER TABLE [Sales].[CustomerLoyalty] ADD CONSTRAINT [DF__CustomerL__Loyal__1F98B2C1] DEFAULT ('Bronze') FOR [LoyaltyLevel]
GO
ALTER TABLE [Sales].[CustomerLoyalty] ADD CONSTRAINT [DF__CustomerL__JoinD__208CD6FA] DEFAULT (getdate()) FOR [JoinDate]
GO

