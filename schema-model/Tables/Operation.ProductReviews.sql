CREATE TABLE [Operation].[ProductReviews]
(
[ReviewID] [int] NOT NULL IDENTITY(1, 1),
[ProductID] [int] NOT NULL,
[CustomerID] [nchar] (5) NOT NULL,
[Rating] [int] NOT NULL,
[ReviewTitle] [nvarchar] (100) NULL,
[ReviewText] [nvarchar] (1000) NULL,
[ReviewDate] [datetime] NOT NULL CONSTRAINT [DF__ProductRe__Revie__0E6E26BF] DEFAULT (getdate()),
[IsVerifiedPurchase] [bit] NOT NULL CONSTRAINT [DF__ProductRe__IsVer__0F624AF8] DEFAULT ((0))
)
GO
ALTER TABLE [Operation].[ProductReviews] ADD CONSTRAINT [CK_ProductReviews_Rating] CHECK (([Rating]>=(1) AND [Rating]<=(5)))
GO
ALTER TABLE [Operation].[ProductReviews] ADD CONSTRAINT [PK_ProductReviews] PRIMARY KEY CLUSTERED ([ReviewID])
GO
ALTER TABLE [Operation].[ProductReviews] ADD CONSTRAINT [FK_ProductReviews_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [Sales].[Customers] ([CustomerID])
GO
ALTER TABLE [Operation].[ProductReviews] ADD CONSTRAINT [FK_ProductReviews_Products] FOREIGN KEY ([ProductID]) REFERENCES [Operation].[Products] ([ProductID])
GO
