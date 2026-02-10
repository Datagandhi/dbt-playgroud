USE [AODataSource]
GO

/****** Object:  StoredProcedure [Fact].[usp_Sales_Services]    Script Date: 09/02/2026 19:48:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [Fact].[usp_Sales_Services]

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

INSERT INTO #ChangeIncremental ( salesOrderAmendmentsId)

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
	AND TSOA.salesOrderAmendmentTypeId IN (3, 8)

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
	AND TSOA.salesOrderAmendmentTypeId IN (3, 8)

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
	AND TSOA.salesOrderAmendmentTypeId IN (3, 8)

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
	AND TSOA.salesOrderAmendmentTypeId IN (3, 8)

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
	AND TSOA.salesOrderAmendmentTypeId IN (3, 8)

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
	AND TSOA.salesOrderAmendmentTypeId IN (3, 8)

INSERT INTO #ChangeIncremental ( salesOrderAmendmentsId)

/* Physical Item */
SELECT
	TSOA.salesOrderAmendmentsId
FROM
	DRLCore.dbo.tbl_SalesOrderAmendments TSOA
JOIN
	DRLCore.dbo.tbl_OrderLineItem TOLI
	ON TSOA.orderLineId = TOLI.orderLineId
JOIN
	DRLCore.dbo.tbl_OLIPhysicalItem TOPI
	ON TOLI.orderLineItemId = TOPI.orderLineItemId
WHERE
	TOPI.ReportingAuditDateTime >= @LastUpdated
	AND TSOA.salesOrderAmendmentTypeId IN (3, 8)

INSERT INTO #ChangeIncremental ( salesOrderAmendmentsId)

/* Sales Order Line Item */

SELECT
	TSOA.salesOrderAmendmentsId
FROM
	DRLCore.dbo.tbl_SalesOrderAmendments TSOA
JOIN
	DRLCore.dbo.tbl_OrderLineItem TOLI
	ON TSOA.orderLineId = TOLI.orderLineId
WHERE
	TOLI.ReportingAuditDateTime >= @LastUpdated
	AND TSOA.salesOrderAmendmentTypeId IN (3, 8)

INSERT INTO #ChangeIncremental ( salesOrderAmendmentsId)

/* Service */

SELECT
	TSOA.salesOrderAmendmentsId
FROM
	DRLCore.dbo.tbl_SalesOrderAmendments TSOA
JOIN
	DRLCore.dbo.tbl_Service TS
	ON TSOA.serviceId = TS.serviceId
WHERE
	TS.ReportingAuditDateTime >= @LastUpdated
	AND TSOA.salesOrderAmendmentTypeId IN (3, 8)

INSERT INTO #ChangeIncremental ( salesOrderAmendmentsId)

/* Sales Order Amendment */

SELECT
	TSOA.salesOrderAmendmentsId
FROM
	DRLCore.dbo.tbl_SalesOrderAmendments TSOA
WHERE
	TSOA.ReportingAuditDateTime >= @LastUpdated
	AND TSOA.salesOrderAmendmentTypeId IN (3, 8)

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
	AND TSOA.salesOrderAmendmentTypeId IN (3, 8)

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
	AND TSOA.salesOrderAmendmentTypeId IN (3, 8)

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
	AND TSOA.salesOrderAmendmentTypeId IN (3, 8)

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
	AND TSOA.salesOrderAmendmentTypeId IN (3, 8)

INSERT INTO #ChangeIncremental ( salesOrderAmendmentsId)

/* Issue */
SELECT
	TSOA.salesOrderAmendmentsId
FROM
	DRLCore.dbo.tbl_SalesOrderAmendments TSOA
JOIN
	DRLCore.dbo.tbl_Issue i
	ON TSOA.salesOrderId = i.salesOrderId
WHERE
	i.ReportingAuditDateTime >= @LastUpdated
	AND TSOA.salesOrderAmendmentTypeId IN (3, 8)

INSERT INTO #ChangeIncremental ( salesOrderAmendmentsId)
/* Task */
SELECT
	TSOA.salesOrderAmendmentsId
FROM
	DRLCore.dbo.tbl_SalesOrderAmendments TSOA
JOIN
	DRLCore.dbo.tbl_Issue i
	ON TSOA.salesOrderId = i.salesOrderId
JOIN
	DRLCore.dbo.tbl_Task t
	ON i.issueId = t.issueId
WHERE
	t.ReportingAuditDateTime >= @LastUpdated
	AND TSOA.salesOrderAmendmentTypeId IN (3, 8)
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
    AND SOA.salesOrderAmendmentTypeId IN (3,8 )

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
    AND SOA.salesOrderAmendmentTypeId IN ( 3,8)

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
    AND SOA.salesOrderAmendmentTypeId IN ( 3,8)

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
	AND SOA.salesOrderAmendmentTypeId IN ( 3,8)

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
	salesOrderAmendmentTypeId IN (3, 8)

END;


SELECT
	soa.salesOrderAmendmentsId, --business key for merges
--dimensional keys 
	so.salesOrderId,
	oli.orderLineId,
	soa.salesOrderAmendmentTypeId ,
	so.clientId,
    c.currency,
	oli.OLIProductColourID,
	sofpm.PaymentMethodID,
	ISNULL(SOFPM.CreditCardPaymentTypeID,-1) CreditCardPaymentTypeID,
	ISNULL(sofpm.KlarnaPaymentMethodType, '') KlarnaPaymentMethodType,
	c.countryid, 
	s.serviceTypeId,
	s.IsPremium,
	s.IsBundled,
	ISNULL(t.IsFree, 0) AS IsFree,
	CONVERT(VARCHAR(50),BO.AccountId) BusinessAccountId,
	soa.OAMadeByUserID,
	ca.customerPostCode,
	dra.deliveryAddressPostCode,
--dates and times
	soa.OADateCreated,
	so.orderDate,
	sao.MinAuthorisationDate,
	schedDel.OLIScheduledDeliveryDate,
	actDel.OLIActualDeliveryDate,
	ol.OLCancellationDate,
	so.SOCancellationDate,
--factsalesin flag
	soa.OAAuthorisationBatchNumber,
--facts
	s.serviceSalePriceExDiscountIncVat,
	s.serviceSalePriceExDiscountExVat,
	s.serviceSalePriceIncDiscountIncVat,
	s.serviceSalePriceIncDiscountExVat,
	s.serviceMarginValue,
	s.ServiceCostExVAT,
	s.ServiceCostIncVAT,
	COALESCE(Store.StoreId, AOcomStore.StoreId) AS StoreId,
	Depot.Depot
FROM 
	[DRLCore].dbo.tbl_SalesOrderAmendments soa 
	INNER JOIN [DRLCore].dbo.tbl_SalesOrder so 
		ON soa.salesOrderId = so.salesOrderId
	INNER JOIN [DRLCore].dbo.tbl_Service s 
		ON soa.serviceId = s.serviceId
	LEFT OUTER JOIN [DRLCore].dbo.tbl_OrderLineItem oli 
		ON s.orderLineItemId = oli.orderLineItemId
	LEFT OUTER JOIN [DRLCore].dbo.tbl_Orderline ol 
		ON oli.orderLineId = ol.orderLineId
	OUTER APPLY 
		(SELECT	MIN(SchedDel.OLIScheduledDeliveryDate) OLIScheduledDeliveryDate
		 FROM	[DRLCore].dbo.tbl_OLIPhysicalItem schedDel 
				LEFT OUTER JOIN [DRLCore].dbo.tbl_OLIPhysicalItem schedDel2 
					ON schedDel.orderLineItemId = schedDel2.orderLineItemId AND schedDel2.OLIScheduledDeliveryDate IS NOT NULL AND schedDel.OLIPhysicalItemId > schedDel2.OLIPhysicalItemId
		 WHERE	oli.orderLineItemId = schedDel.orderLineItemId
		 AND schedDel2.OLIPhysicalItemId IS NULL
		 AND schedDel.OLIScheduledDeliveryDate IS NOT NULL) schedDel
	OUTER APPLY 
		(SELECT	MIN(actDel.OLIActualDeliveryDate) OLIActualDeliveryDate
		 FROM	[DRLCore].dbo.tbl_OLIPhysicalItem actDel 
				LEFT OUTER JOIN [DRLCore].dbo.tbl_OLIPhysicalItem actDel2 
					ON actDel.orderLineItemId = actDel2.orderLineItemId AND actDel2.OLIActualDeliveryDate IS NOT NULL AND actDel.OLIPhysicalItemId > actDel2.OLIPhysicalItemId
		 WHERE	oli.orderLineItemId = actDel.orderLineItemId
		 AND	actDel2.OLIPhysicalItemId IS NULL
		 AND	actDel.OLIActualDeliveryDate IS NOT NULL) actDel
	LEFT OUTER JOIN [AOAnalyticsAdmin].dbo.tbl_SalesOrderFirstPaymentMethod sofpm 
		ON so.salesOrderId = sofpm.SalesOrderID
	INNER JOIN [DRLCore].dbo.tbl_Client c 
        ON so.clientid = c.clientId
	LEFT OUTER JOIN [DRLDataWarehouse].dbo.SysAuthorisedOrders sao 
		ON so.salesOrderId = sao.SalesOrderID
	LEFT OUTER JOIN [AOAnalyticsAdmin].dbo.tbl_BusinessOrders BO 
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
       1 AS 'IsFree'
    FROM
        DRLCore.dbo.tbl_Task t
        INNER JOIN DRLCore.dbo.tbl_Issue i
            ON t.issueId = i.issueId
    WHERE
        t.taskTypeId = 92
        AND i.salesorderid = ol.salesOrderId
		AND s.ServiceSalePriceIncVAT = 0
    ) t
	

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
		SOA.salesOrderAmendmentsId = C.salesOrderAmendmentsId
	)
	AND c.isIncludedinreports = 1 
GO


