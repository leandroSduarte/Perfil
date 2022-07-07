#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  | DDMAX12X   บAutor  ณ Gabriel Verํssimo บ Data ณ  11/07/19  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de integra็ใo de Produtos MOBILE                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Perfil                                               	  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function DDMAX12X(lMensagem, lDel)

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
	Local cChvAB7		:= ""

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

	If !Empty(SB1->B1_XMAXID)
		c_Url	:=	"https://api.umov.me/CenterWeb/api/"+AllTrim(c_key)+"/item/"+AllTrim(SB1->B1_XMAXID)+".xml"
	Else
		c_Url	:=	"https://api.umov.me/CenterWeb/api/"+AllTrim(c_key)+"/item.xml"
	EndIf
	
	cGrupo := AllTrim(Posicione("SBM", 1, xFilial("SBM") + SB1->B1_GRUPO, "BM_GRUPO"))
	
	c_XML := ""
	c_XML += "data=<item>" + CRLF
	c_XML += " <alternativeIdentifier>" + Alltrim(SB1->B1_COD) + "</alternativeIdentifier>"+CRLF
	c_XML += " <description>" + Alltrim(AjuStr(SB1->B1_DESC)) + "</description>"+CRLF
	c_XML += " <active>" + IIf(SB1->B1_MSBLQL == "1" .Or. lDel, "false", "true") + "</active>"+CRLF
	c_XML += "<subGroup>
	c_XML += "  <alternativeIdentifier>" + IIf(Empty(cGrupo), "9999", cGrupo) + "</alternativeIdentifier>
	c_XML += "</subGroup>
	c_XML += "<tags>" + AllTrim(AjuStr(SB1->B1_XTAG)) + "</tags>"
	c_XML += "</item>" + CRLF

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
			c_Errors := "Erro no m้todo HttpPost"
		Else
			c_Errors := "Erro na comunica็ใo com a API Maxview"
			If XmlChildEx(o_xml:_RESULT,"_ERRORS")<>Nil
				c_Errors += " - " + StRTran(AllTrim(o_xml:_RESULT:_ERRORS:TEXT),";","")
			EndIf
		EndIf
	EndIf

	If !Empty(c_Errors)
		Conout("Nใo foi possํvel enviar o Produto "+AllTrim(SB1->B1_COD)+" a Max View. Mensagem do erro: "+AllTrim(c_Errors))
		If lMensagem
			MsgStop("Nใo foi possํvel enviar o Produto "+AllTrim(SB1->B1_COD)+" a Max View. Mensagem do erro: "+AllTrim(c_Errors))
		EndIf
		Return(Nil)
	EndIf

	If !Empty(c_IDMax)
		DbSelectArea("SB1")
		SB1->(RecLock("SB1",.F.))
		SB1->B1_XMAXID := c_IDMax
		SB1->(MsUnlock())
	EndIf

	Conout("Produto " + AllTrim(SB1->B1_COD) + " enviado a Max View. "+Iif(!Empty(c_IDMax),"ID Max "+AllTrim(c_IDMax),""))
	If lMensagem
		MsgInfo("Produto " + AllTrim(SB1->B1_COD)+" enviado a Max View. "+Iif(!Empty(c_IDMax),"ID Max "+AllTrim(c_IDMax),""))
	EndIf

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  | DDMAXI1Z   บAutor  ณ Anderson Messias บ Data ณ  14/05/19   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de integra็ใo de Produtos MOBILE - Todos            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Perfil                                               	  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DDMAX12Z()

	RpcSetType(3)
	RPCSetEnv("02","0101")

	DBSelectArea("SB1")
	DBSetOrder(1)
	DBGoTop()

	While !SB1->(Eof())
		u_DDMAX12X(.F.)
		SB1->(DbSkip())
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
	cTexto:=Strtran(cTexto,"ด"," ")
	cTexto:=Strtran(cTexto,"'"," ")
	cTexto:=Strtran(cTexto,"&","E")
	cTexto:=Strtran(cTexto,"€","C")
	cTexto:=Strtran(cTexto,"","c")
	cTexto:=Strtran(cTexto,"","A")
	cTexto:=Strtran(cTexto,chr(143),"A")
	cTexto:=Strtran(cTexto,"ล","A")
	cTexto:=Strtran(cTexto,"…","a")
	cTexto:=Strtran(cTexto,"","a")
	cTexto:=Strtran(cTexto," ","a")
	cTexto:=Strtran(cTexto,"","a")
	cTexto:=Strtran(cTexto,"ฆ","a")
	cTexto:=Strtran(cTexto,"ๅ","a")
	cTexto:=Strtran(cTexto,chr(144),"E")
	cTexto:=Strtran(cTexto,"","e")
	cTexto:=Strtran(cTexto,"","e")
	cTexto:=Strtran(cTexto,"ก","i")
	cTexto:=Strtran(cTexto,chr(141),"i")
	cTexto:=Strtran(cTexto,"“","o")
	cTexto:=Strtran(cTexto,"”","o")
	cTexto:=Strtran(cTexto,"•","o")
	cTexto:=Strtran(cTexto,"ข","o")
	cTexto:=Strtran(cTexto,"ง","o")
	cTexto:=Strtran(cTexto,"๐","o")
	cTexto:=Strtran(cTexto,"ฃ","u")
	cTexto:=Strtran(cTexto,chr(129),"u")
	cTexto:=Strtran(cTexto,"ั","N")
	cTexto:=Strtran(cTexto,"๑","n")
	cTexto:=Strtran(cTexto,"%","P")
	cTexto:=Strtran(cTexto,"$","S")
	cTexto:=Strtran(cTexto,"þ","c")
	cTexto:=Strtran(cTexto,"๗","o")
	cTexto:=Strtran(cTexto,"Ý","i")
	cTexto:=Strtran(cTexto,"ฐ","o")
	cTexto:=Strtran(cTexto,"ฌ","q")
	cTexto:=Strtran(cTexto,"","a")
	cTexto:=Strtran(cTexto,"","a")
	cTexto:=Strtran(cTexto,"ฦ","a")
	cTexto:=Strtran(cTexto,"ต","a")
	cTexto:=Strtran(cTexto,"ถ","A")
	cTexto:=Strtran(cTexto,"บ","o")
	cTexto:=Strtran(cTexto,"ช","a")
	cTexto:=Strtran(cTexto,"ใ","a")
	cTexto:=Strtran(cTexto,"ร","A")
	cTexto:=Strtran(cTexto,"๕","o")
	cTexto:=Strtran(cTexto,"ี","O")
	cTexto:=Strtran(cTexto,"็","c")
	cTexto:=Strtran(cTexto,"ว","C")
	cTexto:=Strtran(cTexto,"แ","a")
	cTexto:=Strtran(cTexto,"้","e")
	cTexto:=Strtran(cTexto,"ํ","i")
	cTexto:=Strtran(cTexto,"๓","o")
	cTexto:=Strtran(cTexto,"๚","u")
	cTexto:=Strtran(cTexto,"เ","a")
	cTexto:=Strtran(cTexto,"่","e")
	cTexto:=Strtran(cTexto,"์","i")
	cTexto:=Strtran(cTexto,"๒","o")
	cTexto:=Strtran(cTexto,"๙","u")
	cTexto:=Strtran(cTexto,"โ","a")
	cTexto:=Strtran(cTexto,"๊","e")
	cTexto:=Strtran(cTexto,"๎","i")
	cTexto:=Strtran(cTexto,"๔","o")
	cTexto:=Strtran(cTexto,"๛","u")
	cTexto:=Strtran(cTexto,"ไ","a")
	cTexto:=Strtran(cTexto,"๋","e")
	cTexto:=Strtran(cTexto,"๏","i")
	cTexto:=Strtran(cTexto,"๖","o")
	cTexto:=Strtran(cTexto,"ü","u")
	cTexto:=Strtran(cTexto,"ม","A")
	cTexto:=Strtran(cTexto,"ษ","E")
	cTexto:=Strtran(cTexto,"อ","I")
	cTexto:=Strtran(cTexto,"ำ","O")
	cTexto:=Strtran(cTexto,"ฺ","U")
	cTexto:=Strtran(cTexto,"ภ","A")
	cTexto:=Strtran(cTexto,"ศ","E")
	cTexto:=Strtran(cTexto,"ฬ","I")
	cTexto:=Strtran(cTexto,"า","O")
	cTexto:=Strtran(cTexto,"ู","U")
	cTexto:=Strtran(cTexto,"ย","A")
	cTexto:=Strtran(cTexto,"ส","E")
	cTexto:=Strtran(cTexto,"ฮ","I")
	cTexto:=Strtran(cTexto,"ิ","O")
	cTexto:=Strtran(cTexto,"Û","U")
	cTexto:=Strtran(cTexto,"ฤ","A")
	cTexto:=Strtran(cTexto,"ห","E")
	cTexto:=Strtran(cTexto,"ฯ","I")
	cTexto:=Strtran(cTexto,"ึ","O")
	cTexto:=Strtran(cTexto,"Ü","U")
	cTexto:=Strtran(cTexto,"–","-")
	cTexto:=Strtran(cTexto,chr(13)+chr(10),"")
	
Return(cTexto)