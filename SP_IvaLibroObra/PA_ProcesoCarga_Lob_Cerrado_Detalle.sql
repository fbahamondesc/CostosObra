IF OBJECT_ID ( 'PA_ProcesoCarga_Lob_Cerrado_Detalle', 'P' ) IS NOT NULL 
    DROP PROCEDURE PA_ProcesoCarga_Lob_Cerrado_Detalle;
GO

CREATE Procedure [dbo].[PA_ProcesoCarga_Lob_Cerrado_Detalle]  
As  
  
/*****************************************************************************  
Nombre Procedimiento : PA_ProcesoCarga_Lob_Cerrado_Detalle  
Descripción       : Procedimiento que efectua las cargas y actualizaciones  
        de la tabla LOB_CERRADO_DETALLE.  
Fecha de Creación  : 24-02-2011  
Cliente     : Icafal  
Creado por    : Félix Aguirre Bulnes
Actualización 2019-12-13 por Francisco Bahamondes:
Se agrega la carga de las columnas de impuesto y monto neto
******************************************************************************/  
  
 /* Proceso de Carga Tabla LOB_CERRADO_DETALLE */  
 Insert Into LOB_CERRADO_DETALLE  
 ( Cer_Id, Obra_Cod, Prv_Rut, Modulo, Lote, RefNbr, Acct, TipoDoc, TipoDoc2, TipoMov,   
   DocDesc, TipoTran, OrigCpnyID, Emp_Cod, Periodo, PerEnt, Status, LineNbr, InvtID,  
  Aux_Glosa, Aux_apdoc_id, Aux_apdoc_cl_id, Aux_InvcNbr, Aux_Tipo_Doc,Aux_ExtRefNbr, 
  TaxAmt, TaxAmt_uf 
 )  
  
 Select  
   a.cer_id  
  ,a.obra_cod  
  ,a.prv_rut  
  ,a.modulo  
  ,a.lote  
  ,a.RefNbr  
  ,a.Acct  
  ,a.TipoDoc  
  ,a.TipoDoc2  
  ,a.TipoMov  
  ,a.DocDesc  
  ,a.TipoTran  
  ,a.OrigCpnyID  
  ,a.emp_cod  
  ,a.periodo  
  ,a.PerEnt  
  ,a.Status  
  ,a.LineNbr  
  ,a.InvtID  
  ,Null as Aux_Glosa  
  ,Null as Aux_apdoc_id  
  ,Null as Aux_apdoc_cl_id  
  ,Null as Aux_InvcNbr  
  ,Null as Aux_Tipo_Doc  
  ,Null as Aux_ExtRefNbr
  ,NULL AS TaxAmt
  ,Null AS TaxAmt_uf
 From Lob_Cerrado as a With (NoLock)  
 Where a.cer_id not in (Select r.cer_id from LOB_CERRADO_DETALLE as r With (NoLock) where  r.cer_id = a.cer_id)  
  
  
 /* Primera Actualización del Campo Glosa en Tabla Lob_Cerrado */  
 Print 'Primer Proceso de Actualización Tabla Lob_Cerrado'  
 Update LOB_CERRADO_DETALLE  
 Set  
  Aux_Glosa = Case  
      -- AP  
      When TipoDoc = 'VO' and TipoDoc2 = 'BH'  Then 'B.Honorarios'  
      When TipoDoc = 'VO' and TipoDoc2 = 'FA'  Then 'Factura'  
      When TipoDoc = 'VO' and TipoDoc2 = 'FE'  Then 'Fact.Elect.'  
      When TipoDoc = 'VO' and TipoDoc2 = 'FC'  Then 'Fact.Compra'  
      --se agrega factura de compra electronica 04/08/2015
      When TipoDoc = 'VO' and TipoDoc2 = 'FCE'  Then 'Fact.Compra Elect.'  
        
      When TipoDoc = 'AD' and TipoDoc2 = 'FA'  Then 'Nota Crédito'  
      When TipoDoc = 'AD' and TipoDoc2 = 'NCE' Then 'N.Cred.Elect.'  
      When TipoDoc = 'AD' and TipoDoc2 = 'FC'  Then 'N.Cred.Compra'  
        
      When TipoDoc = 'AC' and TipoDoc2 = 'NDE' Then 'N.Deb.Elect.'  
      When TipoDoc = 'AC' and TipoDoc2 = 'AC'  Then 'Nota Débito'  
      When TipoDoc = 'AC'                      Then 'Nota Débito'  
        
      -- AR  
      When TipoDoc = 'IN' and TipoDoc2 = 'IN'  Then 'Factura'  
      When TipoDoc = 'IN' and TipoDoc2 = 'OT'  Then 'Documento'  
      When TipoDoc = 'IN' and TipoDoc2 = 'LE'  Then 'Letras'  
      When TipoDoc = 'IN' and TipoDoc2 = 'CHF' Then 'Cheque'       
      When TipoDoc = 'IN' and TipoDoc2 = 'LF'  Then 'Liquidación Factura'  
      When TipoDoc = 'IN' and TipoDoc2 = 'CM'  Then 'Nota Crédito Factura'  
      When TipoDoc = 'IN' and TipoDoc2 = 'BV'  Then 'Boleta de Venta'  
        
      When TipoDoc = 'CM' and TipoDoc2 = 'IN'  Then 'Nota Crédito'  
      When TipoDoc = 'CM' and TipoDoc2 = 'OT'  Then 'Nota Crédito'  
      When TipoDoc = 'CM' and TipoDoc2 = 'CM'  Then 'Nota Crédito'  
      When TipoDoc = 'CM' and TipoDoc2 = 'LE'  Then 'Nota Crédito Letra'       
      When TipoDoc = 'CM' and TipoDoc2 = 'CHF' Then 'Nota Crédito Cheque'  
        
      When TipoDoc = 'DM' and TipoDoc2 = 'IN'  Then 'Nota Débito Factura'  
      When TipoDoc = 'DM' and TipoDoc2 = 'OT'  Then 'Nota Débito OT'  
        
      When TipoDoc = 'PP'                      Then 'Anticipo'  
      When TipoDoc = 'SC'                      Then 'Elim. Saldo Acreedor'  
      When TipoDoc = 'RP'                      Then 'Cambio Cliente'  
      When TipoDoc = 'NS'                      Then 'Reversa de Pago'  
      When TipoDoc = 'SB'                      Then 'Elim. Saldo Deudor'  
      When TipoDoc = 'PA'                      Then 'Pago'  
        
      -- GL  
      When Modulo = 'GL' and TipoMov = 'LR'   Then 'Cargo Remuneración'  
      When Modulo = 'GL' and TipoMov = 'CL-M' Then 'CL - Manual'  
      When Modulo = 'GL' and TipoMov = 'G1'   Then 'Gtos Boleta Gtía'  
      When Modulo = 'GL' and TipoMov = 'G4'   Then 'Int. Boleta Gtía'  
      When Modulo = 'GL'            Then 'Comprobante Contable'  
        
      Else '???'  
      End  
        
 From LOB_CERRADO_DETALLE  
 Where   
 (Aux_Glosa is null or Aux_Glosa = '???')  
  
  
  
 /* Segunda Actualización del Campo Glosa en Tabla Lob_Cerrado utilizando tabla Doc_ApDoc */  
 Print 'Segunda Proceso de Actualización Tabla Lob_Cerrado'  
 /* 1.- Marca Reversa de Gastos */  
 Print '1.- Marca Reversa de Gastos'  
 Update LOB_CERRADO_DETALLE  
 Set  
  Aux_Glosa = 'Reversa de Gastos'  
 From   
  LOB_CERRADO_DETALLE as a With (Nolock)  
 Inner Join DOC_APDoc as b With (Nolock)  
 On  
   a.Emp_Cod = b.CpnyID  
  and a.Lote    = b.BatNbr  
  and a.RefNbr  = b.RefNbr  
 Where  
 (a.Aux_Glosa is null or a.Aux_Glosa = '???')  
 and b.DocType = 'VO'   
 and b.User5   = 'OT'   
 and b.Acct    = '210702'  
   
   
   
 /* 2.- Marca Rendición Gtos con Boleta */  
 Print '2.- Marca Rendición Gtos con Boleta'  
 Update LOB_CERRADO_DETALLE  
 Set  
  Aux_Glosa = 'Rendición Gtos con Boleta'  
 From   
  LOB_CERRADO_DETALLE as a With (Nolock)  
 Inner Join DOC_APDoc as b With (Nolock)  
 On  
   a.Emp_Cod = b.CpnyID  
  and a.Lote    = b.BatNbr  
  and a.RefNbr  = b.RefNbr  
 Where  
 (a.Aux_Glosa is null or a.Aux_Glosa = '???')  
 and b.DocType = 'VO'   
 and b.User5   = 'OT'   
 and b.Acct in ('210704','211205')  
   
    
    
 /* 3.- Marca Reversa Factura */  
 Print '3.- Marca Reversa Factura'  
 Update LOB_CERRADO_DETALLE  
 Set  
  Aux_Glosa = 'Reversa Factura'  
 From   
  LOB_CERRADO_DETALLE as a With (Nolock)  
 Inner Join DOC_APDoc as b With (Nolock)  
 On  
   a.Emp_Cod = b.CpnyID  
  and a.Lote    = b.BatNbr  
  and a.RefNbr  = b.RefNbr  
 Where  
 (a.Aux_Glosa is null or a.Aux_Glosa = '???')  
 and b.DocType = 'AD'   
 and b.User5   = 'OT'   
 and b.Acct    = '210702'  
   
   
   
 /* 4.- Marca Reversa Rend. Gastos */  
 Print '4.- Marca Reversa Rend. Gastos'  
 Update LOB_CERRADO_DETALLE  
 Set  
  Aux_Glosa = 'Reversa Rend. Gastos'  
 From   
  LOB_CERRADO_DETALLE as a With (Nolock)  
 Inner Join DOC_APDoc as b With (Nolock)  
 On  
   a.Emp_Cod = b.CpnyID  
  and a.Lote    = b.BatNbr  
  and a.RefNbr  = b.RefNbr  
 Where  
 (a.Aux_Glosa is null or a.Aux_Glosa = '???')  
 and b.DocType = 'AD'   
 and b.User5   = 'OT'   
 and b.Acct in ('210704','211205')  
   
   
   
 /* 5.- Marca Nota de Debito Elect. */  
 Print '5.- Marca Nota de Debito Elect.'  
 Update LOB_CERRADO_DETALLE  
 Set  
  Aux_Glosa = 'Nota de Debito Elect.'  
 From   
  LOB_CERRADO_DETALLE as a With (Nolock)  
 Inner Join DOC_APDoc as b With (Nolock)  
 On  
   a.emp_cod = b.CpnyID  
  and a.lote    = b.BatNbr  
  and a.RefNbr  = b.RefNbr  
 Where  
 (a.Aux_Glosa is null or a.Aux_Glosa = '???')  
 and b.DocType = 'AC'   
 and b.User5   = 'NDE'   
 and b.Acct    = '210702'  
    
    
   
 /* 6.- Marca Anula BH. */  
 Print '6.- Marca Anula BH.'  
 Update LOB_CERRADO_DETALLE  
 Set  
  Aux_Glosa = 'Anula BH.'  
 From   
  LOB_CERRADO_DETALLE as a With (Nolock)  
 Inner Join DOC_APDoc as b With (Nolock)  
 On  
   a.Emp_Cod = b.CpnyID  
  and a.Lote    = b.BatNbr  
  and a.RefNbr  = b.RefNbr  
 Where  
 (a.Aux_Glosa is null or a.Aux_Glosa = '???')  
 and b.DocType = 'VO'   
 and b.User5   = 'OT'   
 and b.Acct    = '211202'  
   
   
   
 /* 7.- Marca Cuentas EERR. */  
 Print '7.- Marca Cuentas EERR.'  
 Update LOB_CERRADO_DETALLE  
 Set  
  Aux_Glosa = 'Cuentas EERR.'  
 From   
  LOB_CERRADO_DETALLE as a With (Nolock)  
 Inner Join DOC_APDoc as b With (Nolock)  
 On  
   a.Emp_Cod = b.CpnyID  
  and a.Lote    = b.BatNbr  
  and a.RefNbr  = b.RefNbr  
 Where  
 (a.Aux_Glosa is null or a.Aux_Glosa = '???')  
 and b.DocType = 'VO'   
 and b.User5   = 'OT'   
 and b.Acct    = '211001'  
   
   
   
 /* 8.- Marca Reversa BH */  
 Print '8.- Marca Reversa BH'  
 Update LOB_CERRADO_DETALLE  
 Set  
  Aux_Glosa = 'Reversa BH'  
 From   
  LOB_CERRADO_DETALLE as a With (Nolock)  
 Inner Join DOC_APDoc as b With (Nolock)  
 On  
   a.Emp_Cod = b.CpnyID  
  and a.Lote    = b.BatNbr  
  and a.RefNbr  = b.RefNbr  
 Where  
 (a.Aux_Glosa is null or a.Aux_Glosa = '???')  
 and b.DocType = 'AD'   
 and b.User5   = 'OT'   
 and b.Acct    = '211202'  
   
   
   
 /* 9.- Marca Reversa Cuentas EERR */  
 Print '9.- Marca Reversa Cuentas EERR'  
 Update LOB_CERRADO_DETALLE  
 Set  
  Aux_Glosa = 'Reversa Cuentas EERR'  
 From   
  LOB_CERRADO_DETALLE as a With (Nolock)  
 Inner Join DOC_APDoc as b With (Nolock)  
 On  
   a.Emp_Cod = b.CpnyID  
  and a.Lote    = b.BatNbr  
  and a.RefNbr  = b.RefNbr  
 Where  
 (a.Aux_Glosa is null or a.Aux_Glosa = '???')  
 and b.DocType = 'AD'   
 and b.User5   = 'OT'   
 and b.Acct    = '211001'   
   
   
   
 /* 10.- Actualiza Campos Aux_apdoc_cl_id - Aux_ExtRefNbr */  
 Print '10.- Actualiza Campos Aux_apdoc_cl_id - Aux_ExtRefNbr'  
 Update LOB_CERRADO_DETALLE  
 Set  
 Aux_apdoc_cl_id = b.apdoc_cl_id  
 ,Aux_ExtRefNbr = b.ExtRefNbr   
 From LOB_CERRADO_DETALLE as a  
 Inner Join BO_GLTran as b  
 ON  
  a.Emp_Cod = b.CpnyID  
  and a.Lote = b.BatNbr  
  and a.RefNbr = b.RefNbr  
  and a.LineNbr = b.LineNbr  
 Where  
 a.Modulo = 'GL'  
 and a.TipoMov in ('CL','CL-A')  
 and b.apdoc_cl_id <> -1  
  
   
   
 /* 11.- Actualiza Campos Aux_InvcNbr - Aux_Tipo_Doc */  
 Print '11.- Actualiza Campos Aux_InvcNbr - Aux_Tipo_Doc'  
 Update LOB_CERRADO_DETALLE  
 Set  
 Aux_InvcNbr = b.InvcNbr  
 ,Aux_Tipo_Doc = b.tipo_doc  
 From LOB_CERRADO_DETALLE as a  
 Inner Join DOC_APDoc as b  
 ON  
 a.Emp_Cod = b.CpnyID  
 and a.Aux_apdoc_cl_id = b.apdoc_id  
 Where  
 a.Aux_apdoc_cl_id is not Null  
 and b.Marca_Virtual = 0  
  
  
  
 /* 12.- Actualiza Campos Aux_apdoc_id */  
 Print '12.- Actualiza Campos Aux_apdoc_id'  
 Update LOB_CERRADO_DETALLE  
 Set  
 Aux_apdoc_id = b.apdoc_id  
 From LOB_CERRADO_DETALLE as a  
 Inner Join BO_GLTran as b  
 ON  
  a.Emp_Cod = b.CpnyID  
  and a.Lote = b.BatNbr  
  and a.RefNbr = b.RefNbr  
  and a.LineNbr = b.LineNbr  
 Where  
 b.apdoc_id <> -1
 
 
