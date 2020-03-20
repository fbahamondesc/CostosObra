IF OBJECT_ID ( 'PA_ProcesoCarga_Lob_Impuestos', 'P' ) IS NOT NULL 
    DROP PROCEDURE PA_ProcesoCarga_Lob_Impuestos;
GO
/*****************************************************************************  
Nombre Procedimiento : PA_ProcesoCarga_Lob_Impuestos  
Descripcion          : Procedimiento que efectua las cargas de la tabla 
                       LOB_IMPUESTOS. 
Fecha de Creacion    : 2019-12-18  
Cliente              : Icafal  
Creado por           : Francisco Bahamondes
******************************************************************************/  
CREATE PROCEDURE PA_ProcesoCarga_Lob_Impuestos
AS
BEGIN

PRINT '   Inicia proceso carga LOB_IMPUESTOS (' + convert(VARCHAR(20), getdate(), 120) + ')'

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
		AND (A.TaxTot00 + A.TaxTot01 + A.TaxTot02) != 0) 
		
EXCEPT
SELECT [RefNbr]
    ,[BatNbr]
    ,[PerPost]
    ,[apdoc_id]
    ,[ardoc_id]
    ,[DocType]
    ,[TranTot]
    ,[TaxAmt00]
    ,[TaxAmt01]
    ,[TaxTot]
FROM [BxO_DATA].[dbo].[LOB_IMPUESTOS]
END
PRINT '   Finaliza proceso carga LOB_RESUMEN_DETALLE (' + convert(VARCHAR(20), getdate(), 120) + ')'
GO
