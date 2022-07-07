#INCLUDE "Protheus.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TopConn.ch"
#INCLUDE "TBICONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ WFW120P  ºAutor  ³ Alexander Leite    º Data ³  12/05/21   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de envio de workflow de orçametno                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Perfil	                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PFGS002R(oProcess)

Local cAlias := GetNextAlias()
Local cNum 	  := oProcess:oHtml:RetByName('NUMORC')
Local cFilial := oProcess:oHtml:RetByName('FILIAL')

Local nItem  := 1
Local nX     := 1
Local nTotal := 0

Local aCab   := {}
Local aDados := {}



    AAdd(aCab,{cNum,;
    oProcess:oHtml:RetByName('EMISSAO'),;
    oProcess:oHtml:RetByName('CLIENTE'),;
    oProcess:oHtml:RetByName('LOJA'),;
    oProcess:oHtml:RetByName('CNPJ'),;
    oProcess:oHtml:RetByName('MOTIVO'),;
    oProcess:oHtml:RetByName('NOME'),;
    oProcess:oHtml:RetByName('TOTAL'),;
    oProcess:oHtml:RetByName('OS')})

    DbSelectArea("AB3")
	AB3->(DbSetOrder(1)) 
    AB3->(DbGoTop())
    If AB3->(DbSeek(xFilial("AB3") + cNum, .F.))
        RecLock("AB3",.F.)
        AB3->AB3__MOTRP := oProcess:oHtml:RetByName('MOTIVO')
	    AB3->AB3__STAWF := "2" // Retornado
        AB3->(MsUnlock())
    Endif
    
    DbSelectArea("AB5")
	AB5->(DbSetOrder(1)) //AB5_FILIAL+AB5_NUMORC+AB4_ITEM
    AB5->(DbGoTop())
	If AB5->(DbSeek(xFilial("AB5") + cNum, .F.))
		While !AB5->(EoF()) .And. AB5->AB5_FILIAL + AB5->AB5_NUMORC == cFilial + cNum
            /*RecLock("AB5",.F.)*/
            If Val(oProcess:oHtml:RetByName('it1.4')[nItem]) > 0
                nTotal += Val(oProcess:oHtml:RetByName('it1.6')[nItem]) * Val(oProcess:oHtml:RetByName('it1.4')[nItem])
                //AB5->AB5_QUANT := Val(oProcess:oHtml:RetByName('it1.4')[nItem])
                //AB5->AB5_MSBLQL := "2"// Aprovado - Não Bloqueado
            /*ElseIf Val(oProcess:oHtml:RetByName('it1.4')[nItem]) == 0
                //AB5->AB5_QUANT := Val(oProcess:oHtml:RetByName('it1.4')[nItem])
                //AB5->AB5_MSBLQL := "1" // Reprovado - Bloqueado*/
            Endif
            /*AB5->(MsUnlock())
			AB5->(DbSkip())*/
            AAdd(aDados,{oProcess:oHtml:RetByName('it1.2')[nItem],;
            oProcess:oHtml:RetByName('it1.3')[nItem],;
            oProcess:oHtml:RetByName('it1.5')[nItem],;
            oProcess:oHtml:RetByName('it1.4')[nItem],;
            oProcess:oHtml:RetByName('it1.6')[nItem]})
            AB5->(DbSkip())
            nItem++
		End	
	EndIf

    PFGS002RB(aCab,aDAdos,nTotal)

Return

/*/{Protheus.doc} PFGS002RB
    (long_description)
    @type  Static Function
    @author Alex Leite
    @since 08/06/2021
    @version version
    @param aCab, aDados
    @return return NIL
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function PFGS002RB(aCab,aDados,ntotal)

    Local oProcess
	Local oHtml

    Local nX   := 1

    oProcess := TWFProcess():New("WORKFLOW", "PFGS003")
    oProcess:NewTask("PFGSR002R",'\workflow\orcamento\HTML\PFGS004R2.htm')

    oHtml     := oProcess:oHtml
	oHtml:ValByName("Titulo", "Workflow de Orçamento Perfil (" + DTOC(Date()) + " - " + Time() + ")")

    oHtml:ValByName("MENSAGEM"	, "Orçamento - Perfil")
	oHtml:ValByName("FILIAL"	, xFilial("AB3"))
	oHtml:ValByName("NUMORC"	, aCab[1,1])
    oHtml:ValByName("EMISSAO"	, aCab[1,2])
	oHtml:ValByName("CLIENTE"	, aCab[1,3])
	oHtml:ValByName("LOJA"		, aCab[1,4])
    oHtml:ValByName("CNPJ"		, aCab[1,5])
    oHtml:ValByName("MOTIVO"    , aCab[1,6])
    oHtml:ValByName("NOME"      , aCab[1,7])
    oHtml:ValByName("TOTAL"     , cValToChar(nTotal))
    oHtml:ValByName("OS"        , aCab[1,9])
    DbSelectArea("SA1")
    SA1->(DbSetOrder(3))
    SA1->(DbGoTop())

    SA1->(DbSeek(xFilial("SA1") + aCab[1,5]))
    oHtml:ValByName("EMAIL"      , SA1->A1__EMLORC)


    For nX := 1 to Len(aDados)
        AAdd((oHtml:ValByName("it1.2")), aDados[nX,1])
		AAdd((oHtml:ValByName("it1.3")), aDados[nX,2])
		AAdd((oHtml:ValByName("it1.5")), aDados[nX,3])
		AAdd((oHtml:ValByName("it1.4")), aDados[nX,4])
        AAdd((oHtml:ValByName("it1.6")), aDados[nX,5])
    Next nX

    oProcess:cTo := SuperGetMv( "4" , .F. , "" ,  )
    oProcess:cSubject := "Retorno Aprovação Workflow do Orçamento N.: " + aCab[1,1] + " - PFGS002"
    oProcess:Start()
	
    
Return 
 