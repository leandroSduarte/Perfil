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
	Local cMailID       := ""
	Local _nPosFile 	:= 0
	Local oProcess
	Local oHtml
	Local nTotal        :=  0
	
	cFileEnv := U_PFOSR03(,,,,.F.)
	
	oProcess := TWFProcess():New("WORKFLOW", "PFGS003")
	oProcess:NewTask("DDMAXI13",'\workflow\orcamento\HTML\PFGS004R.htm')
	oHtml     := oProcess:oHtml
	oHtml:ValByName("Titulo", "Workflow de Orçamento Perfil (" + DTOC(Date()) + " - " + Time() + ")")
	//oProcess:bReturn := "U_PFGS002R()"
	//Retorna destinatários do e-mail
	SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
	If SA1->(DbSeek(xFilial("SA1") + AB3->AB3_CODCLI + AB3->AB3_LOJA))
		If Empty(SA1->A1__EMLORC)
			Help(NIL, NIL, "PFGS002", NIL, "E-mail não preenchido", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique informação digitada no campo de e-mail"})
		Else
			cTo += SA1->A1__EMLORC + ";"
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
	oHtml:ValByName("EMISSAO"	, AB3->AB3_EMISSA)
	If Empty(AB3->AB3_XOSCLI)
		oHtml:ValByName("OS"	    , "N/A")
	Else
		oHtml:ValByName("OS"	    , AB3->AB3_XOSCLI)
	Endif

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	SA1->(DbGoTop())
	If SA1->(DbSeek(xFilial("SA1") + AB3->AB3_CODCLI + AB3->AB3_LOJA))
		oHtml:ValByName("CNPJ"	, SA1->A1_CGC )
	Endif
	
	AB5->(DbSetOrder(1)) //AB5_FILIAL+AB5_NUMORC+AB4_ITEM
	If AB5->(DbSeek(xFilial("AB5") + AB3->AB3_NUMORC, .F.))
		While !AB5->(EoF()) .And. AB5->AB5_FILIAL + AB5->AB5_NUMORC == xFilial("AB3") + AB3->AB3_NUMORC
			AAdd((oHtml:ValByName("it1.2")), AB5->AB5_CODPRO)
			AAdd((oHtml:ValByName("it1.3")), AllTrim(Posicione("SB1", 1, xFilial("SB1") + AB5->AB5_CODPRO, "B1_DESC")))
			AAdd((oHtml:ValByName("it1.4")), AB5->AB5_QUANT )
			AAdd((oHtml:ValByName("it1.5")), AB5->AB5_TOTAL )
			AAdd((oHtml:ValByName("it1.6")), AB5->AB5_VUNIT )
			nTotal += AB5->AB5_TOTAL
			AB5->(DbSkip())
		End	
	EndIf
	
	oHtml:ValByName("TOTAL"	, nTotal)

	//Envio o email para o solicitante
	cDestino := "\Workflow\orcamento\"
	_nPosFile := RAT("\", cFileEnv)
	_cFileAttac := cDestino + AllTrim(SubStr(cFileEnv, _nPosFile + 1))

	// Atacha arquivo configurado no inicio
	COPY FILE &(AllTrim(cFileEnv) + ".pdf") To &(AllTrim(_cFileAttac) + ".pdf")
	Sleep(5000)



	oProcess:AttachFile(AllTrim(_cFileAttac)+".pdf")
	oProcess:ClientName(cUserName)
	oProcess:cTo := "pedcom1"
	oProcess:bReturn := "U_PFGS002R()"
	
	//oProcess:cTo := cTo
	oProcess:cSubject := "Workflow de Orçamento Perfil (" + DTOC(Date()) + " - " + Time() + ")" + " - PFGS002"
	cMailId := oProcess:Start('workflow\emp02\mail\workflow\sent\' + DTOS(Date()))  
	

	cAssunto	:= "Aprovação do Orçamento Nº:" + AB3->AB3_NUMORC
	cHtmlModelo := "\workflow\orcamento\HTML\WFLINK.HTM"
	oProcess:NewTask(cAssunto, cHtmlModelo)  
	oProcess:cSubject := cAssunto
	oProcess:cTo := cTo
	oProcess:cCC := SuperGetMv( "MV_EMAILOR" , .F. , "" ,  )
	//oProcess:oHtml:ValByName("WAPROV"	, SAK->AK_NOME)
	oProcess:oHtml:ValByName("WLink"	, "http://192.168.12.13:8084/wf/workflow/emp02/mail/workflow/sent/" + DTOS(dDataBase) +"/" + cMailID + ".htm")
	oProcess:Start()
	oProcess:Free()
	//http://192.168.12.12:8084/wf/workflow/emp02/mail/workflow/sent/20210604/0000565e017e5640cab8.htm
	MsgInfo("E-mail enviado com sucesso!")
	RecLock("AB3",.F.)
	AB3->AB3__STAWF := "1" // Enviado
	AB3->(MsUnlock())


	RestArea(aArea)
	RestArea(aAreaAB3)
	RestArea(aAreaAB4)
	
Return
