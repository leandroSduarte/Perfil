#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#include "tbiconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ DDMAXWS1 ณ Autor ณ Anderson Messias      ณ Data ณ 02/05/19 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Webservice de integracao MAXVIEW Mobile                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Anhembi                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DDMAXWS1()
Return(Nil)
             
WSService DDMAXWS1 Description "WEBSERVICE de integracao do MAXVIEW Mobile"
	
	WsData nRecno			AS Integer
	
	//Get Os Cliente
	WsData PrmGetOsCliente	As StrucOSCliente
	WsData RetGetOsCliente	As StrucRetorno
	
	//Get Os
	WsData PrmGetDadosOs	As StrucOSDados
	WsData RetGetDadosOs	As StrucRetorno

	WsMethod GetOSCliente	Description "Busca Ordem de Servico do Cliente"
	WsMethod GetDadosOS	Description "Busca Dados da Ordem de Servico"
	WsMethod SetOSTecnico	Description "Atualiza o tecnico da Ordem de Servico"
	
	
ENDWSService

WSSTRUCT StrucRetorno
	WsData lRet			As Boolean Optional
	WsData Mensagem		As String Optional
	WsData Conteudo		As String Optional
ENDWSSTRUCT

WSSTRUCT StrucOSCliente
	WsData cCliente		As String Optional
	WsData cLoja		As String Optional
	WsData cTecnico		As String Optional
ENDWSSTRUCT

WSSTRUCT StrucOSDados
	WsData cOS			As String Optional
	WsData cTecnico		As String Optional
ENDWSSTRUCT

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ GetOSClienteบAutor  ณAnderson Messias  บ Data ณ  23/03/20  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina que Busca as OS do Cliente                          บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PERFIL                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
WSMETHOD GetOSCliente WSRECEIVE PrmGetOsCliente WSSEND RetGetOsCliente WSSERVICE DDMAXWS1

local cQuery		:= ""
local cCliente		:= iif(ValType(::PrmGetOsCliente:cCliente)!="U",::PrmGetOsCliente:cCliente,"******")
local cLoja			:= iif(ValType(::PrmGetOsCliente:cLoja)!="U",::PrmGetOsCliente:cLoja,"****")
local cTecnico		:= iif(ValType(::PrmGetOsCliente:cTecnico)!="U",::PrmGetOsCliente:cTecnico,"")
local cXML := ""

//Devido ao Maxview, estou tendo que tratar o codigo e a loja de forma diferente

Conout(time())
Conout("Antes")
Conout(cCliente)
Conout(cLoja)
nPosLoja := RAT("-",cLoja)
Conout(nPosLoja)
if nPosLoja > 0
	cLoja := Alltrim(Substr(cLoja,nPosLoja+1))
	Conout(cLoja)
	nPosLoja := RAT(cLoja,cCliente)
	Conout(nPosLoja)
	if nPosLoja > 0
		cCliente := Alltrim(Substring(cCliente,1,nPosLoja-1))
		Conout(cCliente)
	endif 
endif

Conout("Depois")
Conout(cCliente)
Conout(cLoja)
DBSelectArea("SA1")
DBSetOrder(1)
Conout(xFilial("SA1"),cCliente,cLoja,DBSeek(xFilial("SA1")+cCliente+cLoja))
if !DBSeek(xFilial("SA1")+Padr(cCliente,6)+Padr(cLoja,4))

    cXML += "<h2>Cliente Nao Localizado</h2>"
    cXML += "<div class='container-fluid'>"
    cXML += "<div class='table-responsive'>"
    cXML += "  <table class='table table-bordered table-hover'>"
    cXML += "    <thead class='thead-dark'>"
    cXML += "      <tr>"
    cXML += "         <th>Ordem Servico</th>"
    cXML += "         <th>Equipamento</th>"
    cXML += "      </tr>"
    cXML += "    </thead>"
    cXML += "    <tbody>"
    cXML += "        <tr>"
    cXML += "           <td></td>"
    cXML += "           <td>Nenhuma O.S. Disponivel</td>"
    cXML += "        </tr>"
    cXML += "    </tbody>"
    cXML += "  </table>"
    cXML += " </div>"
    cXML += " </div>"

	::RetGetOsCliente:lRet := .F.
	::RetGetOsCliente:Mensagem := "Cliente informado nao localizado!"
	::RetGetOsCliente:Conteudo := cXML
	Return .T.
endif

// cQuery := "SELECT TOP 20 "+CRLF
cQuery := "SELECT "+CRLF
cQuery += "  AB6_NUMOS, "+CRLF
cQuery += "  AB7_NUMSER, "+CRLF
cQuery += "  B1_DESC as AB7_XDESPO, "+CRLF
cQuery += "  AB6.R_E_C_N_O_ as AB6_RECNO "+CRLF
cQuery += "FROM "+RetSQLName("AB6")+" AB6 "+CRLF
cQuery += "  LEFT JOIN "+RetSQLName("AB7")+" AB7 ON AB7_FILIAL=AB6_FILIAL AND AB7_NUMOS=AB6_NUMOS AND AB7.D_E_L_E_T_='' "+CRLF
cQuery += "  LEFT JOIN "+RetSQLName("SB1")+" SB1 ON B1_COD=AB7_CODPRO AND SB1.D_E_L_E_T_='' "+CRLF
cQuery += "WHERE AB6.D_E_L_E_T_='' "+CRLF
cQuery += "  AND AB6_XCLAOS='2' "+CRLF
cQuery += "  AND AB6_CODCLI='"+cCliente+"' "+CRLF
cQuery += "  AND AB6_LOJA='"+cLoja+"' "+CRLF
cQuery += "  AND AB6_XIDTEC='' "+CRLF
cQuery += "ORDER BY "+CRLF
cQuery += "  AB6_NUMOS "+CRLF

If Select("TSQL") > 0
	dbSelectArea("TSQL")
	DbCloseArea()
EndIf                   
Conout(cQuery)                   
TCQUERY cQuery NEW ALIAS "TSQL"
DBSelectArea("TSQL")

if !TSQL->(Eof()) .AND. !TSQL->(Bof())
	
	/*
	cXML := '<?xml version="1.0" encoding="utf-8" ?>'+CRLF
	cXML += '<Dados>'+CRLF
	While !TSQL->(Eof())
		cXML += '  <Registros>'+CRLF
		cXML += '    <AB6_NUMOS>'+alltrim(TSQL->Z37_FILIAL)+alltrim(TSQL->Z37_OP)+'</AB6_NUMOS>'+CRLF
		cXML += '    <AB7_XDESPO>'+alltrim(TSQL->Z37_LINHA)+'</AB7_XDESPO>'+CRLF
		cXML += '    <R_E_C_N_O_>'+alltrim(Str(TSQL->AB6_RECNO))+'</R_E_C_N_O_>'+CRLF
		cXML += '  </Registros>'+CRLF
		TSQL->(DBSkip())
	EndDo
	cXML += '</Dados>'+CRLF
	*/

    cXML += "<h2>" + alltrim(SA1->A1_NOME) + "</h2>"
    cXML += "<div class='container-fluid'>"
    cXML += "<div class='table-responsive'>"
    cXML += "  <table class='table table-bordered table-hover'>"
    cXML += "    <thead class='thead-dark'>"
    cXML += "      <tr>"
    cXML += "         <th>Ordem Servico</th>"
    cXML += "         <th>Ativo</th>"
    cXML += "         <th>Equipamento</th>"
    cXML += "      </tr>"
    cXML += "    </thead>"
    cXML += "    <tbody>"
    While !TSQL->(Eof())
	    cXML += "        <tr>"
	    cXML += "           <td><a href='/SetOrdemServico.aspx?OS="+TSQL->AB6_NUMOS+"&Tecnico="+cTecnico+"&Token=Deltadecisao' class='btn btn-primary btn-lg'>"+TSQL->AB6_NUMOS+"</a></td>"
	    cXML += "           <td>"+alltrim(TSQL->AB7_NUMSER)+"</td>"
	    cXML += "           <td>"+alltrim(TSQL->AB7_XDESPO)+"</td>"
	    cXML += "        </tr>"
	    TSQL->(DBSkip())
	Enddo
    cXML += "    </tbody>"
    cXML += "  </table>"
    cXML += " </div>"
    cXML += " </div>"

	::RetGetOsCliente:lRet := .T.
	::RetGetOsCliente:Mensagem := "Consulta realizada com sucesso"
	::RetGetOsCliente:Conteudo := cXML
	conout(cXML)
else
	/*
	cXML := '<?xml version="1.0" encoding="utf-8" ?>'+CRLF
	cXML += '<Dados>'+CRLF
	cXML += '  <Registros>'+CRLF
		cXML += '    <AB6_NUMOS></AB6_NUMOS>'+CRLF
		cXML += '    <AB7_XDESPO>Nenhuma O.S. Disponivel</AB7_XDESPO>'+CRLF
		cXML += '    <R_E_C_N_O_></R_E_C_N_O_>'+CRLF
	cXML += '  </Registros>'+CRLF
	cXML += '</Dados>'+CRLF
	*/

    cXML += "<h2>" + alltrim(SA1->A1_NOME) + "</h2>"
    cXML += "<div class='container-fluid'>"
    cXML += "<div class='table-responsive'>"
    cXML += "  <table class='table table-bordered table-hover'>"
    cXML += "    <thead class='thead-dark'>"
    cXML += "      <tr>"
    cXML += "         <th>Ordem Servico</th>"
    cXML += "         <th>Equipamento</th>"
    cXML += "      </tr>"
    cXML += "    </thead>"
    cXML += "    <tbody>"
    cXML += "        <tr>"
    cXML += "           <td></td>"
    cXML += "           <td>Nenhuma O.S. Disponivel</td>"
    cXML += "        </tr>"
    cXML += "    </tbody>"
    cXML += "  </table>"
    cXML += " </div>"
    cXML += " </div>"

	::RetGetOsCliente:lRet := .T.
	::RetGetOsCliente:Mensagem := "Consulta sem retorno de registros"
	::RetGetOsCliente:Conteudo := cXML
endif

If Select("TSQL") > 0
	dbSelectArea("TSQL")
	DbCloseArea()
EndIf

return .T.


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ GetOS       บAutor  ณAnderson Messias  บ Data ณ  23/03/20  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina que Busca a OS                                      บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PERFIL                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
WSMETHOD GetDadosOS WSRECEIVE PrmGetDadosOs WSSEND RetGetDadosOs WSSERVICE DDMAXWS1

local cQuery		:= ""
local cOS		:= iif(ValType(::PrmGetDadosOs:cOS)!="U",::PrmGetDadosOs:cOS,"******")
local cTecnico		:= iif(ValType(::PrmGetDadosOs:cTecnico)!="U",::PrmGetDadosOs:cTecnico,"")
local cXML := ""
Local aXCateg := {"Refrigeracao","Ar Condicionado"}

//Devido ao Maxview, estou tendo que tratar o codigo e a loja de forma diferente

Conout(cOS)
Conout(cTecnico)
DBSelectArea("AB6")
DBSetOrder(1)
if !DBSeek(xFilial("AB6")+Padr(cOS,6))
    cXML += "<h2>O. S. nao localizada</h2>"

	::RetGetOs:lRet := .F.
	::RetGetOs:Mensagem := "O.S. informada nao localizado!"
	::RetGetOs:Conteudo := cXML
	Return .T.
endif

cQuery := "SELECT "+CRLF
cQuery += "  AB6_NUMOS, "+CRLF
cQuery += "  AB6_CODCLI, "+CRLF
cQuery += "  AB6_LOJA, "+CRLF
cQuery += "  B1_DESC as AB7_XDESPO, "+CRLF
cQuery += "  AB6_XCATEG, "+CRLF
cQuery += "  AB7_NUMSER, "+CRLF
cQuery += "  AB6.R_E_C_N_O_ as AB6_RECNO "+CRLF
cQuery += "FROM "+RetSQLName("AB6")+" AB6 "+CRLF
cQuery += "  LEFT JOIN "+RetSQLName("AB7")+" AB7 ON AB7_FILIAL=AB6_FILIAL AND AB7_NUMOS=AB6_NUMOS AND AB7.D_E_L_E_T_='' "+CRLF
cQuery += "  LEFT JOIN "+RetSQLName("SB1")+" SB1 ON B1_COD=AB7_CODPRO AND SB1.D_E_L_E_T_='' "+CRLF
cQuery += "WHERE AB6.D_E_L_E_T_='' "+CRLF
cQuery += "  AND AB6_NUMOS='"+cOS+"' "+CRLF
cQuery += "ORDER BY "+CRLF
cQuery += "  AB6_NUMOS "+CRLF

If Select("TSQL") > 0
	dbSelectArea("TSQL")
	DbCloseArea()
EndIf                   
Conout(cQuery)                   
TCQUERY cQuery NEW ALIAS "TSQL"
DBSelectArea("TSQL")

if !TSQL->(Eof()) .AND. !TSQL->(Bof())
	
	nCateg := val(TSQL->AB6_XCATEG)
	cCateg := ""
	if nCateg > 0
		cCateg := aXCateg[nCateg]
	endif
	
	DBSelectArea("SA1")
	DBSetOrder(1)
	DBSeek(xFilial("SA1")+TSQL->AB6_CODCLI+TSQL->AB6_LOJA)
	
    cXML += "<h2>" + Alltrim(SA1->A1_NOME) + "</h2>"
    cXML += "<p>"
    cXML += "  <b>Ordem de Servico:</b>&nbsp;" + TSQL->AB6_NUMOS + "<br>"
    cXML += "  <b>Ativo:</b>&nbsp;" + TSQL->AB7_NUMSER + "<br>"
    cXML += "  <b>Equipamento(s):</b>&nbsp;" + TSQL->AB7_XDESPO + "<br>"
    cXML += "  <b>Categoria</b>&nbsp;" + cCateg + "<br>"
    cXML += "</p>"

	::RetGetDadosOs:lRet := .T.
	::RetGetDadosOs:Mensagem := "Consulta realizada com sucesso"
	::RetGetDadosOs:Conteudo := cXML
	conout(cXML)
else

    cXML += "<h2>O.S. nao localizada!</h2>"

	::RetGetDadosOs:lRet := .T.
	::RetGetDadosOs:Mensagem := "Consulta sem retorno de registros"
	::RetGetDadosOs:Conteudo := cXML
endif

If Select("TSQL") > 0
	dbSelectArea("TSQL")
	DbCloseArea()
EndIf

return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ SetOSTecnicoบAutor  ณAnderson Messias  บ Data ณ  23/03/20  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina que Busca a OS                                      บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PERFIL                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
WSMETHOD SetOSTecnico WSRECEIVE PrmGetDadosOs WSSEND RetGetDadosOs WSSERVICE DDMAXWS1

local cQuery		:= ""
local cOS		:= iif(ValType(::PrmGetDadosOs:cOS)!="U",::PrmGetDadosOs:cOS,"******")
local cTecnico		:= iif(ValType(::PrmGetDadosOs:cTecnico)!="U",::PrmGetDadosOs:cTecnico,"")
local cXML := ""
Local aXCateg := {"Refrigeracao","Ar Condicionado"}

//Devido ao Maxview, estou tendo que tratar o codigo e a loja de forma diferente

Conout("SetOSTecnico")
Conout(cOS)
Conout(cTecnico)
DBSelectArea("AB6")
DBSetOrder(1)
if !DBSeek(xFilial("AB6")+Padr(cOS,6))
    cXML += "<h2>O. S. nao localizada</h2>"

	::RetGetDadosOs:lRet := .F.
	::RetGetDadosOs:Mensagem := "O.S. informado nao localizado!"
	::RetGetDadosOs:Conteudo := cXML
	Conout(::RetGetDadosOs:Conteudo)
	Return .T.
endif

cQuery := "SELECT "+CRLF
cQuery += "  AA1_CODTEC, "+CRLF
cQuery += "  AA1_NOMTEC, "+CRLF
cQuery += "  AA1.R_E_C_N_O_ as AA1_RECNO "+CRLF
cQuery += "FROM "+RetSQLName("AA1")+" AA1 "+CRLF
cQuery += "WHERE AA1.D_E_L_E_T_='' "+CRLF
cQuery += "  AND Upper(AA1_NREDUZ)='"+Upper(cTecnico)+"' "+CRLF
cQuery += "ORDER BY "+CRLF
cQuery += "  R_E_C_N_O_ "+CRLF
conout(cQuery)
If Select("TSQL") > 0
	dbSelectArea("TSQL")
	DbCloseArea()
EndIf                   

TCQUERY cQuery NEW ALIAS "TSQL"
DBSelectArea("TSQL")
if TSQL->(Eof()) .AND. TSQL->(Bof())
	If Select("TSQL") > 0
		dbSelectArea("TSQL")
		DbCloseArea()
	EndIf                   

    cXML += "<h2>Tecnico nao localizado</h2>"

	::RetGetDadosOs:lRet := .F.
	::RetGetDadosOs:Mensagem := "Tecnico informado nao localizado!"
	::RetGetDadosOs:Conteudo := cXML
	Conout(::RetGetDadosOs:Conteudo)
	Return .T.
else
	DBSelectArea("AB6")
	Reclock("AB6",.F.)
	AB6->AB6_XIDTEC := TSQL->AA1_CODTEC
	AB6->AB6_XCOLAB := TSQL->AA1_NOMTEC
	MsUnlock()
	U_DDMAXI8X(.F.)

    cXML += "<h2>" + Alltrim(TSQL->AA1_NOMTEC) + "</h2>"
    cXML += "<p>"
    cXML += "  <b>Ordem de Servico:</b>&nbsp;" + cOS + "<br>"
    cXML += "  <b>Atualizada com sucesso<br>"
    cXML += "  <b>Sincronize o Aplicativo para receber a O.S. para apontamento<br>"
    cXML += "</p>"

	::RetGetDadosOs:lRet := .T.
	::RetGetDadosOs:Mensagem := "Atualizacao realizada com sucesso"
	::RetGetDadosOs:Conteudo := cXML
	Conout(::RetGetDadosOs:Conteudo)

endif

If Select("TSQL") > 0
	dbSelectArea("TSQL")
	DbCloseArea()
EndIf

return .T.
	