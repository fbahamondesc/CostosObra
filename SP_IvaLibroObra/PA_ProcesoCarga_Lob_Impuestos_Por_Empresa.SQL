IF OBJECT_ID ( 'PA_ProcesoCarga_Lob_Impuestos_Por_Empresa', 'P' ) IS NOT NULL 
    DROP PROCEDURE PA_ProcesoCarga_Lob_Impuestos_Por_Empresa;
GO
/*****************************************************************************  
Nombre Procedimiento : PA_ProcesoCarga_Lob_Impuestos_Por_Empresa  
Descripcion          : Procedimiento que efectua las cargas de la tabla 
                       LOB_IMPUESTOS y actualiza tablas LOB CERRADO_DETALLE
					   y LOB_BORRADOR_DETALLE con el impuesto correspondiente. 
Fecha de Creacion    : 2019-12-18  
Cliente              : Icafal  
Creado por           : Francisco Bahamondes
******************************************************************************/  
CREATE PROCEDURE PA_ProcesoCarga_Lob_Impuestos_Por_Empresa
	@emp_cod CHAR(5)
AS
BEGIN

PRINT '   Inicia proceso PA_ProcesoCarga_Lob_Impuestos_Por_Empresa (' + convert(VARCHAR(20), getdate(), 120) + ')'

DELETE FROM LOB_IMPUESTOS 
WHERE 1=1
	AND apdoc_id IN (SELECT apdoc_id FROM DOC_APDoc WHERE CpnyID = @emp_cod)
	OR ardoc_id IN (SELECT ardoc_id FROM DOC_ARDOC WHERE CpnyID = @emp_cod)

INSERT INTO [dbo].[LOB_IMPUESTOS]
           ([RefNbr]
           ,[BatNbr]
           ,[PerPost]
           ,[apdoc_id]
           ,[ardoc_id]
           ,[DocType]
           ,[TranTot]
           ,[TaxAmt00]
           ,[TaxAmt01]
           ,[TaxTot])
(
SELECT A.RefNbr
	,A.BatNbr
	,A.PerPost
	,A.apdoc_id
	,Null AS ardoc_id
	,Null as DocType
	,CAST(A.TranTot AS numeric) AS TranTot
	,CAST(A.TaxAmt00 AS numeric) AS TaxAmt00
	,CAST(B.TranAmt AS numeric) AS TaxAmt01
	,CAST(ISNULL(A.TaxAmt00,0) + ISNULL(B.TranAmt,0) AS numeric) AS TaxTot
FROM
/* Agrega montos de impuesto desde DOC_APTran */
(
	SELECT A.apdoc_id
		,A.RefNbr
		,A.BatNbr
		,A.PerPost
		,SUM(A.TranAmt) AS TranTot
		,CASE 
			WHEN SUM(A.TranAmt) < 0
				THEN SUM(A.CuryTaxAmt00 + A.CuryTaxAmt01 + A.CuryTaxAmt02) * - 1
			ELSE SUM(A.CuryTaxAmt00 + A.CuryTaxAmt01 + A.CuryTaxAmt02)
			END AS TaxAmt00
	FROM DOC_APTran A WITH (NOLOCK)
	WHERE A.User1 != '' 
		AND A.CpnyID = @emp_cod
		AND 'EXENTO' NOT IN (A.taxId00, A.taxId01, A.taxId02)
	GROUP BY A.apdoc_id	
		,A.RefNbr
		,A.BatNbr
		,A.PerPost
) A
/* Agrega impuesto especifico */
LEFT JOIN DOC_APTran B WITH (NOLOCK) ON B.apdoc_id = A.apdoc_id 
	AND B.Acct = '110902' 
	AND B.TranAmt != 0 
	AND ('ESPECIFICO' IN (B.taxId00, B.taxId01, B.taxId02) 
		OR B.TranDesc = 'Impuesto Especifico')
WHERE NOT (A.TaxAmt00 = 0 AND B.TranAmt IS NULL) 

UNION
/* Agrega impuestos de modulos AR */
SELECT DISTINCT a.refnbr
		,a.batnbr
		,A.Perpost
		,NULL AS apdoc_id
		,B.ardoc_id
		,A.DocType
		,CAST(B.tranamt AS numeric) as TranTot
		,CASE WHEN A.DocType = 'CM' THEN 
			CAST(B.CuryTaxAmt00 + B.CuryTaxAmt01 + B.CuryTaxAmt02 AS numeric) * -1 
			ELSE CAST(B.CuryTaxAmt00 + B.CuryTaxAmt01 + B.CuryTaxAmt02 AS numeric) END AS TaxAmt00
		,NULL as TaxAmt01
		,CAST(B.CuryTaxAmt00 + B.CuryTaxAmt01 + B.CuryTaxAmt02 AS numeric) AS TaxTot
	FROM DOC_ARDOC A WITH (NOLOCK)
	INNER JOIN DOC_ARTRAN B WITH (NOLOCK) ON A.ardoc_id = B.ardoc_id
	WHERE B.user1 != '' 
		AND (A.TaxTot00 + A.TaxTot01 + A.TaxTot02) != 0
		AND A.CpnyID = @emp_cod
		AND 'EXENTO' NOT IN (A.taxId00, A.taxId01, A.taxId02)
		)
END
PRINT '   Finaliza carga  de tabla LOB_IMPUESTOS (' + convert(VARCHAR(20), getdate(), 120) + ')'

 /* 1.- Actualiza campo TaxAmt con el impuesto proporcional al monto en lob cerrado */
 Print '1.- Actualiza campo TaxAmt con el impuesto proporcional al monto en lob cerrado (' + convert(VARCHAR(20), getdate(), 120) + ')'  
 UPDATE LOB_CERRADO_DETALLE
 SET TaxAmt = CASE WHEN LI.TranTot = 0 THEN 0 ELSE ((LI.TaxTot) * (LC.DrAmt - LC.CrAmt))/LI.TranTot END
	,TaxAmt_uf = CASE WHEN LI.TranTot = 0 THEN 0 ELSE (((LI.TaxTot) * (LC.DrAmt - LC.CrAmt))/LI.TranTot)/LMU.mon_valor END
 FROM LOB_CERRADO_DETALLE LCD WITH (NOLOCK)
 INNER JOIN LOB_CERRADO LC WITH (NOLOCK) ON LCD.Cer_Id = LC.cer_id
 INNER JOIN LOB_MONEDA_UF LMU ON LC.periodo = LMU.mon_periodo
 INNER JOIN LOB_IMPUESTOS LI ON LI.apdoc_id IN (
 	LCD.Aux_apdoc_cl_id
 	,LCD.Aux_apdoc_id
 )
 WHERE 1=1
	AND LCD.TaxAmt IS NULL
	AND LCD.Emp_Cod = @emp_cod
 

 /* 2.- Actualiza TaxTot00 y TranTot con para modulos AR */
 Print '2.- Actualiza TaxTot00 y TranTot con para modulos AR en lob cerrado (' + convert(VARCHAR(20), getdate(), 120) + ')'
 UPDATE LOB_CERRADO_DETALLE
 SET TaxAmt = C.TaxTot
	,TaxAmt_uf = C.TaxTot / LMU.mon_valor
 FROM LOB_CERRADO_DETALLE A WITH (NOLOCK)
 INNER JOIN LOB_CERRADO B WITH (NOLOCK) ON A.Cer_Id = B.cer_id
 INNER JOIN LOB_MONEDA_UF LMU ON B.periodo = LMU.mon_periodo
 INNER JOIN LOB_IMPUESTOS C ON A.RefNbr = C.refnbr
	AND A.Lote = C.batnbr
	AND ((B.DrAmt - B.CrAmt) = C.TranTot
		OR (B.CrAmt - B.DrAmt) = C.TranTot
		)
 where 1=1
	AND A.modulo = 'AR' 
	AND A.TaxAmt IS NULL
	AND A.Emp_Cod = @emp_cod

/* 3.- Actualiza campo TaxAmt con el impuesto proporcional al monto en lob borrador */
 Print '3.- Actualiza campo TaxAmt con el impuesto proporcional al monto en lob borrador (' + convert(VARCHAR(20), getdate(), 120) + ')'
 UPDATE Lob_Borrador_Detalle
 SET TaxAmt = CASE WHEN LI.TranTot = 0 THEN 0 ELSE ((LI.TaxTot) * (LB.DrAmt - LB.CrAmt))/LI.TranTot END
	,TaxAmt_uf = CASE WHEN LI.TranTot = 0 THEN 0 ELSE (((LI.TaxTot) * (LB.DrAmt - LB.CrAmt))/LI.TranTot)/LMU.mon_valor END
 FROM Lob_Borrador_Detalle LCD WITH (NOLOCK)
 INNER JOIN LOB_BORRADOR LB WITH (NOLOCK) ON LCD.Bor_Id = LB.bor_id
 INNER JOIN LOB_MONEDA_UF LMU ON LB.periodo = LMU.mon_periodo
 INNER JOIN LOB_IMPUESTOS LI ON LI.apdoc_id IN (
 	LCD.Aux_apdoc_cl_id
 	,LCD.Aux_apdoc_id
 )
 WHERE 1=1
	AND LCD.TaxAmt IS NULL
	AND LCD.Emp_Cod = @emp_cod
 

 /* 4.- Actualiza TaxTot00 y TranTot con para modulos AR */
 Print '4.- Actualiza TaxTot00 y TranTot con para modulos AR en lob borrador (' + convert(VARCHAR(20), getdate(), 120) + ')'
 UPDATE Lob_Borrador_Detalle
 SET TaxAmt = C.TaxTot
	,TaxAmt_uf = C.TaxTot / LMU.mon_valor
 FROM Lob_Borrador_Detalle A WITH (NOLOCK)
 INNER JOIN LOB_BORRADOR B WITH (NOLOCK) ON A.Bor_Id = B.bor_id
 INNER JOIN LOB_MONEDA_UF LMU ON LMU.mon_periodo = B.periodo
 INNER JOIN LOB_IMPUESTOS C ON A.RefNbr = C.refnbr
	AND A.Lote = C.batnbr
	AND ((B.DrAmt - B.CrAmt) = C.TranTot
		OR (B.CrAmt - B.DrAmt) = C.TranTot
		)
 where 1=1
	AND A.modulo = 'AR' 
	AND A.TaxAmt IS NULL
	AND A.Emp_Cod = @emp_cod

PRINT '   Finaliza proceso PA_ProcesoCarga_Lob_Impuestos_Por_Empresa (' + convert(VARCHAR(20), getdate(), 120) + ')'

GO

