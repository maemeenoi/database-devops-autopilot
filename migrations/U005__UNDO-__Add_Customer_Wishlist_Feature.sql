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

