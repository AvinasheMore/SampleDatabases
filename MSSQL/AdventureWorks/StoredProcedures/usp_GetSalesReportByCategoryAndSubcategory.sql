-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Avinash More
-- Create date: 01 Jan 2025
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_GetSalesReportByCategoryAndSubcategory 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Step 1: Aggregate sales data by Product Subcategory
	WITH CategorySales AS (
		SELECT 
			PPC.ProductCategoryID as  ParentProductCategoryID,
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
			SS.ProductCategoryID,
			SS.ParentCategoryName,
			SS.CategoryName,
			SS.CategorySalesAmount,
			CS.ParentCategorySalesAmount,
			(SS.CategorySalesAmount / CS.ParentCategorySalesAmount) * 100 AS CategoryContributionPercentage
		FROM categorySales SS
		INNER JOIN ParentCategorySales CS 
		ON SS.ParentProductCategoryID = CS.ParentProductCategoryID
	)

	-- Step 4: Select the final report data
	SELECT 
		ParentCategoryName,
		CategoryName,
		ParentCategorySalesAmount,
		CategorySalesAmount,
		CategoryContributionPercentage
	FROM 
		FinalReport
	ORDER BY 
		ParentCategoryName ,CategoryName;
    
END
GO
