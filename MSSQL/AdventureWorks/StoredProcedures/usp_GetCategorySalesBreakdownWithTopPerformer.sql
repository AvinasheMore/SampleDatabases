SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Avinash More
-- Create date: 01 Jan 2025
-- Description:	Parent Category breakdown of sales data with a focus on the top-performing category.
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[usp_GetCategorySalesBreakdownWithTopPerformer] 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Step 1: Aggregate sales data by Product Subcategory
WITH CategorySales AS (
    SELECT 
        PPC.ProductCategoryID AS ParentProductCategoryID,
        PPC.Name AS ParentCategoryName,
        PC.ProductCategoryID,
        PC.Name AS CategoryName,
        SUM(SOD.LineTotal) AS CategorySalesAmount
    FROM SalesLT.SalesOrderDetail SOD
    INNER JOIN SalesLT.Product P 
        ON SOD.ProductID = P.ProductID
    INNER JOIN SalesLT.ProductCategory PC 
        ON P.ProductCategoryID = PC.ProductCategoryID
    INNER JOIN SalesLT.ProductCategory PPC 
        ON PC.ParentProductCategoryID = PPC.ProductCategoryID   
    GROUP BY PC.ProductCategoryID, PC.Name, PPC.ProductCategoryID, PPC.Name
),

-- Step 2: Aggregate sales data by Product Category
ParentCategorySales AS (
    SELECT 
        ParentProductCategoryID,
        ParentCategoryName,
        SUM(CategorySalesAmount) AS ParentCategorySalesAmount
    FROM CategorySales
    GROUP BY ParentProductCategoryID, ParentCategoryName
),

-- Step 3: Calculate the percentage contribution of each subcategory to its parent category
FinalReport AS (
    SELECT 
        CS.ProductCategoryID,
        CS.ParentCategoryName,
        CS.CategoryName,
        CS.CategorySalesAmount,
        PCS.ParentCategorySalesAmount,
        (CS.CategorySalesAmount / PCS.ParentCategorySalesAmount) * 100 AS CategoryContributionPercentage,
        -- Add a row number to identify the top subcategory within each parent category
        ROW_NUMBER() OVER (
            PARTITION BY CS.ParentProductCategoryID 
            ORDER BY CS.CategorySalesAmount DESC
        ) AS SubcategoryRank
    FROM CategorySales CS
    INNER JOIN ParentCategorySales PCS 
        ON CS.ParentProductCategoryID = PCS.ParentProductCategoryID
)

-- Step 4: Select the final report data
SELECT 
    ParentCategoryName,
    ParentCategorySalesAmount,
    CategoryName,    
    CategorySalesAmount,
    CategoryContributionPercentage  
FROM 
    FinalReport
WHERE SubcategoryRank = 1;
    
END
GO
