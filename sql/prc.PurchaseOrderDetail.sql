/*====================================================
Purchase Order History Aggregate
====================================================*/

WITH EKBE_AGG AS
(
    SELECT
        EBELN,
        EBELP,

        /* Goods Receipt */

        SUM(
            CASE
                WHEN VGABE = '1'
                THEN
                    CASE
                        WHEN SHKZG = 'H'
                        THEN -MENGE
                        ELSE MENGE
                    END
                ELSE 0
            END
        ) AS GrQty,

        SUM(
            CASE
                WHEN VGABE = '1'
                THEN
                    CASE
                        WHEN SHKZG = 'H'
                        THEN -DMBTR
                        ELSE DMBTR
                    END
                ELSE 0
            END
        ) AS GrAmount,

        MAX(
            CASE
                WHEN VGABE = '1'
                THEN BUDAT
            END
        ) AS LastGrDate,

        /* Invoice Receipt */

        SUM(
            CASE
                WHEN VGABE = '2'
                THEN
                    CASE
                        WHEN SHKZG = 'H'
                        THEN -MENGE
                        ELSE MENGE
                    END
                ELSE 0
            END
        ) AS IrQty,

        SUM(
            CASE
                WHEN VGABE = '2'
                THEN
                    CASE
                        WHEN SHKZG = 'H'
                        THEN -DMBTR
                        ELSE DMBTR
                    END
                ELSE 0
            END
        ) AS IrAmount,

        MAX(
            CASE
                WHEN VGABE = '2'
                THEN BUDAT
            END
        ) AS LastIrDate

    FROM EKBE

    GROUP BY
        EBELN,
        EBELP
)

SELECT

    /*====================================================
      Purchase Order
    ====================================================*/

    H.EBELN                                AS PoNumber,
    I.EBELP                                AS PoItem,
    H.BUKRS                                AS CompanyCode,
    H.BSART                                AS PoType,
    H.EKORG                                AS PurchasingOrg,
    H.EKGRP                                AS PurchasingGroup,

    /*====================================================
      Vendor
    ====================================================*/

    H.LIFNR                                AS VendorCode,
    V.NAME1                                AS VendorName,
    V.LAND1                                AS VendorCountry,

    /*====================================================
      Material
    ====================================================*/

    I.MATNR                                AS MaterialCode,
    M.MAKTX                                AS MaterialDescription,
    I.TXZ01                                AS MaterialShortText,
    I.MATKL                                AS MaterialGroup,

    /*====================================================
      Organization
    ====================================================*/

    I.WERKS                                AS Plant,
    I.LGORT                                AS StorageLocation,

    /*====================================================
      Date
    ====================================================*/

    H.BEDAT                                AS PoDate,
    I.EINDT                                AS DeliveryDate,

    /*====================================================
      Quantity & Amount
    ====================================================*/

    I.MENGE                                AS OrderQty,
    I.MEINS                                AS OrderUom,
    I.NETPR                                AS UnitPrice,
    I.NETWR                                AS OrderAmount,
    H.WAERS                                AS Currency,

    /*====================================================
      Payment
    ====================================================*/

    H.ZTERM                                AS PaymentTerm,

    /*====================================================
      PR Information
    ====================================================*/

    I.BANFN                                AS PrNumber,
    I.BNFPO                                AS PrItem,

    /*====================================================
      Contract Information
    ====================================================*/

    I.KONNR                                AS ContractNumber,
    I.KTPNR                                AS ContractItem,

    /*====================================================
      PO Status
    ====================================================*/

    I.LOEKZ                                AS DeleteIndicator,
    I.ELIKZ                                AS DeliveryCompleted,
    I.WEPOS                                AS GoodsReceiptIndicator,
    I.REPOS                                AS InvoiceReceiptIndicator,

    /*====================================================
      GR Summary
    ====================================================*/

    ISNULL(B.GrQty,0)                      AS GrQty,
    ISNULL(B.GrAmount,0)                   AS GrAmount,
    B.LastGrDate,

    /*====================================================
      IR Summary
    ====================================================*/

    ISNULL(B.IrQty,0)                      AS IrQty,
    ISNULL(B.IrAmount,0)                   AS IrAmount,
    B.LastIrDate,

    /*====================================================
      Derived Columns
    ====================================================*/

    I.MENGE - ISNULL(B.GrQty,0)            AS OpenQty,

    I.NETWR - ISNULL(B.IrAmount,0)         AS OpenAmount,

    DATEDIFF(
        DAY,
        H.BEDAT,
        B.LastGrDate
    )                                      AS PoToGrDays,

    CASE
        WHEN I.LOEKZ IS NOT NULL
             AND LTRIM(RTRIM(I.LOEKZ)) <> ''
        THEN 'Deleted'

        WHEN ISNULL(B.GrQty,0) >= I.MENGE
        THEN 'Closed'

        ELSE 'Open'
    END                                    AS PoStatus,

    GETDATE()                              AS EtlLoadTime

FROM EKKO H

INNER JOIN EKPO I
    ON H.EBELN = I.EBELN

LEFT JOIN LFA1 V
    ON H.LIFNR = V.LIFNR

LEFT JOIN MAKT M
    ON I.MATNR = M.MATNR
   AND M.SPRAS = 'M'

LEFT JOIN EKBE_AGG B
    ON I.EBELN = B.EBELN
   AND I.EBELP = B.EBELP;
