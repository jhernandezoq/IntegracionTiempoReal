DECLARE 
@numserie NVARCHAR(MAX),
@numfac NVARCHAR(MAX),
@CANJEO INT 
SET @numserie='AAAF'
SET @numfac='178203'
SET @CANJEO = (SELECT VALOR FROM PARAMETROS WHERE CLAVE = 'FIDEL' AND SUBCLAVE = 'EDTOS')


--RECAUDOS
truncate table ZZRECAUDOSXML;
insert into ZZRECAUDOSXML
select top 1
	'C' as Campo03,
	'Z001' as Campo04,
	'1000'as Campo05,
	'' as Campo06,
	(SELECT FORMAT(A.Fecha,N'yyyyMMdd')) as Campo07,
	(SELECT FORMAT(A.Fecha,N'yyyyMMdd')) as Campo08,
	'COP' as Campo09,
	LTRIM(A.NUMSERIE) + REPLICATE('0',12-LEN(A.NUMFAC))+LTRIM(A.NUMFAC) AS Campo10
From ALBVENTACAB A
	inner join CLIENTES B
	on A.CODCLIENTE = B.CODCLIENTE
	inner Join CLIENTESCAMPOSLIBRES C
	on B.CODCLIENTE = C.CODCLIENTE
	inner Join SERIESCAMPOSLIBRES D
	on A.NUMSERIE = D.SERIE
	inner Join TESORERIA E
	on D.SERIE = E.SERIE AND A.NUMFAC = E.NUMERO
	inner Join VENCIMFPAGO F
	on E.CODTIPOPAGO = F.CODTIPOPAGO
	inner Join TIPOSPAGO G
	on E.CODTIPOPAGO = G.CODTIPOPAGO
	inner Join ALBVENTALIN H
	on A.NUMSERIE = H.NUMSERIE AND A.NUMALBARAN = H.NUMALBARAN
where A.NUMSERIE=@numserie AND A.NUMFAC=@numfac AND E.CODTIPOPAGO NOT IN ('-1');
--RecaudosMedioDePago
Insert into ZZRECAUDOSXML
Select  
	'P' as Campo03,
	CASE WHEN RIGHT(A.NUMSERIEFAC,1) IN  ('F','H','G','J','K') THEN '40' WHEN RIGHT(A.NUMSERIEFAC,1) IN ('L','M','N','O','Y') THEN '50'  ELSE '' END as Campo04,
	CASE WHEN E.CODTIPOPAGO='1' THEN LEFT(D.CTA_EFECTIVO,10)ELSE F.CUENTACOBRO	END COLLATE Latin1_General_CS_AI as Campo05,
	'' as Campo06,
	CASE WHEN RIGHT(A.NUMSERIEFAC,1) IN  ('F','H','G','J','K') THEN (E.IMPORTE) WHEN RIGHT(A.NUMSERIEFAC,1) IN ('Y','M','N','O','Y') THEN (ABS(E.IMPORTE))  ELSE '' END as Campo07,
	(CASE WHEN G.RAIZCOBROS IS NULL THEN D.SAP_OFICINAS_VENTAS ELSE G.RAIZCOBROS END)COLLATE Latin1_General_CS_AI as Campo08,
	(CASE WHEN G.RAIZPAGOS IS NULL THEN D.SAP_GRUPO_VENDEDOR ELSE G.RAIZPAGOS END)COLLATE Latin1_General_CS_AI as Campo09,
	'' as Campo10
From ALBVENTACAB A
	inner join CLIENTES B
	on A.CODCLIENTE = B.CODCLIENTE
	inner Join CLIENTESCAMPOSLIBRES C
	on B.CODCLIENTE = c.CODCLIENTE
	inner Join SERIESCAMPOSLIBRES D
	on A.NUMSERIE = D.SERIE
	inner Join TESORERIA E
	on A.NUMSERIE = E.SERIE AND A.NUMFAC = E.NUMERO
	inner Join VENCIMFPAGO F
	on E.CODTIPOPAGO = F.CODTIPOPAGO
	inner Join TIPOSPAGO G
	on E.CODTIPOPAGO = G.CODTIPOPAGO
	inner Join ALBVENTALIN H
	on A.NUMSERIE = H.NUMSERIE AND A.NUMALBARAN = H.NUMALBARAN
where A.NUMSERIE=@numserie AND A.NUMFAC=@numfac AND E.CODTIPOPAGO NOT IN ('-1') 
GROUP BY A.NUMSERIEFAC,E.CODTIPOPAGO,D.CTA_EFECTIVO,F.CUENTACOBRO,E.IMPORTE,G.RAIZCOBROS,D.SAP_OFICINAS_VENTAS,G.RAIZPAGOS,D.SAP_GRUPO_VENDEDOR;
--RecaudosDatosCliente
Insert into ZZRECAUDOSXML
Select TOP 1
	'P' as Campo03,
	CASE WHEN RIGHT(A.NUMSERIEFAC,1) IN  ('F','H','G','J','K') THEN '15' WHEN RIGHT(A.NUMSERIEFAC,1) IN ('L','M','N','O','Y') THEN '05'  ELSE '' END as Campo04,
	ISNULL(C.CODCLIENTESAP,'7000000000') as Campo05,
	'' as Campo06,
	CASE WHEN RIGHT(A.NUMSERIEFAC,1) IN  ('F','H','G','J','K') THEN SUM(SUM(DISTINCT E.IMPORTE))OVER(ORDER BY E.IMPORTE DESC) WHEN RIGHT(A.NUMSERIEFAC,1) IN ('Y','M','N','O','Y') THEN (ABS(E.IMPORTE)) ELSE '' END as Campo07,
	(CASE WHEN G.RAIZCOBROS IS NULL THEN D.SAP_OFICINAS_VENTAS ELSE G.RAIZCOBROS END) COLLATE Latin1_General_CS_AI as Campo08,
	(CASE WHEN G.RAIZPAGOS IS NULL THEN D.SAP_GRUPO_VENDEDOR ELSE G.RAIZPAGOS END) COLLATE Latin1_General_CS_AI as Campo09,
	'' as Campo10
From ALBVENTACAB A
	inner join CLIENTES B
	on A.CODCLIENTE = B.CODCLIENTE
	inner Join CLIENTESCAMPOSLIBRES C
	on B.CODCLIENTE = c.CODCLIENTE
	inner Join SERIESCAMPOSLIBRES D
	on A.NUMSERIE = D.SERIE
	inner Join TESORERIA E
	on A.NUMSERIE = E.SERIE AND A.NUMFAC = E.NUMERO
	inner Join VENCIMFPAGO F
	on E.CODTIPOPAGO = F.CODTIPOPAGO
	inner Join TIPOSPAGO G
	on E.CODTIPOPAGO = G.CODTIPOPAGO
	inner Join ALBVENTALIN H
	on A.NUMSERIE = H.NUMSERIE AND A.NUMALBARAN = H.NUMALBARAN
where A.NUMSERIE=@numserie AND A.NUMFAC=@numfac AND E.CODTIPOPAGO NOT IN ('-1')  
GROUP BY A.NUMSERIEFAC, C.CODCLIENTESAP, E.IMPORTE, G.RAIZCOBROS, D.SAP_OFICINAS_VENTAS, G.RAIZPAGOS, D.SAP_GRUPO_VENDEDOR
ORDER BY CAMPO07 DESC

--ENCABEZADOS




SELECT 

(
	select top 1
		'Z001' as TipoInterfaz,
		SUBSTRING(E.SAP_DEN_SOC_FINAN,1,4) as SAP_DEN_SOC_FINAN,
		CASE WHEN RIGHT(C.NUMSERIEFAC,1) IN  ('F','H','G','J','K') THEN 'ZPOS' WHEN RIGHT(C.NUMSERIEFAC,1) IN ('L','M','N','O','Y') THEN 'YPOS'  ELSE '' END AS ClaseDocumento,
		CASE WHEN F.ABONODE_NUMALBARAN = -1 THEN '' ELSE G.NUMSERIEFAC+REPLICATE('0',12-LEN(LTRIM((G.NUMFAC))))+LTRIM(G.NUMFAC) END AS ReferenciaDocumento,
		E.SAP_ORG_VENTAS as OrgVentaSAP,
		'0' as MonedaDocumento,
		'' as Sector,
		CASE WHEN I.RAIZCOBROS IS NOT NULL THEN I.RAIZCOBROS ELSE E.SAP_OFICINAS_VENTAS  END AS OficinaVentaSAP,
		CASE WHEN I.RAIZPAGOS IS NOT NULL THEN I.RAIZPAGOS ELSE E.SAP_GRUPO_VENDEDOR END AS GrupoVendedorSAP,
		ISNULL(B.CODCLIENTESAP,'7000000000') as CodigoClienteSAP, 
		CASE WHEN B.CODCLIENTESAP IS NULL THEN (SELECT NOMBRECLIENTE FROM CLIENTES WHERE CODCLIENTE='7000627') ELSE A.NOMBRECLIENTE END AS NombreCliente, 
		CASE WHEN B.CODCLIENTESAP IS NULL THEN (SELECT DIRECCION1 FROM CLIENTES WHERE CODCLIENTE='7000627') ELSE A.DIRECCION1 END AS Direccion1, 
		CASE WHEN B.CODCLIENTESAP IS NULL THEN (SELECT PROVINCIA FROM CLIENTES WHERE CODCLIENTE='7000627') ELSE A.PROVINCIA END AS Poblacion, 
		CASE WHEN B.CODCLIENTESAP IS NULL THEN (SELECT POBLACION FROM CLIENTES WHERE CODCLIENTE='7000627') ELSE A.POBLACION END AS RegionSAP,
		CASE WHEN B.CODCLIENTESAP IS NULL THEN (SELECT TELEFONO1 FROM CLIENTES WHERE CODCLIENTE='7000627') ELSE  A.TELEFONO1 END AS Telefono1, 
		ISNULL(B.CODCLIENTESAP,'7000000000') as Destinatario,
		LTRIM(C.NUMSERIE) + REPLICATE('0',12-LEN(C.NUMFAC))+LTRIM(C.NUMFAC) AS NumeroSAP,
		(SELECT FORMAT(C.Fecha,N'yyyyMMdd')) as Fecha,
		(SELECT FORMAT(C.Fecha,N'yyyyMMdd')) as FechaEntrega,
		(SELECT FORMAT(C.Fecha,N'yyyyMMdd')) as FechaPrecio,
		'0' as Moneda,
		'0' as TipoCambio,
		'0' as CondicionPago,
		'0' as CondicionExpedicion,
		'0' as Texto, 
		SUBSTRING (D.MOTIVO_DE_PEDIDO,1,3) as MotivoPedido
	from CLIENTES A
		inner join CLIENTESCAMPOSLIBRES B
		on A.CODCLIENTE = B.CODCLIENTE
		inner join ALBVENTACAB    C
		on A.CODCLIENTE = C.CODCLIENTE
		Inner Join FACTURASVENTACAMPOSLIBRES D
		on C.NUMSERIE= D.NUMSERIE
		Inner Join SERIESCAMPOSLIBRES E
		on C.NUMSERIE = E.SERIE
		Inner Join ALBVENTALIN F
		on C.NUMSERIE = F.NUMSERIE AND C.NUMALBARAN = F.NUMALBARAN
		Left Join ITG_ENC2 G
		on C.NUMSERIE = G.NUMSERIE_ENC AND C.NUMALBARAN = G.NUMALBARAN_ENC
		Inner Join TESORERIA H
		on C.NUMSERIE = H.SERIE AND C.NUMFAC = H.NUMERO
		Inner Join TIPOSPAGO I
		on H.CODTIPOPAGO = i.CODTIPOPAGO
	where C.NUMSERIE=@numserie AND C.NUMFAC=@numfac FOR JSON PATH ) DataVentasEnc,

--POSICIONES

(
	select 
		CASE WHEN RIGHT(A.NUMSERIEFAC,1) IN  ('F','H','G','J','K') THEN 'ZPOS' WHEN RIGHT(A.NUMSERIEFAC,1) IN ('L','M','N','O','Y') THEN 'YPOS' ELSE '' END as ClaseDoc, 
		LTRIM(A.NUMSERIE) + REPLICATE('0',12-LEN(A.NUMFAC))+LTRIM(A.NUMFAC) AS NumeroSAP,
		B.NUMLIN*10 AS Linea,
		B.REFERENCIA AS Material, 
		CASE WHEN RIGHT (A.NUMSERIEFAC,1)IN('F','H','G','J','K') THEN CAST(B.UNIDADESTOTAL AS INT) WHEN RIGHT(A.NUMSERIEFAC,1) IN ('L','M','N','O','Y') THEN CAST(B.UNIDADESTOTAL*-1 AS INT) END AS Cantidad,
		ISNULL(F.UNIDADMEDIDA,'') AS UnidadMedida, 
		CASE
		WHEN RIGHT(A.NUMSERIEFAC,1) IN ('F','H','G','J','K') AND F.DPTO IN ('6')  AND B.REFERENCIA NOT IN ('200301') THEN 'TAX' 
		WHEN RIGHT(A.NUMSERIEFAC,1) IN ('F','H','G','J','K') AND F.DPTO IN ('6')  AND B.REFERENCIA IN ('200301') THEN 'ZFFR'
		WHEN RIGHT(A.NUMSERIEFAC,1) IN ('L','M','N','O','Y') AND F.DPTO IN ('6')  AND B.REFERENCIA NOT IN ('200301') THEN 'ZTX1' 
		WHEN RIGHT(A.NUMSERIEFAC,1) IN ('L','M','N','O','Y') AND F.DPTO IN ('6') AND B.REFERENCIA IN ('200301') THEN 'ZTXF' 
		WHEN RIGHT(A.NUMSERIEFAC,1) IN  ('F','H','G','J','K') AND F.DESCRIPCION  NOT IN ('IMPUESTO AL CONSUMO BOLSA%') THEN 'ZPOS'
		WHEN RIGHT(A.NUMSERIEFAC,1) IN  ('F','H','G','J','K') AND F.DESCRIPCION IN ('IMPUESTO AL CONSUMO BOLSA%') THEN 'ZBOL'
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
		CASE WHEN (A.PUNTOSACUM > 0 AND RIGHT(A.NUMSERIE,1) IN  ('F','H','G','J','K')) THEN ROUND((B.TOTALEXPANSION/1000)*@CANJEO,-0) WHEN (A.PUNTOSACUM <> 0 AND RIGHT(A.NUMSERIE,1) IN ('L','M','N','O','Y')) THEN ROUND((B.TOTALEXPANSION/1000)*-1*@CANJEO,-0) ELSE 0*1 END AS ImporteProvisionSoles,
		CASE WHEN (A.PUNTOSACUM > 0 AND RIGHT(A.NUMSERIE,1) IN  ('F','H','G','J','K')) THEN ROUND((B.TOTALEXPANSION/1000)*@CANJEO,-0) WHEN (A.PUNTOSACUM <> 0 AND RIGHT(A.NUMSERIE,1) IN ('L','M','N','O','Y')) THEN ROUND((B.TOTALEXPANSION/1000)*-1*@CANJEO,-0) ELSE 0*1 END AS ValorProvisionSoles
	FROM ALBVENTACAB A
		INNER JOIN ALBVENTALIN B ON A.NUMSERIE = B.NUMSERIE AND A.NUMALBARAN = B.NUMALBARAN AND A.N = B.N
		INNER JOIN SERIESCAMPOSLIBRES C ON A.NUMSERIE = C.SERIE
		LEFT  JOIN CLIENTESCAMPOSLIBRES D ON A.CODCLIENTE = D.CODCLIENTE 
		LEFT  JOIN CLIENTES E ON A.CODCLIENTE = E.CODCLIENTE
		INNER JOIN ARTICULOS F ON B.CODARTICULO = F.CODARTICULO
		INNER JOIN ALMACEN G ON B.CODALMACEN = G.CODALMACEN
	where A.NUMSERIE=@numserie AND A.NUMFAC=@numfac FOR JSON PATH ) DataVentasDet,
(
	SELECT * FROM ZZRECAUDOSXML FOR JSON PATH ) DataRecaudo 


FOR JSON PATH