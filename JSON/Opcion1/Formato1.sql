DECLARE 
@numserie NVARCHAR(MAX),
@numfac NVARCHAR(MAX),
@CANJEO INT 
SET @numserie='AAAF'
SET @numfac='178203'
SET @CANJEO = (SELECT VALOR FROM [ICGTIERRAGRO2017].DBO.PARAMETROS WHERE CLAVE = 'FIDEL' AND SUBCLAVE = 'EDTOS')
TRUNCATE TABLE ZZRECAUDOSXML;



--RecaudosCabecera
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
--ENCABEZADOS




SELECT 

(
	SELECT TOP 1
		'Z001' AS TipoInterfaz,
		SUBSTRING(E.SAP_DEN_SOC_FINAN,1,4) AS SAP_DEN_SOC_FINAN,
		CASE WHEN RIGHT(C.NUMSERIEFAC,1) IN  ('F','H','G','J','K') THEN 'ZPOS' WHEN RIGHT(C.NUMSERIEFAC,1) IN ('L','M','N','O','Y') THEN 'YPOS'  ELSE '' END AS ClaseDocumento,
		CASE WHEN F.ABONODE_NUMALBARAN = -1 THEN '' ELSE G.NUMSERIEFAC+REPLICATE('0',12-LEN(LTRIM((G.NUMFAC))))+LTRIM(G.NUMFAC) END AS ReferenciaDocumento,
		E.SAP_ORG_VENTAS AS OrgVentaSAP,
		'0' AS MonedaDocumento,
		'' AS Sector,
		CASE WHEN I.RAIZCOBROS IS NOT NULL THEN I.RAIZCOBROS ELSE E.SAP_OFICINAS_VENTAS  END AS OficinaVentaSAP,
		CASE WHEN I.RAIZPAGOS IS NOT NULL THEN I.RAIZPAGOS ELSE E.SAP_GRUPO_VENDEDOR END AS GrupoVendedorSAP,
		ISNULL(B.CODCLIENTESAP,'') AS CodigoClienteSAP, 
		ISNULL(A.NOMBRECLIENTE,'') AS NombreCliente, 
		ISNULL(A.DIRECCION1,'') AS Direccion1, 
		ISNULL(A.PROVINCIA,'') AS Poblacion, 
		ISNULL(A.POBLACION,'') AS RegionSAP,
		ISNULL(A.TELEFONO1,'') AS Telefono1, 
		ISNULL(B.CODCLIENTESAP,'') AS Destinatario,
		LTRIM(C.NUMSERIE) + REPLICATE('0',12-LEN(C.NUMFAC))+LTRIM(C.NUMFAC) AS NumeroSAP,
		(SELECT FORMAT(C.Fecha,N'yyyyMMdd')) AS Fecha,
		(SELECT FORMAT(C.Fecha,N'yyyyMMdd')) AS FechaEntrega,
		(SELECT FORMAT(C.Fecha,N'yyyyMMdd')) AS FechaPrecio,
		'0' AS Moneda,
		'0' AS TipoCambio,
		'0' AS CondicionPago,
		'0' AS CondicionExpedicion,
		'0' AS Texto, 
		SUBSTRING (D.MOTIVO_DE_PEDIDO,1,3) AS MotivoPedido
	FROM [ICGTIERRAGRO2017].DBO.CLIENTES A
		INNER JOIN [ICGTIERRAGRO2017].DBO.CLIENTESCAMPOSLIBRES B
		ON A.CODCLIENTE = B.CODCLIENTE
		INNER JOIN [ICGTIERRAGRO2017].DBO.ALBVENTACAB    C
		ON A.CODCLIENTE = C.CODCLIENTE
		INNER JOIN [ICGTIERRAGRO2017].DBO.FACTURASVENTACAMPOSLIBRES D
		ON C.NUMSERIE= D.NUMSERIE
		INNER JOIN [ICGTIERRAGRO2017].DBO.SERIESCAMPOSLIBRES E
		ON C.NUMSERIE = E.SERIE
		INNER JOIN [ICGTIERRAGRO2017].DBO.ALBVENTALIN F
		ON C.NUMSERIE = F.NUMSERIE AND C.NUMALBARAN = F.NUMALBARAN
		LEFT JOIN ITG_ENC2 G
		ON C.NUMSERIE = G.NUMSERIE_ENC AND C.NUMALBARAN = G.NUMALBARAN_ENC
		INNER JOIN [ICGTIERRAGRO2017].DBO.TESORERIA H
		ON C.NUMSERIE = H.SERIE AND C.NUMFAC = H.NUMERO
		INNER JOIN [ICGTIERRAGRO2017].DBO.TIPOSPAGO I
		ON H.CODTIPOPAGO = i.CODTIPOPAGO
	WHERE C.NUMSERIE=@numserie AND C.NUMFAC=@numfac FOR JSON PATH ) DataVentasEnc,

--POSICIONES

(
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
	WHERE A.NUMSERIE=@numserie AND A.NUMFAC=@numfac FOR JSON PATH ) DataVentasDet,
(
	SELECT * FROM ZZRECAUDOSXML FOR JSON PATH ) DataRecaudo 


FOR JSON PATH