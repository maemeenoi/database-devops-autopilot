SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Dropping foreign keys from [Sales].[WishlistItems]'
GO
ALTER TABLE [Sales].[WishlistItems] DROP CONSTRAINT [FK_WishlistItems_Wishlists]
GO
ALTER TABLE [Sales].[WishlistItems] DROP CONSTRAINT [FK_WishlistItems_Products]
GO
PRINT N'Dropping foreign keys from [Sales].[CustomerWishlists]'
GO
ALTER TABLE [Sales].[CustomerWishlists] DROP CONSTRAINT [FK_CustomerWishlists_Customers]
GO
PRINT N'Dropping constraints from [Sales].[WishlistItems]'
GO
ALTER TABLE [Sales].[WishlistItems] DROP CONSTRAINT [CK_WishlistItems_Priority]
GO
PRINT N'Dropping constraints from [Sales].[CustomerWishlists]'
GO
ALTER TABLE [Sales].[CustomerWishlists] DROP CONSTRAINT [PK_CustomerWishlists]
GO
PRINT N'Dropping constraints from [Sales].[WishlistItems]'
GO
ALTER TABLE [Sales].[WishlistItems] DROP CONSTRAINT [PK_WishlistItems]
GO
PRINT N'Dropping constraints from [Operation].[InventoryAudit]'
GO
ALTER TABLE [Operation].[InventoryAudit] DROP CONSTRAINT [DF__Inventory__Chang__151B244E]
GO
PRINT N'Dropping constraints from [Operation].[ProductReviews]'
GO
ALTER TABLE [Operation].[ProductReviews] DROP CONSTRAINT [DF__ProductRe__Revie__0E6E26BF]
GO
PRINT N'Dropping constraints from [Operation].[ProductReviews]'
GO
ALTER TABLE [Operation].[ProductReviews] DROP CONSTRAINT [DF__ProductRe__IsVer__0F624AF8]
GO
PRINT N'Dropping constraints from [Sales].[CustomerLoyalty]'
GO
ALTER TABLE [Sales].[CustomerLoyalty] DROP CONSTRAINT [DF__CustomerL__Total__08B54D69]
GO
PRINT N'Dropping constraints from [Sales].[CustomerLoyalty]'
GO
ALTER TABLE [Sales].[CustomerLoyalty] DROP CONSTRAINT [DF__CustomerL__Loyal__09A971A2]
GO
PRINT N'Dropping constraints from [Sales].[CustomerLoyalty]'
GO
ALTER TABLE [Sales].[CustomerLoyalty] DROP CONSTRAINT [DF__CustomerL__JoinD__0A9D95DB]
GO
PRINT N'Dropping constraints from [Sales].[CustomerWishlists]'
GO
ALTER TABLE [Sales].[CustomerWishlists] DROP CONSTRAINT [DF__CustomerW__Wishl__18EBB532]
GO
PRINT N'Dropping constraints from [Sales].[CustomerWishlists]'
GO
ALTER TABLE [Sales].[CustomerWishlists] DROP CONSTRAINT [DF__CustomerW__Creat__19DFD96B]
GO
PRINT N'Dropping constraints from [Sales].[CustomerWishlists]'
GO
ALTER TABLE [Sales].[CustomerWishlists] DROP CONSTRAINT [DF__CustomerW__IsAct__1AD3FDA4]
GO
PRINT N'Dropping constraints from [Sales].[WishlistItems]'
GO
ALTER TABLE [Sales].[WishlistItems] DROP CONSTRAINT [DF__WishlistI__Added__1EA48E88]
GO
PRINT N'Dropping constraints from [Sales].[WishlistItems]'
GO
ALTER TABLE [Sales].[WishlistItems] DROP CONSTRAINT [DF__WishlistI__Prior__1F98B2C1]
GO
PRINT N'Dropping [Sales].[CustomerWishlistAnalytics]'
GO
DROP VIEW [Sales].[CustomerWishlistAnalytics]
GO
PRINT N'Dropping [Sales].[WishlistItems]'
GO
DROP TABLE [Sales].[WishlistItems]
GO
PRINT N'Dropping [Sales].[CustomerWishlists]'
GO
DROP TABLE [Sales].[CustomerWishlists]
GO
PRINT N'Adding constraints to [Operation].[InventoryAudit]'
GO
ALTER TABLE [Operation].[InventoryAudit] ADD CONSTRAINT [DF__Inventory__Chang__3B0BC30C] DEFAULT (getdate()) FOR [ChangeDate]
GO
PRINT N'Adding constraints to [Operation].[ProductReviews]'
GO
ALTER TABLE [Operation].[ProductReviews] ADD CONSTRAINT [DF__ProductRe__Revie__345EC57D] DEFAULT (getdate()) FOR [ReviewDate]
GO
ALTER TABLE [Operation].[ProductReviews] ADD CONSTRAINT [DF__ProductRe__IsVer__3552E9B6] DEFAULT ((0)) FOR [IsVerifiedPurchase]
GO
PRINT N'Adding constraints to [Sales].[CustomerLoyalty]'
GO
ALTER TABLE [Sales].[CustomerLoyalty] ADD CONSTRAINT [DF__CustomerL__Total__2EA5EC27] DEFAULT ((0)) FOR [TotalPoints]
GO
ALTER TABLE [Sales].[CustomerLoyalty] ADD CONSTRAINT [DF__CustomerL__Loyal__2F9A1060] DEFAULT ('Bronze') FOR [LoyaltyLevel]
GO
ALTER TABLE [Sales].[CustomerLoyalty] ADD CONSTRAINT [DF__CustomerL__JoinD__308E3499] DEFAULT (getdate()) FOR [JoinDate]
GO

