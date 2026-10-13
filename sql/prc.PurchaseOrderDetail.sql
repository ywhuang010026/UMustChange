SELECT

    /* =========================
       Purchase Order
       ========================= */

    H.EBELN                             AS PoNumber,
    I.EBELP                             AS PoItem,
    H.BSART                             AS PoType,
    H.BUKRS                             AS CompanyCode,
    H.EKORG                             AS PurchasingOrg,
    H.EKGRP                             AS PurchasingGroup,

    /* =========================
       Vendor
       ========================= */

    H.LIFNR                             AS VendorCode,
    V.NAME1                             AS VendorName,
    V.LAND1                             AS VendorCountry,

    /* =========================
       Purchase Order Date
       ========================= */

    H.BEDAT                             AS PoDate,
    I.EINDT                             AS DeliveryDate,

    /* =========================
       Material
       ========================= */

    I.MATNR                             AS MaterialCode,
    M.MAKTX                             AS MaterialDescription,
    I.TXZ01                             AS ShortText,
    I.MATKL                             AS MaterialGroup,

    /* =========================
       Plant
       ========================= */

    I.WERKS                             AS Plant,
    I.LGORT                             AS StorageLocation,

    /* =========================
       Quantity
       ========================= */

    I.MENGE                             AS OrderQty,
    I.MEINS                             AS OrderUom,

    /* =========================
       Amount
       ========================= */

    I.NETPR                             AS UnitPrice,
    I.NETWR                             AS OrderAmount,
    H.WAERS                             AS Currency,

    /* =========================
       Payment
       ========================= */

    H.ZTERM                             AS PaymentTerm,

    /* =========================
       PR Reference
       ========================= */

    I.BANFN                             AS PrNumber,
    I.BNFPO                             AS PrItem,

    /* =========================
       Contract Reference
       ========================= */

    I.KONNR                             AS ContractNumber,
    I.KTPNR                             AS ContractItem,

    /* =========================
       Status
       ========================= */

    I.LOEKZ                             AS DeletionIndicator,
    I.ELIKZ                             AS DeliveryCompleted,
    I.WEPOS                             AS GoodsReceiptIndicator,
    I.REPOS                             AS InvoiceReceiptIndicator,

    /* =========================
       Placeholder
       後續由 EKBE 補
       ========================= */

    CAST(NULL AS DECIMAL(18,2))         AS GrQty,
    CAST(NULL AS DECIMAL(18,2))         AS GrAmount,
    CAST(NULL AS DECIMAL(18,2))         AS IrQty,
    CAST(NULL AS DECIMAL(18,2))         AS IrAmount,

    /* =========================
       ETL
       ========================= */

    GETDATE()                           AS LoadDate

FROM EKKO H

INNER JOIN EKPO I
    ON H.EBELN = I.EBELN

LEFT JOIN LFA1 V
    ON H.LIFNR = V.LIFNR

LEFT JOIN MAKT M
    ON I.MATNR = M.MATNR
   AND M.SPRAS = 'M';
