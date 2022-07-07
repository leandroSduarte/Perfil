#INCLUDE "Protheus.ch"
#INCLUDE "RWMAKE.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "TbiConn.ch" 
#INCLUDE "Font.ch"
#INCLUDE "FwBrowse.ch"

User Function fAptPerf()

If ConPad1(,,,"SZ2")
	U_PERAPTOP()
EndIf

Return Nil


/*-------------------------------------------------------------------------------------
{Protheus.doc} PERAPTOP

@Author  	   Felipe Aguiar - Focus Consultoria
@since		   03/2019
@version	   P12

@description Apontamento de OP
---------------------------------------------------------------------------------------
|Author                  | Date       | Description                                    |
|                        |            |                                                |
--------------------------------------------------------------------------------------*/
User Function PERAPTOP()

Local a_AreaATU	        := GetArea() 
Local a_Buttons	        := {}
Local nOpca				

Private oDlg
Private oTGet1
Private oSize	        	:= Nil
Private cTGet1 	        := Space(TAMSX3("Z3_OP")[1])
Private cTGet2	        := Space(TAMSX3("Z3_OPERAC")[1])
Private cTGet3	        := Space(TAMSX3("Z3_RECURSO")[1])
Private cTGet4	        := Space(30)
Private cTGet5	        := SZ2->Z2_CODIGO
Private cTGet6	        := SZ2->Z2_NOME

Private oGetDados
Private nFreeze         := 0
Private nMax            := 999
Private aAlter          := {}
Private cIniCpos        := "+" 
Private nOpc            := GD_UPDATE+GD_DELETE
Private cLinha          := "AllwaysTrue"
Private cTudoOk         := "AllwaysTrue" 
Private cCampoOk        := "AllwaysTrue"
Private cSuperApagar    := "AllwaysTrue"
Private cApagaOk        := "AllwaysTrue"

Private a_Cols
Private aHd


cCadastro := "Apontamento Ordem de Produção"

//Calcula as dimensoes dos objetos        
oSize := FwDefSize():New(.T.)             

oSize:AddObject( "CABECALHO" , 100, 65, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "RODAPE"    , 100, 35, .T., .T. ) // Totalmente dimensionavel s

oSize:lProp 	:= .T. // Proporcional             
oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

oSize:Process() // Dispara os calculos 

oDlg := MSDialog():New(oSize:aWindSize[1],oSize:aWindSize[2],oSize:aWindSize[3],oSize:aWindSize[4],"",,,,,CLR_BLACK,CLR_WHITE,,,.T.)


//Painel Ordem de Produção
oGrp2 := TGroup():New(	oSize:GetDimension("RODAPE","LININI")+5,;
						oSize:GetDimension("RODAPE","COLINI"),;
						oSize:GetDimension("RODAPE","LINEND"),;
						oSize:GetDimension("RODAPE","COLEND")/3,"Ordem de Produção",oDlg,,,.T.,)

// Label do campo OP
oSay1:= TSay():New( oSize:GetDimension("RODAPE","LININI")+15,;
                    oSize:GetDimension("RODAPE","COLINI")+5,;
                    {||"Op"},oGrp2,,,,,,.T.,,,50,20)

//Get do campo Op						
oTGet1  := TGet():New( oSize:GetDimension("RODAPE","LININI")+30,;
                       oSize:GetDimension("RODAPE","COLINI")+5,;
                       {|u| If(PCount() > 0, cTGet1 := u, cTGet1 )},oGrp2,100,010,"@!", { || EXISTCPO("SC2", cTGet1 ) },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"SC2TMP",cTGet1,,,,,,,,)


// Label do campo Operacao
oSay2:= TSay():New( oSize:GetDimension("RODAPE","LININI")+45,;
                    oSize:GetDimension("RODAPE","COLINI")+5,;
                    {||"Operação"},oGrp2,,,,,,.T.,,,40,20)

//Get do campo Operacao						
oTGet2  := TGet():New( oSize:GetDimension("RODAPE","LININI")+60,;
                       oSize:GetDimension("RODAPE","COLINI")+5,;
                       {|u| If(PCount() > 0, cTGet2 := u, cTGet2 )},oGrp2,20,010,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTGet2,,,,,,,,)


oTGet2:bChange := { ||  U_fAtuGrid()  }


/**************************************************************************************************************************************************/ 

//Objeto do GRID
aPosGetD := { 030, 005, oSize:GetDimension("CABECALHO","YSIZE"), oSize:GetDimension("CABECALHO","XSIZE") - 4 }
a_Hd  	    := U_fHEADER("SZ3") 
a_Cols	    := U_fCOLS(a_Hd)

oGetDados   := MsNewGetDados():New( aPosGetD[1] , aPosGetD[2],aPosGetD[3],aPosGetD[4],nOpc,cLinha,cTudoOk,cIniCpos,aAlter,nFreeze,nMax,cCampoOk,cSuperApagar,cApagaOk,oDlg,a_Hd,a_Cols)


/*****************************************************************************************************************************************/					   

//Painel Recurso
oGrp3 := TGroup():New(	oSize:GetDimension("RODAPE","LININI")+5,;
						(oSize:GetDimension("RODAPE","COLEND")/3)+5,;
						oSize:GetDimension("RODAPE","LINEND"),;
						(oSize:GetDimension("RODAPE","COLEND")/3)*2,"Recurso",oDlg,,,.T.,)

// Label do campo Recurso
oSay3:= TSay():New( oSize:GetDimension("RODAPE","LININI")+15,;
                    (oSize:GetDimension("RODAPE","COLEND")/3)+10,;
                    {||"Recurso"},oGrp3,,,,,,.T.,,,40,20)

//Get do campo Recurso						
oTGet3  := TGet():New( oSize:GetDimension("RODAPE","LININI")+30,;
                       (oSize:GetDimension("RODAPE","COLEND")/3)+10,;
                       {|u| If(PCount() > 0, cTGet3 := u, cTGet3 )},oGrp3,20,010,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"SH1",cTGet3,,,,,,,,)


oTGet3:LREADONLY := .T.


// Label do campo Descrição Recurso
oSay4:= TSay():New( oSize:GetDimension("RODAPE","LININI")+45,;
                    (oSize:GetDimension("RODAPE","COLEND")/3)+10,;
                    {||"Descrição"},oGrp3,,,,,,.T.,,,40,20)

//Get do campo Descrição Recurso						
oTGet4  := TGet():New( oSize:GetDimension("RODAPE","LININI")+60,;
                       (oSize:GetDimension("RODAPE","COLEND")/3)+10,;
                       {|u| If(PCount() > 0, cTGet4 := u, cTGet4 )},oGrp3,200,010,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTGet4,,,,,,,,)	

oTGet4:LREADONLY := .T.					   

/*****************************************************************************************************************************************/

//Painel Operador
oGrp4 := TGroup():New(	oSize:GetDimension("RODAPE","LININI")+5,;
						((oSize:GetDimension("RODAPE","COLEND")/3)*2)+5,;
						oSize:GetDimension("RODAPE","LINEND"),;
						oSize:GetDimension("RODAPE","COLEND"),"Operador",oDlg,,,.T.,)

// Label do campo Codigo Operador
oSay5:= TSay():New( oSize:GetDimension("RODAPE","LININI")+15,;
                    ((oSize:GetDimension("RODAPE","COLEND")/3)*2)+10,;
                    {||"Codigo"},oGrp4,,,,,,.T.,,,40,20)

//Get do campo Codigo Operador						
oTGet5  := TGet():New( oSize:GetDimension("RODAPE","LININI")+30,;
                       ((oSize:GetDimension("RODAPE","COLEND")/3)*2)+10,;
                       {|u| If(PCount() > 0, cTGet5 := u, cTGet5 )},oGrp4,20,010,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"",cTGet5,,,,,,,,)
oTGet5:LREADONLY := .T.

// Label do campo Nome
oSay6:= TSay():New( oSize:GetDimension("RODAPE","LININI")+45,;
                    ((oSize:GetDimension("RODAPE","COLEND")/3)*2)+10,;
                    {||"Nome"},oGrp4,,,,,,.T.,,,40,20)

//Get do campo Nome						
oTGet6  := TGet():New( oSize:GetDimension("RODAPE","LININI")+60,;
                       ((oSize:GetDimension("RODAPE","COLEND")/3)*2)+10,;
                       {|u| If(PCount() > 0, cTGet6 := u, cTGet6 )},oGrp4,200,010,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"",cTGet6,,,,,,,,)

oTGet6:LREADONLY := .T. 

oTGet1:SetFocus()

/*****************************************************************************************************************************************/

oDlg:bInit := {||  EnchoiceBar( oDlg, { || nOpca := 1 , IIF( fTudoOK() , MsgRun("Gerando apontamentos...", "Por Favor, aguarde.", {|| GravaZ3()  }), Nil )  }, {|| nOpca := 0, oDlg:End() },, a_Buttons)}		
				   
oDlg:Activate()

RestArea(a_AreaATU)

Return Nil


/*-------------------------------------------------------------------------------------
{Protheus.doc} fHEADER

@Author  	   Focus Consultoria
@since		   03/2019
@version	   P11

@description Função generica para montar Header da NewGetDados
--------------------------------------------------------------------------------------
|Author                  | Date       | Description                                    |
|                        |            |                                                |
--------------------------------------------------------------------------------------*/
User Function fHEADER(cTab)

	Local 		c_Campos	:= ""
	Local		aHeader		:= {}

	c_Campos := "Z3_OP#Z3_PRODUTO#Z3_OPERAC#Z3_RECURSO#Z3_DATAINI#Z3_HORAINI#Z3_DATAFIN#Z3_HORAFIN#Z3_QTDPROD#Z3_QTDPERD#Z3_OPERADO#Z3_LOCAL"

	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek(cTab)

	While SX3->X3_Arquivo == cTab .And. !SX3->(EOF()) 
     
		If !(AllTrim(Upper(X3_CAMPO)) $ c_Campos)
			dbSkip()
			Loop
		End
     
		If X3Uso(SX3->X3_Usado,10) .And. cNivel >= SX3->X3_Nivel .And. Trim(SX3->X3_ARQUIVO)== cTab

			AAdd(aHeader, {Trim(SX3->X3_TITULO),;
						SX3->X3_CAMPO	,;
						SX3->X3_PICTURE	,;
						SX3->X3_TAMANHO	,;
						SX3->X3_DECIMAL	,;
						SX3->X3_VALID	,;
						SX3->X3_USADO	,;
						SX3->X3_TIPO	,;
						SX3->X3_F3		,;
						SX3->X3_CONTEXT	,;
						SX3->X3_CBOX	,;
						SX3->X3_RELACAO	,;
						SX3->X3_WHEN	,;
						SX3->X3_VISUAL	,;
						SX3->X3_VLDUSER	,;
						SX3->X3_PICTVAR	})
						
		EndIf
     
		SX3->(dbSkip())
     
	EndDo

Return aHeader


/*-------------------------------------------------------------------------------------
{Protheus.doc} fCOLS

@Author  	   Focus Consultoria
@since		   03/2019
@version	   P11

@description Função para montar o Array aCols da GetDados
--------------------------------------------------------------------------------------
|Author                  | Date       | Description                                    |
|                        |            |                                                |
--------------------------------------------------------------------------------------*/
User Function fCOLS(aHd, cQuery, aTables)

	Local   aCL    := {}
	Default aHd    := {}
	Default cQuery := ""
	Default aTables := {}

	If !Empty(cQuery) 
		nCont   := 0 
		nTotReg := 0
		cAliasA := GetNextAlias()
		TcQuery := ChangeQuery(cQuery)
	
		DbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), cAliasA , .T., .T.) 
		For _w1 := 1 To Len(aTables)
			aEval( &(aTables[_w1])->(DbStruct()),{|x| If(x[2] != "C", TcSetField(cAliasA, AllTrim(x[1]), x[2], x[3], x[4]),Nil)})
		Next _w1	
		
		DbSelectArea( cAliasA )
		(cAliasA)->( DbEval( { || nTotReg++ },,{ || !Eof() } ) )
		(cAliasA)->( DbGoTop() )
	
		ProcRegua( nTotReg )
	
		If (cAliasA)->(!Eof())
			While (cAliasA)->(!Eof())
				IncProc( "Registro "+StrZero(++nCont,6)+" de "+StrZero(nTotReg,6) )
			
				aadd(aCL,Array(Len(aHd)+1))
				For _n1 := 1 To Len(aHd)
					aCL[Len(aCL),_n1] := (cAliasA)->&(aHd[_n1][2])
				Next _n1
				aCL[Len(aCL),Len(aHd)+1] := .F.
			
				(cAliasA)->(DbSkip())
			End-While 
		EndIf
		(cAliasA)->(DbCloseArea())
	EndIf
                                                 
	If Len(aCL) <= 0
		aadd(aCL,Array(Len(aHd)+1))

		For _n1 := 1 To Len(aHd)                                                                               
			If aHd[_n1,8] == "C"
				nCriaV	:= Space(aHd[_n1,4])
			ElseIf aHd[_n1,8] == "N"
				nCriaV	:= 0
			ElseIf aHd[_n1,8] == "L"
				nCriaV	:= .F.
			ElseIf aHd[_n1,8] == "D"
				nCriaV	:= Ctod("")
			Else
				nCriaV	:= ""
			EndIf
							                                 
			aCL[Len(aCL),_n1] := Iif( LEFT(aHd[_n1][2],5) == "XREGS", 0, nCriaV )
		Next _n1
		aCL[Len(aCL),Len(aHd)+1] := .F.
	EndIf
	                       
Return(aCl)                       

/*************************************************************************************************/

User Function fAtuGrid()

Local a_AreaSC2 := SC2->(GetArea())
Local a_AreaSG2	:= {}
Local a_AreaSH6	:= {}
Local aBotoes	:= {}
Local nOp		:= 0


Local n_QtdPer := 0
Local n_QtdPr  := 0

Private nPosOp 		:= aScan(a_Hd, {|x| AllTrim(x[2])  == "Z3_OP"			})
Private nPosPrd		:= aScan(a_Hd, {|x| AllTrim(x[2])  == "Z3_PRODUTO"		})
Private nPosOper	:= aScan(a_Hd, {|x| AllTrim(x[2])  == "Z3_OPERAC"		})
Private nPosRec		:= aScan(a_Hd, {|x| AllTrim(x[2])  == "Z3_RECURSO"		})
Private nPosDtI		:= aScan(a_Hd, {|x| AllTrim(x[2])  == "Z3_DATAINI"		})
Private nPosHrI		:= aScan(a_Hd, {|x| AllTrim(x[2])  == "Z3_HORAINI"		})
Private nPosDtF		:= aScan(a_Hd, {|x| AllTrim(x[2])  == "Z3_DATAFIN"		})
Private nPosHrF		:= aScan(a_Hd, {|x| AllTrim(x[2])  == "Z3_HORAFIN"		})
Private nPosQtP		:= aScan(a_Hd, {|x| AllTrim(x[2])  == "Z3_QTDPROD"		})
Private nPosQtPd	:= aScan(a_Hd, {|x| AllTrim(x[2])  == "Z3_QTDPERD"		})
Private nPosOpdo	:= aScan(a_Hd, {|x| AllTrim(x[2])  == "Z3_OPERADO"		})
Private nPosLoc		:= aScan(a_Hd, {|x| AllTrim(x[2])  == "Z3_LOCAL"		})


Private c_Saldo	:= ""

oFont := TFont():New("Calibri",,030,,.T.,,,,,.F.,.F.)

DbSelectArea("SC2")
DbSetOrder(1)

If DbSeek(xFilial("SC2")+cTGet1)

		If !(u_fValid())
			MsgStop("Esta operação ja foi bipada na tela")
			Return Nil
		EndIf

		//Valido se existem operações anteriores e q nao foram iniciadas
		If !(fValOper(cTGet2))
			Return Nil
		EndIf

		//Valido se operador que esta encerrando a operacao é o mesmo que abriu
		If !(fOperador(cTGet5))
			 Return Nil
		EndIf

		If Len(oGetDados:aCols) == 1

			If Empty(oGetDados:aCols[1][1])				
				i:= 1
			Else				
				aadd(oGetDados:aCols,Array(Len(a_Hd)+1))			
				i := Len(oGetDados:aCols) 			
			EndIF
		Else
			aadd(oGetDados:aCols,Array(Len(a_Hd)+1)) 
			i:= Len(oGetDados:aCols) 
		EndIf	

		DbSelectArea("SZ3")
		DbSetOrder(1)
							
		c_Enc := " SELECT COUNT(*) AS QTD FROM ( "
		c_Enc += " SELECT	* "
		c_Enc += " FROM	"+RetSqlName("SZ3") +" (NOLOCK)"
		c_Enc += " WHERE	Z3_FILIAL = '"+xFilial("SZ3")+"'"
		c_Enc += " AND		Z3_OP = '"+ SC2->(C2_NUM+C2_ITEM+C2_SEQUEN)+ "'"
		c_Enc += " AND		Z3_PRODUTO = '" +SC2->C2_PRODUTO+"'"
		c_Enc += " AND		Z3_OPERAC = '"+cTGet2+"'"
		c_Enc += " AND		Z3_CTRSH6  = ''
		c_Enc += " AND		D_E_L_E_T_ = ''	 ) AS TEMP "	
		
		If Select("TEMAP") > 0
			TEMAP->(DbCloseArea())
		Endif

		TCQUERY c_Enc NEW ALIAS "TEMAP"

		n_tem := TEMAP->QTD
			
		If n_tem > 0							
			c_DtIni	:= CTOD("//")
			c_HrIni	:= Space(5)
			c_DtFim := Date()
			c_HrFim := Left(Time(), 5)
			
		Else				
			c_DtIni	:= Date()
			c_HrIni	:= Left(Time(), 5)
			c_DtFim := CTOD("//")
			c_HrFim := Space(5)
		EndIf 

		a_AreaSG2 :=  SG2->(GetArea())

		DbSelectArea("SG2")
		DbSetOrder(3)
		If DbSeek(xFilial("SG2")+SC2->C2_PRODUTO+cTGet2)

			cTGet3 := ALLTRIM(SG2->G2_RECURSO)
			oTGet3:Refresh()

			cTGet4 := ALLTRIM(SG2->G2_DESCRI)
			oTGet4:Refresh()
		
		EndIf

		RestArea(a_AreaSG2)	

		
		If fTemSldo()

			oGetDados:aCols[i][nPosOp] 	 	:= SC2->(C2_NUM+C2_ITEM+C2_SEQUEN)
			oGetDados:aCols[i][nPosPrd]		:= SC2->C2_PRODUTO 
			oGetDados:aCols[i][nPosOper]	:= cTGet2
			oGetDados:aCols[i][nPosRec]		:= cTGet3
			oGetDados:aCols[i][nPosDtI]		:= c_DtIni
			oGetDados:aCols[i][nPosHrI]		:= c_HrIni	
			oGetDados:aCols[i][nPosDtF]		:= c_DtFim
			oGetDados:aCols[i][nPosHrF]		:= c_HrFim
			oGetDados:aCols[i][nPosQtP]		:= 0
			oGetDados:aCols[i][nPosQtPd]	:= 0
			oGetDados:aCols[i][nPosOpdo]	:= SZ2->Z2_CODIGO	
			oGetDados:aCols[i][nPosLoc]		:= SC2->C2_LOCAL

			oGetDados:aCols[i][Len(a_Hd)+1] := .F.
			oGetDados:ForceRefresh()	
			oGetDados:GoTop()	
					
			If !Empty(oGetDados:aCols[i][nPosDtF])
			
				Define MsDialog oDlgQtd Title "Quantidade Produzida" From 000,000 To 212,450 Pixel

				@ 043,007 Say "Digite Qtd Produzida:"      						Size 100,008 Pixel Of oDlgQtd
				@ 050,007 Get n_QtdPr Picture PesqPict("SH6","H6_QTDPROD",18)   Size 50,010 Object o_Txt VALID !EMPTY(n_QtdPr)
				
				@ 065,007 Say "Digite Qtd Perdida:"                				Size 100,008 Pixel Of oDlgQtd
				@ 072,007 Get n_QtdPer Picture PesqPict("SH6","H6_QTDPERD",18)  Size 50,010 Object o_Txt 
				
				oSay  := TSay():New(080,120,{ ||" Saldo:"},oDlgQtd,,oFont,,,,.T.,CLR_RED  ,CLR_WHITE,,)
				oSay2 := TSay():New(080,150,{ || c_Saldo },oDlgQtd,,oFont,,,,.T.,CLR_BLUE,CLR_WHITE,,)
				
				Activate MsDialog oDlgQtd Centered On Init EnchoiceBar(oDlgQtd,{|| nOp := 1 , oDlgQtd:End() }, {|| nOp := 0, oDlgQtd:End() },, aBotoes)


				If nOp == 1
					
					oGetDados:aCols[i][nPosQtP]		:= n_QtdPr
					oGetDados:aCols[i][nPosQtPd]	:= n_QtdPer

					oGetDados:ForceRefresh()	
					oGetDados:GoTop()
								
				EndIf
					
			EndIf
					
		EndIf		
	
Else 
	
	MsgStop("Op não encontrada","ATENÇÃO")

EndIf

RestArea(a_AreaSC2)

Return Nil

/***************************************************************************************************/
User Function fGravaSH6()

Local _aSH6		:= {}
Local c_Query	:= ""		

c_Query	:= " SELECT	Z3_FILIAL,"
c_Query	+= " 		Z3_OP,"
c_Query	+= "		Z3_PRODUTO,"
c_Query	+= "		Z3_OPERAC,"
c_Query	+= "		Z3_RECURSO,"
c_Query	+= "		MAX(Z3_DATAINI) AS 'Z3_DATAINI',"
c_Query	+= "		MAX(Z3_HORAINI) AS 'Z3_HORAINI',"
c_Query	+= "		MAX(Z3_DATAFIN) AS 'Z3_DATAFIN',"
c_Query	+= "		MAX(Z3_HORAFIN) AS 'Z3_HORAFIN',"
c_Query	+= "		SUM(Z3_QTDPROD) AS 'Z3_QTDPROD',"
c_Query	+= "		SUM(Z3_QTDPERD) AS 'Z3_QTDPERD',"
c_Query	+= "		Z3_LOCAL,"
c_Query	+= "		Z3_OPERADO"
c_Query	+= " FROM	" +RetSqlName("SZ3")+" (NOLOCK)"
c_Query	+= " WHERE	Z3_FILIAL = '"+ xFilial("SZ3") +"'"
c_Query	+= " AND		Z3_OP = '"+ oGetDados:aCols[n_Item][nPosOp] +"'"
c_Query	+= " AND		Z3_PRODUTO = '" + oGetDados:aCols[n_Item][nPosPrd] + "'" 
c_Query	+= " AND		Z3_OPERAC = '" + oGetDados:aCols[n_Item][nPosOper] + "'"
c_Query	+= " AND		Z3_CTRSH6 = ''"
c_Query	+= " AND		D_E_L_E_T_ = ''"
c_Query	+= " GROUP BY Z3_FILIAL, Z3_OP,Z3_PRODUTO,Z3_OPERAC,Z3_RECURSO,Z3_LOCAL, Z3_OPERADO"

If Select("GRVH6") > 0
	GRVH6->(DbCloseArea())
Endif

MemoWrite("Gera_SH6.SQL", c_Query)

TCQUERY c_Query NEW ALIAS "GRVH6"

GRVH6->(dbGotop())
While GRVH6->(!Eof())

	_aSH6 := {}

	aAdd(_aSH6,{"H6_OP"			, GRVH6->Z3_OP				, Nil})
	aAdd(_aSH6,{"H6_PRODUTO"	, GRVH6->Z3_PRODUTO			, Nil})
	aAdd(_aSH6,{"H6_OPERAC"		, GRVH6->Z3_OPERAC 			, Nil})
	aAdd(_aSH6,{"H6_RECURSO"	, GRVH6->Z3_RECURSO			, Nil}) 
	aAdd(_aSH6,{"H6_DATAINI"	, STOD(GRVH6->Z3_DATAINI)	, Nil}) 
	aAdd(_aSH6,{"H6_HORAINI"	, GRVH6->Z3_HORAINI			, Nil})
	aAdd(_aSH6,{"H6_DATAFIN"	, STOD(GRVH6->Z3_DATAFIN)	, Nil}) 
	aAdd(_aSH6,{"H6_HORAFIN"	, GRVH6->Z3_HORAFIN			, Nil})
	aAdd(_aSH6,{"H6_QTDPROD"	, GRVH6->Z3_QTDPROD			, Nil})
	aAdd(_aSH6,{"H6_QTDPERD"	, GRVH6->Z3_QTDPERD			, Nil})
	aAdd(_aSH6,{"H6_OPERADO"	, GRVH6->Z3_OPERADO			, Nil})
	aAdd(_aSH6,{"H6_LOCAL"		, GRVH6->Z3_LOCAL			, Nil})
			
	If Len(_aSH6) > 0
		lMsErroAuto := .F.
		//Apontamento de Producao baseado no Roteiro de Operacoes 
		MSExecAuto({|x| mata681(x)},_aSH6)  // inclusao
		If (lMsErroAuto)
			Mostraerro()			
			Final("Não foi possível finalizar o processo.")			
		Else
			
			DbSelectArea("SZ3")
			DbSetOrder(1)//Z3_FILIAL, Z3_OP, Z3_PRODUTO, Z3_OPERAC, R_E_C_N_O_, D_E_L_E_T_
			DbSeek(xFilial("SZ3")+GRVH6->(Z3_OP+Z3_PRODUTO+Z3_OPERAC))

			While SZ3->(!Eof()) .AND. SZ3->Z3_FILIAL == xFilial() .AND. SZ3->Z3_OP == GRVH6->Z3_OP .AND. SZ3->Z3_PRODUTO == GRVH6->Z3_PRODUTO .AND. SZ3->Z3_OPERAC == GRVH6->Z3_OPERAC

				RECLOCK("SZ3", .F.)
				SZ3->Z3_CTRSH6 := "1"
				SZ3->( MsUnLock() )

				SZ3->(DbSkip())

			EndDo		

			MsgInfo("Apontamento realizado com sucesso!")	

		EndIf       

	EndIf

	GRVH6->(DbSkip())

EndDo

Return Nil

/****************************************************************************************************/
Static Function GravaZ3()

Private n_Item		:= 0
Private nPosOp 		:= aScan(a_Hd, {|x| AllTrim(x[2])  == "Z3_OP"			})
Private nPosPrd		:= aScan(a_Hd, {|x| AllTrim(x[2])  == "Z3_PRODUTO"		})
Private nPosOper	:= aScan(a_Hd, {|x| AllTrim(x[2])  == "Z3_OPERAC"		})
Private nPosRec		:= aScan(a_Hd, {|x| AllTrim(x[2])  == "Z3_RECURSO"		})
Private nPosDtI		:= aScan(a_Hd, {|x| AllTrim(x[2])  == "Z3_DATAINI"		})
Private nPosHrI		:= aScan(a_Hd, {|x| AllTrim(x[2])  == "Z3_HORAINI"		})
Private nPosDtF		:= aScan(a_Hd, {|x| AllTrim(x[2])  == "Z3_DATAFIN"		})
Private nPosHrF		:= aScan(a_Hd, {|x| AllTrim(x[2])  == "Z3_HORAFIN"		})
Private nPosQtP		:= aScan(a_Hd, {|x| AllTrim(x[2])  == "Z3_QTDPROD"		})
Private nPosQtPd	:= aScan(a_Hd, {|x| AllTrim(x[2])  == "Z3_QTDPERD"		})
Private nPosOpdo	:= aScan(a_Hd, {|x| AllTrim(x[2])  == "Z3_OPERADO"		})
Private nPosLoc		:= aScan(a_Hd, {|x| AllTrim(x[2])  == "Z3_LOCAL"		})

BEGIN TRANSACTION

	For n_Item := 1 To Len(oGetDados:aCols)

		If oGetDados:aCols[n_Item][Len(oGetDados:aHeader)+1] == .F. 

			//Tratamento para se o usuario digitar qtd na abertura NAO gravar
			If !(Empty(oGetDados:aCols[n_Item][nPosDtI]))
				nQtPro := 0
				nQtPer := 0 
			Else	
				nQtPro := oGetDados:aCols[n_Item][nPosQtP]
				nQtPer := oGetDados:aCols[n_Item][nPosQtPd]
			EndIf
			
			RecLock("SZ3",.T.)

			Z3_FILIAL		:= xFilial("SZ3")		
			Z3_OP			:= oGetDados:aCols[n_Item][nPosOp]	
			Z3_PRODUTO		:= oGetDados:aCols[n_Item][nPosPrd]
			Z3_OPERAC		:= oGetDados:aCols[n_Item][nPosOper]	
			Z3_RECURSO		:= oGetDados:aCols[n_Item][nPosRec]
			Z3_DATAINI		:= oGetDados:aCols[n_Item][nPosDtI]
			Z3_HORAINI		:= oGetDados:aCols[n_Item][nPosHrI]
			Z3_DATAFIN		:= oGetDados:aCols[n_Item][nPosDtF]
			Z3_HORAFIN		:= oGetDados:aCols[n_Item][nPosHrF]
			Z3_QTDPROD		:= nQtPro
			Z3_QTDPERD		:= nQtPer
			Z3_OPERADO		:= oGetDados:aCols[n_Item][nPosOpdo]
			Z3_LOCAL		:= oGetDados:aCols[n_Item][nPosLoc]
		
			SZ3->( MsUnLock() )

			If !(Empty(oGetDados:aCols[n_Item][nPosDtF])) 
				U_fGravaSH6()
			Else
				MsgInfo("Apontamento realizado com sucesso!")	
			EndIf 
		
		EndIF	
				
	Next n_Item

END TRANSACTION

If ConPad1(,,,"SZ2")

	cTGet5 := SZ2->Z2_CODIGO
	oTGet5:Refresh()
	cTGet6 := SZ2->Z2_NOME
	oTGet6:Refresh()

EndIf

a_Cols := U_fCOLS(a_Hd)
oGetDados:SetArray(a_Cols)
oGetDados:ForceRefresh()

cTGet1 := Space(TAMSX3("Z3_OP")[1])
oTGet1:Refresh()

cTGet2 := Space(TAMSX3("Z3_OPERAC")[1])
oTGet2:Refresh()

cTGet3 := Space(TAMSX3("Z3_RECURSO")[1])
oTGet3:Refresh()

cTGet4 := Space(30)
oTGet4:Refresh()

oGrp2:SetFocus()
oTGet1:SetFocus()

Return Nil 

///**********************************************************************************************************************************/
User Function fValid()

Local l_Ok := .T.


	For n_Item := 1 To Len(oGetDados:aCols)

		If oGetDados:aCols[n_Item][Len(oGetDados:aHeader)+1] == .F. 

			If oGetDados:aCols[n_Item][1] == SC2->(C2_NUM+C2_ITEM+C2_SEQUEN) .AND. oGetDados:aCols[n_Item][2] == SC2->C2_PRODUTO .AND. oGetDados:aCols[n_Item][3] == cTGet2
				 l_Ok := .F.
				 Exit
			EndIF

		EndIF	
				
	Next n_Item

Return l_Ok


/*************************************************************************************************8 */
Static Function fTudoOK()

Local l_OK := .T.

For n_Item := 1 To Len(oGetDados:aCols)

	If oGetDados:aCols[n_Item][Len(oGetDados:aHeader)+1] == .F. 

		If !Empty(oGetDados:aCols[n_Item][GdFieldPos("Z3_DATAINI",oGetDados:aHeader)]) .AND. (  !Empty(oGetDados:aCols[n_Item][GdFieldPos("Z3_QTDPROD",oGetDados:aHeader)])  .OR. !Empty(oGetDados:aCols[n_Item][GdFieldPos("Z3_QTDPERD",oGetDados:aHeader)] ) )
			l_OK := .F.
			MsgStop("Não deve ser informada quantidade para apontamento de abertura da operação!")	
		EndIF

	EndIF	
				
Next n_Item

Return l_OK


/******************************************************************************************************/
Static Function fTemSldo()

Local l_Sld := .T.
Local c_QrySaldo := ""
Local n_sld

c_QrySaldo := " SELECT	ISNULL(SUM(H6_QTDPROD+H6_QTDPERD),0) AS QTDAP "
c_QrySaldo += " FROM	"+RetSqlName("SH6")+" (NOLOCK) "
c_QrySaldo += " WHERE	H6_OP = '"+ SC2->(C2_NUM+C2_ITEM+C2_SEQUEN) +"' "   
c_QrySaldo += " AND		H6_OPERAC = '" + cTGet2 +"' "
c_QrySaldo += " AND		D_E_L_E_T_ = '' "

If Select("XSLD") > 0
    XSLD->(DbCloseArea())
Endif

TCQUERY c_QrySaldo NEW ALIAS "XSLD"

n_sld := XSLD->QTDAP

n_Rest := SC2->C2_QUANT - n_sld

If n_Rest <= 0
  l_Sld := .F.
  MsgStop("Não existe Saldo para esta operação!")


	a_Cols	    := U_fCOLS(a_Hd)
	oGetDados:SetArray(a_Cols)
	oGetDados:ForceRefresh()


	cTGet1 := Space(TAMSX3("Z3_OP")[1])
	oTGet1:Refresh()

	cTGet2 := Space(TAMSX3("Z3_OPERAC")[1])
	oTGet2:Refresh()

	cTGet3 := Space(TAMSX3("Z3_RECURSO")[1])
	oTGet3:Refresh()

	cTGet4 := Space(30)
	oTGet4:Refresh()

ElseIf !(Empty(SC2->C2_DATRF)) 

	l_Sld := .F.
	MsgStop("O.P. encerrada!")
	
Else
	c_Saldo := Transform(n_Rest,"@E 999,999.9999") 
EndIf

Return l_Sld


/*********************************************************************************************************************************/
Static Function fValOper(c_Oper)

Local l_Oper 	:= .T.
Local c_Qry 	:= ""
Local c_Apont	:= ""
Local a_AreaSG2 := SG2->(GetArea())


DbSelectArea("SG2")
DbSetOrder(3)

If !(DbSeek(xFilial("SG2")+SC2->C2_PRODUTO+c_Oper))
	l_Oper := .F.
	MsgAlert("Operação inválida.")
	
EndIf

If l_Oper

	//Busco quantas operações existem antes da que esta sendo bipada
	c_Qry 	:= " SELECT	G2_OPERAC"
	c_Qry 	+= " FROM	"+RetSqlName("SG2") +"(NOLOCK)"
	c_Qry 	+= " WHERE	G2_FILIAL = '"+xFilial("SG2")+"'"
	c_Qry 	+= " AND		G2_CODIGO = '01' "
	c_Qry 	+= " AND		G2_PRODUTO = '" +SC2->C2_PRODUTO+ "'" 
	c_Qry 	+= " AND		G2_OPERAC < '" +c_Oper+ "'"
	c_Qry 	+= " AND		D_E_L_E_T_ = '' "

	If Select("XOPER") > 0
		XOPER->(DbCloseArea())
	Endif

	MemoWrite("Operações.SQL", c_Qry)

	TCQUERY c_Qry NEW ALIAS "XOPER"

	If Select("XRSOP") > 0
		XRSOP->(DbCloseArea())
	Endif

	TCQUERY "SELECT COUNT(*) AS QTDREG FROM ("+c_Qry+") AS RESULT" NEW ALIAS "XRSOP"

	n_Resul := XRSOP->QTDREG

	If n_Resul > 0 

			XOPER->(DbGotop())
			While XOPER->(!Eof())

					//Verifico se as operações anteiores ja foram iniciadas						
					c_Apont	:= " SELECT	COUNT(*) AS 'QTD'"
					c_Apont	+= " FROM	"+RetSqlName("SZ3") +"(NOLOCK)" 
					c_Apont	+= " WHERE	Z3_OP = '"+ SC2->(C2_NUM+C2_ITEM+C2_SEQUEN) +"'" 
					c_Apont	+= " AND		Z3_PRODUTO = '"+ SC2->C2_PRODUTO	+"'"
					c_Apont	+= " AND		Z3_OPERAC = '"+ XOPER->G2_OPERAC +"'"	
					c_Apont	+= " AND		D_E_L_E_T_ = '' "

					If Select("XQTD") > 0
					XQTD->(DbCloseArea())
					Endif
					
					TCQUERY c_Apont NEW ALIAS "XQTD"
					
					n_Quant := XQTD->QTD 

					If n_Quant == 0

						l_Oper := .F.
						MsgStop("Operação ["+ ALLTRIM(c_Oper) +"] inválida, pois a operação anterior não foi iniciada.","ATENÇÃO")

						Return l_Oper

					EndIf
		
					XOPER->(DbSkip())

			EndDo

	EndIf

EndIf

RestArea(a_AreaSG2)

Return l_Oper

/*****************************************************************************************/
Static Function fOperador(c_Operador)

Local c_QryOp := ""
Local c_Count	:= ""
Local n_tem		:= 0 
Local l_Ret		:= .T.
							
c_QryOp := " SELECT	* "
c_QryOp += " FROM	"+RetSqlName("SZ3") +" (NOLOCK)"
c_QryOp += " WHERE	Z3_FILIAL = '"+xFilial("SZ3")+"'"
c_QryOp += " AND		Z3_OP = '"+ SC2->(C2_NUM+C2_ITEM+C2_SEQUEN)+ "'"
c_QryOp += " AND		Z3_PRODUTO = '" +SC2->C2_PRODUTO+"'"
c_QryOp += " AND		Z3_OPERAC = '"+cTGet2+"'"
c_QryOp += " AND		Z3_CTRSH6  = ''
c_QryOp += " AND		D_E_L_E_T_ = ''	  "	
		
c_Count := "SELECT COUNT(*) AS 'QTD' FROM ( " + c_QryOp + " ) AS RESULT"

If Select("XCOUNT") > 0
	XCOUNT->(DbCloseArea())
Endif

TCQUERY c_Count NEW ALIAS "XCOUNT"

n_tem := XCOUNT->QTD

If n_tem > 0 

		If Select("XOPERA") > 0
			XOPERA->(DbCloseArea())
		Endif

		TCQUERY c_QryOp NEW ALIAS "XOPERA"
		
		XOPERA->(DbGotop())
		While XOPERA->(!Eof())

			If XOPERA->Z3_OPERADO <> c_Operador
				MsgStop("Operador de encerramento não pode ser diferente de abertura da operação.","Atenção")
				l_Ret := .F. 
				Return l_Ret
				
			EndIf
		
			XOPERA->(DbSkip())

		EndDo

EndIf

Return l_Ret