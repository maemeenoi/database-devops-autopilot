SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Dropping constraints from [Operation].[InventoryAudit]'
GO
IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF__Inventory__Chang__3B0BC30C' AND parent_object_id = OBJECT_ID('[Operation].[InventoryAudit]'))
    ALTER TABLE [Operation].[InventoryAudit] DROP CONSTRAINT [DF__Inventory__Chang__3B0BC30C]
GO
PRINT N'Dropping constraints from [Operation].[ProductReviews]'
GO
IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF__ProductRe__Revie__345EC57D' AND parent_object_id = OBJECT_ID('[Operation].[ProductReviews]'))
    ALTER TABLE [Operation].[ProductReviews] DROP CONSTRAINT [DF__ProductRe__Revie__345EC57D]
GO
PRINT N'Dropping constraints from [Operation].[ProductReviews]'
GO
IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF__ProductRe__IsVer__3552E9B6' AND parent_object_id = OBJECT_ID('[Operation].[ProductReviews]'))
    ALTER TABLE [Operation].[ProductReviews] DROP CONSTRAINT [DF__ProductRe__IsVer__3552E9B6]
GO
PRINT N'Dropping constraints from [Sales].[CustomerLoyalty]'
GO
IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF__CustomerL__Total__2EA5EC27' AND parent_object_id = OBJECT_ID('[Sales].[CustomerLoyalty]'))
    ALTER TABLE [Sales].[CustomerLoyalty] DROP CONSTRAINT [DF__CustomerL__Total__2EA5EC27]
GO
PRINT N'Dropping constraints from [Sales].[CustomerLoyalty]'
GO
IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF__CustomerL__Loyal__2F9A1060' AND parent_object_id = OBJECT_ID('[Sales].[CustomerLoyalty]'))
    ALTER TABLE [Sales].[CustomerLoyalty] DROP CONSTRAINT [DF__CustomerL__Loyal__2F9A1060]
GO
PRINT N'Dropping constraints from [Sales].[CustomerLoyalty]'
GO
IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF__CustomerL__JoinD__308E3499' AND parent_object_id = OBJECT_ID('[Sales].[CustomerLoyalty]'))
    ALTER TABLE [Sales].[CustomerLoyalty] DROP CONSTRAINT [DF__CustomerL__JoinD__308E3499]
GO
PRINT N'Creating [Sales].[CustomerWishlists]'
GO
CREATE TABLE [Sales].[CustomerWishlists]
(
[WishlistID] [int] NOT NULL IDENTITY(1, 1),
[CustomerID] [nchar] (5) NOT NULL,
[WishlistName] [nvarchar] (100) NOT NULL CONSTRAINT [DF__CustomerW__Wishl__18EBB532] DEFAULT ('My Wishlist'),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__CustomerW__Creat__19DFD96B] DEFAULT (getdate()),
[IsActive] [bit] NOT NULL CONSTRAINT [DF__CustomerW__IsAct__1AD3FDA4] DEFAULT ((1))
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
[AddedDate] [datetime] NOT NULL CONSTRAINT [DF__WishlistI__Added__1EA48E88] DEFAULT (getdate()),
[Priority] [int] NOT NULL CONSTRAINT [DF__WishlistI__Prior__1F98B2C1] DEFAULT ((3)),
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
ALTER TABLE [Operation].[InventoryAudit] ADD CONSTRAINT [DF__Inventory__Chang__151B244E] DEFAULT (getdate()) FOR [ChangeDate]
GO
PRINT N'Adding constraints to [Operation].[ProductReviews]'
GO
ALTER TABLE [Operation].[ProductReviews] ADD CONSTRAINT [DF__ProductRe__Revie__0E6E26BF] DEFAULT (getdate()) FOR [ReviewDate]
GO
ALTER TABLE [Operation].[ProductReviews] ADD CONSTRAINT [DF__ProductRe__IsVer__0F624AF8] DEFAULT ((0)) FOR [IsVerifiedPurchase]
GO
PRINT N'Adding constraints to [Sales].[CustomerLoyalty]'
GO
ALTER TABLE [Sales].[CustomerLoyalty] ADD CONSTRAINT [DF__CustomerL__Total__08B54D69] DEFAULT ((0)) FOR [TotalPoints]
GO
ALTER TABLE [Sales].[CustomerLoyalty] ADD CONSTRAINT [DF__CustomerL__Loyal__09A971A2] DEFAULT ('Bronze') FOR [LoyaltyLevel]
GO
ALTER TABLE [Sales].[CustomerLoyalty] ADD CONSTRAINT [DF__CustomerL__JoinD__0A9D95DB] DEFAULT (getdate()) FOR [JoinDate]
GO

