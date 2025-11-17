CREATE TABLE [Operation].[InventoryAudit]
(
[AuditID] [int] NOT NULL IDENTITY(1, 1),
[ProductID] [int] NOT NULL,
[ChangeDate] [datetime] NOT NULL CONSTRAINT [DF__Inventory__Chang__151B244E] DEFAULT (getdate()),
[OldQuantity] [int] NOT NULL,
[NewQuantity] [int] NOT NULL,
[ChangeReason] [nvarchar] (100) NULL,
[ChangedBy] [nvarchar] (50) NULL
)
GO
ALTER TABLE [Operation].[InventoryAudit] ADD CONSTRAINT [PK_InventoryAudit] PRIMARY KEY CLUSTERED ([AuditID])
GO
ALTER TABLE [Operation].[InventoryAudit] ADD CONSTRAINT [FK_InventoryAudit_Products] FOREIGN KEY ([ProductID]) REFERENCES [Operation].[Products] ([ProductID])
GO
