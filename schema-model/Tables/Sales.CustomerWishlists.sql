CREATE TABLE [Sales].[CustomerWishlists]
(
[WishlistID] [int] NOT NULL IDENTITY(1, 1),
[CustomerID] [nchar] (5) NOT NULL,
[WishlistName] [nvarchar] (100) NOT NULL CONSTRAINT [DF__CustomerW__Wishl__18EBB532] DEFAULT ('My Wishlist'),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__CustomerW__Creat__19DFD96B] DEFAULT (getdate()),
[IsActive] [bit] NOT NULL CONSTRAINT [DF__CustomerW__IsAct__1AD3FDA4] DEFAULT ((1))
)
GO
ALTER TABLE [Sales].[CustomerWishlists] ADD CONSTRAINT [PK_CustomerWishlists] PRIMARY KEY CLUSTERED ([WishlistID])
GO
ALTER TABLE [Sales].[CustomerWishlists] ADD CONSTRAINT [FK_CustomerWishlists_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [Sales].[Customers] ([CustomerID])
GO
