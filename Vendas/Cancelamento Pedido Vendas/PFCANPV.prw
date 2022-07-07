#INCLUDE "Protheus.ch"
#INCLUDE "RWMAKE.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "Font.ch"
#INCLUDE "FwBrowse.ch"


/*-------------------------------------------------------------------------------------
{Protheus.doc} PFCANPV

@Author  	   Felipe Aguiar - Focus Consultoria
@since		   03/2019
@version	   P12

@description Cancela Pedido de Compra
---------------------------------------------------------------------------------------
|Author                  | Date       | Description                                    |
|                        |            |                                                |
--------------------------------------------------------------------------------------*/
User Function PFCANPV()

Local a_Area    := GetArea()
Local a_AreaSC5 := SC5->(GetArea())

Private c_Motv      := Space(50)
Private aButton     := {}
Private nOpca

If MsgYesNo("Confirma cancelamento do pedido?"+CHR(10)+CHR(13)+"Obs: Esta acao nao podera ser revertida!","ATENCAO")

    Define MsDialog oDlg Title "Motivo de Cancelmento" From 000,000 To 212,450 Pixel

    @ 043,007 Say "Digite um motivo"                	Size 040,008 Pixel Of oDlg
    @ 050,007 Get c_Motv Picture "@!"                   Size 200,010 Object o_Txt Valid fValid()
        
    Activate MsDialog oDlg Centered On Init EnchoiceBar(oDlg,{|| nOpca := 1 , oDlg:End() }, {|| nOpca := 0, oDlg:End() },, aButton)

    If nOpca == 1

        Ma410Resid('SC5',SC5->(RecNo()),2)

        If SC5->C5_NOTA == 'XXXXXXXXX'
                
            BEGIN TRANSACTION

                 RecLock("SC5",.F.)

                        SC5->C5_XUSERCA := cUserName
                        SC5->C5_XMOTCA  := ALLTRIM(c_Motv)
                        SC5->C5_XDTCANC  := Date()
                        SC5->C5_XHRCANC := LEFT(Time(),5)

                SC5->(MsUnlock())

            END TRANSACTION

            MsgInfo("Pedido cancelado com sucesso.","INFORMACAO")

        Else 

            MsgStop("Nao foi possivel cancelar o pedido.","ATENCAO")        
    
        EndIf
    
    EndIf

EndIf        

RestArea(a_AreaSC5)
RestArea(a_Area)

Return Nil

/****************************************************************************/
Static Function fValid()

Local l_Ok := .T.

If Empty(c_Motv)
    MsgStop("Informe um motivo para o cancelamento")
    l_Ok := .F.
EndIf

Return l_Ok