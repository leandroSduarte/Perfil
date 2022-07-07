#INCLUDE "Protheus.ch"
#INCLUDE "RWMAKE.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "TbiConn.ch" 
#INCLUDE "Font.ch"
#INCLUDE "FwBrowse.ch"


/*-------------------------------------------------------------------------------------
{Protheus.doc} TLCONSOP

@Author  	   Felipe Aguiar - Focus Consultoria
@since		   03/2019
@version	   P12

@description Lista Apontamentos de OP
---------------------------------------------------------------------------------------
|Author                  | Date       | Description                                    |
|                        |            |                                                |
--------------------------------------------------------------------------------------*/
User Function TLCONSOP()

Local a_AreaATU	:= GetArea() 
Local a_Buttons	:= {}

Private	cSay1		:= "Quantidade Total:"
Private	cSay2		:= "0"
Private	cSay3		:= "Tempo Total (Hr/Min):"
Private cSay4		:= "00:00"
Private oSize	    := Nil
Private aListBox1  	:= {}
Private oListBox
Private cTGet1      := ""
Private cTGet2      := ""
Private cTGet3      := ""
Private cTGet4      := ""
Private cTGet5      := ""
Private cTGet6      := ""
Private cTGet7      := ""
Private cTGet8      := ""
Private cTGet9      := ""
Private cTGet10     := ""
Private c_Perg		:= "XCONSZ3"
Private oListBox1

oFont := TFont():New("Calibri",,030,,.T.,,,,,.F.,.F.)

aAdd(a_Buttons,{"RELATORIO",{|| 	RefTela() 					 }	,"Atualizar Tela"		})
aAdd(a_Buttons,{"RELATORIO",{|| 	NovaPesq() 					 }	,"Novo Filtro"			})
aAdd(a_Buttons,{"RELATORIO",{|| 	U_RELAPT(aListBox1) 		 }	,"Exportar"				})
aAdd(a_Buttons,{"RELATORIO",{|| 	TPesq(aListBox1,oListBox1)	 }	,"Pesquisar"			})

ValidPerg(c_Perg)

If !Pergunte(c_Perg, .T.)
	Return .F.
Else 

	cTGet1	:= MV_PAR01
	cTGet2	:= MV_PAR02
	cTGet3  := MV_PAR03
	cTGet4  := MV_PAR04
	cTGet5 	:= MV_PAR05
	cTGet6 	:= MV_PAR06
	cTGet7 	:= MV_PAR07
	cTGet8 	:= MV_PAR08
	cTGet9 	:= MV_PAR09
	cTGet10 := MV_PAR10

EndIf

cCadastro := "Consulta de Apontamentos Ordem de Produção"

//Calcula as dimensoes dos objetos        
oSize := FwDefSize():New(.T.)             

oSize:AddObject( "CABECALHO", 100, 10 , .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "RODAPE"   , 100, 90 , .T., .T. ) // Totalmente dimensionavel 

oSize:lProp 	:= .T. // Proporcional             
oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos 

oDlg := MSDialog():New(oSize:aWindSize[1],oSize:aWindSize[2],oSize:aWindSize[3],oSize:aWindSize[4],"",,,,,CLR_BLACK,CLR_WHITE,,,.T.)


oGrp1   := TGroup():New(oSize:GetDimension("CABECALHO","LININI"),;
						oSize:GetDimension("CABECALHO","COLINI"),;
						oSize:GetDimension("CABECALHO","LINEND"),;
						oSize:GetDimension("CABECALHO","COLEND"),"",oDlg,,,.T.,)


//Label Quantidade
oSay1:= TSay():New( oSize:GetDimension("CABECALHO","LININI")+10,oSize:GetDimension("CABECALHO","COLINI")+5,{||cSay1},oGrp1,,oFont,,,,.T.,CLR_BLUE,CLR_WHITE,100,30)
oSay1:Align := CONTROL_ALIGN_NONE

//Quantidade
oSay2:= TSay():New( oSize:GetDimension("CABECALHO","LININI")+10,oSize:GetDimension("CABECALHO","COLINI")+100,{||cSay2},oGrp1,,oFont,,,,.T.,CLR_RED,CLR_WHITE,100,30)
oSay2:Align := CONTROL_ALIGN_NONE

//LAbel Tempo Total 
oSay3:= TSay():New( oSize:GetDimension("CABECALHO","LININI")+10,oSize:GetDimension("CABECALHO","XSIZE")/2 ,{||cSay3},oGrp1,,oFont,,,,.T.,CLR_BLUE,CLR_WHITE,150,30)
oSay3:Align := CONTROL_ALIGN_NONE

//Tempo Total
oSay4:= TSay():New( oSize:GetDimension("CABECALHO","LININI")+10,(oSize:GetDimension("CABECALHO","XSIZE")/2)+150,{||cSay4},oGrp1,,oFont,,,,.T.,CLR_RED,CLR_WHITE,100,30)
oSay4:Align := CONTROL_ALIGN_NONE


oGrp2   := TGroup():New(oSize:GetDimension("RODAPE","LININI"),;
						oSize:GetDimension("RODAPE","COLINI"),;
						oSize:GetDimension("RODAPE","LINEND"),;
						oSize:GetDimension("RODAPE","COLEND"),"",oDlg,,,.T.,)
              

@ oSize:GetDimension("RODAPE","LININI")+10,oSize:GetDimension("RODAPE","COLINI")+5 LISTBOX oListBox1 FIELDS HEADER ;
"Ordem de Produção", "Produto","Descrição", "Operação", "Descrição", "Recurso", "Dt. Inicial", "Hora Inicial","Dt. Final","Hora Final","Tempo Real","Qtd. Produzida","Operador","Nome";
COLSIZES 100, 100, 100, 30, 100, 50, 50, 50, 50, 50,50,50,50 SIZE oSize:GetDimension("RODAPE","XSIZE")-10 , oSize:GetDimension("RODAPE","YSIZE")-10 OF oDlg Pixel; 

Processa({|| U_fFiltro()},"Aguarde","Selecionando registros...")           

oDlg:bInit := {||  EnchoiceBar( oDlg , , {|| oDlg:End() },,a_Buttons,,,.F.,.F.,.F.,.F.,.F.)}		

oDlg:Activate()

RestArea(a_AreaATU)

Return Nil 

/***********************************************************************************************************/

User Function fFiltro()

Local c_Query := ""
Local c_Qry	  := CHR(13)+CHR(10)
Local n_Hr 	  := 0
Local n_Min	  := 0
Local nQtd	  := 0

aListBox1 := {}

c_Query := " SELECT	H6_OP," +c_Qry 	   
c_Query += "		H6_PRODUTO," +c_Qry
c_Query += "		B1_DESC," +c_Qry
c_Query += "		H6_OPERAC," +c_Qry
c_Query += "		G2_DESCRI," +c_Qry 
c_Query += "		H6_RECURSO," +c_Qry 
c_Query += "		H6_DATAINI," +c_Qry 
c_Query += "		H6_HORAINI," +c_Qry
c_Query += "		H6_DATAFIN," +c_Qry 
c_Query += "		H6_HORAFIN," +c_Qry 
c_Query += "		H6_TEMPO," +c_Qry	
c_Query += "		H6_QTDPROD," +c_Qry
c_Query += "		H6_OPERADO," +c_Qry
c_Query += "		Z2_NOME	 " +c_Qry
c_Query += " FROM	"+RetSqlName("SH6")+"(NOLOCK) H6 "+c_Qry
c_Query += " INNER JOIN "+RetSqlName("SG2")+"(NOLOCK) G2 "+c_Qry
c_Query += " 	ON G2_FILIAL = H6_FILIAL "+c_Qry
c_Query += " 	AND	G2_CODIGO = '01' "+c_Qry
c_Query += " 	AND	G2_PRODUTO = H6_PRODUTO "+c_Qry
c_Query += " 	AND	G2_OPERAC = H6_OPERAC"+c_Qry
c_Query += " 	AND	G2.D_E_L_E_T_ = '' "+c_Qry
c_Query += " INNER JOIN "+RetSqlName("SZ2")+"(NOLOCK) Z2 "+c_Qry
c_Query += " 	ON Z2_CODIGO = H6_OPERADO "+c_Qry
c_Query += " 	AND	Z2.D_E_L_E_T_ = '' "+c_Qry
c_Query += " INNER JOIN "+RetSqlName("SB1")+"(NOLOCK) B1 "+c_Qry
c_Query += " 	ON B1_COD = H6_PRODUTO"+c_Qry
c_Query += " 	AND B1.D_E_L_E_T_ = ''"+c_Qry
c_Query += " WHERE	H6_DTAPONT BETWEEN '"+ DTOS(cTGet1) +"' AND '"+ DTOS(cTGet2) +"'"+c_Qry
c_Query += " AND 		H6_OP BETWEEN '"+ cTGet3 +"' AND '"+ cTGet4 +"'"+c_Qry
c_Query += " AND		H6_OPERADO BETWEEN '"+ cTGet5 +"' AND '"+ cTGet6 +"'"+c_Qry
c_Query += " AND		H6_OPERAC BETWEEN '"+ cTGet7 +"' AND '"+ cTGet8 +"'"+c_Qry
c_Query += " AND		H6_RECURSO BETWEEN '"+ cTGet9 +"' AND '"+ cTGet10 +"'"+c_Qry
c_Query += " AND		H6.D_E_L_E_T_ = ''"+c_Qry
c_Query += ""+c_Qry
c_Query += "UNION ALL"+c_Qry
c_Query += ""+c_Qry
c_Query += "SELECT	Z3_OP AS 'H6_OP',"+c_Qry
c_Query += "		Z3_PRODUTO AS 'H6_PORDUTO',"+c_Qry
c_Query += "		B1_DESC,"+c_Qry
c_Query += "		Z3_OPERAC AS 'H6_OPERAC',"+c_Qry
c_Query += "		G2_DESCRI,"+c_Qry
c_Query += "		Z3_RECURSO AS 'H6_RECURSO',"+c_Qry
c_Query += "		Z3_DATAINI AS 'H6_DATAINI',"+c_Qry
c_Query += "		Z3_HORAINI AS 'H6_HORAINI',"+c_Qry
c_Query += "		Z3_DATAFIN AS 'H6_DATAFIN',"+c_Qry
c_Query += "		Z3_HORAFIN AS 'H6_HORAFIN',"+c_Qry
c_Query += "		'' AS 'H6_TEMPO',"+c_Qry
c_Query += "		Z3_QTDPROD AS 'H6_QTDPROD',"+c_Qry
c_Query += "		Z3_OPERADO AS 'H6_OPERADO',"+c_Qry
c_Query += "		Z2_NOME"+c_Qry
c_Query += ""+c_Qry
c_Query += "FROM	"+RetSqlName("SZ3")+"(NOLOCK) Z3"+c_Qry
c_Query += "INNER JOIN "+RetSqlName("SG2")+"(NOLOCK) G2 "+c_Qry
c_Query += "	ON G2_FILIAL = Z3_FILIAL"+c_Qry 
c_Query += "	AND	G2_CODIGO = '01'"+c_Qry 
c_Query += "	AND	G2_PRODUTO = Z3_PRODUTO"+c_Qry 
c_Query += "	AND	G2_OPERAC = Z3_OPERAC"+c_Qry 
c_Query += "	AND	G2.D_E_L_E_T_ = ''"+c_Qry 
c_Query += ""+c_Qry
c_Query += "INNER JOIN "+RetSqlName("SZ2")+"(NOLOCK) Z2 "+c_Qry
c_Query += "	ON Z2_CODIGO = Z3_OPERADO "+c_Qry
c_Query += "	AND	Z2.D_E_L_E_T_ = '' "+c_Qry
c_Query += " INNER JOIN "+RetSqlName("SB1")+"(NOLOCK) B1 "+c_Qry
c_Query += "	ON B1_COD = Z3_PRODUTO"+c_Qry
c_Query += "	AND B1.D_E_L_E_T_ = ''"+c_Qry
c_Query += " WHERE	Z3_DATAINI BETWEEN '"+ DTOS(cTGet1) +"' AND '"+ DTOS(cTGet2) +"'"+c_Qry
c_Query += " AND 		Z3_OP BETWEEN '"+ cTGet3 +"' AND '"+ cTGet4 +"'"+c_Qry
c_Query += " AND		Z3_OPERADO BETWEEN '"+ cTGet5 +"' AND '"+ cTGet6 +"'"+c_Qry
c_Query += " AND		Z3_OPERAC BETWEEN '"+ cTGet7 +"' AND '"+ cTGet8 +"'"+c_Qry
c_Query += " AND		Z3_RECURSO BETWEEN '"+ cTGet9 +"' AND '"+ cTGet10 +"'"+c_Qry
c_Query += " AND		Z3_CTRSH6 = ''"+c_Qry// Filtro o que só foi aberto, pois o que ja foi fechada, trago pelo SH6
c_Query += " AND		Z3.D_E_L_E_T_ = ''"+c_Qry

If Select("CONSOP") > 0
    CONSOP->(DbCloseArea())
Endif

TCQUERY c_Query NEW ALIAS "CONSOP"

MemoWrite("Apontamentos.sql",c_Query)

DbSelectArea("CONSOP")
CONSOP->(DbGoTop())

While CONSOP->(!Eof()) 

    aAdd(aListBox1,{ 	CONSOP->H6_OP 	        ,;
					  	CONSOP->H6_PRODUTO	 	,;
						CONSOP->B1_DESC			,;
					  	CONSOP->H6_OPERAC	    ,;
						CONSOP->G2_DESCRI       ,;  
                        CONSOP->H6_RECURSO 	 	,;					  	  
                        CONSOP->H6_DATAINI 	    ,;
					  	CONSOP->H6_HORAINI	 	,;
					  	CONSOP->H6_DATAFIN 		,;
					  	CONSOP->H6_HORAFIN 	 	,;
					  	CONSOP->H6_TEMPO	 	,;
						CONSOP->H6_QTDPROD		,;
					  	CONSOP->H6_OPERADO		,;
						CONSOP->Z2_NOME		    })
	//001:11
	c_Time 	:= ALLTRIM(CONSOP->H6_TEMPO)
	n_Hr 	+= VAL(SUBSTR(c_Time , 1 , At(":", c_Time)-1))
	n_Min	+= VAL(SUBSTR(c_Time , At(":", c_Time) + 1 , Len(c_Time) )) 
	
	nQtd += CONSOP->H6_QTDPROD
	
    CONSOP->(DbSkip())
                    
EndDo

c_MinTot 	:= ALLTRIM(cValtoChar(Min2Hrs( n_Min)))
c_HrTot 	:= Val(SUBSTR( c_MinTot ,1, At(".", c_MinTot)-1 ))
c_MinTot2 	:= Val(SUBSTR( c_MinTot ,At(".", c_MinTot)+1, Len(c_MinTot) ))

n_Hr 	+= c_HrTot
n_Min 	:= c_MinTot2 

c_TotTime := Alltrim(StrZero(n_Hr,3)) +":" + AllTrim(StrZero(n_Min,2))

If Len(aListBox1) == 0
    aAdd(aListBox1,{ "","","","","","","","","","","","","",""})
EndIf

oListBox1:SetArray( aListBox1 )
oListBox1:bLine := {|| {        aListBox1[oListBox1:nAt,1],;
                                aListBox1[oListBox1:nAt,2],;
                                aListBox1[oListBox1:nAt,3],;
                                aListBox1[oListBox1:nAt,4],;
                                aListBox1[oListBox1:nAt,5],;
                                aListBox1[oListBox1:nAt,6],;
								STOD(aListBox1[oListBox1:nAt,7]),;
                                aListBox1[oListBox1:nAt,8],;                                
                                STOD(aListBox1[oListBox1:nAt,9]),;
                                aListBox1[oListBox1:nAt,10],;
								aListBox1[oListBox1:nAt,11],;
                                aListBox1[oListBox1:nAt,12],;
                                aListBox1[oListBox1:nAt,13],;
								aListBox1[oListBox1:nAt,14]}}
                            
oListBox1:Refresh()            
oDlg:Refresh()

cSay2 := Str(nQtd)
oSay2:Refresh()

cSay4 := c_TotTime
oSay4:Refresh()

Return Nil

/************************************************************************************************************************* */
Static Function ValidPerg(c_Perg)

aRegs := {}

//         Grupo /Ordem /Pergunta                /PERSPA   / PERENG/Variavel/Tipo   /Tamanho  /Decimal/Presel /GSC /Valid/Var01      /Def01    		  	/DEFSPA1 /DEFENG1 /Cnt01 /Var02     /Def02           /DEFSPA2 /DEFENG2 /Cnt02 /Var03     /Def03          /DEFSPA3 /DEFENG3 /Cnt03 /Var04     /Def04          	/DEFSPA4 /DEFENG4 /Cnt04 /Var05     /Def05          /DEFSPA5/DEFENG5  /Cnt05 /F3   /PYME/GRPSXG
aAdd(aRegs,{c_Perg,"01"  ,"Emissão de?		",""      	,""     ,"MV_CH1","D"    ,08      ,0       ,0     ,"C" ,""    ,"MV_PAR01",""    		        ,""      ,""      ,""   ,""         ,""	            ,""      ,""      ,""    ,""        ,""              ,""      ,""     ,""     ,""       ,""	                ,""      ,""      ,""    ,""        ,""            ,""      ,""      ,""    ,""       })
aAdd(aRegs,{c_Perg,"02"  ,"Emissão até?"	,""      	,""     ,"MV_CH2","D"    ,08      ,0       ,0     ,"G" ,""    ,"MV_PAR02",""         			,""      ,""      ,""   ,""         ,""            	,""      ,""      ,""    ,""        ,""              ,""      ,""     ,""     ,""       ,""             	,""      ,""      ,""    ,""        ,""            ,""      ,""      ,""    ,""       })
aAdd(aRegs,{c_Perg,"03"  ,"OP de?"			,""      	,""     ,"MV_CH3","C"    ,14      ,0       ,0     ,"G" ,""    ,"MV_PAR03",""					,""      ,""      ,""   ,""         ,""  			,""      ,""      ,""    ,""        ,""        		 ,""      ,""     ,""     ,""       ,""             	,""      ,""      ,""    ,""        ,""            ,""      ,""      ,""    ,"SC2"    })
aAdd(aRegs,{c_Perg,"04"  ,"OP até?"			,""      	,""     ,"MV_CH4","C"    ,14      ,0       ,0     ,"G" ,""    ,"MV_PAR04",""					,""      ,""      ,""   ,""         ,""			  	,""      ,""      ,""    ,""        ,""			     ,""      ,""     ,""     ,""       ,""             	,""      ,""      ,""    ,""        ,""            ,""      ,""      ,""    ,"SC2"    })
aAdd(aRegs,{c_Perg,"05"  ,"Operador de?"	,""      	,""     ,"MV_CH5","C"    ,10      ,0       ,0     ,"G" ,""    ,"MV_PAR05",""					,""      ,""      ,""   ,""         ,""  			,""      ,""      ,""    ,""        ,""        		 ,""      ,""     ,""     ,""       ,""             	,""      ,""      ,""    ,""        ,""            ,""      ,""      ,""    ,"SZ2"    })
aAdd(aRegs,{c_Perg,"06"  ,"Operador até?"	,""      	,""     ,"MV_CH6","C"    ,10      ,0       ,0     ,"G" ,""    ,"MV_PAR06",""					,""      ,""      ,""   ,""         ,""			  	,""      ,""      ,""    ,""        ,""			     ,""      ,""     ,""     ,""       ,""             	,""      ,""      ,""    ,""        ,""            ,""      ,""      ,""    ,"SZ2"    })
aAdd(aRegs,{c_Perg,"07"  ,"Operação de?"	,""      	,""     ,"MV_CH7","C"    ,02      ,0       ,0     ,"G" ,""    ,"MV_PAR07",""					,""      ,""      ,""   ,""         ,""			  	,""      ,""      ,""    ,""        ,""			     ,""      ,""     ,""     ,""       ,""             	,""      ,""      ,""    ,""        ,""            ,""      ,""      ,""    ,""    	  })
aAdd(aRegs,{c_Perg,"08"  ,"Operação até?"	,""      	,""     ,"MV_CH8","C"    ,02      ,0       ,0     ,"G" ,""    ,"MV_PAR08",""					,""      ,""      ,""   ,""         ,""			  	,""      ,""      ,""    ,""        ,""			     ,""      ,""     ,""     ,""       ,""             	,""      ,""      ,""    ,""        ,""            ,""      ,""      ,""    ,""    	  })
aAdd(aRegs,{c_Perg,"09"  ,"Recurso de?" 	,""      	,""     ,"MV_CH9","C"    ,06      ,0       ,0     ,"G" ,""    ,"MV_PAR09",""					,""      ,""      ,""   ,""         ,""			  	,""      ,""      ,""    ,""        ,""			     ,""      ,""     ,""     ,""       ,""             	,""      ,""      ,""    ,""        ,""            ,""      ,""      ,""    ,""   	  })
aAdd(aRegs,{c_Perg,"10"  ,"Recurso até?" 	,""      	,""     ,"MV_CHA","C"    ,06      ,0       ,0     ,"G" ,""    ,"MV_PAR10",""					,""      ,""      ,""   ,""         ,""			  	,""      ,""      ,""    ,""        ,""			     ,""      ,""     ,""     ,""       ,""             	,""      ,""      ,""    ,""        ,""            ,""      ,""      ,""    ,""   	  })


U_PutX1PERF(c_Perg, aRegs)

Return Nil

/*-------------------------------------------------------------------------------------
{Protheus.doc} PutX1PERF

@Author  	   Felipe Aguiar - Focus Consultoria
@since		   03/2019
@version	   P12

@description Validar se existe o grupo de perguntas no SX1.
---------------------------------------------------------------------------------------
|Author                  | Date       | Description                                    |
|                        |            |                                                |
|--------------------------------------------------------------------------------------*/
User Function PutX1PERF(c_Perg, a_Regs)

Local a_AreaATU	:= GetArea()
Local i			:= 0
Local j			:= 0

c_Perg := c_Perg + Replicate(" ", 10 - Len(c_Perg))

DbSelectArea("SX1")
DbSetOrder(1)

For i := 1 To Len(a_Regs)
	If !SX1->(DbSeek(c_Perg+a_Regs[i,2], .F.))
		RecLock("SX1", .T.)
		For j := 1 To FCount()
			If j <= Len(a_Regs[i])
				FieldPut(j,a_Regs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next i

RestArea(a_AreaATU)

Return Nil


/*************************************************************/

Static Function NovaPesq()

ValidPerg(c_Perg)

If !Pergunte(c_Perg, .T.)
	Return .F.
Else 

	cTGet1	:= MV_PAR01 
	cTGet2	:= MV_PAR02
	cTGet3  := MV_PAR03
	cTGet4  := MV_PAR04
	cTGet5 	:= MV_PAR05
	cTGet6 	:= MV_PAR06
	cTGet7 	:= MV_PAR07
	cTGet8 	:= MV_PAR08
	cTGet9 	:= MV_PAR09
	cTGet10 := MV_PAR10

	RefTela()

EndIf

Return Nil


/*************************************************************/

Static Function RefTela()

Processa({|| U_fFiltro()},"Aguarde","Selecionando registros...")

Return Nil


/*************************************************************/
Static Function TPesq(a_Pesquisa, o_Lista)

Local oDlgSeek
Local c_Texto 	:= Space(14)
Local cCombo 	:= ""
Local aCombo 	:= {}
	
	cCombo := "1 - Por OP"
	aCombo := {"1 - Por Op","2 - Por Produto"}

	DEFINE MSDIALOG oDlgSeek FROM  0,0 TO 120,280 TITLE " Pesquisa " PIXEL

	@ 005,010 ComboBox 	cCombo 	Items aCombo Size 100, 020 OF oDlgSeek PIXEL
	@ 025,010 MSGET 	c_Texto OF oDlgSeek PIXEL

	DEFINE SBUTTON FROM 42,045 TYPE 1  	ENABLE OF oDlgSeek ACTION (fPesquisa(@oListBox1, @a_Pesquisa, AllTrim(c_Texto), Val(Left(cCombo, 1)) ),oDlgSeek:End())
	DEFINE SBUTTON FROM 42,075 TYPE 2  	ENABLE OF oDlgSeek ACTION oDlgSeek:End()

	ACTIVATE MSDIALOG oDlgSeek CENTER

Return Nil

/*****************************************************************************************************/

Static Function fPesquisa(oListBox1, a_Pesquisa, c_Texto, n_Col)

	Local n_Linha := 0
	
	If ValType(a_Pesquisa[1][n_Col]) == "C"
		a_Pesquisa := aSort(a_Pesquisa,,,{|x,y| x[n_Col] < y[n_Col]})
		n_Linha := aScan(a_Pesquisa, {|x| Upper(Left(x[n_Col], Len(c_Texto))) == Upper(c_Texto)})
	ElseIf ValType(a_Pesquisa[1][n_Col]) == "D"
		a_Pesquisa := aSort(a_Pesquisa,,,{|x,y| DTOS(x[n_Col]) < DTOS(y[n_Col])})
		n_Linha := aScan(a_Pesquisa, {|x| x[n_Col] == CTOD(c_Texto)})
	ElseIf ValType(a_Pesquisa[1][n_Col]) == "N"
		a_Pesquisa := aSort(a_Pesquisa,,,{|x,y| x[n_Col] < y[n_Col]})
		n_Linha := aScan(a_Pesquisa, {|x| x[n_Col] == Val(c_Texto)})
	Endif

	If n_Linha > 0
		oListBox1:NAT := n_Linha
	Else
		MsgStop("Registro não localizado.", "Atenção")
		oListBox1:NAT := 1
	Endif

	oListBox1:Refresh()	

Return Nil