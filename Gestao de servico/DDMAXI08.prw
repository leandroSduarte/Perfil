#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | DDMAXI8X   �Autor  � Gabriel Ver�ssimo � Data � 27/06/19   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina de integra��o Ordens de Servi�o MOBILE              ���
�������������������������������������������������������������������������͹��
���Uso       � Perfil		                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function DDMAXI8X(lMensagem, lDel)

	Local c_Url			:= ""
	Local n_TimeOut		:= 120
	Local a_HeadOut		:= {}
	Local c_HeadRet		:= ""
	Local s_PostRet		:= ""
	Local c_Error		:= ""
	Local c_Warning		:= ""
	Local o_Xml			:= Nil
	Local c_Errors		:= ""
	Local c_key			:= AllTrim(SuperGetMV("MV_XCHTASK",.F.,"",Nil))
	Local cChvAB7		:= ""
	Local cOcorren		:= ""
	Local lPrev			:= .F.
	Local cCodTec		:= ""
	Local lSucess		:= .T.
	Local cCodProd		:= ""
	Local cDesProd		:= ""

	Default lMensagem 	:= .T.
	Default lDel		:= .F.

	If ValType(lMensagem) <> "L"
		lMensagem := .T.
	EndIf

	If ValType(lDel) <> "L"
		lDel := .F.
	EndIf

	aAdd(a_HeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')
	aAdd(a_HeadOut,'Content-Type: application/x-www-form-urlencoded')

	// Define se a ordem de servi�o que est� sendo integrada � do tipo preventiva
	if AB6->AB6_XCLAOS == "2"
		lPrev := .T.
	endif

	// Ordem de servi�o corretiva deve ser integrada somente se estiver direcionada para algum t�cnico
	If !lPrev .And. Len(AB6->AB6_XIDTEC) == 0
		conout("Integra��o n�o ser� realizada pois o campo AB6_XIDTEC n�o foi preenchido.")
		If lMensagem
			MsgInfo("Integra��o n�o ser� realizada pois o campo AB6_XIDTEC n�o foi preenchido.", "DDMAXI08")
		EndIf
		lSucess := .F.
		Return lSucess
	EndIf

	AB7->(DbSetOrder(1)) // AB7_FILIAL+AB7_NUMOS+AB7_ITEM
	If !(AB7->(DbSeek(xFilial("AB7") + AB6->AB6_NUMOS)))
		conout("Integra��o n�o ser� realizada pois n�o foi poss�vel localizar registro no alias AB7")
		If lMensagem
			MsgInfo("Integra��o n�o ser� realizada pois n�o foi poss�vel localizar registro no alias AB7")
		EndIf
		lSucess := .F.
		Return lSucess
	Else
		While !AB7->(EoF()) .And. AB7->AB7_FILIAL + AB7->AB7_NUMOS == AB6->AB6_FILIAL + AB6->AB6_NUMOS
			AA3->(DbSetOrder(1)) //AA3_FILIAL+AA3_CODCLI+AA3_LOJA+AA3_CODPRO+AA3_NUMSER+AA3_FILORI
			If AA3->(DbSeek(xFilial("AA3") + AB7->AB7_CODCLI + AB7->AB7_LOJA + AB7->AB7_CODPRO + AB7->AB7_NUMSER))
				cCodProd := AllTrim(AA3->AA3_XMAXID)
				cDesProd := AllTrim(AA3->AA3_NUMSER) + " - " + AllTrim(Posicione("SB1", 1, xFilial("SB1") + AA3->AA3_CODPRO, "B1_DESC")) //+ " - " + AllTrim(AA3->AA3_NUMSER)
			EndIf

			cOcorren := Posicione("AAG", 1, xFilial("AAG") + AB7->AB7_CODPRB, "AAG_DESCRI")

			If !Empty(AB7->AB7_XMAXID)
				c_Url	:=	"https://api.umov.me/CenterWeb/api/"+AllTrim(c_key)+"/schedule/"+AllTrim(AB7->AB7_XMAXID)+".xml"
			Else
				c_Url	:=	"https://api.umov.me/CenterWeb/api/"+AllTrim(c_key)+"/schedule.xml"
			EndIf

			c_XML := ""
			c_XML += "data=<schedule>"+CRLF
			c_XML += "<agent>"+CRLF
			c_XML += "  <alternativeIdentifier>" + AllTrim(AB6->AB6_XIDTEC) + "</alternativeIdentifier>"+CRLF
			c_XML += "</agent>"+CRLF
			//Tipo de Tarefa
			c_XML += "<scheduleType>"+CRLF
			c_XML += "<alternativeIdentifier>" + IIf(!lPrev, "TP_TRF_OS_CORR", "TP_TRF_OS_PREV") + "</alternativeIdentifier>"+CRLF
			c_XML += "<active>true</active>"+CRLF
			c_XML += "</scheduleType>"+CRLF
			//Tipo de Tarefa
			c_XML += "<serviceLocal>"+CRLF
			c_XML += "  <alternativeIdentifier>" + AllTrim(AB6->AB6_CODCLI) + AllTrim(AB6->AB6_LOJA) + "</alternativeIdentifier>"+CRLF
			c_XML += "</serviceLocal>"+CRLF
			c_XML += "<alternativeIdentifier>"+Alltrim(AB7->AB7_NUMOS) + Alltrim(AB7->AB7_ITEM)+"</alternativeIdentifier>"+CRLF
			if !lPrev
				c_XML += "<date>"+SubStr(DtoS(AB6->AB6_EMISSA),1,4)+"-"+SubStr(DtoS(AB6->AB6_EMISSA),5,2)+"-"+SubStr(DtoS(AB6->AB6_EMISSA),7,2)+"</date>"+CRLF
				c_XML += "<hour>" + AllTrim(AB6->AB6_HORA) + "</hour>"+CRLF
			else
				c_XML += "<date>"+SubStr(DtoS(Date()),1,4)+"-"+SubStr(DtoS(Date()),5,2)+"-"+SubStr(DtoS(Date()),7,2)+"</date>"+CRLF
				c_XML += "<hour>" + AllTrim(SubStr(Time(), 1, 5)) + "</hour>"+CRLF
			endif
			c_XML += "<priority></priority>"+CRLF
			c_XML += "<origin>3</origin>"+CRLF
			c_XML += "<observation>OS: " + Alltrim(AB7->AB7_NUMOS) + CRLF
			c_XML += "Ativo: " + Alltrim(cDesProd) + CRLF
			if !lPrev
				c_XML += "CORRETIVA" + CRLF
			else
				c_XML += "PREVENTIVA" + CRLF
			endif
			c_XML += cOcorren + "</observation>"+CRLF
			// A tag <active> define se a tarefa  estar� ativa ou inativa
			c_XML += "<active>" + IIf(lDel, "false", "true") + "</active>"+CRLF
			c_XML += "<activitiesOrigin>7</activitiesOrigin>"+CRLF
			c_XML += "<activities></activities>"+CRLF
			c_XML += "<customFields>"+CRLF
			c_XML += "<NR__OS>" + Alltrim(AB7->AB7_NUMOS) + Alltrim(AB7->AB7_ITEM) + "</NR__OS>"+CRLF
			c_XML += "<COD__ATIVO__TRF>" + cCodProd + "</COD__ATIVO__TRF>"+CRLF //AB7_CODPRO
			c_XML += "<DESCR__ATIVO__TRF>" + cDesProd + "</DESCR__ATIVO__TRF>"+CRLF
			c_XML += "<ALF_CATEG_TAREFA>" + AllTrim(AB6->AB6_XCATEG) + "</ALF_CATEG_TAREFA>"+CRLF
			c_XML += "</customFields>"+CRLF
			c_XML += "</schedule>"+CRLF

			conout(c_Url)
			conout(c_XML)

			s_PostRet := HttpPost(c_Url, "", c_XML, n_TimeOut, a_HeadOut, @c_HeadRet)
			conout(s_PostRet)

			If ValType(s_PostRet) <> "U"
				o_Xml := Nil
				o_Xml := XmlParser(s_PostRet, "_",@c_Error, @c_Warning) //Abre o xml

				c_IDMax := ""
				If XmlChildEx(o_xml:_RESULT,"_RESOURCEID")<>Nil
					c_IDMax := AllTrim(o_xml:_RESULT:_RESOURCEID:TEXT)
				Else
					If XmlChildEx(o_xml:_RESULT,"_ERRORS")<>Nil
						c_Errors := StRTran(AllTrim(o_xml:_RESULT:_ERRORS:TEXT),";","")
					EndIf
				EndIf
			Else
				If ValType(s_PostRet) == "U"
					c_Errors := "Erro no m�todo HttpPost"
				Else
					c_Errors := "Erro na comunica��o com a API Maxview"
					If XmlChildEx(o_xml:_RESULT,"_ERRORS")<>Nil
						c_Errors += " - " + StRTran(AllTrim(o_xml:_RESULT:_ERRORS:TEXT),";","")
					EndIf
				EndIf
			EndIf

			If !Empty(c_Errors)
				Conout("N�o foi poss�vel enviar a Ordem de Servi�o "+AllTrim(AB7->AB7_NUMOS)+ "/" + AllTrim(AB7->AB7_ITEM) + " a Max View. Mensagem do erro: "+AllTrim(c_Errors))
				If lMensagem
					MsgStop("N�o foi poss�vel enviar a Ordem de Servi�o "+AllTrim(AB7->AB7_NUMOS)+ "/" + AllTrim(AB7->AB7_ITEM) +" a Max View. Mensagem do erro: "+AllTrim(c_Errors))
				EndIf
				lSucess := .F.
				Return lSucess
			EndIf

			If !Empty(c_IDMax)
				DbSelectArea("AB7")
				AB7->(RecLock("AB7",.F.))
				AB7->AB7_XMAXID := c_IDMax
				AB7->(MsUnlock())
			EndIf

			Conout("Ordem de Servi�o " + AllTrim(AB7->AB7_NUMOS) + "/" + AllTrim(AB7->AB7_ITEM) + " enviado a Max View. "+Iif(!Empty(c_IDMax),"ID Max "+AllTrim(c_IDMax),""))
			If lMensagem
				MsgInfo("Ordem de Servi�o " + AllTrim(AB7->AB7_NUMOS)+ "/" + AllTrim(AB7->AB7_ITEM) +" enviado a Max View. "+Iif(!Empty(c_IDMax),"ID Max "+AllTrim(c_IDMax),""))
			EndIf
			AB7->(DbSkip())
		End
	EndIf

Return lSucess


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | DDMAXI1Z   �Autor  � Gabriel Ver�ssimo  � Data �  27/06/19 ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina de integra��o de Clientes MOBILE - Todos            ���
�������������������������������������������������������������������������͹��
���Uso       � Perfil                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function DDMAXI8Z()

	RpcSetType(3)
	RPCSetEnv("02","0101")

	DBSelectArea("AB6")
	DBSetOrder(1)
	DBGoTop()

	While !AB6->(Eof())
		u_DDMAXI8X(.F.)
		AB6->(DbSkip())
	EndDo

	//RPCClearEnv() //Fecho o ambiente

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} AjuStr
Remove caracteres especiais

@author    Jonatas C. de Almeida
@version   1.xx
@since     17/06/2015
/*/
//-----------------------------------------------------------------------
Static Function AjuStr(_xTexto)
	Local cTexto := AllTrim(_xTexto)

	cTexto:=Strtran(cTexto,"@"," ")
	cTexto:=Strtran(cTexto,"�"," ")
	cTexto:=Strtran(cTexto,"'"," ")
	cTexto:=Strtran(cTexto,"&","E")
	cTexto:=Strtran(cTexto,"�","C")
	cTexto:=Strtran(cTexto,"�","c")
	cTexto:=Strtran(cTexto,"�","A")
	cTexto:=Strtran(cTexto,chr(143),"A")
	cTexto:=Strtran(cTexto,"�","A")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,chr(144),"E")
	cTexto:=Strtran(cTexto,"�","e")
	cTexto:=Strtran(cTexto,"�","e")
	cTexto:=Strtran(cTexto,"�","i")
	cTexto:=Strtran(cTexto,chr(141),"i")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","u")
	cTexto:=Strtran(cTexto,chr(129),"u")
	cTexto:=Strtran(cTexto,"�","N")
	cTexto:=Strtran(cTexto,"�","n")
	cTexto:=Strtran(cTexto,"%","P")
	cTexto:=Strtran(cTexto,"$","S")
	cTexto:=Strtran(cTexto,"�","c")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","i")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","q")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","A")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","A")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","O")
	cTexto:=Strtran(cTexto,"�","c")
	cTexto:=Strtran(cTexto,"�","C")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","e")
	cTexto:=Strtran(cTexto,"�","i")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","u")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","e")
	cTexto:=Strtran(cTexto,"�","i")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","u")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","e")
	cTexto:=Strtran(cTexto,"�","i")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","u")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","e")
	cTexto:=Strtran(cTexto,"�","i")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","u")
	cTexto:=Strtran(cTexto,"�","A")
	cTexto:=Strtran(cTexto,"�","E")
	cTexto:=Strtran(cTexto,"�","I")
	cTexto:=Strtran(cTexto,"�","O")
	cTexto:=Strtran(cTexto,"�","U")
	cTexto:=Strtran(cTexto,"�","A")
	cTexto:=Strtran(cTexto,"�","E")
	cTexto:=Strtran(cTexto,"�","I")
	cTexto:=Strtran(cTexto,"�","O")
	cTexto:=Strtran(cTexto,"�","U")
	cTexto:=Strtran(cTexto,"�","A")
	cTexto:=Strtran(cTexto,"�","E")
	cTexto:=Strtran(cTexto,"�","I")
	cTexto:=Strtran(cTexto,"�","O")
	cTexto:=Strtran(cTexto,"�","U")
	cTexto:=Strtran(cTexto,"�","A")
	cTexto:=Strtran(cTexto,"�","E")
	cTexto:=Strtran(cTexto,"�","I")
	cTexto:=Strtran(cTexto,"�","O")
	cTexto:=Strtran(cTexto,"�","U")
	cTexto:=Strtran(cTexto,"�","-")
	cTexto:=Strtran(cTexto,chr(13)+chr(10),"")
Return(cTexto)
