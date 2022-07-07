User Function AT450TOK ()

    Local lRet      := .T.
    Local lPrev     := .F.
    Local lInteg    := .F.
    Local lHasId    := .F.
    Local nPosId    := aScan( aHeader, {|x| Alltrim( Upper( x[2] ) ) == "AB7_XMAXID"} )

    // Percorrer AB7 e verificar se a Ordem de Serviço já foi integrada com o MaxView
    // Qunado a OS for preventiva, caso não tenha sido integrada, permite alteração de todos os campos. Caso tenha sido integrada, permite somente a alteração do técnico

    // ** Preciso saber se cada um dos campos foi alterado? Se sim, pensar em forma prática de fazer isso. Se não, somente exibe mensagem 'alteração não é permitida'
    if Altera
        // Verifico tipo da ordem de serviço
        if AB6->AB6_XCLAOS == "2"
            lPrev := .T.
        endif

        // Verifico se a ordem de serviço já foi integrada com o MaxView
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

        // Quando a OS for corretiva, caso não tenha sido integrada, permite alteração de todos os campos. 
        // Caso já tenha sido integrada, não permite alteração de nenhum campo.
        if !lPrev .And. lHasId
            Help(NIL, NIL, "AT450TOK", NIL, "Alteração não permitida", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Não é permitido alterar uma ordem de serviço corretiva após ter sido integrada com o MaxView"})
            lRet := .F.
        endif

        if lRet .And. lPrev
            // Quando for alteração e o campo 'técnico' estiver em branco, deve inativar a tarefa já criada no MaxView e depois apagar o conteúdo do campo 'AB7_XMAXID'
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