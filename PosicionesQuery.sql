DECLARE 
@numserie NVARCHAR(MAX),
@numfac NVARCHAR(MAX)
--
SET @numserie='AAAF'
SET @numfac='178200'

--POSICIONES
DECLARE @CANJEO INT 
SET @CANJEO = (SELECT VALOR FROM [ICGTIERRAGRO2017].DBO.PARAMETROS WHERE CLAVE = 'FIDEL' AND SUBCLAVE = 'EDTOS')
TRUNCATE TABLE ZZPRUEBADET;
INSERT INTO ZZPRUEBADET
SELECT
CASE WHEN RIGHT(A.NUMSERIEFAC,1) IN  ('F','H','G','J','K') THEN 'ZPOS' WHEN RIGHT(A.NUMSERIEFAC,1) IN ('L','M','N','O','Y') THEN 'YPOS' ELSE '' END AS ClaseDoc, 
LTRIM(A.NUMSERIE) + REPLICATE('0',12-LEN(A.NUMFAC))+LTRIM(A.NUMFAC) AS NumeroSAP,
B.NUMLIN*10 AS Linea,
B.REFERENCIA AS Material, 
CASE WHEN RIGHT (A.NUMSERIEFAC,1)IN('F','H','G','J','K') THEN CAST(B.UNIDADESTOTAL AS INT) WHEN RIGHT(A.NUMSERIEFAC,1) IN ('L','M','N','O','Y') THEN CAST(B.UNIDADESTOTAL*-1 AS INT) END AS Cantidad,
ISNULL(F.UNIDADMEDIDA,'') AS UnidadMedida, 
CASE
WHEN RIGHT(A.NUMSERIEFAC,1) IN ('F','H','G','J','K') AND F.DPTO IN ('6')  AND B.REFERENCIA NOT IN ('200301') THEN 'TAX' 
WHEN RIGHT(A.NUMSERIEFAC,1) IN ('F','H','G','J','K') AND F.DPTO IN ('6')  AND B.REFERENCIA IN ('200301') THEN 'ZFFR'
WHEN RIGHT(A.NUMSERIEFAC,1) IN ('L','M','N','O','Y') AND F.DPTO IN ('6')  AND B.REFERENCIA NOT IN ('200301') THEN 'ZTX1' 
WHEN RIGHT(A.NUMSERIEFAC,1) IN ('L','M','N','O','Y') AND F.DPTO IN ('6') AND B.REFERENCIA IN ('200301') THEN 'ZTXF' 
WHEN RIGHT(A.NUMSERIEFAC,1) IN  ('F','H','G','J','K') AND F.DESCRIPCION  NOT IN ('IMPUESTO AL CONSUMO BOLSA%') THEN 'ZPOS'
WHEN RIGHT(A.NUMSERIEFAC,1) IN  ('F','H','G','J','K') AND F.DESCRIPCION IN ('IMPUESTO AL CONSUMO BOLSA%') THEN 'ZBOL'
WHEN RIGHT(A.NUMSERIEFAC,1) IN ('L','M','N','O','Y') AND F.DESCRIPCION NOT IN ('IMPUESTO AL CONSUMO BOLSA%') THEN 'YPOS'  
WHEN RIGHT(A.NUMSERIEFAC,1) IN ('L','M','N','O','Y') AND F.DESCRIPCION IN ('IMPUESTO AL CONSUMO BOLSA%') THEN 'ZBDV'  
ELSE '' END AS TipoPosicion, 
G.CODPOSTAL AS CentroCosto,
G.CENTROCOSTE AS CodigoAlmacen,
'ZPR1' AS CondicionPrecio,
ROUND(B.PRECIO, 0) AS PrecioBase,
CASE WHEN RIGHT (A.NUMSERIEFAC,1)IN('F','H','G','J','K') THEN ROUND(B.precio * B.UNIDADESTOTAL, 0) WHEN RIGHT(A.NUMSERIEFAC,1) IN ('L','M','N','O','Y')THEN ROUND(B.precio*B.UNIDADESTOTAL*-1, 0) END AS PrecioBaseTotal,
'Z024' AS DsctoAuto,
'0' AS Dscto,
'0' AS ValorDscto,
'Z021' AS CondicionSoles,
'0' AS Soles,
'0' AS ValorSoles,
'Z022' AS CondicionDsctoManual,
CASE 
WHEN (B.DTO > 0) AND RIGHT(A.NUMSERIEFAC,1) IN ('F','H','G','J','K') THEN ((B.DTO/100)*B.PRECIO*B.UNIDADESTOTAL)
WHEN (B.DTO > 0) AND RIGHT(A.NUMSERIEFAC,1) IN ('L','M','N','O','Y') THEN ((B.DTO/100)*B.PRECIO*B.UNIDADESTOTAL*-1)
ELSE '0' END AS DsctoManual,
CASE 
WHEN (B.DTO > 0) AND RIGHT(A.NUMSERIEFAC,1) IN ('F','H','G','J','K') THEN ((B.DTO/100)*B.PRECIO*B.UNIDADESTOTAL)
WHEN (B.DTO > 0) AND RIGHT(A.NUMSERIEFAC,1) IN ('L','M','N','O','Y') THEN ((B.DTO/100)*B.PRECIO*B.UNIDADESTOTAL*-1)
ELSE '0' END AS ValordsctoManual,
'0' AS CondicionBonificacion,
'0' AS PorcentajeBonificacion,
'0' AS ValorBonificacion,
'0' AS CondicionFlete,
'0' AS PorcentajeFlete,
'0' AS ValorFlete,
'0' AS CondicionRecargoM,
'0' AS PorcentajeRecargoM,
'0' AS ValorRecargoM,
'ZIVA' AS CondicionIVA,
CAST(B.IVA AS INT) AS PorcentajeIVA,
CAST(ROUND((B.TOTAL*(B.IVA/100))*B.UNIDADESTOTAL,0) AS INT)AS ValorIVA,
'Z020' AS CondicionProvisionSoles,
CASE 
WHEN (A.PUNTOSACUM > 0 AND RIGHT(A.NUMSERIE,1) IN  ('F','H','G','J','K')) THEN ROUND((B.TOTALEXPANSION/1000)*@CANJEO,-0) 
WHEN (A.PUNTOSACUM <> 0 AND RIGHT(A.NUMSERIE,1) IN ('L','M','N','O','Y')) THEN ROUND((B.TOTALEXPANSION/1000)*-1*@CANJEO,-0) ELSE 0*1 END AS ImporteProvisionSoles,
CASE 
WHEN (A.PUNTOSACUM > 0 AND RIGHT(A.NUMSERIE,1) IN  ('F','H','G','J','K')) THEN ROUND((B.TOTALEXPANSION/1000)*@CANJEO,-0) 
WHEN (A.PUNTOSACUM <> 0 AND RIGHT(A.NUMSERIE,1) IN ('L','M','N','O','Y')) THEN ROUND((B.TOTALEXPANSION/1000)*-1*@CANJEO,-0) ELSE 0*1 END AS ValorProvisionSoles
FROM [ICGTIERRAGRO2017].DBO.ALBVENTACAB A
INNER JOIN [ICGTIERRAGRO2017].DBO.ALBVENTALIN B 
ON A.NUMSERIE = B.NUMSERIE AND A.NUMALBARAN = B.NUMALBARAN AND A.N = B.N
INNER JOIN [ICGTIERRAGRO2017].DBO.SERIESCAMPOSLIBRES C 
ON A.NUMSERIE = C.SERIE
LEFT  JOIN [ICGTIERRAGRO2017].DBO.CLIENTESCAMPOSLIBRES D 
ON A.CODCLIENTE = D.CODCLIENTE 
LEFT  JOIN [ICGTIERRAGRO2017].DBO.CLIENTES E 
ON A.CODCLIENTE = E.CODCLIENTE
INNER JOIN [ICGTIERRAGRO2017].DBO.ARTICULOS F 
ON B.CODARTICULO = F.CODARTICULO
INNER JOIN [ICGTIERRAGRO2017].DBO.ALMACEN G 
ON B.CODALMACEN = G.CODALMACEN
WHERE A.NUMSERIE=@numserie AND A.NUMFAC=@numfac;
SELECT * FROM ZZPRUEBADET FOR XML RAW('DataVentasDet'), ELEMENTS