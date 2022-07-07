#INCLUDE "FIVEWIN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE 'TOPCONN.CH'
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#Define DMPAPER_A4 9 // A4 210 x 297 mm


/*-------------------------------------------------------------------------------------
{Protheus.doc} RELPSEP

@Author  	   Felipe Aguiar - Focus Consultoria
@since		   06/2019
@version	   P12

@description Relatorio de Pre Separacao
---------------------------------------------------------------------------------------
|Author                  | Date       | Description                                    |
|                        |            |                                                |
--------------------------------------------------------------------------------------*/

User Function RELPSEP(n_Orig, c_Mv01,c_Mv02,c_Mv03,c_Mv04)

Local wnrel			:= "RELSEP"

Local lAdjustToLegacy 	:= .T.
Local lDisableSetup 	:= .T. 
Local cLocal            := GetTempPath() 

Private lViewPDF    := .T.
Private contador 	:= 0
Private cStartPath 	:= GetSrvProfString("Startpath","")
Private cPecaRev 	:= ""
Private Tamanho		:= "G"
Private titulo	 	:= "Pré Separação"
Private aReturn 	:= {"Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
Private nomeprog	:= "PERFSEP"
Private nLastKey	:= 0
Private nBegin		:= 0
Private nDifColCC   := 0
Private aLinha		:= {}
Private aSenhas		:= {}
Private aUsuarios	:= {}
Private M_PAG		:= 1
Private lin 		:= 580
Private ncw 		:= 1
Private nordem 		:= 1
Private c_Perg      := "XPRESEP"

Private c_Pag       := "01" 

Default n_Orig      := 1 // 1= Menu , 2 = impressao de op  
Default c_Mv01      := ""
Default c_Mv02      := ""
Default c_Mv03      := ""
Default c_Mv04      := ""

ValidPerg(c_Perg)

If n_Orig == 1

    If !Pergunte(c_Perg, .T.)
        Return .F.
    EndIf

Else 

    MV_PAR01 := c_Mv01
    MV_PAR02 := c_Mv02
    MV_PAR03 := c_Mv03
    MV_PAR04 := c_Mv04
    
EndIf    

//oPrint	:= TMSPrinter():New( "Pré Separação" )

oPrint := FWMSPrinter():New(Alltrim(MV_PAR01)+"_presep.rel", IMP_PDF, lAdjustToLegacy,cLocal, lDisableSetup, , , , , , .F., lViewPDF )
oPrint:cPathPDF := cLocal

MsgRun("Gerando Visualizacao, Aguarde...","",{|| CursorWait(), MontaRel(oPrint), CursorArrow()})
 
oPrint:SetPortrait()
oPrint:SetPaperSize(DMPAPER_A4)

oPrint:Setup()

If oPrint:nModalResult == PD_OK
	oPrint:Preview()
	oPrint:SetViewPDF(.T.)
EndIf

Return Nil


/**************************************************************************************************/
Static Function MontaRel(oPrint)   

Local c_Obs	    := ""
Local a_Lista   := {}
Local c_Cabec   := ""
Local n_Aux     := 1
	
oArial18N	:= TFont():New("Arial",18,18,,.T.,,,,.T.,.F.)
oArial14N	:= TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)
oArial12N	:= TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)
oArial12	:= TFont():New("Arial",12,12,,.F.,,,,.F.,.F.)
oArial10	:= TFont():New("Arial",10,10,,.F.,,,,.F.,.F.)
oArial12N	:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
oArial8	    := TFont():New("Arial",08,08,,.F.,,,,.F.,.F.)
oArial9	    := TFont():New("Arial",09,09,,.F.,,,,.F.,.F.)

_nMargEsq 	    := 50
_nMargDir	    := 3100

c_Cabec   := " SELECT	C2_NUM+C2_ITEM AS 'ORIG',C2_NUM+C2_ITEM+C2_SEQUEN AS 'OP', C2_PRODUTO , B1_DESC, C2_QUANT, C2_UM, C2_EMISSAO, C2_PEDIDO, C5_CLIENTE, C5_LOJACLI, A1_NOME ,C2_DATPRF, C2_OBS "
c_Cabec   += " FROM	"+RetSqlName("SC2")+"(NOLOCK) C2 "
c_Cabec   += "	INNER JOIN "+RetSqlName("SB1")+"(NOLOCK) B1 "
c_Cabec   += "	ON B1_FILIAL = '"+xFilial("SB1")+"'"
c_Cabec   += "	AND	C2_PRODUTO = B1_COD "
c_Cabec   += "	AND B1.D_E_L_E_T_ = '' "
c_Cabec   += " LEFT JOIN "+RetSqlName("SC5")+"(NOLOCK) C5 "
c_Cabec   += "	ON	C2_FILIAL = C5_FILIAL " 
c_Cabec   += "	AND	C2_PEDIDO = C5_NUM "
c_Cabec   += "	AND C5.D_E_L_E_T_ = '' "
c_Cabec   += " LEFT JOIN "+RetSqlName("SA1")+"(NOLOCK) A1 "
c_Cabec   += "	ON	A1_FILIAL = '"+xFilial("SA1")+"' " 
c_Cabec   += "	AND	A1_COD = C5_CLIENTE "
c_Cabec   += "	AND	A1_LOJA = C5_LOJACLI "
c_Cabec   += "	AND	A1.D_E_L_E_T_ = '' "
c_Cabec   += " WHERE	C2_NUM+C2_ITEM+C2_SEQUEN BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"
c_Cabec   += " AND      C2_DATPRF BETWEEN '"+ DTOS(MV_PAR03)+ "' AND '"+ DTOS(MV_PAR04)+"'"
//c_Cabec   += " AND   B1_XPRESEP = '1'"
c_Cabec   += " AND		C2.D_E_L_E_T_ = ''"
c_Cabec   += " ORDER BY OP "

If Select("CABEC") > 0
	CABEC->(DBCLOSEAREA())
EndIf

TcQuery c_Cabec New Alias "CABEC"

CABEC->(DbGotop())
While CABEC->(!EOF())

    a_Lista := fDadosEmp()
    
    If Len(a_Lista) > 0 
    
        n_Linha := 682 //Linha inicio dos itens

        n_Aux := 1

        oPrint:StartPage() // Inicia uma nova pagina
        fCabec()//Imprimi Cabecalho

        //Percorre os itens SD4
        For n_Item := 1 To Len(a_Lista)

            If n_Aux > 38 // Numero de itens que cabem no box, caso seja maior, crio uma nova pagina
                
                c_Pag := SOMA1(c_Pag)            
                fRodape() 
                oPrint:EndPage() 	
                oPrint:StartPage() // Inicia uma nova pagina
                fCabec()
                n_Aux := 1
                n_Linha := 682 //Qndo trocar a pagina, volto para a primeira linha do box
                
            EndIf    
            
            //Percorre as colunas impressas
            For n_Dad := 1 To Len(a_Lista[n_Item])
                
                n_Col   := a_Lista[n_Item][n_Dad][1]
                c_Inf   := ""

                If ValType(a_Lista[n_Item][n_Dad][2]) == "C"
                    c_Inf   := a_Lista[n_Item][n_Dad][2]
                ElseIf ValType(a_Lista[n_Item][n_Dad][2]) == "N"
                    c_Inf   := STR(a_Lista[n_Item][n_Dad][2])
                ElseIf ValType(a_Lista[n_Item][n_Dad][2]) == "D"
                    c_Inf   := DTOC(a_Lista[n_Item][n_Dad][2])   
                EndIf

                oPrint:Say( n_Linha , n_Col , c_Inf , oArial9 )
                            
            Next n_Dad
            
            If n_Aux < 38
                oPrint:Line( n_Linha + 25 , 50, n_Linha + 25, 2339)   	// LINHA HORIZONTAL
            EndIf

            n_Linha := n_Linha + 50

            n_Aux++

        Next n_Item
        
        fRodape()      
                
        oPrint:EndPage() 		// Finaliza a pagina

        c_Pag := "01" // Ao trocar de OP reinicio a contagem de paginas

    EndIf 

    CABEC->(DbSkip())

EndDo

	
Return Nil

/***************************************************************************************************/
Static Function fCabec()

Local cLogo     := "\system\lgrl01.bmp"	
Local cNomEmp   := ALLTRIM(Posicione("SM0",1,cEmpAnt+cFilAnt,"M0_NOME") )
Local cNomFil   := ALLTRIM(Posicione("SM0",1,cEmpAnt+cFilAnt,"M0_FILIAL") )
Local a_AreaSC2 := SC2->(GetArea())
Local a_AreaSC5 := SC5->(GetArea())
Local a_AreaSA1 := SA1->(GetArea())
Local c_Pedido  := ""
Local c_ItemPv  := ""

//Logotipo
oPrint:SayBitmap(060,050,cLogo,302,165)

oPrint:Say( 132, 400, "Empresa: " +cNomEmp   ,oArial12N )
oPrint:Say( 182, 400, "Filial: "  +cNomFil   ,oArial12N )

oPrint:Say( 132, 1200, "PRÉ SEPARAÇÃO: " ,oArial12N )
oPrint:Say( 182, 1200, "NRO: " +ALLTRIM(CABEC->OP)    ,oArial14N )

oPrint:Say( 082, 2110, "Pág.: " + c_Pag ,oArial8 )
oPrint:Say( 132, 2110, "Emissão: " + DtoC(MsDate()) ,oArial8 )
oPrint:Say( 182, 2110, "Hora: " + Time()            ,oArial8 )

oPrint:Line( 243, 50, 243, 2339)   	// LINHA HORIZONTAL

DbSelectArea("SC2")
SC2->(DbSetOrder(1))
SC2->(DbSeek( xFilial("SC2")+CABEC->ORIG+"001")) //C2_FILIAL, C2_NUM, C2_ITEM, C2_SEQUEN, C2_ITEMGRD, R_E_C_N_O_, D_E_L_E_T_

If !(Empty(SC2->C2_PEDIDO))
    c_Pedido := SC2->C2_PEDIDO
    c_ItemPv := SC2->C2_ITEMPV
Else
    c_Pedido := SC2->C2_XPEDMAN
    c_ItemPv := SC2->C2_XITEPEM
EndIf

DbSelectArea("SC5")
SC5->(DbSetOrder(1))
SC5->(DbSeek( xFilial("SC5")+c_Pedido))

DbSelectArea("SC6")
SC6->(DbSetOrder(1))
SC6->(DbSeek( xFilial("SC6")+c_Pedido+c_ItemPv))

DbSelectArea("SA1")
SA1->(DbSeek( xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI ))

oPrint:Say( 300, 060, "Data Geração: " +ALLTRIM(DTOC(STOD(CABEC->C2_EMISSAO))), oArial12N )
oPrint:Say( 350, 060, "Pedido/Item: "       +ALLTRIM(c_Pedido) +" / "+ ALLTRIM(c_ItemPv) , oArial12N  ) 
oPrint:Say( 400, 060, "Produto: "      +ALLTRIM(CABEC->C2_PRODUTO), oArial12N )
oPrint:Say( 450, 060, "Quantidade: "   +Alltrim(Transform(CABEC->C2_QUANT,PesqPict("SC2","C2_QUANT"))), oArial12N )
oPrint:Say( 500, 060, "Obs: "          +ALLTRIM(CABEC->C2_OBS), oArial12N )

oPrint:Say( 300, 750, "Usuario Impressão: " + cUserName , oArial12N )
oPrint:Say( 350, 750, "Cliente: "       	 +ALLTRIM(SC5->C5_CLIENTE+"/"+SC5->C5_LOJACLI+"-"+SA1->A1_NOME), oArial12N )
oPrint:Say( 400, 750, "Descrição: "         +ALLTRIM(CABEC->B1_DESC), oArial12N )
oPrint:Say( 450, 750, "Unid. Medida: "      +ALLTRIM(CABEC->C2_UM), oArial12N )
	
oPrint:Say( 300, 2060, "Dt. Entrega: " +ALLTRIM(DTOC(STOD(CABEC->C2_DATPRF))), oArial12N )
oPrint:Say( 350, 2060, "Semana: "  +PADL(retsem(STOD(CABEC->C2_DATPRF)),2,"0")    , oArial12N )

oPrint:Line( 533, 50, 533, 2339)   	// LINHA HORIZONTAL

oPrint:Say( 562, 1050, "Materiais para Separação", oArial12N )

oPrint:Box( 592, 0050, 2568, 2339 )  // BOX ITENS

oPrint:Say( 622, 60, "Produto"      , oArial12N )

oPrint:Line( 592, 240, 2568, 240)   	// LINHA VERTICAL
oPrint:Say( 622, 250, "Descrição"   , oArial12N )

oPrint:Line( 592, 950, 2568, 950 ) 	// LINHA VERTICAL
oPrint:Say( 622, 960, "Tipo"         , oArial12N )

oPrint:Line( 592, 1050, 2568, 1050)   	// LINHA VERTICAL
oPrint:Say( 622, 1060, "Qtde"       , oArial12N )

oPrint:Line( 592, 1150, 2568, 1150)   	// LINHA VERTICAL
oPrint:Say( 622, 1160, "UM"         , oArial12N )

oPrint:Line( 592, 1220, 2568, 1220)   	// LINHA VERTICAL 1400
oPrint:Say( 622, 1230, "Armz."      , oArial12N )

//oPrint:Line( 592, 1320, 2568, 1320)   	// LINHA VERTICAL 1410
//oPrint:Say( 622, 1330, "Desc."      , oArial12N )

oPrint:Line( 592, 1320, 2568, 1320)   	// LINHA VERTICAL 1540
oPrint:Say( 622, 1330, "Lote"       , oArial12N )

oPrint:Line( 592, 1519, 2568, 1519)   	// LINHA VERTICAL 1729
oPrint:Say( 622, 1529, "Num. Serie" , oArial12N )

oPrint:Line( 592, 1729, 2568, 1729)   	// LINHA VERTICAL 1939
oPrint:Say( 622, 1739, "Check 1"      , oArial12N )

oPrint:Line( 592, 1939, 2568, 1939)   	// LINHA VERTICAL 2139
oPrint:Say( 622, 1949, "Check 2"      , oArial12N )

oPrint:Line( 592, 2139, 2568, 2139)   	// LINHA VERTICAL 2139
oPrint:Say( 622, 2149, "Dt. Separação" , oArial12N )

oPrint:Line( 652, 050, 652, 2339)   	// LINHA HORIZONTAL

RestArea(a_AreaSC2)
RestArea(a_AreaSC5)
RestArea(a_AreaSA1)

Return Nil 

/***************************************************************************************************/
Static Function fRodape()

oPrint:Say( 2608, 060, "Observação:" , oArial12N )
oPrint:Box( 2628, 050, 2828, 2339 )  // BOX RODAPE

oPrint:Say( 2888, 060, "Separado Por: "  , oArial12N )
oPrint:Line( 2888, 370, 2888, 2090)   	// LINHA HORIZONTAL
oPrint:Say( 2958, 060, "Conferido Por: " , oArial12N )
oPrint:Line( 2958, 370, 2958, 2090)   	// LINHA HORIZONTAL

oPrint:Say( 2888, 2100, "Data: ___/___/___" , oArial12N )
oPrint:Say( 2958, 2100, "Data: ___/___/___" , oArial12N )

Return Nil 


/***************************************************************************************************/
Static Function fDadosEmp()

Local a_Itens   := {}
Local a_Aux     := {}
Local c_Query   := "" 
Local c_EOL     := CHR(13)+CHR(10)

c_Query   := "SELECT	D4_COD, B1_DESC, D4_QUANT, B1_UM ,B1_TIPO,D4_LOCAL, D4_LOTECTL, ISNULL(DC_NUMSERI,'') AS DC_NUMSERI, NNR_DESCRI"+c_EOL
c_Query   += "FROM	"+RetSqlName("SD4")+"(NOLOCK) D4"+c_EOL
c_Query   += "	INNER JOIN "+RetSqlName("SB1")+"(NOLOCK) B1"+c_EOL
c_Query   += "	ON B1_FILIAL = '"+xFilial("SB1")+"'"+c_EOL
c_Query   += "	AND	D4_COD = B1_COD"+c_EOL
c_Query   += "	AND B1.D_E_L_E_T_ = ''"+c_EOL
c_Query   += "	LEFT JOIN "+RetSqlName("NNR")+"(NOLOCK) NR"+c_EOL
c_Query   += "	ON  D4_FILIAL = NNR_FILIAL
c_Query   += "	AND	D4_LOCAL = NNR_CODIGO
c_Query   += "	AND	NR.D_E_L_E_T_ = ''   
c_Query   += "	LEFT JOIN "+RetSqlName("SDC")+"(NOLOCK) DC"+c_EOL
c_Query   += "	ON	D4_FILIAL = DC_FILIAL"+c_EOL
c_Query   += "	AND	D4_COD = DC_PRODUTO"+c_EOL
c_Query   += "	AND	DC_LOCAL = D4_LOCAL"+c_EOL
c_Query   += "	AND	DC_OP = D4_OP"+c_EOL
c_Query   += "	AND	D4_TRT = DC_TRT"+c_EOL
c_Query   += "	AND D4_LOTECTL = DC_LOTECTL"+c_EOL
c_Query   += "	AND	D4_NUMLOTE = DC_NUMLOTE"+c_EOL
c_Query   += "	AND	DC.D_E_L_E_T_ = ''"+c_EOL
c_Query   += "WHERE	D4_OP = '"+CABEC->OP+"'" +c_EOL
c_Query   += "AND   B1_XPRESEP = '1'"+c_EOL
c_Query   += "AND		D4.D_E_L_E_T_ = ''"+c_EOL
c_Query   += "ORDER BY D4_COD"+c_EOL

If Select("PRESEP") > 0
	PRESEP->(DBCLOSEAREA())
EndIf

MemoWrite("pre_separacao.sql", c_Query)

TcQuery c_Query New Alias "PRESEP"

PRESEP->(DbGotop())
While PRESEP->(!EOF())

        a_Aux := {}
                            
        aAdd( a_Aux, { 60   , PRESEP->D4_COD                                                    })
        aAdd( a_Aux, { 250  , PRESEP->B1_DESC                                                   })
        aAdd( a_Aux, { 0960 , PRESEP->B1_TIPO                                                   })
        aAdd( a_Aux, { 1060 , Alltrim(Transform(PRESEP->D4_QUANT,PesqPict("SC2","C2_QUANT")))   })
        aAdd( a_Aux, { 1160 , PRESEP->B1_UM                                                     })
        aAdd( a_Aux, { 1230 , PRESEP->D4_LOCAL                                                  })
       // aAdd( a_Aux, { 1330 , PRESEP->NNR_DESCRI                                                })
        aAdd( a_Aux, { 1330 , PRESEP->D4_LOTECTL                                                })
        aAdd( a_Aux, { 1529 , PRESEP->DC_NUMSERI                                                })
        aAdd( a_Aux, { 1739 , "(    )"                                                          })
        aAdd( a_Aux, { 1949 , "(    )"                                                          })
        aAdd( a_Aux, { 2149 , "        /        /"                                              })
                              
        aAdd( a_Itens, a_Aux )
        
    PRESEP->(DbSkip()) 

EndDo

Return a_Itens


/************************************************************************************************************************* */
Static Function ValidPerg(c_Perg)

aRegs := {}

//         Grupo /Ordem /Pergunta                /PERSPA   / PERENG/Variavel/Tipo   /Tamanho  /Decimal/Presel /GSC /Valid/Var01      /Def01    		  	/DEFSPA1 /DEFENG1 /Cnt01 /Var02     /Def02           /DEFSPA2 /DEFENG2 /Cnt02 /Var03     /Def03          /DEFSPA3 /DEFENG3 /Cnt03 /Var04     /Def04          	/DEFSPA4 /DEFENG4 /Cnt04 /Var05     /Def05          /DEFSPA5/DEFENG5  /Cnt05 /F3   /PYME/GRPSXG
aAdd(aRegs,{c_Perg,"01"  ,"OP de?"			,""      	,""     ,"MV_CH1","C"    ,14      ,0       ,0     ,"G" ,""    ,"MV_PAR01",""					,""      ,""      ,""   ,""         ,""  			,""      ,""      ,""    ,""        ,""        		 ,""      ,""     ,""     ,""       ,""             	,""      ,""      ,""    ,""        ,""            ,""      ,""      ,""    ,"SC2"    })
aAdd(aRegs,{c_Perg,"02"  ,"OP até?"			,""      	,""     ,"MV_CH2","C"    ,14      ,0       ,0     ,"G" ,""    ,"MV_PAR02",""					,""      ,""      ,""   ,""         ,""			  	,""      ,""      ,""    ,""        ,""			     ,""      ,""     ,""     ,""       ,""             	,""      ,""      ,""    ,""        ,""            ,""      ,""      ,""    ,"SC2"    })
aAdd(aRegs,{c_Perg,"03"  ,"Data de?"		,""      	,""     ,"MV_CH3","D"    ,08      ,0       ,0     ,"G" ,""    ,"MV_PAR03",""					,""      ,""      ,""   ,""         ,""			  	,""      ,""      ,""    ,""        ,""			     ,""      ,""     ,""     ,""       ,""             	,""      ,""      ,""    ,""        ,""            ,""      ,""      ,""    ,""       })
aAdd(aRegs,{c_Perg,"04"  ,"Data até?"		,""      	,""     ,"MV_CH4","D"    ,08      ,0       ,0     ,"G" ,""    ,"MV_PAR04",""					,""      ,""      ,""   ,""         ,""			  	,""      ,""      ,""    ,""        ,""			     ,""      ,""     ,""     ,""       ,""             	,""      ,""      ,""    ,""        ,""            ,""      ,""      ,""    ,""       })

U_PutX1PERF(c_Perg, aRegs)

Return Nil