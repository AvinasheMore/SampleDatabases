USE [AdventureWorksLT2012]
GO
/****** Object:  Schema [SalesLT]    Script Date: 1/28/2025 1:08:42 PM ******/
CREATE SCHEMA [SalesLT]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains objects related to products, customers, sales orders, and sales territories.' , @level0type=N'SCHEMA',@level0name=N'SalesLT'
GO
