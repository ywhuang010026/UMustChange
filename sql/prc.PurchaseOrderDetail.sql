WITH EKBE_AGG AS
(
    SELECT
        EBELN,
        EBELP,

        SUM(
            CASE
                WHEN BEWTP = 'E'
                THEN CASE WHEN SHKZG = 'H'
                          THEN -MENGE
                          ELSE MENGE
                     END
                ELSE 0
            END
        ) AS GrQty,

        SUM(
            CASE
                WHEN BEWTP = 'E'
                THEN CASE WHEN SHKZG = 'H'
                          THEN -DMBTR
                          ELSE DMBTR
                     END
                ELSE 0
            END
        ) AS GrAmount,

        MAX(
            CASE
                WHEN BEWTP = 'E'
                THEN BUDAT
            END
        ) AS LastGrDate,

        SUM(
            CASE
                WHEN BEWTP = 'Q'
                THEN CASE WHEN SHKZG = 'H'
                          THEN -MENGE
                          ELSE MENGE
                     END
                ELSE 0
            END
        ) AS IrQty,

        SUM(
            CASE
                WHEN BEWTP = 'Q'
                THEN CASE WHEN SHKZG = 'H'
                          THEN -DMBTR
                          ELSE DMBTR
                     END
                ELSE 0
            END
        ) AS IrAmount,

        MAX(
            CASE
                WHEN BEWTP = 'Q'
                THEN BUDAT
            END
        ) AS LastIrDate

    FROM EKBE
    GROUP BY
        EBELN,
        EBELP
),

EKKN_AGG AS
(
    SELECT
        EBELN,
        EBELP,

        MAX(SAKTO) AS GlAccount,
        MAX(KOSTL) AS CostCenter,
        MAX(AUFNR) AS IntOrder

    FROM EKKN
    GROUP BY
        EBELN,
        EBELP
)

SELECT

    /* Key */
    H.EBELN                    AS PoNumber,
    I.EBELP                    AS PoItem,

    /* Header */
    H.BSART                    AS PoType,
    H.BUKRS                    AS CompanyCode,
    H.EKORG                    AS PurchOrg,
    H.EKGRP                    AS PurchGroup,
    H.BEDAT                    AS PoDate,

    /* Vendor */
    H.LIFNR                    AS Vendor,
    H.ZTERM                    AS PaymentTerm,
    V.NAME1                    AS VendorName,
    V.LAND1                    AS VendorCountry,

    /* Material */
    I.MATNR                    AS Material,
    M.MAKTX                    AS MaterialDesc,
    I.MATKL                    AS MaterialGroup,

    /* Organization */
    I.WERKS                    AS Plant,
    I.LGORT                    AS StorLoc,

    /* Account Assignment */
    K.GlAccount                AS GlAccount,
    K.CostCenter               AS CostCenter,
    K.IntOrder                 AS IntOrder,

    /* Amount */
    I.MENGE                    AS OrderQty,
    I.MEINS                    AS OrderUom,
    I.NETPR                    AS NetPrice,
    I.NETWR                    AS NetValue,

    H.WAERS                    AS Currency,
    H.WKURS                    AS ExchangeRate,

    /* Delivery */
    --I.EINDT                    AS DelivDate,
    I.ELIKZ                    AS DelivComplInd,
    I.WEPOS                    AS GrInd,
    I.REPOS                    AS IrInd,
    I.LOEKZ                    AS DeletionInd,

    /* GR Summary */
    ISNULL(B.GrQty,0)          AS GrQty,
    ISNULL(B.GrAmount,0)       AS GrAmount,
    B.LastGrDate               AS LastGrDate,

    /* IR Summary */
    ISNULL(B.IrQty,0)          AS IrQty,
    ISNULL(B.IrAmount,0)       AS IrAmount,
    B.LastIrDate               AS LastIrDate,

    /* PR */
    I.BANFN                    AS PrNumber,
    I.BNFPO                    AS PrItem,

    /* Contract */
    I.KONNR                    AS Contract,
    I.KTPNR                    AS ContractItem

FROM EKKO H

INNER JOIN EKPO I
    ON H.EBELN = I.EBELN

LEFT JOIN LFA1 V
    ON H.LIFNR = V.LIFNR

LEFT JOIN MAKT M
    ON I.MATNR = M.MATNR
   AND M.SPRAS = 'M'

LEFT JOIN EKKN_AGG K
    ON I.EBELN = K.EBELN
   AND I.EBELP = K.EBELP

LEFT JOIN EKBE_AGG B
    ON I.EBELN = B.EBELN
   AND I.EBELP = B.EBELP;
