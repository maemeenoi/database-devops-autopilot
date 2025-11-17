SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
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

