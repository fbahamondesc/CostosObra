DECLARE @apdoc_id AS INT = 15785323

--SELECT * FROM LOB_CERRADO_DETALLE
--WHERE 1=1
--	AND InvtID = '99402'
--	AND RefNbr = '034799'

--	select * from LOB_IMPUESTOS
--	where apdoc_id = 15785344
--SELECT * FROM LOB_CERRADO WHERE cer_id IN (
--1717755)


--exec PA_ProcesoCarga_Lob_Impuestos_Por_Empresa '0102'
--EXEC PA_ProcesoCarga_LobResumenDetalle '0102'
--TRUNCATE TABLE LOB_RESUMEN_DETALLE
--SELECT * FROM DOC_ARDOC WHERE 'EXENTO' IN (TaxId00,TaxID01,TaxId02)

--SELECT A.Cer_Id 
--	,B.DrAmt - B.CrAmt AS NETO
--	,A.TaxAmt
--	,(B.DrAmt - B.CrAmt) * 0.19 AS Imp
--FROM LOB_CERRADO_DETALLE A
--inner join LOB_CERRADO B ON A.Cer_Id = B.cer_id
--WHERE A.TaxAmt IS NOT NULL AND A.TaxAmt != 0
----UPDATE LOB_CERRADO_DETALLE SET TaxAmt = NULL, TaxAmt_uf = NULL WHERE Emp_Cod = '0101'
--SELECT * FROM DOC_APTran WHERE apdoc_id in (15785344)

--SELECT a.Lote, c.BatNbr, b.DrAmt, b.CrAmt, * FROM LOB_CERRADO_DETALLE a
--inner join LOB_CERRADO b on a.Cer_Id = b.cer_id
--inner join DOC_APTran c on c.apdoc_id in (a.Aux_apdoc_cl_id, a.Aux_apdoc_id)
--	and a.RefNbr = c.RefNbr
--	--and a.Lote = c.BatNbr
--	and ABS(b.DrAmt - b.CrAmt) = c.TranAmt
--WHERE 15785344 in (a.Aux_apdoc_cl_id, a.Aux_apdoc_id)


--SELECT * FROM LOB_CERRADO WHERE Cer_Id IN (2633232
--,2633231
--)


SELECT lcd.TaxAmt 
	,lc.DrAmt - lc.CrAmt as MontoNeto
	, lc.InvtID
	,lc.TipoMov
FROM LOB_CERRADO_DETALLE lcd
inner join LOB_CERRADO lc on lcd.Cer_Id = lc.cer_id
WHERE @apdoc_id in (Aux_apdoc_cl_id, Aux_apdoc_id)

--SELECT * FROM DOC_APTran A 
--INNER JOIN DOC_APDoc B ON A.apdoc_id = B.apdoc_id
--WHERE A.apdoc_id = 15785323
--AND A.User1 != ''

select * from DOC_APTran where apdoc_id = @apdoc_id
--select * from DOC_APDoc where apdoc_id = @apdoc_id
