#include 'protheus.ch'
#include 'parmtype.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  | DDMAXI13   บAutor  ณ Gabriel Verํssimo บ Data ณ  11/07/19  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de gera็ใo de atendimento da Ordem de Servi็o       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Perfil                                               	  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function DDMAXI13()

	Local aArea		:= GetArea()
	Local aAreaAB6	:= AB6->(GetArea())
	Local aAreaAB7	:= AB7->(GetArea())
	Local aAreaAB8	:= AB8->(GetArea())
	Local aItens 	:= {} 	//Array para o item da O.S
	Local lRet 		:= .F. 	//Retorno da fun็ใo
	Local nI, nZ	:= 0
	Local cNumOS 	:= ""
	Local cMaxID 	:= ""
	Local aCabAB6	:= {}	//Array para o cabe็alho da ordem de servi็o (AB6)
	Local aColsAB7	:= {}	//Array para os itens da ordem de servi็o (AB7)
	Local aColsAB8 	:= {}	//Array para os itens de apontamento da ordem de servi็o (AB8)
	Local aCabAB9 	:= {} 	//Array para o cabe็alho do atendimento (AB9)
	Local cSubItem 	:= ""	
	Local nHrFat	:= 0
	Local aHrFat	:= {}
	Local aTransla	:= {}
	Local cTransla  := ""
	Local cQuery	:= ""
	Local lGrvLog	:= .F.

	Private lMsErroAuto := .F. //Informa a ocorr๊ncia de erros no ExecAuto
	Private lMsHelpAuto	:= .T.
	Private lAutoErrNoFile := .T.

	If Select("TRB") > 0
		TRB->(DbCloseArea())
	EndIf

	cQuery := ""
	cQuery += "SELECT SZF.R_E_C_N_O_ AS RECNO, * "
	cQuery += "	FROM " + RetSQLName("SZF") + " SZF "
	cQuery += "	WHERE ZF_FILIAL = '" + xFilial("SZF") + "' "
	cQuery += "		AND SZF.D_E_L_E_T_ = '' "
	cQuery += "		AND ZF_IDINTEG = '00752601' "
	//00752601  
	cQuery += "		AND ZF_PROC = '' "
	cQuery += "	ORDER BY ZF_IDMAX, SZF.R_E_C_N_O_ ASC "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TRB', .F., .T.)

	TRB->(DbGoTop())

	While !TRB->(EoF())
		//Desprezo registro caso jแ esteja processado
		If TRB->ZF_PROC == "1"
			TRB->(DbSkip())
			Loop
		EndIf
		//Tratamento de ajuste - Gabriel Verํssimo Lakatos 17/12/19
		//Se for UPDATE, significa que o registro anterior nใo trouxe a imagem correta
		If AllTrim(TRB->ZF_TIPO) == "UPDATE"
			If AllTrim(TRB->ZF_CODSEC) == "S_INFO_FA_"
				AB7->(DbSetOrder(1)) //AB7_FILIAL+AB7_NUMOS+AB7_ITEM
				If AB7->(DbSeek(xFilial("AB7") + TRB->ZF_IDINTEG))
					AB7->(RecLock("AB7", .F.))
					AB7->AB7_XASSIN := TRB->ZF_ASSINA
					AB7->(MsUnlock())
				EndIf
			EndIf
			
			//Atualiza registro da SZF como processado
			SZF->(DbGoTo(TRB->RECNO))
			SZF->(RecLock("SZF", .F.))
			SZF->ZF_PROC := "1"
			SZF->(MsUnlock())
			
			//Continua com o restante do processamento
			TRB->(DbSkip())
			Loop
		EndIf
		If cMaxID <> TRB->ZF_IDMAX
			cMaxID 		:= alltrim(TRB->ZF_IDMAX)
			cSubItem 	:= "01"
			aCabAB6		:= {} //Limpo cabe็alho da Ordem de Servi็o
			aColsAB7	:= {} //Limpo itens da Ordem de Servi็o
			aColsAB8	:= {} //Limpo itens do Apontamento da Ordem de Servi็o
			aCabAB9 	:= {} //Limpo cabe็alho do Atendimento da Ordem de Servi็o
			lContinua 	:= .F. //Variแvel para controlar se o atendimento foi totalmente preenchido
			lMsErroAuto := .F. //Altero variแvel novamente para nใo bloquear gera็ใo de outros atendimentos
			conout("Processando ZF_IDINTEG: " + TRB->ZF_IDINTEG )
			While !TRB->(EoF()) .And. cMaxID == alltrim(TRB->ZF_IDMAX)
				conout("Posicionado em " + TRB->ZF_CODSEC)
				If AllTrim(TRB->ZF_CODSEC) == "S_INFO_ID_" //Inf. Inicio Deslocamento
					conout("Gravando S_INFO_ID_")
					cNumOS := AllTrim(TRB->ZF_IDINTEG)
					//Rotina para posicionar registro nas tabelas AB6 e AB7
					PosReg(cNumOS)
					aTransla := {TRB->ZF_DATA, TRB->ZF_HORA}
					aAdd(aCabAB9, {"AB9_NUMOS"	, SubStr(TRB->ZF_IDINTEG, 1, 6) + SubStr(TRB->ZF_IDINTEG, 7, 2)	, Nil })
					aAdd(aCabAB9, {"AB9_SEQ"	, "01"					, Nil}) //Sequencia de Atendimento
					aAdd(aCabAB9, {"AB9_CODTEC"	, TRB->ZF_USER			, Nil}) //C๓digo do T้cnico 
					aAdd(aCabAB9, {"AB9_XPLACA"	, TRB->ZF_PLACA			, Nil}) //Placa
					aAdd(aCabAB9, {"AB9_XKMINI"	, TRB->ZF_KMINI			, Nil}) //KM Inํcio
					aAdd(aCabAB9, {"AB9_XDTIDE"	, StoD(TRB->ZF_DATA)	, Nil}) //Data Inํcio do Deslocamento
					aAdd(aCabAB9, {"AB9_XHRIDE"	, TRB->ZF_HORA			, Nil}) //Hora Inํcio do Deslocamento
				ElseIf AllTrim(TRB->ZF_CODSEC) == "S_INFO_FD_" //Inf. Fim Deslocamento
					conout("Gravando S_INFO_FD_")
					//Valida se variแvel aTransla ้ do tipo array e estแ preenchida para nใo dar erro na fun็ใo GetTempo() 
					If ValType(aTransla) == "A" .And. !Empty(aTransla)
						cTransla := AjustaHr(GetTempo(aTransla, {TRB->ZF_DATA, TRB->ZF_HORA}))
					End
					aAdd(aCabAB9, {"AB9_DTCHEG"	, StoD(TRB->ZF_DATA)	, Nil}) //Data da Chegada
					aAdd(aCabAB9, {"AB9_HRCHEG"	, TRB->ZF_HORA			, Nil}) //Hora da Chegada
					aAdd(aCabAB9, {"AB9_XKMFIM"	, TRB->ZF_KMFIM			, Nil}) //KM Final
					aAdd(aCabAB9, {"AB9_TRASLA"	, cTransla				, Nil}) //Tempo de Translado
				ElseIf AllTrim(TRB->ZF_CODSEC) == "S_INFO_IA_" //Inf. Inicio Atividade
					conout("Gravando S_INFO_IA_")
					aHrFat := {TRB->ZF_DATA, TRB->ZF_HORA}
					aAdd(aCabAB9, {"AB9_DTINI"	, StoD(TRB->ZF_DATA), Nil}) //Data Inํcio da Atividade
					aAdd(aCabAB9, {"AB9_HRINI"	, TRB->ZF_HORA		, Nil}) //Hora Inํcio da Atividade
					If AllTrim(TRB->ZF_ATIVOK) == "2" //Se o ativo informado na OS nใo estiver correto, altero AB7 com dados apontados no mobile
						aAdd(aColsAB7, {"AB7_CODPRO"	, Posicione("AA3", 6, xFilial("AA3") + TRB->ZF_ATIVCOR, "AA3_CODPRO")}) //C๓digo do Produto
						aAdd(aColsAB7, {"AB7_NUMSER"	, TRB->ZF_ATIVCOR}) //ID ๚nico
						aAdd(aColsAB7, {"AB7_TIPO"		, "4"}) //Status - 2-Pedido Gerado/4-Atendido/5-Encerrado/13-Em Atendimento
					EndIf
				ElseIf AllTrim(TRB->ZF_CODSEC) == "S_INFO_MAT" //Inf. Materiais Corretiva
					conout("Gravando S_INFO_MAT")
					cAtivo := IIF(Empty(TRB->ZF_ATIVCOR), TRB->ZF_ITEM, TRB->ZF_ATIVCOR)
					cLocPad := Posicione("SB1", 1, xFilial("SB1") + cAtivo, "B1_LOCPAD")
					aAdd(aColsAB8, {{"AB8_FILIAL"	, xFilial("AB8")},; 												//Filial
									{"AB8_NUMOS"	, SubStr(cNumOS, 1, 6)},;											//Numero da OS
									{"AB8_ITEM"		, SubStr(cNumOS, 7, 2)},; 											//Item
									{"AB8_SUBITE"	, cSubItem},; 														//Sub-item
									{"AB8_CODPRO"	, cAtivo},; 														//C๓digo do Ativo
									{"AB8_DESPRO"	, IIF(Empty(TRB->ZF_ATIVCOR), TRB->ZF_DESITEM, TRB->ZF_DESCCOR)},; 	//Descri็ใo do Ativo
									{"AB8_CODSER"	, "000001"},; 														//C๓digo do Servi็o
									{"AB8_QUANT"	, TRB->ZF_QUANT},; 													//Quantidade
									{"AB8_VUNIT"	, 0},; 																//Valor Unitแrio
									{"AB8_PRCLIS"	, 0},; 																//Pre็o de Lista
									{"AB8_TOTAL"	, 0},; 																//Valor Total
									{"AB8_LOCAL"	, cLocPad},; 														//Almoxarifado
									{"AB8_XSTATUS"	, IIF(AllTrim(Upper(TRB->ZF_STATUS)) == "SOLICITADO", "1", "2")}}) 	//Status
					cSubItem := Soma1(cSubItem)
				ElseIf AllTrim(TRB->ZF_CODSEC) == "S_INFO_FA_" //Inf. Final Atendimento
					conout("Gravando S_INFO_FA_")
					//Valida se variแvel aHrFat ้ do tipo array e estแ preenchida para nใo dar erro na fun็ใo GetTempo()
					If ValType(aHrFat) == "A" .And. !Empty(aHrFat)
						nHrFat := GetTempo(aHrFat, {TRB->ZF_DATA, TRB->ZF_HORA})
					EndIf 
					aAdd(aCabAB9, {"AB9_DTFIM"	, StoD(TRB->ZF_DATA)											, Nil}) //Data Final do Atendimento
					aAdd(aCabAB9, {"AB9_HRFIM"	, TRB->ZF_HORA													, Nil}) //Hora Final do Atendimento
					aAdd(aCabAB9, {"AB9_DTSAID"	, StoD(TRB->ZF_DATA)											, Nil}) //Data de Saํda
					aAdd(aCabAB9, {"AB9_HRSAID"	, TRB->ZF_HORA													, Nil}) //Hora de Saํda
					aAdd(aCabAB9, {"AB9_CODPRB"	, AB7->AB7_CODPRB												, Nil}) //C๓digo da Ocorr๊ncia
					aAdd(aColsAB7, {"AB7_XASSIN"	, TRB->ZF_ASSINA}) //Assinatura do Cliente
					aAdd(aCabAB9, {"AB9_TOTFAT"	, PadL(SubStr(cValToChar(nHrFat), 1, 5), 6, "0")							, Nil}) //Total de Horas Faturadas
					aAdd(aCabAB9, {"AB9_TIPO"	, "1"															, Nil}) //Status do Atendimento (1 = Atendido/Encerrado)
					lContinua := .T.
				elseif AllTrim(TRB->ZF_CODSEC) == "S_INFO_TEC" //Inf. Final Atendimento
					conout("Gravando S_INFO_TEC")
					aAdd(aCabAB9, {"AB9_XLOCAL"	, TRB->ZF_DESCLOC	, Nil}) //Localiza็ใo
					aAdd(aCabAB9, {"AB9_XIDENT"	, TRB->ZF_DESIDEN	, Nil}) //Identidade
					aAdd(aCabAB9, {"AB9_XGRUPO"	, TRB->ZF_DESCGRP	, Nil}) //Grupo
					aAdd(aCabAB9, {"AB9_XFOTO"	, TRB->ZF_FOTO		, Nil}) //Foto do Ativo
					aAdd(aCabAB9, {"AB9_XEXEC"	, TRB->ZF_DESMEXE	, Nil}) //Execu็ใo
					aAdd(aCabAB9, {"AB9_XSTEXE"	, TRB->ZF_DESSTEX	, Nil}) //Status de Execu็ใo
					aAdd(aCabAB9, {"AB9_XOBS"	, TRB->ZF_OBSERV	, Nil}) //Status de Execu็ใo
				EndIf
				TRB->(DbSkip())
			End

			//Executa ExecAuto
			If lContinua
				TECA460(aCabAB9, aItens, 3) // 3-Incluir ; 4-Alterar ; 5-Excluir
			Else
				Loop
			EndIf

			If !lMsErroAuto
				lRet := .T.
			Else
			//	MostraErro()
			
				conout("Erro na importa็ใo de Atendimentos (AB9) - verificar log")
				// conout(varinfo("Array cabe็alho AB9", aCabAB9,, .F.))
				// conout(varinfo("Array itens AB9", aItens,, .F.))
				cLogFile := "\logs\importa_atendimentos_OS.log"
				aLog := GetAutoGRLog()
				If !File(cLogFile)
					If (nHandle := FCreate(cLogFile)) <> -1
						lGrvLog := .T.
					EndIf		
				Else			
					If (nHandle := FOpen(cLogFile, 2)) <> -1
						FSeek(nHandle, 0, 2)
						lGrvLog := .T.
					EndIf
				EndIf
				//Grava as informa็๕es de log no arquivo especificado
				If lGrvLog
					For nX := 1 To Len(aLog)
						FWrite(nHandle, aLog[nX] + CHR(13) + CHR(10))
					Next nX
				EndIf
				FClose(nHandle)
			EndIf

			If lRet
				//ATUALIZA A FLAG DE PROCESSADO DO REGISTRO NA TABELA AUXILIAR 
				SZF->(DbSetOrder(1))
				If SZF->(DbSeek(xFilial("SZF") + AllTrim(cMaxID)))
					While !SZF->(EoF()) .And. AllTrim(SZF->ZF_IDMAX) == AllTrim(cMaxID)
						SZF->(RecLock("SZF", .F.))
						SZF->ZF_PROC := "1"
						SZF->(MsUnlock())
						SZF->(DbSkip())
					End
				EndIf
				
				//ATUALIZA REGISTRO NA AB6
				AB6->(DbSetOrder(1))
				If AB6->(DbSeek(xFilial("AB6") + SubStr(cNumOS, 1, 6)))
					AB6->(RecLock("AB6", .F.))
					For nI := 1 To Len(aCabAB6)
						&("AB6->" + aCabAB6[nI][1]) := aCabAB6[nI][2]
					Next
					// Chamada de fun็ใo padrใo para atualizar status da Ordem de Servi็o
					AB6->AB6_STATUS := AtOsStatus(AB6->AB6_NUMOS)
					AB6->(MsUnlock())
				EndIf

				//ATUALIZA REGISTRO DA AB7
				
				AB7->(DbSetOrder(1))
				If AB7->(DbSeek(xFilial("AB7") + cNumOS))
					AB7->(RecLock("AB7", .F.))
					For nI := 1 To Len(aColsAB7)
						&("AB7->" + aColsAB7[nI][1]) := aColsAB7[nI][2]
					Next
					AB7->(MsUnlock())
				EndIf
				
				//GERA REGISTRO NA AB8
				AB8->(DbSetOrder(1))
				//Verifico se existe registro de apontamento
				If !AB8->(DbSeek(xFilial("AB8") + cNumOS))
					For nI := 1 To Len(aColsAB8)
						AB8->(RecLock("AB8", .T.))
						For nZ := 1 To Len(aColsAB8[nI])
							// Tratamento para executar fun็ใo padrใo nos campos de valores dos apontamentos - Gabriel Verํssimo 08/07/2020
							// Foi feito dessa maneira pois ้ necessแrio ter a tabela de pre็o utilizada na ordem de servi็o
							if aColsAB8[nI][nZ][1] $ "AB8_VUNIT|AB8_PRCLIS"
								&("AB8->" + aColsAB8[nI][nZ][1]) := AT450Tab(AB8->AB8_CODPRO,AB6->AB6_TABELA,AB8->AB8_QUANT,AB6->AB6_CODCLI,AB6->AB6_LOJA,AB6->AB6_MOEDA)
							elseif aColsAB8[nI][nZ][1] $ "AB8_TOTAL"
								&("AB8->" + aColsAB8[nI][nZ][1]) := AB8->AB8_QUANT * AB8->AB8_VUNIT
							else
								&("AB8->" + aColsAB8[nI][nZ][1]) := aColsAB8[nI][nZ][2]
							endif
						Next nZ

						AB7->(DbSetOrder(1))
						If AB7->(DbSeek(xFilial("AB7") + cNumOS))
							AB8->AB8_ENTREG := AB6->AB6_EMISSA 
							AB8->AB8_NUMPV  := ALLTRIM(AB6->AB6_XNUMPV)  + ALLTRIM(AB7->AB7_ITEM) 
							AB8->AB8_CODCLI := AB7->AB7_CODCLI 
							AB8->AB8_LOJA   := AB7->AB7_LOJA
							AB8->AB8_CODPRD := AB7->AB7_CODPRO
							AB8->AB8_NUMSER := AB7->AB7_NUMSER
							AB8->AB8_TIPO   := AB7->AB7_TIPO
						endif
						AB8->(MsUnlock())
					Next nI
				Else
					conout("DDMAXI13 - Jแ existe registro na AB8.")
				EndIf

				//Integra็ใo da ordem de servi็o com portal
				U_DDMAXI8X(.F.)

				//Envia e-mail contendo relat๓rio da Ordem de Servi็o
				//Somente envia e-mail quando todos os itens estiverem atendidos
				If AllTrim(AB6->AB6_STATUS) == "B"
					EnvWF(xFilial("AB7"), (AB7->AB7_NUMOS + AB7->AB7_ITEM), AB7->AB7_CODCLI, AB7->AB7_LOJA)
				EndIf

				Loop
			EndIf
		EndIf
		TRB->(DbSkip())
	End

	If Select("TRB") > 0
		TRB->(DbCloseArea())
	EndIf

	RestArea(aArea)
	RestArea(aAreaAB6)
	RestArea(aAreaAB7)
	RestArea(aAreaAB8)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  | PosReg    บAutor  ณ Gabriel Verํssimo บ Data ณ  11/07/19   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de posicionamento dos registros                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Perfil                                               	  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PosReg(cNum)

	//Cabe็alho da ordem de servi็o
	AB6->(DbSetOrder(1)) //AB6_FILIAL+AB6_NUMOS
	AB6->(DbSeek(xFilial("AB6") + SubStr(cNum, 1, 6)))

	//Itens da ordem de servi็o
	AB7->(DbSetOrder(1)) //AB7_FILIAL+AB7_NUMOS+AB7_ITEM
	AB7->(DbSeek(xFilial("AB7") + cNum))

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  | GetTempo  บAutor  ณ Gabriel Verํssimo บ Data ณ  11/07/19   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de ajuste de hora do apontamento                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Perfil                                               	  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function GetTempo(aInicio, aFim)

	Local cDtIni 	:= aInicio[1]
	Local cHrIni 	:= AjustaHr(aInicio[2])
	Local cDtFim 	:= aFim[1]
	Local cHrFim 	:= AjustaHr(aFim[2])
	Local nDayDiff	:= 0
	Local cRet		:= ""

	cRet := ElapTime(cHrIni, cHrFim)
	nDayDiff := DateDiffDay(StoD(cDtIni), StoD(cDtFim))
	If nDayDiff > 0 //A fun็ใo ElapTime trata diferen็as de at้ 24 horas, portanto ้ necessแrio validar diferen็a superior hแ um dia
		If cRet >= "00:00:00" //Se for maior que um 24h
			cRet := Str(Val(SubStr(cRet, 1, 2)) + (24 * nDayDiff), 2) + SubStr(cRet, 3)
		EndIf
	Else
		cRet := ElapTime(cHrIni, cHrFim)
	EndIf

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  | AjustaHr  บAutor  ณ Gabriel Verํssimo บ Data ณ  11/07/19   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de ajuste de hora do apontamento                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Perfil                                               	  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function AjustaHr(cPar1)

	Local cRet := ""

	//Remove caracteres
	cPar1 := AllTrim(StrTran(cPar1, ":", ""))
	cPar1 := AllTrim(StrTran(cPar1, ".", ""))

	If Len(cPar1) < 4
		cPar1 := PadL(cPar1, 4, "0")
	EndIf

	//Separa hora, minuto e segundo
	cHora := SubStr(cPar1, 1, 2)
	cMin := SubStr(cPar1, 3, 2)
	cSeg := SubStr(cPar1, 5, 2)

	//Monta string formatada
	cRet := PadL(cHora, 2, "0") + ":" + PadL(cMin, 2, "0") + ":" + PadL(cSeg, 2, "0")

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  | EnvWF     บAutor  ณ Gabriel Verํssimo บ Data ณ  11/07/19   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de envio de worfklow			                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Perfil                                               	  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function EnvWF(_cFilial, _cNumOS, _Cli, _cLoja)

	Local cTo := ""
	Local aAreaSA1 := SA1->(GetArea())
	Local aAreaAAX := AAX->(GetArea())
	Local aAreaSB1 := SB1->(GetArea())
	Local aArea	   := GetArea()

	//Processo Finalizado, Gerando dados nas tabelas Customizadas.
	//Enviar WorkFlow.

	cFileEnv := U_PFOSR01(,,,,.F.)

	oProcess := TWFProcess():New("WORKFLOW", "DDMAXI13")
	oProcess:NewTask("DDMAXI13",'\workflow\orcamento\HTML\DDMAXI13.htm')
	oHtml     := oProcess:oHtml
	oHtml:ValByName("Titulo", "Workflow de Ordem de Servi็o Perfil (" + DTOC(Date()) + " - " + Time() + ")")

	//Retorna destinatแrios do e-mail
	SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
	If SA1->(DbSeek(xFilial("SA1") + _Cli + _cLoja))
		If !Empty(SA1->A1_XMAILGE)
			cTo += SA1->A1_XMAILGE + ";"
		EndIf
	EndIf
	AAX->(DbSetOrder(1)) //AAX_FILIAL+AAX_CODEQU
	If AAX->(DbSeek(xFilial("AAX") + AB6->AB6_XEQUIP))
		If !Empty(AAX->AAX_XMAILM)
			cTo += AllTrim(AAX->AAX_XMAILM) + ";"
		EndIf
		If !Empty(AAX->AAX_XMAILV)
			cTo += AllTrim(AAX->AAX_XMAILV) + ";"
		EndIf
		If !Empty(AAX->AAX_XMAILR)
			cTo += AllTrim(AAX->AAX_XMAILR) + ";"
		EndIf
	EndIf

	AB7->(DbSetOrder(1)) //AB7_FILIAL+AB7_NUMOS+AB7_ITEM
	If AB7->(DbSeek(xFilial("AB7") + _cNumOS, .F.))
		While !AB7->(EoF()) .And. AB7->AB7_FILIAL + AB7->AB7_NUMOS == _cFilial + SubStr(_cNumOS, 1, 6)
			AAdd((oHtml:ValByName("it1.1")), AB7->AB7_ITEM)
			AAdd((oHtml:ValByName("it1.2")), AB7->AB7_CODPRO)
			AAdd((oHtml:ValByName("it1.3")), AllTrim(Posicione("SB1", 1, xFilial("SB1") + AB7->AB7_CODPRO, "B1_DESC")))
			AAdd((oHtml:ValByName("it1.4")), AB7->AB7_CODPRB + " - " + Posicione("AAG", 1, xFilial("AAG") + AB7->AB7_CODPRB, "AAG_DESCRI"))
			AB7->(DbSkip())
		End
	EndIf

	oHtml:ValByName( "MENSAGEM"	, "Ordem de Servi็o - Perfil")

	oHtml:ValByName("FILIAL"	, xFilial("AB7"))
	oHtml:ValByName("NUMOS"		, SubStr(_cNumOS, 1, 6) + "-" + SubStr(_cNumOS, 7, 2))
	oHtml:ValByName("CLIENTE"	, _Cli + " - " + AllTrim(SA1->A1_NOME))
	oHtml:ValByName("LOJA"		, _cLoja)

	//Envio o email para o solicitante
	cDestino:="\Workflow\orcamento\"
	_nPosFile := RAT("\", cFileEnv)
	_cFileAttac := cDestino+alltrim(SubStr(cFileEnv, _nPosFile + 1))

	// Atacha arquivo configurado no inicio
	COPY FILE &(AllTrim(cFileEnv) + ".pdf") To &(AllTrim(_cFileAttac) + ".pdf")
	Sleep(5000)

	oProcess:AttachFile(alltrim(_cFileAttac)+".pdf")
	oProcess:ClientName(cUserName)
	oProcess:cTo := cTo
	oProcess:cSubject := "Workflow de Ordem de Servi็o Perfil (" + DTOC(Date()) + " - " + Time() + ")" + " - PFGSR01"
	oProcess:Start()
	oProcess:Free()

	RestArea(aArea)
	RestArea(aAreaSA1)
	RestArea(aAreaAAX)
	RestArea(aAreaSB1)

Return
