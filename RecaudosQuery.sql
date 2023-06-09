DECLARE 
@numserie NVARCHAR(MAX),
@numfac NVARCHAR(MAX)
--
SET @numserie='AAAF'
SET @numfac='178200'

--RECAUDOS
TRUNCATE TABLE ZZRECAUDOSXML;
--Recaudos CABECERA
INSERT INTO ZZRECAUDOSXML
SELECT TOP 1
'C' AS Campo03,
'Z001' AS Campo04,
'1000'AS Campo05,
'' AS Campo06,
(SELECT FORMAT(A.Fecha,N'yyyyMMdd')) AS Campo07,
(SELECT FORMAT(A.Fecha,N'yyyyMMdd')) AS Campo08,
'COP' AS Campo09,
LTRIM(A.NUMSERIE) + REPLICATE('0',12-LEN(A.NUMFAC))+LTRIM(A.NUMFAC) AS Campo10
From [ICGTIERRAGRO2017].DBO.ALBVENTACAB A
INNER JOIN [ICGTIERRAGRO2017].DBO.CLIENTES B
ON A.CODCLIENTE = B.CODCLIENTE
INNER JOIN [ICGTIERRAGRO2017].DBO.CLIENTESCAMPOSLIBRES C
ON B.CODCLIENTE = C.CODCLIENTE
INNER JOIN [ICGTIERRAGRO2017].DBO.SERIESCAMPOSLIBRES D
ON A.NUMSERIE = D.SERIE
INNER JOIN [ICGTIERRAGRO2017].DBO.TESORERIA E
ON D.SERIE = E.SERIE AND A.NUMFAC = E.NUMERO
INNER JOIN [ICGTIERRAGRO2017].DBO.VENCIMFPAGO F
ON E.CODTIPOPAGO = F.CODTIPOPAGO
INNER JOIN [ICGTIERRAGRO2017].DBO.TIPOSPAGO G
ON E.CODTIPOPAGO = G.CODTIPOPAGO
INNER JOIN [ICGTIERRAGRO2017].DBO.ALBVENTALIN H
ON A.NUMSERIE = H.NUMSERIE AND A.NUMALBARAN = H.NUMALBARAN
WHERE A.NUMSERIE=@numserie AND A.NUMFAC=@numfac AND E.CODTIPOPAGO NOT IN ('-1');
--RecaudosMedioDePago
INSERT INTO ZZRECAUDOSXML
SELECT  
'P' AS Campo03,
CASE WHEN RIGHT(A.NUMSERIEFAC,1) IN  ('F','H','G','J','K') THEN '40' WHEN RIGHT(A.NUMSERIEFAC,1) IN ('L','M','N','O','Y') THEN '50'  ELSE '' END AS Campo04,
CASE WHEN E.CODTIPOPAGO='1' THEN LEFT(D.CTA_EFECTIVO,10)ELSE F.CUENTACOBRO	END COLLATE Latin1_General_CS_AI AS Campo05,
'' AS Campo06,
CASE WHEN RIGHT(A.NUMSERIEFAC,1) IN  ('F','H','G','J','K') THEN (E.IMPORTE) WHEN RIGHT(A.NUMSERIEFAC,1) IN ('Y','M','N','O','Y') THEN (ABS(E.IMPORTE))  ELSE '' END AS Campo07,
(CASE WHEN G.RAIZCOBROS IS NULL THEN D.SAP_OFICINAS_VENTAS ELSE G.RAIZCOBROS END)COLLATE Latin1_General_CS_AI AS Campo08,
(CASE WHEN G.RAIZPAGOS IS NULL THEN D.SAP_GRUPO_VENDEDOR ELSE G.RAIZPAGOS END)COLLATE Latin1_General_CS_AI AS Campo09,
'' AS Campo10
From [ICGTIERRAGRO2017].DBO.ALBVENTACAB A
INNER JOIN [ICGTIERRAGRO2017].DBO.CLIENTES B
ON A.CODCLIENTE = B.CODCLIENTE
INNER JOIN [ICGTIERRAGRO2017].DBO.CLIENTESCAMPOSLIBRES C
ON B.CODCLIENTE = c.CODCLIENTE
INNER JOIN [ICGTIERRAGRO2017].DBO.SERIESCAMPOSLIBRES D
ON A.NUMSERIE = D.SERIE
INNER JOIN [ICGTIERRAGRO2017].DBO.TESORERIA E
ON A.NUMSERIE = E.SERIE AND A.NUMFAC = E.NUMERO
INNER JOIN [ICGTIERRAGRO2017].DBO.VENCIMFPAGO F
ON E.CODTIPOPAGO = F.CODTIPOPAGO
INNER JOIN [ICGTIERRAGRO2017].DBO.TIPOSPAGO G
ON E.CODTIPOPAGO = G.CODTIPOPAGO
INNER JOIN [ICGTIERRAGRO2017].DBO.ALBVENTALIN H
ON A.NUMSERIE = H.NUMSERIE AND A.NUMALBARAN = H.NUMALBARAN
WHERE A.NUMSERIE=@numserie AND A.NUMFAC=@numfac AND E.CODTIPOPAGO NOT IN ('-1') 
GROUP BY A.NUMSERIEFAC,E.CODTIPOPAGO,D.CTA_EFECTIVO,F.CUENTACOBRO,E.IMPORTE,G.RAIZCOBROS,D.SAP_OFICINAS_VENTAS,G.RAIZPAGOS,D.SAP_GRUPO_VENDEDOR;
--RecaudosDatosCliente
INSERT INTO ZZRECAUDOSXML
SELECT TOP 1
'P' AS Campo03,
CASE WHEN RIGHT(A.NUMSERIEFAC,1) IN  ('F','H','G','J','K') THEN '15' WHEN RIGHT(A.NUMSERIEFAC,1) IN ('L','M','N','O','Y') THEN '05'  ELSE '' END AS Campo04,
ISNULL(C.CODCLIENTESAP,'7000000000') AS Campo05,
'' AS Campo06,
CASE WHEN RIGHT(A.NUMSERIEFAC,1) IN  ('F','H','G','J','K') THEN SUM(SUM(DISTINCT E.IMPORTE))OVER(ORDER BY E.IMPORTE DESC) WHEN RIGHT(A.NUMSERIEFAC,1) IN ('Y','M','N','O','Y') THEN SUM(SUM(DISTINCT E.IMPORTE*-1)) OVER(ORDER BY E.IMPORTE DESC) ELSE '' END AS Campo07,
(CASE WHEN G.RAIZCOBROS IS NULL THEN D.SAP_OFICINAS_VENTAS ELSE G.RAIZCOBROS END) COLLATE Latin1_General_CS_AI AS Campo08,
(CASE WHEN G.RAIZPAGOS IS NULL THEN D.SAP_GRUPO_VENDEDOR ELSE G.RAIZPAGOS END) COLLATE Latin1_General_CS_AI AS Campo09,
'' AS Campo10
From [ICGTIERRAGRO2017].DBO.ALBVENTACAB A
INNER JOIN [ICGTIERRAGRO2017].DBO.CLIENTES B
ON A.CODCLIENTE = B.CODCLIENTE
INNER JOIN [ICGTIERRAGRO2017].DBO.CLIENTESCAMPOSLIBRES C
ON B.CODCLIENTE = c.CODCLIENTE
INNER JOIN [ICGTIERRAGRO2017].DBO.SERIESCAMPOSLIBRES D
ON A.NUMSERIE = D.SERIE
INNER JOIN [ICGTIERRAGRO2017].DBO.TESORERIA E
ON A.NUMSERIE = E.SERIE AND A.NUMFAC = E.NUMERO
INNER JOIN [ICGTIERRAGRO2017].DBO.VENCIMFPAGO F
ON E.CODTIPOPAGO = F.CODTIPOPAGO
INNER JOIN [ICGTIERRAGRO2017].DBO.TIPOSPAGO G
ON E.CODTIPOPAGO = G.CODTIPOPAGO
INNER JOIN [ICGTIERRAGRO2017].DBO.ALBVENTALIN H
ON A.NUMSERIE = H.NUMSERIE AND A.NUMALBARAN = H.NUMALBARAN
WHERE A.NUMSERIE=@numserie AND A.NUMFAC=@numfac AND E.CODTIPOPAGO NOT IN ('-1')  
GROUP BY A.NUMSERIEFAC, C.CODCLIENTESAP, E.IMPORTE, G.RAIZCOBROS, D.SAP_OFICINAS_VENTAS, G.RAIZPAGOS, D.SAP_GRUPO_VENDEDOR
ORDER BY CAMPO07 DESC
--XML
SELECT * FROM ZZRECAUDOSXML
FOR XML RAW('DataRecaudo'), ELEMENTS