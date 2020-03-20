IF OBJECT_ID ( 'PA_ProcesoCarga_LobResumenDetalle', 'P' ) IS NOT NULL 
    DROP PROCEDURE PA_ProcesoCarga_LobResumenDetalle;
GO

/********************************************************************************* 
	Nombre Procedimiento : PA_ProcesoCarga_LobResumenDetalle
	Descripcion          : Procedimiento que efectua las cargas y actualizacion 
						   de la tabla LOB_RESUMEN_DETALLE. 
	Fecha de Creacion    : 2019-12-18  
	Cliente              : Icafal  
	Creado por           : Francisco Bahamondes
**********************************************************************************/  
CREATE PROCEDURE PA_ProcesoCarga_LobResumenDetalle 
(
	@emp_cod CHAR(5),
	@periodo_ini CHAR(6) = NULL,
	@periodo_fin CHAR(6) = NULL
)
AS
-- CARGA TABLA LOB_RESUMEN_DETALLE CON DATOS DE LOB_RESUMEN
print 'CARGA TABLA LOB_RESUMEN_DETALLE CON DATOS DE LOB_RESUMEN PARA LA EMPRESA (' + convert(VARCHAR(20), getdate(), 120) + ')'
BEGIN
	INSERT INTO LOB_RESUMEN_DETALLE (
		per_id
		,obra_cod
		,cta_cod
		,sub_cod
		,invtID
		,sdo_impuestos
		,sdo_impuestos_uf
		,sdo_impuestos_acum
		,sdo_impuestos_uf_acum
		)
	SELECT LRD.per_id
		,LRD.obra_cod
		,LRD.cta_cod
		,LRD.sub_cod
		,LRD.invtID
		,0
		,0
		,0
		,0
	FROM LOB_RESUMEN LRD WITH (NOLOCK)
	INNER JOIN LOB_PERIODO LP ON LRD.per_id = LP.per_id
	WHERE LP.emp_cod = @emp_cod

	EXCEPT

	SELECT LRD.per_id
		,LRD.obra_cod
		,LRD.cta_cod
		,LRD.sub_cod
		,LRD.invtID
		,0
		,0
		,0
		,0
	FROM LOB_RESUMEN_DETALLE LRD WITH (NOLOCK)
	INNER JOIN LOB_PERIODO LP ON LRD.per_id = LP.per_id
	WHERE LP.emp_cod = @emp_cod
END

-- ACTUALIZA LOB_RESUMEN_DETALLE CON LOS MONTOS DE IMPUESTOS
print 'ACTUALIZA LOB_RESUMEN_DETALLE CON LOS MONTOS DE IMPUESTOS PARA LA EMPRESA (' + convert(VARCHAR(20), getdate(), 120) + ')'
BEGIN
UPDATE LRD
SET	LRD.sdo_impuestos = ILR.TaxAmt
	,LRD.sdo_impuestos_uf = ILR.TaxAmt_uf
FROM LOB_RESUMEN_DETALLE LRD WITH (NOLOCK)
INNER JOIN (
SELECT SUM(TaxAmt) TaxAmt
		,SUM(TaxAmt_uf) TaxAmt_uf
		,LCD.Obra_Cod
		,LCD.InvtID
		,LCD.Periodo
		,LC.per_id
		,LCD.Emp_Cod
		,SUBSTRING(LC.sub_cod, 1, 1) + '00' AS cta_cod
		,LC.sub_cod
	FROM [BxO_DATA].[dbo].[LOB_CERRADO_DETALLE] LCD WITH (NOLOCK)
	INNER JOIN LOB_CERRADO LC WITH (NOLOCK) ON LCD.Cer_Id = LC.cer_id
	WHERE TaxAmt IS NOT NULL AND LCD.Emp_Cod = @emp_cod
	GROUP BY LCD.Obra_Cod
		,LCD.InvtID
		,LCD.Periodo
		,LC.per_id
		,LCD.Emp_Cod
		,LC.sub_cod

UNION

SELECT SUM(TaxAmt) TaxAmt
		,SUM(TaxAmt_uf) TaxAmt_uf
		,LBD.Obra_Cod
		,LB.InvtID
		,LBD.Periodo
		,LB.per_id
		,LBD.Emp_Cod
		,SUBSTRING(LB.sub_cod, 1, 1) + '00' AS cta_cod
		,LB.sub_cod
	FROM [BxO_DATA].[dbo].[LOB_BORRADOR_DETALLE] LBD WITH (NOLOCK)
	INNER JOIN LOB_BORRADOR LB WITH (NOLOCK) ON LBD.Bor_Id = LB.bor_id
	WHERE TaxAmt IS NOT NULL AND LBD.Emp_Cod = @emp_cod
	GROUP BY LBD.Obra_Cod
		,LB.InvtID
		,LBD.Periodo
		,LB.per_id
		,LBD.Emp_Cod
		,LB.sub_cod
	) AS ILR ON LRD.obra_cod = ILR.Obra_Cod
			AND LRD.invtID = ILR.InvtID
			AND LRD.per_id = ILR.per_id
			AND ILR.sub_cod = LRD.sub_cod
	WHERE LRD.sdo_impuestos IS NULL OR LRD.sdo_impuestos = 0
END
-- ACTUALIZA LOB_RESUMEN_DETALLE CON LOS MONTOS DE IMPUESTOS ACUMULADOS
print 'ACTUALIZA LOB_RESUMEN_DETALLE CON LOS MONTOS DE IMPUESTOS ACUMULADOS PARA LA EMPRESA (' + convert(VARCHAR(20), getdate(), 120) + ')'
begin
	exec PA_ProcesoCalculo_LobResDetAcum @emp_cod, @periodo_ini, @periodo_fin
END
GO
