#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"  

User Function JOBWS() 

	//Preparar o Ambiente
	RpcSetType( 3 )
	RpcSetEnv( "02", "0101" )                  

	conout("-----------------------------------------------------------------")
	conout("- WS CONTROLADORAS - INICIO : " +Time())
	conout("-----------------------------------------------------------------")
	
    U_WSCONTRO(.T.)
	
	conout("-----------------------------------------------------------------")
	conout("- WS CONTROLADORAS - FIM : " +Time())
	conout("-----------------------------------------------------------------")
	
	RpcClearEnv()
	
Return Nil 

/*------------------------------------------------------------------------
{Protheus.doc} WSCONTRO

@Author  	   Felipe Aguiar - Delta Decisao
@since		   12/2019
@version	   P12

@description API para consultar as Controladoras 
--------------------------------------------------------------------------
|Author                  | Date       | Description                       |
|                        |            |                                   |
-------------------------------------------------------------------------*/

User Function WSCONTRO(_lJob)

	Default _lJob		:= .F.
	Private lJob		:= _lJob

	If !(lJob)
		MsgRun( "Processando controladoras. Por favor aguarde...", "WebService - Controladoras", {|| fProces()} )
	Else
		fProces()
	EndIf	

Return Nil


/*------------------------------------------------------------------------
{Protheus.doc} GravaLog

@Author  	   Felipe Aguiar - Delta Decisao
@since		   12/2019
@version	   P12

@description Grava log de requisições do WebService
--------------------------------------------------------------------------
|Author                  | Date       | Description                       |
|                        |            |                                   |
-------------------------------------------------------------------------*/
User Function GravaLog( c_Orig, c_Forn, c_Client, c_Loja, c_Dest, c_Req, c_Ret, c_Contro, c_Ok, c_Info  )

Default c_Orig	 := ""
Default c_Dest   := ""
Default c_Forn	 := "" 
Default c_Client := ""
Default c_Loja	 := ""
Default c_Req	 := "" 
Default c_Ret	 := ""


If !(Empty(c_Req))

	ZA3->(RecLock("ZA3",.T.))
	ZA3->ZA3_FILIAL			:= xFilial("ZA3")
	ZA3->ZA3_ORIGEM			:= c_Orig
	ZA3->ZA3_DESTIN			:= c_Dest
	ZA3->ZA3_FORNEC			:= c_Forn
	ZA3->ZA3_CLIENT			:= c_Client
	ZA3->ZA3_LOJA			:= c_Loja
	ZA3->ZA3_DATA			:= Date()
	ZA3->ZA3_HORA			:= Left(Time(), 5)
	ZA3->ZA3_REQ			:= c_Req	
	ZA3->ZA3_RETORN			:= c_Ret
	ZA3->ZA3_CONTRO			:= c_Contro
	ZA3->ZA3_COMOK			:= c_Ok
	ZA3->ZA3_INFO			:= c_Info
	ZA3->(MsUnlock())		

EndIf

Return Nil

/*
|---------------------------------------------------------------------------|
| Programa  | fProces  | Autor | Felipe Aguiar            | Data | 06/01/20 |
|-----------+---------------------------------------------------------------|
| Descrição | Verifica se o alarme que esta vindo no WS ja foi gravado na   |
|           | base.                                             	        |
|-----------+---------------------------------------------------------------|
| Uso       | Perfil  Refrigeração                                          |
|---------------------------------------------------------------------------|
*/
Static Function fProces()

	Local c_Rotina 		:= ""
	Local c_Exec		:= ""

	DbSelectArea("ZA2")
	ZA2->(DbGoTop())
	
	While ZA2->(!EoF())
		
		c_Rotina := AllTrim(ZA2->ZA2_ROTINA)

		If	!(c_Rotina == "")
			
			//Verifica se a controladora está bloqueada para processamento
			If ZA2->ZA2_MSBLQL <> "1"
				conout("Processando " + c_Rotina)
				c_Exec := "U_WS" + c_Rotina + "()"
				&(c_Exec)

				If ZA2->ZA2_CONENE == "S"
					conout("Processando " + c_Rotina)
					c_Exec := "U_WSCE" + c_Rotina + "()"
					&(c_Exec)
				EndIf		
			EndIf		

		EndIf

		ZA2->(DbSkip())
		
	EndDo

Return Nil

/*
|---------------------------------------------------------------------------|
| Programa  | WSStruct | Autor | Gabriel Veríssimo        | Data | 30/01/20 |
|-----------+---------------------------------------------------------------|
| Descrição | Retorna estrutura de campos x valores que deverão ser         |
|           | graavdos                                             	        |
|-----------+---------------------------------------------------------------|
| Uso       | Perfil  Refrigeração                                          |
|---------------------------------------------------------------------------|
*/

User Function WSStruct(cRotina)

    Local aRet 		:= {}
	Default cRotina := ""

    If AllTrim(cRotina) == "DANFOS"
        AADD( aRet, {"ZA1_FILIAL"   , "xFilial('ZA1')"} )
        AADD( aRet, {"ZA1_DTINIC"   , "CtoD(oItemDet:_OCCURDATE:TEXT)"} )
        AADD( aRet, {"ZA1_HRINIC"   , "oItemDet:_OCCURTIME:TEXT"} )
        AADD( aRet, {"ZA1_DTFIM"    , "CtoD(oItemDet:_ACKDATE:TEXT)"} )
        AADD( aRet, {"ZA1_HRFIM"    , "oItemDet:_ACKTIME:TEXT"} )
        AADD( aRet, {"ZA1_DTEXEC"   , "Date()"} )
        AADD( aRet, {"ZA1_HREXEC"   , "Left(Time(), 5)"} )
        AADD( aRet, {"ZA1_IDEQUI"   , "AllTrim(oItemDet:_ADDR:TEXT)"} )
        AADD( aRet, {"ZA1_DESCRI"   , "oItemDet:_DEVICENAME:TEXT"} )
        AADD( aRet, {"ZA1_CODALA"   , "oItemDet:_REF:TEXT"} )
        AADD( aRet, {"ZA1_DESCAL"   , "oItemDet:_NAME:TEXT"} )
        AADD( aRet, {"ZA1_CLIENT"   , "ZA2->ZA2_CLIENT"} )
        AADD( aRet, {"ZA1_LOJA"     , "ZA2->ZA2_LOJA"} )
        AADD( aRet, {"ZA1_FABRIC"   , "SubStr(x3FieldToCbox('ZA2_FABRIC',ZA2->ZA2_FABRIC),5,Len(x3FieldToCbox('ZA2_FABRIC',ZA2->ZA2_FABRIC)) )"} )
        AADD( aRet, {"ZA1_CONTRO"   , "ZA2->ZA2_CODIGO"} )
	ElseIf AllTrim(cRotina) == "CAREL"
		AADD( aRet, {"ZA1_FILIAL"   , "xFilial('ZA1')"} )
        AADD( aRet, {"ZA1_DTINIC"   , "STOD(STRTRAN(SUBSTR( o_xml:_RESPONSES:_RESPONSE:_ALARM[n_Item]:_STARTTIME:TEXT, 1 , 10 ),'-', ''  ))"} )
        AADD( aRet, {"ZA1_HRINIC"   , "SUBSTR( o_xml:_RESPONSES:_RESPONSE:_ALARM[n_Item]:_STARTTIME:TEXT, 12 , 5 )"} )
        AADD( aRet, {"ZA1_DTFIM"    , "STOD(STRTRAN(SUBSTR( o_xml:_RESPONSES:_RESPONSE:_ALARM[n_Item]:_ENDTIME:TEXT, 1 , 10 ),'-', ''  ))"} )
        AADD( aRet, {"ZA1_HRFIM"    , "SUBSTR( o_xml:_RESPONSES:_RESPONSE:_ALARM[n_Item]:_ENDTIME:TEXT, 12 , 5 )"} )
        AADD( aRet, {"ZA1_DTEXEC"   , "Date()"} )
        AADD( aRet, {"ZA1_HREXEC"   , "Left(Time(), 5)"} )
        AADD( aRet, {"ZA1_IDEQUI"   , "o_xml:_RESPONSES:_RESPONSE:_ALARM[n_Item]:_IDDEVICE:TEXT"} )
        AADD( aRet, {"ZA1_DESCRI"   , "o_xml:_RESPONSES:_RESPONSE:_ALARM[n_Item]:_DEVICEDESCRIPTION:TEXT"} )
        AADD( aRet, {"ZA1_CODALA"   , "o_xml:_RESPONSES:_RESPONSE:_ALARM[n_Item]:_IDALARM:TEXT"} )
        AADD( aRet, {"ZA1_DESCAL"   , "o_xml:_RESPONSES:_RESPONSE:_ALARM[n_Item]:_NAME:TEXT"} )
        AADD( aRet, {"ZA1_CLIENT"   , "ZA2->ZA2_CLIENT"} )
        AADD( aRet, {"ZA1_LOJA"     , "ZA2->ZA2_LOJA"} )
        AADD( aRet, {"ZA1_FABRIC"   , "SubStr(x3FieldToCbox('ZA2_FABRIC',ZA2->ZA2_FABRIC),5,Len(x3FieldToCbox('ZA2_FABRIC',ZA2->ZA2_FABRIC)) )"} )
        AADD( aRet, {"ZA1_CONTRO"   , "ZA2->ZA2_CODIGO"} )
	ElseIf AllTrim(cRotina) == "EMER"
		AADD( aRet, {"ZA1_FILIAL"   , "xFilial('ZA1')"} )
        AADD( aRet, {"ZA1_DTINIC"   , "Date()"} )
        AADD( aRet, {"ZA1_HRINIC"   , "Left(Time(), 5)"} )
        AADD( aRet, {"ZA1_DTFIM"    , "Date()"} )
        AADD( aRet, {"ZA1_HRFIM"    , "Left(Time(), 5)"} )
        AADD( aRet, {"ZA1_DTEXEC"   , "Date()"} )
        AADD( aRet, {"ZA1_HREXEC"   , "Left(Time(), 5)"} )
        AADD( aRet, {"ZA1_IDEQUI"   , "AllTrim(c_Device)"} )
        AADD( aRet, {"ZA1_DESCRI"   , "AllTrim(c_NomeDev)"} )
        AADD( aRet, {"ZA1_CODALA"   , "AllTrim(c_Id)"} )
        AADD( aRet, {"ZA1_DESCAL"   , "AllTrim(c_Alarm)"} )
        AADD( aRet, {"ZA1_CLIENT"   , "ZA2->ZA2_CLIENT"} )
        AADD( aRet, {"ZA1_LOJA"     , "ZA2->ZA2_LOJA"} )
        AADD( aRet, {"ZA1_FABRIC"   , "SubStr(x3FieldToCbox('ZA2_FABRIC',ZA2->ZA2_FABRIC),5,Len(x3FieldToCbox('ZA2_FABRIC',ZA2->ZA2_FABRIC)) )"} )
        AADD( aRet, {"ZA1_CONTRO"   , "ZA2->ZA2_CODIGO"} )
	ElseIf AllTrim(cRotina) == "CECAREL"
		AADD( aRet, {"ZA4_FILIAL"       , "xFilial('ZA4')"} )
        AADD( aRet, {"ZA4_CONTRO"   , "ZA2->ZA2_CODIGO"} )
        AADD( aRet, {"ZA4_IDDEV"    , "o_xml:_RESPONSES:_RESPONSE:_DEVICE[n_Item]:_IDDEVICE:TEXT"} )
        AADD( aRet, {"ZA4_DESDEV"   , "o_xml:_RESPONSES:_RESPONSE:_DEVICE[n_Item]:_DEVDESCR:TEXT"} )
        AADD( aRet, {"ZA4_ADRESS"   , "o_xml:_RESPONSES:_RESPONSE:_DEVICE[n_Item]:_DEVADDR:TEXT"} )
	ElseIf AllTrim(cRotina) == "CPCEMER"
		AADD( aRet, {"ZA1_FILIAL"   , "xFilial('ZA1')"} )
        // AADD( aRet, {"ZA1_DTINIC"   , "stod(subStr(alltrim(o_Xml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_E2_GETALARMLISTRESPONSE:_E2_DATA[n_Item]:_E2_TIMESTAMP:TEXT), 1, 8))"} )
        AADD( aRet, {"ZA1_DTINIC"   , "stod('20'+subStr(alltrim(o_Xml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_E2_GETALARMLISTRESPONSE:_E2_DATA[n_Item]:_E2_TIMESTAMP:TEXT), 7, 2)+" +;
                                      "subStr(alltrim(o_Xml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_E2_GETALARMLISTRESPONSE:_E2_DATA[n_Item]:_E2_TIMESTAMP:TEXT), 4, 2)+" +;
                                      "subStr(alltrim(o_Xml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_E2_GETALARMLISTRESPONSE:_E2_DATA[n_Item]:_E2_TIMESTAMP:TEXT), 1, 2))"} )
        AADD( aRet, {"ZA1_HRINIC"   , "subStr(alltrim(o_Xml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_E2_GETALARMLISTRESPONSE:_E2_DATA[n_Item]:_E2_TIMESTAMP:TEXT), 10, 5)"} )
        // AADD( aRet, {"ZA1_DTFIM"    , "stod(subStr(alltrim(o_Xml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_E2_GETALARMLISTRESPONSE:_E2_DATA[n_Item]:_E2_RTNTIMESTAMP:TEXT), 1, 8))"} )
        AADD( aRet, {"ZA1_DTFIM"   , "stod('20'+subStr(alltrim(o_Xml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_E2_GETALARMLISTRESPONSE:_E2_DATA[n_Item]:_E2_RTNTIMESTAMP:TEXT), 7, 2)+" +;
                                      "subStr(alltrim(o_Xml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_E2_GETALARMLISTRESPONSE:_E2_DATA[n_Item]:_E2_RTNTIMESTAMP:TEXT), 4, 2)+" +;
                                      "subStr(alltrim(o_Xml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_E2_GETALARMLISTRESPONSE:_E2_DATA[n_Item]:_E2_RTNTIMESTAMP:TEXT), 1, 2))"} )
        AADD( aRet, {"ZA1_HRFIM"    , "subStr(alltrim(o_Xml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_E2_GETALARMLISTRESPONSE:_E2_DATA[n_Item]:_E2_RTNTIMESTAMP:TEXT), 10, 5)"} )
        AADD( aRet, {"ZA1_DTEXEC"   , "Date()"} )
        AADD( aRet, {"ZA1_HREXEC"   , "Left(Time(), 5)"} )
        AADD( aRet, {"ZA1_IDEQUI"   , ""} )
        AADD( aRet, {"ZA1_DESCRI"   , "o_Xml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_E2_GETALARMLISTRESPONSE:_E2_DATA[n_Item]:_E2_SOURCE:TEXT"} )
        AADD( aRet, {"ZA1_CODALA"   , "o_Xml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_E2_GETALARMLISTRESPONSE:_E2_DATA[n_Item]:_E2_ADVID:TEXT"} )
        AADD( aRet, {"ZA1_DESCAL"   , "o_Xml:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_E2_GETALARMLISTRESPONSE:_E2_DATA[n_Item]:_E2_TEXT:TEXT"} )
        AADD( aRet, {"ZA1_CLIENT"   , "ZA2->ZA2_CLIENT"} )
        AADD( aRet, {"ZA1_LOJA"     , "ZA2->ZA2_LOJA"} )
        AADD( aRet, {"ZA1_FABRIC"   , "SubStr(x3FieldToCbox('ZA2_FABRIC',ZA2->ZA2_FABRIC),5,Len(x3FieldToCbox('ZA2_FABRIC',ZA2->ZA2_FABRIC)) )"} )
        AADD( aRet, {"ZA1_CONTRO"   , "ZA2->ZA2_CODIGO"} )
  EndIf

Return aRet
