DECLARE @emp_cod CHAR(6) = '0102'

--SELECT DISTINCT A.RefNbr
--			,A.BatNbr
--			,A.PerPost
--			,A.apdoc_id
--			,Null AS ardoc_id
--			,A.cer_id
--			,Null as DocType
--			,CAST(A.TranTot AS numeric) AS TranTot
--			,CAST(A.TaxAmt00 AS numeric) AS TaxAmt00
--			,CAST(B.TranAmt AS numeric) AS TaxAmt01
--			,CAST(ISNULL(A.TaxAmt00,0) + ISNULL(B.TranAmt,0) AS numeric) AS TaxTot
--		FROM
--		/* Agrega montos de impuesto desde DOC_APTran */
--		(
--			SELECT A.apdoc_id
--				,LC.cer_id
--				,A.RefNbr
--				,A.BatNbr
--				,A.PerPost
--				,A.TranAmt AS TranTot
--				,CASE 
--					WHEN A.TranAmt < 0
--						THEN (A.CuryTaxAmt00 + A.CuryTaxAmt01 + A.CuryTaxAmt02) * - 1
--					ELSE (A.CuryTaxAmt00 + A.CuryTaxAmt01 + A.CuryTaxAmt02)
--					END AS TaxAmt00
--			FROM LOB_CERRADO_DETALLE LCD WITH (NOLOCK)
--			INNER JOIN LOB_CERRADO LC ON LCD.Cer_Id = LC.cer_id
--			INNER JOIN DOC_APTran A  ON 1=1
--				AND A.apdoc_id IN (LCD.Aux_apdoc_cl_id, LCD.Aux_apdoc_id)
--				AND A.TranAmt = LC.DrAmt - LC.CrAmt
--				AND A.BatNbr = LCD.Lote
--				AND A.RefNbr = LCD.RefNbr
--			WHERE A.User1 != '' 
--				AND LCD.Emp_Cod = @emp_cod
--				AND 'EXENTO' NOT IN (A.taxId00, A.taxId01, A.taxId02)
--				AND NOT( A.Acct = '110902' 
--				AND ('ESPECIFICO' IN (A.taxId00, A.taxId01, A.taxId02) 
--				OR A.TranDesc = 'Impuesto Especifico'))
--			--GROUP BY A.apdoc_id	
--			--	,A.RefNbr
--			--	,A.BatNbr
--			--	,A.PerPost
--			--	,LC.cer_id
--		) A
--		/* Agrega impuesto especifico */
--		LEFT JOIN DOC_APTran B WITH (NOLOCK) ON B.apdoc_id = A.apdoc_id 
--			AND B.Acct = '110902' 
--			AND B.TranAmt != 0 
--			AND ('ESPECIFICO' IN (B.taxId00, B.taxId01, B.taxId02) 
--				OR B.TranDesc = 'Impuesto Especifico')
--		WHERE NOT (A.TaxAmt00 = 0)

--		--UNION
--		--SELECT * FROM 

--		UNION
--		/* Agrega impuestos de modulos AR */
--		SELECT DISTINCT a.refnbr
--				,a.batnbr
--				,A.Perpost
--				,NULL AS apdoc_id
--				,B.ardoc_id
--				,LC.cer_id
--				,A.DocType
--				,CAST(B.tranamt AS numeric) as TranTot
--				,CASE WHEN A.DocType = 'CM' THEN 
--					CAST(B.CuryTaxAmt00 + B.CuryTaxAmt01 + B.CuryTaxAmt02 AS numeric) * -1 
--					ELSE CAST(B.CuryTaxAmt00 + B.CuryTaxAmt01 + B.CuryTaxAmt02 AS numeric) END AS TaxAmt00
--				,NULL as TaxAmt01
--				,CAST(B.CuryTaxAmt00 + B.CuryTaxAmt01 + B.CuryTaxAmt02 AS numeric) AS TaxTot
--			FROM LOB_CERRADO LC
--			INNER JOIN LOB_CERRADO_DETALLE LCD ON LC.cer_id = LCD.Cer_Id
--			INNER JOIN DOC_ARDOC A WITH (NOLOCK) ON 1=1
--				AND A.refnbr = LCD.RefNbr 
--				AND LCD.Lote = A.batnbr 
--			INNER JOIN DOC_ARTRAN B WITH (NOLOCK) ON A.ardoc_id = B.ardoc_id
--				AND ABS(LC.DrAmt - LC.CrAmt) = CAST(B.tranamt AS numeric)
--			WHERE B.user1 != '' 
--				AND (A.TaxTot00 + A.TaxTot01 + A.TaxTot02) != 0
--				AND LCD.Emp_Cod = @emp_cod
--				AND 'EXENTO' NOT IN (A.taxId00, A.taxId01, A.taxId02)
--				AND LCD.Modulo = 'AR' 

					
--select * from DOC_APTran where 1=1
--	and apdoc_id = 15785344

SELECT LCD.InvtID as Insumo
	,LCD.Aux_Glosa
	,LCD.TipoDoc
	,LCD.TipoMov
	,LCD.RefNbr
	,LCD.DocDesc
	,LC.DrAmt - LC.CrAmt as MontoNeto
	,APT.TranAmt
	,LCD.TaxAmt
	,(APT.CuryTaxAmt00 + APT.CuryTaxAmt01 + APT.CuryTaxAmt02) AS TAX
	,LCD.Aux_apdoc_id
	,LCD.Aux_apdoc_cl_id
	FROM LOB_CERRADO_DETALLE LCD
	INNER JOIN LOB_CERRADO LC ON LCD.Cer_Id = LC.cer_id
	INNER JOIN LOB_PERIODO LP ON LC.per_id = LP.per_id
	INNER JOIN DOC_APTran APT ON APT.apdoc_id IN (LCD.Aux_apdoc_id,LCD.Aux_apdoc_cl_id)
	WHERE 1=1
		AND LCD.Emp_Cod = @emp_cod
		--AND TaxAmt != 0
		AND LC.obra_cod = 'II10'
		AND LCD.InvtID = '99402'
		--AND LC.RefNbr = '034799'
		AND APT.User1 != ''
		AND 'EXENTO' NOT IN (APT.taxId00, APT.taxId01, APT.taxId02)
	order by LCD.TipoDoc DESC
		,LCD.RefNbr asc
		,LP.per_periodo desc

