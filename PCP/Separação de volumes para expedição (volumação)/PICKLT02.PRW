#INCLUDE "FIVEWIN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE 'TOPCONN.CH'
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#Define DMPAPER_A4 9 // A4 210 x 297 mm
/*-------------------------------------------------------------------------------------
{Protheus.doc} PICKLT02

@Author  	   Felipe Aguiar - Focus Consultoria
@since		   06/2019
@version	   P12

@description Picklist de Embarque de Volumes Detalhado
---------------------------------------------------------------------------------------
|Author                  | Date       | Description                                    |
|                        |            |                                                |
--------------------------------------------------------------------------------------*/
User Function PICKLT02()

Local lAdjustToLegacy 	:= .T.
Local lDisableSetup 	:= .T. 
Local cLocal            := GetTempPath() 

Private lViewPDF        := .T.
Private c_Perg          := "XPICK01"

ValidPerg(c_Perg)

If !Pergunte(c_Perg, .T.)
    Return .F.
EndIf

oPrint := FWMSPrinter():New("pick_vol_"+Alltrim(MV_PAR01)+"_detalhado.rel", IMP_PDF, lAdjustToLegacy,cLocal, lDisableSetup, , , , , , .F., lViewPDF )
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

Local c_Cabec   := ""
Local c_EOL     := CHR(13)+CHR(10)
Local n_Aux     := 1

oArial18N	:= TFont():New("Arial",18,18,,.T.,,,,.T.,.F.)
oArial14N	:= TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)
oArial14	:= TFont():New("Arial",14,14,,.F.,,,,.F.,.F.)
oArial14N	:= TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)
oArial12	:= TFont():New("Arial",12,12,,.F.,,,,.F.,.F.)
oArial10	:= TFont():New("Arial",10,10,,.F.,,,,.F.,.F.)
oArial10N	:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
oArial8	    := TFont():New("Arial",08,08,,.F.,,,,.F.,.F.)
oArial9	    := TFont():New("Arial",09,09,,.F.,,,,.F.,.F.)

c_Cabec   := " SELECT	C5_NUM, C6_ITEM, A1_COD, A1_LOJA,A1_NOME"+c_EOL
c_Cabec   += "FROM	"+RetSqlName("SC5")+"(NOLOCK) C5"+c_EOL
c_Cabec   += ""+c_EOL
c_Cabec   += "INNER JOIN "+RetSqlName("SC6")+"(NOLOCK) C6"+c_EOL
c_Cabec   += "	"+c_EOL
c_Cabec   += "	ON	C5_FILIAL = C6_FILIAL"+c_EOL
c_Cabec   += "	AND	C5_NUM = C6_NUM"+c_EOL
c_Cabec   += "	AND C6.D_E_L_E_T_ = ''"+c_EOL
c_Cabec   += ""+c_EOL
c_Cabec   += "INNER JOIN "+RetSqlName("SA1")+"(NOLOCK) A1"+c_EOL
c_Cabec   += ""+c_EOL
c_Cabec   += "	ON C5_CLIENTE = A1_COD"+c_EOL
c_Cabec   += "	AND C5_LOJACLI = A1_LOJA"+c_EOL
c_Cabec   += "	AND A1.D_E_L_E_T_ = ''"+c_EOL
c_Cabec   += ""+c_EOL
c_Cabec   += "WHERE	C5_NUM BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"+c_EOL
c_Cabec   += "AND		C6_ITEM BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'"+c_EOL
c_Cabec   += "AND		C5.D_E_L_E_T_ = ''"+c_EOL

If Select("CABEC") > 0
	CABEC->(DBCLOSEAREA())
EndIf

TcQuery c_Cabec New Alias "CABEC"

CABEC->(DbGotop())
While CABEC->(!EOF())
        
    a_Lista := fDadosVol()
    
    If Len(a_Lista) > 0 

        oPrint:StartPage() // Inicia uma nova pagina
        fCabec()//Imprimi Cabecalho

        n_Linha := 672 //Linha inicio dos itens
        n_Aux := 1
        
        //Percorre os itens 
        For n_Item := 1 To Len(a_Lista)
                          
            If n_Aux > 19 // Numero de itens que cabem no box, caso seja maior, crio uma nova pagina
                    
                    oPrint:EndPage() 	
                    oPrint:StartPage() // Inicia uma nova pagina
                    fBox()// Crio o BOX para a folha inteira  
                    n_Aux := 1
                    n_Linha := 294 //Qndo trocar a pagina, volto para a primeira linha do box
                
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

                
                //If n_Dad == 2
                    //  n_LinBar := ( n_Linha/42 ) - 1
                    //oPrint:FWMSBAR("CODE128" /*cTypeBar*/,n_LinBar/*nRow*/ ,26/*nCol*/ ,c_Inf  /*cCode*/,oPrint/*oPrint*/,/*lCheck*/,/*Color*/,/*lHorz*/, /*nWidth*/,0.7/*nHeigth*/,/*lBanner*/,/*cFont*/,/*cMode*/,.F./*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/,/*lCmtr2Pix*/)  
                //Else
                    oPrint:Say( n_Linha , n_Col , c_Inf , oArial14 )
                //EndIf 

                a_Detalhes := fDetVol( CABEC->C5_NUM , CABEC->C6_ITEM , a_Lista[n_Item][n_Dad][2] )    
                
                For n_Det := 1 To Len(a_Detalhes)

                    If n_Aux > 19 // Numero de itens que cabem no box, caso seja maior, crio uma nova pagina
                    
                        oPrint:EndPage() 	
                        oPrint:StartPage() // Inicia uma nova pagina
                        fBox()// Crio o BOX para a folha inteira  
                        n_Aux := 1
                        n_Linha := 294 //Qndo trocar a pagina, volto para a primeira linha do box
                    
                    EndIf 

                    For n_ItemDet := 1 To Len(a_Detalhes[n_Det])
                    
                        n_Col2   := a_Detalhes[n_Det][n_ItemDet][1]
                        c_Inf2   := ""

                        If ValType(a_Detalhes[n_Det][n_ItemDet][2]) == "C"
                            c_Inf2   := a_Detalhes[n_Det][n_ItemDet][2]
                        ElseIf ValType(a_Detalhes[n_Det][n_ItemDet][2]) == "N"
                            c_Inf2   := STR(a_Detalhes[n_Det][n_ItemDet][2])
                        ElseIf ValType(a_Detalhes[n_Det][n_ItemDet][2]) == "D"
                            c_Inf2   := DTOC(a_Detalhes[n_Det][n_ItemDet][2])   
                        EndIf

                        oPrint:Say( n_Linha , n_Col2 , c_Inf2 , oArial14 )

                    Next n_ItemDet

                    n_Linha := n_Linha + 120
                    n_Aux++
                    
                Next  n_Det   

            Next n_Dad
            
            //oPrint:Say( n_Linha , 60 , STR(n_Item) , oArial14 )            
            //n_Linha := n_Linha + 120
            n_Aux++

            oPrint:Line( n_Linha-60 , 50, n_Linha-60, 2339)   	// LINHA HORIZONTAL
                       
        Next n_Item
                
        oPrint:EndPage() // Finaliza a pagina

    EndIf    

    CABEC->(DbSkip())

EndDo

/*************************************************************************************************************************/
Static Function ValidPerg(c_Perg)

aRegs := {}

//         Grupo /Ordem /Pergunta                /PERSPA   / PERENG/Variavel/Tipo   /Tamanho  /Decimal/Presel /GSC /Valid/Var01      /Def01    		  	/DEFSPA1 /DEFENG1 /Cnt01 /Var02     /Def02           /DEFSPA2 /DEFENG2 /Cnt02 /Var03     /Def03          /DEFSPA3 /DEFENG3 /Cnt03 /Var04     /Def04          	/DEFSPA4 /DEFENG4 /Cnt04 /Var05     /Def05          /DEFSPA5/DEFENG5  /Cnt05 /F3   /PYME/GRPSXG
aAdd(aRegs,{c_Perg,"01"  ,"Pedido de?"	    ,""      	,""     ,"MV_CH1","C"    ,06      ,0       ,0     ,"G" ,""    ,"MV_PAR01",""					,""      ,""      ,""   ,""         ,""  			,""      ,""      ,""    ,""        ,""        		 ,""      ,""     ,""     ,""       ,""             	,""      ,""      ,""    ,""        ,""            ,""      ,""      ,""    ,"SC5"    })
aAdd(aRegs,{c_Perg,"02"  ,"Pedido até?"		,""      	,""     ,"MV_CH2","C"    ,06      ,0       ,0     ,"G" ,""    ,"MV_PAR02",""					,""      ,""      ,""   ,""         ,""			  	,""      ,""      ,""    ,""        ,""			     ,""      ,""     ,""     ,""       ,""             	,""      ,""      ,""    ,""        ,""            ,""      ,""      ,""    ,"SC5"    })
aAdd(aRegs,{c_Perg,"03"  ,"Item de?"		,""      	,""     ,"MV_CH3","C"    ,02      ,0       ,0     ,"G" ,""    ,"MV_PAR03",""					,""      ,""      ,""   ,""         ,""			  	,""      ,""      ,""    ,""        ,""			     ,""      ,""     ,""     ,""       ,""             	,""      ,""      ,""    ,""        ,""            ,""      ,""      ,""    ,""       })
aAdd(aRegs,{c_Perg,"04"  ,"Item até?"		,""      	,""     ,"MV_CH4","C"    ,02      ,0       ,0     ,"G" ,""    ,"MV_PAR04",""					,""      ,""      ,""   ,""         ,""			  	,""      ,""      ,""    ,""        ,""			     ,""      ,""     ,""     ,""       ,""             	,""      ,""      ,""    ,""        ,""            ,""      ,""      ,""    ,""       })

U_PutX1PERF(c_Perg, aRegs)

Return Nil

/***************************************************************************************************/
Static Function fCabec()

Local cLogo     := "\system\lgrl01.bmp"	

//Logotipo
oPrint:SayBitmap(060,050,cLogo,302,165)

oPrint:Say( 132, 790 , "RELATÓRIO DE DETALHAMENTO DOS VOLUMES" ,oArial18N )

oPrint:Line( 243, 50, 243, 2339)   	// LINHA HORIZONTAL

oPrint:Say( 300, 0060, "Pedido/Item: " +ALLTRIM(CABEC->(C5_NUM+"/"+C6_ITEM)) , oArial14N )
oPrint:Say( 300, 1909, "Dt.Impressão: " +ALLTRIM(DTOC(DATE())), oArial14N )
oPrint:Say( 350, 0060, "Cliente/Loja: " +ALLTRIM(CABEC->(A1_COD+"/"+A1_LOJA+" - " + A1_NOME)) , oArial14N  ) 

oPrint:Line( 400, 50, 400, 2339)   	// LINHA HORIZONTAL

oPrint:Say( 460, 1050, "Detalhamento dos Volumes", oArial14N )

oPrint:Line( 500, 50, 500, 2339)   	// LINHA HORIZONTAL
oPrint:Box( 510, 0050, 2958, 2339 )  // BOX ITENS
oPrint:Say( 562, 0200, "Nº Volume"      , oArial14N )
oPrint:Line( 510, 650, 2958, 650 ) 	// LINHA VERTICAL
oPrint:Say( 562, 1155, "Produtos"        , oArial14N )
oPrint:Line( 510, 2000, 2958, 2000 ) 	// LINHA VERTICAL
oPrint:Say( 562, 2070, "Quantidades"     , oArial14N )
oPrint:Line( 612, 50, 612, 2339)   	// LINHA HORIZONTAL

Return Nil

/***************************************************************************************************/
Static Function fDadosVol()

Local a_Itens   := {}
Local a_Aux     := {}
Local c_Query   := "" 
Local c_EOL     := CHR(13)+CHR(10)

c_Query   := "SELECT	* " +c_EOL
c_Query   += "FROM	"+RetSqlName("SZ7")+"(NOLOCK)"+c_EOL
c_Query   += "WHERE	Z7_PEDIDO = '"+CABEC->C5_NUM+"'" +c_EOL
c_Query   += "AND		Z7_ITEM = '"+CABEC->C6_ITEM+"'"+c_EOL
c_Query   += "AND		D_E_L_E_T_ = ''" +c_EOL

If Select("XVOL") > 0
	XVOL->(DBCLOSEAREA())
EndIf

MemoWrite("pick_vol.sql", c_Query)

TcQuery c_Query New Alias "XVOL"

XVOL->(DbGotop())
While XVOL->(!EOF())

        a_Aux := {}
                            
        aAdd( a_Aux, { 0200 , XVOL->Z7_NUMVOL  })
        //aAdd( a_Aux, { 1525 , XVOL->Z7_NUMVOL+XVOL->Z7_PEDIDO+XVOL->Z7_ITEM    })
        //aAdd( a_Aux, { 2100 , IIF( XVOL->Z7_EXPEDID == "1", "SIM", "NÃO" )     })
 
        aAdd( a_Itens, a_Aux )
        
    XVOL->(DbSkip()) 

EndDo

Return a_Itens
/*******************************************************************************************************/
Static Function fBox()

oPrint:Box( 132, 0050, 2958, 2339 )  // BOX ITENS
oPrint:Line( 132, 650, 2958, 650 ) 	// LINHA VERTICAL
oPrint:Line( 132, 2000, 2958, 2000 ) 	// LINHA VERTICAL

Return Nil

/**************************************************************************/
Static Function fDetVol(c_Pedido, c_Item, c_NumVol )

Local a_Ret     := {}
Local c_Det     := ""
Local a_AuxDet  := {} 
Local a_AreaSB1 := SB1->(GetArea())

c_Det := " SELECT	* "
c_Det += " FROM	"+RetSqlName("SZ8")+"(NOLOCK) "
c_Det += " WHERE	Z8_NUMVOL = '"+c_NumVol+"' " 
c_Det += " AND		Z8_PEDIDO = '"+c_Pedido+"' "
c_Det += " AND		Z8_ITEM = '"+c_Item+"' "
c_Det += " AND		D_E_L_E_T_ = '' "

If Select("XDETVOL") > 0
	XDETVOL->(DBCLOSEAREA())
EndIf

MemoWrite("pick_det.sql", c_Det)

TcQuery c_Det New Alias "XDETVOL"

XDETVOL->(DbGotop())
While XDETVOL->(!EOF())

        a_AuxDet := {}

        DbSelectArea("SB1")
        DbSetOrder(1)
        DbSeek(xFilial("SB1")+XDETVOL->Z8_PRODUTO)

        aAdd( a_AuxDet, { 0660 , ALLTRIM(SB1->B1_COD)+" - "+ ALLTRIM(SB1->B1_DESC)            })
        aAdd( a_AuxDet, { 2100 , ALLTRIM(Transform(XDETVOL->Z8_QTDVOL, "@E 999,999.99"))      })

        aAdd( a_Ret, a_AuxDet )
    
    XDETVOL->(DbSkip()) 

EndDo    

RestArea(a_AreaSB1)    

Return a_Ret