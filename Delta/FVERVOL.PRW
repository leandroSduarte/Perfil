#INCLUDE "Protheus.ch"
#INCLUDE "RWMAKE.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "TbiConn.ch"


/*-------------------------------------------------------------------------------------
{Protheus.doc} FVERVOL

@Author  	   Felipe Aguiar - Focus Consultoria
@since		   07/2019
@version	   P12

@description Verifica se existem itens do empenho sem volumes montados 
---------------------------------------------------------------------------------------
|Author                  | Date       | Description                                    |
|                        |            |                                                |
--------------------------------------------------------------------------------------*/
User Function FVERVOL()

Local oDlg
Local c_Title 		:= OemToAnsi("Verificação de Empenhos x Volumes ")
Local n_Opca 		:= 0
Local a_CA			:= { OemToAnsi("Confirma"), OemToAnsi("Abandona")}
Local a_Says		:= {}
Local a_Buttons		:= {}
Local c_Perg		:= "XVERVOL"
Private l_Ret		:= .T.
Private a_Relato    := {}

ValidPerg(c_Perg);	Pergunte(c_Perg, .F.)

c_Texto	:= "Este programa tem como objetivo verificar se existem"
aAdd(a_Says, OemToAnsi(c_Texto)) 		
c_Texto	:= "itens empenhados na O.P que não foram montado volumes."  	
aAdd(a_Says, OemToAnsi(c_Texto)) 	
c_Texto	:= "[Vr.07/2019]"
aAdd(a_Says, OemToAnsi(c_Texto))
aAdd(a_Buttons, { 1,.T.,{|o| n_Opca:= 1, If( .T., o:oWnd:End(), n_Opca:=0 ) }} )
aAdd(a_Buttons, { 2,.T.,{|o| o:oWnd:End() }} )
aAdd(a_Buttons, { 5,.T.,{|o| Pergunte(c_Perg, .T.) }} )
FormBatch( c_Title, a_Says, a_Buttons ,,220,380)

If n_Opca == 1
    Processa({|lend| l_Ret := fVerItens()},"Pesquisando dados... Por favor, aguarde.")
    If l_Ret
        MsgInfo("Não existem itens pendentes!", "Informativo")
    Else
        MsgInfo("Existem itens pendentes, será gerado um relatório.", "Atenção")
        fGeraRel()
    Endif
Else
    MsgStop("Rotina cancelada!","Abortado")
Endif

Return Nil 


/*************************************************************************************************************************/
Static Function fVerItens()

Local l_Ret     := .T.
Local c_Query   := ""
Local c_EOL     := CHR(13)+CHR(10)
Local n_QtdVol  := 0

c_Query := " SELECT	D4_OP,D4_COD, D4_LOCAL, D4_QUANT "
c_Query += " FROM	"+RetSqlName("SD4")+"(NOLOCK) D4 "
c_Query += ""
c_Query += "	INNER JOIN "+RetSqlName("SB1")+"(NOLOCK) B1"
c_Query += "	ON	B1_FILIAL = '"+xFilial("SB1")+"'"
c_Query += "	AND	D4_COD = B1_COD"
c_Query += "	AND	B1.D_E_L_E_T_ = ''"
c_Query += ""
c_Query += " WHERE	D4_OP BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"
c_Query += " AND    B1_XVOLUME = 'S'"
c_Query += " AND    D4.D_E_L_E_T_ = ''"

If Select("EXPEST") > 0
	EXPEST->(DbCloseArea())
Endif

TCQUERY c_Query NEW ALIAS "EXPEST"

DbSelectArea("EXPEST")
EXPEST->(DbGoTop())

While EXPEST->(!Eof()) 

    n_QtdVol := ftemVol(EXPEST->D4_OP, EXPEST->D4_COD )
    n_Sld    := EXPEST->D4_QUANT - n_QtdVol

    If n_Sld > 0 

        aAdd( a_Relato, {EXPEST->D4_COD , n_Sld, EXPEST->D4_OP } )
        l_Ret := .F.

    EndIf

    EXPEST->(DbSkip()) 

EndDo

Return l_Ret

/*************************************************************************************************************************/
Static Function ftemVol(c_Op,c_Produto )

Local c_Qry := ""
Local n_Ret := 0

c_Qry := " SELECT	SUM(Z8_QTDVOL) AS 'VOL'"
c_Qry += " FROM	"+RetSqlName("SZ7")+"(NOLOCK) Z7"
c_Qry += " 	INNER JOIN SZ8010(NOLOCK) Z8"
c_Qry += " 	ON Z7_FILIAL = Z8_FILIAL"
c_Qry += " 	AND	Z7_NUMVOL = Z8_NUMVOL"
c_Qry += " 	AND	Z7_PEDIDO = Z8_PEDIDO"
c_Qry += " 	AND Z7_ITEM = Z8_ITEM"
c_Qry += " 	AND Z8.D_E_L_E_T_ = ''"
c_Qry += " WHERE	Z7_OP = '"+c_Op+"'"
c_Qry += " AND		Z8_PRODUTO = '"+c_Produto+"'"
c_Qry += " AND		Z7.D_E_L_E_T_ = ''"

If Select("TEMVOL") > 0
	TEMVOL->(DbCloseArea())
Endif

TCQUERY c_Qry NEW ALIAS "TEMVOL"

DbSelectArea("TEMVOL")
TEMVOL->(DbGoTop())

n_Ret := TEMVOL->VOL

Return n_Ret

/*************************************************************************************************************************/
Static Function ValidPerg(c_Perg)

aRegs := {}

//         Grupo /Ordem /Pergunta                /PERSPA   / PERENG/Variavel/Tipo   /Tamanho  /Decimal/Presel /GSC /Valid/Var01      /Def01    		  	/DEFSPA1 /DEFENG1 /Cnt01 /Var02     /Def02           /DEFSPA2 /DEFENG2 /Cnt02 /Var03     /Def03          /DEFSPA3 /DEFENG3 /Cnt03 /Var04     /Def04          	/DEFSPA4 /DEFENG4 /Cnt04 /Var05     /Def05          /DEFSPA5/DEFENG5  /Cnt05 /F3   /PYME/GRPSXG
aAdd(aRegs,{c_Perg,"01"  ,"OP de?"			,""      	,""     ,"MV_CH1","C"    ,14      ,0       ,0     ,"G" ,""    ,"MV_PAR01",""					,""      ,""      ,""   ,""         ,""  			,""      ,""      ,""    ,""        ,""        		 ,""      ,""     ,""     ,""       ,""             	,""      ,""      ,""    ,""        ,""            ,""      ,""      ,""    ,"SC2"    })
aAdd(aRegs,{c_Perg,"02"  ,"OP até?"			,""      	,""     ,"MV_CH2","C"    ,14      ,0       ,0     ,"G" ,""    ,"MV_PAR02",""					,""      ,""      ,""   ,""         ,""			  	,""      ,""      ,""    ,""        ,""			     ,""      ,""     ,""     ,""       ,""             	,""      ,""      ,""    ,""        ,""            ,""      ,""      ,""    ,"SC2"    })

U_PutX1PERF(c_Perg, aRegs)

Return Nil

/********************************************************************************************************************/

Static Function	fGeraRel()

Local oExcel 	:= FWMSEXCEL():New() 
Local c_Dia 	:= STRTRAN(DTOC(MSDATE()),"/","_")+"_"+Replace(Time(),":","_")
Local c_Arq		:= ""
Local c_ExtArq 	:= ".xml"
Local c_Path 	:= cGetFile("\", "Selecione o Local para salvar a Arquivo.",,,,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_LOCALFLOPPY)
Local c_Obs  := ""

If !ExistDir( c_Path )
	c_Path 	:= __RELDIR
EndIf
 
oExcel:SetTitleFrColor("#000000") 	// Cor do Texto da Primeira Linha
oExcel:SetTitleBgColor("#FFFFFF") 	// Cor de Fundo da Primeira Linha
oExcel:SetFrColorHeader("#FFFFFF")  // Texto do Titulo das Colunas
oExcel:SetBgColorHeader("#003366")  // Background do Titulo das Colunas
oExcel:SetLineBGColor("#FFFFFF")  	// Background das linhas de texto
oExcel:Set2LineBGColor("#FFFFFF")	// Background das linhas de texto 	

c_XLS := "Saldo_Op_X_Volumes_"+c_Dia
c_Tab := "ITENS"

oExcel:AddworkSheet( c_Tab )          
oExcel:AddTable ( c_Tab, c_Tab )
oExcel:AddColumn( c_Tab, c_Tab, "Produto"           ,1,1)
oExcel:AddColumn( c_Tab, c_Tab, "Saldo Sem Volumes" ,1,2)
oExcel:AddColumn( c_Tab, c_Tab, "OP"                ,1,1)


For n_Diver := 1 To Len(a_Relato) 
	
    oExcel:AddRow( c_Tab, c_Tab, {	a_Relato[n_Diver][1],;
									a_Relato[n_Diver][2],;
									a_Relato[n_Diver][3] } )
	
Next n_Diver

oExcel:Activate()
oExcel:GetXMLFile(c_XLS+c_ExtArq)
	
//- Move Arquivo para Pasta Relato do Usuário
c_NovoArq := AllTrim(c_Path + c_XLS + c_ExtArq)

If __CopyFile( c_XLS+c_ExtArq, c_NovoArq )
	//MsgInfo( "Arquivo " + c_NovoArq + " gerado com sucesso no diretório " + c_Path )
    ShellExecute("open", c_Path + c_XLS + c_ExtArq, "", "", 1)
Else
	MsgStop( "Arquivo não copiado para temporário do usuário." )
EndIf

Return Nil