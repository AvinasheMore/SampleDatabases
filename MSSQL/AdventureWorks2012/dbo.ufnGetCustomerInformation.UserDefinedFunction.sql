USE [AdventureWorksLT2012]
GO
/****** Object:  UserDefinedFunction [dbo].[ufnGetCustomerInformation]    Script Date: 1/28/2025 1:08:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[ufnGetCustomerInformation](@CustomerID int)
RETURNS TABLE 
AS 
-- Returns the CustomerID, first name, and last name for the specified customer.
RETURN (
    SELECT 
        CustomerID, 
        FirstName, 
        LastName
    FROM [SalesLT].[Customer] 
    WHERE [CustomerID] = @CustomerID
);
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Input parameter for the table value function ufnGetCustomerInformation. Enter a valid CustomerID from the Sales.Customer table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'ufnGetCustomerInformation', @level2type=N'PARAMETER',@level2name=N'@CustomerID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table value function returning the customer ID, first name, and last name for a given customer.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'FUNCTION',@level1name=N'ufnGetCustomerInformation'
GO
