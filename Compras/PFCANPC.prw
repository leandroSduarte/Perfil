#INCLUDE "Protheus.ch"
#INCLUDE "RWMAKE.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "Font.ch"
#INCLUDE "FwBrowse.ch"


/*-------------------------------------------------------------------------------------
{Protheus.doc} PFCANPC

@Author  	   Felipe Aguiar - Focus Consultoria
@since		   03/2019
@version	   P12

@description Cancela Pedido de Compra
---------------------------------------------------------------------------------------
|Author                  | Date       | Description                                    |
|                        |            |                                                |
--------------------------------------------------------------------------------------*/
User Function PFCANPC()

Local a_AreaSC7     := SC7->(GetArea())
Local a_AreaSB2     := SB2->(GetArea())
Local nAlt          := 0

Private c_Motv      := Space(50)
Private aButton     := {}
Private nOpca 

c_NumPed := SC7->(C7_FILIAL+C7_NUM)

l_Pode := fVerifica(c_NumPed)

If l_Pode

    If MsgYesNo("Confirma cancelamento do pedido?"+CHR(10)+CHR(13)+"Obs: Esta acao nao podera ser revertida!","ATENCAO")

        Define MsDialog oDlg Title "Motivo de Cancelmento" From 000,000 To 212,450 Pixel

        @ 043,007 Say "Digite um motivo"                	Size 040,008 Pixel Of oDlg
        @ 050,007 Get c_Motv Picture "@!"                   Size 200,010 Object o_Txt Valid fValid()
            
        Activate MsDialog oDlg Centered On Init EnchoiceBar(oDlg,{|| nOpca := 1 , oDlg:End() }, {|| nOpca := 0, oDlg:End() },, aButton)

        If nOpca == 1

            DbSelectArea("SC7")
            DbSetOrder(1)
        
            If DbSeek(c_NumPed)

                BEGIN TRANSACTION
                
                    While SC7->(!EOF()) .AND. SC7->(C7_FILIAL+C7_NUM) == c_NumPed 
                        
                        If Empty(SC7->C7_ENCER) .AND. Empty(SC7->C7_RESIDUO) 

                                            
                            RecLock("SC7",.F.)

                            SC7->C7_RESIDUO := "S"
                            SC7->C7_ENCER   := "E"
                            SC7->C7_XUSERCA := cUserName
                            SC7->C7_XMOTCAN := ALLTRIM(c_Motv)
                            SC7->C7_XDTCANC  := Date()
                            SC7->C7_XHRCANC := LEFT(Time(),5)

                            SC7->(MsUnlock())
                                            

                            DbSelectArea("SB2")
                            DbSetOrder(1)//B2_FILIAL, B2_COD, B2_LOCAL, R_E_C_N_O_, D_E_L_E_T_

                            If DbSeek(xFilial("SB2")+SC7->(C7_PRODUTO+C7_LOCAL))

                                n_SldAnt := SB2->B2_SALPEDI

                                RecLock("SB2",.F.)
                                SB2->B2_SALPEDI := n_SldAnt - SC7->C7_QUANT
                                SB2->(MsUnlock())
                            
                            EndIf

                        EndIf  
                
                        SC7->(DbSkip())
            
                    EndDo

                END TRANSACTION

            EndIf    
  
            MsgInfo("Pedido cancelado com sucesso.","INFORMACAO")

        EndIf

    EndIf

Else

    MsgStop("Nenhum item pode ser atualizado pois o pedido esta completamente encerrado.","ATENCAO") 

EndIf


RestArea(a_AreaSB2)
RestArea(a_AreaSC7)

Return Nil

/****************************************************************************/
Static Function fValid()

Local l_Ok := .T.

If Empty(c_Motv)
    MsgStop("Informe um motivo para o cancelamento")
    l_Ok := .F.
EndIf

Return l_Ok

/*****************************************************************************/

Static Function fVerifica(c_Num)

Local a_AreaSC7     := SC7->(GetArea())
Local l_OK          := .F.

DbSelectArea("SC7")
DbSetOrder(1)
    
If DbSeek(c_Num)

    While SC7->(!EOF()) .AND. SC7->(C7_FILIAL+C7_NUM) == c_NumPed 
                
        If Empty(SC7->C7_ENCER) .AND. Empty(SC7->C7_RESIDUO) 
               
            l_OK := .T.
                
        EndIf  
        
        SC7->(DbSkip())
        
    EndDo

EndIf    

RestArea(a_AreaSC7)

Return l_OK
