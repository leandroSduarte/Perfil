User Function AT450TOK ()

    Local lRet      := .T.
    Local lPrev     := .F.
    Local lInteg    := .F.
    Local lHasId    := .F.
    Local nPosId    := aScan( aHeader, {|x| Alltrim( Upper( x[2] ) ) == "AB7_XMAXID"} )

    // Percorrer AB7 e verificar se a Ordem de Servi�o j� foi integrada com o MaxView
    // Qunado a OS for preventiva, caso n�o tenha sido integrada, permite altera��o de todos os campos. Caso tenha sido integrada, permite somente a altera��o do t�cnico

    // ** Preciso saber se cada um dos campos foi alterado? Se sim, pensar em forma pr�tica de fazer isso. Se n�o, somente exibe mensagem 'altera��o n�o � permitida'
    if Altera
        // Verifico tipo da ordem de servi�o
        if AB6->AB6_XCLAOS == "2"
            lPrev := .T.
        endif

        // Verifico se a ordem de servi�o j� foi integrada com o MaxView
        AB7->(DbSetOrder(1)) //AB7_FILIAL+AB7_NUMOS+AB7_ITEM
        if AB7->(DbSeek(xFilial("AB7") + M->AB6_NUMOS))
            while !AB7->(EoF()) .And. AB7->AB7_FILIAL == xFilial("AB7") .And. AB7->AB7_NUMOS == M->AB6_NUMOS 
                if Len(AllTrim(AB7->AB7_XMAXID)) > 0
                    lHasId  := .T.
                    exit
                endif
                AB7->(DbSkip())
            end
        endif

        // Quando a OS for corretiva, caso n�o tenha sido integrada, permite altera��o de todos os campos. 
        // Caso j� tenha sido integrada, n�o permite altera��o de nenhum campo.
        if !lPrev .And. lHasId
            Help(NIL, NIL, "AT450TOK", NIL, "Altera��o n�o permitida", 1, 0, NIL, NIL, NIL, NIL, NIL, {"N�o � permitido alterar uma ordem de servi�o corretiva ap�s ter sido integrada com o MaxView"})
            lRet := .F.
        endif

        if lRet .And. lPrev
            // Quando for altera��o e o campo 't�cnico' estiver em branco, deve inativar a tarefa j� criada no MaxView e depois apagar o conte�do do campo 'AB7_XMAXID'
            if lHasId .And. Len(AllTrim(M->AB6_XIDTEC)) == 0
                lInteg := U_DDMAXI8X(.F., .T.)
                if lInteg
                    for nI := 1 to Len(aCols)
                        aCols[nI][nPosId] := ""
                    next nI
                endif
            endif
        endif
    endif
    
Return lRet