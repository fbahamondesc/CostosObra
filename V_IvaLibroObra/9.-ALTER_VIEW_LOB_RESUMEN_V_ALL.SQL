ALTER VIEW [dbo].[LOB_RESUMEN_V_ALL] AS
SELECT 

	rtrim(PE.emp_cod) as Empr,
	left(PE.per_periodo,4) as Año,
	substring(PE.per_periodo,5,2) as Mes,
	PE.per_periodo as Periodo,
	
	rtrim(R.obra_cod) as Obra,
	
	rtrim(R.cta_cod) as PCO_cuenta,
	rtrim(R.sub_cod) as PCO_subcta,
	
	rtrim(R.InvtID) as Insumo,

	R.sdo_fin_mes as Saldo_Mes,
	convert(float,R.sdo_fin_mes_uf) as SaldoUF_Mes,
	
	ISNULL(LRD.sdo_impuestos,0) AS Saldo_Impuestos,
	convert(float,ISNULL(LRD.sdo_impuestos_uf,0)) as Saldo_ImpuestosUF,
	
	R.sdo_acum as Saldo_Acum,
	convert(float,R.sdo_acum_uf) as SaldoUF_Acum,

	ISNULL(LRD.sdo_impuestos_acum,0) AS Saldo_Impuestos_Acum,
	convert(float,ISNULL(LRD.sdo_impuestos_uf_acum,0)) as Saldo_ImpuestosUF_Acum,

	convert(float,R.pco_cantavance) as PCO_cantavance,
	convert(float,R.pco_montoavance) as PCO_montoavance,
	convert(float,R.pco_canttotal) as PCO_canttotal,
	convert(float,R.pco_montototal) as PCO_montototal,
	
	case PE.per_estado when 'C' then 1 else 0 end as Periodo_Cerrado,
	R.per_id
	
from 
	LOB_RESUMEN R WITH (NOLOCK)
	INNER JOIN LOB_PERIODO PE WITH (NOLOCK) ON R.per_id = PE.per_id
	LEFT JOIN LOB_RESUMEN_DETALLE LRD ON R.per_id = LRD.per_id
									AND R.obra_cod = LRD.obra_cod
									AND R.cta_cod = LRD.cta_cod
									AND R.sub_cod = LRD.sub_cod
									AND R.invtID = LRD.invtID
	
GO