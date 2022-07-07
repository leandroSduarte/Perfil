#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  | DDMAXI1X  ºAutor  ³ Gabriel Veríssimo º Data ³  04/11/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de integração Ativo   MOBILE                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Perfil                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DDMAXI2X(lMensagem, lDel)

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
	Local cDesc			:= ""
	Local aAreaSB1		:= SB1->(GetArea())

	Local lDesen := GetNewPar("MV_XAPIDEV",.T.)
	Local cTabUmov := ""

	Default lMensagem 	:= .T.
	Default	lDel		:= .F.

	if lDesen
		cTabUmov := "320899"
	else
		cTabUmov := "219403"
	endif
	
	If ValType(lMensagem) <> "L"
		lMensagem := .T.
	EndIf
	
	If ValType(lDel) <> "L"
		lDel := .F.
	EndIf

	aAdd(a_HeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')
	aAdd(a_HeadOut,'Content-Type: application/x-www-form-urlencoded')

	If !Empty(AA3->AA3_XMAXID)
		c_Url	:=	"https://api.umov.me/CenterWeb/api/"+AllTrim(c_key)+"/customEntity/"+cTabUmov+"/customEntityEntry/"+AllTrim(AA3->AA3_XMAXID)+".xml"
	Else
		c_Url	:=	"https://api.umov.me/CenterWeb/api/"+AllTrim(c_key)+"/customEntity/"+cTabUmov+"/customEntityEntry.xml"
	EndIf
	
	cDesc := Posicione("SB1", 1, xFilial("SB1") + AA3->AA3_CODPRO, "B1_DESC")
	
	c_XML := ""
	c_XML += "data=<customEntityEntry>" + CRLF
	c_XML += "<alternativeIdentifier>" + Alltrim(AA3->AA3_NUMSER) + "</alternativeIdentifier>"+CRLF
	c_XML += "<description>" + Alltrim(AA3->AA3_NUMSER) + " - " + Alltrim(AjuStr(cDesc)) + "</description>"+CRLF
	c_XML += "<active>" + IIf(AA3->AA3_MSBLQL == "1" .Or. lDel, "false", "true") + "</active>"+CRLF
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
			c_Errors := "Erro no método HttpPost"
		Else
			c_Errors := "Erro na comunicação com a API Maxview"
			If XmlChildEx(o_xml:_RESULT,"_ERRORS")<>Nil
				c_Errors += " - " + StRTran(AllTrim(o_xml:_RESULT:_ERRORS:TEXT),";","")
			EndIf
		EndIf
	EndIf

	If !Empty(c_Errors)
		Conout("Não foi possível enviar o Ativo "+AllTrim(AA3->AA3_NUMSER)+" a Max View. Mensagem do erro: "+AllTrim(c_Errors))
		If lMensagem
			MsgStop("Não foi possível enviar o Ativo "+AllTrim(AA3->AA3_NUMSER)+" a Max View. Mensagem do erro: "+AllTrim(c_Errors))
		EndIf
		Return(Nil)
	EndIf

	If !Empty(c_IDMax)
		DbSelectArea("AA3")
		AA3->(RecLock("AA3",.F.))
		AA3->AA3_XMAXID := c_IDMax
		AA3->(MsUnlock())
	EndIf

	Conout("Ativo " + AllTrim(AA3->AA3_NUMSER) + " enviado a Max View. "+Iif(!Empty(c_IDMax),"ID Max "+AllTrim(c_IDMax),""))
	If lMensagem
		MsgInfo("Ativo " + AllTrim(AA3->AA3_NUMSER)+" enviado a Max View. "+Iif(!Empty(c_IDMax),"ID Max "+AllTrim(c_IDMax),""))
	EndIf
	
	RestArea(aAreaSB1)

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  | DDMAXI1Z   ºAutor  ³ Gabriel Veríssimo º Data ³ 04/11/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de integração de Ativo MOBILE - Todos               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Perfil	                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function DDMAXI2Z()

	RpcSetType(3)
	RPCSetEnv("02","0101")

	DBSelectArea("AA3")
	DBSetOrder(1)
	DBGoTop()

	While !AA3->(Eof())
		u_DDMAXI2X(.F.)
		AA3->(DbSkip())
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
	cTexto:=Strtran(cTexto,"´"," ")
	cTexto:=Strtran(cTexto,"'"," ")
	cTexto:=Strtran(cTexto,"&","E")
	cTexto:=Strtran(cTexto,"€","C")
	cTexto:=Strtran(cTexto,"‡","c")
	cTexto:=Strtran(cTexto,"Ž","A")
	cTexto:=Strtran(cTexto,chr(143),"A")
	cTexto:=Strtran(cTexto,"Å","A")
	cTexto:=Strtran(cTexto,"…","a")
	cTexto:=Strtran(cTexto,"†","a")
	cTexto:=Strtran(cTexto," ","a")
	cTexto:=Strtran(cTexto,"„","a")
	cTexto:=Strtran(cTexto,"¦","a")
	cTexto:=Strtran(cTexto,"å","a")
	cTexto:=Strtran(cTexto,chr(144),"E")
	cTexto:=Strtran(cTexto,"ˆ","e")
	cTexto:=Strtran(cTexto,"‚","e")
	cTexto:=Strtran(cTexto,"¡","i")
	cTexto:=Strtran(cTexto,chr(141),"i")
	cTexto:=Strtran(cTexto,"“","o")
	cTexto:=Strtran(cTexto,"”","o")
	cTexto:=Strtran(cTexto,"•","o")
	cTexto:=Strtran(cTexto,"¢","o")
	cTexto:=Strtran(cTexto,"§","o")
	cTexto:=Strtran(cTexto,"ð","o")
	cTexto:=Strtran(cTexto,"£","u")
	cTexto:=Strtran(cTexto,chr(129),"u")
	cTexto:=Strtran(cTexto,"Ñ","N")
	cTexto:=Strtran(cTexto,"ñ","n")
	cTexto:=Strtran(cTexto,"%","P")
	cTexto:=Strtran(cTexto,"$","S")
	cTexto:=Strtran(cTexto,"þ","c")
	cTexto:=Strtran(cTexto,"÷","o")
	cTexto:=Strtran(cTexto,"Ý","i")
	cTexto:=Strtran(cTexto,"°","o")
	cTexto:=Strtran(cTexto,"¬","q")
	cTexto:=Strtran(cTexto,"ƒ","a")
	cTexto:=Strtran(cTexto,"Ÿ","a")
	cTexto:=Strtran(cTexto,"Æ","a")
	cTexto:=Strtran(cTexto,"µ","a")
	cTexto:=Strtran(cTexto,"¶","A")
	cTexto:=Strtran(cTexto,"º","o")
	cTexto:=Strtran(cTexto,"ª","a")
	cTexto:=Strtran(cTexto,"ã","a")
	cTexto:=Strtran(cTexto,"Ã","A")
	cTexto:=Strtran(cTexto,"õ","o")
	cTexto:=Strtran(cTexto,"Õ","O")
	cTexto:=Strtran(cTexto,"ç","c")
	cTexto:=Strtran(cTexto,"Ç","C")
	cTexto:=Strtran(cTexto,"á","a")
	cTexto:=Strtran(cTexto,"é","e")
	cTexto:=Strtran(cTexto,"í","i")
	cTexto:=Strtran(cTexto,"ó","o")
	cTexto:=Strtran(cTexto,"ú","u")
	cTexto:=Strtran(cTexto,"à","a")
	cTexto:=Strtran(cTexto,"è","e")
	cTexto:=Strtran(cTexto,"ì","i")
	cTexto:=Strtran(cTexto,"ò","o")
	cTexto:=Strtran(cTexto,"ù","u")
	cTexto:=Strtran(cTexto,"â","a")
	cTexto:=Strtran(cTexto,"ê","e")
	cTexto:=Strtran(cTexto,"î","i")
	cTexto:=Strtran(cTexto,"ô","o")
	cTexto:=Strtran(cTexto,"û","u")
	cTexto:=Strtran(cTexto,"ä","a")
	cTexto:=Strtran(cTexto,"ë","e")
	cTexto:=Strtran(cTexto,"ï","i")
	cTexto:=Strtran(cTexto,"ö","o")
	cTexto:=Strtran(cTexto,"ü","u")
	cTexto:=Strtran(cTexto,"Á","A")
	cTexto:=Strtran(cTexto,"É","E")
	cTexto:=Strtran(cTexto,"Í","I")
	cTexto:=Strtran(cTexto,"Ó","O")
	cTexto:=Strtran(cTexto,"Ú","U")
	cTexto:=Strtran(cTexto,"À","A")
	cTexto:=Strtran(cTexto,"È","E")
	cTexto:=Strtran(cTexto,"Ì","I")
	cTexto:=Strtran(cTexto,"Ò","O")
	cTexto:=Strtran(cTexto,"Ù","U")
	cTexto:=Strtran(cTexto,"Â","A")
	cTexto:=Strtran(cTexto,"Ê","E")
	cTexto:=Strtran(cTexto,"Î","I")
	cTexto:=Strtran(cTexto,"Ô","O")
	cTexto:=Strtran(cTexto,"Û","U")
	cTexto:=Strtran(cTexto,"Ä","A")
	cTexto:=Strtran(cTexto,"Ë","E")
	cTexto:=Strtran(cTexto,"Ï","I")
	cTexto:=Strtran(cTexto,"Ö","O")
	cTexto:=Strtran(cTexto,"Ü","U")
	cTexto:=Strtran(cTexto,"–","-")
	cTexto:=Strtran(cTexto,chr(13)+chr(10),"")
Return(cTexto)
