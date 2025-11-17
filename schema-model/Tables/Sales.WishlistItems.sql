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
ALTER TABLE [Sales].[WishlistItems] ADD CONSTRAINT [CK_WishlistItems_Priority] CHECK (([Priority]>=(1) AND [Priority]<=(3)))
GO
ALTER TABLE [Sales].[WishlistItems] ADD CONSTRAINT [PK_WishlistItems] PRIMARY KEY CLUSTERED ([WishlistItemID])
GO
ALTER TABLE [Sales].[WishlistItems] ADD CONSTRAINT [FK_WishlistItems_Products] FOREIGN KEY ([ProductID]) REFERENCES [Operation].[Products] ([ProductID])
GO
ALTER TABLE [Sales].[WishlistItems] ADD CONSTRAINT [FK_WishlistItems_Wishlists] FOREIGN KEY ([WishlistID]) REFERENCES [Sales].[CustomerWishlists] ([WishlistID])
GO
