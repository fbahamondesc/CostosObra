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

--PRINT '   Inicia proceso PA_ProcesoCarga_Lob_Impuestos_Por_Empresa (' + convert(VARCHAR(20), getdate(), 120) + ')'

--DELETE FROM LOB_IMPUESTOS WHERE cer_id IN (SELECT cer_id FROM LOB_CERRADO_DETALLE WHERE Emp_Cod = @emp_cod)

--INSERT INTO [dbo].[LOB_IMPUESTOS]
--           ([RefNbr]
--           ,[BatNbr]
--           ,[PerPost]
--           ,[apdoc_id]
--           ,[ardoc_id]
--		   ,[cer_id]
--           ,[DocType]
--           ,[TranTot]
--           ,[TaxAmt00]
--           ,[TaxAmt01]
--           ,[TaxTot])
--(
--SELECT DISTINCT A.RefNbr
--	,A.BatNbr
--	,A.PerPost
--	,A.apdoc_id
--	,Null AS ardoc_id
--	,A.cer_id
--	,Null as DocType
--	,CAST(A.TranTot AS numeric) AS TranTot
--	,CAST(A.TaxAmt00 AS numeric) AS TaxAmt00
--	,CAST(B.TranAmt AS numeric) AS TaxAmt01
--	,CAST(ISNULL(A.TaxAmt00,0) + ISNULL(B.TranAmt,0) AS numeric) AS TaxTot
--FROM
--/* Agrega montos de impuesto desde DOC_APTran */
--(
--	SELECT A.apdoc_id
--		,LC.cer_id
--		,A.RefNbr
--		,A.BatNbr
--		,A.PerPost
--		,A.TranAmt AS TranTot
--		,CASE 
--			WHEN A.TranAmt < 0
--				THEN (A.CuryTaxAmt00 + A.CuryTaxAmt01 + A.CuryTaxAmt02) * - 1
--			ELSE (A.CuryTaxAmt00 + A.CuryTaxAmt01 + A.CuryTaxAmt02)
--			END AS TaxAmt00
--	FROM LOB_CERRADO_DETALLE LCD WITH (NOLOCK)
--	INNER JOIN LOB_CERRADO LC ON LCD.Cer_Id = LC.cer_id
--	INNER JOIN DOC_APTran A  ON 1=1
--		AND A.apdoc_id IN (LCD.Aux_apdoc_cl_id, LCD.Aux_apdoc_id)
--		AND A.TranAmt = LC.DrAmt - LC.CrAmt
--	WHERE A.User1 != '' 
--		AND A.CpnyID = @emp_cod
--		AND 'EXENTO' NOT IN (A.taxId00, A.taxId01, A.taxId02)
--	--GROUP BY A.apdoc_id	
--	--	,A.RefNbr
--	--	,A.BatNbr
--	--	,A.PerPost
--	--	,LC.cer_id
--) A
--/* Agrega impuesto especifico */
--LEFT JOIN DOC_APTran B WITH (NOLOCK) ON B.apdoc_id = A.apdoc_id 
--	AND B.Acct = '110902' 
--	AND B.TranAmt != 0 
--	AND ('ESPECIFICO' IN (B.taxId00, B.taxId01, B.taxId02) 
--		OR B.TranDesc = 'Impuesto Especifico')
--WHERE NOT (A.TaxAmt00 = 0 AND B.TranAmt IS NULL)

--UNION
--/* Agrega impuestos de modulos AR */
--SELECT DISTINCT a.refnbr
--		,a.batnbr
--		,A.Perpost
--		,NULL AS apdoc_id
--		,B.ardoc_id
--		,LC.cer_id
--		,A.DocType
--		,CAST(B.tranamt AS numeric) as TranTot
--		,CASE WHEN A.DocType = 'CM' THEN 
--			CAST(B.CuryTaxAmt00 + B.CuryTaxAmt01 + B.CuryTaxAmt02 AS numeric) * -1 
--			ELSE CAST(B.CuryTaxAmt00 + B.CuryTaxAmt01 + B.CuryTaxAmt02 AS numeric) END AS TaxAmt00
--		,NULL as TaxAmt01
--		,CAST(B.CuryTaxAmt00 + B.CuryTaxAmt01 + B.CuryTaxAmt02 AS numeric) AS TaxTot
--	FROM LOB_CERRADO LC
--	INNER JOIN LOB_CERRADO_DETALLE LCD ON LC.cer_id = LCD.Cer_Id
--	INNER JOIN DOC_ARDOC A WITH (NOLOCK) ON 1=1
--		AND A.refnbr = LCD.RefNbr 
--		AND LCD.Lote = A.batnbr 
--	INNER JOIN DOC_ARTRAN B WITH (NOLOCK) ON A.ardoc_id = B.ardoc_id
--		AND ABS(LC.DrAmt - LC.CrAmt) = CAST(B.tranamt AS numeric)
--	WHERE B.user1 != '' 
--		AND (A.TaxTot00 + A.TaxTot01 + A.TaxTot02) != 0
--		AND A.CpnyID = @emp_cod
--		AND 'EXENTO' NOT IN (A.taxId00, A.taxId01, A.taxId02)
--		AND LCD.Modulo = 'AR' 
--		)
--END
--PRINT '   Finaliza carga  de tabla LOB_IMPUESTOS (' + convert(VARCHAR(20), getdate(), 120) + ')'
 UPDATE LOB_CERRADO_DETALLE SET TaxAmt = 0, TaxAmt_uf = 0 WHERE Emp_Cod = @emp_cod
 /* 1.- Actualiza campo TaxAmt con el impuesto proporcional al monto en lob cerrado */
 Print '1.- Actualiza campo TaxAmt con el impuesto correspondiente al monto en lob cerrado (' + convert(VARCHAR(20), getdate(), 120) + ')'  
 UPDATE LCD
 SET TaxAmt = IMP.TaxTot
	,TaxAmt_uf = IMP.TaxTot /LMU.mon_valor
 FROM LOB_CERRADO_DETALLE LCD WITH (NOLOCK)
 INNER JOIN LOB_MONEDA_UF LMU ON LMU.mon_periodo = LCD.Periodo
 INNER JOIN (
			SELECT DISTINCT A.RefNbr
				,A.BatNbr
				,A.PerPost
				,A.apdoc_id
				,Null AS ardoc_id
				,A.cer_id
				,Null as DocType
				,CAST(A.TranTot AS numeric) AS TranTot
				,CAST(A.TaxAmt00 AS numeric) AS TaxAmt00
				,CAST(B.TranAmt AS numeric) AS TaxAmt01
				,CAST(ISNULL(A.TaxAmt00,0) + ISNULL(B.TranAmt,0) AS numeric) AS TaxTot
			FROM
			/* Agrega montos de impuesto desde DOC_APTran */
			(
				SELECT A.apdoc_id
					,LC.cer_id
					,A.RefNbr
					,A.BatNbr
					,A.PerPost
					,A.TranAmt AS TranTot
					,CASE 
						WHEN LC.DrAmt - LC.CrAmt < 0
							THEN (A.CuryTaxAmt00 + A.CuryTaxAmt01 + A.CuryTaxAmt02) * - 1
						ELSE (A.CuryTaxAmt00 + A.CuryTaxAmt01 + A.CuryTaxAmt02)
						END AS TaxAmt00
				FROM LOB_CERRADO_DETALLE LCD WITH (NOLOCK)
				INNER JOIN LOB_CERRADO LC ON LCD.Cer_Id = LC.cer_id
				INNER JOIN DOC_APTran A  ON 1=1
					AND A.apdoc_id IN (LCD.Aux_apdoc_cl_id, LCD.Aux_apdoc_id)
					AND A.TranAmt = ABS(LC.DrAmt - LC.CrAmt)
					--AND A.BatNbr = LCD.Lote
					AND A.RefNbr = LCD.RefNbr
				WHERE A.User1 != '' 
					AND LCD.Emp_Cod = @emp_cod
					AND 'EXENTO' NOT IN (A.taxId00, A.taxId01, A.taxId02)
					AND NOT( A.Acct = '110902' 
					AND ('ESPECIFICO' IN (A.taxId00, A.taxId01, A.taxId02) 
					OR A.TranDesc = 'Impuesto Especifico'))
				--GROUP BY A.apdoc_id	
				--	,A.RefNbr
				--	,A.BatNbr
				--	,A.PerPost
				--	,LC.cer_id
			) A
			/* Agrega impuesto especifico */
			LEFT JOIN DOC_APTran B WITH (NOLOCK) ON B.apdoc_id = A.apdoc_id 
				AND B.Acct = '110902' 
				AND B.TranAmt != 0 
				AND ('ESPECIFICO' IN (B.taxId00, B.taxId01, B.taxId02) 
					OR B.TranDesc = 'Impuesto Especifico')
			WHERE NOT (A.TaxAmt00 = 0)

			UNION
			/* Agrega impuestos de modulos AR */
			SELECT DISTINCT a.refnbr
					,a.batnbr
					,A.Perpost
					,NULL AS apdoc_id
					,B.ardoc_id
					,LC.cer_id
					,A.DocType
					,CAST(B.tranamt AS numeric) as TranTot
					,CASE WHEN A.DocType = 'CM' THEN 
						CAST(B.CuryTaxAmt00 + B.CuryTaxAmt01 + B.CuryTaxAmt02 AS numeric) * -1 
						ELSE CAST(B.CuryTaxAmt00 + B.CuryTaxAmt01 + B.CuryTaxAmt02 AS numeric) END AS TaxAmt00
					,NULL as TaxAmt01
					,CAST(B.CuryTaxAmt00 + B.CuryTaxAmt01 + B.CuryTaxAmt02 AS numeric) AS TaxTot
				FROM LOB_CERRADO LC
				INNER JOIN LOB_CERRADO_DETALLE LCD ON LC.cer_id = LCD.Cer_Id
				INNER JOIN DOC_ARDOC A WITH (NOLOCK) ON 1=1
					AND A.refnbr = LCD.RefNbr 
					AND LCD.Lote = A.batnbr 
				INNER JOIN DOC_ARTRAN B WITH (NOLOCK) ON A.ardoc_id = B.ardoc_id
					AND ABS(LC.DrAmt - LC.CrAmt) = CAST(B.tranamt AS numeric)
				WHERE B.user1 != '' 
					AND (A.TaxTot00 + A.TaxTot01 + A.TaxTot02) != 0
					AND LCD.Emp_Cod = @emp_cod
					AND 'EXENTO' NOT IN (A.taxId00, A.taxId01, A.taxId02)
					AND LCD.Modulo = 'AR' 
			 ) AS IMP ON IMP.cer_id = LCD.cer_id
 

/* 2.- Actualiza campo TaxAmt con el impuesto proporcional al monto en lob borrador */
UPDATE LOB_BORRADOR_DETALLE SET TaxAmt = 0, TaxAmt_uf = 0 WHERE Emp_Cod = @emp_cod
 Print '2.- Actualiza campo TaxAmt con el impuesto correspondiente al monto en lob borrador (' + convert(VARCHAR(20), getdate(), 120) + ')'
 UPDATE Lob_Borrador_Detalle
 SET TaxAmt = IMP.TaxTot
	,TaxAmt_uf = IMP.TaxTot/LMU.mon_valor
 FROM Lob_Borrador_Detalle LBD WITH (NOLOCK)
 INNER JOIN LOB_MONEDA_UF LMU ON LBD.periodo = LMU.mon_periodo
 INNER JOIN (
	SELECT DISTINCT A.RefNbr
	,A.BatNbr
	,A.PerPost
	,A.apdoc_id
	,Null AS ardoc_id
	,A.bor_id
	,Null as DocType
	,CAST(A.TranTot AS numeric) AS TranTot
	,CAST(A.TaxAmt00 AS numeric) AS TaxAmt00
	,CAST(B.TranAmt AS numeric) AS TaxAmt01
	,CAST(ISNULL(A.TaxAmt00,0) + ISNULL(B.TranAmt,0) AS numeric) AS TaxTot
FROM
/* Agrega montos de impuesto desde DOC_APTran */
(
	SELECT A.apdoc_id
		,LB.bor_id
		,A.RefNbr
		,A.BatNbr
		,A.PerPost
		,A.TranAmt AS TranTot
		,CASE 
			WHEN LB.DrAmt - LB.CrAmt < 0
				THEN (A.CuryTaxAmt00 + A.CuryTaxAmt01 + A.CuryTaxAmt02) * - 1
			ELSE (A.CuryTaxAmt00 + A.CuryTaxAmt01 + A.CuryTaxAmt02)
			END AS TaxAmt00
	FROM Lob_Borrador_Detalle LBD WITH (NOLOCK)
	INNER JOIN LOB_BORRADOR LB ON LBD.Bor_Id = LB.bor_id
	INNER JOIN DOC_APTran A  ON 1=1
		AND A.apdoc_id IN (LBD.Aux_apdoc_cl_id, LBD.Aux_apdoc_id)
		AND A.TranAmt = ABS(LB.DrAmt - LB.CrAmt)
		--AND A.BatNbr = LBD.Lote
		AND A.RefNbr = LBD.RefNbr
	WHERE A.User1 != '' 
		AND LBD.Emp_Cod = @emp_cod
		AND 'EXENTO' NOT IN (A.taxId00, A.taxId01, A.taxId02)
		AND NOT( A.Acct = '110902' 
			AND ('ESPECIFICO' IN (A.taxId00, A.taxId01, A.taxId02) 
			OR A.TranDesc = 'Impuesto Especifico'))
	--GROUP BY A.apdoc_id	
	--	,A.RefNbr
	--	,A.BatNbr
	--	,A.PerPost
	--	,LC.cer_id
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
		,LB.bor_id
		,A.DocType
		,CAST(B.tranamt AS numeric) as TranTot
		,CASE WHEN A.DocType = 'CM' THEN 
			CAST(B.CuryTaxAmt00 + B.CuryTaxAmt01 + B.CuryTaxAmt02 AS numeric) * -1 
			ELSE CAST(B.CuryTaxAmt00 + B.CuryTaxAmt01 + B.CuryTaxAmt02 AS numeric) END AS TaxAmt00
		,NULL as TaxAmt01
		,CAST(B.CuryTaxAmt00 + B.CuryTaxAmt01 + B.CuryTaxAmt02 AS numeric) AS TaxTot
	FROM LOB_BORRADOR LB
	INNER JOIN Lob_Borrador_Detalle LBD ON LB.bor_id = LBD.Bor_Id
	INNER JOIN DOC_ARDOC A WITH (NOLOCK) ON 1=1
		AND A.refnbr = LBD.RefNbr 
		AND LBD.Lote = A.batnbr 
	INNER JOIN DOC_ARTRAN B WITH (NOLOCK) ON A.ardoc_id = B.ardoc_id
		AND ABS(LB.DrAmt - LB.CrAmt) = CAST(B.tranamt AS numeric)
	WHERE B.user1 != '' 
		AND (A.TaxTot00 + A.TaxTot01 + A.TaxTot02) != 0
		AND LBD.Emp_Cod = @emp_cod
		AND 'EXENTO' NOT IN (A.taxId00, A.taxId01, A.taxId02)
		AND LBD.Modulo = 'AR' 
 ) AS IMP ON LBD.Bor_Id = IMP.bor_id
 WHERE 1=1
	AND LBD.Emp_Cod = @emp_cod
 


PRINT '   Finaliza proceso PA_ProcesoCarga_Lob_Impuestos_Por_Empresa (' + convert(VARCHAR(20), getdate(), 120) + ')'
END
GO

