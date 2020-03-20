CREATE TABLE LOB_RESUMEN_DETALLE (
	[per_id] [int] NOT NULL,
	[obra_cod] [varchar](5) NOT NULL,
	[cta_cod] [varchar](5) NOT NULL,
	[sub_cod] [varchar](5) NOT NULL,
	[invtID] [varchar](10) NOT NULL,
	[sdo_impuestos] INT NULL,
	[sdo_impuestos_uf] INT NULL
	CONSTRAINT [PK_LOB_RESUMEN_DETALLE] PRIMARY KEY CLUSTERED 
	(
		[per_id] ASC,
		[obra_cod] ASC,
		[cta_cod] ASC,
		[sub_cod] ASC,
		[invtID] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)
)
