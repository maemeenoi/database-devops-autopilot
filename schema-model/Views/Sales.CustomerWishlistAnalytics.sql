SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
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
