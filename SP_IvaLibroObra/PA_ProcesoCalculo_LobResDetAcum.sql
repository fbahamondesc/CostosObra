IF OBJECT_ID ( 'PA_ProcesoCalculo_LobResDetAcum', 'P' ) IS NOT NULL 
    DROP PROCEDURE PA_ProcesoCalculo_LobResDetAcum;
GO
/********************************************************************************* 
	Nombre Procedimiento : PA_ProcesoCalculo_LobResDetAcum
	Descripcion          : Procedimiento que realiza el calculo de los saldos 
						   de impuestos acumulados en LOB_RESUMEN_DETALLE. 
	Fecha de Creacion    : 2019-12-18  
	Cliente              : Icafal  
	Creado por           : Francisco Bahamondes
**********************************************************************************/  

CREATE PROCEDURE [dbo].[PA_ProcesoCalculo_LobResDetAcum]
(
	@emp_cod CHAR(5)
	,@periodo_ini CHAR(6) = NULL
	,@periodo_fin CHAR(6) = NULL
)
as
BEGIN
	DECLARE @perid_act INT
		,@periodo_act CHAR(6)
		,@perid_res INT
		,@periodo_ant CHAR(6)
		,@periodo_iniemp CHAR(6)
		,@acum NUMERIC(22, 0)
		,@acum_uf NUMERIC(20, 7)
		,@obra_cod VARCHAR(10)
		,@sub_cod VARCHAR(10)
		,@invtID VARCHAR(10)
		,@mes_enero CHAR(2)
		,@obra_vig SMALLINT
		,@obra_historica SMALLINT
		,@obra_anual SMALLINT
	
	IF @periodo_ini IS NULL
	BEGIN
	select @periodo_ini = min(per_periodo) from LOB_PERIODO where (emp_cod = @emp_cod) and (per_estado = 'B')
	END

	IF @periodo_fin IS NULL
	BEGIN
	select @periodo_fin = max(per_periodo) from LOB_PERIODO where (emp_cod = @emp_cod)
	END

	SELECT @obra_anual = 1

	SELECT @obra_historica = 2

	SELECT @mes_enero = '01'

	SELECT @periodo_iniemp = min(per_periodo)
	FROM LOB_PERIODO
	WHERE (emp_cod = @emp_cod)

	IF (@periodo_ini <= @periodo_iniemp)
	BEGIN
		SELECT @periodo_ant = @periodo_iniemp
			,@periodo_ini = @periodo_iniemp
	END
	ELSE
	BEGIN
		SELECT @periodo_ant = max(per_periodo)
		FROM LOB_PERIODO
		WHERE (emp_cod = @emp_cod)
			AND (per_periodo < @periodo_ini)
	END

	UPDATE LOB_RESUMEN_DETALLE
	SET sdo_impuestos_acum = sdo_impuestos
		,sdo_impuestos_uf_acum = sdo_impuestos_uf
	WHERE per_id IN (
			SELECT DISTINCT per_id
			FROM LOB_PERIODO
			WHERE (per_periodo >= @periodo_ini)
				AND (emp_cod = @emp_cod)
			)



	DECLARE Puntero_per_id CURSOR
	FOR
	SELECT per_id
		,per_periodo
	FROM LOB_PERIODO PP
	WHERE PP.per_periodo >= @periodo_ini and PP.per_periodo <= @periodo_fin
		AND PP.emp_cod = @emp_cod
	ORDER BY PP.per_periodo

	OPEN Puntero_per_id

	FETCH NEXT
	FROM Puntero_per_id
	INTO @perid_act
		,@periodo_act

	WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT '   acumulación de saldos para ' + @periodo_act + ', empresa ' + @emp_cod + ' (' + convert(VARCHAR(20), getdate(), 120) + ')'

		DECLARE Puntero CURSOR
		FOR
		SELECT rtrim(PR.obra_cod)
			,rtrim(PR.sub_cod)
			,rtrim(PR.invtID)
			,PR.sdo_impuestos_acum
			,PR.sdo_impuestos_uf_acum
			,PR.per_id
		FROM LOB_RESUMEN_DETALLE PR
		WHERE PR.per_id IN (
				SELECT X.per_id
				FROM LOB_PERIODO X
				WHERE X.emp_cod = @emp_cod
					AND X.per_periodo IN (
						SELECT max(LOB_PERIODO.per_periodo)
						FROM LOB_PERIODO
						WHERE LOB_PERIODO.emp_cod = @emp_cod
							AND LOB_PERIODO.per_periodo < @periodo_act
							AND
							LOB_PERIODO.per_periodo >= @periodo_ant
						)
				)

		OPEN Puntero

		FETCH NEXT
		FROM Puntero
		INTO @obra_cod
			,@sub_cod
			,@invtID
			,@acum
			,@acum_uf
			,@perid_res

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SELECT @obra_vig = O.obra_vig
			FROM LOB_OBRA O
			WHERE (O.emp_cod = @emp_cod)
				AND (O.obra_cod = @obra_cod)

			IF EXISTS (
					SELECT 1
					FROM LOB_RESUMEN_DETALLE
					WHERE per_id = @perid_act
						AND obra_cod = @obra_cod
						AND sub_cod = @sub_cod
						AND InvtID = @InvtID
					)
			BEGIN
				UPDATE LOB_RESUMEN_DETALLE
				SET sdo_impuestos_acum = (@acum + sdo_impuestos_acum)
					,sdo_impuestos_uf_acum = (@acum_uf + sdo_impuestos_uf_acum)
				WHERE (per_id = @perid_act)
					AND (obra_cod = @obra_cod)
					AND (sub_cod = @sub_cod)
					AND (InvtID = @InvtID)
					AND (
						(@obra_vig = @obra_historica)
						OR (right(@periodo_act, 2) <> @mes_enero)
						)
			END


			FETCH NEXT
			FROM Puntero
			INTO @obra_cod
				,@sub_cod
				,@invtID
				,@acum
				,@acum_uf
				,@perid_res
		END

		CLOSE Puntero

		DEALLOCATE Puntero

		FETCH NEXT
		FROM Puntero_per_id
		INTO @perid_act
			,@periodo_act

	END

	CLOSE Puntero_per_id

	DEALLOCATE Puntero_per_id

	PRINT '   Finalizado cálculo impuestos acumulado histórico (' + convert(VARCHAR(20), getdate(), 120) + ')'

	RETURN 1
END