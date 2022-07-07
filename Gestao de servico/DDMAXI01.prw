#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | DDMAXI1X  �Autor  � Gabriel Ver�ssimo � Data �  04/11/19   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina de integra��o Cliente MOBILE                        ���
�������������������������������������������������������������������������͹��
���Uso       � Perfil                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function DDMAXI1X(lMensagem, lDel)

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
	Local cAtivo		:= ""
	Local aAreaSA1		:= SA1->(GetArea())
	Local aAreaAA3		:= AA3->(GetArea())
	Local cImgUrl		:= SuperGetMv("MV_XIMGURL", .F., "")

	Local lDesen := GetNewPar("MV_XAPIDEV",.T.)
	Local cTabUmov := ""

	Default lMensagem 	:= .T.
	Default	lDel		:= .F.

	if lDesen
		cTabUmov := "320898"
	else
		cTabUmov := "209562"
	endif

	If ValType(lMensagem) <> "L"
		lMensagem := .T.
	EndIf

	If ValType(lDel) <> "L"
		lDel := .F.
	EndIf

	aAdd(a_HeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')
	aAdd(a_HeadOut,'Content-Type: application/x-www-form-urlencoded')

	//Integra��o CustomEntity
	If !Empty(SA1->A1_XMAXID)
		c_Url	:=	"https://api.umov.me/CenterWeb/api/"+AllTrim(c_key)+"/customEntity/"+cTabUmov+"/customEntityEntry/"+AllTrim(SA1->A1_XMAXID)+".xml"
	Else
		c_Url	:=	"https://api.umov.me/CenterWeb/api/"+AllTrim(c_key)+"/customEntity/"+cTabUmov+"/customEntityEntry.xml"
	EndIf

	c_XML := ""
	c_XML += "data=<customEntityEntry>" + CRLF
	c_XML += "<description>" + AllTrim(AjuStr(SA1->A1_NOME)) + " - " + AllTrim(SA1->A1_LOJA) + "</description>" + CRLF
	c_XML += "<active>" + IIf(SA1->A1_MSBLQL == "1" .Or. lDel, "false", "true") + "</active>" + CRLF //Tratar o campo A1_MSBLQL se existir
	c_XML += "<alternativeIdentifier>" + AllTrim(SA1->A1_COD) + AllTrim(SA1->A1_LOJA) + "</alternativeIdentifier>" + CRLF
	c_XML += "</customEntityEntry>" + CRLF

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
			c_Errors := "Erro na comunicacao com a API Maxview"
			If XmlChildEx(o_xml:_RESULT,"_ERRORS")<>Nil
				c_Errors += " - " + StrTran(AllTrim(o_xml:_RESULT:_ERRORS:TEXT),";","")
			EndIf
		EndIf
	EndIf

	If !Empty(c_Errors)
		Conout("N�o foi poss�vel enviar o Cliente "+AllTrim(SA1->A1_NOME)+" a Max View. Mensagem do erro: "+AllTrim(c_Errors))
		if lMensagem
			MsgStop("N�o foi poss�vel enviar o Cliente "+AllTrim(SA1->A1_NOME)+" a Max View. Mensagem do erro: "+AllTrim(c_Errors))
		endif
		Return(Nil)
	EndIf

	if !Empty(c_IDMax)
		if Empty(SA1->A1_XMAXID)
			dbSelectArea("SA1")
			SA1->(RecLock("SA1",.F.))
			SA1->A1_XMAXID := c_IDMax
			SA1->(MsUnlock())
		endif
	endif

	Conout("Cliente "+AllTrim(SA1->A1_NOME)+" enviado a Max View. "+Iif(!Empty(c_IDMax),"ID Max "+AllTrim(c_IDMax),""))
	if lMensagem
		MsgInfo("Cliente "+AllTrim(SA1->A1_NOME)+" enviado a Max View. "+Iif(!Empty(c_IDMax),"ID Max "+AllTrim(c_IDMax),""))
	endif
	//Integra��o CustomEntity

	//Integra��o ServiceLocal
	If !Empty(SA1->A1_XMAXIDS)
		c_Url	:=	"https://api.umov.me/CenterWeb/api/"+AllTrim(c_key)+"/serviceLocal/"+AllTrim(SA1->A1_XMAXIDS)+".xml"
	Else
		c_Url	:=	"https://api.umov.me/CenterWeb/api/"+AllTrim(c_key)+"/serviceLocal.xml"
	EndIf

	DBSelectArea("SA1")
	DBSetOrder(1)
	DBSeek(xFilial("SA1")+SA1->A1_COD+SA1->A1_LOJA)

	AA3->(DbSetOrder(1)) //AA3_FILIAL+AA3_CODCLI+AA3_LOJA+AA3_CODPRO+AA3_NUMSER+AA3_FILORI
	If AA3->(DbSeek(xFilial("AA3") + SA1->A1_COD + SA1->A1_LOJA))
		While !AA3->(EoF()) .And. AA3->AA3_CODCLI + AA3->AA3_LOJA == SA1->A1_COD + SA1->A1_LOJA
			if len(alltrim(AA3->AA3_XMAXID)) > 0
				cAtivo += AllTrim(AA3->AA3_XMAXID) + "|"
			endif
			AA3->(DbSkip())
		End
	End

	c_XML := ""
	c_XML += "data=<serviceLocal>"+CRLF
	c_XML += "<description>" + AllTrim(AjuStr(SA1->A1_NOME)) + " - " + AllTrim(SA1->A1_LOJA) +"</description>"+CRLF 
	c_XML += "<active>" + IIf(SA1->A1_MSBLQL == "1" .Or. lDel, "false", "true") + "</active>" + CRLF //Tratar o campo A1_MSBLQL se existir
	c_XML += "<alternativeIdentifier>"+AllTrim(SA1->A1_COD)+AllTrim(SA1->A1_LOJA)+"</alternativeIdentifier>"+CRLF
	c_XML += "<corporateName>"+AllTrim(AjuStr(SA1->A1_NOME))+"</corporateName>"+CRLF
	c_XML += "<country>Brasil</country>"+CRLF
	c_XML += "<state>"+AllTrim(SA1->A1_EST)+"</state>"+CRLF
	c_XML += "<city>"+AllTrim(AjuStr(SA1->A1_MUN))+"</city>"+CRLF
	c_XML += "<cityNeighborhood>"+AllTrim(AjuStr(SA1->A1_BAIRRO))+"</cityNeighborhood>"+CRLF
	c_XML += "<street>"+AllTrim(AjuStr(SA1->A1_END))+"</street>"+CRLF
	c_XML += "<streetComplement/>"+CRLF
	c_XML += "<zipCode>"+AllTrim(SA1->A1_CEP)+"</zipCode>"+CRLF
	c_XML += "<cellphoneNumber/>"+CRLF
	c_XML += "<phoneIdd>" + AllTrim(SA1->A1_DDD) + "</phoneIdd>"+CRLF
	c_XML += "<phoneNumber>"+AllTrim(StrTran(SA1->A1_TEL, "-", ""))+"</phoneNumber>"+CRLF
	c_XML += "<email>"+AllTrim(SA1->A1_EMAIL)+"</email>"+CRLF
	c_XML += "<observation>"+AllTrim(AjuStr(SA1->A1_OBS))+"</observation>"+CRLF
	c_XML += "<origin>1</origin>"+CRLF
	c_XML += "<serviceLocalActivities/>"+CRLF
	c_XML += "<image>"+CRLF
	c_XML += "  <imageUrlImport>" + cImgUrl + AllTrim(SA1->A1_COD) + ".png</imageUrlImport>"
	c_XML += "</image>"+CRLF
	c_XML += "<customFields>"+CRLF
	c_XML += "	<ATIVO__CLIENTE>" + cAtivo + "</ATIVO__CLIENTE>"+CRLF
	c_XML += "</customFields>"+CRLF
	c_XML += "<processGeocoordinate>false</processGeocoordinate>"+CRLF
	c_XML += "<serviceLocalType>"+CRLF
	// c_XML += "	<id>182231</id>"+CRLF
	c_XML += "  <description>Cliente</description>"+CRLF
	c_XML += "  <alternativeIdentifier>TPCL001</alternativeIdentifier>"+CRLF
	c_XML += "  <active>true</active>"+CRLF
	c_XML += "</serviceLocalType>"+CRLF
	c_XML += "</serviceLocal>"+CRLF

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
		c_Errors := "Erro na comunicacao com a API Maxview"
		If XmlChildEx(o_xml:_RESULT,"_ERRORS")<>Nil
			c_Errors += " - " + StrTran(AllTrim(o_xml:_RESULT:_ERRORS:TEXT),";","")
		EndIf
	EndIf

	If !Empty(c_Errors)
		Conout("N�o foi poss�vel enviar o Cliente "+AllTrim(SA1->A1_NOME)+" a Max View. Mensagem do erro: "+AllTrim(c_Errors))
		if lMensagem
			MsgStop("N�o foi poss�vel enviar o Cliente "+AllTrim(SA1->A1_NOME)+" a Max View. Mensagem do erro: "+AllTrim(c_Errors))
		endif
		Return(Nil)
	EndIf

	if !Empty(c_IDMax)
		DbSelectArea("SA1")
		SA1->(RecLock("SA1",.F.))
		SA1->A1_XMAXIDS := c_IDMax
		SA1->(MsUnlock())
	endif

	Conout("Cliente " + AllTrim(SA1->A1_NOME) + " enviado a Max View. "+Iif(!Empty(c_IDMax),"ID Max "+AllTrim(c_IDMax),""))
	if lMensagem
		MsgInfo("Cliente " + AllTrim(SA1->A1_NOME)+" enviado a Max View. "+Iif(!Empty(c_IDMax),"ID Max "+AllTrim(c_IDMax),""))
	endif
	//Integra��o ServiceLocal
	
	RestArea(aAreaSA1)
	RestArea(aAreaAA3)

Return(Nil)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | DDMAXI1Z   �Autor  � Gabriel Ver�ssimo � Data � 04/11/19   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina de integra��o de Clientes MOBILE - Todos            ���
�������������������������������������������������������������������������͹��
���Uso       � Perfil	                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function DDMAXI1Z()

	RpcSetType(3)
	RPCSetEnv("02","0101")

	DBSelectArea("SA1")
	DBSetOrder(1)
	DBGoTop()

	While !SA1->(Eof())
		u_DDMAXI1X(.F.)
		SA1->(DbSkip())
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

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | CRMA980    �Autor  � Gabriel Ver�ssimo � Data � 04/11/19   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada da rotina de cadastro de clientes         ���
��           � no modelo MVC									          ���
�������������������������������������������������������������������������͹��
���Uso       � Perfil	                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function CRMA980()

	Local aParam	:= PARAMIXB
	Local oObj
	Local cIdPonto	:= ""
	Local cIdModel	:= ""
	Local lRet		:= .T.

	If aParam <> NIL
		oObj		:= aParam[1]
		cIdPonto	:= aParam[2]
		cIdModel	:= aParam[3]

		If cIdPonto == "FORMCOMMITTTSPRE"
			If !(Inclui .Or. Altera)
				//u_DDMAXI1X(.F., .T.)
			EndIf
		ElseIf cIdPonto == "FORMCOMMITTTSPOS"
			//u_DDMAXI1X(.F.)
		EndIf
	EndIf

Return lRet
