#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"  


/*------------------------------------------------------------------------
{Protheus.doc} WSCPCEMER

@Author  	   Felipe Aguiar - Delta Decisao
@since		   12/2019
@version	   P12

@description API para consultar as Controladoras Emerson
--------------------------------------------------------------------------
|Author                  | Date       | Description                       |
|                        |            |                                   |
-------------------------------------------------------------------------*/
User Function WSCPCEMER()
    Local n_Item        := 0
    Local c_Url			:= ""
    Local c_XML			:= ""
    Local n_TimeOut		:= 120
    Local a_HeadOut		:= {}
    Local c_HeadRet		:= ""
    Local c_Warning		:= ""
    Local c_Error		:= ""
    Local cInfo 		:= ""
    Local lRet          := .T.
    Local nX            := 0
    Private cCpoFim   := "ZA1_DTFIM/ZA1_HRFIM"

    conout("INICIO CPC-EMERSON")

    aAdd(a_HeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')
    aAdd(a_HeadOut,'Content-Type: application/xml')

    c_Url	:= AllTrim(ZA2->ZA2_END)  // "http://172.10.11.2"

    c_XML := "<s:Envelope xmlns:s='http://schemas.xmlsoap.org/soap/envelope/'>" + CRLF
    c_XML += "<s:Body xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema'>" + CRLF
    c_XML += "<GetAlarmList xmlns='http://tempuri.org/e2.xsd'>" + CRLF
    c_XML += "  <controller></controller>" + CRLF
    c_XML += "  <filter>false</filter>" + CRLF
    c_XML += "</GetAlarmList>" + CRLF
    c_XML += "</s:Body>" + CRLF
    c_XML += "</s:Envelope>" + CRLF

    conout("Request GetAlarmList")
    conout(c_Url)
    conout(c_XML)
    s_PostRet := HttpPost(c_Url, "", c_XML, n_TimeOut, a_HeadOut, @c_HeadRet)
    // conout("Response GetAlarmList")
    // conout(s_PostRet)

    If ValType(s_PostRet) <> "U"
        o_Xml := Nil
        o_Xml := XmlParser(s_PostRet , "_" , @c_Error, @c_Warning) //Abre o xml
        // conout(o_Xml)
        // conout(VarInfo("o_Xml", o_Xml, , .F.))

        if o_Xml == NIL
            conout("Erro no parse do XML")
            // cInfo += "Erro no parse do XML de criação do alarme"
            lRet := .F.
        elseif XmlChildEx(o_Xml, "_SOAP_ENV_ENVELOPE") == NIL
            conout("Erro no primeiro node")
            // cInfo += "Erro no node _GetAlarmListResponse de criação do alarme"
            lRet := .F.
            // Return cRet
        elseif XmlChildEx(o_xml:_SOAP_ENV_ENVELOPE, "_SOAP_ENV_BODY") == NIL
            conout("Erro no segundo node")
            // cInfo += "Erro no node _RESPONSE de criação do alarme - " +  o_xml:_RESPONSES:_INFO:_MESSAGE:TEXT
            lRet := .F.
            // Return cRet
        elseif XmlChildEx(o_xml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY, "_E2_GETALARMLISTRESPONSE") == NIL
            conout("Erro no terceiro node")
            // cInfo += "Erro no node _RESPONSE de criação do alarme - " +  o_xml:_RESPONSES:_INFO:_MESSAGE:TEXT
            lRet := .F.
            // Return cRet
        elseif XmlChildEx(o_xml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_E2_GETALARMLISTRESPONSE, "_E2_DATA") == NIL
            conout("Erro no quarto node")
            // cInfo += "Erro no node _RESPONSE de criação do alarme - " +  o_xml:_RESPONSES:_INFO:_MESSAGE:TEXT
            lRet := .F.
            // Return cRet
        endif

        if lRet
            If XmlChildEx(o_xml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_E2_GETALARMLISTRESPONSE, "_E2_DATA") <> Nil
                // conout("Qtd de itens do XML")
                // conout(Len( o_xml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_E2_GETALARMLISTRESPONSE:_E2_DATA ))

                // conout("Dados do Alarme")
                // conout(o_Xml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_E2_GETALARMLISTRESPONSE:_E2_DATA[1]:_E2_ADVID:TEXT)
                // conout(subStr(alltrim(o_Xml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_E2_GETALARMLISTRESPONSE:_E2_DATA[1]:_E2_TIMESTAMP:TEXT), 1, 8))
                // conout(stod(subStr(alltrim(o_Xml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_E2_GETALARMLISTRESPONSE:_E2_DATA[1]:_E2_TIMESTAMP:TEXT), 1, 8)))
                // conout(subStr(alltrim(o_Xml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_E2_GETALARMLISTRESPONSE:_E2_DATA[1]:_E2_TIMESTAMP:TEXT), 10, 5))
                // conout("tratamento de ano")
                // conout(subStr(alltrim(o_Xml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_E2_GETALARMLISTRESPONSE:_E2_DATA[1]:_E2_TIMESTAMP:TEXT), 7, 2))
                // conout(padl(subStr(alltrim(o_Xml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_E2_GETALARMLISTRESPONSE:_E2_DATA[1]:_E2_TIMESTAMP:TEXT), 7, 2), 4, "20"))
                // conout("20"+subStr(alltrim(o_Xml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_E2_GETALARMLISTRESPONSE:_E2_DATA[1]:_E2_TIMESTAMP:TEXT), 7, 2) +;
                //         subStr(alltrim(o_Xml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_E2_GETALARMLISTRESPONSE:_E2_DATA[1]:_E2_TIMESTAMP:TEXT), 4, 2) +;
                //         subStr(alltrim(o_Xml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_E2_GETALARMLISTRESPONSE:_E2_DATA[1]:_E2_TIMESTAMP:TEXT), 1, 2))
                // conout(stod("20"+subStr(alltrim(o_Xml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_E2_GETALARMLISTRESPONSE:_E2_DATA[1]:_E2_TIMESTAMP:TEXT), 7, 2) +;
                //         subStr(alltrim(o_Xml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_E2_GETALARMLISTRESPONSE:_E2_DATA[1]:_E2_TIMESTAMP:TEXT), 4, 2) +;
                //         subStr(alltrim(o_Xml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_E2_GETALARMLISTRESPONSE:_E2_DATA[1]:_E2_TIMESTAMP:TEXT), 1, 2)))
                for n_Item := 1 to len(o_xml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_E2_GETALARMLISTRESPONSE:_E2_DATA)

                    dbSelectArea("ZA1")
                    dbSetOrder(3)

                    // conout("ID Alarme: ", o_xml:_RESPONSES:_RESPONSE:_ALARM[n_Item]:_IDALARM:TEXT)
                    //Verifico se o alarme já foi gravado na base
                    if !(dbSeek(xFilial("ZA1")+ZA2->ZA2_CODIGO+o_Xml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_E2_GETALARMLISTRESPONSE:_E2_DATA[n_Item]:_E2_ADVID:TEXT))

                        conout("Criando alarme")

                        // Retorno a estrutura dos campos que serão gravados na ZA1 x tags
                        aStruct := u_WSStruct(ZA2->ZA2_ROTINA)

                        ZA1->(recLock("ZA1", .T.))
                        ZA1->ZA1_CONTRO		:= ZA2->ZA2_CODIGO
                        for nX := 1 To Len(aStruct)
                            if !(Type(aStruct[nX][2]) == "U")
                                &("ZA1->" + aStruct[nX][1]) := &(aStruct[nX][2])
                            endif
                        next
                        ZA1->(msUnlock())
                    elseif upper(alltrim(o_Xml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_E2_GETALARMLISTRESPONSE:_E2_DATA[n_Item]:_E2_RTN:TEXT)) == "TRUE"
                        conout("Encerrando alarme")
                        // Retorno a estrutura dos campos que serão gravados na ZA1 x tags
                        aStruct := u_WSStruct(ZA2->ZA2_ROTINA)
                        ZA1->(recLock("ZA1", .F.))
                        for nX := 1 To Len(aStruct)
                            if !(type(aStruct[nX][2]) == "U")
                                &("ZA1->" + aStruct[nX][1]) := &(aStruct[nX][2])
                            endif
                        next
                        ZA1->(msUnlock())
                    endif
                    
                    cInfo := "Comunicação válida"
                    // cRet := o_xml:_RESPONSES:_RESPONSE:_ALARM[n_Item]:_IDALARM:TEXT

                Next n_Item

            EndIf
        endif

    Else

        If ValType(s_PostRet) == "U"
            conout( "Falha de comunicação com a controladora. Erro no método HttpPost de criação do alarme" )
            cInfo += "Falha de comunicação com a controladora. Erro no método HttpPost de criação do alarme"
        else
            conout( "Erro desconhecido" )
            cInfo += "Erro desconhecido"
        EndIf

    EndIf

    // u_GravaLog( "PROTHEUS", "CPCEMERSON", ZA2->ZA2_CLIENT, ZA2->ZA2_LOJA ,c_Url, c_Req, c_Json, ZA2->ZA2_CODIGO, iif(lRet, "S", "N"), cInfo )	
    u_GravaLog( "PROTHEUS", "CPCEMERSON", ZA2->ZA2_CLIENT, ZA2->ZA2_LOJA ,c_Url, c_XML, "", ZA2->ZA2_CODIGO, iif(lRet, "S", "N"), cInfo )	
    
    // conout("FIM EMERSON")

Return Nil 


/*
|---------------------------------------------------------------------------|
| Programa  | fVerAlarm| Autor | Felipe Aguiar            | Data | 06/01/20 |
|-----------+---------------------------------------------------------------|
| Descrição | Verifica se o alarme que esta vindo no WS ja foi gravado na   |
|           | base.                                             	        |
|-----------+---------------------------------------------------------------|
| Uso       | Perfil  Refrigeração                                          |
|---------------------------------------------------------------------------|
*/
Static Function fVerAlarm(c_IdAl, c_Eq)

Local l_OK  := .F.
Local c_Qry := ""

c_Qry := " SELECT	* "
c_Qry += " FROM	"+RetSqlName("ZA1")+ "(NOLOCK)"
c_Qry += " WHERE	ZA1_IDEQUI = '"+c_Eq+"'"
c_Qry += " AND		ZA1_CODALA = '"+c_IdAl+ "'"
c_Qry += " AND		D_E_L_E_T_ = ''"

If Select("QRY") > 0
    QRY->(DbCloseArea())
Endif

c_Tem := "SELECT COUNT(*) AS QTD FROM ( "+c_Qry+") AS CONTADOR"

If Select("CONTA") > 0
    CONTA->(DbCloseArea())
Endif

TCQUERY c_Tem NEW ALIAS "CONTA"

n_Amarr := CONTA->QTD

If n_Amarr > 0 
    l_OK := .T.
EndIF

Return l_OK



/*
|---------------------------------------------------------------------------|
| Programa  | fFinAlarm| Autor | Felipe Aguiar            | Data | 06/01/20 |
|-----------+---------------------------------------------------------------|
| Descrição | Verifica se existem alarmes na base que não constam mais no   |
|           | retorno do WS, neste caso , significa que os mesmos ja        |
|           | foram finalizados                                  	        |
|-----------+---------------------------------------------------------------|
| Uso       | Perfil  Refrigeração                                          |
|---------------------------------------------------------------------------|
*/
Static Function fFinAlarm(a_Alar)

Local c_Query   := ""
Local n_Scan    := 0
Local a_AreaZA1 := ZA1->(GetArea())
Local aStruct   := {}
Local nX        := 0

// conout("INICIO fFinAlarm")

c_Query   := " SELECT	* " 
c_Query   += " FROM	"+RetSqlName("ZA1")+ "(NOLOCK)"
c_Query   += " WHERE	ZA1_DTFIM = ''"
c_Query   += " AND		ZA1_FABRIC = 'EMERSON'
c_Query   += " AND		D_E_L_E_T_ = '' "

If Select("QRY") > 0
    QRY->(DbCloseArea())
Endif

TCQUERY c_Query NEW ALIAS "QRY"

DbSelectArea("QRY")
QRY->(DbGotop())

While QRY->(!EOF())

    n_Scan := ASCAN( a_Alar , ALLTRIM(QRY->ZA1_CODALA)  )

    If n_Scan == 0
        // conout("EMERSON - Encerrando alarme")
        // Retorno a estrutura dos campos que serão gravados na ZA1 x tags
        aStruct := u_WSStruct(ZA2->ZA2_ROTINA)

        DbSelectArea("ZA1")
        ZA1->(DbGoTo(QRY->R_E_C_N_O_))
        
       /*  RecLock("ZA1",.F.)
        ZA1->ZA1_DTFIM  := Date()
        ZA1->ZA1_HRFIM  := Left(Time(), 5)
        ZA1->(MsUnlock()) */
        ZA1->(RecLock("ZA1", .F.))

        For nX := 1 To Len(aStruct)
            If aStruct[nX][1] $ cCpoFim
                &("ZA1->" + aStruct[nX][1]) := &(aStruct[nX][2])
            EndIf
        Next

        ZA1->(MsUnlock())

    EndIf 

    QRY->(DbSkip())

EndDo

RestArea(a_AreaZA1)

// conout("FIM fFinAlarm")

Return Nil
