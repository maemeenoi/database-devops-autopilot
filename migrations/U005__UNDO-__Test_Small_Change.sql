SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Dropping constraints from [Operation].[InventoryAudit]'
GO
ALTER TABLE [Operation].[InventoryAudit] DROP CONSTRAINT [DF__Inventory__Chang__61F08603]
GO
PRINT N'Dropping constraints from [Operation].[ProductReviews]'
GO
ALTER TABLE [Operation].[ProductReviews] DROP CONSTRAINT [DF__ProductRe__Revie__5B438874]
GO
PRINT N'Dropping constraints from [Operation].[ProductReviews]'
GO
ALTER TABLE [Operation].[ProductReviews] DROP CONSTRAINT [DF__ProductRe__IsVer__5C37ACAD]
GO
PRINT N'Dropping constraints from [Sales].[CustomerLoyalty]'
GO
ALTER TABLE [Sales].[CustomerLoyalty] DROP CONSTRAINT [DF__CustomerL__Total__558AAF1E]
GO
PRINT N'Dropping constraints from [Sales].[CustomerLoyalty]'
GO
ALTER TABLE [Sales].[CustomerLoyalty] DROP CONSTRAINT [DF__CustomerL__Loyal__567ED357]
GO
PRINT N'Dropping constraints from [Sales].[CustomerLoyalty]'
GO
ALTER TABLE [Sales].[CustomerLoyalty] DROP CONSTRAINT [DF__CustomerL__JoinD__5772F790]
GO
PRINT N'Altering [Sales].[Customers]'
GO
ALTER TABLE [Sales].[Customers] DROP
COLUMN [TestColumn]
GO
PRINT N'Refreshing [Sales].[CustomerOrdersSummary]'
GO
EXEC sp_refreshview N'[Sales].[CustomerOrdersSummary]'
GO
PRINT N'Adding constraints to [Operation].[InventoryAudit]'
GO
ALTER TABLE [Operation].[InventoryAudit] ADD CONSTRAINT [DF__Inventory__Chang__725BF7F6] DEFAULT (getdate()) FOR [ChangeDate]
GO
PRINT N'Adding constraints to [Operation].[ProductReviews]'
GO
ALTER TABLE [Operation].[ProductReviews] ADD CONSTRAINT [DF__ProductRe__Revie__6BAEFA67] DEFAULT (getdate()) FOR [ReviewDate]
GO
ALTER TABLE [Operation].[ProductReviews] ADD CONSTRAINT [DF__ProductRe__IsVer__6CA31EA0] DEFAULT ((0)) FOR [IsVerifiedPurchase]
GO
PRINT N'Adding constraints to [Sales].[CustomerLoyalty]'
GO
ALTER TABLE [Sales].[CustomerLoyalty] ADD CONSTRAINT [DF__CustomerL__Total__65F62111] DEFAULT ((0)) FOR [TotalPoints]
GO
ALTER TABLE [Sales].[CustomerLoyalty] ADD CONSTRAINT [DF__CustomerL__Loyal__66EA454A] DEFAULT ('Bronze') FOR [LoyaltyLevel]
GO
ALTER TABLE [Sales].[CustomerLoyalty] ADD CONSTRAINT [DF__CustomerL__JoinD__67DE6983] DEFAULT (getdate()) FOR [JoinDate]
GO

