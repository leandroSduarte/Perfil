#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH" 

/*-------------------------------------------------------------------------------------
{Protheus.doc} AT400GRV

@Author  	   Felipe Aguiar - Delta Decisao
@since	   	   11/2019
@version	   P12

@description  Ponto de entrada p chamar a função para calculo de impostos
----------------------------------------------------------------------------------------
|Author                  | Date       | Description                                    |
|                        |            |                                                |
----------------------------------------------------------------------------------------
*/

User Function AT400GRV() 

Local a_Area    := GetArea()
Local a_AreaAA5 := AA5->(GetArea())
Local a_AreaAB5 := AB5->(GetArea())
Local a_Imp     := {}
Local nValLiq   := 0
Local n_Item    := 0


DbSelectArea("AB5")
DbSetOrder(1) //AB5_FILIAL, AB5_NUMORC, AB5_ITEM, AB5_SUBITE, R_E_C_N_O_, D_E_L_E_T_
AB5->(dbSeek(xFilial("AB5")+AB3->AB3_NUMORC))			

While AB5->(!EOF())	.And. AB5->AB5_FILIAL == xFilial("AB5") .And. AB5->AB5_NUMORC == AB3->AB3_NUMORC
    
    DbSelectArea("AA5")
    DbSetOrder(1) //AA5_FILIAL, AA5_CODSER, R_E_C_N_O_, D_E_L_E_T_
    If AA5->(dbSeek(xFilial("AA5")+AB5->AB5_CODSER))

        a_Imp := U_DDCalcImp( AB5->AB5_CODPRO,;
                              Nil,;
                              AB5->AB5_QUANT,;
                              AA5->AA5_TES,;
                              AB5->AB5_VUNIT,;
                              AB5->AB5_TOTAL,;
                              Nil,;
                              AB3->AB3_CODCLI,; 
                              AB3->AB3_LOJA,;
                              AB3->AB3_XTPCLI,;
                              AB3->AB3_EMISSA,;
                              AB3->AB3_CONPAG )

        For n_Item := 1 To Len(a_Imp) 

            Reclock("AB5",.F.)

            //Aliquotas            
            AB5->AB5_XALQIP := a_Imp[n_Item][1]
            AB5->AB5_XALQIC := a_Imp[n_Item][2]
            AB5->AB5_XALQPI := a_Imp[n_Item][3]
            AB5->AB5_XALQCO := a_Imp[n_Item][4]
            AB5->AB5_XALQIS := a_Imp[n_Item][5]
            AB5->AB5_XAISS  := a_Imp[n_Item][6]

            //Bases
            AB5->AB5_XBASIP := a_Imp[n_Item][7]
            AB5->AB5_XBASIC := a_Imp[n_Item][8]
            AB5->AB5_XBASPI := a_Imp[n_Item][9]
            AB5->AB5_XBASCO := a_Imp[n_Item][10]
            AB5->AB5_XBASIS := a_Imp[n_Item][11]
            AB5->AB5_XBISS  := a_Imp[n_Item][12]

            //Valores
            AB5->AB5_XVALIP := a_Imp[n_Item][13]
            AB5->AB5_XVALIC := a_Imp[n_Item][14]
            AB5->AB5_XVALPI := a_Imp[n_Item][15]
            AB5->AB5_XVALCO := a_Imp[n_Item][16]
            AB5->AB5_XVALIS := a_Imp[n_Item][17]
            AB5->AB5_XVLISS := a_Imp[n_Item][18]

            nValLiq := a_Imp[n_Item][19] - ( a_Imp[n_Item][13] + a_Imp[n_Item][14] + a_Imp[n_Item][15] + a_Imp[n_Item][16] + a_Imp[n_Item][17] + a_Imp[n_Item][18] )
            
            AB5->AB5_XVALLI := nValLiq

        Next n_Item

    EndIF

AB5->(DbSkip())

EndDo 

RestArea(a_AreaAB5)
RestArea(a_AreaAA5)
RestArea(a_Area)

Return Nil