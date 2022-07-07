#INCLUDE "Protheus.ch"
#INCLUDE "RWMAKE.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "TbiConn.ch"

/*-------------------------------------------------------------------------------------
{Protheus.doc} MT381VLD

@Author  	   Felipe Aguiar - Focus Consultoria
@since		   06/2019
@version	   P12

@description Valida alteracoes no Empenho  
---------------------------------------------------------------------------------------
|Author                  | Date       | Description                                    |
|                        |            |                                                |
--------------------------------------------------------------------------------------*/
User Function MT381VLD()

Local l_Alt     := PARAMIXB[2]
Local l_Ok      := .T.
Local n_It      := 0
Local a_Head    := ACLONE(aHeader)  // Variavel private do fonte MATA381
Local a_Cols    := ACLONE(aCols)    // Variavel private do fonte MATA381
Local nPosCod   := aScan(a_Head, {|x| AllTrim(x[2])  == "D4_COD"   })
//Local nPosOp    := aScan(a_Head, {|x| AllTrim(x[2])  == "D4_OP"    })
Local nPosQtd   := aScan(a_Head, {|x| AllTrim(x[2])  == "D4_QUANT" })
Local a_AreaSD4 := SD4->(GetArea())
Local a_AreaSZ7 := SZ7->(GetArea())
Local a_AreaSZ8 := SZ8->(GetArea())
Local i         := 0
Local c_Produto := ""
Local n_Quant   := 0
Local a_Vol     := {}
Local c_Itens   := ""

If l_Alt

    For n_It := 1 To Len(a_Cols)

            c_Produto := a_Cols[n_It][nPosCod]              
            n_Quant   := a_Cols[n_It][nPosQtd]
 
            DbSelectArea("SD4")
	        DbSetOrder(1)//D4_FILIAL, D4_COD, D4_OP, D4_TRT, D4_LOTECTL, D4_NUMLOTE, R_E_C_N_O_, D_E_L_E_T_
            If DbSeek(xFilial("SD4")+c_Produto+cOP)

                    DbSelectArea("SZ7")
                    DbSetOrder(3)//Z7_FILIAL, Z7_OP, R_E_C_N_O_, D_E_L_E_T_

                    If DbSeek(xFilial("SZ7")+cOP)

                        While SZ7->(!EOF()) .AND. ALLTRIM(SZ7->Z7_OP) == ALLTRIM(cOP)

                            DbSelectArea("SZ8")
                            DbSetOrder(3)//Z8_FILIAL, Z8_NUMVOL, Z8_PEDIDO, Z8_ITEM, Z8_PRODUTO, R_E_C_N_O_, D_E_L_E_T_

                            If DbSeek(xFilial("SZ8")+SZ7->(Z7_NUMVOL+Z7_PEDIDO+Z7_ITEM)+c_Produto)

                                While SZ8->(!EOF()) .AND. SZ8->(Z8_FILIAL+Z8_NUMVOL+Z8_PEDIDO+Z8_ITEM+Z8_PRODUTO) == SZ7->(Z7_FILIAL+Z7_NUMVOL+Z7_PEDIDO+Z7_ITEM)+c_Produto
                                
                                    If ( (a_Cols[n_It][Len(a_Head)+1] == .F. .AND. n_Quant < SD4->D4_QUANT)  .OR. a_Cols[n_It][Len(a_Head)+1] == .T. )
                                    
                                        If aScan(a_Vol, ALLTRIM(c_Produto) ) == 0  //Condicao para nao repetir codigos na msg
                                            aAdd(a_Vol, ALLTRIM(c_Produto))
                                        EndIf

                                    EndIf    
                                    
                                    SZ8->(DbSkip()) 

                                EndDo

                            EndIf

                            SZ7->(DbSkip()) 

                        EndDo    
                    
                    EndIf                    
                                
            EndIf       
        
    Next n_It    

EndIf

If Len(a_Vol) > 0 
    For i := 1 To Len(a_Vol)
        c_Itens += a_Vol[i] + IIF( i == Len(a_Vol) , "" ,", " )
    Next i
EndIf

If !(Empty(c_Itens))
    l_Ok := .F.
    Help(NIL, NIL, "XVOL", NIL, "Já existem volumes montados para os produtos; " +CHR(13)+CHR(10)+CHR(13)+CHR(10)+c_Itens, 1, 0, NIL, NIL, NIL, NIL, NIL, {"Para alterar o empenho é necessário excluir os volumes. " })
EndIf 

RestArea(a_AreaSZ8)
RestArea(a_AreaSZ7)
RestArea(a_AreaSD4)

Return l_Ok 
