#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include 'FWMVCDEF.CH'
/*/ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPRFLOGEST บ Autor ณ Delta Decisao      บ Data ณ  05/02/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณLog de Importacao de Estrutura do PA.                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPerfil Refrigeracao.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAjuste    ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿/*/ 
User function PRFLOGEST()

Local _oBrowse 		:= Nil
Private _oView		:= Nil
Private _aRotina	:= MenuDef() 

_oBrowse := FWMBrowse():New()
_oBrowse:SetAlias('SZ5')
_oBrowse:SetDescription('LOG IMPORTACAO DE ESTRUTURA DO PA')
_oBrowse:DisableDetails()
_oBrowse:DisableLocate(.F.)
_oBrowse:SetUseCursor(.F.)
_oBrowse:SetWalkThru(.F.)

_oBrowse:Activate()
	
Return



/*/ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ MenuDef  บ Autor ณ Delta Decisao      บ Data ณ  05/02/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Opcoes do menu (aRotina).                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPerfil Refrigeracao.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAjuste    ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿/*/  
Static Function MenuDef()

Local _aRot := {} 

ADD OPTION _aRot Title 'Visualizar'	Action 'VIEWDEF.PRFLOGEST'  OPERATION 2 ACCESS 0

Return(_aRot)                                          
                       
/*/ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ ModelDef บ Autor ณ Delta Decisao      บ Data ณ  05/02/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Contem a regra de negocio.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPerfil Refrigeracao.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAjuste    ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿/*/ 
Static Function ModelDef()     
                    
Local _oStruCab  := FWFormStruct(1,'SZ5') 
Local _oStruGrid := FWFormStruct(1,'SZ5')

_oModel := MPFormModel():New('MODEL_PRFLOGEST',/*bPreValidacao*/, , , /*bCancel*/ ) 

_oStruCab:SetProperty('Z5_CODAGRP',MODEL_FIELD_OBRIGAT,.F.)
_oModel:AddFields('SZ5MASTER',/*cOwner*/,_oStruCab)
_oModel:AddGrid('SZ5DETAILA','SZ5MASTER',_oStruGrid,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/)

_oModel:GetModel('SZ5DETAILA'):SetOptional(.F.)
//_oModel:GetModel('SZ5DETAILA'):SetUniqueLine({'Z5_CODAGRP'})
_oModel:SetRelation('SZ5DETAILA',{{"Z5_FILIAL","xFilial('SZ5')"},{"Z5_GRPSUB","Z5_GRPSUB"},{"Z5_CODAGRP","Z5_CODAGRP"},{"Z5_SEQUENC","Z5_SEQUENC"}},SZ5->(IndexKey(1)))

_oModel:SetPrimaryKey({'Z5_FILIAL','Z5_GRPSUB','Z5_CODAGRP','Z5_SEQUENC'})
_oModel:SetDescription('LOG IMPORTACAO Estrutura do PA - WBC-CAD') 

_oModel:GetModel('SZ5MASTER'):SetDescription('Cabe็alho')
_oModel:GetModel('SZ5DETAILA'):SetDescription('Itens')
_oModel:SetPrimaryKey({'Z5_FILIAL','Z5_GRPSUB','Z5_CODAGRP','Z5_SEQUENC'})

Return(_oModel)


/*/ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ ViewDef  บ Autor ณ Delta Decisao      บ Data ณ  05/02/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Contem a interface.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPerfil Refrigeracao.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAjuste    ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿/*/ 
Static Function ViewDef()

Local _oStruCab  	:= FWFormStruct(2,'SZ5')
Local _oStruGrid	:= FWFormStruct(2,'SZ5')
Local _oModel   	:= FWLoadModel('PRFLOGEST')

_oView := FWFormView():New()
_oView:SetModel(_oModel)
_oView:AddField('VIEW_SZ5',_oStruCab,'SZ5MASTER')
_oView:AddGrid('VIEW_SZ5A',_oStruGrid,'SZ5DETAILA')

//Retira o campos do cabecalho, pois ele devem aparecer apenas na grid
_oStruCab:RemoveField('Z5_ITEM')
_oStruCab:RemoveField('Z5_SETOR')
_oStruCab:RemoveField('Z5_CODPA')
_oStruCab:RemoveField('Z5_CODFIL') 
_oStruCab:RemoveField('Z5_COR')
_oStruCab:RemoveField('Z5_QUANT')

//Retira os campos para nao exibir na grid apenas no cabecalho
_oStruGrid:RemoveField('Z5_GRPSUB')
_oStruGrid:RemoveField('Z5_CODAGRP')
_oStruGrid:RemoveField('Z5_ARQUIVO')
_oStruGrid:RemoveField('Z5_USUARIO')
_oStruGrid:RemoveField('Z5_DTIMP') 
_oStruGrid:RemoveField('Z5_HORA')
_oStruGrid:RemoveField('Z5_SEQUENC')


_oView:CreateHorizontalBox('EMCIMA',22)
_oView:CreateHorizontalBox('EMBAIXO',78)
_oView:SetOwnerView('VIEW_SZ5','EMCIMA')
_oView:SetOwnerView('VIEW_SZ5A','EMBAIXO')

//-------------------------------------
// Desabilita o navegador de Registro
//-------------------------------------
_oView:setUseCursor(.T.)

//----------------------------------------------
// For็a o fechamento da tela ao salvar o model
//----------------------------------------------
_oView:SetCloseOnOk({|| .T.})

Return(_oView)