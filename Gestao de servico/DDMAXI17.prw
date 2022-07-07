#include 'protheus.ch'
#include 'parmtype.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  | DDMAXI17   บAutor  ณ Gabriel Verํssimo บ Data ณ  11/07/19  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de gera็ใo de atendimento da Ordem de Servi็o       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Perfil                                               	  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function DDMAXI17()

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
	Local aSZI		:= {}
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
	cQuery += "SELECT SZJ.R_E_C_N_O_ AS RECNO, * "
	cQuery += "	FROM " + RetSQLName("SZJ") + " SZJ "
	cQuery += "	WHERE ZJ_FILIAL = '" + xFilial("SZJ") + "' "
	cQuery += "		AND SZJ.D_E_L_E_T_ = '' "
	cQuery += "		AND ZJ_PROC = '' "
	cQuery += "	ORDER BY ZJ_IDMAX, SZJ.R_E_C_N_O_ ASC "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TRB', .F., .T.)

	TRB->(DbGoTop())

	While !TRB->(EoF())
		//Desprezo registro caso jแ esteja processado
		If TRB->ZJ_PROC == "1"
			TRB->(DbSkip())
			Loop
		EndIf
		//Tratamento de ajuste - Gabriel Verํssimo Lakatos 17/12/19
		//Se for UPDATE, significa que o registro anterior nใo trouxe a imagem correta
		If AllTrim(TRB->ZJ_TIPO) == "UPDATE"
			If AllTrim(TRB->ZJ_CODSEC) == "S_INFO_FA_"
				AB7->(DbSetOrder(1)) //AB7_FILIAL+AB7_NUMOS+AB7_ITEM
				If AB7->(DbSeek(xFilial("AB7") + TRB->ZJ_IDINTEG))
					AB7->(RecLock("AB7", .F.))
					AB7->AB7_XASSIN := TRB->ZJ_ASSINA
					AB7->(MsUnlock())
				EndIf
			EndIf
			
			//Atualiza registro da SZJ como processado
			SZJ->(DbGoTo(TRB->RECNO))
			SZJ->(RecLock("SZJ", .F.))
			SZJ->ZJ_PROC := "1"
			SZJ->(MsUnlock())
			
			//Continua com o restante do processamento
			TRB->(DbSkip())
			Loop
		EndIf
		
		If cMaxID <> TRB->ZJ_IDMAX
			cMaxID 		:= TRB->ZJ_IDMAX
			cSubItem 	:= "01"
			aCabAB6		:= {} //Limpo cabe็alho da Ordem de Servi็o
			aColsAB7	:= {} //Limpo itens da Ordem de Servi็o
			aColsAB8	:= {} //Limpo itens do Apontamento da Ordem de Servi็o
			aCabAB9 	:= {} //Limpo cabe็alho do Atendimento da Ordem de Servi็o
			aSZI		:= {}
			lContinua 	:= .F. //Variแvel para controlar se o atendimento foi totalmente preenchido
			lMsErroAuto := .F. //Altero variแvel novamente para nใo bloquear gera็ใo de outros atendimentos
			While !TRB->(EoF()) .And. cMaxID == TRB->ZJ_IDMAX
				If AllTrim(TRB->ZJ_CODSEC) == "S_INFO_IA_" //Inf. Inicio Atividade
					cNumOS := AllTrim(TRB->ZJ_IDINTEG)
					//Rotina para posicionar registro nas tabelas AB6 e AB7
					PosReg(cNumOS)
					aHrFat := {TRB->ZJ_DATA, TRB->ZJ_HORA}
					aAdd(aCabAB9, {"AB9_NUMOS"	, SubStr(TRB->ZJ_IDINTEG, 1, 6) + SubStr(TRB->ZJ_IDINTEG, 7, 2)	, Nil })
					aAdd(aCabAB9, {"AB9_SEQ"	, "01"					, Nil}) //Sequencia de Atendimento
					aAdd(aCabAB9, {"AB9_CODTEC"	, TRB->ZJ_USER			, Nil}) //C๓digo do T้cnico 
					aAdd(aCabAB9, {"AB9_DTINI"	, StoD(TRB->ZJ_DATA)	, Nil}) //Data Inํcio da Atividade
					aAdd(aCabAB9, {"AB9_HRINI"	, TRB->ZJ_HORA			, Nil}) //Hora Inํcio da Atividade
					aAdd(aCabAB9, {"AB9_DTCHEG"	, StoD(TRB->ZJ_DATA)	, Nil}) //Data da Chegada
					aAdd(aCabAB9, {"AB9_HRCHEG"	, TRB->ZJ_HORA			, Nil}) //Hora da Chegada
					aAdd(aCabAB9, {"AB9_XFOTO"	, TRB->ZJ_FOTO			, Nil}) //Foto do Ativo
					aAdd(aCabAB9, {"AB9_XCLAOS"	, "2"					, Nil}) //Classe da Ordem de Servi็o
					if AllTrim(TRB->ZJ_ATIVOK) == "2" //Se o ativo informado na OS nใo estiver correto, altero AB7 com dados apontados no mobile
						aAdd(aColsAB7, {"AB7_CODPRO"	, Posicione("AA3", 6, xFilial("AA3") + TRB->ZJ_ATIVCOR, "AA3_CODPRO")}) //C๓digo do Produto
						aAdd(aColsAB7, {"AB7_NUMSER"	, TRB->ZJ_ATIVCOR}) //ID ๚nico
						aAdd(aColsAB7, {"AB7_TIPO"		, "4"}) //Status - 2-Pedido Gerado/4-Atendido/5-Encerrado/13-Em Atendimento
					endif
				ElseIf AllTrim(TRB->ZJ_CODSEC) == "S_INFO_MAT" //Inf. Materiais Corretiva
					cAtivo := IIF(Empty(TRB->ZJ_ATIVCOR), TRB->ZJ_ITEM, TRB->ZJ_ATIVCOR)
					cLocPad := Posicione("SB1", 1, xFilial("SB1") + cAtivo, "B1_LOCPAD")
					aAdd(aColsAB8, {{"AB8_FILIAL"	, xFilial("AB8")},; 												//Filial
									{"AB8_NUMOS"	, SubStr(cNumOS, 1, 6)},;											//Numero da OS
									{"AB8_ITEM"		, SubStr(cNumOS, 7, 2)},; 											//Item
									{"AB8_SUBITE"	, cSubItem},; 														//Sub-item
									{"AB8_CODPRO"	, cAtivo},; 														//C๓digo do Ativo
									{"AB8_DESPRO"	, IIF(Empty(TRB->ZJ_ATIVCOR), TRB->ZJ_DESITEM, TRB->ZJ_DESCCOR)},; 	//Descri็ใo do Ativo
									{"AB8_CODSER"	, "000001"},; 														//C๓digo do Servi็o
									{"AB8_QUANT"	, TRB->ZJ_QUANT},; 													//Quantidade
									{"AB8_VUNIT"	, 0.01},; 															//Valor Unitแrio
									{"AB8_TOTAL"	, TRB->ZJ_QUANT * 0.01},; 											//Valor Total
									{"AB8_PRCLIS"	, 0.01},; 															//Pre็o de Lista
									{"AB8_LOCAL"	, cLocPad},; 														//Almoxarifado
									{"AB8_XSTATUS"	, IIF(AllTrim(Upper(TRB->ZJ_STATUS)) == "SOLICITADO", "1", "2")}}) 	//Status
					cSubItem := Soma1(cSubItem)
				ElseIf AllTrim(TRB->ZJ_CODSEC) == "S_INFO_FA_" //Inf. Final Atendimento
					//Valida se variแvel aHrFat ้ do tipo array e estแ preenchida para nใo dar erro na fun็ใo GetTempo()
					If ValType(aHrFat) == "A" .And. !Empty(aHrFat)
						nHrFat := AjustaHr(GetTempo(aHrFat, {TRB->ZJ_DATA, TRB->ZJ_HORA}))
					EndIf 
					aAdd(aCabAB9, {"AB9_DTFIM"	, StoD(TRB->ZJ_DATA)											, Nil}) //Data Final do Atendimento
					aAdd(aCabAB9, {"AB9_HRFIM"	, TRB->ZJ_HORA													, Nil}) //Hora Final do Atendimento
					aAdd(aCabAB9, {"AB9_DTSAID"	, StoD(TRB->ZJ_DATA)											, Nil}) //Data de Saํda
					aAdd(aCabAB9, {"AB9_HRSAID"	, TRB->ZJ_HORA													, Nil}) //Hora de Saํda
					aAdd(aCabAB9, {"AB9_CODPRB"	, AB7->AB7_CODPRB												, Nil}) //C๓digo da Ocorr๊ncia
					aAdd(aCabAB9, {"AB9_TOTFAT"	, PadL(SubStr(cValToChar(nHrFat), 1, 5), 6, "0")				, Nil}) //Total de Horas Faturadas
					aAdd(aCabAB9, {"AB9_TIPO"	, "1"															, Nil}) //Status do Atendimento (1 = Atendido/Encerrado)
					aAdd(aColsAB7, {"AB7_XASSIN", TRB->ZJ_ASSINA}) 														//Assinatura do Cliente
				ElseIf AllTrim(TRB->ZJ_CODSEC) == "S_INFO_CHE"
					aAdd(aSZI, {{"ZI_FILIAL"	, xFilial("SZI")},;
								{"ZI_NUMOS"		, SubStr(cNumOS, 1, 6)},;
								{"ZI_CONJUN"	, AllTrim(TRB->ZJ_ITEM)},;
								{"ZI_IDENTIF"	, AllTrim(TRB->ZJ_CODIDEN)},;
								{"ZI_EXEC"		, AllTrim(TRB->ZJ_CODEXE)},;
								{"ZI_STEXEC"	, AllTrim(TRB->ZJ_CODSTEX)}})
					aAdd(aCabAB9, {"AB9_XOBS"	, TRB->ZJ_OBSERV													, Nil}) //Observa็ใo
					lContinua := .T.
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
				//MostraErro()
				conout("Erro na importa็ใo de Atendimentos (AB9) - verificar log")
				cLogFile := "\logs\importa_atendimentos_OS_Preventiva.log"
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
				SZJ->(DbSetOrder(1))
				If SZJ->(DbSeek(xFilial("SZJ") + AllTrim(cMaxID)))
					While !SZJ->(EoF()) .And. AllTrim(SZJ->ZJ_IDMAX) == AllTrim(cMaxID)
						SZJ->(RecLock("SZJ", .F.))
						SZJ->ZJ_PROC := "1"
						SZJ->(MsUnlock())
						SZJ->(DbSkip())
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
							&("AB8->" + aColsAB8[nI][nZ][1]) := aColsAB8[nI][nZ][2]
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
					conout("DDMAXI17 - Jแ existe registro na AB8.")
				EndIf

				// GERA REGISTRO NA SZI
				ChkFile("SZJ")
				SZI->(DbSetOrder(1))
				conout(Len(aSZI))
				conout("Len(aSZI)")
				
				For nSZI := 1 To Len(aSZI)
					SZI->(RecLock("SZI", .T.))
					For nZ := 1 To Len(aSZI[nSZI])
						&("SZI->" + aSZI[nSZI][nZ][1]) := aSZI[nSZI][nZ][2]
					Next nZ
					SZI->(MsUnlock())
				Next nSZI

				U_PFTEC01(cNumOS)

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

	cFileEnv := U_PFOSR04(,,,,.F.)

	oProcess := TWFProcess():New("WORKFLOW", "DDMAXI17")
	oProcess:NewTask("DDMAXI17",'\workflow\orcamento\HTML\DDMAXI17.htm')
	oHtml     := oProcess:oHtml
	oHtml:ValByName("Titulo", "Workflow de Ordem de Servi็o Perfil (" + DTOC(Date()) + " - " + Time() + ")")

	//Retorna destinatแrios do e-mail
	SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
	If SA1->(DbSeek(xFilial("SA1") + _Cli + _cLoja))
		If !Empty(SA1->A1_XMAIPRE)
			cTo += SA1->A1_XMAIPRE + ";"
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
