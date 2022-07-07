//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
 
 
/*/{Protheus.doc} PFTEC01
Função para cópia da movimentação dos planos
@author Alexander Leite
@since 14/04/2021
@version 1.0
    @return Nil, Função não tem retorno
    @example
    u_SZGMVG()
/*/
 
User Function PFTEC01(cNumOS)
    Local aAreaABE   := ABE->(GetArea())

    DbSelectArea("ABE")
    ABE->(DbSetOrder(5))
    ABE->(DbGoTop())
    DbSelectArea("SZZ")

    If ABE->(DbSeek(xFilial("ABE") + cNumOS))
        RecLock("SZZ",.T.)
        SZZ->ZZ_FILIAL := ABE->ABE_FILIAL
        SZZ->ZZ_CODFA  := ABE->ABE_CODFAB
        SZZ->ZZ_LOJFAB := ABE->ABE_LOJAFA
        SZZ->ZZ_CODPRO := ABE->ABE_CODPRO
        SZZ->ZZ_NUMSE  := ABE->ABE_NUMSER
        SZZ->ZZ_PLANO  := ABE->ABE_PLANO
        SZZ->ZZ_ITEM   := ABE->ABE_ITEM
        SZZ->ZZ_DATA   := ABE->ABE_DATA
        SZZ->ZZ_DTORIG := ABE->ABE_DTORIG
        SZZ->ZZ_SEQUE  := ABE->ABE_SEQUEN
        SZZ->ZZ_OK     := ABE->ABE_OK
        SZZ->ZZ_NUMOS  := ABE->ABE_NUMOS
        SZZ->(MsUnlock())
    Endif

    RecLock("ABE",.F.)
    ABE->(DbDelete())
    ABE->(MsUnlock())

    RestArea(aAreaABE)
Return Nil
 
