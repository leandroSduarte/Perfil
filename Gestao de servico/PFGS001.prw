#include 'protheus.ch'
#include 'parmtype.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PFGS001  ºAutor  ³ Gabriel Veríssimo  º Data ³  07/06/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de geração do Orçamento a partir da Ordem de Serviçoº±±
±±			 ³ 							                        		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PERFIL                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PFGS001()

	Local aCabec		:= {}
	Local aItens		:= {}
	Local aItem			:= {}
	Local aAponts		:= {}
	Local aApont		:= {}
	Local nOpc			:= 3
	Local cNumOrc		:= ""
	Local aArea			:= GetArea()
	Local dEmissao
	Private lMsErroAuto := .F.

	//AB3->(DbSelectArea("AB3"))

	//Tratamento para o campo AB3_EMISSAO (rotina não permite data de emissão inferior a database)
	If AB6->AB6_EMISSA < dDatabase
		dEmissao := dDatabase
	Else
		dEmissao := AB6->AB6_EMISSA
	EndIf

	//Preenche array do cabeçalho
	//AAdd(aCabec, {"AB3_NUMORC"	, cNumOrc			, Nil})
	AAdd(aCabec, {"AB3_CODCLI"	, AB6->AB6_CODCLI	, Nil})
	AAdd(aCabec, {"AB3_LOJA" 	, AB6->AB6_LOJA		, Nil})
	AAdd(aCabec, {"AB3_EMISSA"	, dEmissao			, Nil})
	AAdd(aCabec, {"AB3_ATEND" 	, AB6->AB6_ATEND	, Nil})
	AAdd(aCabec, {"AB3_CONPAG"	, AB6->AB6_CONPAG	, Nil})
	AAdd(aCabec, {"AB3_HORA" 	, AB6->AB6_HORA		, Nil})

	//Preenche array dos itens
	AB7->(DbSetOrder(1)) //AB7_FILIAL+AB7_NUMOS+AB7_ITEM
	If AB7->(DbSeek(xFilial("AB7") + AB6->AB6_NUMOS, .F.))
		While !AB7->(EoF()) .And. AB7->AB7_FILIAL + AB7->AB7_NUMOS == AB6->AB6_FILIAL + AB6->AB6_NUMOS
			AAdd(aItem, {"AB4_ITEM" 	, AB7->AB7_ITEM		, Nil})
			AAdd(aItem, {"AB4_CODPRO"	, AB7->AB7_CODPRO	, Nil})
			AAdd(aItem, {"AB4_NUMSER"	, AB7->AB7_NUMSER	, Nil})
			AAdd(aItem, {"AB4_CODPRB"	, AB7->AB7_CODPRB	, Nil})
			AAdd(aItem, {"AB4_NUMOS"	, AB7->AB7_NUMOS	, Nil})
			//Preenche array dos apontamentos
			AB8->(DbSetOrder(1)) //AB8_FILIAL+AB8_NUMOS+AB8_ITEM+AB8_SUBITE
			If AB8->(DbSeek(xFilial("AB8") + AB7->AB7_NUMOS + AB7->AB7_ITEM, .F.))
				While !AB8->(EoF()) .And. AB8->AB8_FILIAL + AB8->AB8_NUMOS + AB8->AB8_ITEM == AB7->AB7_FILIAL + AB7->AB7_NUMOS + AB7->AB7_ITEM
					//Conforme solicitação do Herison, considerar apenas itens "Solicitado" para geração do Orçamento (04/06/2021)
					If AB8->AB8_XSTATU <> '1'
						AB8->(DbSkip())
						Loop
					Endif
					AAdd(aApont, {"AB5_ITEM" 	, AB8->AB8_ITEM  					, Nil})
					AAdd(aApont, {"AB5_SUBITE"	, AB8->AB8_SUBITE					, Nil})
					AAdd(aApont, {"AB5_CODPRO"	, AB8->AB8_CODPRO					, Nil})
					AAdd(aApont, {"AB5_CODSER"	, AB8->AB8_CODSER					, Nil})
					AAdd(aApont, {"AB5_QUANT"	, AB8->AB8_QUANT					, Nil})
					AAdd(aApont, {"AB5_VUNIT"	, AB8->AB8_VUNIT					, Nil})
					AAdd(aApont, {"AB5_TOTAL"	, AB8->AB8_QUANT * AB8->AB8_VUNIT	, Nil})
					AAdd(aApont, {"AB5_PRCLIS"	, AB8->AB8_PRCLIS					, Nil})
					AAdd(aAponts, aApont)
					aApont := {}
					AB8->(DbSkip())
				End
			EndIf
			AAdd(aItens, aItem)
			aItem := {}
			AB7->(DbSkip())
		End
	EndIf

	MsExecAuto({|a, b, c, d, e| TECA400(a, b, c, d, e)}, "", aCabec, aItens, aAponts, nOpc)
	If !lMsErroAuto
		AB3->(DbSetOrder(1))
		AB3->(DbGoBottom())
		//EnvWF()
		//EnvWF(xFilial("AB3"), AB3->AB3_NUMORC, AB3->AB3_CODCLI, AB3->AB3_LOJA)
		MsgInfo("Orçamento " + AB3->AB3_NUMORC + " incluído com sucesso!", "PFGS001")
	Else
		conout("Erro na inclusao!")
		MostraErro()
	EndIf

	RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ EnvWF   ºAutor  ³ Gabriel Veríssimo  º Data ³  07/06/19    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de envio do workflow 								  º±±
±±			 ³ 							                        		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PERFIL                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function EnvWF(_cFilial, _cOrc, _Cli, _cLoja)

	//Processo Finalizado, Gerando dados nas tabelas Customizadas.
	//Enviar WorkFlow.

	cFileEnv := u_PFOSR03(,,,,.F.)

	oProcess := TWFProcess():New("WORKFLOW", "PFGS001")
	oProcess:NewTask("PFGSR01",'\workflow\orcamento\HTML\PFGS001.htm')
	oHtml     := oProcess:oHtml
	oHtml:ValByName("Titulo", "Workflow de Orçamento Perfil (" + DTOC(Date()) + " - " + Time() + ")")

	nValDoc := 0
	nValPed := 0
	nValDif := 0
	nValOrc	:= 0
	
	AB4->(DbSetOrder(1)) //AB4_FILIAL+AB4_NUMORC+AB4_ITEM
	If AB4->(DbSeek(xFilial("AB4") + _cOrc, .F.))
		While !AB4->(EoF()) .And. AB4->AB4_FILIAL + AB4->AB4_NUMORC == _cFilial + _cOrc
			AB5->(DbSetOrder(1)) //AB5_FILIAL+AB5_NUMORC+AB5_ITEM+AB5_SUBITE
			If AB5->(DbSeek(xFilial("AB5") + AB4->AB4_NUMORC + AB4->AB4_ITEM, .F.))
				While !AB5->(EoF()) .And. AB5->AB5_FILIAL + AB5->AB5_NUMORC + AB5->AB5_ITEM == AB4->AB4_FILIAL + AB4->AB4_NUMORC + AB4->AB4_ITEM
					AAdd((oHtml:ValByName("it1.1")), AB5->AB5_ITEM)
					AAdd((oHtml:ValByName("it1.2")), AB5->AB5_CODPRO)
					AAdd((oHtml:ValByName("it1.3")), AB5->AB5_DESPRO)
					AAdd((oHtml:ValByName("it1.4")), AB4->AB4_CODPRB + " - " + Posicione("AAG", 1, xFilial("AAG") + AB4->AB4_CODPRB, "AAG_DESCRI"))
					AAdd((oHtml:ValByName("it1.5")), AB5->AB5_CODSER + " - " + Posicione("AA5", 1, xFilial("AA5") + AB5->AB5_CODSER, "AA5_DESCRI"))
					AAdd((oHtml:ValByName("it1.6")), AB5->AB5_QUANT)
					AAdd((oHtml:ValByName("it1.7")), "R$ " + Transform(AB5->AB5_VUNIT, "@E 999,999,999.99"))
					AAdd((oHtml:ValByName("it1.8")), "R$ " + Transform(AB5->AB5_TOTAL, "@E 999,999,999.99"))
					nValOrc += AB5->AB5_TOTAL
					AB5->(DbSkip())
				End
			EndIf
			AB4->(DbSkip())
		End
	EndIf

	oHtml:ValByName( "MENSAGEM"	, "Orçamento Perfil")
	oHtml:ValByName( "MENSAGEM2", "E-mail Teste - DESCONSIDERAR")

	oHtml:ValByName("FILIAL"	, xFilial("AB3"))
	oHtml:ValByName("ORCAMENTO"	, _cOrc)
	oHtml:ValByName("CLIENTE"	, _Cli)
	oHtml:ValByName("LOJA"		, _cLoja)
	oHtml:ValByName("COND"		, AB3->AB3_CONPAG + " - " + Posicione("SE4", 1, xFilial("SE4") + AB3->AB3_CONPAG, "E4_DESCRI"))
	oHtml:ValByName("VALOR"		, "R$ " + Transform(nValOrc, "@E 999,999,999.99"))

	//Envio o email para o solicitante
	cDestino:="\Workflow\orcamento\"
	_nPosFile := RAT("\", cFileEnv)
	_cFileAttac := cDestino+alltrim(SubStr(cFileEnv, _nPosFile + 1))

	// Atacha arquivo configurado no inicio
	COPY FILE &(AllTrim(cFileEnv) + ".pdf") To &(AllTrim(_cFileAttac) + ".pdf")
	Sleep(5000)

	oProcess:AttachFile(alltrim(_cFileAttac)+".pdf")
	oProcess:ClientName(cUserName)
	oProcess:cTo := SuperGetMv("MV__PFGS01", .F., "")
	oProcess:cSubject := "Workflow de Orçamento Perfil (" + DTOC(Date()) + " - " + Time() + ")" + " - PFGSR01"
	oProcess:Start()
	oProcess:Free()

Return
