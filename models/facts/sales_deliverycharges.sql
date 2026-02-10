USE [AODataSource]
GO

/****** Object:  StoredProcedure [Fact].[usp_Sales_DeliveryCharges]    Script Date: 09/02/2026 19:42:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [Fact].[usp_Sales_DeliveryCharges]
@LastUpdated DATETIME , @FullReload BIT

AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#Change') IS NOT NULL
	DROP TABLE #Change;

CREATE TABLE #Change
	(
	salesOrderAmendmentsId INT NOT NULL,
	PRIMARY KEY CLUSTERED(salesOrderAmendmentsId)
	);

IF OBJECT_ID('tempdb..#ChangeIncremental') IS NOT NULL
	DROP TABLE #ChangeIncremental;

CREATE TABLE #ChangeIncremental
	(
	salesOrderAmendmentsId INT NOT NULL
	);

IF @FullReload = 0 BEGIN

INSERT INTO
	#ChangeIncremental
	(
	salesOrderAmendmentsId
	)

/* Order Line */
SELECT
	TSOA.salesOrderAmendmentsId
FROM
	DRLCore.dbo.tbl_SalesOrderAmendments TSOA
JOIN
	DRLCore.dbo.tbl_OrderLine TOL
	ON TSOA.salesOrderId = TOL.salesOrderId
WHERE
	TOL.ReportingAuditDateTime >= @LastUpdated
	AND TSOA.salesOrderAmendmentTypeId IN (2, 7)

INSERT INTO #ChangeIncremental ( salesOrderAmendmentsId)


/* Client */
SELECT
	TSOA.salesOrderAmendmentsId
FROM
	DRLCore.dbo.tbl_SalesOrderAmendments TSOA
JOIN
	DRLCore.dbo.tbl_SalesOrder TSO
	ON TSOA.salesOrderId = TSO.salesOrderId
JOIN
	DRLCore.dbo.tbl_Client TC
	ON TSO.clientId = TC.clientId
WHERE
	TC.ReportingAuditDateTime >= @LastUpdated
	AND TSOA.salesOrderAmendmentTypeId IN (2, 7)

INSERT INTO #ChangeIncremental ( salesOrderAmendmentsId)

/* Business Order */

SELECT
	TSOA.salesOrderAmendmentsId
FROM
	DRLCore.dbo.tbl_SalesOrderAmendments TSOA
JOIN
	AOAnalyticsAdmin.dbo.tbl_BusinessOrders TBO
	ON TSOA.salesOrderId = TBO.SalesOrderId
WHERE
	TBO.ReportingAuditDateTime >= @LastUpdated
	AND TSOA.salesOrderAmendmentTypeId IN (2, 7)

INSERT INTO #ChangeIncremental ( salesOrderAmendmentsId)

/* Sales Order */

SELECT
	TSOA.salesOrderAmendmentsId
FROM
	DRLCore.dbo.tbl_SalesOrderAmendments TSOA
JOIN
	DRLCore.dbo.tbl_SalesOrder TSO
	ON TSOA.salesOrderId = TSO.salesOrderId
WHERE
	TSO.ReportingAuditDateTime >= @LastUpdated
	AND TSOA.salesOrderAmendmentTypeId IN (2, 7)

INSERT INTO #ChangeIncremental ( salesOrderAmendmentsId)

/* Sales Order First Payment Method */

SELECT
	TSOA.salesOrderAmendmentsId
FROM
	DRLCore.dbo.tbl_SalesOrderAmendments TSOA
JOIN
	AOAnalyticsAdmin.dbo.tbl_SalesOrderFirstPaymentMethod TSOFPM
	ON TSOA.salesOrderId = TSOFPM.SalesOrderID
WHERE
	TSOFPM.ReportingAuditDateTime >= @LastUpdated
	AND TSOA.salesOrderAmendmentTypeId IN (2, 7)

INSERT INTO #ChangeIncremental ( salesOrderAmendmentsId)

/* Sys Authorised Order */

SELECT
	TSOA.salesOrderAmendmentsId
FROM
	DRLCore.dbo.tbl_SalesOrderAmendments TSOA
JOIN
	DRLDataWarehouse.dbo.SysAuthorisedOrders SAO
	ON TSOA.salesOrderId = SAO.SalesOrderID
WHERE
	SAO.ReportingAuditDateTime >= @LastUpdated
	AND TSOA.salesOrderAmendmentTypeId IN (2, 7)

INSERT INTO #ChangeIncremental ( salesOrderAmendmentsId)

/* Order Line Item */
SELECT
	TSOA.salesOrderAmendmentsId
FROM
	DRLCore.dbo.tbl_SalesOrderAmendments TSOA
JOIN
	DRLCore.dbo.tbl_OrderLineItem TOLI
	ON TSOA.orderLineId = TOLI.orderLineId
WHERE
	TOLI.ReportingAuditDateTime >= @LastUpdated
	AND TSOA.salesOrderAmendmentTypeId IN (2, 7)

INSERT INTO #ChangeIncremental ( salesOrderAmendmentsId)

/* Additional Charge Item */

SELECT
	TSOA.salesOrderAmendmentsId
FROM
	DRLCore.dbo.tbl_SalesOrderAmendments TSOA
JOIN
	DRLCore.dbo.tbl_AdditionalChargeItem TACI
	ON TSOA.additionalChargeItemId = TACI.additionalChargeItemId
WHERE
	TACI.ReportingAuditDateTime >= @LastUpdated
	AND TSOA.salesOrderAmendmentTypeId IN (2, 7)

INSERT INTO #ChangeIncremental ( salesOrderAmendmentsId)

/* Issues */

SELECT
	TSOA.salesOrderAmendmentsId
FROM
	DRLCore.dbo.tbl_SalesOrderAmendments TSOA
JOIN
	DRLCore.dbo.tbl_AdditionalChargeItem TACI
	ON TSOA.additionalChargeItemId = TACI.additionalChargeItemId
JOIN
	DRLCore.dbo.tbl_Issue TI
	ON TACI.issueId = TI.issueId
WHERE
	TI.ReportingAuditDateTime >= @LastUpdated
	AND TSOA.salesOrderAmendmentTypeId IN (2, 7)

INSERT INTO #ChangeIncremental ( salesOrderAmendmentsId)

/* Sales Order Amendment */

SELECT
	TSOA.salesOrderAmendmentsId
FROM
	DRLCore.dbo.tbl_SalesOrderAmendments TSOA
WHERE
	TSOA.ReportingAuditDateTime >= @LastUpdated
	AND TSOA.salesOrderAmendmentTypeId IN (2, 7)

INSERT INTO #ChangeIncremental ( salesOrderAmendmentsId)

/* Customer */
SELECT
	TSOA.salesOrderAmendmentsId
FROM
	DRLCore.dbo.tbl_SalesOrderAmendments TSOA
JOIN
	DRLCore.dbo.tbl_SalesOrder TSO
	ON TSOA.salesOrderId = TSO.salesOrderId
JOIN
	DRLCore.dbo.tbl_Customer TC
	ON TSO.customerId = TC.customerId
WHERE
	TC.ReportingAuditDateTime >= @LastUpdated
	AND TSOA.salesOrderAmendmentTypeId IN (2, 7)

INSERT INTO #ChangeIncremental ( salesOrderAmendmentsId)

/* Delivery Recipient */
SELECT
	TSOA.salesOrderAmendmentsId
FROM
	DRLCore.dbo.tbl_SalesOrderAmendments TSOA
JOIN
	DRLCore.dbo.tbl_SalesOrder TSO
	ON TSOA.salesOrderId = TSO.salesOrderId
JOIN
	DRLCore.dbo.tbl_DeliveryRecipient DR
	ON TSO.deliveryRecipientId = DR.deliveryRecipientId
WHERE
	DR.ReportingAuditDateTime >= @LastUpdated
	AND TSOA.salesOrderAmendmentTypeId IN (2, 7)

INSERT INTO #ChangeIncremental ( salesOrderAmendmentsId)

/* Customer Address*/
SELECT
	TSOA.salesOrderAmendmentsId
FROM
	DRLCore.dbo.tbl_SalesOrderAmendments TSOA
JOIN
	DRLCore.dbo.tbl_SalesOrder TSO
	ON TSOA.salesOrderId = TSO.salesOrderId
JOIN
	DRLCore.dbo.tbl_Customer TC
	ON TSO.customerId = TC.customerId
JOIN
	DRLCore.dbo.tbl_CustomerAddress ca
	ON TC.customerAddressId = ca.customerAddressId
WHERE
	ca.ReportingAuditDateTime >= @LastUpdated
	AND TSOA.salesOrderAmendmentTypeId IN (2, 7)

INSERT INTO #ChangeIncremental ( salesOrderAmendmentsId)

/* Delivery Recipient Address*/
SELECT
	TSOA.salesOrderAmendmentsId
FROM
	DRLCore.dbo.tbl_SalesOrderAmendments TSOA
JOIN
	DRLCore.dbo.tbl_SalesOrder TSO
	ON TSOA.salesOrderId = TSO.salesOrderId
JOIN
	DRLCore.dbo.tbl_DeliveryRecipient DR
	ON TSO.deliveryRecipientId = DR.deliveryRecipientId
JOIN
	DRLCore.dbo.tbl_deliveryRecipientAddress dra
	ON dr.deliveryRecipientAddressId = dra.deliveryRecipientAddressId
WHERE
	dra.ReportingAuditDateTime >= @LastUpdated
	AND TSOA.salesOrderAmendmentTypeId IN (2, 7)

INSERT INTO #ChangeIncremental ( salesOrderAmendmentsId)

/* kafka_retail_store_dynamo_order_lineitem */
SELECT
    SOA.salesOrderAmendmentsId
FROM
	InStoreSales.dbo.kafka_retail_store_dynamo_order_lineitem KRSDOL
	JOIN DRLCore.dbo.tbl_SalesOrder SO  ON KRSDOL.ClientReferenceID = SO.clientReference
	JOIN DRLCore.dbo.tbl_OrderLine OL ON SO.salesOrderId = OL.salesOrderId
	JOIN DRLCore.dbo.tbl_SalesOrderAmendments SOA ON OL.orderLineId = SOA.orderLineId
  
WHERE
    KRSDOL.ReportingAuditDateTime >= @LastUpdated
    AND SOA.salesOrderAmendmentTypeId IN (2, 7 )

INSERT INTO #ChangeIncremental ( salesOrderAmendmentsId)

/* Store */
SELECT
    SOA.salesOrderAmendmentsId
FROM
	InStoreSales.dbo.tbl_Store S 
	JOIN InStoreSales.dbo.kafka_retail_store_dynamo_order_lineitem KRSDOL ON S.StoreID = KRSDOL.StoreId
	JOIN DRLCore.dbo.tbl_SalesOrder SO  ON KRSDOL.ClientReferenceID = SO.clientReference
	JOIN DRLCore.dbo.tbl_OrderLine OL ON SO.salesOrderId = OL.salesOrderId
	JOIN DRLCore.dbo.tbl_SalesOrderAmendments SOA ON OL.orderLineId = SOA.orderLineId
  
WHERE
    S.ReportingAuditDateTime >= @LastUpdated
    AND SOA.salesOrderAmendmentTypeId IN ( 2, 7 )
INSERT INTO #ChangeIncremental ( salesOrderAmendmentsId)

/* ao.com orders marked as being taken in-store*/
SELECT
    SOA.salesOrderAmendmentsId
FROM
	InStoreSales.dbo.tbl_Store S 
	JOIN InStoreSales.dbo.tbl_CanterburyOrders CO ON S.WebTaggingDescription = CO.Source
	JOIN DRLCore.dbo.tbl_SalesOrder SO  ON CO.OrderNumber = SO.OrderNumber
	JOIN DRLCore.dbo.tbl_OrderLine OL ON SO.salesOrderId = OL.salesOrderId
	JOIN DRLCore.dbo.tbl_SalesOrderAmendments SOA ON OL.orderLineId = SOA.orderLineId
  
WHERE
    CO.LoadDate >= @LastUpdated
    AND SOA.salesOrderAmendmentTypeId IN ( 2, 7 )

INSERT INTO #ChangeIncremental ( salesOrderAmendmentsId)
/* depot - order mapping*/
SELECT
    SOA.salesOrderAmendmentsId
FROM
	AOAnalyticsAdmin.dbo.tbl_GEAC_OrderToDepotMapping G
	JOIN DRLCore.dbo.tbl_SalesOrder SO ON SO.orderNumber = G.OrderNumber
	JOIN DRLCore.dbo.tbl_SalesOrderAmendments SOA ON SOA.salesOrderId = SO.salesOrderId  
WHERE
    G.ReportingAuditDateTime >= @LastUpdated
	AND SOA.salesOrderAmendmentTypeId IN ( 2, 7 )

	INSERT #Change (salesOrderAmendmentsId)
	SELECT DISTINCT salesOrderAmendmentsId FROM #ChangeIncremental CI
END

ELSE

BEGIN
INSERT INTO
	#Change
	(
	salesOrderAmendmentsId
	)

/* Order Line */
SELECT
	salesOrderAmendmentsId
FROM
	DRLCore.dbo.tbl_SalesOrderAmendments
WHERE
	salesOrderAmendmentTypeId IN (2, 7)

END;

SELECT 
	soa.salesOrderAmendmentsId, --business key for merges
--dimensional keys 
	so.salesOrderId,
	soa.salesOrderAmendmentTypeId,
	so.clientId,
    c.currency,
	sofpm.PaymentMethodID,
	ISNULL(SOFPM.CreditCardPaymentTypeID,-1) CreditCardPaymentTypeID,
	ISNULL(sofpm.KlarnaPaymentMethodType, '') KlarnaPaymentMethodType,
	c.countryid, 
	sodc.deliveryChargeType,
	CONVERT(VARCHAR(50),BO.AccountId) BusinessAccountId,
	soa.OAMadeByUserID,
	ca.customerPostCode,
	dra.deliveryAddressPostCode,
--dates and times
	soa.OADateCreated,
	so.orderDate,
	sao.MinAuthorisationDate,
	d.scheduledDeliveryDate,
	so.SOCancellationDate,
--factsalesin flag
	soa.OAAuthorisationBatchNumber,
--facts
	sodc.DeliveryChargeAmountExDiscountIncVAT,
	sodc.DeliveryChargeAmountExDiscountExVAT,
	sodc.DeliveryChargeAmountIncDiscountIncVAT,
	sodc.DeliveryChargeAmountIncDiscountExVAT,
	sodc.deliveryChargeMarginValue,
	sodc.DeliveryChargeCostExVAT,
	sodc.DeliveryChargeCostIncVAT,
	COALESCE(Store.StoreId, AOcomStore.StoreId) AS StoreId,
	Depot.Depot
FROM 
	[DRLCore].dbo.tbl_SalesOrderAmendments soa 
	INNER JOIN [DRLCore].dbo.tbl_SalesOrder so 
		ON soa.salesOrderId = so.salesOrderId
	INNER JOIN [DRLCore].dbo.tbl_SalesOrderDeliveryCharges sodc 
		ON soa.salesOrderDeliveryChargesId = sodc.salesOrderDeliveryChargesId
	LEFT OUTER JOIN [AOAnalyticsAdmin].dbo.tbl_SalesOrderFirstPaymentMethod sofpm 
		ON so.salesOrderId = sofpm.SalesOrderID
    INNER JOIN [DRLCore].dbo.tbl_Client c 
        ON so.clientid = c.clientId
	INNER JOIN [DRLCore].dbo.tbl_delivery d 
		ON sodc.deliveryId = d.deliveryid
	LEFT OUTER JOIN [DRLDataWarehouse].dbo.SysAuthorisedOrders sao
		ON so.salesOrderId = sao.SalesOrderID
	LEFT JOIN [AOAnalyticsAdmin].dbo.tbl_BusinessOrders bo
		ON so.salesOrderId = BO.SalesOrderId
	LEFT JOIN DRLCore.dbo.tbl_Customer TCu
		ON SO.customerId = TCu.customerId
	LEFT JOIN DRLCore.dbo.tbl_CustomerAddress ca
		ON TCu.customerAddressId = ca.customerAddressId
	LEFT JOIN DRLCore.dbo.tbl_DeliveryRecipient DR
		ON SO.deliveryRecipientId = DR.deliveryRecipientId
	LEFT JOIN DRLCore.dbo.tbl_deliveryRecipientAddress dra
		ON dr.deliveryRecipientAddressId = dra.deliveryRecipientAddressId
LEFT JOIN AOAnalyticsAdmin.dbo.tbl_GEAC_OrderToDepotMapping depot ON depot.OrderNumber = so.orderNumber
OUTER APPLY (
				SELECT TOP 1 
					StoreId 
				FROM 
					InStoreSales.dbo.kafka_retail_store_dynamo_order_lineitem KRSDOL 
				WHERE 
					KRSDOL.ClientReferenceID = SO.clientReference
				) Store
OUTER APPLY (
			SELECT TOP 1 
				S.StoreId 
			FROM 
				InStoreSales.dbo.tbl_CanterburyOrders CO 
				JOIN InStoreSales.dbo.tbl_Store S ON CO.Source = S.WebTaggingDescription
			WHERE 
				CO.OrderNumber = SO.OrderNUmber
			) AOcomStore
WHERE
	EXISTS
	(
	SELECT
		NULL
	FROM
		#Change C
	WHERE
		soa.salesOrderAmendmentsId = C.salesOrderAmendmentsId
	)
	AND c.isIncludedinreports = 1
GO


