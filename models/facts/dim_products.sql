SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;
DECLARE @LastUpdated DATETIME = ?

SELECT 

	COALESCE(pci.ProductColourID, pc.ProdColourID, '') AS 'ProductColourID',
	COALESCE(pci.ProductCode, pc.Product_Code COLLATE DATABASE_DEFAULT, '')  AS 'ProductCode',
	COALESCE(pci.ProductCodeWithoutSuffix, LEFT(pc.Product_Code COLLATE DATABASE_DEFAULT, LEN(pc.product_code COLLATE DATABASE_DEFAULT) - CHARINDEX('_', REVERSE(pc.Product_Code COLLATE DATABASE_DEFAULT))), '') AS 'ProductCodeWithoutSuffix',
	pci.SmallImageFilename,
	pci.MediumImageFilename,
	pci.LargeImageFilename, 
	pci.BrandImageFilename,
	COALESCE(pci.OnSiteTitle,	CONCAT (b.Brand_Name + ' ',
			COALESCE(pf.Description + ' ', ''),
			CASE
				WHEN CHARINDEX ('_', pc.Product_Code, 1) > 0 
				THEN REPLACE (LEFT(pc.Product_Code, CHARINDEX ('_', pc.Product_Code, 1)), '_', '')
				ELSE pc.Product_Code
			END + ' ',
			CASE
				WHEN t.Type_ID = 9 AND ft.Fit_Type_Name = 'BI' THEN 'Integrated '
				WHEN agt.Description !=  'Major Domestic Appliances' THEN '' 
				WHEN ft.Fit_Type_Desc = 'Built In' THEN 'Integrated '
				ELSE ft.Fit_Type_Desc + ' '
			END,
			t.Type_Name + ' ',
			CASE
				WHEN pc.Colour != 'N/A' THEN 'in ' + pc.Colour COLLATE DATABASE_DEFAULT
			END
		), '') AS 'OnSiteTitle',
	pci.ProductURL,
	COALESCE(pci.Brand, b.Brand_Name COLLATE DATABASE_DEFAULT, '') AS 'Brand',
	pci.BrandFamily,
	ft.Fit_Type_Desc AS 'FitTypeDesc',
	ft.Fit_Type_Name,
	pci.StandardWarrantyYears,
	COALESCE(pci.Colour, c2.description, pc.Colour COLLATE DATABASE_DEFAULT, '') AS 'Colour',
	COALESCE(pci.TrueColour, pc.Colour COLLATE DATABASE_DEFAULT, '') AS 'TrueColour',
	COALESCE(pci.Height, pcd.Height, p.Height, 0) AS 'Height',
	COALESCE(pci.Width, pcd.Width, p.Width, 0) AS 'Width',
	COALESCE(pci.Depth, pcd.Depth, p.Depth, 0) AS 'Depth',
	COALESCE(pcd.Weight, p.Weight, 0) AS 'Weight',
	pci.hasVideo,
	pci.BrightCoveVideoID,
	pci.TotalVideoCouint,
	pci.Promotion,
	pci.FuelType, 
---- non catalog data
	EAN.EANCode,
	bg.Description AS 'BrandGroup',
	m.Name AS 'Manufacturer',
	t.Type_Name AS 'ApplianceType',
	tsc.Description AS 'SubCategory',
	tmc.Description AS 'MainCategory',
	CASE 
        WHEN tsc.Description = 'Care Pack' THEN 'Care Packs' 
        ELSE agt.Description
    END AS 'ApplianceGroup',
	CASE WHEN p.brand_id IN (52, 54, 55, 302) THEN 1 ELSE 0 END AS 'ExcludeFromReporting',
	pt.Description ProductType,
	pc.ManufacturerPartNumber,
	c.CountryCode AS 'ProductCountryCode',
	ps.Description AS 'ProductStatus',
	b.DisplayName AS 'BrandDisplayName',
	mh.DisplayText AS 'MenuDisplayText',
                pc.SupplierAccountNumber AS 'SupplierAccountNumber'

FROM 
	DRLNewProducts.dbo.tbl_product_colours pc
	LEFT OUTER JOIN DRLNewProducts.dbo.tbl_Products p
		ON pc.Product_ID = p.Product_ID
	LEFT OUTER JOIN DRLNewProducts.dbo.tbl_ProductColourDimensions pcd
		ON pc.ProdColourID = pcd.ProdColourID
	LEFT OUTER JOIN DRLNewProducts.dbo.tbl_Brands b
		ON p.Brand_ID = b.Brand_ID
	LEFT OUTER JOIN DRLNewProducts.dbo.tbl_Manufacturer m
		ON b.ManufacturerID = m.ID
	LEFT OUTER JOIN DRLNewProducts.dbo.tbl_BrandGroups bg
		ON b.BrandGroupID = bg.BrandGroupID
	LEFT OUTER JOIN DRLNewProducts.dbo.tbl_types t
		ON p.Type_ID = t.Type_ID
	LEFT OUTER JOIN DRLNewProducts.dbo.tbl_ApplianceGroup_Translation agt
		ON t.ApplianceGroupID = agt.ApplianceGroupID AND agt.LanguageID = 1
	LEFT OUTER JOIN DRLNewProducts.dbo.tbl_TypeSubCategory tsc
		ON t.SubCategoryID = tsc.ID
	LEFT OUTER JOIN DRLNewProducts.dbo.tbl_TypeMainCategory tmc
		ON tsc.MainCategoryID = tmc.ID
	LEFT OUTER JOIN DRLNewProducts.dbo.tbl_fit_type ft
		ON p.Fit_Type_ID = ft.Fit_Type_ID
	LEFT OUTER JOIN DRLNewProducts.dbo.tbl_ProductStatus ps
		ON pc.Show_On_Web = ps.ID
	LEFT OUTER JOIN DRLNewProducts.dbo.tbl_ProductFamily pf
		ON p.FamilyID = pf.ID
	LEFT OUTER JOIN DRLNewProducts.dbo.tbl_MatchingColour mc
	INNER JOIN DRLNewProducts.dbo.tbl_Colours c2
		ON mc.BaseColourID = c2.id
		ON pc.ColourId = mc.MatchingColourID
	LEFT OUTER JOIN DRLNewProducts.dbo.tbl_product_colours_EANCode EAN 
		ON pc.ProdColourID = EAN.ProdColourID_FK AND EAN.IsActiveEAN = 1
	LEFT OUTER JOIN AOAnalyticsAdmin.dbo.tbl_ProductCatalogInfo pci
		ON pc.ProdColourID = pci.ProductColourID
	LEFT OUTER JOIN DRLNewProducts.dbo.tbl_ProductType pt
		ON pc.ProductTypeId = pt.ProductTypeId
	LEFT OUTER JOIN DRLNewProducts.dbo.tbl_Country C
		ON b.CountryID = C.CountryID
	LEFT OUTER JOIN DRLNewProducts.dbo.tbl_MenuHierarchy mh
        ON p.ParentNodeID = mh.MenuID

WHERE
	(
	pc.ReportingAuditDateTime >= @LastUpdated
	OR
	p.ReportingAuditDateTime >= @LastUpdated
	OR
	pcd.ReportingAuditDateTime >= @LastUpdated
	OR
	b.ReportingAuditDateTime >= @LastUpdated
	OR
	m.ReportingAuditDateTime >= @LastUpdated
	OR
	bg.ReportingAuditDateTime >= @LastUpdated
	OR
	t.ReportingAuditDateTime >= @LastUpdated
	OR
	agt.ReportingAuditDateTime >= @LastUpdated
	OR
	tsc.ReportingAuditDateTime >= @LastUpdated
	OR
	tmc.ReportingAuditDateTime >= @LastUpdated
	OR
	ft.ReportingAuditDateTime >= @LastUpdated
	OR
	ps.ReportingAuditDateTime >= @LastUpdated
	OR
	pf.ReportingAuditDateTime >= @LastUpdated
	OR
	mc.ReportingAuditDateTime >= @LastUpdated
	OR
	c2.ReportingAuditDateTime >= @LastUpdated
	OR
	ean.ReportingAuditDateTime >= @LastUpdated
	OR
	pci.DateUpdated >= @LastUpdated
	OR
	mh.ReportingAuditDatetime >= @LastUpdated
	)