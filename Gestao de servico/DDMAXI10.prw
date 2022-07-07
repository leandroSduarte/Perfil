#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | DDMAX10X   �Autor  � Gabriel Ver�ssimo � Data �  11/07/19  ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina de integra��o de Atendentes MOBILE                  ���
�������������������������������������������������������������������������͹��
���Uso       � Perfil                                               	  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function DDMAX10X(lMensagem, lDel)

	Local c_Url			:= ""
	Local n_TimeOut		:= 120
	Local a_HeadOut		:= {}
	Local c_HeadRet		:= ""
	Local s_PostRet		:= ""
	Local c_Error		:= ""
	Local c_Warning		:= ""
	Local o_Xml			:= Nil
	Local c_Errors		:= ""
	Local c_key			:= AllTrim(SuperGetMV("MV_XCHTASK",.F.,"23484ede3a4e10ce2bfa3ac80c16dfcb9932d",Nil))

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

	//Valida��o para somente realizar integra��o quando a OS estiver direcionada para algum t�cnico
	If Empty(AA1->AA1_NREDUZ) .Or. Empty(AA1->AA1_SENHA)
		conout("Integra��o n�o ser� realizada pois os campos de Login e Senha n�o foram preenchidos.")
		If lMensagem
			MsgInfo("Integra��o n�o ser� realizada pois os campos de Login e Senha n�o foram preenchidos.", "DDMAXI10")
		EndIf
		Return Nil
	EndIf

	If !Empty(AA1->AA1_XMAXID)
		c_Url	:=	"https://api.umov.me/CenterWeb/api/"+AllTrim(c_key)+"/agent/"+AllTrim(AA1->AA1_XMAXID)+".xml"
	Else
		c_Url	:=	"https://api.umov.me/CenterWeb/api/"+AllTrim(c_key)+"/agent.xml"
	EndIf

	c_XML := ""
	c_XML += "data=<agent>"+CRLF
	c_XML += "  <alternativeIdentifier>" + AllTrim(AA1->AA1_CODTEC) + iif(lDel, "_old", "") + "</alternativeIdentifier>"+CRLF
	c_XML += "  <active>" + IIf(AA1->AA1_MSBLQL == "1" .Or. lDel, "false", "true") + "</active>"+CRLF
	c_XML += "  <name>" + AllTrim(AjuStr(AA1->AA1_NOMTEC)) + "</name>"+CRLF
	c_XML += "  <login>" + AllTrim(AjuStr(AA1->AA1_NREDUZ)) + "</login>"+CRLF
	c_XML += "  <password>" + AllTrim(AA1->AA1_SENHA) + "</password>"+CRLF
	c_XML += "	<email>" + AllTrim(AA1->AA1_EMAIL) + "</email>"+CRLF
	//Habilita usu�rio a acessar mobile
	c_XML += "  <mobileUser>true</mobileUser>"+CRLF
	//Campo 'Tipo de Pessoa'
	c_XML += "	<agentType>"+CRLF
	c_XML += "		<alternativeIdentifier>TEC001</alternativeIdentifier>"+CRLF
	c_XML += "	</agentType>"+CRLF
	//Campo 'Idioma'
	c_XML += "	<idiom>"+CRLF
	c_XML += "		<locale>pt_BR</locale>"+CRLF
	c_XML += "	</idiom>"+CRLF
	c_XML += "</agent>"+CRLF

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
		Conout("N�o foi poss�vel enviar o Atendente "+AllTrim(AA1->AA1_CODTEC)+" a Max View. Mensagem do erro: "+AllTrim(c_Errors))
		If lMensagem
			MsgStop("N�o foi poss�vel enviar o Atendente "+AllTrim(AA1->AA1_CODTEC)+" a Max View. Mensagem do erro: "+AllTrim(c_Errors))
		EndIf
		Return(Nil)
	EndIf

	If !Empty(c_IDMax)
		DbSelectArea("AA1")
		AA1->(RecLock("AA1",.F.))
		AA1->AA1_XMAXID := c_IDMax
		AA1->(MsUnlock())
	EndIf

	Conout("Atendente " + AllTrim(AA1->AA1_CODTEC) + " enviado a Max View. "+Iif(!Empty(c_IDMax),"ID Max "+AllTrim(c_IDMax),""))
	If lMensagem
		MsgInfo("Atendente " + AllTrim(AA1->AA1_CODTEC)+" enviado a Max View. "+Iif(!Empty(c_IDMax),"ID Max "+AllTrim(c_IDMax),""))
	EndIf

Return(Nil)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | DDMAXI1Z   �Autor  � Gabriel Ver�ssimo � Data �  11/07/19  ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina de integra��o de Atendentes MOBILE - Todos          ���
�������������������������������������������������������������������������͹��
���Uso       � Perfil                                               	  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function DDMAX10Z()

	RpcSetType(3)
	RPCSetEnv("02","0101")

	DBSelectArea("AA1")
	DBSetOrder(1)
	DBGoTop()

	While !AA1->(Eof())
		u_DDMAX10X(.F.)
		AA1->(DbSkip())
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
