/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � DDGAT001 �Autor � Gabriel Verissimo   � Data �  21/08/20   ���
�������������������������������������������������������������������������͹��
���Desc.     � Gatilho para preencher c�digo do produto e ID unico do     ���
���Desc.     � item do or�amento                                          ���
�������������������������������������������������������������������������͹��
���Uso       � Perfil                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function DDGAT001()

    Local aArea     := GetArea()
    Local aAreaAA3  := AA3->(GetArea())
    Local cRet      := ""
    Local cProdDef  := GetNewPar("DD_PRDDEF", "000000") //"999999"
    Local nPosProd  := aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "AB4_CODPRO"}) 
    Local nPosID    := aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "AB4_NUMSER"})  

    cRet := M->AB3_LOJA

    AA3->(dbSetOrder(1)) // AA3_FILIAL+AA3_CODCLI+AA3_LOJA+AA3_CODPRO+AA3_NUMSER+AA3_FILORI
    if AA3->(dbSeek(xFilial("AA3") + M->AB3_CODCLI + M->AB3_LOJA + cProdDef))
        for nI := 1 to len(aCols)
            aCols[nI][nPosProd] := AA3->AA3_CODPRO
            aCols[nI][nPosID]   := AA3->AA3_NUMSER
        next
    else
        Help(NIL, NIL, "DDGAT001", NIL, "Produto default n�o cadastrado para cliente selecionado", 1, 0, NIL,;
             NIL, NIL, NIL, NIL, {"Realize a inclus�o do produto default ou selecionar um produto j� cadastrado para o cliente"})
    endif

    GetDRefresh()

    RestArea(aAreaAA3)
    RestArea(aArea)

Return cRet
