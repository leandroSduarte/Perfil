#include 'protheus.ch'
#include 'parmtype.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PFGS002  ºAutor  ³ Gabriel Veríssimo  º Data ³  07/06/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de workflow do orçamento		                      º±±
±±			 ³ 							                        		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PERFIL                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PFGS002()
	
	Local aArea			:= GetArea()
	Local aAreaAB3		:= AB3->(GetArea())
	Local aAreaAB4		:= AB4->(GetArea())
	Local cTo 			:= ""
	Local cFileEnv		:= ""
	Local cDestino		:= ""
	Local _cFileAttac 	:= ""
	Local _nPosFile 	:= 0
	Local oProcess
	Local oHtml
	
	cFileEnv := U_PFOSR03(,,,,.F.)
	
	oProcess := TWFProcess():New("WORKFLOW", "PFGS002")
	oProcess:NewTask("DDMAXI13",'\workflow\orcamento\HTML\PFGS002.htm')
	oHtml     := oProcess:oHtml
	oHtml:ValByName("Titulo", "Workflow de Orçamento Perfil (" + DTOC(Date()) + " - " + Time() + ")")
	
	//Retorna destinatários do e-mail
	SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
	If SA1->(DbSeek(xFilial("SA1") + AB3->AB3_CODCLI + AB3->AB3_LOJA))
		If Empty(SA1->A1_XMAILGE)
			Help(NIL, NIL, "PFGS002", NIL, "E-mail não preenchido", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique informação digitada no campo de e-mail"})
		Else
			cTo += SA1->A1_XMAILGE + ";"
		EndIf
	Else
		Help(NIL, NIL, "PFGS002", NIL, "Cliente não localizado", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o cliente e loja digitados"})
		Return .F.
	EndIf
	
	oHtml:ValByName("MENSAGEM"	, "Orçamento - Perfil")
	oHtml:ValByName("FILIAL"	, xFilial("AB3"))
	oHtml:ValByName("NUMORC"	, AB3->AB3_NUMORC)
	oHtml:ValByName("CLIENTE"	, AB3->AB3_CODCLI + " - " + AllTrim(SA1->A1_NOME))
	oHtml:ValByName("LOJA"		, AB3->AB3_LOJA)
	
	AB4->(DbSetOrder(1)) //AB4_FILIAL+AB4_NUMORC+AB4_ITEM
	If AB4->(DbSeek(xFilial("AB4") + AB3->AB3_NUMORC, .F.))
		While !AB4->(EoF()) .And. AB4->AB4_FILIAL + AB4->AB4_NUMORC == xFilial("AB4") + AB3->AB3_NUMORC
			AAdd((oHtml:ValByName("it1.1")), AB4->AB4_ITEM)
			AAdd((oHtml:ValByName("it1.2")), AB4->AB4_CODPRO)
			AAdd((oHtml:ValByName("it1.3")), AllTrim(Posicione("SB1", 1, xFilial("SB1") + AB4->AB4_CODPRO, "B1_DESC")))
			AAdd((oHtml:ValByName("it1.4")), AB4->AB4_CODPRB + " - " + Posicione("AAG", 1, xFilial("AAG") + AB4->AB4_CODPRB, "AAG_DESCRI"))
			AB4->(DbSkip())
		End
	EndIf
	
	//Envio o email para o solicitante
	cDestino := "\Workflow\orcamento\"
	_nPosFile := RAT("\", cFileEnv)
	_cFileAttac := cDestino + AllTrim(SubStr(cFileEnv, _nPosFile + 1))

	// Atacha arquivo configurado no inicio
	COPY FILE &(AllTrim(cFileEnv) + ".pdf") To &(AllTrim(_cFileAttac) + ".pdf")
	Sleep(5000)

	oProcess:AttachFile(AllTrim(_cFileAttac)+".pdf")
	oProcess:ClientName(cUserName)
	oProcess:cTo := cTo
	oProcess:cSubject := "Workflow de Orçamento Perfil (" + DTOC(Date()) + " - " + Time() + ")" + " - PFGS002"
	oProcess:Start()
	oProcess:Free()
	
	MsgInfo("E-mail enviado com sucesso!")
	
	RestArea(aArea)
	RestArea(aAreaAB3)
	RestArea(aAreaAB4)
	
Return