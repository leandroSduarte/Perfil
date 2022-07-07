#DEFINE NCOL_LMARCA			1
#DEFINE NCOL_CPEDIDO		2
#DEFINE NCOL_CITEM	    	3
#DEFINE NCOL_CVOLUME		4
#DEFINE NCOL_CCLIENTE		5
#DEFINE NCOL_CLOJA			6
#DEFINE NCOL_CNOME			7

#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE "rwmake.ch"
#INCLUDE 'COLORS.ch'
#INCLUDE "FwBrowse.ch"
#INCLUDE "TopConn.ch"


/*-------------------------------------------------------------------------------------
{Protheus.doc} CADSZ7

@Author  	   Felipe Aguiar - Focus Consultoria
@since		   06/2019
@version	   P12

@description Cadastro de Volumes para Embarque  
---------------------------------------------------------------------------------------
|Author                  | Date       | Description                                    |
|                        |            |                                                |
--------------------------------------------------------------------------------------*/

User Function CADSZ7()

Local aArea   := GetArea()
Local oBrowse

//Instânciando FWMBrowse - Somente com dicionário de dados
oBrowse := FWMBrowse():New()

//Setando a tabela de cadastro de Autor/Interprete
oBrowse:SetAlias("SZ7")
//Setando a descrição da rotina
oBrowse:SetDescription("MONTAGEM DE VOLUMES")

//Legendas;
oBrowse:AddLegend( "SZ7->Z7_EXPEDID == '1'", "RED"  ,"Expedido"   )
oBrowse:AddLegend( "SZ7->Z7_EXPEDID == '2'", "GREEN","Em Aberto"  )

//Ativa a Browse
oBrowse:Activate()

RestArea(aArea)

Return Nil


/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Felipe Aguiar                                                |
 | Data:  06/2019                                                      |
 | Desc:  Criação do menu MVC                                          |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function MenuDef()

Local a_Rotina := {}

//Adicionando opções
ADD OPTION a_Rotina TITLE 'Visualizar'           ACTION 'VIEWDEF.CADSZ7' OPERATION 2 ACCESS 0 
ADD OPTION a_Rotina TITLE 'Incluir'              ACTION 'VIEWDEF.CADSZ7' OPERATION 3 ACCESS 0 
ADD OPTION a_Rotina TITLE 'Alterar'              ACTION 'VIEWDEF.CADSZ7' OPERATION 4 ACCESS 0 
ADD OPTION a_Rotina TITLE 'Excluir'              ACTION 'VIEWDEF.CADSZ7' OPERATION 5 ACCESS 0 
ADD OPTION a_Rotina TITLE 'Legenda'              ACTION 'U_SZ7LEG()'     OPERATION 6 ACCESS 0 
ADD OPTION a_Rotina TITLE 'Verificar'            ACTION 'U_FVERVOL()'    OPERATION 6 ACCESS 0
ADD OPTION a_Rotina TITLE 'Pick List'            ACTION 'U_PICKLT01()'   OPERATION 6 ACCESS 0
ADD OPTION a_Rotina TITLE 'Pick List Detalhado'  ACTION 'U_PICKLT02()'   OPERATION 6 ACCESS 0
ADD OPTION a_Rotina TITLE 'Embarcar'             ACTION 'U_SZ7EMB()'     OPERATION 6 ACCESS 0 

Return a_Rotina


/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Felipe Aguiar                                                |
 | Data:  06/2019                                                      |
 | Desc:  Criação do modelo de dados MVC                               |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function ModelDef()

Local oModel 		:= Nil
Local oStPai 		:= FWFormStruct(1, 'SZ7')
Local oStFilho 	    := FWFormStruct(1, 'SZ8')
Local aSZRel		:= {}
	
//Criando o modelo e os relacionamentos
oModel := MPFormModel():New('CADSZ7M', /*bPreValidacao*/, { |oModel| U_FZ8VLD(oModel) }/*bPosValidacao*/,  { |oModel| U_FZ8GRV( oModel ) }/*bGravacao*/ , /*bCancel*/ )

oModel:AddFields('SZ7MASTER',/*cOwner*/,oStPai)
oModel:AddGrid('SZ8DETAIL','SZ7MASTER',oStFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence

oStFilho:AddField( " ", " ", "OK", "L", 1, 0, FwBuildFeature(STRUCT_FEATURE_VALID, "AlwaysTrue()"), FwBuildFeature(STRUCT_FEATURE_WHEN, "AlwaysTrue()"), Nil, .F., Nil, .F., .F., .T.)

//Fazendo o relacionamento entre o Pai e Filho
aAdd(aSZRel, {'Z8_FILIAL',	'xFilial( "SZ8" )' })
aAdd(aSZRel, {'Z8_NUMVOL',	'Z7_NUMVOL' }) 
aAdd(aSZRel, {'Z8_PEDIDO',	'Z7_PEDIDO' }) 
aAdd(aSZRel, {'Z8_ITEM'  ,	'Z7_ITEM'   }) 

oStFilho:SetProperty('Z8_PRODUTO' , MODEL_FIELD_WHEN , {|| .F. })
oStFilho:SetProperty('Z8_LOCAL'   , MODEL_FIELD_WHEN , {|| .F. })
oStFilho:SetProperty('Z8_QTDEMP'  , MODEL_FIELD_WHEN , {|| .F. })
oStFilho:SetProperty('Z8_LOTE'    , MODEL_FIELD_WHEN , {|| .F. })


//oStPai:SetProperty('Z7_ITEM'    , MODEL_FIELD_WHEN , {|| .F. })
//oStPai:SetProperty('Z7_CLIENTE' , MODEL_FIELD_WHEN , {|| .F. })
//oStPai:SetProperty('Z7_LOJA'    , MODEL_FIELD_WHEN , {|| .F. })
//oStPai:SetProperty('Z7_EXPEDID' , MODEL_FIELD_WHEN , {|| .F. })
//oStPai:SetProperty('Z7_EMISSAO' , MODEL_FIELD_WHEN , {|| .F. })

oModel:SetRelation('SZ8DETAIL', aSZRel, SZ8->(IndexKey(1))) //IndexKey -> quero a ordenação e depois filtrado
oModel:GetModel('SZ8DETAIL'):SetUniqueLine({"Z8_FILIAL","Z8_PRODUTO"})	//Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}
oModel:SetPrimaryKey({})

//Setando as descrições
oModel:SetDescription("MONTAGEM DE VOLUMES")
oModel:GetModel('SZ8DETAIL'):SetDescription('ITENS')

oModel:SetVldActive( { | oModel | Z8PREVLD(oModel) } )

Return oModel


/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Felipe Aguiar                                                |
 | Data:  06/2019                                                      |
 | Desc:  Criação da visão MVC                                         |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function ViewDef()

Local oView		:= Nil
Local oModel	:= FWLoadModel('CADSZ7')
Local oStPai	:= FWFormStruct(2, 'SZ7')
Local oStFilho	:= FWFormStruct(2, 'SZ8')

//Criando a View
oView := FWFormView():New()
oView:SetModel(oModel)

oStFilho:AddField( 'OK','','OK','',, 'Check')

//Adicionando os campos do cabeçalho e o grid dos filhos
oView:AddField('VIEW_SZ7',oStPai  ,'SZ7MASTER')
oView:AddGrid( 'VIEW_SZ8',oStFilho,'SZ8DETAIL')
oView:AddOtherObject("PANEL_SEL",{|oPanel,oOtherObject| CriaButtonSel(oPanel,oOtherObject)})

oStFilho:RemoveField('Z8_NUMVOL')
oStFilho:RemoveField('Z8_PEDIDO')
oStFilho:RemoveField('Z8_ITEM')
oStFilho:RemoveField('Z8_NUMSERI')

//Setando o dimensionamento de tamanho
oView:CreateHorizontalBox('CABEC',20)
oView:CreateHorizontalBox('BOX_SEL',05)
oView:CreateHorizontalBox('GRID',75)

//Amarrando a view com as box
oView:SetOwnerView('VIEW_SZ7' ,'CABEC'   )
oView:SetOwnerView('PANEL_SEL','BOX_SEL' )
oView:SetOwnerView('VIEW_SZ8' ,'GRID'    )

//Habilitando título
oView:EnableTitleView('VIEW_SZ8','ITENS')

Return oView


/*---------------------------------------------------------------------*
 | Func:  SZ7LEG                                                       |
 | Autor: Felipe Aguiar                                                |
 | Data:  06/2019                                                      |
 | Desc:  Criação da legenda                                           |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
User Function SZ7LEG()

Local a_Leg := {}

aAdd(a_Leg,{"BR_VERDE"     ,"Em Aberto"	})
aAdd(a_Leg,{"BR_VERMELHO"  ,"Embarcado"	})

BrwLegenda("STATUS", OemToAnsi("STATUS"), a_Leg)

Return Nil 


/*---------------------------------------------------------------------*
 | Func:  fExpEst                                                      |
 | Autor: Felipe Aguiar                                                |
 | Data:  06/2019                                                      |
 | Desc:  Explode estrutura do produto através da OP.                  | 
 | Obs.:  Gatilho chamado pelo campo Z7_OP                             |
 *---------------------------------------------------------------------*/
User Function fExpEst(cOp)
 
Local c_Query   := ""
Local oModel    := FWModelActive()
Local oModelSZ8 := oModel:GetModel( 'SZ8DETAIL' ) 
Local oModelSZ7 := oModel:GetModel( 'SZ7MASTER' ) 
Local nLinAtual := 0
Local n_Sld     := 0 
Local n_Qtd     := 0 
Local c_EOL     := CHR(13)+CHR(10)
Local n_Aux     := 1
Local a_AresC2  := SC2->(GetArea()) 
Local cTexto    := ""


c_OpOrig := LEFT(oModelSZ7:GetValue("Z7_OP"), 8 ) 

DbSelectArea("SC2")
DbSetOrder(1)//C2_FILIAL, C2_NUM, C2_ITEM, C2_SEQUEN, C2_ITEMGRD, R_E_C_N_O_, D_E_L_E_T_

If DbSeek(xFilial("SC2")+c_OpOrig+"001")

    If SC2->C2_PEDIDO <> oModelSZ7:GetValue("Z7_PEDIDO")
        If SC2->C2_XPEDMAN <> oModelSZ7:GetValue("Z7_PEDIDO")
            MsgStop("Pedido não atrelado a O.P. informada.") 
            oModelSZ7:LoadValue("Z7_OP","")
            Return Nil
        EndIf
    EndIf
EndIf    

c_Query := " SELECT	D4_OP,D4_COD, D4_LOCAL, D4_QUANT, D4_LOTECTL,B1_COD,B1_DESC,B1_XVOLUME"+c_EOL
c_Query += " FROM	"+RetSqlName("SD4")+"(NOLOCK) D4 "+c_EOL
c_Query += ""+c_EOL
c_Query += "	INNER JOIN "+RetSqlName("SB1")+"(NOLOCK) B1"+c_EOL
c_Query += "	ON	B1_FILIAL = '"+xFilial("SB1")+"'"+c_EOL
c_Query += "	AND	D4_COD = B1_COD"+c_EOL
c_Query += "	AND	B1.D_E_L_E_T_ = ''"+c_EOL
c_Query += ""+c_EOL
c_Query += " WHERE	D4_OP = '"+cOp+"'"+c_EOL
//c_Query += " AND    B1_XVOLUME = '1'"+c_EOL
c_Query += " AND    D4.D_E_L_E_T_ = ''"

If Select("EXPEST") > 0
	EXPEST->(DbCloseArea())
Endif

TCQUERY c_Query NEW ALIAS "EXPEST"

DbSelectArea("EXPEST")
EXPEST->(DbGoTop())

oModelSZ8:ClearData()

While EXPEST->(!Eof())  
	If EXPEST->B1_XVOLUME = '1'

    	n_Qtd := fSaldo()
    	n_Sld := EXPEST->D4_QUANT - n_Qtd

    	If n_Sld > 0       
    
        	If n_Aux > 1
            	oModelSZ8:AddLine()
        	EndIf    
        
        	nLinAtual := oModelSZ8:GetLine()

        	oModelSZ8:GoLine(nLinAtual)
        	oModelSZ8:LoadValue("OK", .F. )
        	oModelSZ8:LoadValue("Z8_PRODUTO", EXPEST->D4_COD     )
        	oModelSZ8:LoadValue("Z8_DESC"   , POSICIONE("SB1", 1, xFilial("SB1") + EXPEST->D4_COD , "B1_DESC") )                                     
        	oModelSZ8:LoadValue("Z8_QTDEMP" , EXPEST->D4_QUANT   )
        	oModelSZ8:LoadValue("Z8_LOCAL"  , EXPEST->D4_LOCAL   )
        	oModelSZ8:LoadValue("Z8_LOTE"   , EXPEST->D4_LOTECTL )
        	oModelSZ8:LoadValue("Z8_SALDO"  , n_Sld              )

        	n_Aux++

    	EndIf  
	Else 
		cTexto += "Cod.: " + EXPEST->B1_COD + " Produto.: " + EXPEST->B1_DESC + c_EOL
	Endif

    	EXPEST->(DbSkip()) 

EndDo 
       
If !Empty(cTexto)   
	AVISO("Atencao", "Os produtos abaixo estão com o campo 'Volume' na pasta outros em 'Branco' ou como 'Não' no cadastro de produtos." + c_EOL + cTexto,{ "OK"}, 3)
Endif

If oModelSZ8:GetQtdLine() > 0
    oModelSZ8:GoLine(1)
EndIf

If oModelSZ8:GetQtdLine() == 1 .AND. Empty(oModelSZ8:GetValue("Z8_PRODUTO"))
    MsgStop("Nao ha registros a serem exibidos.")   
    //oModelSZ8:SetNoInsertLine()
    //oModelSZ8:SetNoUpdateLine() 
    //oModelSZ8:SetNoDeleteLine()
EndIf    

RestArea(a_AresC2)

Return Nil


/*---------------------------------------------------------------------*
 | Func:  fSaldo                                                       |
 | Autor: Felipe Aguiar                                                |
 | Data:  06/2019                                                      |
 | Desc:  Busca saldo de empenho                                       | 
 | Obs.:                                                               |
 *---------------------------------------------------------------------*/
Static Function fSaldo()

Local c_Qry     := ""
Local c_EOL     := CHR(13)+CHR(10)
Local n_QtdJEnt := 0 

c_Qry   := "SELECT	 SUM(Z8_QTDVOL) AS 'QTJENT'"+c_EOL
c_Qry   += "FROM	 "+RetSqlName("SZ7")+"(NOLOCK) Z7"+c_EOL
c_Qry   += ""+c_EOL
c_Qry   += "	INNER JOIN "+RetSqlName("SZ8")+"(NOLOCK) Z8"+c_EOL
c_Qry   += "	ON	Z7_FILIAL = Z8_FILIAL"+c_EOL
c_Qry   += "	AND	Z7_NUMVOL = Z8_NUMVOL"+c_EOL
c_Qry   += "	AND	Z7_PEDIDO = Z8_PEDIDO"+c_EOL
c_Qry   += "	AND	Z7_ITEM = Z8_ITEM	"+c_EOL
c_Qry   += "	AND	Z8.D_E_L_E_T_ = ''"+c_EOL
c_Qry   += ""+c_EOL
c_Qry   += "WHERE	Z7_OP = '"+EXPEST->D4_OP+"'"+c_EOL
c_Qry   += "AND		Z8_PRODUTO = '"+EXPEST->D4_COD+"'"+c_EOL
c_Qry   += "AND		Z8_LOCAL = '"+EXPEST->D4_LOCAL+"'"+c_EOL
c_Qry   += "AND		Z7.D_E_L_E_T_ = ''"+c_EOL


If Select("XSEP") > 0
	XSEP->(DbCloseArea())
Endif

TCQUERY c_Qry NEW ALIAS "XSEP"

n_QtdJEnt := XSEP->QTJENT

Return n_QtdJEnt


/*---------------------------------------------------------------------*
 | Func:  CriaButtonSel                                                |
 | Autor: Felipe Aguiar                                                |
 | Data:  06/2019                                                      |
 | Desc:  Cria um botao                                                | 
 | Obs.:                                                               |
 *---------------------------------------------------------------------*/
Static Function CriaButtonSel(oPanel,oOtherObject)
    TButton():New( 02, 02, "Selecionar Todos",oPanel,{|| SelGrid(oOtherObject)}, 60,10,,,.F.,.T.,.F.,,.F.,,,.F. )
    TButton():New( 02, 65, "Atualizar Grid"  ,oPanel,{|| u_SZ8SALDO(oOtherObject)}, 60,10,,,.F.,.T.,.F.,,.F.,,,.F. )
Return Nil


/*---------------------------------------------------------------------*
 | Func:  SelGrid                                                      |
 | Autor: Felipe Aguiar                                                |
 | Data:  06/2019                                                      |
 | Desc:  Funcao Selecionar todos                                      | 
 | Obs.:                                                               |
 *---------------------------------------------------------------------*/
Static Function SelGrid(oOtherObject)

Local oGrid := oOtherObject:GetModel():GetModel("SZ8DETAIL")
Local nX
Local lValue
Local nLine := oGrid:GetLine()

For nX:=1 to oGrid:Length()
    oGrid:GoLine(nX)
    If !oGrid:isDeleted()
        lValue := oGrid:GetValue("OK")
        oGrid:LoadValue("OK", !lValue)
    EndIf
Next nX

oGrid:GoLine(nLine)
oOtherObject:oControl:Refresh('VIEW_SZ8')

Return Nil

/*---------------------------------------------------------------------*
 | Func:  FZ8GRV                                                       |
 | Autor: Felipe Aguiar                                                |
 | Data:  06/2019                                                      |
 | Desc:  Funcao que prepara gravação dos itens                        | 
 | Obs.:                                                               |
 *---------------------------------------------------------------------*/
 User Function FZ8GRV(oModel)

Local oModelZ8	:= oModel:GetModel('SZ8DETAIL')
Local lRet 		:= .T.
Local nOperation := oModel:GetOperation()


If  nOperation <> 5

    //Desbloqueia a exclusão de linhas do grid
    oModelZ8:SetNoDeleteLine(.F.)

    //Deleta os registros não selecionados
    For nCont := 1 To oModelZ8:Length()
        oModelZ8:GoLine( nCont )
        If !(oModelZ8:GetValue("OK", nCont))
            Iif(oModelZ8:IsDeleted(nCont),,oModelZ8:DeleteLine())	
        Endif
    Next nCont

    //Grava no banco										
    lRet := FWFormCommit(oModel)

    If lRet
        U_ETQVOL01( SZ7->Z7_NUMVOL, SZ7->Z7_PEDIDO, SZ7->Z7_ITEM , SZ7->Z7_OP )
    EndIf

Else

    DbSelectArea("SZ8")
    DbSetOrder(1)//Z8_FILIAL, Z8_NUMVOL, Z8_PEDIDO, Z8_ITEM, R_E_C_N_O_, D_E_L_E_T_

    If DbSeek(xFilial("SZ8")+SZ7->(Z7_NUMVOL+Z7_PEDIDO+Z7_ITEM))

        While SZ8->(!EOF()) .AND. SZ8->(Z8_NUMVOL+Z8_PEDIDO+Z8_ITEM) == SZ7->(Z7_NUMVOL+Z7_PEDIDO+Z7_ITEM)

            RecLock("SZ8", .F.)
			SZ8->(DbDelete())	
			SZ8->(MsUnlock())
        
            SZ8->(DbSkip())
        EndDo
    EndIf

    RecLock("SZ7", .F.)
	SZ7->(DbDelete())	
	SZ7->(MsUnlock())
    
EndIf

Return lRet


/*---------------------------------------------------------------------*
 | Func:  Z8PREVLD                                                       |
 | Autor: Felipe Aguiar                                                |
 | Data:  06/2019                                                      |
 | Desc:  Funcao de validação do modelo                                | 
 | Obs.:                                                               |
 *---------------------------------------------------------------------*/
Static Function Z8PREVLD(oModel)

Local lRet       := .T.
Local nOperation := oModel:GetOperation()

If nOperation == 4 .OR. nOperation == 5

    If SZ7->Z7_EXPEDID == "1" 
        Help(NIL, NIL, "XEMB", NIL, "Este volume não pode sofrer alterações pois já foi embarcado.", 1, 0, NIL, NIL, NIL, NIL, NIL, {""})
        Return .F.
    EndIf

EndIf

Return lRet

/*---------------------------------------------------------------------*
 | Func:  FZ8VLD                                                       |
 | Autor: Felipe Aguiar                                                |
 | Data:  06/2019                                                      |
 | Desc:  Funcao de validação do modelo                                | 
 | Obs.:                                                               |
 *---------------------------------------------------------------------*/
 User Function FZ8VLD(oModel)

Local aStr      := oModel:GetModel('SZ8DETAIL'):GetStruct():aFields
Local oModelVld := oModel:GetModel('SZ8DETAIL')
Local nOperation := oModelVld:GetOperation()
Local nX        := 0
Local nY        := 0
Local aAux      := {}
Local aItens    := {}
Local cAux      := ""
Local lRet      := .T.
Local c_Sld     := ""

If  nOperation <> 5

    For nX := 1 to oModelVld:Length()
        oModelVld:GoLine( nX )
        lOk := oModelVld:GetValue("OK")
        If lOk // Verifico se esta marcada
            If !(oModelVld:IsDeleted(nX)) // Verifico se esta deletada
                aAux := {}
                For nY := 1 to Len(aStr)
                    cAux := oModelVld:GetValue(aStr[nY][3])

                    If aStr[nY][3] == "Z8_SALDO"
                        c_Sld := cAux
                    EndIf
                    
                    If  aStr[nY][3] == "Z8_QTDVOL" .AND. (  cAux == 0 .OR. c_Sld < cAux )     
                            Help(NIL, NIL, "QTDITEM", NIL, "Quantidade invalida", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Digite uma quantidade para volumar ou verifique o saldo disponivel do item "+ oModelVld:GetValue("Z8_PRODUTO") })
                            Return .F.              
                    EndIf         
                    aAdd(aAux,{aStr[nY][3],cAux})	
                Next nY
                aAdd(aItens, { aClone(aAux) } )
            EndIf
        EndIf
    Next nX

    If Len(aItens) == 0 
        Help(NIL, NIL, "NOSELITEM", NIL, "Itens", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Necessário marcar ao menos um item."})	
        lRet := .F.
    EndIf

EndIf

Return lRet


/*---------------------------------------------------------------------*
 | Func:  SZ7EMB                                                       |
 | Autor: Felipe Aguiar                                                |
 | Data:  06/2019                                                      |
 | Desc:  Embarca o volume selecionado                                 |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
User Function SZ7EMB()

Private o_LbxVol
Private o_Chk
Private l_Chk 		:= .F.
Private a_Volumes 	:= {}
Private oOk			:= LoadBitmap( GetResources(), "CHECKED" )   	//CHECKED
Private oNo 		:= LoadBitmap( GetResources(), "UNCHECKED" ) 	//UNCHECKED
Private cPerg       := "XEMBVOL"

ValidPerg(cPerg)

If !pergunte(cPerg,.T.)
	Return Nil
EndIf

fVolumes()

If Len( a_Volumes ) == 0
   MsgInfo("Não existe registros para os parâmetros informados.","I-N-F-O-R-M-A-Ç-Ã-O")
   Return Nil
EndIf

cCadastro := "Selecione Volumes para Embarque"
oSize := FwDefSize():New(.T.)             

oSize:AddObject( "CABECALHO", 100, 100 , .T., .T. ) // Totalmente dimensionavel

oSize:lProp 	:= .T. // Proporcional             
oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos 

oDlg := MSDialog():New(oSize:aWindSize[1],oSize:aWindSize[2],oSize:aWindSize[3],oSize:aWindSize[4],"",,,,,CLR_BLACK,CLR_WHITE,,,.T.)
 

oGrp1   := TGroup():New(oSize:GetDimension("CABECALHO","LININI"),;
						oSize:GetDimension("CABECALHO","COLINI"),;
						oSize:GetDimension("CABECALHO","LINEND"),;
						oSize:GetDimension("CABECALHO","COLEND"),"",oDlg,,,.T.,)            

@ oSize:GetDimension("CABECALHO","LININI")+30,oSize:GetDimension("CABECALHO","COLINI")+5 LISTBOX o_LbxVol FIELDS HEADER ;
" ", "Pedido", "Item", "Volume" ;
COLSIZES 10,25,25,25   SIZE oSize:GetDimension("CABECALHO","XSIZE")-10 , oSize:GetDimension("CABECALHO","YSIZE")-20 OF oDlg Pixel ON DblClick(a_Volumes[o_LbxVol:nAt,1] := !a_Volumes[o_LbxVol:nAt,1]) 

o_LbxVol:SetArray( a_Volumes )
		o_LbxVol:bLine := {|| {Iif(	a_Volumes[o_LbxVol:nAt,1],oOk,oNo),;
		a_Volumes[o_LbxVol:nAt,2],;
        a_Volumes[o_LbxVol:nAt,3],;
        a_Volumes[o_LbxVol:nAt,4]}}

@ oSize:GetDimension("CABECALHO","LININI")+10,10 CHECKBOX o_Chk VAR l_Chk PROMPT "Inverter a Seleção" SIZE 70,7 PIXEL OF oDlg;
		ON CLICK( aEval( a_Volumes, {|x| x[1] := !x[1] } ), o_LbxVol:Refresh() )

oDlg:bInit := {||  EnchoiceBar(oDlg,{|| oDlg:End(), fGrvEmb() },{||oDlg:End()})}		

oDlg:Activate()    

Return Nil

/*---------------------------------------------------------------------*
 | Func:  fVolumes                                                     |
 | Autor: Felipe Aguiar                                                |
 | Data:  08/2019                                                      |
 | Desc:  Carrega dados para Embarque                                  |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function fVolumes()    

Local c_Query := ""

c_Query += " SELECT *" 
c_Query += " FROM "+RetSqlName("SZ7")   
c_Query += " WHERE D_E_L_E_T_ = ''" 
c_Query += " AND Z7_PEDIDO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'" 
c_Query += " AND Z7_ITEM BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 +  "'"
c_Query += " AND Z7_EXPEDID = '2'"

If Select("QRY") > 0
	QRY->(DbCloseArea())
Endif 

TCQUERY c_Query NEW ALIAS "QRY"       

While QRY->(!EOF())
	aAdd( a_Volumes, { .F. ,; 
	                 QRY->Z7_PEDIDO,;
					 QRY->Z7_ITEM,;
					 QRY->Z7_NUMVOL })
	QRY->(DbSkip())
EndDo 

Return Nil

/*---------------------------------------------------------------------*
 | Func:  fGrvEmb                                                      |
 | Autor: Felipe Aguiar                                                |
 | Data:  08/2019                                                      |
 | Desc:  Grava Embarque                                               |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function fGrvEmb()  

Local n_I       := 0
Local a_AreaSZ7 := SZ7->(GetArea())

For n_I := 1 To Len(a_Volumes)	
	If a_Volumes[n_I][1]		

        DbSelectArea("SZ7")
        DbSetOrder(1)//Z7_FILIAL, Z7_NUMVOL, Z7_PEDIDO, Z7_ITEM, R_E_C_N_O_, D_E_L_E_T_

        If DbSeek(xFilial("SZ7")+a_Volumes[n_I][4]+a_Volumes[n_I][2]+a_Volumes[n_I][3] )
                        
            RECLOCK("SZ7",.F.)
            SZ7->Z7_EXPEDID := "1"
            MSUNLOCK()

        EndIf

	EndIf
Next n_I

MsgInfo("Processo finalizado.")

RestArea(a_AreaSZ7)

Return Nil


/*---------------------------------------------------------------------*
 | Func:  SZ7NUM                                                       |
 | Autor: Felipe Aguiar                                                |
 | Data:  06/2019                                                      |
 | Desc:  Gatilho para numeracao                                       |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
User Function SZ7NUM()

Local c_Num     := "000001"
Local c_Gat     := ""
Local c_OpOrig  := ""
Local oModel    := FWModelActive()
Local oModelSZ7 := oModel:GetModel( 'SZ7MASTER' ) 

c_Gat := " SELECT CASE WHEN MAX(Z7_NUMVOL) IS NULL THEN '000001' ELSE REPLICATE('0', 6 - LEN(MAX(Z7_NUMVOL)+1)) + RTrim(MAX(Z7_NUMVOL)+1) 
c_Gat += "	 END AS 'PROX'"
c_Gat += " FROM	"+RetSqlName("SZ7")+"(NOLOCK)"
c_Gat += " WHERE Z7_FILIAL = '"	+xFilial("SZ7")+"'"
c_Gat += " AND Z7_PEDIDO = '"+oModelSZ7:GetValue("Z7_PEDIDO")+"'"
c_Gat += " AND		Z7_ITEM = '"+oModelSZ7:GetValue("Z7_ITEM")+"'"
//c_Gat += " AND		D_E_L_E_T_ = ''"

If Select("ZNUM") > 0
	ZNUM->(DbCloseArea())
Endif

TCQUERY c_Gat NEW ALIAS "ZNUM"

DbSelectArea("ZNUM")
ZNUM->(DbGoTop())  

c_Num := ZNUM->PROX

Return c_Num



/*---------------------------------------------------------------------*
 | Func:  VLDITEM                                                      |
 | Autor: Felipe Aguiar                                                |
 | Data:  06/2019                                                      |
 | Desc:  Valida se pode usar o pedido                                 |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
User Function VLDITEM()

Local l_Ret     := .T.
Local c_Qry     := ""
Local oModel    := FWModelActive()
Local oModelSZ7 := oModel:GetModel( 'SZ7MASTER' ) 
Local n_Qtd     := 0

c_Qry := " SELECT	COUNT(*) AS ITEM"
c_Qry += " FROM	"+RetSqlName("SC5") +"(NOLOCK) C5"
c_Qry += " INNER JOIN "+RetSqlName("SC6") +"(NOLOCK) C6"
c_Qry += " 	ON	C5_FILIAL = C6_FILIAL"
c_Qry += " 	AND C5_NUM = C6_NUM "
c_Qry += " 	AND C6.D_E_L_E_T_ = ''"
c_Qry += " WHERE	C5_FILIAL = '"+xFilial("SC5")+"'"
c_Qry += " AND		C5_NUM = '"+oModelSZ7:GetValue("Z7_PEDIDO")+"'"
c_Qry += " AND		C5.D_E_L_E_T_ = ''"
c_Qry += " AND		C6_NOTA = ''"

If Select("VLDITEM") > 0
	VLDITEM->(DbCloseArea())
Endif

TCQUERY c_Qry NEW ALIAS "VLDITEM"

DbSelectArea("VLDITEM")
VLDITEM->(DbGoTop())  

n_Qtd := VLDITEM->ITEM

If n_Qtd == 0 
    l_Ret := .F.
    Help(NIL, NIL, "XSZ7PED", NIL, "Este pedido já foi faturado.", 1, 0, NIL, NIL, NIL, NIL, NIL,)	
EndIf

Return l_Ret


/************************************************************************************************************************* */
Static Function ValidPerg(c_Perg)

aRegs := {}

//         Grupo /Ordem /Pergunta                /PERSPA   / PERENG/Variavel/Tipo   /Tamanho  /Decimal/Presel /GSC /Valid/Var01      /Def01    		  	/DEFSPA1 /DEFENG1 /Cnt01 /Var02     /Def02           /DEFSPA2 /DEFENG2 /Cnt02 /Var03     /Def03          /DEFSPA3 /DEFENG3 /Cnt03 /Var04     /Def04          	/DEFSPA4 /DEFENG4 /Cnt04 /Var05     /Def05          /DEFSPA5/DEFENG5  /Cnt05 /F3   /PYME/GRPSXG
aAdd(aRegs,{c_Perg,"01"  ,"Pedido de?"			,""      	,""     ,"MV_CH1","C"    ,06      ,0       ,0     ,"G" ,""    ,"MV_PAR01",""					,""      ,""      ,""   ,""         ,""  			,""      ,""      ,""    ,""        ,""        		 ,""      ,""     ,""     ,""       ,""             	,""      ,""      ,""    ,""        ,""            ,""      ,""      ,""    ,"SC5"    })
aAdd(aRegs,{c_Perg,"02"  ,"Pedido até?"			,""      	,""     ,"MV_CH2","C"    ,06      ,0       ,0     ,"G" ,""    ,"MV_PAR02",""					,""      ,""      ,""   ,""         ,""			  	,""      ,""      ,""    ,""        ,""			     ,""      ,""     ,""     ,""       ,""             	,""      ,""      ,""    ,""        ,""            ,""      ,""      ,""    ,"SC5"    })
aAdd(aRegs,{c_Perg,"03"  ,"Item de?"		    ,""      	,""     ,"MV_CH3","C"    ,02      ,0       ,0     ,"G" ,""    ,"MV_PAR03",""					,""      ,""      ,""   ,""         ,""			  	,""      ,""      ,""    ,""        ,""			     ,""      ,""     ,""     ,""       ,""             	,""      ,""      ,""    ,""        ,""            ,""      ,""      ,""    ,""       })
aAdd(aRegs,{c_Perg,"04"  ,"Item até?"		    ,""      	,""     ,"MV_CH4","C"    ,02      ,0       ,0     ,"G" ,""    ,"MV_PAR04",""					,""      ,""      ,""   ,""         ,""			  	,""      ,""      ,""    ,""        ,""			     ,""      ,""     ,""     ,""       ,""             	,""      ,""      ,""    ,""        ,""            ,""      ,""      ,""    ,""       })

U_PutX1PERF(c_Perg, aRegs)

Return Nil

/*---------------------------------------------------------------------*
 | Func:  SZ8SALDO                                                     |
 | Autor: Felipe Aguiar                                                |
 | Data:  06/2019                                                      |
 | Desc: Atualiza o saldo na alteracao do volume                       |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
User Function SZ8SALDO(oOtherObject)

Local nSaldo        := 0 
Local oModel        := FWModelActive()
Local oModelZ7      := oOtherObject:GetModel():GetModel("SZ7MASTER") 
Local oModelVld     := oOtherObject:GetModel():GetModel("SZ8DETAIL") 
Local nOperation    := oModelVld:GetOperation()
Local nX            := 0
Local nY            := 0

If nOperation == 4

    For nX := 1 to oModelVld:Length()
        oModelVld:GoLine( nX )
        If !(oModelVld:IsDeleted(nX)) // Verifico se esta deletada
            nRetSld := fQrySld( oModelZ7:GetValue("Z7_OP") , oModelVld:GetValue("Z8_PRODUTO") , oModelVld:GetValue("Z8_LOCAL")  )
            nResult := oModelVld:GetValue("Z8_QTDEMP") - nRetSld
            oModelVld:LoadValue("Z8_SALDO" , nResult)
        EndIf
    Next nX

EndIf

oModelVld:GoLine(1)
oOtherObject:oControl:Refresh('VIEW_SZ8')

Return Nil

/********************************************************88 */
Static Function fQrySld(_OP,_PRODUTO,_LOCAL )

Local c_Qry := ""

c_Qry   := " SELECT	 SUM(Z8_QTDVOL) AS 'QTJENT'"
c_Qry   += " FROM	 "+RetSqlName("SZ7")+"(NOLOCK) Z7"
c_Qry   += "	INNER JOIN "+RetSqlName("SZ8")+"(NOLOCK) Z8"
c_Qry   += "	ON	Z7_FILIAL = Z8_FILIAL"
c_Qry   += "	AND	Z7_NUMVOL = Z8_NUMVOL"
c_Qry   += "	AND	Z7_PEDIDO = Z8_PEDIDO"
c_Qry   += "	AND	Z7_ITEM = Z8_ITEM	"
c_Qry   += "	AND	Z8.D_E_L_E_T_ = ''"
c_Qry   += " WHERE	Z7_OP ='"+_OP+"'"
c_Qry   += " AND		Z8_PRODUTO = '"+_PRODUTO+"'"
c_Qry   += " AND		Z8_LOCAL = '"+_LOCAL+"'"
c_Qry   += " AND		Z7.D_E_L_E_T_ = ''"

If Select("XSEP") > 0
    XSEP->(DbCloseArea())
Endif

TCQUERY c_Qry NEW ALIAS "XSEP"

n_QtdJEnt := XSEP->QTJENT

Return n_QtdJEnt




