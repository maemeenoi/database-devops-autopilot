CREATE TABLE [Sales].[CustomerLoyalty]
(
[CustomerID] [nchar] (5) NOT NULL,
[TotalPoints] [int] NOT NULL CONSTRAINT [DF__CustomerL__Total__08B54D69] DEFAULT ((0)),
[LoyaltyLevel] [nvarchar] (20) NOT NULL CONSTRAINT [DF__CustomerL__Loyal__09A971A2] DEFAULT ('Bronze'),
[JoinDate] [datetime] NOT NULL CONSTRAINT [DF__CustomerL__JoinD__0A9D95DB] DEFAULT (getdate()),
[LastPointUpdate] [datetime] NULL
)
GO
ALTER TABLE [Sales].[CustomerLoyalty] ADD CONSTRAINT [PK_CustomerLoyalty] PRIMARY KEY CLUSTERED ([CustomerID])
GO
ALTER TABLE [Sales].[CustomerLoyalty] ADD CONSTRAINT [FK_CustomerLoyalty_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [Sales].[Customers] ([CustomerID])
GO
