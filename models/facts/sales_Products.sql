USE [AODataSource]
GO

/****** Object:  StoredProcedure [Fact].[usp_Sales_Products]    Script Date: 09/02/2026 19:47:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [Fact].[usp_Sales_Products]

@LastUpdated DATETIME  , @FullReload bit



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
	AND TSOA.salesOrderAmendmentTypeId IN (1, 6)




/* Client */
INSERT INTO
	#ChangeIncremental
	(
	salesOrderAmendmentsId
	)
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
	AND TSOA.salesOrderAmendmentTypeId IN (1, 6)



/* Business Order */
INSERT INTO
	#ChangeIncremental
	(
	salesOrderAmendmentsId
	)

SELECT
	TSOA.salesOrderAmendmentsId
FROM
	DRLCore.dbo.tbl_SalesOrderAmendments TSOA
JOIN
	AOAnalyticsAdmin.dbo.tbl_BusinessOrders TBO
	ON TSOA.salesOrderId = TBO.SalesOrderId
WHERE
	TBO.ReportingAuditDateTime >= @LastUpdated
	AND TSOA.salesOrderAmendmentTypeId IN (1, 6)



/* Sales Order */
INSERT INTO
	#ChangeIncremental
	(
	salesOrderAmendmentsId
	)
SELECT
	TSOA.salesOrderAmendmentsId
FROM
	DRLCore.dbo.tbl_SalesOrderAmendments TSOA
JOIN
	DRLCore.dbo.tbl_SalesOrder TSO
	ON TSOA.salesOrderId = TSO.salesOrderId
WHERE
	TSO.ReportingAuditDateTime >= @LastUpdated
	AND TSOA.salesOrderAmendmentTypeId IN (1, 6)



/* Sales Order First Payment Method */
INSERT INTO
	#ChangeIncremental
	(
	salesOrderAmendmentsId
	)
SELECT
	TSOA.salesOrderAmendmentsId
FROM
	DRLCore.dbo.tbl_SalesOrderAmendments TSOA
JOIN
	AOAnalyticsAdmin.dbo.tbl_SalesOrderFirstPaymentMethod TSOFPM
	ON TSOA.salesOrderId = TSOFPM.SalesOrderID
WHERE
	TSOFPM.ReportingAuditDateTime >= @LastUpdated
	AND TSOA.salesOrderAmendmentTypeId IN (1, 6)



/* Sys Authorised Order */
INSERT INTO
	#ChangeIncremental
	(
	salesOrderAmendmentsId
	)
SELECT
	TSOA.salesOrderAmendmentsId
FROM
	DRLCore.dbo.tbl_SalesOrderAmendments TSOA
JOIN
	DRLDataWarehouse.dbo.SysAuthorisedOrders SAO
	ON TSOA.salesOrderId = SAO.SalesOrderID
WHERE
	SAO.ReportingAuditDateTime >= @LastUpdated
	AND TSOA.salesOrderAmendmentTypeId IN (1, 6)



/* Order Line Item */
INSERT INTO
	#ChangeIncremental
	(
	salesOrderAmendmentsId
	)
SELECT
	TSOA.salesOrderAmendmentsId
FROM
	DRLCore.dbo.tbl_SalesOrderAmendments TSOA
JOIN
	DRLCore.dbo.tbl_OrderLineItem TOLI
	ON TSOA.orderLineId = TOLI.orderLineId
WHERE
	TOLI.ReportingAuditDateTime >= @LastUpdated
	AND TSOA.salesOrderAmendmentTypeId IN (1, 6)



/* Expense Item */
INSERT INTO
	#ChangeIncremental
	(
	salesOrderAmendmentsId
	)
SELECT
	TSOA.salesOrderAmendmentsId
FROM
	DRLCore.dbo.tbl_SalesOrderAmendments TSOA
JOIN
	DRLCore.dbo.tbl_ExpenseItem TEI
	ON TSOA.expenseItemId = TEI.expenseItemId
WHERE
	TEI.ReportingAuditDateTime >= @LastUpdated
	AND TSOA.salesOrderAmendmentTypeId IN (1, 6)



/* Issues */
INSERT INTO
	#ChangeIncremental
	(
	salesOrderAmendmentsId
	)
SELECT
	TSOA.salesOrderAmendmentsId
FROM
	DRLCore.dbo.tbl_SalesOrderAmendments TSOA
JOIN
	DRLCore.dbo.tbl_ExpenseItem TEI
	ON TSOA.expenseItemId = TEI.expenseItemId
JOIN
	DRLCore.dbo.tbl_Issue TI
	ON TEI.issueId = TI.issueId
WHERE
	TI.ReportingAuditDateTime >= @LastUpdated
	AND TSOA.salesOrderAmendmentTypeId IN (1, 6)



/* Sales Order Amendment */
INSERT INTO
	#ChangeIncremental
	(
	salesOrderAmendmentsId
	)
SELECT
	TSOA.salesOrderAmendmentsId
FROM
	DRLCore.dbo.tbl_SalesOrderAmendments TSOA
WHERE
	TSOA.ReportingAuditDateTime >= @LastUpdated
	AND TSOA.salesOrderAmendmentTypeId IN (1, 6)


/* Customer */
INSERT INTO
	#ChangeIncremental
	(
	salesOrderAmendmentsId
	)
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
	AND TSOA.salesOrderAmendmentTypeId IN (1, 6)



/* Delivery Recipient */
INSERT INTO
	#ChangeIncremental
	(
	salesOrderAmendmentsId
	)
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
	AND TSOA.salesOrderAmendmentTypeId IN (1, 6)



/* Customer Address*/
INSERT INTO
	#ChangeIncremental
	(
	salesOrderAmendmentsId
	)
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
	AND TSOA.salesOrderAmendmentTypeId IN (1, 6)



/* Delivery Recipient Address*/
INSERT INTO
	#ChangeIncremental
	(
	salesOrderAmendmentsId
	)
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
	AND TSOA.salesOrderAmendmentTypeId IN (1, 6)



/* Trading Category */
INSERT INTO
	#ChangeIncremental
	(
	salesOrderAmendmentsId
	)
SELECT
	TSOA.salesOrderAmendmentsId
FROM
	DRLCore.dbo.tbl_SalesOrderAmendments TSOA
JOIN
	DRLCore.dbo.tbl_OrderLine TOL
		ON TSOA.salesOrderId = TOL.salesOrderId
JOIN AOAnalyticsAdmin.dbo.tbl_StockClassHistory tsch
		ON tol.OLProductColourID = tsch.ProductColourID
			AND CAST(tol.OLDateAdded AS DATE) = tsch.Date
WHERE
	tsch.ReportingAuditDateTime >= @LastUpdated
	AND TSOA.salesOrderAmendmentTypeId IN (1, 6)



/* kafka_retail_store_dynamo_order_lineitem */
INSERT INTO
	#ChangeIncremental
	(
	salesOrderAmendmentsId
	)
SELECT
    SOA.salesOrderAmendmentsId
FROM
	InStoreSales.dbo.kafka_retail_store_dynamo_order_lineitem KRSDOL
	JOIN DRLCore.dbo.tbl_SalesOrder SO  ON KRSDOL.ClientReferenceID = SO.clientReference
	JOIN DRLCore.dbo.tbl_OrderLine OL ON SO.salesOrderId = OL.salesOrderId
	JOIN DRLCore.dbo.tbl_SalesOrderAmendments SOA ON OL.orderLineId = SOA.orderLineId
  
WHERE
    KRSDOL.ReportingAuditDateTime >= @LastUpdated
    AND SOA.salesOrderAmendmentTypeId IN ( 1, 6 )



/* Store */
INSERT INTO
	#ChangeIncremental
	(
	salesOrderAmendmentsId
	)
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
    AND SOA.salesOrderAmendmentTypeId IN ( 1, 6 )


/* ao.com orders marked as being taken in-store*/
INSERT INTO
	#ChangeIncremental
	(
	salesOrderAmendmentsId
	)
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
    AND SOA.salesOrderAmendmentTypeId IN ( 1, 6 )

INSERT INTO
	#ChangeIncremental
	(
	salesOrderAmendmentsId
	)
/* depot - order mapping*/
SELECT
    SOA.salesOrderAmendmentsId
FROM
	AOAnalyticsAdmin.dbo.tbl_GEAC_OrderToDepotMapping G
	JOIN DRLCore.dbo.tbl_SalesOrder SO ON SO.orderNumber = G.OrderNumber
	JOIN DRLCore.dbo.tbl_SalesOrderAmendments SOA ON SOA.salesOrderId = SO.salesOrderId  
WHERE
    G.ReportingAuditDateTime >= @LastUpdated
	AND SOA.salesOrderAmendmentTypeId IN (1, 6)



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
	salesOrderAmendmentTypeId IN (1, 6)

END;






IF OBJECT_ID('tempdb..#SalesOrderAmendments') IS NOT NULL DROP TABLE #SalesOrderAmendments;

CREATE TABLE #SalesOrderAmendments
	(
	SalesOrderAmendmentsId INT NOT NULL PRIMARY KEY CLUSTERED,
	orderLineId INT NOT NULL,
	SalesOrderID INT NOT NULL	
	);

IF OBJECT_ID('tempdb..#DeliveryCosts') IS NOT NULL DROP TABLE #DeliveryCosts;

CREATE TABLE #DeliveryCosts
	(
	SalesOrderId INT NOT NULL PRIMARY KEY CLUSTERED,
	PaidTimeSlot BIT NOT NULL DEFAULT(1)
	);

IF OBJECT_ID('tempdb..#DeliveryTimeslotId') IS NOT NULL DROP TABLE #DeliveryTimeslotId;

CREATE TABLE #DeliveryTimeslotId
	(
	SalesOrderAmendmentsId INT NOT NULL PRIMARY KEY CLUSTERED,
	DeliveryTimeslotId INT NOT NULL
	);

INSERT INTO
	#SalesOrderAmendments
		(
		SalesOrderAmendmentsId,
		orderLineId,
		SalesOrderID
		)

SELECT
	C.salesOrderAmendmentsId,
	COALESCE(S.orderLineId, -1) AS orderLineId,
	S.salesOrderId
FROM
	DRLCore.dbo.tbl_SalesOrderAmendments S
JOIN
	#Change C
	ON S.salesOrderAmendmentsId = C.salesOrderAmendmentsId;


INSERT INTO #DeliveryCosts
	(
	SalesOrderId
	)
SELECT DISTINCT
		SOA.SalesOrderID

	FROM
		#SalesOrderAmendments SOA
	JOIN
		DRLCore.dbo.tbl_Delivery D
		ON SOA.SalesOrderID = D.salesOrderId
	JOIN
		DRLCore.dbo.tbl_SalesOrderDeliveryCharges DC
		ON D.deliveryId = DC.deliveryId
	WHERE
		DC.isDeleted = 0
		AND DC.deliveryChargeType = 'DeliveryTimeSlot'
		AND D.isDeleted = 0
		AND DC.DeliveryChargeAmountIncDiscountExVAT > 0
	
INSERT INTO #DeliveryTimeslotId
	(
	SalesOrderAmendmentsId,
	DeliveryTimeslotId
	)
	SELECT DISTINCT
		   TSOA.SalesOrderAmendmentsId,

		   FIRST_VALUE(TOPI.deliveryTimeslotId) OVER (PARTITION BY
														  TSOA.SalesOrderAmendmentsId
													  ORDER BY
														  TOPI.OLIPhysicalItemId
													 ) AS deliveryTimeslotId
	FROM
		#SalesOrderAmendments TSOA
	JOIN
		DRLCore.dbo.tbl_OrderLineItem TOLI
		ON TSOA.orderLineId = TOLI.orderLineId
	JOIN
		DRLCore.dbo.tbl_OLIPhysicalItem TOPI
		ON TOLI.orderLineItemId = TOPI.orderLineItemId
	WHERE
		TOPI.deliveryTimeslotId IS NOT NULL

SELECT 
	soa.salesOrderAmendmentsId, --business key for merges
--dimensional keys 
	so.salesOrderId,
	ol.orderLineId,
	soa.salesOrderAmendmentTypeId ,
	so.clientId,
    c.currency,
	ol.OLProductColourID,
	sofpm.PaymentMethodID,
	ISNULL(SOFPM.CreditCardPaymentTypeID,-1) CreditCardPaymentTypeID,
	ISNULL(sofpm.KlarnaPaymentMethodType, '') KlarnaPaymentMethodType,
	c.countryid, 
	CONVERT(VARCHAR(50),BO.AccountId) BusinessAccountId,
	soa.OAMadeByUserID,
	ca.customerPostCode,
	dra.deliveryAddressPostCode,
    tsch.ABCStockClass,
    tsch.XYZStockClass,
    tsch.TradingRange,
    tsch.Exclusive,
    tsch.Elite,
    tsch.JITOnly,
--dates and times
	soa.OADateCreated,
	so.orderDate,
	sao.MinAuthorisationDate,
	schedDel.OLIScheduledDeliveryDate AS 'OLIScheduledDeliveryDate',
    actDel.OLIActualDeliveryDate AS 'OLIActualDeliveryDate',
	ol.OLCancellationDate,
	so.SOCancellationDate,
--factsalesin flag
	soa.OAAuthorisationBatchNumber,
--facts
	ol.OLRevenueSalesPriceExDiscountIncVat,
	ol.OLRevenueSalesPriceExDiscountExVat,
	ol.OLRevenueSalesPriceIncDiscountIncVat,
	ol.OLRevenueSalesPriceIncDiscountExVat,
	ol.OLRevenueMarginIncDiscountExVAT, 
	ol.OLCostIncVAT,
	ol.OLCostExVAT,
	ol.OLSOAValue,
	ol.TrueCostExVat,
	ol.OLAdvertValue,
	CAST(TDTS.Description AS NVARCHAR(255)) AS TimeSlotDescription,
	CAST(TDTS.CourierCode AS NVARCHAR(255)) AS TimeSlotCourierCode,
	CAST(COALESCE(TDTS.WebDescription, '') AS NVARCHAR(255)) AS TimeSlotWebDescription,
	COALESCE(DC.PaidTimeSlot, 0) AS PaidTimeSlot,
	COALESCE(Store.StoreId, AOcomStore.StoreId) AS StoreId,
	Depot.Depot
FROM 
	[DRLCore].dbo.tbl_SalesOrderAmendments soa WITH (NOLOCK)
	INNER JOIN [DRLCore].dbo.tbl_SalesOrder so WITH (NOLOCK)
		ON soa.salesOrderId = so.salesOrderId
	INNER JOIN [DRLCore].dbo.tbl_OrderLine ol WITH (NOLOCK)
		ON soa.orderLineId = ol.orderLineId

	
	OUTER APPLY 
		(SELECT	MIN(SchedDel.OLIScheduledDeliveryDate) OLIScheduledDeliveryDate
		 FROM	
				[DRLCore].dbo.tbl_OrderLineItem oli WITH (NOLOCK)
				INNER JOIN [DRLCore].dbo.tbl_OLIPhysicalItem schedDel WITH (NOLOCK)
					ON oli.orderLineItemId = schedDel.orderLineItemId
				LEFT OUTER JOIN [DRLCore].dbo.tbl_OLIPhysicalItem schedDel2 WITH (NOLOCK)
					ON schedDel.orderLineItemId = schedDel2.orderLineItemId AND schedDel2.OLIScheduledDeliveryDate IS NOT NULL AND schedDel.OLIPhysicalItemId > schedDel2.OLIPhysicalItemId
		 WHERE	ol.orderLineId = oli.orderLineId
		 AND schedDel2.OLIPhysicalItemId IS NULL
		 AND schedDel.OLIScheduledDeliveryDate IS NOT NULL) schedDel

	OUTER APPLY 
		(SELECT	MIN(actDel.OLIActualDeliveryDate) OLIActualDeliveryDate
		 FROM	[DRLCore].dbo.tbl_OrderLineItem oli 
				INNER JOIN [DRLCore].dbo.tbl_OLIPhysicalItem actDel 
					ON oli.orderLineItemId = actDel.orderLineItemId
				LEFT OUTER JOIN [DRLCore].dbo.tbl_OLIPhysicalItem actDel2 
					ON actDel.orderLineItemId = actDel2.orderLineItemId AND actDel2.OLIActualDeliveryDate IS NOT NULL AND actDel.OLIPhysicalItemId > actDel2.OLIPhysicalItemId
		 WHERE	ol.orderLineId = oli.orderLineId
		 AND	actDel2.OLIPhysicalItemId IS NULL
		 AND	actDel.OLIActualDeliveryDate IS NOT NULL) actDel
	LEFT OUTER JOIN [AOAnalyticsAdmin].dbo.tbl_SalesOrderFirstPaymentMethod sofpm 
		ON so.salesOrderId = sofpm.SalesOrderID
    INNER JOIN [DRLCore].dbo.tbl_Client c 
        ON so.clientid = c.clientId
	LEFT OUTER JOIN [DRLDataWarehouse].dbo.SysAuthorisedOrders sao 
		ON so.salesOrderId = sao.SalesOrderID
	LEFT JOIN [AOAnalyticsAdmin].dbo.tbl_BusinessOrders BO 
		 ON so.salesOrderId = BO.SalesOrderId
	LEFT JOIN DRLCore.dbo.tbl_Customer TCu
		ON SO.customerId = TCu.customerId
	LEFT JOIN DRLCore.dbo.tbl_CustomerAddress ca
		ON TCu.customerAddressId = ca.customerAddressId
	LEFT JOIN DRLCore.dbo.tbl_DeliveryRecipient DR
		ON SO.deliveryRecipientId = DR.deliveryRecipientId
	LEFT JOIN DRLCore.dbo.tbl_deliveryRecipientAddress dra
		ON dr.deliveryRecipientAddressId = dra.deliveryRecipientAddressId
	LEFT JOIN AOAnalyticsAdmin.dbo.tbl_StockClassHistory tsch
		ON ol.OLProductColourID = tsch.ProductColourID
			AND CAST(ol.OLDateAdded AS DATE) = tsch.Date
	LEFT JOIN
		#DeliveryTimeslotId DTI
		ON SOA.SalesOrderAmendmentsId = DTI.SalesOrderAmendmentsId
	LEFT JOIN
		DRLCore.dbo.tbl_DeliveryTimeSlot TDTS
		ON DTI.deliveryTimeslotId = TDTS.TimeSlotId
	LEFT JOIN
		DRLCore.dbo.tbl_DeliveryTimeSlotCategory TDTSC
		ON TDTSC.Id = TDTS.DeliveryTimeSlotCategoryId
	LEFT JOIN
		#DeliveryCosts DC
		ON SOA.SalesOrderID = DC.SalesOrderID
	LEFT JOIN AOAnalyticsAdmin.dbo.tbl_GEAC_OrderToDepotMapping depot ON depot.OrderNumber = so.orderNumber
	OUTER APPLY (
					SELECT TOP 1 
						StoreId 
					FROM 
						InStoreSales.dbo.kafka_retail_store_dynamo_order_lineitem KRSDOL 
					WHERE 
						ClientReferenceID = SO.clientReference
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


