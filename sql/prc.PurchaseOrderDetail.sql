SELECT
    /* Header */
    H.EBELN                          AS PoNumber,
    H.BUKRS                          AS CompanyCode,
    H.BSART                          AS PoType,
    H.EKORG                          AS PurchasingOrg,
    H.EKGRP                          AS PurchasingGroup,
    H.LIFNR                          AS VendorCode,
    H.BEDAT                          AS PoDate,
    H.WAERS                          AS Currency,
    H.ZTERM                          AS PaymentTerm,

    /* Item */
    I.EBELP                          AS PoItem,
    I.MATNR                          AS MaterialCode,
    I.TXZ01                          AS MaterialDescription,
    I.MATKL                          AS MaterialGroup,
    I.WERKS                          AS Plant,
    I.LGORT                          AS StorageLocation,

    I.MENGE                          AS OrderQty,
    I.MEINS                          AS OrderUom,
    I.NETPR                          AS NetPrice,
    I.NETWR                          AS NetAmount,

    I.EINDT                          AS DeliveryDate,

    /* PR */
    I.BANFN                          AS PrNumber,
    I.BNFPO                          AS PrItem,

    /* Contract */
    I.KONNR                          AS ContractNo,
    I.KTPNR                          AS ContractItem,

    /* Status */
    I.LOEKZ                          AS DeleteIndicator,
    I.ELIKZ                          AS DeliveryCompleted,
    I.WEPOS                          AS GrIndicator,
    I.REPOS                          AS IrIndicator,

    /* ETL */
    GETDATE()                        AS CreateTime

FROM EKKO H
INNER JOIN EKPO I
    ON H.EBELN = I.EBELN
;
