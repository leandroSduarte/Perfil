#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"
#Include "RWMAKE.CH"
#Include "MSOLE.CH"
#Include "TbiConn.ch"

#DEFINE cEstilo "QPushButton:pressed { background-color: #e6e6f9; border-style: inset;}"

Static nSysHRes := oMainWnd:nClientWidth
Static lSysFlat := "MP8" $ oApp:cVersion .And. ((Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild())
Static cRETLTF3

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PERPCP01   ³ Autor ³ Flavio Valentin           ³ Data ³ 04/12/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina para separacao de produtos para armazem de producao.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil.                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
User Function PERPCP01()

Private cGet1	   		:= Criavar("D4_OP",.F.)
Private oGet1
Private oOK
Private oCancel

Private cPerg    		:= "PPCP02"
Private nmvpar01 		:= 0
Private cmvpar02 		:= ""
Private cmvpar03 		:= ""
Private lMsHelpAuto 	:= .T.
Private lMsErroAuto 	:= .F.
Private l380 			:= .T.
Private l381 			:= .F.
Private oBrwSld
Private oDlgOP

// Valida Data com Parametro
If !VLDPCP02()
	Return
EndIf

SetKey( VK_F12,  {||  Chamapar() } )
DEFINE MSDIALOG oDlgOP TITLE "Separação de Produtos para Produção" FROM FAJUSTCOOR(317),FAJUSTCOOR(449) To FAJUSTCOOR(496),FAJUSTCOOR(716) PIXEL

@ FAJUSTCOOR(013),FAJUSTCOOR(004) To FAJUSTCOOR(064),FAJUSTCOOR(130) LABEL "Ordem de Produção" PIXEL OF oDlgOP

@ FAJUSTCOOR(029),FAJUSTCOOR(028) MSGET oGet1 VAR cGet1 F3 "SC2" Size FAJUSTCOOR(073),FAJUSTCOOR(013)  COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgOP

@ FAJUSTCOOR(070),FAJUSTCOOR(098) BUTTON oOK 		PROMPT "Ok"  	   SIZE 040, 014 ACTION (  Processa( {|| Confirma(@cGet1,oGet1), oGet1:SetFocus() },"Aguarde, Validando os dados...") ) PIXEL OF oDlgOP
@ FAJUSTCOOR(070),FAJUSTCOOR(066) BUTTON oCancel 	PROMPT "Cancelar" SIZE 040, 014 ACTION (oDlgOP:End()) PIXEL OF oDlgOP
//--@ FAJUSTCOOR(082),FAJUSTCOOR(006) SAY "F12 - Parâmetros" PIXEL OF oDlgOP COLORS 12615680, 16777215

oOK:cToolTip 	 := "Inicializa processo de separação"
oOK:SetCss(cEstilo)
oCancel:cToolTip := "Retorna tela anterior"
oCancel:SetCss(cEstilo)
oGet1:bValid 	 := {|| ExistCpo("SC2",cGet1),If(Empty(cGet1),oDlgOP:End(),.t.) }

ACTIVATE MSDIALOG oDlgOP CENTERED
SetKey(VK_F12, Nil)

Return(Nil)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Confirma   ³ Autor ³ Flavio Valentin           ³ Data ³ 04/12/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para confirmacao para iniciar o processo de transferencia.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cGet1 => No. da Ordem de Producao.                               ³±±
±±³          ³ oGet1 => Objeto da tela.                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function Confirma(cGet1,oGet1)
	
	Local lLote    		:= (SuperGetMv("MV_SELPLOT",.F.,"2") == "1")
	Local _lUsaVenc		:= (SuperGetMV('MV_XLOTVEN')=='S')
	Local cArmProd 		:= Alltrim(GetMV("MV_XLOCPRO"))
	Local cArmNo   		:= cArmProd+","+Alltrim(GetMV("MV_LOCPROC"))+","+Alltrim(GetMV("MV_CQ"))+","
	Local cInfoSld 		:= "Os produtos abaixo não possuem saldos 01 " + CRLF
	Local aSldLote 		:= {}
	Local aSSLD02  		:= {}
	Local aTransf  		:= {}
	Local aSemSldo 		:= {}
	Local aParc    		:= {}
	Local aArea    		:= GetArea()
	Local lSemSld  		:= .F.
	Local lSSLD02  		:= .F.
	Local lParcial 		:= .F.
	Local lCont    		:= .F.
	Local i				:= 0
	Local _lSemDados	:= .F.
	Local _aTransfer	:= {}
	Private cEndProd 	:= PADR(GETMV("MV_XENDPRO"),TamSX3("BF_LOCALIZ")[1])

	// Ajusta Ordem
	SB1->(dbSetOrder(1))
	SB2->(dbSetOrder(1))

	// Verifica se existe apontamento de produção
	dbSelectArea("SDC")
	dbSetOrder(2)
	ProcRegua(4)
	// veriifica se componentes possuem saldos em estoque para transferencia.
	dbSelectArea("SD4")
	dbSetOrder(2) //D4_FILIAL, D4_OP, D4_COD, D4_LOCAL, R_E_C_N_O_, D_E_L_E_T_
	If SD4->(MSSeek(xFilial("SD4")+cGet1))
		// Cria um backup do registro, caso não exista
		dbSelectArea("SZ1")
		dbSetOrder(1) //Z1_FILIAL, Z1_COD, Z1_OP, Z1_TRT, Z1_LOTECTL, Z1_NUMLOTE, R_E_C_N_O_, D_E_L_E_T_
		If SZ1->(!MSSeek(xFilial("SZ1")+SD4->(D4_COD+D4_OP+D4_TRT+D4_LOTECTL+D4_NUMLOTE))) 
			If GetNewPar("MV_XGERSZ1",.T.)
				CriaBkp(cGet1)
			EndIf
		EndIf
		// Efetua Validação Processo para Transferência
		aVld     := VldProc(cGet1)
		lSSLD02  := aVld[1]
		lSemSld  := aVld[2]
		cInfoSld := aVld[3]
		aTransf  := aVld[5]
		aSemSldo := aVld[6]
		aSSLD02  := aVld[7]
		
		_lSemDados := Iif(Len(aSSLD02)==0 .And. Len(aTransf)==0,.T.,.F.)
        
		// Localiza Ordem de Produção
			dbSelectArea("SC2")
			dbSetOrder(1) //C2_FILIAL, C2_NUM, C2_ITEM, C2_SEQUEN, C2_ITEMGRD, R_E_C_N_O_, D_E_L_E_T_
			If SC2->(MSSeek(xFilial("SC2")+cGet1))
				If (SC2->C2__SEP == "S") 
					If !_lSemDados
						If !MsgYesNo("Ordem de Produção já separada, deseja verificar saldo parcial?")
						cGet1 := Criavar("D4_OP",.F.)
						oGet1:Refresh()
						Return(.F.)
					
						EndIf
				     Endif 
				ElseIf (SC2->C2_TPOP <> 'F')
					MsgAlert("Não é possivel separar ordem de produção prevista")
					cGet1 := Criavar("D4_OP",.F.)
					oGet1:Refresh()
					Return(.F.)
				EndIf
			Else
				MsgAlert("Ordem de Produção não encontrada")
				Return(.F.)
			EndIf
			
			Begin Transaction
		
		//15.01.2019 - trecho comentado, pois precisa confirmar com o consultor Ivan Rossoni se ignora quando um dos itens da OP nao possui saldo 
		/*If (lSemSld)
			_cMensagem := "Detectado produto(s) sem saldo."
			Alert(_cMensagem)
			cGet1 := Criavar("D4_OP",.F.)
			oGet1:Refresh()
			RestArea(aArea)
			DisarmTransaction()
			Return
		EndIf*/
		
		If (_lSemDados)
			_cMensagem := "O Saldo Total dos itens desta OP já foram Transferidos para a produção"
			Alert(_cMensagem)
			cGet1 := Criavar("D4_OP",.F.)
			oGet1:Refresh()
			RestArea(aArea)
			DisarmTransaction()
			Return
		EndIf
		
		If Len(aSSLD02) > 0
			For i := 1 To Len(aSSLD02)
				aAdd(_aTransfer,{aSSLD02[i][1],aSSLD02[i][2],aSSLD02[i][3],aSSLD02[i][4],aSSLD02[i][5],aSSLD02[i][6],aSSLD02[i][7],aSSLD02[i][8],aSSLD02[i][9],aSSLD02[i][10],aSSLD02[i][11],aSSLD02[i][12],aSSLD02[i][13]})
			Next i
		EndIf
		
		If Len(aTransf) > 0
			For i := 1 To Len(aTransf)
				aAdd(_aTransfer,{aTransf[i][1],aTransf[i][2],aTransf[i][3],aTransf[i][4],aTransf[i][5],aTransf[i][6],aTransf[i][7],aTransf[i][8],aTransf[i][9],aTransf[i][10],aTransf[i][11],aTransf[i][12],aTransf[i][13]})
			Next i
		EndIf
		
		If (Len(_aTransfer) > 0)
			If !ParcExec(_aTransfer,"Transferência p/ Almoxarifado "+Alltrim(GetMV("MV_XLOCPRO")))
				cGet1 := Criavar("D4_OP",.F.)
				oGet1:Refresh()
				RestArea(aArea)
				DisarmTransaction()
				Return
			EndIf
		EndIf
		
		MsgRun("Transferências realizadas com sucesso!!!","Mensagem", {|| Sleep(3000)} )
		
		dbSelectArea("SC2")
		dbSetOrder(1) //C2_FILIAL, C2_NUM, C2_ITEM, C2_SEQUEN, C2_ITEMGRD, R_E_C_N_O_, D_E_L_E_T_
		SC2->(MSSeek(xFilial("SC2")+cGet1))
		While !SC2->(Eof()) .And. Alltrim(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN)==Alltrim(cGet1)
			If Empty(SC2->C2__DTSEP)
				SC2->(RecLock("SC2",.F.))
				SC2->C2__DTSEP := ddatabase
				SC2->C2__SEP   := "S"
				SC2->C2__OPST  := "SE"
				SC2->(MsUnlock())
			EndIf
			SC2->(dbSkip())
		EndDo
		
		//verifica se imprime etiqueta
		/*
		If (nmvpar01 == 1)
			IncProc("Imprimindo etiqueta")
			For i:=1 To Len(aTransf)
				//cod          lote        quant          op
				ppcpf01(aTransf[i,2],aTransf[i,5],aTransf[i,4],aTransf[i,1],cmvpar02,cmvpar03)
			Next
			If (lSemSld)
				For i := 1 To Len(aSemSldo)
					//cod          lote        quant          op
					ppcpf01(aSemSldo[i,2],aSemSldo[i,5],aSemSldo[i,4],aSemSldo[i,1],cmvpar02,cmvpar03)
				Next i
			EndIf
		EndIf
		*/
		
		cGet1 := Criavar("D4_OP",.F.)
		oGet1:Refresh()
		oGet1:SetFocus()

		End Transaction
	EndIf

	RestArea(aArea)

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VldProc    ³ Autor ³ Flavio Valentin           ³ Data ³ 04/12/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que valida Processo Transferencia verificando o saldo e   ³±±
±±³          ³ retornando um array separado Itens para transferencia e Itens    ³±±
±±³          ³ sem saldo.                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aRET => Array separado Itens para transferencia e Itens sem saldo³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function VldProc(pOP)

Local _aAreaSC2		:= SC2->(GetArea())
Local _aAreaSD4		:= SD4->(GetArea())
Local aRET     		:= {Nil,Nil,Nil,Nil,Nil,Nil,Nil}
Local lSemSld  		:= .F.
Local lAjuste  		:= .F.
Local aSldLote 		:= {}
Local aAjuste  		:= {}
Local aTransf  		:= {}
Local aSemSld  		:= {}
Local aSD4SLT  		:= {}
Local aSD402   		:= {}
Local _lUsaVenc 	:= (SuperGetMV('MV_XLOTVEN')=='S')
Local lLote    		:= (SuperGetMv("MV_SELPLOT",.F.,"2") == "1")
Local cArmProd 		:= Alltrim(GetMV("MV_XLOCPRO"))
Local cArmNo   		:= cArmProd+","+Alltrim(GetMV("MV_LOCPROC"))+","+Alltrim(GetMV("MV_CQ"))+","
Local cInfoSld 		:= "Os produtos abaixo não possuem saldos 02 " + CRLF
Local nSaldoPro 	:= 0
Local lRastro		:= .F.
Local _nSalB2        := 0

// Efetua Validação para Saldo e Inconsistências
dbSelectArea("SD4")
dbSetOrder(2) //D4_FILIAL, D4_OP, D4_COD, D4_LOCAL, R_E_C_N_O_, D_E_L_E_T_
SD4->(dbGoTop())
If SD4->(MSSeek(xFilial("SD4")+pOP))
	While (!SD4->(EOF()) .And. xFilial("SD4") == SD4->D4_FILIAL .And. AllTrim(SD4->D4_OP) == AllTrim(pOP))
		
		// Verifico se existe Armazem 02
		A220ATUSB2(SD4->D4_COD,cArmProd)
		// Verifico a existencia de Endereço para Armazem 02
		CriaSBE(cArmProd,cEndProd)
		
		// Posiciona tabelas
		SB1->(dbSetOrder(1))
		SB1->(MSSeek(xFilial('SB1')+SD4->D4_COD))
		
		If SB1->B1_XCONS <> 'S' // Não considera produtos consumíveis conforme e-mail direcionado nesta data 08/04/2019
			
			lRastro  := Rastro(SD4->D4_COD)
			lLocaliz := Localiza(SD4->D4_COD)
			
			If !(SD4->D4_LOCAL $ cArmNo) .And. Substr(SD4->D4_COD,1,3) <> 'MOD'
				
				If !(lRastro) .And. !(lLocaliz)
					//Produtos que na	o tem Lote nem Localização.
					lNecessida	:= .F.
					lConsTerc	:= .F.
					nQtdEmp		:= 0
					nQtdPrj		:= 0
					lSaldoSemR	:= .F.
					
					dbSelectarea("SB2")
					SB2->(dbSetOrder(1))
					If SB2->(MSSeek(xFilial("SB2")+SD4->D4_COD+SD4->D4_LOCAL))
						lSemSld		:= (SB2->B2_QATU < SD4->D4_QUANT) // Informar na tela itens sem saldo
						//Else
						//	lSemSld		:= .T.
						//EndIf
						_nSalB2 := 0
						_nSalB2 += SB2->(SaldoSB2())
						
						/*If _nSalB2 >= 0
							lSemSld := .F.
						Else
							lSemSld := .T.
						Endif*/
						
						If (lSemSld)
							cInfoSld += "PRODUTO: "+SD4->D4_COD+" - "+Alltrim(SB1->B1_DESC)+" LOCAL: "+SD4->D4_LOCAL+" SALDO: "+Alltrim(Str(nSaldoPro))+CRLF
							aAdd(aSemSld,{SD4->D4_OP,SD4->D4_COD,SD4->D4_LOCAL,SD4->D4_QUANT,"","",SD4->D4_QTDEORI,STOD(""),"","",SD4->D4_TRT,SD4->D4_OPORIG,_nSalB2} )
						Else
							aAdd(aTransf,{SD4->D4_OP,SD4->D4_COD,SD4->D4_LOCAL,SD4->D4_QUANT,"","",SD4->D4_QTDEORI,SD4->D4_DTVALID,"","",SD4->D4_TRT,SD4->D4_OPORIG,_nSalB2})
						EndIf
						
					Endif
				Else
					//Despreso os itens que tem OP Origem e ano tem lote preenchido
					If (lRastro) .And. (!Empty(SD4->D4_OPORIG) .And. Empty(SD4->D4_LOTECTL))
						SD4->(dbSkip())
						Loop
					EndIf
					
					If (lRastro) .And. (Empty(SD4->D4_OPORIG) .And. Empty(SD4->D4_LOTECTL))
						cInfoSld += SD4->D4_COD+" "+PADR(SB1->B1_DESC,45)+" SEM LOTE INFORMADO"+CRLF
						aAdd(aSemSld, {SD4->D4_OP,SD4->D4_COD,SD4->D4_LOCAL,SD4->D4_QUANT,SD4->D4_LOTECTL,"" ,SD4->D4_QUANT, SD4->D4_DTVALID,SD4->D4_NUMLOTE, "",SD4->D4_TRT, SD4->D4_OPORIG, nSaldoPro} )
						SD4->(dbSkip())
						Loop
					EndIf
					
					//aAdd(aTransf,{SD4->D4_OP, SD4->D4_COD, SD4->D4_LOCAL, SD4->D4_QUANT, SD4->D4_LOTECTL, SDC->DC_LocalIZ, SDC->DC_QUANT, SD4->D4_DTVALID, SD4->D4_NUMLOTE, SDC->DC_NUMSERI, SD4->D4_TRT, SD4->D4_OPORIG })
					If (lLocaliz)
						// Localizo Composição Produto já empenhado
						If SDC->(MSSeek(xFilial("SDC")+SD4->D4_COD+SD4->D4_LOCAL+SD4->D4_OP+SD4->D4_TRT+SD4->D4_LOTECTL+SD4->D4_NUMLOTE,.F.))
							While SDC->(!Eof()) .And. xFilial("SDC")+SD4->D4_COD+SD4->D4_LOCAL+SD4->D4_OP+SD4->D4_TRT+SD4->D4_LOTECTL+SD4->D4_NUMLOTE==;
								SDC->DC_FILIAL+SDC->DC_PRODUTO+SDC->DC_LOCAL+SDC->DC_OP+SDC->DC_TRT+SDC->DC_LOTECTL+SDC->DC_NUMLOTE
								dbSelectArea("SBF")
								SBF->(dbsetOrder(1))
								If SBF->(MSSeek(xFilial("SBF")+SDC->DC_LOCAL+SDC->DC_LOCALIZ+SDC->DC_PRODUTO+SDC->DC_NUMSERI+SDC->DC_LOTECTL+SDC->DC_NUMLOTE))
									//If SBF->BF_QUANT < SDC->DC_QUANT - Marcelo Rambau
									If ((SBF->BF_QUANT-SBF->BF_EMPENHO)+SDC->DC_QUANT) < SDC->DC_QUANT     //- (SBF->BF_EMPENHO-SDC->DC_QUANT)
										lSemSld		:= .T.
										nSaldoPro	:= 0
									Else
										nSaldoPro	:= SBF->BF_QUANT
										lSemSld		:= (nSaldoPro < SDC->DC_QUANT)
									EndIf
								Else
									lSemSld		:= .T.
									nSaldoPro	:= 0
								EndIf
								If (lSemSld)
									cInfoSld += "PRODUTO: "+SD4->D4_COD+" - "+Alltrim(SB1->B1_DESC)+" LOCAL: "+SD4->D4_LOCAL+" LOTE: "+Alltrim(SDC->DC_LOTECTL)+" ENDERECO: "+Alltrim(SDC->DC_LocalIZ)+" SALDO: "+Alltrim(Str(nSaldoPro))+CRLF
									aAdd(aSemSld,{SD4->D4_OP,SD4->D4_COD,SD4->D4_LOCAL,SDC->DC_QUANT,SD4->D4_LOTECTL,SDC->DC_LOCALIZ,SDC->DC_QUANT,SD4->D4_DTVALID,SD4->D4_NUMLOTE,SDC->DC_NUMSERI,SD4->D4_TRT,SD4->D4_OPORIG,nSaldoPro} )
								Else
									aAdd(aTransf,{SD4->D4_OP,SD4->D4_COD,SD4->D4_LOCAL,SDC->DC_QUANT,SD4->D4_LOTECTL,SDC->DC_LOCALIZ,SDC->DC_QUANT,SD4->D4_DTVALID,SD4->D4_NUMLOTE,SDC->DC_NUMSERI,SD4->D4_TRT,SD4->D4_OPORIG,nSaldoPro })
								EndIf
								
								SDC->(dbSkip())
							EndDo
						Else
							cInfoSld += "PRODUTO: "+SD4->D4_COD+" - "+Alltrim(SB1->B1_DESC)+" Local:"+SD4->D4_LOCAL+" SEM LOTE OU ENDERECO INFORMADO"+CRLF
							aAdd(aSemSld,{SD4->D4_OP,SD4->D4_COD,SD4->D4_LOCAL,SD4->D4_QUANT,SD4->D4_LOTECTL,SDC->DC_LOCALIZ,SDC->DC_QUANT,SD4->D4_DTVALID,SD4->D4_NUMLOTE,SDC->DC_NUMSERI,SD4->D4_TRT,SD4->D4_OPORIG,nSaldoPro} )
						EndIf
					Else
						If (lRastro) .And. (!Empty(SD4->D4_OPORIG) .And. Empty(SD4->D4_LOTECTL))
							SD4->(dbSkip())
							Loop
						EndIf
						dbSelectarea("SB8")
						SB8->(dbSetOrder(1))
						If SB8->(MSSeek(xFilial("SB8")+SD4->D4_COD+SD4->D4_LOCAL+DTOS(SD4->D4_DTVALID)+SD4->D4_LOTECTL,.F.))
							//If SB8->B8_SALDO  < SD4->D4_QUANT //Marcelo Rambau
							If ((SB8->B8_SALDO-SB8->B8_EMPENHO)+SD4->D4_QUANT) < SD4->D4_QUANT //- (SB8->B8_EMPENHO-SD4->D4_QUANT)
								lSemSld		:= .T.
								nSaldoPro	:= 0
							Else
								nSaldoPro	:= SB8->B8_SALDO
								lSemSld		:= (nSaldoPro < SD4->D4_QUANT)
							EndIf
						Else
							lSemSld		:= .T.
							nSaldoPro	:= 0
						EndIf
						If (lSemSld)
							cInfoSld += "PRODUTO: "+SD4->D4_COD+" - "+Alltrim(SB1->B1_DESC)+" LOCAL: "+SD4->D4_LOCAL+" LOTE: "+Alltrim(SD4->D4_LOTECTL)+" SALDO: "+Alltrim(Str(nSaldoPro))+CRLF
							aAdd(aSemSld,{SD4->D4_OP,SD4->D4_COD,SD4->D4_LOCAL,SD4->D4_QUANT,SD4->D4_LOTECTL,,SDC->DC_QUANT,SD4->D4_DTVALID,SD4->D4_NUMLOTE,,SD4->D4_TRT,SD4->D4_OPORIG,nSaldoPro} )
						Else
							aAdd(aTransf,{SD4->D4_OP,SD4->D4_COD,SD4->D4_LOCAL,SD4->D4_QUANT,SD4->D4_LOTECTL,,SD4->D4_QUANT,SD4->D4_DTVALID,SD4->D4_NUMLOTE,,SD4->D4_TRT,SD4->D4_OPORIG,nSaldoPro})
						EndIf
					EndIf
				EndIf
			ElseIf (SD4->D4_LOCAL $ cArmNo) .And. Substr(SD4->D4_COD,1,3) <> 'MOD' .And. Empty(SD4->D4_OPORIG) .And. (Empty(SD4->D4_LOTECTL) .And. lRastro) //Os produtos cadastros neste ambiente nao possuem rastro
				//-----ElseIf (SD4->D4_LOCAL $ cArmNo) .And. Substr(SD4->D4_COD,1,3) <> 'MOD' .And. Empty(SD4->D4_OPORIG) .And. (Empty(SD4->D4_LOTECTL) .And. !(lRastro))
				aAdd(aSD402, {SD4->D4_OP,SD4->D4_COD,SD4->D4_LOCAL,SD4->D4_QUANT,SD4->D4_LOTECTL,"",0, SD4->D4_DTVALID,SD4->D4_NUMLOTE, "",SD4->D4_TRT, SD4->D4_OPORIG, nSaldoPro} )
			EndIf
		Endif
		SD4->(dbSkip())
	EndDo
EndIf
// Retorno Array
aRET[1] := (Len(aSD402)>0)
aRET[2] := (Len(aSemSld)>0)
aRET[3] := cInfoSld
aRET[4] := aClone(aSD4SLT)
aRET[5] := aClone(aTransf)
aRET[6] := aClone(aSemSld)
aRET[7] := aClone(aSD402)

RestArea(_aAreaSC2)
RestArea(_aAreaSD4)

Return(aRET)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VLDPCP02   ³ Autor ³ Flavio Valentin           ³ Data ³ 04/12/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que valida dDatabase com Parametro.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ _lRet => .T./.F.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function VLDPCP02()

Local cDtBloq 	:= SuperGetMV("MV_DBLQMOV", ," ")		//pega a data do parâmetro MV_DBLQMOV
Local cData   	:= dDatabase 							//pega a database do sistema
Local _lRet	  	:= .F.

//se database > parametro, executa a rotina normal, senão trava e exibe mesagem de aviso.
_lRet := (cData > cDtBloq)

If (!_lRet)
	MsgINFO("Problema:" + CRLF +;
	"Não pode ser digitado movimento com data anterior a última data de fechamento (virada de saldos)." + CRLF +;
	"Solução:" + CRLF +;
	"Utilizar data posterior ao último fechamento de estoque (MV_ULMES)/posterior à data do bloqueio de movimentos (MV_DBLQMOV).","AVISO - Ref. VLDPCP02()","OK")
END

Return(_lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FAJUSTCOOR ³ Autor ³ Flavio Valentin           ³ Data ³ 04/12/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que ajusta coordenadas.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nTam => Coordenada a ser ajustada.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ nTam => coordenada ajustada.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function FAJUSTCOOR(nTam)

If nSysHRes == 640
	nTam *= 0.8
ElseIf (nSysHRes == 798) .Or. (nSysHRes == 800)
	nTam *= 1
Else
	nTam *= 1.28
EndIf

If lSysFlat
	nTam *= 0.90
EndIf

Return(INT(nTam))


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PPCPF01    ³ Autor ³ Flavio Valentin           ³ Data ³ 04/12/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para impressao de etiqueta atraves de rotina de           ³±±
±±³          ³ apontamento de transferencia.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCod		=> Codigo do produto;                                   ³±±
±±³          ³ cLote	=> Lote;                                                ³±±
±±³          ³ nqtde	=> Quantidade;                                          ³±±
±±³          ³ cOp		=> No. OP;                                              ³±±
±±³          ³ cObs 	=> Descricao ISO;                                       ³±±
±±³          ³ cPt 		=> Porta.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil.                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function PPCPF01(cCod,cLote,nqtde,cOp,cObs,cPt)
	
Local cResp:=""
Local cFornec,cProd
Local nQtdEti := 1
Local cPorta  := iif(Empty(cPt),"LPT1",Upper(alltrim(cPt)))

cQuery:="SELECT " + CRLF
cQuery+="  B1_DESC, D1_COD, A2_COD, A2_NOME " + CRLF
cQuery+="FROM " + RetSQLName("SD1") + " D1  " + CRLF
cQuery+="  INNER JOIN " + RetSQLName("SA2") + " A2  	" + CRLF
cQuery+="  ON D1_FORNECE = A2_COD AND D1_LOJA = A2_LOJA " + CRLF
cQuery+="  INNER JOIN " + RetSQLName("SB1") + " B1  	" + CRLF
cQuery+="  ON B1_COD = D1_COD AND B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
cQuery+="WHERE D1.D_E_L_E_T_ <> '*' AND A2.D_E_L_E_T_ <> '*'  AND B1.D_E_L_E_T_ <> '*' " + CRLF
cQuery+="  AND D1_TIPO NOT IN ('D','B') " + CRLF
cQuery+="  AND D1_FILIAL = '"+xFilial("SD1")+"' AND A2_FILIAL = '"+xFilial("SA2")+"' " + CRLF
cQuery+="  AND D1_COD = '"+cCod+"' AND D1_LOTECTL = '"+cLote+"' " + CRLF

If Select("TCQ") > 0
	TCQ->(dbCloseArea())
EndIf

TcQuery cQuery new alias "TCQ"
dbSelectArea("TCQ")
TCQ->(dbGotop())

cFornec:=TCQ->A2_COD+" "+ALLTRIM(TCQ->A2_NOME)
cProd  :=TCQ->B1_DESC
Imprime(cCod,cFornec,cProd,cLote,nqtde,cResp,nQtdEti,cOp,cObs,cPorta)

TCQ->( dbClosearea() )

Return(Nil)



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Imprime    ³ Autor ³ Flavio Valentin           ³ Data ³ 04/12/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que imprime a etiqueta.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCod 	=> Codigo do produto;                                   ³±±
±±³          ³ cFornec 	=> Fornecedor;                                          ³±±
±±³          ³ cProd 	=> Descricao do Produto;                                ³±±
±±³          ³ cLote 	=> Lote;                                                ³±±
±±³          ³ nqtde 	=> Quantidade;                                          ³±±
±±³          ³ cResp 	=> Responsavel;                                         ³±±
±±³          ³ nQtdEti 	=> Quantidade de etiquetas;                             ³±±
±±³          ³ cOp 		=> No. OP;                                              ³±±
±±³          ³ cObs 	=> Descricao ISO;                                       ³±±
±±³          ³ cPorta 	=> Porta.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil.                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function Imprime(cCod,cFornec,cProd,cLote,nqtde,cResp,nQtdEti,cOp,cObs,cPorta)

MSCBPRINTER("ALLEGRO","LPT1",Nil,)
MSCBCHKSTATUS(.F.)
MSCBLOADGRF("wem1.pcx")
MSCBBEGIN(nQtdEti,6)
MSCBGRAFIC(005,022,"wem1")

//      XX,YY          // COLUNA (largura), LINHA (altura)
MSCBSAY(40,24,"CODIGO:","N","2","001,001" )
MSCBSAY(59,24,cCod,"N","3","001,001" )

MSCBSAY(05,19,"FORNEC:","N","2","001,001")
MSCBSAY(24,19,subs(cFornec,1,45),"N","3","001,001")

MSCBSAY(05,15,"PROD:","N","2","001,001")
MSCBSAY(24,15,subs(cProd,1,45),"N","3","001,001")

MSCBSAY(05,11,"LOTE:","N","2","001,001")
MSCBSAY(24,11,cLote,"N","3","001,001")

MSCBSAY(05,07,"OP:","N","2","001,001")
MSCBSAY(24,07,cOp,"N","3","001,001")

MSCBSAY(50,07,"QTDE:","N","2","001,001")
MSCBSAY(68,07,ALLTRIM(Transform(nQtde,"@E 99999999.9999")),"N","3","001,001")

MSCBSAY(05,03,"SEPARADO POR: "+alltrim(usrfullname(retcodusr())),"N","3","001,001")

MSCBGRAFIC(15,20,"WEM") //Posiciona o logotipo

MSCBSAY(30,34,cObs,"N","2","002,002")

MSCBEND()
MSCBCLOSEPRINTER()

Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MntEmp     ³ Autor ³ Flavio Valentin           ³ Data ³ 05/12/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao Controle dos  Empenhos.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ paTransf => Array contendo os registros para executar o processo ³±±
±±³          ³ de Controle dos  Empenhos.                                       ³±±
±±³          ³ pnOPC 	=> Operacao                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ _lRet => .T. => Controle dos  Empenhos executada.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function MntEmp(_aAltEmp, pnOPC)

Local aVetor   := {}
Local aEmpen   := {}
Local aTMP     := {}
Local aErrAut  := {}
Local cLocaliz := Criavar('DC_LOCALIZ')
Local nREG     := 0
Local dData    := dDatabase
Local cTRT     := Criavar('D4_TRT')
Local _lRet    := .T.
Local cArmProd := Alltrim(GetMV("MV_XLOCPRO"))
Local _cMsg
Local _nDifEmp := 0
//                  1            2            3             4               5                 6               7                8               9                  10             11          12
//aAdd(aTransf,{SD4->D4_OP, SD4->D4_COD, SD4->D4_LOCAL, SD4->D4_QUANT, SD4->D4_LOTECTL, SDC->DC_LocalIZ, SDC->DC_QUANT, SD4->D4_DTVALID, SD4->D4_NUMLOTE, SDC->DC_NUMSERI, SD4->D4_TRT, SD4->D4_OPORIG })

For nREG := 1 To Len(_aAltEmp)
	
	lRastro  := Rastro(_aAltEmp[nREG][01])
	lLocaliz := Localiza(_aAltEmp[nREG][01])
	
	//Conout(_aAltEmp[nREG][01])
	//Conout(lRastro)
	//Conout(lLocaliz)
	
	lMsErroAuto := .F.
	
	If (pNOPC==4)
		
		//cLocal		:= _aAltEmp[nREG][03]// Assumo o Armazem Original
		//cLocaliz	:= _aAltEmp[nREG][06]
		
		// gera empenho na Origem caso o movimento tenha sido parcial no pagamento da OP
		
		//cTRT := _aAltEmp[nREG][13]
		
		cQryTmp := " SELECT MAX(D4_TRT) ULT_REVISAO "
		cQryTmp += "   FROM " + RetSqlName("SD4") + " SD4"
		cQryTmp += "   WHERE D4_FILIAL = '" + xFilial("SD4") + "'"
		cQryTmp += "   AND SD4.D4_COD  = '" + _aAltEmp[nREG][01] + "'"
		cQryTmp += "   AND SD4.D4_OP = '" + _aAltEmp[nREG][03] + "'"
		//cQryTmp += "   AND SD4.D4_LOCAL = '" + _aAltEmp2[nAlt2][02] + "'"
		
		If Select("TRBREN") <> 0
			dbSelectArea("TRBREN")
			dbCloseArea()
		EndIf
		
		dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQryTmp), "TRBREN" , .T. , .F. )
		
		If !TRBREN->(Eof())
			cTRT := Soma1(TRBREN->ULT_REVISAO)
		Endif
			
		aSavAtu := GetArea()
		aSavSD4 := SD4->(GetArea())
		
		aVetor	:=	{}
		aAdd(aVetor, {"D4_COD"		,_aAltEmp[nREG][01]	,Nil})
		aAdd(aVetor, {"D4_LOCAL"	,_aAltEmp[nREG][02]	,Nil})
		aAdd(aVetor, {"D4_OP"		,_aAltEmp[nREG][03]	,Nil})
		aAdd(aVetor, {"D4_DATA"		,_aAltEmp[nREG][05] ,Nil})
		aAdd(aVetor, {"D4_QTDEORI"	,_aAltEmp[nREG][06]	,Nil})
		aAdd(aVetor, {"D4_QUANT"	,_aAltEmp[nREG][06]	,Nil})
		aAdd(aVetor, {"D4_OPORIG"	,_aAltEmp[nREG][07]	,Nil})
		If (lRastro)
			aAdd(aVetor, {"D4_LOTECTL"	,_aAltEmp[nREG][08]	,Nil})
			aAdd(aVetor, {"D4_NUMLOTE"	,_aAltEmp[nREG][09]	,NIL})
			aAdd(aVetor, {"D4_DTVALID"	,_aAltEmp[nREG][10]	,NIL})
			////Conout("Empenhando Lote: "+_aAltEmp[nREG][05])
		EndIf
		aAdd(aVetor, {"D4_TRT"		,_aAltEmp[nREG][13] ,Nil})
		aAdd(aVetor, {"D4_QTSEGUM"	,0             		,Nil})
		aAdd(aVetor, {"ZERAEMP"     ,"S",NIL})
		
		MSExecAuto( { |x,y,z| mata380(x,y,z)}, aVetor,pnOpc, aEmpen)
		
		If (lMsErroAuto)
			MostraErro()
			Return(.F.)
		EndIf
		
		DbSelectArea("SD4")
		DbSetOrder(1)         //D4_FILIAL, D4_COD,            D4_OP, D4_TRT, D4_LOTECTL, D4_NUMLOTE, R_E_C_N_O_, D_E_L_E_T_
		If SD4->(MSSeek(xFilial("SD4")+_aAltEmp[nREG][01]+_aAltEmp[nREG][03]+_aAltEmp[nREG][13]+_aAltEmp[nREG][08]+_aAltEmp[nREG][09]))
		
			//cTRT := Soma1(cTRT)
			cUpdSd4a := " DELETE FROM "+RetSqlName("SD4")
			cUpdSd4a += " WHERE D_E_L_E_T_= ' ' AND D4_OP= '"+SD4->D4_OP+"' AND D4_LOTECTL = '"+ SD4->D4_LOTECTL+"' AND D4_LOCAL = '"+SD4->D4_LOCAL+"' AND D4_COD = '"+SD4->D4_COD+"'  "
			cUpdSd4a += " AND D4_QUANT = 0 "
			TCSQLEXEC(cUpdSd4a)
			
		Endif
		
		_nDifEmp := _aAltEmp[nREG][06] - _aAltEmp[nREG][04]
				
		aVetor	:=	{}
		aAdd(aVetor, {"D4_COD"		,_aAltEmp[nREG][01]	,Nil})
		aAdd(aVetor, {"D4_LOCAL"	,_aAltEmp[nREG][02]	,Nil})
		aAdd(aVetor, {"D4_OP"		,_aAltEmp[nREG][03]	,Nil})
		aAdd(aVetor, {"D4_DATA"		,dDataBase ,Nil})
		aAdd(aVetor, {"D4_QTDEORI"	,_nDifEmp	,Nil})
		aAdd(aVetor, {"D4_QUANT"	,_nDifEmp	,Nil})
		aAdd(aVetor, {"D4_OPORIG"	,_aAltEmp[nREG][07]	,Nil})
		If (lRastro)
			aAdd(aVetor, {"D4_LOTECTL"	,_aAltEmp[nREG][08]	,Nil})
			aAdd(aVetor, {"D4_NUMLOTE"	,Criavar('D4_NUMLOTE')	,NIL})
			aAdd(aVetor, {"D4_DTVALID"	,_aAltEmp[nREG][10]	,NIL})
			////Conout("Empenhando Lote: ",_aAltEmp[nREG][05])
		EndIf
		aAdd(aVetor, {"D4_TRT"		,cTRT				,Nil})
		aAdd(aVetor, {"D4_QTSEGUM"	,0             		,Nil})
		
		If (lLocaliz)
			If !Empty(_aAltEmp[nREG][11])
				aAdd(aEmpen,{_nDifEmp,;   		// SD4->D4_QUANT
			    _aAltEmp[nREG][11],;   // DC_LocalIZ         - paTransf[nREG][06]
				_aAltEmp[nREG][12],;   	// DC_NUMSERI
				0               ,;    	// D4_QTSEGUM
				0               ,;    	// D4_QTSEGUM
				.F.})
				//Conout("Empenhando Endereco: "+cLocaliz)
			EndIf
		EndIf
		
		//Conout("Linha Empenho ")
		//Conout(pnOpc)
		//Conout("*****")
		//Conout(Alltrim(Str(nREG)))
		//Conout(_aAltEmp[nREG][02])
		//Conout(cLocal)
		//Conout(_aAltEmp[nREG][05])
		//Conout(Alltrim(Str(_aAltEmp[nREG][04])))
		
		//cMostra := "Linha do Array: "+Alltrim(Str(nREG))+" Produto: "+_aAltEmp[nREG][02]+" Local: "+cLocal+" Lote: "+_aAltEmp[nREG][05]+" Qtde.: "+Alltrim(Str(_aAltEmp[nREG][04]))
		//Conout(//cMostra)
		
		MSExecAuto( { |x,y,z| mata380(x,y,z)}, aVetor,3, aEmpen)
		
		If (lMsErroAuto)
			MostraErro()
			Return(.F.)
		EndIf
		
	EndIf
	
	_nDifEmp := 0		
	aEmpen   := {}
	
Next

Return(.T.)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ZerEmp     ³ Autor ³ Flavio Valentin           ³ Data ³ 05/12/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao Controle dos  Empenhos.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ paTransf => Array contendo os registros para executar o processo ³±±
±±³          ³ de Controle dos  Empenhos.                                       ³±±
±±³          ³ pnOPC 	=> Operacao                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ _lRet => .T. => Controle dos  Empenhos executada.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function ZerEmp(_aZerEmp, pnOPC)

Local aVetor   := {}
Local aEmpen   := {}
Local aTMP     := {}
Local aErrAut  := {}
Local cLocaliz := Criavar('DC_LOCALIZ')
Local nREG     := 0
Local dData    := dDatabase
Local cTRT     := Criavar('D4_TRT')
Local _lRet    := .T.
Local cArmProd := Alltrim(GetMV("MV_XLOCPRO"))
Local _cMsg
Local _nDifEmp := 0
//                  1            2            3             4               5                 6               7                8               9                  10             11          12
//aAdd(aTransf,{SD4->D4_OP, SD4->D4_COD, SD4->D4_LOCAL, SD4->D4_QUANT, SD4->D4_LOTECTL, SDC->DC_LocalIZ, SDC->DC_QUANT, SD4->D4_DTVALID, SD4->D4_NUMLOTE, SDC->DC_NUMSERI, SD4->D4_TRT, SD4->D4_OPORIG })

For nREG := 1 To Len(_aZerEmp)
	
	lRastro  := Rastro(_aZerEmp[nREG][01])
	lLocaliz := Localiza(_aZerEmp[nREG][01])
	
	//Conout(_aZerEmp[nREG][01])
	//Conout(lRastro)
	//Conout(lLocaliz)
	
	lMsErroAuto := .F.
	
	aEmpen   := {}
	
	If (pNOPC==4)
		
		//cLocal		:= _aZerEmp[nREG][03]// Assumo o Armazem Original
		//cLocaliz	:= _aZerEmp[nREG][08]
		
		// gera empenho na Origem caso o movimento tenha sido parcial no pagamento da OP
		
		//cTRT := _aZerEmp[nREG][09]
		
		aSavAtu := GetArea()
		aSavSD4 := SD4->(GetArea())
		
		aVetor	:=	{}
		aAdd(aVetor, {"D4_COD"		,_aZerEmp[nREG][01]	,Nil})
		aAdd(aVetor, {"D4_LOCAL"	,_aZerEmp[nREG][02] ,Nil})
		aAdd(aVetor, {"D4_OP"		,_aZerEmp[nREG][03]	,Nil})
		aAdd(aVetor, {"D4_DATA"		,_aZerEmp[nREG][05] ,Nil})
		aAdd(aVetor, {"D4_QTDEORI"	,_aZerEmp[nREG][06]	,Nil})
		aAdd(aVetor, {"D4_QUANT"	,_aZerEmp[nREG][04]	,Nil})
		aAdd(aVetor, {"D4_OPORIG"	,_aZerEmp[nREG][07]	,Nil})
		If (lRastro)
			aAdd(aVetor, {"D4_LOTECTL"	,_aZerEmp[nREG][08]	,Nil})
			aAdd(aVetor, {"D4_NUMLOTE"	,_aZerEmp[nREG][09]	,NIL})
			aAdd(aVetor, {"D4_DTVALID"	,_aZerEmp[nREG][10]	,NIL})
			////Conout("Empenhando Lote: "+ _aZerEmp[nREG][08])
		EndIf
		aAdd(aVetor, {"D4_TRT"		,_aZerEmp[nREG][13]	   ,Nil})
		aAdd(aVetor, {"D4_QTSEGUM"	,0             	 	   ,Nil})
		aAdd(aVetor, {"ZERAEMP"     ,"S",NIL})
		
		////Conout("Linha Empenho ")
		////Conout(pnOpc)
		////Conout("*****")
		////Conout(Alltrim(Str(nREG)))
		////Conout(_aZerEmp[nREG][02])
		////Conout(cLocal)
		////Conout(_aZerEmp[nREG][05])
		////Conout(Alltrim(Str(_aZerEmp[nREG][04])))
		
		////cMostra := "Linha do Array: "+Alltrim(Str(nREG))+" Produto: "+_aZerEmp[nREG][02]+" Local: "+cLocal+" Lote: "+_aZerEmp[nREG][05]+" Qtde.: "+Alltrim(Str(_aZerEmp[nREG][04]))
		////Conout(//cMostra)
		
		MSExecAuto( { |x,y,z| mata380(x,y,z)}, aVetor,pnOpc, aEmpen)
		
		If (lMsErroAuto)
			MostraErro()
			Return(.F.)
		EndIf
		
		RestArea(aSavSD4)
		RestArea(aSavAtu)
		
	EndIf
	
Next

For nREG := 1 To Len(_aZerEmp)
	
	DbSelectArea("SD4")
	DbSetOrder(1) //D4_FILIAL,            D4_COD,            D4_OP,             D4_TRT,           D4_LOTECTL,      D4_NUMLOTE, R_E_C_N_O_, D_E_L_E_T_
	If SD4->(MSSeek(xFilial("SD4")+_aZerEmp[nREG][01]+_aZerEmp[nREG][03]+_aZerEmp[nREG][13]+_aZerEmp[nREG][08]+_aZerEmp[nREG][09]))
		cUpdSd4a := " DELETE FROM "+RetSqlName("SD4")
		cUpdSd4a += " WHERE D_E_L_E_T_= ' ' AND D4_OP= '"+SD4->D4_OP+"' AND D4_LOTECTL = '"+ SD4->D4_LOTECTL+"' AND D4_LOCAL = '"+SD4->D4_LOCAL+"' AND D4_COD = '"+SD4->D4_COD+"'  "
		cUpdSd4a += " AND D4_QUANT = 0 "
		TCSQLEXEC(cUpdSd4a)
		
	Endif
	
Next

Return(.T.)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TransArm   ³ Autor ³ Flavio Valentin           ³ Data ³ 05/12/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao TransFerencia Armazem.                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ paTransf => Array contendo os registros para executar o processo ³±±
±±³          ³ de transferencia de saldo.                                       ³±±
±±³          ³ pnOPC 	=> Operacao                                             ³±±
±±³          ³ plSemSld	=> .T. (Sem saldo).                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ _lRet => .T. => Transferencia executada.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function TransArm(paTransf, pnOPC, plSemSld)

Local cProd		:= ""
Local cUM		:= ""
Local cLocal	:= ""
Local cDoc		:= ""
Local cLote		:= ""
Local cNumLot	:= ""
Local cLocaliz	:= Criavar("D3_LOCALIZ")
Local cLocDest	:= cEndProd
Local dDatVal	:= ""
Local nQuant	:= 0
Local lOk		:= .F.
Local aItem		:= {}
Local aAuto		:= {}
Local nOpcAuto	:= 3
Local cArmProd	:= Alltrim(GetMV("MV_XLOCPRO"))
Local _lRet		:= .T.
Local nREG
Local cOPTra	:= ""

Default plSemSld := .F.

DbSelectArea("SB1")
dbSetOrder(1)

lMsErroAuto := .F.

//Conout("Iniciando Transferencias")
For nREG := 1 To Len(paTransf)
	
	If SB1->(MsSeek(xFilial("SB1")+paTransf[nREG][1]))
		cProd 	:= SB1->B1_COD
		cDescri	:= SB1->B1_DESC
		cUM 	:= SB1->B1_UM
		//cLocal	:= SB1->B1_LOCPAD   //ADICIONADO TEMPORARI 14/08
		//                  1            2            3             4               5                 6               7                8               9                  10             11          12
		//		SD4->D4_OP, SD4->D4_COD, SD4->D4_LOCAL, SD4->D4_QUANT, SD4->D4_LOTECTL, SDC->DC_LocalIZ, SDC->DC_QUANT, SD4->D4_DTVALID, SD4->D4_NUMLOTE, SDC->DC_NUMSERI, SD4->D4_TRT, SD4->D4_OPORIG })
		cLocaliz 	:= If(Empty(paTransf[nREG][11]),Criavar('DC_LOCALIZ'),paTransf[nREG][11])
		cLocDest	:= cEndProd
		cNumSeri 	:= If(Empty(paTransf[nREG][12]),Criavar('DC_NUMSERI'),paTransf[nREG][12])
		cLote		:= If(Empty(paTransf[nREG][08]),Criavar('D4_LOTECTL'),paTransf[nREG][08])
		dDataVl		:= If(Empty(paTransf[nREG][10]),Criavar('D4_DTVALID'),paTransf[nREG][10])
		cNumLot  	:= If(Empty(paTransf[nREG][09]),Criavar('D4_NUMLOTE'),paTransf[nREG][09])
		nQuant		:= If(Empty(paTransf[nREG][04]),Criavar('DC_QUANT'), paTransf[nREG][04])
		cOPTra		:= If(Empty(paTransf[nREG][03]),"", paTransf[nREG][03])
		cLocal		:= If(Empty(paTransf[nREG][02]),Criavar('D4_LOCAL'), paTransf[nREG][02])
		
		cDoc		:= GetSxENum("SD3","D3_DOC")
		CONFIRMSX8()
		
		If Len(aAuto) == 0
			aAdd(aAuto, {cDoc, dDataBase} )
		EndIf
		
		// Localizacao Destino
		If (plSemSld)
			cLocDest := Criavar('DC_LOCALIZ')
		EndIf
		
		aAdd(aItem,{"D3_COD"		,cProd					,Nil})	//D3_COD ORIGEM ***
		aAdd(aItem,{"D3_DESCRI"		,cDescri				,Nil})	//D3_DESCRI ORIGEM
		aAdd(aItem,{"D3_UM"			,cUM					,Nil})	//D3_UM ORIGEM
		aAdd(aItem,{"D3_LOCAL"		,cLocal					,Nil})	//D3_Local ORIGEM
		aAdd(aItem,{"D3_LOCALIZ"	,cLocaliz				,Nil})	//D3_LocalIZ ORIGEM
		aAdd(aItem,{"D3_COD"		,cProd					,Nil})	//D3_COD DESTINO ***
		aAdd(aItem,{"D3_DESCRI"		,cDescri				,Nil})	//D3_DESCRI DESTINO
		aAdd(aItem,{"D3_UM"			,cUM					,Nil})	//D3_UM DESTIBNO
		aAdd(aItem,{"D3_LOCAL"		,cArmProd				,Nil})	//D3_Local DESTINO
		aAdd(aItem,{"D3_LOCALIZ"	,cLocDest				,Nil})	//D3_LocalIZ DESTINO
		aAdd(aItem,{"D3_NUMSERI"	,cNumSeri				,Nil})	//D3_NUMSERI
		aAdd(aItem,{"D3_LOTECTL"	,cLote					,Nil})	//D3_LOTECTL
		aAdd(aItem,{"D3_NUMLOTE"	,cNumLot				,Nil})	//D3_NUMLOTE
		aAdd(aItem,{"D3_DTVALID"	,dDataVl				,Nil})	//D3_DTVALID
		aAdd(aItem,{"D3_POTENCI"	,Criavar("D3_POTENCI")	,Nil})	//D3_POTENCI
		aAdd(aItem,{"D3_QUANT"		,nQuant					,Nil})	//D3_QUANT
		aAdd(aItem,{"D3_QTSEGUM"	,Criavar("D3_QTSEGUM")	,Nil})	//D3_QTSEGUM
		aAdd(aItem,{"D3_ESTORNO"	,Criavar("D3_ESTORNO")	,Nil})  //D3_ESTORNO
		aAdd(aItem,{"D3_NUMSEQ"		,Criavar("D3_NUMSEQ")	,Nil})  //D3_NUMSEQ
		aAdd(aItem,{"D3_LOTECTL"	,Criavar("D3_LOTECTL")	,Nil}) 	//D3_LOTECTL   - cLote
		aAdd(aItem,{"D3_DTVALID"	,dDataVl				,Nil})	//D3_DTVALID
		aAdd(aItem,{"D3_ITEMGRD"	,Criavar("D3_ITEMGRD")	,Nil})	//D3_ITEMGRD
		aAdd(aItem,{"D3_OBS"		,Criavar("D3_OBS")		,Nil})	//D3_OBS
		aAdd(aItem,{"D3_OPTRA"		,cOPTra					,Nil})	//D3_OPTRA
		aAdd(aAuto,aItem)
		aItem := {}
		
		//Conout("Linha de Transferencia")
		//Conout(cProd)
		//Conout(cDescri)
		//Conout(cUM)
		//Conout(cLocal)
		//Conout(cLocaliz)
		//Conout(cArmProd)
		//Conout(cLocDest)
		//Conout(cNumSeri)
		//Conout(cNumLot)
		//Conout(nQuant)
		//Conout(dDataVl)
	EndIf
	
Next
If Len(aAuto) > 0
	lMsErroAuto := .F.
	MSExecAuto( { |x,y| mata261(x,y) }, aAuto, 3)
	If (lMsErroAuto)
		MostraErro()
		_lRet := .F.
	Else
		cDoc  := Soma1(cDoc,TamSX3("D3_DOC")[1])
		aAuto := {}
		_lRet  := .T.
	EndIf
EndIf

Return(_lRet)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MntEmp     ³ Autor ³ Flavio Valentin           ³ Data ³ 05/12/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao Controle dos  Empenhos.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ paTransf => Array contendo os registros para executar o processo ³±±
±±³          ³ de Controle dos  Empenhos.                                       ³±±
±±³          ³ pnOPC 	=> Operacao                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ _lRet => .T. => Controle dos  Empenhos executada.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function GerEmp(paTransf, pnOPC)

Local aVetor   := {}
Local aEmpen   := {}
Local aTMP     := {}
Local aErrAut  := {}
Local cLocaliz := Criavar('DC_LOCALIZ')
Local nREG     := 0
Local dData    := dDatabase
Local cTRT     := Criavar('D4_TRT')
Local _lRet    := .T.
Local cArmProd := Alltrim(GetMV("MV_XLOCPRO"))
Local _cMsg
Local _nDifEmp := 0
//                  1            2            3             4               5                 6               7                8               9                  10             11          12
//aAdd(aTransf,{SD4->D4_OP, SD4->D4_COD, SD4->D4_LOCAL, SD4->D4_QUANT, SD4->D4_LOTECTL, SDC->DC_LocalIZ, SDC->DC_QUANT, SD4->D4_DTVALID, SD4->D4_NUMLOTE, SDC->DC_NUMSERI, SD4->D4_TRT, SD4->D4_OPORIG })

For nREG := 1 To Len(paTransf)
	
	lRastro  := Rastro(paTransf[nREG][01])
	lLocaliz := Localiza(paTransf[nREG][01])
	
	//Conout(paTransf[nREG][01])
	//Conout(lRastro)
	//Conout(lLocaliz)
	
	lMsErroAuto := .F.
	
	If (pNOPC==4)
		cLocal		:= paTransf[nREG][02]// Assumo o Armazem Original
		cLocaliz	:= paTransf[nREG][11]
		
		// gera empenho na Origem caso o movimento tenha sido parcial no pagamento da OP
		
		_nDifEmp := paTransf[nREG][06] - paTransf[nREG][04]
		
		If _nDifEmp > 0 .OR. !Empty(paTransf[nREG][08])
			
			cTRT := paTransf[nREG][11]
			
			aSavAtu := GetArea()
			aSavSD4 := SD4->(GetArea())
			
			lAchou  := .T.
			dbSelectArea("SD4")
			dbSetOrder(1) //D4_FILIAL+D4_COD+D4_OP+D4_TRT
			While (lAchou)
				If SD4->(MSSeek(xFilial("SD4")+paTransf[nREG][01]+paTransf[nREG][03]+cTRT))
					cTRT := Soma1(cTRT)
				Else
					lAchou := .F.
				EndIf
			EndDo
			
			RestArea(aSavSD4)
			RestArea(aSavAtu)
			
			aVetor	:=	{}
			aAdd(aVetor, {"D4_COD"		,paTransf[nREG][01]	,Nil})
			aAdd(aVetor, {"D4_LOCAL"	,cLocal				,Nil})
			aAdd(aVetor, {"D4_OP"		,paTransf[nREG][03]	,Nil})
			aAdd(aVetor, {"D4_DATA"		,dDatabase   		,Nil})
			aAdd(aVetor, {"D4_QTDEORI"	,_nDifEmp	,Nil})
			aAdd(aVetor, {"D4_QUANT"	,_nDifEmp	,Nil})
			aAdd(aVetor, {"D4_OPORIG"	,paTransf[nREG][07]	,Nil})
			If (lRastro)
				aAdd(aVetor, {"D4_LOTECTL"	,paTransf[nREG][08]	,Nil})
				aAdd(aVetor, {"D4_NUMLOTE"	,paTransf[nREG][09]	,NIL})
				aAdd(aVetor, {"D4_DTVALID"	,paTransf[nREG][10]	,NIL})
				////Conout("Empenhando Lote: "+paTransf[nREG][05])
			EndIf
			aAdd(aVetor, {"D4_TRT"		,cTRT				,Nil})
			aAdd(aVetor, {"D4_QTSEGUM"	,0             		,Nil})
			
			If (pNOPC==4)
				
				aSavAtu := GetArea()
				aSavSD4 := SD4->(GetArea())
				
				//Para exclusao, verifico se o item ja foi excluido, necessario quando o mesmo SD4 tem mais de um endereço selecionado
				dbSelectArea("SD4")
				dbSetOrder(2)
				If !SD4->(MSSeek(xFilial("SD4")+paTransf[nREG][01]+paTransf[nREG][03]+cLocal))
					RestArea(aSavSD4)
					RestArea(aSavAtu)
					Loop
				EndIf
				
				RestArea(aSavSD4)
				RestArea(aSavAtu)
			EndIf
			
			If (lLocaliz)
				If !Empty(paTransf[nREG][06])
					aAdd(aEmpen,{   _nDifEmp,;   		// SD4->D4_QUANT
					cLocaliz,;   			// DC_LocalIZ         - paTransf[nREG][06]
					paTransf[nREG][12],;   	// DC_NUMSERI
					0               ,;    	// D4_QTSEGUM
					0               ,;    	// D4_QTSEGUM
					.F.})
					////Conout("Empenhando Endereco: "+cLocaliz)
				EndIf
			EndIf
			
			////Conout("Linha Empenho ")
			////Conout(pnOpc)
			////Conout("*****")
			////Conout(Alltrim(Str(nREG)))
			////Conout(paTransf[nREG][02])
			////Conout(cLocal)
			////Conout(paTransf[nREG][05])
			////Conout(Alltrim(Str(paTransf[nREG][04])))
			
			////cMostra := "Linha do Array: "+Alltrim(Str(nREG))+" Produto: "+paTransf[nREG][02]+" Local: "+cLocal+" Lote: "+paTransf[nREG][05]+" Qtde.: "+Alltrim(Str(paTransf[nREG][04]))
			////Conout(//cMostra)
			
			MSExecAuto( { |x,y,z| mata380(x,y,z)}, aVetor,pnOpc, aEmpen)
			
			If (lMsErroAuto)
				MostraErro()
				Return(.F.)
			EndIf
			
		Endif
		
	Else
		cLocal		:= cArmProd		// Altero para Armazem Destino - 02
		cLocaliz	:= cEndProd		// Busco Endereço Destino
	EndIf
	
	//Anderson Messias - Devido a um erro no Mata380, verifico se o TRT da Filial+Cod+OP+TRT ja existe na SD4, se existir Somo um no trt e teste novamente.
	cTRT := paTransf[nREG][13]
	If (pNOPC==3)
		
		aSavAtu := GetArea()
		aSavSD4 := SD4->(GetArea())
		
		lAchou  := .T.
		dbSelectArea("SD4")
		dbSetOrder(1) //D4_FILIAL+D4_COD+D4_OP+D4_TRT
		While (lAchou)
			If SD4->(MSSeek(xFilial("SD4")+paTransf[nREG][01]+paTransf[nREG][03]+cTRT))
				cTRT := Soma1(cTRT)
			Else
				lAchou := .F.
			EndIf
		EndDo
		
		RestArea(aSavSD4)
		RestArea(aSavAtu)
	EndIf
	
	aVetor	:=	{}
	aAdd(aVetor, {"D4_COD"		,paTransf[nREG][01]	,Nil})
	aAdd(aVetor, {"D4_LOCAL"	,cLocal				,Nil})
	aAdd(aVetor, {"D4_OP"		,paTransf[nREG][03]	,Nil})
	aAdd(aVetor, {"D4_DATA"		,dDatabase   		,Nil})
	aAdd(aVetor, {"D4_QTDEORI"	,paTransf[nREG][04]	,Nil})
	aAdd(aVetor, {"D4_QUANT"	,paTransf[nREG][04]	,Nil})
	aAdd(aVetor, {"D4_OPORIG"	,paTransf[nREG][07]	,Nil})
	If (lRastro)
		aAdd(aVetor, {"D4_LOTECTL"	,paTransf[nREG][08]	,Nil})
		aAdd(aVetor, {"D4_NUMLOTE"	,paTransf[nREG][09]	,NIL})
		aAdd(aVetor, {"D4_DTVALID"	,paTransf[nREG][10]	,NIL})
		////Conout("Empenhando Lote: "+paTransf[nREG][05])
	EndIf
	aAdd(aVetor, {"D4_TRT"		,cTRT				,Nil})
	aAdd(aVetor, {"D4_QTSEGUM"	,0             		,Nil})
	
	If (pNOPC==5)
		
		aSavAtu := GetArea()
		aSavSD4 := SD4->(GetArea())
		
		//Para exclusao, verifico se o item ja foi excluido, necessario quando o mesmo SD4 tem mais de um endereço selecionado
		dbSelectArea("SD4")
		dbSetOrder(2)
		If !SD4->(MSSeek(xFilial("SD4")+paTransf[nREG][01]+paTransf[nREG][03]+cLocal))
			RestArea(aSavSD4)
			RestArea(aSavAtu)
			Loop
		EndIf
		
		RestArea(aSavSD4)
		RestArea(aSavAtu)
	EndIf
	
	//If (pNOPC<>5)
	If (lLocaliz)
		If !Empty(paTransf[nREG][11])
			aAdd(aEmpen,{   paTransf[nREG][04],;   		// SD4->D4_QUANT
			cLocaliz,;   			// DC_LocalIZ         - paTransf[nREG][06]
			paTransf[nREG][12],;   	// DC_NUMSERI
			0               ,;    	// D4_QTSEGUM
			.F.})
			////Conout("Empenhando Endereco: "+cLocaliz)
		EndIf
	EndIf
	//EndIf
	
	////Conout("Linha Empenho ")
	////Conout(pnOpc)
	////Conout("*****")
	////Conout(Alltrim(Str(nREG)))
	////Conout(paTransf[nREG][02])
	////Conout(cLocal)
	////Conout(paTransf[nREG][05])
	////Conout(Alltrim(Str(paTransf[nREG][04])))
	
	////cMostra := "Linha do Array: "+Alltrim(Str(nREG))+" Produto: "+paTransf[nREG][02]+" Local: "+cLocal+" Lote: "+paTransf[nREG][05]+" Qtde.: "+Alltrim(Str(paTransf[nREG][04]))
	////Conout(//cMostra)
	
	MSExecAuto( { |x,y,z| mata380(x,y,z)}, aVetor, pnOpc, aEmpen)
	
	If (lMsErroAuto)
		MostraErro()
		Return(.F.)
	EndIf
	aEmpen   := {}
Next

Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ParcExec   ³ Autor ³ Flavio Valentin           ³ Data ³ 05/12/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao Monta tela apresentando produtos sem saldo.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ paSSLD02 => Array contendo os registros para executar o processo ³±±
±±³          ³ sem saldo.                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ _lRet => Validacao ().T./.F.)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function ParcExec(paSSLD02, cTitulo)

Local _lRet 	:= .F.
Local oBtCancel
Local oBtOk
Local oFGet		:= TFont():New("MS Sans Serif",,016,,.T.,,,,,.F.,.F.)
Local oFTitulo	:= TFont():New("MS Sans Serif",,022,,.T.,,,,,.F.,.F.)
Local oGOp
Local oGrp
Local oPanel
Local oSay1
Local oSOp
//--Local _cTit	:= "Transferência Parcial"
Local _cTit		:= cTitulo

Private aColsEx	:= {}
Private cGOp 	:= paSSLD02[1][1]

Private cProdu   := ""
Private dDemi    := ""
Private nQtde    := 0
Private oDlgOP2

DbSelectArea("SC2")
DbSetOrder(1)//C2_FILIAL, C2_NUM, C2_ITEM, C2_SEQUEN, C2_ITEMGRD, R_E_C_N_O_, D_E_L_E_T_
SC2->(MSSeek(xFilial("SC2")+Substr(cGOp,1,6)+Substr(cGOp,7,2)+Substr(cGOp,9,3)))

dDemi := SC2->C2_EMISSAO
nQtde := SC2->C2_QUANT

DbSelectArea("SB1")
DbSetOrder(1)//C2_FILIAL, C2_NUM, C2_ITEM, C2_SEQUEN, C2_ITEMGRD, R_E_C_N_O_, D_E_L_E_T_
SB1->(MSSeek(xFilial("SB1")+SC2->C2_PRODUTO))

cProdu := SB1->B1_COD+" - "+ SB1->B1_DESC

SetKey( VK_F4, { || u_ShowF3() } )

DEFINE MSDIALOG oDlgOP2 TITLE _cTit FROM FAJUSTCOOR(10), FAJUSTCOOR(100)  To FAJUSTCOOR(400), FAJUSTCOOR(800) COLORS 0, 16777215 PIXEL

@ FAJUSTCOOR(004), FAJUSTCOOR(004) MSPANEL oPanel SIZE FAJUSTCOOR(520), FAJUSTCOOR(213) OF oDlgOP2   COLORS 0, 16777215 RAISED
@ FAJUSTCOOR(015), FAJUSTCOOR(007) GROUP oGrp To FAJUSTCOOR(047), FAJUSTCOOR(339) OF oPanel COLOR  0, 16777215 PIXEL
@ FAJUSTCOOR(017), FAJUSTCOOR(014) SAY oSOp PROMPT "Numero Op:" SIZE FAJUSTCOOR(033), FAJUSTCOOR(007) OF oPanel COLORS 0, 16777215 PIXEL
@ FAJUSTCOOR(017), FAJUSTCOOR(120) SAY oProdu PROMPT "Produto:" SIZE FAJUSTCOOR(033), FAJUSTCOOR(007) OF oPanel COLORS 0, 16777215 PIXEL
@ FAJUSTCOOR(033), FAJUSTCOOR(014) SAY oDemi PROMPT "Data Emissao:" SIZE FAJUSTCOOR(033), FAJUSTCOOR(007) OF oPanel COLORS 0, 16777215 PIXEL
@ FAJUSTCOOR(033), FAJUSTCOOR(120) SAY oQtde PROMPT "Quantidade:" SIZE FAJUSTCOOR(033), FAJUSTCOOR(007) OF oPanel COLORS 0, 16777215 PIXEL

fBrwSld(paSSLD02, oPanel)

@ FAJUSTCOOR(016), FAJUSTCOOR(040) MSGET oGOp VAR cGOp SIZE FAJUSTCOOR(060), FAJUSTCOOR(010) OF oPanel COLORS 255, 16777215 FONT oFGet READONLY PIXEL
@ FAJUSTCOOR(016), FAJUSTCOOR(145) MSGET oProdu VAR cProdu SIZE FAJUSTCOOR(190), FAJUSTCOOR(010) OF oPanel COLORS 255, 16777215 FONT oFGet READONLY PIXEL
@ FAJUSTCOOR(032), FAJUSTCOOR(040) MSGET oDemi VAR dDemi SIZE FAJUSTCOOR(060), FAJUSTCOOR(010) OF oPanel COLORS 255, 16777215 FONT oFGet READONLY PIXEL
@ FAJUSTCOOR(032), FAJUSTCOOR(145) MSGET oQtde VAR nQtde PICTURE "@E 999,999,999.99" SIZE FAJUSTCOOR(060), FAJUSTCOOR(010) OF oPanel COLORS 255, 16777215 FONT oFGet READONLY PIXEL
@ FAJUSTCOOR(006), FAJUSTCOOR(126) SAY oSay1 PROMPT _cTit SIZE FAJUSTCOOR(104), FAJUSTCOOR(010)  FONT oFTitulo COLORS 16711680, 16777215  OF oPanel	PIXEL
@ FAJUSTCOOR(175), FAJUSTCOOR(044) BUTTON oBtOk PROMPT "Ok" SIZE FAJUSTCOOR(037), FAJUSTCOOR(015)  ACTION ( PROCESSA( { || Iif(u_PERFVLNGRD(2),OkTraParc(paSSLD02, @_lRet),_lRet := .F.),oDlgOP2:End() },"Processando Movimentações") ) OF oDlgOP2 	PIXEL
@ FAJUSTCOOR(175), FAJUSTCOOR(085) BUTTON oBtExcel PROMPT "Excel" SIZE FAJUSTCOOR(037), FAJUSTCOOR(015)  ACTION ( PROCESSA( { || Iif(u_PERFVLNGRD(2),OkExcel(),_lRet := .F.),oDlgOP2:End() },"Gerando Planilha") ) OF oDlgOP2 	PIXEL
@ FAJUSTCOOR(175), FAJUSTCOOR(004) BUTTON oBtCancel PROMPT "Cancelar" SIZE FAJUSTCOOR(037), FAJUSTCOOR(015)  ACTION (  oDlgOP2:End() ) OF oDlgOP2 PIXEL
//--oBtOk:cToolTip 	   := "Inicializa processo de separação parcial"
oBtOk:cToolTip 	   := "Inicializa processo de separação "+_cTit
oBtOk:SetCss(cEstilo)
oBtCancel:cToolTip := "Retorna tela anterior"
oBtCancel:SetCss(cEstilo)

ACTIVATE MSDIALOG oDlgOP2 CENTERED

SetKey(VK_F4, Nil)

Return(_lRet)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fBrwSld    ³ Autor ³ Flavio Valentin           ³ Data ³ 05/12/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que faz a Montagem da tela transferencia parcial          ³±±
±±³          ³ (MsNewGetDados).                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ paSemSldo=> Array contendo os registros para executar o processo ³±±
±±³          ³ sem saldo.                                                       ³±±
±±³          ³ poPanel 	=> objeto.                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ _lRet => Validacao ().T./.F.)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function fBrwSld(paSemSldo, poPanel)

Local nX
Local aHeaderEx 	:= {}
Local aFieldFill 	:= {}
Local aFields 		:= {'D4_COD','B1_DESC','D4_LOCAL','D4_QTDEORI','D4_QUANT','D4_LOTECTL','B2_QATU','DC_LOCALIZ','DC_NUMSERI','D4_TRT'}
Local aPos			:= {2, 0, 3, 4 , 5}
//Local aAlterFields	:= {'D4_QTDEORI','D4_LOTECTL'}
Local aAlterFields	:= {'D4_QTDEORI'}
Local aAreaBrw    	:= GetArea()
Local cF3			:= ""
Local _lRet			:= .T.
Local nL

// Define field properties
dbSelectArea("SX3")
SX3->(dbSetOrder(2))
For nX := 1 To Len(aFields)
	If SX3->(MSSeek(aFields[nX]))
		If nX == Len(aFields)
			cF3 	:= "SLDF3"
			cValid 	:= ""
		Else
			cF3 	:= SX3->X3_F3
			cValid 	:= SX3->X3_VALID
		EndIf
		If AllTrim(SX3->X3_CAMPO)$"D4_QUANT/D4_QTDEORI/D4_LOTECTL"
			
			//criado os dois if´s abaixo para ajustar o nome do campo da coluna na montagem da tela, Vinicius Belini - 01/03/2019
			If AllTrim(SX3->X3_CAMPO) == "D4_QUANT"
				aAdd(aHeaderEx, {"Sal.Pagam",SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"",;
				SX3->X3_USADO,SX3->X3_TIPO,cF3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
			EndIf
			
			If AllTrim(SX3->X3_CAMPO) == "D4_QTDEORI"
				aAdd(aHeaderEx, {"Qtd.Paga",SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"",;
				SX3->X3_USADO,SX3->X3_TIPO,cF3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
			EndIf
			
			If AllTrim(SX3->X3_CAMPO) == "D4_LOTECTL"
				aAdd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,"",;
				SX3->X3_USADO,SX3->X3_TIPO,cF3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
			Endif
			
		Else
			aAdd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,cValid,;
			SX3->X3_USADO,SX3->X3_TIPO,cF3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		EndIf
	EndIf
Next nX

//                  1            2            3             4               5                 6               7                8               9                  10             11          12
//			 SD4->D4_OP, SD4->D4_COD, SD4->D4_LOCAL, SD4->D4_QUANT, SD4->D4_LOTECTL, SDC->DC_LocalIZ, SDC->DC_QUANT, SD4->D4_DTVALID, SD4->D4_NUMLOTE, SDC->DC_NUMSERI, SD4->D4_TRT, SD4->D4_OPORIG })
For nL := 1 To Len(paSemSldo)
	For nX := 1 To Len(aFields)
		If MSSeek(aFields[nX])
			If (nX == 1)
				aAdd(aFieldFill, paSemSldo[nL][02])
			ElseIf (nX == 2)
				aAdd(aFieldFill, POSICIONE('SB1',1,XFILIAL('SB1')+paSemSldo[nL][2],'B1_DESC') )
			ElseIf (nX == 3)
				aAdd(aFieldFill, paSemSldo[nL][3])
			ElseIf (nX == 4)
				aAdd(aFieldFill, 0)
			ElseIf (nX == 5)
				aAdd(aFieldFill, paSemSldo[nL][4])
			ElseIf (nX == 6)
				aAdd(aFieldFill, paSemSldo[nL][5])
			ElseIf (nX == 7)
				aAdd(aFieldFill, paSemSldo[nL][13])
			ElseIf (nX == 8)
				aAdd(aFieldFill, paSemSldo[nL][06])
			ElseIf (nX == 9)
				aAdd(aFieldFill, paSemSldo[nL][10])
			ElseIf (nX == 10)
				aAdd(aFieldFill,paSemSldo[nL][11])
			EndIf
			
		EndIf
	Next nX
	aAdd(aFieldFill, .F.)
	aAdd(aColsEx, aFieldFill)
	aFieldFill := {}
Next nL

_lRet := (Len(aColsEx) > 0)

oBrwSld := MsNewGetDados():New(FAJUSTCOOR(049), FAJUSTCOOR(007), FAJUSTCOOR(160), FAJUSTCOOR(339), GD_UPDATE, "u_PERFVLNGRD(1)", "AlWaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", poPanel, aHeaderEx, aColsEx)

RestArea(aAreaBrw)

Return(_lRet)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OkTraParc  ³ Autor ³ Flavio Valentin           ³ Data ³ 05/12/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Confirmação para Iniciar o Processo Parcial.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ paSSLD02	=> Array contendo os registros para executar o processo ³±±
±±³          ³ parcial.                                                         ³±±
±±³          ³ plRET 	=> Executado (.T./.F.)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ _lRet => Executado (.T./.F.)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function OkTraParc(paSSLD02, plRET)

Local _lRet 	 	:= .T.
Local cArmProd  	:= Alltrim(GetMV("MV_XLOCPRO"))
Local cLocaliz  	:= cEndProd
Local cCodigoTM		:= GetNewPar("MV_TMPCP02","100")
Local nQtdDif   	:= 0
Local nPosReg   	:= 0
Local nUltCol   	:= Len(paSSLD02[1])
Local nSaldo		:= 0
Local nQtde			:= 0
Local cOP			:= ""
Local cProduto  	:= ""
Local cLocal		:= ""
Local cLote	 		:= ""
Local aCampo    	:= {}
//Local _aEmp     	:= {}
//Local _aTMP     	:= {}
//Local _aTMP02   	:= {}
Local _nSalEmp      := 0
Local _aAltEmp      := {}
Local _aZerEmp      := {}
Local _aTransf      := {}
Local _aNewEmp      := {}
Local aDel02    	:= aClone(paSSLD02)
Local aDelSD4   	:= aClone(paSSLD02)
Local nCol
Local nL
Local lAlerta   	:= .F.
Local _nSaldoBF := 0
Local _lTemSer := .F.
Local _nI			:= 0
Local _nPosProdut	:= 1
Local _nPosLocal	:= 2
Local _nPosQtde		:= 3
Local _nPosLote  	:= 5
Local _nPosSubLote	:= 6
Local _nPosEndereco	:= 7
Local _nPosValidade	:= 8
Local _nPosNumSer 	:= 9
Local _nPosValeRe 	:= 10
Local _nPosHospi  	:= 11
Local _nPosDoc    	:= 12
Local _nPosSerie  	:= 13
Local _nPosItemD2 	:= 14
Local _nPosIdentB 	:= 15
Local _nQtdeOri     := 0

_lUsaVenc := (SuperGetMV('MV_XLOTVEN')=='S')

ProcRegua(4)

// Verificar se terá algum tipo de validacao antes de confirmar
aColsEX := aClone(oBrwSld:aCols)
For nL := 1 To Len(aColsEX)
	//D4_COD+D4_LOCAL+D4_LOTECTL
	nPosReg := aScan(aDelSD4, { |X| X[2]+X[3]==aColsEX[nL][1]+aColsEX[nL][3] } )
	If nPosReg > 0
		cOP		  := paSSLD02[nPosReg][1]
		cProduto  := aColsEX[nL][1]//paSSLD02[nPosReg][2]
		cLocal	  := aColsEX[nL][3]//paSSLD02[nPosReg][3]
		nQtde	  := aColsEX[nL][4]
		cLote	  := aColsEX[nL][6]
		nSaldo	  := aColsEX[nL][7]//paSSLD02[nPosReg][nUltCol]
		
		If nQtde > 0
			
			// cria array para o tratamento de alteração do empenho de Origem
			cLocPad := GETADVFVAL("SB1","B1_LOCPAD",xFilial("SB1")+cProduto,1,"")
			If Rastro(cProduto)
				If !Empty(cLote)
					lBaixaEmp	:= .T.
					
					If Empty(aColsEX[nL][8]) // Pesquisa o saldo por lote de Produtos sem endereço
						
						_aSaldos	:= SldPorLote(cProduto,cLocal,nQtde,nQtde,cLote,/*SC6->C6_NUMLOTE*/,/*SC6->C6_LocalIZ*/,/*SC6->C6_NUMSERI*/,NIL,NIL,NIL,_lUsaVenc,nil,nil,dDataBase)
						
					Else
						
						_nSaldoBF	:= SaldoSBF(cLocal,aColsEX[nL][8],cProduto,aColsEX[nL][9],cLote,"")
					Endif
					
					If !Empty(cLote) .AND. Empty(aColsEX[nL][8])// tem lote e não tem endereço
						
						If Len(_aSaldos) > 0
							For _nI := 1 To Len(_aSaldos)
								
								aSavAtu := GetArea()
								aSavSD4 := SD4->(GetArea())
								
								dbSelectArea("SD4")
								dbSetOrder(1)//D4_FILIAL, D4_COD, D4_OP, D4_TRT,D4_LOTECTL, D4_NUMLOTE, R_E_C_N_O_, D_E_L_E_T_
								If SD4->(MSSeek(xFilial("SD4")+aColsEX[nL][01]+cOP+aColsEX[nL][10]+aColsEX[nL][06]))
									
									_nQtdeOri := SD4->D4_QTDEORI
									_nSalEmp := SD4->D4_QUANT - nQtde
									
								EndIf
								
								RestArea(aSavSD4)
								RestArea(aSavAtu)
								
								dbSelectArea("SB8")
								dbSetOrder(3) //B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_LOTECTL, B8_NUMLOTE, B8_DTVALID, R_E_C_N_O_, D_E_L_E_T_
								SB8->(MSSeek(xFilial("SB8")+aColsEX[nL][01]+aColsEX[nL][03]+aColsEX[nL][06]))
								
								If _nSalEmp >= 1
									//Produto          Local        OP     Quantidade  Data Empenho   Qtd.Orig   OP.Orig            Lote       SubLote         Data Validade      Endereço      Serie            Sequencia
									aAdd(_aAltEmp,{aColsEX[nL][01],aColsEX[nL][03],cOP,aColsEX[nL][04],SD4->D4_DATA,_nQtdeOri,SD4->D4_OPORIG,aColsEX[nL][06],SD4->D4_NUMLOTE,SB8->B8_DTVALID,aColsEX[nL][08],aColsEX[nL][09],aColsEX[nL][10]})  // Array Contendo o empenho que será alterado na Origem
									//      1               2         3        4             5            6          7               8                 9               10            11               12              13
								Else
									//Produto          Local        OP     Quantidade  Data Empenho   Qtd.Orig   OP.Orig            Lote       SubLote         Data Validade      Endereço      Serie            Sequencia
									aAdd(_aZerEmp,{aColsEX[nL][01],aColsEX[nL][03],cOP,aColsEX[nL][04],SD4->D4_DATA,_nQtdeOri,SD4->D4_OPORIG,aColsEX[nL][06],SD4->D4_NUMLOTE,SB8->B8_DTVALID,aColsEX[nL][08],aColsEX[nL][09],aColsEX[nL][10]})  // Array Contendo o empenho que será alterado na Origem
									//      1               2         3        4             5            6          7               8                 9               10            11               12              13
								Endif
								
								aAdd(_aTransf,{aColsEX[nL][01],aColsEX[nL][03],cOP,aColsEX[nL][04],SD4->D4_DATA,_nQtdeOri,SD4->D4_OPORIG,aColsEX[nL][06],SD4->D4_NUMLOTE,SB8->B8_DTVALID,aColsEX[nL][08],aColsEX[nL][09],aColsEX[nL][10]})  // Array Contendo o empenho que será alterado na Origem
								aAdd(_aNewEmp,{aColsEX[nL][01],aColsEX[nL][03],cOP,aColsEX[nL][04],SD4->D4_DATA,_nQtdeOri,SD4->D4_OPORIG,aColsEX[nL][06],SD4->D4_NUMLOTE,SB8->B8_DTVALID,aColsEX[nL][08],aColsEX[nL][09],aColsEX[nL][10]})  // Array Contendo o empenho que será alterado na Origem
								
							Next _nI
							
						Endif
					Else
						If _nSaldoBF > 0 .AND. Empty(aColsEX[nL][09]) // Tem endereço e não controla série
							
							aSavAtu := GetArea()
							aSavSD4 := SD4->(GetArea())
							
							dbSelectArea("SD4")
							dbSetOrder(1)//D4_FILIAL, D4_COD, D4_OP, D4_TRT,D4_LOTECTL, D4_NUMLOTE, R_E_C_N_O_, D_E_L_E_T_
							If SD4->(MSSeek(xFilial("SD4")+aColsEX[nL][01]+cOP+aColsEX[nL][10]+aColsEX[nL][06]))
								
								_nQtdeOri := SD4->D4_QTDEORI
								_nSalEmp := SD4->D4_QUANT - nQtde
								
							EndIf
							
							RestArea(aSavSD4)
							RestArea(aSavAtu)
							
							dbSelectArea("SB8")
							dbSetOrder(3) //B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_LOTECTL, B8_NUMLOTE, B8_DTVALID, R_E_C_N_O_, D_E_L_E_T_
							SB8->(MSSeek(xFilial("SB8")+aColsEX[nL][01]+aColsEX[nL][03]+aColsEX[nL][06]))
							
							If _nSalEmp >= 1
								//Produto          Local        OP     Quantidade  Data Empenho   Qtd.Orig   OP.Orig            Lote       SubLote         Data Validade      Endereço      Serie            Sequencia
								aAdd(_aAltEmp,{aColsEX[nL][01],aColsEX[nL][03],cOP,aColsEX[nL][04],SD4->D4_DATA,_nQtdeOri,SD4->D4_OPORIG,aColsEX[nL][06],SD4->D4_NUMLOTE,SB8->B8_DTVALID,aColsEX[nL][08],aColsEX[nL][09],aColsEX[nL][10]})  // Array Contendo o empenho que será alterado na Origem
								//      1               2         3        4             5            6          7               8                 9               10            11               12              13
							Else
								//Produto          Local        OP     Quantidade  Data Empenho   Qtd.Orig   OP.Orig            Lote       SubLote         Data Validade      Endereço      Serie            Sequencia
								aAdd(_aZerEmp,{aColsEX[nL][01],aColsEX[nL][03],cOP,aColsEX[nL][04],SD4->D4_DATA,_nQtdeOri,SD4->D4_OPORIG,aColsEX[nL][06],SD4->D4_NUMLOTE,SB8->B8_DTVALID,aColsEX[nL][08],aColsEX[nL][09],aColsEX[nL][10]})  // Array Contendo o empenho que será alterado na Origem
								//      1               2         3        4             5            6          7               8                 9               10            11               12              13
							Endif
							
							aAdd(_aTransf,{aColsEX[nL][01],aColsEX[nL][03],cOP,aColsEX[nL][04],SD4->D4_DATA,_nQtdeOri,SD4->D4_OPORIG,aColsEX[nL][06],SD4->D4_NUMLOTE,SB8->B8_DTVALID,aColsEX[nL][08],aColsEX[nL][09],aColsEX[nL][10]})  // Array Contendo o empenho que será alterado na Origem
							aAdd(_aNewEmp,{aColsEX[nL][01],aColsEX[nL][03],cOP,aColsEX[nL][04],SD4->D4_DATA,_nQtdeOri,SD4->D4_OPORIG,aColsEX[nL][06],SD4->D4_NUMLOTE,SB8->B8_DTVALID,aColsEX[nL][08],aColsEX[nL][09],aColsEX[nL][10]})  // Array Contendo o empenho que será alterado na Origem
							
						Endif
						
						If ! Empty(aColsEX[nL][09])
							
							_lTemSer := .T.
							
						Endif
						
					EndIf
				Else
					lAlerta   := .T.
				EndIf
			Else
				
				If Empty(aColsEX[nL][09]) // Entra para fazer somente SB2 E Não possui somente controle de série
					
					aSavAtu := GetArea()
					aSavSD4 := SD4->(GetArea())
					
					dbSelectArea("SD4")
					dbSetOrder(1)//D4_FILIAL, D4_COD, D4_OP, D4_TRT,D4_LOTECTL, D4_NUMLOTE, R_E_C_N_O_, D_E_L_E_T_
					If SD4->(MSSeek(xFilial("SD4")+aColsEX[nL][01]+cOP+aColsEX[nL][10]+aColsEX[nL][06]))
						
						_nQtdeOri := SD4->D4_QTDEORI
						_nSalEmp := SD4->D4_QUANT - nQtde
						
					EndIf
					
					RestArea(aSavSD4)
					RestArea(aSavAtu)
					
					If _nSalEmp >= 1
						//Produto          Local        OP     Quantidade  Data Empenho   Qtd.Orig   OP.Orig            Lote       SubLote         Data Validade      Endereço      Serie            Sequencia
						aAdd(_aAltEmp,{aColsEX[nL][01],aColsEX[nL][03],cOP,aColsEX[nL][04],SD4->D4_DATA,_nQtdeOri,SD4->D4_OPORIG,aColsEX[nL][06],SD4->D4_NUMLOTE,SB8->B8_DTVALID,aColsEX[nL][08],aColsEX[nL][09],aColsEX[nL][10]})  // Array Contendo o empenho que será alterado na Origem
						//      1               2         3        4             5            6          7               8                 9               10            11               12              13
					Else
						//Produto          Local        OP     Quantidade  Data Empenho   Qtd.Orig   OP.Orig            Lote       SubLote         Data Validade      Endereço      Serie            Sequencia
						aAdd(_aZerEmp,{aColsEX[nL][01],aColsEX[nL][03],cOP,aColsEX[nL][04],SD4->D4_DATA,_nQtdeOri,SD4->D4_OPORIG,aColsEX[nL][06],SD4->D4_NUMLOTE,SB8->B8_DTVALID,aColsEX[nL][08],aColsEX[nL][09],aColsEX[nL][10]})  // Array Contendo o empenho que será alterado na Origem
						//      1               2         3        4             5            6          7               8                 9               10            11               12              13
					Endif
					
					aAdd(_aTransf,{aColsEX[nL][01],aColsEX[nL][03],cOP,aColsEX[nL][04],SD4->D4_DATA,_nQtdeOri,SD4->D4_OPORIG,aColsEX[nL][06],SD4->D4_NUMLOTE,SB8->B8_DTVALID,aColsEX[nL][08],aColsEX[nL][09],aColsEX[nL][10]})  // Array Contendo o empenho que será alterado na Origem
					aAdd(_aNewEmp,{aColsEX[nL][01],aColsEX[nL][03],cOP,aColsEX[nL][04],SD4->D4_DATA,_nQtdeOri,SD4->D4_OPORIG,aColsEX[nL][06],SD4->D4_NUMLOTE,SB8->B8_DTVALID,aColsEX[nL][08],aColsEX[nL][09],aColsEX[nL][10]})  // Array Contendo o empenho que será alterado na Origem
					
					
				Else
					
					_lTemSer := .T.
					
				Endif
				
			Endif
			
		EndIf
		
	EndIf
Next
If (lAlerta)
	MsgAlert("Atenção existe produto(s) sem lote")
EndIf

// Será excluído o Empenho armazem 01
If Len(_aAltEmp) > 0
	IncProc("Alterando empenho do armazem de Origem")
	If !MntEmp(_aAltEmp, 4)
		Return(.F.)
	EndIf
EndIf

If Len(_aZerEmp) > 0
	IncProc("Excluindo empenho do armazem origem")
	If !ZerEmp(_aZerEmp, 4)
		Return(.F.)
	EndIf
EndIf

// Devera ser realizado a Transferencia
If Len(_aTransf) >0
	IncProc("Realizando transferência de armazem")
	If !TransArm(_aTransf, 3)
		Return(.F.)
	EndIf
Endif

// Gerando Empenhos armazem 02
If Len(_aNewEmp) >0
	IncProc("Gerando o empenho para armazem "+Alltrim(cArmProd))
	If !GerEmp(_aNewEmp, 3)
		Return(.F.)
	EndIf
Endif

If _lTemSer
	
	U_TRATSERIE(aColsEX,cOP)
	
Endif

plRET := _lRet

Return(_lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TRATSERIE    ³ Autor ³ Edson Estevam           ³ Data ³ 23/03/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que Trata movimentos com controle de série                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/

User Function TRATSERIE(aTelaProd,cOP)

Local aVetor   := {}
Local aEmpen   := {}
Local aTMP     := {}
Local aErrAut  := {}
Local cLocaliz := Criavar('DC_LOCALIZ')
Local nREG     := 0
Local dData    := dDatabase
Local cTRT     := Criavar('D4_TRT')
Local _lRet    := .T.
Local cArmProd := Alltrim(GetMV("MV_XLOCPRO"))
Local _cMsg
Local _nDifEmp := 0
Local _nQtde := 0
Local _cProd := ""
Local _aAltEmp2 := {}
Local _aGerEmp2 := {}
Local _aItZeros := {}
Local _lDel     := .F.
// Tratamento dos empenhos remanescentes

_cProd := aTelaProd[01][01]
_cLote := aTelaProd[01][06]

For nREG := 1 To Len(aTelaProd)
	
	If !EMPTY(aTelaProd[nREG][09])
		
		/*
		If aTelaProd[nREG][04] == 0 .AND. _cProd == aTelaProd[nREG][01] //.AND. _cLote ==  aTelaProd[nREG][06]   // Soma a quantidade dos empenho remanescente.
		
		_cProd      := aTelaProd[nREG][01]
		cLocal		:= aTelaProd[nREG][03]// Assumo o Armazem Original
		cLocaliz	:= aTelaProd[nREG][08]// Endereço Original
		
		dbSelectArea("SD4")
		dbSetOrder(1) //D4_FILIAL+D4_COD+D4_OP+D4_TRT
		SD4->(MSSeek(xFilial("SD4")+aTelaProd[nREG][01]+cOP+aTelaProd[nREG][10]))
		
		dbSelectArea("SB8")
		dbSetOrder(3) //B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_LOTECTL, B8_NUMLOTE, B8_DTVALID, R_E_C_N_O_, D_E_L_E_T_
		SB8->(MSSeek(xFilial("SB8")+aTelaProd[nREG][01]+aTelaProd[nREG][03]+aTelaProd[nREG][06]))
		
		//dbSelectArea("SDC")
		//dbSetOrder(2) //DC_FILIAL, DC_PRODUTO, DC_LOCAL, DC_OP, DC_TRT, DC_LOTECTL, DC_NUMLOTE, DC_LOCALIZ, DC_NUMSERI, R_E_C_N_O_, D_E_L_E_T_
		//If SDC->(MSSeek(xFilial("SDC")+aTelaProd[nREG][01]+aTelaProd[nREG][03]+cOP+aTelaProd[nREG][10]+aTelaProd[nREG][06]+""+aTelaProd[nREG][08]+aTelaProd[nREG][09]))
		
		aAdd(_aAltEmp2,{aTelaProd[nREG][01],cLocal,cOP,cLocaliz,SD4->D4_DATA,SD4->D4_QTDEORI,SD4->D4_QUANT,SD4->D4_OPORIG,aTelaProd[nREG][06],"",SB8->B8_DTVALID,aTelaProd[nREG][10],0,aTelaProd[nREG][09]})
		
		//Endif
		
		Endif
		
		*/
		If aTelaProd[nREG][04] <> 0
			
			cLocal		:= aTelaProd[nREG][03]// Assumo o Armazem Original
			cLocaliz	:= aTelaProd[nREG][08]// Endereço Original
			
			cLocalDes		:= Alltrim(GetMV("MV_XLOCPRO"))
			cLocaliDe	:= PADR(GETMV("MV_XENDPRO"),TamSX3("BF_LOCALIZ")[1])
			
			dbSelectArea("SD4")
			dbSetOrder(1) //D4_FILIAL+D4_COD+D4_OP+D4_TRT
			SD4->(MSSeek(xFilial("SD4")+aTelaProd[nREG][01]+cOP+aTelaProd[nREG][10]))
			
			dbSelectArea("SB8")
			dbSetOrder(3) //B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_LOTECTL, B8_NUMLOTE, B8_DTVALID, R_E_C_N_O_, D_E_L_E_T_
			SB8->(MSSeek(xFilial("SB8")+aTelaProd[nREG][01]+aTelaProd[nREG][03]+aTelaProd[nREG][06]))
			
			//dbSelectArea("SDC")
			//dbSetOrder(2) //DC_FILIAL, DC_PRODUTO, DC_LOCAL, DC_OP, DC_TRT, DC_LOTECTL, DC_NUMLOTE, DC_LOCALIZ, DC_NUMSERI, R_E_C_N_O_, D_E_L_E_T_
			//If SDC->(MSSeek(xFilial("SDC")+aTelaProd[nREG][01]+aTelaProd[nREG][03]+cOP+aTelaProd[nREG][10]+aTelaProd[nREG][06]+""+aTelaProd[nREG][08]+aTelaProd[nREG][09]))
			
			//aAdd(_aGerEmp2,{SD4->D4_COD,cLocal,SD4->D4_OP,cLocaliz,SD4->D4_DATA,SD4->D4_QTDEORI,SD4->D4_QUANT,SD4->D4_OPORIG,SDC->DC_LOTECTL,SDC->DC_NUMLOTE,SB8->B8_DTVALID,SDC->DC_TRT,0,aTelaProd[nREG][09],cLocalDes,cLocaliDe,.F.})
			aAdd(_aGerEmp2,{aTelaProd[nREG][01],cLocal,cOP,cLocaliz,SD4->D4_DATA,SD4->D4_QTDEORI,SD4->D4_QUANT,SD4->D4_OPORIG,aTelaProd[nREG][06],"",SB8->B8_DTVALID,aTelaProd[nREG][10],0,aTelaProd[nREG][09],cLocalDes,cLocaliDe})
			// Produto           Lote             Endereço   Série
			
			//aAdd(_aItZeros,{aTelaProd[nREG][01],aTelaProd[nREG][06],cLocaliz,aTelaProd[nREG][09]})
			aAdd(_aItZeros,{aTelaProd[nREG][01]})//,aTelaProd[nREG][06],cLocaliz,aTelaProd[nREG][09]})
			//Endif
			
			
		Endif
		
	Endif
	
Next

For nREG2 := 1 To Len(aTelaProd)
	
	If !EMPTY(aTelaProd[nREG2][09])
		
		//If aScan(_aItZeros,{ |X| X[1]+X[2]+X[3]+X[4]==aTelaProd[nREG2][01]+aTelaProd[nREG2][06]+cLocaliz+aTelaProd[nREG2][09]}) > 0
		If aScan(_aItZeros,{ |X| X[1]==aTelaProd[nREG2][01]}) > 0
			
			If aTelaProd[nREG2][04] == 0
				
				//MsgAlert(aTelaProd[nREG2][01] + " " + aTelaProd[nREG2][01] + "ACHOU ZERO")
				
				dbSelectArea("SD4")
				dbSetOrder(1) //D4_FILIAL+D4_COD+D4_OP+D4_TRT
				SD4->(MSSeek(xFilial("SD4")+aTelaProd[nREG2][01]+cOP+aTelaProd[nREG2][10]))
				
				dbSelectArea("SB8")
				dbSetOrder(3) //B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_LOTECTL, B8_NUMLOTE, B8_DTVALID, R_E_C_N_O_, D_E_L_E_T_
				SB8->(MSSeek(xFilial("SB8")+aTelaProd[nREG2][01]+aTelaProd[nREG2][03]+aTelaProd[nREG2][06]))
				
				aAdd(_aAltEmp2,{aTelaProd[nREG2][01],cLocal,cOP,cLocaliz,SD4->D4_DATA,SD4->D4_QTDEORI,SD4->D4_QUANT,SD4->D4_OPORIG,aTelaProd[nREG2][06],"",SB8->B8_DTVALID,aTelaProd[nREG2][10],0,aTelaProd[nREG2][09]})
				
			Endif
			
		Endif
	Endif
Next

If Len(_aAltEmp2) > 0
	For nAlt := 1 To Len(_aAltEmp2)
		
		lRastro  := Rastro(_aAltEmp2[nAlt][01])
		lLocaliz := Localiza(_aAltEmp2[nAlt][01])
		
		lMsErroAuto := .F.
		
		//Zera o empenho existente
		//                    1         2       3         4         5              6             7               8              9                 10             11            12     13
		//aAdd(_aAltEmp,{SD4->D4_COD,cLocal,SD4->D4_OP,cLocaliz,SD4->D4_DATA,SD4->D4_QTDEORI,SD4->D4_QUANT,SD4->D4_OPORIG,SD4->D4_LOTECTL,SD4->D4_NUMLOTE,SD4->D4_DTVALID,SD4->D4_TRT,0,.F.})
		
		//dbSelectArea("SD4")
		//dbSetOrder(1) //D4_FILIAL+D4_COD+D4_OP+D4_TRT
		cQuery := ""
		cQuery := " SELECT * FROM "
		cQuery += RetSqlName("SD4")+" SD4 "
		cQuery += " WHERE SD4.D_E_L_E_T_ = '' "
		cQuery += " AND D4_FILIAL = '"+xFilial("SD4")+"'"
		cQuery += "   AND SD4.D4_COD  = '" + _aAltEmp2[nAlt][01] + "'"
		cQuery += "   AND SD4.D4_OP = '" + _aAltEmp2[nAlt][03] + "'"
		cQuery += "   AND SD4.D4_QUANT <> 0 "
		cQuery += "   AND SD4.D4_LOCAL = '" + _aAltEmp2[nAlt][02] + "'"
		
		
		//* Verifica se a Query Existe, se existir fecha
		If Select("TMP") > 0
			dbSelectArea("TMP")
			DbCloseArea()
		EndIf
		
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TMP", .F., .T.)
		
		dbSelectArea("TMP")
		Do While !Eof()
			
			If TMP->D4_QUANT > 0
				aVetor	:=	{}
				aAdd(aVetor, {"D4_COD"		,_aAltEmp2[nAlt][01]	,Nil})
				aAdd(aVetor, {"D4_LOCAL"	,_aAltEmp2[nAlt][02]	,Nil})
				aAdd(aVetor, {"D4_OP"		,_aAltEmp2[nAlt][03]	    ,Nil})
				aAdd(aVetor, {"D4_DATA"		,_aAltEmp2[nAlt][05]   , Nil})
				aAdd(aVetor, {"D4_QTDEORI"	,_aAltEmp2[nAlt][06],Nil})
				aAdd(aVetor, {"D4_QUANT"	,_aAltEmp2[nAlt][07]	,Nil})
				aAdd(aVetor, {"D4_OPORIG"	,_aAltEmp2[nAlt][08]	,Nil})
				If (lRastro)  
					////Conout("Lote" +_aAltEmp2[nAlt][09])
					aAdd(aVetor, {"D4_LOTECTL"	,_aAltEmp2[nAlt][09]	,Nil})
					aAdd(aVetor, {"D4_NUMLOTE"	,_aAltEmp2[nAlt][10]	,NIL})
					aAdd(aVetor, {"D4_DTVALID"	,_aAltEmp2[nAlt][11] 	,NIL})
					
				EndIf
				aAdd(aVetor, {"D4_TRT"		,TMP->D4_TRT				,Nil})
				aAdd(aVetor, {"D4_QTSEGUM"	,0             		,Nil})
				aAdd(aVetor, {"ZERAEMP"     ,"S",NIL})
				
				MSExecAuto( { |x,y,z| mata380(x,y,z)}, aVetor,4, aEmpen)
				
				If (lMsErroAuto)
					MostraErro()
					Return(.F.)
				EndIf
				
			Endif
			
			DbSelectArea("TMP")
			DbSkip()
			
		Enddo
	Next
	
	If Len(_aAltEmp2) > 0
		For Del1 := 1 To Len(_aAltEmp2)
			
			DbSelectArea("SD4")
			DbSetOrder(1) //D4_FILIAL, D4_COD, D4_OP, D4_TRT, D4_LOTECTL, D4_NUMLOTE, R_E_C_N_O_, D_E_L_E_T_
			If SD4->(MSSeek(xFilial("SD4")+_aAltEmp2[Del1][01]+_aAltEmp2[Del1][03]+_aAltEmp2[Del1][12]+_aAltEmp2[Del1][09]+_aAltEmp2[Del1][10]))
				cUpdSd4a := " DELETE FROM "+RetSqlName("SD4")
				cUpdSd4a += " WHERE D_E_L_E_T_= ' ' AND D4_OP= '"+SD4->D4_OP+"' AND D4_LOTECTL = '"+ SD4->D4_LOTECTL+"' AND D4_LOCAL = '"+SD4->D4_LOCAL+"' AND D4_COD = '"+SD4->D4_COD+"'  "
				cUpdSd4a += " AND D4_QUANT = 0 "
				TCSQLEXEC(cUpdSd4a)
				
			Endif
			
		Next
	Endif
	
	For nAlt2 := 1 To Len(_aAltEmp2)
		
		lRastro  := Rastro(_aAltEmp2[nAlt2][01])
		lLocaliz := Localiza(_aAltEmp2[nAlt2][01])
		
		aVetor   := {}
		aEmpen   := {}
		aTMP     := {}
		aErrAut  := {}
		cLocaliz := Criavar('DC_LOCALIZ')
		nREG     := 0
		dData    := dDatabase
		_lRet    := .T.
		//cArmProd := Alltrim(GetMV("MV_XLOCPRO"))
		//cEndProd := PADR(GETMV("MV_XENDPRO"),TamSX3("BF_LOCALIZ")[1])
		
		_cMsg := ""
		_nDifEmp := 0
		
		aSavAtu := GetArea()
		aSavSD4 := SD4->(GetArea())
		
		//lAchou  := .T.
		//dbSelectArea("SD4")
		//dbSetOrder(1) //D4_FILIAL+D4_COD+D4_OP+D4_TRT
		//If SD4->(MSSeek(xFilial("SD4")+_aAltEmp[nAlt][01]+_aAltEmp[nAlt][03]+cTRT))
		
		cQryTmp := " SELECT MAX(D4_TRT) ULT_REVISAO "
		cQryTmp += "   FROM " + RetSqlName("SD4") + " SD4"
		cQryTmp += "   WHERE D4_FILIAL = '" + xFilial("SD4") + "'"
		cQryTmp += "   AND SD4.D4_COD  = '" + _aAltEmp2[nAlt2][01] + "'"
		cQryTmp += "   AND SD4.D4_OP = '" + _aAltEmp2[nAlt2][03] + "'"
		//cQryTmp += "   AND SD4.D4_LOCAL = '" + _aAltEmp2[nAlt2][02] + "'"
		
		If Select("TRBREN") <> 0
			dbSelectArea("TRBREN")
			dbCloseArea()
		EndIf
		
		dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQryTmp), "TRBREN" , .T. , .F. )
		
		If !TRBREN->(Eof())
			cTRT := Soma1(TRBREN->ULT_REVISAO)
		Endif
		
		aVetor	:=	{}
		aAdd(aVetor, {"D4_COD"		,_aAltEmp2[nAlt2][01]	,Nil})
		aAdd(aVetor, {"D4_LOCAL"	,_aAltEmp2[nAlt2][02]	,Nil})
		aAdd(aVetor, {"D4_OP"		,_aAltEmp2[nAlt2][03]	    ,Nil})
		aAdd(aVetor, {"D4_DATA"		,_aAltEmp2[nAlt2][05]   , Nil})
		aAdd(aVetor, {"D4_QTDEORI"	,1,Nil})
		aAdd(aVetor, {"D4_QUANT"	,1,Nil})
		aAdd(aVetor, {"D4_OPORIG"	,_aAltEmp2[nAlt2][08]	,Nil})
		If (lRastro)
		    ////Conout("Lote2 : " + _aAltEmp2[nAlt][09])
			aAdd(aVetor, {"D4_LOTECTL"	,_aAltEmp2[nAlt2][09]	,Nil})
			aAdd(aVetor, {"D4_NUMLOTE"	,_aAltEmp2[nAlt2][10]	,NIL})
			aAdd(aVetor, {"D4_DTVALID"	,_aAltEmp2[nAlt2][11] 	,NIL})
		EndIf
		aAdd(aVetor, {"D4_TRT"		,cTRT				,Nil})
		aAdd(aVetor, {"D4_QTSEGUM"	,0             		,Nil})
		
		If (lLocaliz)
			aAdd(aEmpen,{   1,;   	// SD4->D4_QUANT
			_aAltEmp2[nAlt2][04],;   	// DC_LocalIZ         - paTransf[nREG][06]
			_aAltEmp2[nAlt2][14],;   	// DC_NUMSERI
			0               ,;    	// D4_QTSEGUM
			.F.})
			
		EndIf
		
		MSExecAuto( { |x,y,z| mata380(x,y,z)}, aVetor, 3, aEmpen)
		
		If (lMsErroAuto)
			MostraErro()
			Return(.F.)
		EndIf
		aEmpen   := {}
		
		RestArea(aSavSD4)
		RestArea(aSavAtu)
	Next
Endif

If Len(_aAltEmp2) = 0 .AND. Len(_aGerEmp2) > 0  

_lDel := .T.

Endif 

If Len(_aGerEmp2) > 0
	
	For nAlt3 := 1 To Len(_aGerEmp2)
		
		lRastro  := Rastro(_aGerEmp2[nAlt3][01])
		lLocaliz := Localiza(_aGerEmp2[nAlt3][01])
		
		lMsErroAuto := .F.
		
		//Zera o empenho existente
		//                       1      2        3         4          5            6                 7             8              9              10               11            12     13         14             15       16
		//aAdd(_aGerEmp2,{SD4->D4_COD,cLocal,SD4->D4_OP,cLocaliz,SD4->D4_DATA,SD4->D4_QTDEORI,SD4->D4_QUANT,SD4->D4_OPORIG,SD4->D4_LOTECTL,SD4->D4_NUMLOTE,SD4->D4_DTVALID,SD4->D4_TRT,0,aTelaProd[nREG][09],cLocalDes,cLocaliDe,.F.})
		
		aSavAtu := GetArea()
		aSavSD4 := SD4->(GetArea())
		
		/*
		cQuery := ""
		cQuery := " SELECT SUM(D4_QUANT) AS SDLEMP FROM "
		cQuery += RetSqlName("SD4")+" SD4 "
		cQuery += " WHERE SD4.D_E_L_E_T_ = '' "
		cQuery += " AND D4_FILIAL = '"+xFilial("SD4")+"'"
		cQuery += "   AND SD4.D4_COD  = '" + _aGerEmp2[nAlt3][01] + "'"
		cQuery += "   AND SD4.D4_OP = '" + _aGerEmp2[nAlt3][03] + "'"
		cQuery += "   AND SD4.D4_QUANT <> 0 "
		cQuery += "   AND SD4.D4_LOCAL = '" + _aGerEmp2[nAlt3][02] + "'"
		
		//* Verifica se a Query Existe, se existir fecha
		If Select("TMP") > 0
			dbSelectArea("TMP")
			DbCloseArea()
		EndIf
		
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TMP", .F., .T.)
		
		dbSelectArea("TMP")
		If !Eof()
			//                       1      2        3         4          5            6                 7             8              9              10               11            12     13         14             15       16
			//aAdd(_aGerEmp2,{SD4->D4_COD,cLocal,SD4->D4_OP,cLocaliz,SD4->D4_DATA,SD4->D4_QTDEORI,SD4->D4_QUANT,SD4->D4_OPORIG,SD4->D4_LOTECTL,SD4->D4_NUMLOTE,SD4->D4_DTVALID,SD4->D4_TRT,0,aTelaProd[nREG][09],cLocalDes,cLocaliDe,.F.})
		If TMP->SDLEMP == 1
		 */     
		 If _lDel // Apaga caso todos os itens da grid estejam com quantidade e não ficará nada pendente

				aVetor	:=	{}
				aAdd(aVetor, {"D4_COD"		,_aGerEmp2[nAlt3][01]	,Nil})
				aAdd(aVetor, {"D4_LOCAL"	,_aGerEmp2[nAlt3][02]	,Nil})
				aAdd(aVetor, {"D4_OP"		,_aGerEmp2[nAlt3][03]	,Nil})
				aAdd(aVetor, {"D4_DATA"		,_aGerEmp2[nAlt3][05]  ,Nil})
				aAdd(aVetor, {"D4_QTDEORI"	,_aGerEmp2[nAlt3][06]  ,Nil})
				aAdd(aVetor, {"D4_QUANT"	,_aGerEmp2[nAlt3][07]	,Nil})
				aAdd(aVetor, {"D4_OPORIG"	,_aGerEmp2[nAlt3][08]	,Nil})
				If (lRastro)
					aAdd(aVetor, {"D4_LOTECTL"	,_aGerEmp2[nAlt3][09]	,Nil})
					aAdd(aVetor, {"D4_NUMLOTE"	,_aGerEmp2[nAlt3][10]	,NIL})
					aAdd(aVetor, {"D4_DTVALID"	,_aGerEmp2[nAlt3][11] 	,NIL})
					
				EndIf
				aAdd(aVetor, {"D4_TRT"		,_aGerEmp2[nAlt3][12]	,Nil})
				aAdd(aVetor, {"D4_QTSEGUM"	,0             		,Nil})
				aAdd(aVetor, {"ZERAEMP"     ,"S",NIL})
				
				MSExecAuto( { |x,y,z| mata380(x,y,z)}, aVetor,4, aEmpen)
				
				If (lMsErroAuto)
					MostraErro()
					Return(.F.)
				EndIf
			Endif
			//	DbSelectArea("TMP")
			//	DbSkip()
		//Endif
	Next
Endif

If Len(_aGerEmp2) > 0
	For nGer := 1 To Len(_aGerEmp2)
		
		_cDoc		:= ""
		_aItem		:= {}
		_aAuto		:= {}
		
		lRastro  := Rastro(_aGerEmp2[nGer][01])
		lLocaliz := Localiza(_aGerEmp2[nGer][01])
		
		DbSelectArea("SB1")
		dbSetOrder(1)
		
		lMsErroAuto := .F.
		
		If SB1->(MsSeek(xFilial("SB1")+_aGerEmp2[nGer][01]))
			
			_cDoc		:= GetSxENum("SD3","D3_DOC")
			CONFIRMSX8()
			
			If Len(_aAuto) == 0
				aAdd(_aAuto, {_cDoc, dDataBase} )
			EndIf
			//                       1      2        3         4          5            6                 7             8              9              10               11            12     13         14             15       16
			//aAdd(_aGerEmp2,{SD4->D4_COD,cLocal,SD4->D4_OP,cLocaliz,SD4->D4_DATA,SD4->D4_QTDEORI,SD4->D4_QUANT,SD4->D4_OPORIG,SD4->D4_LOTECTL,SD4->D4_NUMLOTE,SD4->D4_DTVALID,SD4->D4_TRT,0,aTelaProd[nREG][09],cLocalDes,cLocaliDe,.F.})
			
			
			aAdd(_aItem,{"D3_COD"		,_aGerEmp2[nGer][01]	,Nil})	//D3_COD ORIGEM ***
			aAdd(_aItem,{"D3_DESCRI"		,SB1->B1_DESC			,Nil})	//D3_DESCRI ORIGEM
			aAdd(_aItem,{"D3_UM"			,SB1->B1_UM				,Nil})	//D3_UM ORIGEM
			aAdd(_aItem,{"D3_LOCAL"		,_aGerEmp2[nGer][02]	,Nil})	//D3_Local ORIGEM
			aAdd(_aItem,{"D3_LOCALIZ"	,_aGerEmp2[nGer][04]	,Nil})	//D3_LocalIZ ORIGEM
			aAdd(_aItem,{"D3_COD"		,_aGerEmp2[nGer][01]	,Nil})	//D3_COD DESTINO ***
			aAdd(_aItem,{"D3_DESCRI"		,SB1->B1_DESC   		,Nil})	//D3_DESCRI DESTINO
			aAdd(_aItem,{"D3_UM"			,SB1->B1_UM  			,Nil})	//D3_UM DESTIBNO
			aAdd(_aItem,{"D3_LOCAL"		,_aGerEmp2[nGer][15]	,Nil})	//D3_Local DESTINO
			aAdd(_aItem,{"D3_LOCALIZ"	,_aGerEmp2[nGer][16]	,Nil})	//D3_LocalIZ DESTINO
			aAdd(_aItem,{"D3_NUMSERI"	,_aGerEmp2[nGer][14]    ,Nil})	//D3_NUMSERI
			aAdd(_aItem,{"D3_LOTECTL"	,_aGerEmp2[nGer][09]	,Nil})	//D3_LOTECTL
			aAdd(_aItem,{"D3_NUMLOTE"	,Criavar("D3_NUMLOTE")	,Nil})	//D3_NUMLOTE
			aAdd(_aItem,{"D3_DTVALID"	,_aGerEmp2[nGer][11]	,Nil})	//D3_DTVALID
			aAdd(_aItem,{"D3_POTENCI"	,Criavar("D3_POTENCI")	,Nil})	//D3_POTENCI
			aAdd(_aItem,{"D3_QUANT"		,1  					,Nil})	//D3_QUANT
			aAdd(_aItem,{"D3_QTSEGUM"	,Criavar("D3_QTSEGUM")	,Nil})	//D3_QTSEGUM
			aAdd(_aItem,{"D3_ESTORNO"	,Criavar("D3_ESTORNO")	,Nil})  //D3_ESTORNO
			aAdd(_aItem,{"D3_NUMSEQ"		,Criavar("D3_NUMSEQ")	,Nil})  //D3_NUMSEQ
			aAdd(_aItem,{"D3_LOTECTL"	,Criavar("D3_LOTECTL")	,Nil}) 	//D3_LOTECTL   - cLote
			aAdd(_aItem,{"D3_DTVALID"	,_aGerEmp2[nGer][11]	,Nil})	//D3_DTVALID
			aAdd(_aItem,{"D3_ITEMGRD"	,Criavar("D3_ITEMGRD")	,Nil})	//D3_ITEMGRD
			aAdd(_aItem,{"D3_OBS"		,Criavar("D3_OBS")		,Nil})	//D3_OBS
			aAdd(_aItem,{"D3_OPTRA"		,_aGerEmp2[nGer][01]    ,Nil})	//D3_OPTRA
			aAdd(_aAuto,_aItem)
			_aItem := {}
			
		EndIf
		
		If Len(_aAuto) > 0
			lMsErroAuto := .F.
			MSExecAuto( { |x,y| mata261(x,y) }, _aAuto, 3)
			If (lMsErroAuto)
				MostraErro()
				_lRet := .F.
			Else
				_cDoc  := Soma1(_cDoc,TamSX3("D3_DOC")[1])
				_aAuto := {}
				_lRet  := .T.
			EndIf
		EndIf
		
	Next
	
	For nGer2 := 1 To Len(_aGerEmp2)
		
		lRastro  := Rastro(_aGerEmp2[nGer2][01])
		lLocaliz := Localiza(_aGerEmp2[nGer2][01])
		
		aVetor   := {}
		aEmpen   := {}
		aTMP     := {}
		aErrAut  := {}
		cLocaliz := Criavar('DC_LOCALIZ')
		nREG     := 0
		dData    := dDatabase
		_lRet    := .T.
		
		_cMsg := ""
		_nDifEmp := 0
		
		aSavAtu := GetArea()
		aSavSD4 := SD4->(GetArea())
		
		cQryTmp2 := " SELECT MAX(D4_TRT) ULT_REVISAO "
		cQryTmp2 += "   FROM " + RetSqlName("SD4") + " SD4"
		cQryTmp2 += "   WHERE D4_FILIAL = '" + xFilial("SD4") + "'"
		cQryTmp2 += "   AND SD4.D4_COD  = '" + _aGerEmp2[nGer2][01] + "'"
		cQryTmp2 += "   AND SD4.D4_OP = '" + _aGerEmp2[nGer2][03] + "'"
		//cQryTmp += "    AND SD4.D4_LOCAL = '" + _aGerEmp2[nGer2][15] + "'"
		
		If Select("TRBREN2") <> 0
			dbSelectArea("TRBREN2")
			dbCloseArea()
		EndIf
		
		dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQryTmp2), "TRBREN2" , .T. , .F. )
		
		If !TRBREN2->(Eof())
			cTRT := Soma1(TRBREN2->ULT_REVISAO)
		Endif
		
		aVetor	:=	{}
		aAdd(aVetor, {"D4_COD"		,_aGerEmp2[nGer2][01]	,Nil})
		aAdd(aVetor, {"D4_LOCAL"	,_aGerEmp2[nGer2][15]	,Nil})
		aAdd(aVetor, {"D4_OP"		,_aGerEmp2[nGer2][03]	    ,Nil})
		aAdd(aVetor, {"D4_DATA"		,_aGerEmp2[nGer2][05]   , Nil})
		aAdd(aVetor, {"D4_QTDEORI"	,1,Nil})
		aAdd(aVetor, {"D4_QUANT"	,1,Nil})
		aAdd(aVetor, {"D4_OPORIG"	,_aGerEmp2[nGer2][08]	,Nil})
		If (lRastro)
			aAdd(aVetor, {"D4_LOTECTL"	,_aGerEmp2[nGer2][09]	,Nil})
			aAdd(aVetor, {"D4_NUMLOTE"	,_aGerEmp2[nGer2][10]	,NIL})
			aAdd(aVetor, {"D4_DTVALID"	,_aGerEmp2[nGer2][11] 	,NIL})
		EndIf
		aAdd(aVetor, {"D4_TRT"		,cTRT				,Nil})
		aAdd(aVetor, {"D4_QTSEGUM"	,0             		,Nil})
		
		If (lLocaliz)
			aAdd(aEmpen,{   1,;   	// SD4->D4_QUANT
			_aGerEmp2[nGer2][16],;   	// DC_LocalIZ         - paTransf[nREG][06]
			_aGerEmp2[nGer2][14],;   	// DC_NUMSERI
			0               ,;    	// D4_QTSEGUM
			.F.})
			
		EndIf
		
		MSExecAuto( { |x,y,z| mata380(x,y,z)}, aVetor, 3, aEmpen)
		
		If (lMsErroAuto)
			MostraErro()
			Return(.F.)
		EndIf
		aEmpen   := {}
		
		RestArea(aSavSD4)
		RestArea(aSavAtu)
	Next
Endif

If Len(_aGerEmp2) > 0
	For Del2 := 1 To Len(_aGerEmp2)
		
		DbSelectArea("SD4")
		DbSetOrder(1) //D4_FILIAL, D4_COD, D4_OP, D4_TRT, D4_LOTECTL, D4_NUMLOTE, R_E_C_N_O_, D_E_L_E_T_
		If SD4->(MSSeek(xFilial("SD4")+_aGerEmp2[Del2][01]+_aGerEmp2[Del2][03]+_aGerEmp2[Del2][12]+_aGerEmp2[Del2][09]+_aGerEmp2[Del2][10]))
			cUpdSd4a := " DELETE FROM "+RetSqlName("SD4")
			cUpdSd4a += " WHERE D_E_L_E_T_= ' ' AND D4_OP= '"+SD4->D4_OP+"' AND D4_LOTECTL = '"+ SD4->D4_LOTECTL+"' AND D4_LOCAL = '"+SD4->D4_LOCAL+"' AND D4_COD = '"+SD4->D4_COD+"'  "
			cUpdSd4a += " AND D4_QUANT = 0 "
			TCSQLEXEC(cUpdSd4a)
			
		Endif
	Next
Endif

Return(.T.)



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OkExcel    ³ Autor ³ Edson Estevam             ³ Data ³ 19/01/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Confirmação para Iniciar o Processo Parcial.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ _lRet => Executado (.T./.F.)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function OkExcel()

Local _lRet 	 	:= .T.
Local _aCabec  := {"PRODUTO","DESCRICAO","ARMAZEM","ENDEREÇO","LOTE","SAL_PAGAMENTO","SALDO_ATUAL","NUMERO_SERIE"}
Local _aItExce := {}

ProcRegua(4)

For nL := 1 To Len(aColsEX)

AADD(_aItExce,{aColsEX[nL][01],aColsEX[nL][02],aColsEX[nL][03],aColsEX[nL][08],aColsEX[nL][06],aColsEX[nL][05],aColsEX[nL][07],aColsEX[nL][09]})

Next

If Len(_aItExce) > 0
	DlgToExcel({{"ARRAY","Itens a Transferir",_aCabec,_aItExce}})
EndIf

Return(_lRet)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ SldLote    ³ Autor ³ Flavio Valentin           ³ Data ³ 05/12/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que busca saldo por lote.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCod 	=> Codigo do Produto;                                   ³±±
±±³          ³ cLocal 	=> Codigo do Produto;                                   ³±±
±±³          ³ pLote 	=> Reservado.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ nRet => Saldo do lote.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function SldLote(cCod, cLocal, pLote)

Local nRET       := 0
Local cQuery     := ""
Local cAliasSB8  := ""
Local lEmpPrev   := If(SuperGetMV("MV_QTDPREV")== "S",.T.,.F.)
Local lVldDtLote := SuperGetMV("MV_VLDLOTE",.F.,.T.)

SB8->(dbSetOrder(1))
cAliasSB8 := GetNextAlias()

cQuery := "SELECT (B8_SALDO-B8_EMPENHO) SALDO FROM " + RetSqlName( "SB8" ) + " SB8 "
cQuery += "WHERE "
cQuery += "B8_FILIAL='"  + xFilial( "SB8" )	+ "' AND "
cQuery += "B8_PRODUTO='" + cCod            	+ "' AND "
cQuery += "B8_Local='"   + cLocal          	+ "' AND "
cQuery += Iif(lVldDtLote,"B8_DATA <= '" + DTOS(dDataBase) 	+ "' AND ","")
cQuery += "D_E_L_E_T_=' ' "
cQuery += "ORDER BY " + SqlOrder( SB8->( IndexKey() ) )

cQuery := ChangeQuery( cQuery )

dbUseArea( .t., "TOPCONN", TcGenQry( ,,cQuery ), "TMPSB8", .f., .t. )

WHILE !EOF()
	nRET += TMPSB8->SALDO      //  SB8Saldo(NIL,NIL,NIL,NIL,"TMPSB8",lEmpPrev,.T.)
	dbSkip()
EndDo

TMPSB8->(dbCloseArea())

Return(nRet)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ XAVISO     ³ Autor ³ Flavio Valentin           ³ Data ³ 05/12/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que emite uma notificacao na tela.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function XAVISO()
MsgAlert("Anteção!!!" +CRLF+CRLF+;
"Ocorreu um problema na rotina automática, por não ter concluído o processo"+CRLF+;
"será estornado os registros. Informe o setor de TI, referente o error log"+CRLF+;
"apresentado.")
Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ chamapar   ³ Autor ³ Flavio Valentin           ³ Data ³ 05/12/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que chama o parametro de pergunta (SX1) .                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil.                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function chamapar()

FCRIAPERG()//Funcao que cria o grupo de perguntas (SX1)
Pergunte(cPerg,.T.) //Funcao que carrega o grupo de perguntas
nmvpar01	:= mv_par01
cmvpar02	:= mv_par02
cmvpar03	:= mv_par03

Return(Nil)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CriaBkp    ³ Autor ³ Flavio Valentin           ³ Data ³ 05/12/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que cria o backup da SD4 (Empenho de OP).                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ pOP => Numero da Ordem de Producao.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function CriaBkp(pOP)

Local aAreaSD4	:= GetArea()
Local cQry	   	:= ""
Local nRet	   	:= 0
Local aStru    	:= SZ1->(dbStruct())

While SD4->(!Eof()) .And. (SD4->D4_OP==pOP)
	dbSelectArea("SZ1")
	SZ1->(RecLock("SZ1",.T.))
	SZ1->Z1_FILIAL 	:= SD4->D4_FILIAL
	SZ1->Z1_COD 	:= SD4->D4_COD
	SZ1->Z1_Local	:= SD4->D4_LOCAL
	SZ1->Z1_OP		:= SD4->D4_OP
	SZ1->Z1_DATA	:= SD4->D4_DATA
	SZ1->Z1_QSUSP	:= SD4->D4_QSUSP
	SZ1->Z1_SITUACA	:= SD4->D4_SITUACA
	SZ1->Z1_QTDEORI	:= SD4->D4_QTDEORI
	SZ1->Z1_QUANT	:= SD4->D4_QUANT
	SZ1->Z1_TRT		:= SD4->D4_TRT
	SZ1->Z1_LOTECTL	:= SD4->D4_LOTECTL
	SZ1->Z1_NUMLOTE	:= SD4->D4_NUMLOTE
	SZ1->Z1_DTVALID	:= SD4->D4_DTVALID
	SZ1->Z1_OPORIG	:= SD4->D4_OPORIG
	SZ1->Z1_QTSEGUM	:= SD4->D4_QTSEGUM
	SZ1->Z1_ORDEM	:= SD4->D4_ORDEM
	SZ1->Z1_POTENCI	:= SD4->D4_POTENCI
	SZ1->Z1_NUMLOTE	:= SD4->D4_NUMLOTE
	If SD4->(FieldPos("D4_PROCES")) > 0
		SZ1->Z1_PROCES	:= SD4->D4_PROCES
	EndIf
	SZ1->Z1_SEQ		:= SD4->D4_SEQ
	SZ1->Z1_NUMPVBN	:= SD4->D4_NUMPVBN
	SZ1->Z1_ITEPVBN	:= SD4->D4_ITEPVBN
	SZ1->Z1_CODLAN	:= SD4->D4_CODLAN
	SZ1->Z1_SLDEMP	:= SD4->D4_SLDEMP
	SZ1->Z1_SLDEMP2	:= SD4->D4_SLDEMP2
	SZ1->Z1_EMPROC	:= SD4->D4_EMPROC
	SZ1->Z1_CBTM	:= SD4->D4_CBTM
	If SD4->(FieldPos("D4_SEQFIFO")) > 0
		SZ1->Z1_SEQFIFO	:= SD4->D4_SEQFIFO
	EndIf
	SZ1->(MsUnlock())
	SD4->(dbSkip())
EndDo

RestArea(aAreaSD4)

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CriaSBE    ³ Autor ³ Flavio Valentin           ³ Data ³ 05/12/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao Cria Endereçamento Fisico (tabela SBE).                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ pArmProd => Armazem do Produto.                                  ³±±
±±³          ³ pEndProd => Endereco.                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Flavio V.     ³05/12/18³Substituido o Reclock pela rotina automatica.        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function CriaSBE(pArmProd,pEndProd)

Local aArea    	:= GetArea()
Local _aVetor	:= {}
Local _nOpc		:= 3

//So grava o endereco, se este nao estiver cadastrado no sistema.
dbSelectArea("SBE")
dbSetOrder(1) //BE_FILIAL, BE_LOCAL, BE_LOCALIZ, BE_ESTFIS, R_E_C_N_O_, D_E_L_E_T_
If SBE->(MSSeek(xFilial("SBE")+pArmProd+pEndProd))
	//Conout("PERPCP01 - Endereco: "+AllTrim(RetTitle("BE_LOCAL"))+": "+AllTrim(pArmProd)+", "+AllTrim(RetTitle("BE_LOCALIZ"))+": "+AllTrim(pEndProd)+" ja cadastrado.")
	Return
EndIf

_aVetor	:= {}
aAdd(_aVetor,{"BE_FILIAL"	,xFilial("SBE")				,Nil})
aAdd(_aVetor,{"BE_LOCAL"	,pArmProd					,Nil})
aAdd(_aVetor,{"BE_LOCALIZ"	,pEndProd					,Nil})
aAdd(_aVetor,{"BE_DESCRIC"	,"Localizacao: "+pEndProd	,Nil})
aAdd(_aVetor,{"BE_PRIOR"	,'ZZZ'						,Nil})
aAdd(_aVetor,{"BE_STATUS"	,'1'						,Nil})

If Len(_aVetor) > 0
	lMsErroAuto := .F.
	MATA015(_aVetor, _nOpc)
	If (lMsErroAuto)
		//Conout("PERPCP01 - Erro ao cadastrar o Endereco: "+AllTrim(RetTitle("BE_LOCAL"))+": "+AllTrim(pArmProd)+", "+AllTrim(RetTitle("BE_LOCALIZ"))+": "+AllTrim(pEndProd))
		Return
	Else
		//Conout("PERPCP01 - Endereco: "+AllTrim(RetTitle("BE_LOCAL"))+": "+AllTrim(pArmProd)+", "+AllTrim(RetTitle("BE_LOCALIZ"))+": "+AllTrim(pEndProd)+" cadastrado com sucesso.")
	EndIf
EndIf

RestArea( aArea )

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ F3Lote     ³ Autor ³ Flavio Valentin           ³ Data ³ 05/12/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que carrega a Tela de Consulta de Lote.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ _cParam1 	=> Reservado;                                       ³±±
±±³          ³ _cParam2 	=> Reservado;                                       ³±±
±±³          ³ _cParam3 	=> Reservado;                                       ³±±
±±³          ³ cProg 		=> Nome do Programa;                                ³±±
±±³          ³ cCod 		=> Codigo do Produto;                               ³±±
±±³          ³ cLocal 		=> Almoxarifado;                                    ³±±
±±³          ³ lParam 		=> Reservado;                                       ³±±
±±³          ³ cLocaliz 	=> Endereco Fisico;                                 ³±±
±±³          ³ nLoteCtl 	=> Reservado;                                       ³±±
±±³          ³ cOP 			=> Reservado;                                       ³±±
±±³          ³ lLoja		=> Reservado;                                       ³±±
±±³          ³ lAtNumLote	=> Reservado.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRETLTF3 => Numero do lote localizado.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function F3Lote(_cParam1, _cParam2, _cParam3, cProg, cCod, cLocal, lParam, cLocaliz, nLoteCtl, cOP, lLoja, lAtNumLote)

Local aStruSB8		:={}
Local aArrayF4		:={}
Local aHeaderF4		:={}
Local nOpt1			:= 1
Local nX
Local cVar
Local cSeek
Local cWhile
Local nEndereco
Local cAlias		:= Alias()
Local nOrdem		:= IndexOrd()
Local nRec			:= RecNo()
Local nValA440		:= 0
Local nHdl			:= GetFocus()
Local cCpo
Local oDlg2
Local cCadastro
Local nOpca
Local cLoteAnt		:= ""
Local cLoteFor		:= ""
Local dDataVali		:= ""
Local dDataCria		:= ""
Local lAdd			:= .F.
Local nSalLote		:= 0
Local nSalLote2		:= 0
Local nPotencia		:= 0
Local nPos2			:= 7
Local nPos3			:= 5
Local nPos4			:= 9
Local nPos5			:= 10
Local nPos6			:= 11
Local nPos7			:= 12
Local nPos8			:= 13
Local aTamSX3		:= {}
Local nOAT
Local aCombo1		:= {"Lote","Validade","Lote Fornecedor"}
Local aPosObj		:= {}
Local aObjects		:= {}
Local aSize			:= MsAdvSize(.F.)

Local cCombo1			:= ""
Local oCombo1
Local lRastro 			:= Rastro(cCod,"S")
Local aAreaSBF			:= {}
Local cQuery    		:= ""
Local cAliasSB8 		:= "SB8"
Local nLoop     		:= 0
Local aUsado     		:= {}
Local cLote241   		:= ''
Local cSLote241  		:= ''
Local lLote      		:= .F.
Local lSLote     		:= .F.
Local nPos       		:= 0
Local nPCod241   		:= 0
Local nPLoc241   		:= 0
Local nPLote241  		:= 0
Local nPSLote241 		:= 0
Local nQuant241  		:= 0
Local nPQuant241 		:= 0
Local nPCod261   		:= 0
Local nPLoc261   		:= 0
Local nPosLt261  		:= 0
Local nPSlote261 		:= 0
Local nQuant261  		:= 0
Local nPosQuant  		:= 0
Local nPosQtdLib 		:= 0
Local nMultiplic 		:= 1
Local _lRet 			:= .T.
Local lSelLote 			:= (SuperGetMV("MV_SELLOTE") == "1")
Local lMTF4Lote			:= .T.
Local lExisteF4Lote 	:= ExistBlock("F4LoteHeader")
Local cNumDoc  			:= ""
Local cSerie   			:= ""
Local cFornece 			:= ""
Local cLoja    			:= ""
Local lEmpPrev 			:= If(SuperGetMV("MV_QTDPREV")== "S",.T.,.F.)
Local nSaldoCons		:= 0
Local cReadVar 			:= ReadVar()
Local lVldDtLote 		:= SuperGetMV("MV_VLDLOTE",.F.,.T.)
Local uVarRet

Private uPVarRet
Private cPReadVar

Default cLocaliz		:= ""
Default cOP     		:= ""
Default nLoteCtl		:= 1
Default lLoja			:= .F.
Default lAtNumLote 		:= .T.

cCpo   := ReadVar()
lParam := Iif(lParam== NIL, .T., lParam)

// Obtem o conteúdo do campo utilizado na Consulta Padrao Customizada
uVarRet   := GetMemVar(cReadVar)
uPVarRet  := uVarRet
cPReadVar := cReadVar

SB1->(dbSetOrder(1))//B1_FILIAL, B1_COD, R_E_C_N_O_, D_E_L_E_T_
SB1->(MsSeek(xFilial("SB1")+cCod))

lLote  := Rastro(cCod)
lSLote := Rastro(cCod, 'S')

If !(lLote)
	MsgAlert("Produto não utiliza rastro")
	Return(Nil)
EndIf

If !(lRastro)
	nPos2:=1;nPos3:=5;nPos4:=8;nPos5:=9;nPos6:=10;nPos7:=11;nPos8:=12
EndIf

If cCpo != "M->D4_NUMLOTE" .And. cCpo != "M->D4_LOTECTL"
	Return(Nil)
EndIf

// Verifica se o arquivo que chamou a consulta tem potencia para informar no lote
If Type("nPosPotenc") != "N"
	nPosPotenc := 0
EndIf

// Verifica o arquivo a ser pesquisado                          ?
dbSelectArea("SB8")
dbSetOrder(1) //B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_DTVALID, B8_LOTECTL, B8_NUMLOTE, R_E_C_N_O_, D_E_L_E_T_
cSeek := cCod+cLocal
MSSeek(xFilial("SB8")+cSeek)
If !Found()
	MsgAlert("Não existe Saldo por Lote para este produto")
	dbSelectArea(cAlias)
	dbSetOrder(nOrdem)
	dbGoto(nRec)
	Return(Nil)
EndIf

// Obtem o numero de casas decimais que dever ser utilizado na
// consulta.
aTamSX3 := TamSX3(Substr(cCpo,4,3)+"QUANT")
If Empty(aTamSX3)
	aTamSX3 := TamSX3("B8_SALDO")
EndIf

// Caso utilize controle de enderecamento e tenha endereco
// preenchido.
If Localiza(cCod) .And. !Empty(cLocaliz)
	dbSelectArea("SB8")
	dbSetOrder(3)//B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_LOTECTL, B8_NUMLOTE, B8_DTVALID, R_E_C_N_O_, D_E_L_E_T_
	dbSelectArea("SBF")
	aAreaSBF := GetArea()
	dbSetOrder(1)
	cSeek := xFilial("SBF")+cLocal+cLocaliz+cCod
	MSSeek(cSeek)
	Do While !Eof() .And. cSeek == BF_FILIAL+BF_Local+BF_LocalIZ+BF_PRODUTO
		If SB8->(MSSeek(xFilial("SB8")+SBF->BF_PRODUTO+SBF->BF_Local+SBF->BF_LOTECTL+If(!Empty(SBF->BF_NUMLOTE),SBF->BF_NUMLOTE,"")))
			If (lVldDtLote) .And. (SB8->B8_DATA > dDataBase)
				SBF->(dbSkip())
				Loop
			EndIf
			If !Empty(SBF->BF_NUMLOTE) .And. (lRastro)
				aAdd(aArrayF4, F4LoteArray(cProg, lSLote, "SBF", "SBF", {SBF->BF_NUMLOTE,SBF->BF_PRODUTO,Str(SBFSaldo(),14,aTamSX3[2]),Str(SBFSaldo(,,,.T.),14,aTamSX3[2]),SB8->B8_DTVALID,SB8->B8_LOTEFOR,SBF->BF_LOTECTL,SB8->B8_DATA,SB8->B8_POTENCI,SBF->BF_LocalIZ,SBF->BF_NUMSERI}))
			Else
				aAdd(aArrayF4, F4LoteArray(cProg, lSLote, "SBF", "SBF", {SBF->BF_LOTECTL,SBF->BF_PRODUTO,Str(SBFSaldo(),14,aTamSX3[2]),Str(SBFSaldo(,,,.T.),14,aTamSX3[2]),SB8->B8_DTVALID,SB8->B8_LOTEFOR,SB8->B8_DATA,SB8->B8_POTENCI,SBF->BF_LocalIZ,SBF->BF_NUMSERI}))
			EndIf
		EndIf
		dbSelectArea("SBF")
		dbSkip()
	EndDo
	RestArea(aAreaSBF)
ElseIf (lSLote)
	SB8->(dbSetOrder(1))//B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_DTVALID, B8_LOTECTL, B8_NUMLOTE, R_E_C_N_O_, D_E_L_E_T_
	cAliasSB8 := GetNextAlias()
	aStruSB8 := SB8->(dbStruct())
	
	cQuery := "SELECT * FROM " + RetSqlName( "SB8" ) + " SB8 "
	cQuery += "WHERE "
	cQuery += "B8_FILIAL='"  + xFilial( "SB8" )	+ "' AND "
	cQuery += "B8_PRODUTO='" + cCod            	+ "' AND "
	cQuery += "B8_Local='"   + cLocal          	+ "' AND "
	cQuery += Iif(lVldDtLote,"B8_DATA <= '" + DTOS(dDataBase) 	+ "' AND ","")
	cQuery += "D_E_L_E_T_=' ' "
	cQuery += "ORDER BY " + SqlOrder( SB8->( IndexKey() ) )
	
	cQuery := ChangeQuery( cQuery )
	
	dbUseArea( .t., "TOPCONN", TcGenQry( ,,cQuery ), cAliasSB8, .f., .t. )
	
	For nLoop := 1 To Len(aStruSB8)
		If aStruSB8[ nLoop, 2 ] <> "C"
			TcSetField( cAliasSB8, aStruSB8[nLoop,1],	aStruSB8[nLoop,2],aStruSB8[nLoop,3],aStruSB8[nLoop,4])
		EndIf
	Next nLoop
	
	While !(cAliasSB8)->(Eof()) .And. xFilial("SB8")+cSeek == (cAliasSB8)->B8_FILIAL+(cAliasSB8)->B8_PRODUTO+(cAliasSB8)->B8_Local
		If !(cProg $ "A100/A240/A440/A241/A270/A465/A685/AT460")
			If SB8Saldo(NIL,NIL,NIL,NIL,cAliasSB8,lEmpPrev,.T.,Iif(cProg=="A380",dDataBase,Nil)) > 0
				aAdd(aArrayF4, F4LoteArray(cProg, lSLote, "SB8", cAliasSB8, {(cAliasSB8)->B8_NUMLOTE, (cAliasSB8)->B8_PRODUTO, Str(SB8Saldo(NIL,NIL,NIL,NIL,cAliasSB8,lEmpPrev,.T.),14,aTamSX3[2]), Str(SB8Saldo(,,,.T.,cAliasSB8,lEmpPrev,.T.),14,aTamSX3[2]), (cAliasSB8)->B8_DTVALID, (cAliasSB8)->B8_LOTEFOR, (cAliasSB8)->B8_LOTECTL, (cAliasSB8)->B8_DATA,(cAliasSB8)->B8_POTENCI}))
			EndIf
		EndIf
		(cAliasSB8)->( dbSkip() )
	EndDo
	
	(cAliasSB8)->(dbCloseArea())
	dbSelectArea("SB8")
	
Else
	SB8->(dbSetOrder(3))//B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_LOTECTL, B8_NUMLOTE, B8_DTVALID, R_E_C_N_O_, D_E_L_E_T_
	cAliasSB8 := GetNextAlias()
	
	aStruSB8 := SB8->(dbStruct())
	
	cQuery := "SELECT * FROM " + RetSqlName( "SB8" ) + " SB8 "
	cQuery += "WHERE "
	cQuery += "B8_FILIAL='"  + xFilial( "SB8" )	+ "' AND "
	cQuery += "B8_PRODUTO='" + cCod            	+ "' AND "
	cQuery += "B8_Local='"   + cLocal          	+ "' AND "
	cQuery += Iif(lVldDtLote,"B8_DATA <= '" + DTOS(dDataBase) 	+ "' AND ","")
	cQuery += "D_E_L_E_T_=' ' "
	cQuery += "ORDER BY " + SqlOrder( SB8->( IndexKey() ) )
	
	cQuery := ChangeQuery( cQuery )
	
	dbUseArea( .t., "TOPCONN", TcGenQry( ,,cQuery ), cAliasSB8, .f., .t. )
	
	For nLoop := 1 To Len(aStruSB8)
		If aStruSB8[nLoop, 2] <> "C"
			TcSetField( cAliasSB8, aStruSB8[nLoop,1],	aStruSB8[nLoop,2],aStruSB8[nLoop,3],aStruSB8[nLoop,4])
		EndIf
	Next nLoop
	
	While !(cAliasSB8)->( Eof()) .And. xFilial("SB8")+cSeek == (cAliasSB8)->B8_FILIAL+(cAliasSB8)->B8_PRODUTO+(cAliasSB8)->B8_Local
		cLoteAnt	:= (cAliasSB8)->B8_LOTECTL
		cLoteFor	:= (cAliasSB8)->B8_LOTEFOR
		dDataVali	:= (cAliasSB8)->B8_DTVALID
		dDataCria	:= (cAliasSB8)->B8_DATA
		nPotencia	:= (cAliasSB8)->B8_POTENCI
		cNumDoc  	:= (cAliasSB8)->B8_DOC
		cSerie   	:= (cAliasSB8)->B8_SERIE
		cFornece 	:= (cAliasSB8)->B8_CLifOR
		cLoja    	:= (cAliasSB8)->B8_LOJA
		
		lAdd	  := .F.
		nSalLote  := 0
		nSalLote2 := 0
		
		While !(cAliasSB8)->(Eof()) .And. xFilial("SB8")+cSeek+cLoteAnt == (cAliasSB8)->B8_FILIAL+(cAliasSB8)->B8_PRODUTO+(cAliasSB8)->B8_Local+(cAliasSB8)->B8_LOTECTL
			If !(cProg $ "A100/A240/A440/A241/A242/A270/AT460/A685")
				nSalLote  += SB8Saldo(NIL,NIL,NIL,NIL,cAliasSB8,lEmpPrev,.T.,dDataBase)
				nSalLote2 += SB8Saldo(,,,.T.,cAliasSB8,lEmpPrev,.T.,dDataBase)
			EndIf
			(cAliasSB8)->(dbSkip())
		EndDo
		If QtdComp(nSalLote) > QtdComp(0)
			aAdd(aArrayF4, F4LoteArray(cProg, lSLote, "", "", {cLoteAnt,cCod,Str(nSalLote,aTamSX3[1],aTamSX3[2]),Str(nSalLote2,aTamSX3[1],aTamSX3[2]), (dDataVali), cLoteFor, dDataCria,nPotencia,cNumDoc,cSerie,cFornece,cLoja}))
		EndIf
	EndDo
	
	(cAliasSB8)->(dbCloseArea())
	dbSelectArea("SB8")
	
EndIf

If (lMTF4Lote)
	If !Empty(aArrayF4)
		
		aAdd( aObjects, { 100, 100, .t., .t.,.t. } )
		aAdd( aObjects, { 100, 30, .t., .f. } )
		
		aSize[ 3 ] -= 50
		aSize[ 4 ] -= 50
		
		aSize[ 5 ] -= 100
		aSize[ 6 ] -= 100
		
		aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 2 }
		aPosObj := MsObjSize( aInfo, aObjects )
		
		cCadastro := "Saldos por Lote"
		nOpca := 0
		
		DEFINE MSDIALOG oDlg2 TITLE cCadastro From aSize[7],00 To aSize[6],aSize[5] OF oMainWnd PIXEL
		@ 7.1,.4 Say "Pesquisa Por: "
		If (lSLote)
			aHeaderF4 := {"Sub-Lote","Produto","Saldo Atual","Saldo Atual 2aUM","Validade","Lote Fornecedor","Lote","Dt Emissao","Potencia","Nota Fiscal","Serie","Cliente/Fornecedor","Loja"}
			aHeaderF4 := RetExecBlock("F4LoteHeader", {cProg, lSLote, aHeaderF4}, "A", aHeaderF4)
			
			If (lExisteF4Lote)
				AjustaPosHeaderF4(aHeaderF4, @nPos2, @nPos3, @nPos4, @nPos5, @nPos6, @nPos7, @nPos8)
			EndIf
			
			oQual := VAR := cVar := TWBrowse():New( aPosObj[1][1], aPosObj[1][2], aPosObj[1][3], aPosObj[1][4],,aHeaderF4,,,,,,,{|nRow,nCol,nFlags|(nOpca := 1,oDlg2:End())},,,,,,, .F.,, .T.,, .F.,,, )
			oQual:SetArray(aArrayF4)
			oQual:bLine := { || aArrayF4[oQual:nAT] }
		Else
			aHeaderF4 := {"Lote","Produto","Saldo Atual","Saldo Atual 2aUM","Validade","Lote Fornecedor","Dt Emissao","Potencia","Nota Fiscal","Serie","Cliente/Fornecedor","Loja"}
			aHeaderF4 := RetExecBlock("F4LoteHeader", {cProg, lSLote, aHeaderF4}, "A", aHeaderF4)
			
			If (lExisteF4Lote)
				AjustaPosHeaderF4(aHeaderF4, @nPos2, @nPos3, @nPos4, @nPos5, @nPos6, @nPos7, @nPos8)
			EndIf
			
			oQual := VAR := cVar := TWBrowse():New( aPosObj[1][1], aPosObj[1][2], aPosObj[1][3], aPosObj[1][4],,aHeaderF4,,,,,,,{|nRow,nCol,nFlags|(nOpca := 1,oDlg2:End())},,,,,,, .F.,, .T.,, .F.,,, )
			oQual:SetArray(aArrayF4)
			oQual:bLine := { || aArrayF4[oQual:nAT] }
		EndIf
		@ aPosObj[2][1]+10,aPosObj[2][2] Say "Pesquisa Por: " PIXEL //
		@ aPosObj[2][1]+10,aPosObj[2][2]+50 MSCOMBOBOX oCombo1 VAR cCombo1 ITEMS aCombo1 SIZE 100,44  VALID F4LotePesq(cCombo1,aArrayF4,oQual,oCombo1) OF oDlg2 FONT oDlg2:oFont PIXEL
		
		DEFINE SBUTTON FROM aPosObj[2][1]+10 ,aPosObj[2][4]-58  TYPE 1 ACTION (nOpca := 1,oDlg2:End()) ENABLE OF oDlg2
		DEFINE SBUTTON FROM aPosObj[2][1]+10 ,aPosObj[2][4]-28   TYPE 2 ACTION oDlg2:End() ENABLE OF oDlg2
		
		ACTIVATE MSDIALOG oDlg2 VALID (nOAT := oQual:nAT,.t.) CENTERED
		
		If (nOpca == 1)
			If (lSLote)
				nEndereco := Ascan(aGets,{ |x| Subs(x,9,10) == "D4_NUMLOTE" } )
				If (nEndereco > 0)
					aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := aArrayF4[nOAT][1]
					M->D4_NUMLOTE := aArrayF4[nOAT][1]
				EndIf
			EndIf
			nEndereco := Ascan(aGets,{ |x| Subs(x,9,10) == "D4_LOTECTL"})
			If (nEndereco > 0)
				aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := aArrayF4[nOAT][nPos2]
				M->D4_LOTECTL := aArrayF4[nOAT][nPos2]
			EndIf
			nEndereco := Ascan(aGets,{ |x| Subs(x,9,10) == "D4_DTVALID" } )
			If (nEndereco > 0)
				aTela[Val(Subs(aGets[nEndereco],1,2))][Val(Subs(aGets[nEndereco],3,1))*2] := aArrayF4[nOAT][nPos3]
				M->D4_DTVALID :=  aArrayF4[nOAT][nPos3]
			EndIf
			uVarRet := aArrayF4[nOAT][nPos2]
			cRETLTF3 := uVarRet
		EndIf
	Else
		MsgAlert('Atenção! Não há saldo em lote para este produto')
	EndIf
EndIf

//------------------------------------------------------------------------------------------------
// Atualiza a Variável de Memória com o Conteúdo do Retorno
SetMemVar(cReadVar,cRETLTF3)
//------------------------------------------------------------------------------------------------
// Força a atualização dos Componentes
SysRefresh(.T.)

dbSelectArea(cAlias)
dbSetOrder(nOrdem)
dbGoto(nRec)
//SetFocus(nHdl)

Return(cRETLTF3)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RETLOTF3   ³ Autor ³ Flavio Valentin           ³ Data ³ 05/12/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao usada na Consulta Padrao Especifica.                      ³±±
±±³          ³ *Necessario criar para ser adicionado no retorno da consulta     ³±±
±±³          ³  padrao.                                                         ³±±
±±³          ³ *Deve ser adicionado no retorno da consulta especifica.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRETLTF3 => Numero do lote localizado.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
User Function RETLOTF3()

Return(cRETLTF3)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ SHOWF3     ³ Autor ³ Flavio Valentin           ³ Data ³ 05/12/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao chamada da rotina consulta especifica F3.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
User Function SHOWF3()

Local aSHOW  := GetArea()
Local cCOD   := oBrwSld:aCOLS[oBrwSld:nAT][1]
Local cLOCL  := oBrwSld:aCOLS[oBrwSld:nAT][3]
//Local nHdl	 := GetFocus()

Private cLoteAnt   := Criavar("D4_NUMLOTE")
Private cLotCtlAnt := Criavar("D4_LOTECTL")
Private cLocal     := Criavar("D4_LOCAL")
Private nQtdAnt    := 0
Private nQtdAnt2UM := 0
Private nQtdOriAnt := 0
Private aAlter     := {}
Private lPerSoZero := .F.
Private aTELA[0,0],aGETS[0]

dbSelectArea('SB1')
dbSetOrder(1)//B1_FILIAL, B1_COD, R_E_C_N_O_, D_E_L_E_T_
If MSSeek(xFilial('SB1')+cCOD)
	dbSelectArea("SD4")
	dbSetOrder(2)//D4_FILIAL, D4_OP, D4_COD, D4_LOCAL, R_E_C_N_O_, D_E_L_E_T_
	If MSSeek(xFilial('SD4')+cGOp+cCOD+cLOCL)
		RegtoMemory('SD4',.F.,.F.)
		If (ReadVar() == "M->D4_LOTECTL")
			cProg := "A380"
			//F4Lote(,,,   "A380",M->D4_COD,M->D4_LOCAL)
			cRETLTF3 := F3Lote(,,,"A380",M->D4_COD, SB1->B1_LOCPAD)   // ADICONADO TEMPORARIO 14/08
			oBrwSld:aCOLS[oBrwSld:nAT][6] := cRETLTF3
		EndIf
	EndIf
Else
	MsgInfo('Produto não encontrado')
EndIf

//SetFocus(nHdl)

RestArea(aSHOW)

Return(.T.)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ExecTran   ³ Autor ³ Flavio Valentin           ³ Data ³ 05/12/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que Executa Transferencia de itens com Saldo.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ paTransf => Array contendo os registros para realizar a          ³±±
±±³          ³ transferencia e exclusao do empenho.                             ³±±
±±³          ³ plSemSld => .T. (Sem saldo).                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function ExecTran(paTransf,plSemSld)

Default plSemSld := .F.

ProcRegua(3)

If !(plSemSld)
	// Será excluído o Empenho armazem 01
	IncProc("Excluindo empenho do armazem 01")
	//Conout('excluindo empenho')
	If !MntEmp(paTransf, 5)
		Return(.F.)
	EndIf
	
	// Deverá ser realizado a Transferência
	IncProc("Realizando transferência de armazem")
	//Conout('executando transferencia')
	If !TransArm(paTransf, 3, plSemSld)
		Return(.F.)
	EndIf
EndIf
// Gerando Empenhos armazem 02
IncProc("Gerando o empenho para novo armazem")
//Conout('gerando empenhos no 02')
If !MntEmp(paTransf, If(!plSemSld,3,4))
	Return(.F.)
EndIf

Return(.T.)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FCRIAPERG  ³ Autor ³ Flavio Valentin           ³ Data ³ 12/12/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualizacao do SX1 - Perguntas.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil.                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function FCRIAPERG()

Local _aArea    	:= GetArea()
Local _aAreaDic 	:= SX1->(GetArea())
Local _aEstrut  	:= {}
Local _aStruDic 	:= SX1->(dbStruct())
Local _aSX1   		:= {}
Local _nI       	:= 0
Local _nJ       	:= 0
Local _nTam1    	:= Len(SX1->X1_GRUPO)
Local _nTam2    	:= Len(SX1->X1_ORDEM)
Local _cGrpPerg		:= cPerg

//Se nao tiver grupo de perguntas informado, sai da rotina.
If Empty(_cGrpPerg)
	Return(Nil)
EndIf

_aEstrut := { 	"X1_GRUPO"  , "X1_ORDEM"  , "X1_PERGUNT", "X1_PERSPA" , "X1_PERENG" , "X1_VARIAVL", "X1_TIPO"   	, ;
"X1_TAMANHO", "X1_DECIMAL", "X1_PRESEL" , "X1_GSC"    , "X1_VALID"  , "X1_VAR01"  , "X1_DEF01"  	, ;
"X1_DEFSPA1", "X1_DEFENG1", "X1_CNT01"  , "X1_VAR02"  , "X1_DEF02"  , "X1_DEFSPA2", "X1_DEFENG2"	, ;
"X1_CNT02"  , "X1_VAR03"  , "X1_DEF03"  , "X1_DEFSPA3", "X1_DEFENG3", "X1_CNT03"  , "X1_VAR04"  	, ;
"X1_DEF04"  , "X1_DEFSPA4", "X1_DEFENG4", "X1_CNT04"  , "X1_VAR05"  , "X1_DEF05"  , "X1_DEFSPA5"	, ;
"X1_DEFENG5", "X1_CNT05"  , "X1_F3"     , "X1_PYME"   , "X1_GRPSXG" , "X1_HELP"   , "X1_PICTURE"	, ;
"X1_IDFIL"  }

aAdd( _aSX1, {_cGrpPerg,'01'	,'Imprime Etiqueta ?'	,'Imprime Etiqueta ?'	,'Imprime Etiqueta ?'	,'MV_CH1','N',1	,0,2,'C','','MV_PAR01','Sim','Si'	,'Yes'	,'','','Nao','No'	,'Not'	,'','','','','','','','','','','','','','','','','','','','','',''} )
aAdd( _aSX1, {_cGrpPerg,'02'	,'Descricao ISO ?'		,'Descricao ISO ?'		,'Descricao ISO ?'		,'MV_CH2','C',20,0,0,'G','','MV_PAR02',''	,''		,''		,'','',''	,''		,''		,'','','','','','','','','','','','','','','','','','','','','',''} )
aAdd( _aSX1, {_cGrpPerg,'03'	,'Porta ?'				,'Porta ?'				,'Porta ?'				,'MV_CH3','C',4 ,0,0,'G','','MV_PAR03',''	,''		,''		,'','',''	,''		,''		,'','','','','','','','','','','','','','','','','','','','','',''} )

// Atualizando dicionario
dbSelectArea("SX1")
SX1->(dbSetOrder(1))
For _nI := 1 To Len(_aSX1)
	If !SX1->(MSSeek(PadR(_aSX1[_nI][1],_nTam1)+PadR(_aSX1[_nI][2],_nTam2)))
		SX1->(RecLock("SX1",.T.))
		For _nJ := 1 To Len(_aSX1[_nI])
			If aScan(_aStruDic, { |aX| PadR(aX[1],10) == PadR(_aEstrut[_nJ],10)}) > 0
				SX1->(FieldPut(FieldPos(_aEstrut[_nJ]),_aSX1[_nI][_nJ]))
			EndIf
		Next _nJ
		SX1->(MsUnLock())
	EndIf
Next _nI

RestArea(_aAreaDic)
RestArea(_aArea)

Return(Nil)



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PERFVLNGRD ³ Autor ³ Flavio Valentin           ³ Data ³ 09/01/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que valida a linha do grid para alteracao do empenho.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function PERFVLNGRD(_nOpc)

Local _lRet		:= .T.
Local _nLinAt	:= 0
Local _nTamArr	:= 0
Local _cArmProd	:= Alltrim(GetMV("MV_XLOCPRO"))

If (_nOpc == 1)
	_nLinAt	:= oBrwSld:nAT
	If (_nLinAt > 0)
		If !oBrwSld:aCols[_nLinAt][Len(oBrwSld:aHeader)+1] //Verifica se a linha nao esta deletado
			If AllTrim(oBrwSld:aCols[_nLinAt][GdFieldPos("D4_LOCAL",oBrwSld:aHeader)]) <> AllTrim(_cArmProd)
				If oBrwSld:aCols[_nLinAt][GdFieldPos("D4_QTDEORI",oBrwSld:aHeader)] > 0
					If oBrwSld:aCols[_nLinAt][GdFieldPos("D4_QTDEORI",oBrwSld:aHeader)] > oBrwSld:aCols[_nLinAt][GdFieldPos("D4_QUANT",oBrwSld:aHeader)]
						Alert("O empenho da linha "+AllTrim(STR(_nLinAt))+" está com a "+RetTitle("D4_QTDEORI")+" maior que o "+RetTitle("D4_QUANT"))
						_lRet := .F.
					EndIf
				EndIf
			EndIf
			If (_lRet)
				If AllTrim(oBrwSld:aCols[_nLinAt][GdFieldPos("D4_LOCAL",oBrwSld:aHeader)]) == AllTrim(_cArmProd)
					Alert("O empenho da linha "+AllTrim(STR(_nLinAt))+" ja foi transferido para o almoxarifado "+_cArmProd)
					_lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
Else
	_nTamArr := Len(oBrwSld:aCols)
	If (_nTamArr > 0)
		For _nIni := 1 To _nTamArr
			If !oBrwSld:aCols[_nIni][Len(oBrwSld:aHeader)+1] //Verifica se a linha nao esta deletado
				If AllTrim(oBrwSld:aCols[_nIni][GdFieldPos("D4_LOCAL",oBrwSld:aHeader)]) <> AllTrim(_cArmProd)
					If (oBrwSld:aCols[_nIni][GdFieldPos("D4_QTDEORI",oBrwSld:aHeader)] > oBrwSld:aCols[_nIni][GdFieldPos("D4_QUANT",oBrwSld:aHeader)])
						Alert("O empenho da linha "+AllTrim(STR(_nIni))+" está com a "+RetTitle("D4_QTDEORI")+" maior que o "+RetTitle("D4_QUANT"))
						_lRet := .F.
						Exit
					EndIf
				EndIf
				If (_lRet)
					If AllTrim(oBrwSld:aCols[_nIni][GdFieldPos("D4_LOCAL",oBrwSld:aHeader)]) == AllTrim(_cArmProd)
						If oBrwSld:aCols[_nIni][GdFieldPos("D4_QTDEORI",oBrwSld:aHeader)] > 0
							Alert("O empenho da linha "+AllTrim(STR(_nIni))+" ja foi transferido para o almoxarifado "+_cArmProd)
							_lRet := .F.
							Exit
						EndIf
					EndIf
				EndIf
			EndIf
		Next _nIni
	EndIf
EndIf

Return(_lRet)
