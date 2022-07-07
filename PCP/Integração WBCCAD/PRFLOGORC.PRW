#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include 'FWMVCDEF.CH'
/*/ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPRFLOGORC บ Autor ณ Flavio Valentin    บ Data ณ  05/02/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณLog de Importacao de Orcamento.                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPerfil Refrigeracao.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAjuste    ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿/*/ 
User function PRFLOGORC()

Local _oBrowse 		:= Nil
Private _oView		:= Nil
Private _aRotina	:= MenuDef() 

_oBrowse := FWMBrowse():New()
_oBrowse:SetAlias('SZ4')
_oBrowse:SetDescription('LOG IMPORTACAO DE ORCAMENTO')
_oBrowse:DisableDetails()
_oBrowse:DisableLocate(.F.)
_oBrowse:SetUseCursor(.F.)
_oBrowse:SetWalkThru(.F.)

_oBrowse:Activate()
	
Return



/*/ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ MenuDef  บ Autor ณ Flavio Valentin    บ Data ณ  05/02/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Opcoes do menu (aRotina).                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPerfil Refrigeracao.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAjuste    ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿/*/  
Static Function MenuDef()

Local _aRot := {} 

ADD OPTION _aRot Title 'Visualizar'	Action 'VIEWDEF.PRFLOGORC'  OPERATION 2 ACCESS 0

Return(_aRot)                                          
                       
/*/ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ ModelDef บ Autor ณ Flavio Valentin    บ Data ณ  05/02/19   บฑฑ
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
                    
Local _oStruCab  := FWFormStruct(1,'SZ4') 
Local _oStruGrid := FWFormStruct(1,'SZ4')

_oModel := MPFormModel():New('MODEL_PRFLOGORC',/*bPreValidacao*/, , , /*bCancel*/ ) 

_oStruCab:SetProperty('Z4_NUMORC',MODEL_FIELD_OBRIGAT,.F.)
_oModel:AddFields('SZ4MASTER',/*cOwner*/,_oStruCab)
_oModel:AddGrid('SZ4DETAILA','SZ4MASTER',_oStruGrid,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/)

_oModel:GetModel('SZ4DETAILA'):SetOptional(.F.)
//_oModel:GetModel('SZ4DETAILA'):SetUniqueLine({'Z4_NUMORC'})
_oModel:SetRelation('SZ4DETAILA',{{"Z4_FILIAL","xFilial('SZ4')"},{"Z4_NUMORC","Z4_NUMORC"}},SZ4->(IndexKey(1)))

_oModel:SetPrimaryKey({'Z4_FILIAL','Z4_NUMORC'})
_oModel:SetDescription('LOG IMPORTACAO ORCAMENTO - WBC-CAD') 

_oModel:GetModel('SZ4MASTER'):SetDescription('Dados')
_oModel:GetModel('SZ4DETAILA'):SetDescription('Itens')
_oModel:SetPrimaryKey({'Z4_FILIAL','Z4_NUMORC'})

Return(_oModel)


/*/ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ ViewDef  บ Autor ณ Flavio Valentin    บ Data ณ  05/02/19   บฑฑ
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

Local _oStruCab  	:= FWFormStruct(2,'SZ4')
Local _oStruGrid	:= FWFormStruct(2,'SZ4')
Local _oModel   	:= FWLoadModel('PRFLOGORC')

_oView := FWFormView():New()
_oView:SetModel(_oModel)
_oView:AddField('VIEW_SZ4',_oStruCab,'SZ4MASTER')
_oView:AddGrid('VIEW_SZ4A',_oStruGrid,'SZ4DETAILA')

//Retira o campos do cabecalho, pois ele devem aparecer apenas na grid
_oStruCab:RemoveField('Z4_ITEMORC')
_oStruCab:RemoveField('Z4_GRPSUB')
_oStruCab:RemoveField('Z4_CODINTE') 
_oStruCab:RemoveField('Z4_CODAGRP')
_oStruCab:RemoveField('Z4_CODPRD')
_oStruCab:RemoveField('Z4_DESCPRD')
_oStruCab:RemoveField('Z4_QUANT')
_oStruCab:RemoveField('Z4_VALOR')
_oStruCab:RemoveField('Z4_CODPA')

//Retira os campos para nao exibir na grid apenas no cabecalho
_oStruGrid:RemoveField('Z4_NUMORC')
_oStruGrid:RemoveField('Z4_CNPJ')
_oStruGrid:RemoveField('Z4_NOME')
_oStruGrid:RemoveField('Z4_NUMPED')
_oStruGrid:RemoveField('Z4_ARQUIVO')
_oStruGrid:RemoveField('Z4_DTEMISS') 
_oStruGrid:RemoveField('Z4_DTIMP')
_oStruGrid:RemoveField('Z4_HORA')
_oStruGrid:RemoveField('Z4_USUARIO')

_oView:CreateHorizontalBox('EMCIMA',22)
_oView:CreateHorizontalBox('EMBAIXO',78)
_oView:SetOwnerView('VIEW_SZ4','EMCIMA')
_oView:SetOwnerView('VIEW_SZ4A','EMBAIXO')

//-------------------------------------
// Desabilita o navegador de Registro
//-------------------------------------
_oView:setUseCursor(.T.)

//----------------------------------------------
// For็a o fechamento da tela ao salvar o model
//----------------------------------------------
_oView:SetCloseOnOk({|| .T.})

Return(_oView)