#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH" 

/*-------------------------------------------------------------------------------------
{Protheus.doc} MA415END

@Author  	   Felipe Aguiar - Delta Decisao
@since	   	   11/2019
@version	   P12

@description  Ponto de entrada p chamar a função para calculo de impostos
----------------------------------------------------------------------------------------
|Author                  | Date       | Description                                    |
|                        |            |                                                |
----------------------------------------------------------------------------------------
*/

User Function MA415END() 

/*
Local a_Area    := GetArea()
Local a_AreaSCK := SCK->(GetArea())
Local n_Tipo    := Paramixb[1] // 0 - Não confirmou / 1 - Confirmou a operação
Local n_Oper    := Paramixb[2] // 1 - Inclusão / 2 - Alteração / 3 - Exclusão
Local a_Imp     := {}
Local nValLiq   := 0
Local n_Item    := 0

If n_Oper <> 3

	If n_Tipo == 1

        DbSelectArea("SCK")
		DbSetOrder(1) //CK_FILIAL + CK_NUM + CK_ITEM + CK_PRODUTO
		SCK->(dbSeek(xFilial("SCK")+SCJ->CJ_NUM))			
		While SCK->(!EOF())	.And. SCK->CK_FILIAL == xFilial("SCK") .And. SCK->CK_NUM == SCJ->CJ_NUM	
			
            a_Imp := U_DDCalcImp( SCK->CK_PRODUTO,;
                                  SCK->CK_LOCAL,;
                                  SCK->CK_QTDVEN,;
                                  SCK->CK_TES,;
                                  SCK->CK_PRUNIT,;
                                  SCK->CK_VALOR,;
                                  Nil,;
                                  If(!Empty(SCJ->CJ_CLIENT),SCJ->CJ_CLIENT,SCJ->CJ_CLIENTE),; 
                                  SCJ->CJ_LOJAENT,;
                                  SCJ->CJ_TIPOCLI,;
                                  SCJ->CJ_EMISSAO,;
                                  SCJ->CJ_CONDPAG,;
                                  SCJ->CJ_FRETE,;
                                  SCJ->CJ_SEGURO,;
                                  SCJ->CJ_FRETAUT,;
                                  SCJ->CJ_DESPESA,;
                                  SCJ->CJ_PDESCAB,;
                                  SCJ->CJ_DESCONT,;
                                  IIF( !Empty(SCJ->CJ_PROSPE) .And. !Empty(SCJ->CJ_LOJPRO) , .T. , .F. ))
                                  
            For n_Item := 1 To Len(a_Imp) 

                Reclock("SCK",.F.)

                //Aliquotas            
                SCK->CK_XALQIPI := a_Imp[n_Item][1]
                SCK->CK_XALQICM := a_Imp[n_Item][2]
                SCK->CK_XALQPIS := a_Imp[n_Item][3]
                SCK->CK_XALQCOF := a_Imp[n_Item][4]
                SCK->CK_XALQIST := a_Imp[n_Item][5]
                SCK->CK_XALQISS := a_Imp[n_Item][6]

                //Bases
                SCK->CK_XBASIPI := a_Imp[n_Item][7]
                SCK->CK_XBASICM := a_Imp[n_Item][8]
                SCK->CK_XBASPIS := a_Imp[n_Item][9]
                SCK->CK_XBASCOF := a_Imp[n_Item][10]
                SCK->CK_XBASIST := a_Imp[n_Item][11]
                SCK->CK_XBASISS := a_Imp[n_Item][12]

                //Valores
                SCK->CK_XVALIPI := a_Imp[n_Item][13]
                SCK->CK_XVALICM := a_Imp[n_Item][14]
                SCK->CK_XVALPIS := a_Imp[n_Item][15]
                SCK->CK_XVALCOF := a_Imp[n_Item][16]
                SCK->CK_XVALIST := a_Imp[n_Item][17]
                SCK->CK_XVALISS := a_Imp[n_Item][18]

                nValLiq := a_Imp[n_Item][19] - ( a_Imp[n_Item][13] + a_Imp[n_Item][14] + a_Imp[n_Item][15] + a_Imp[n_Item][16] + a_Imp[n_Item][17] + a_Imp[n_Item][18] )
                
                SCK->CK_XVALLIQ := nValLiq

            Next n_Item

            SCK->(MsUnlock())

			SCK->(DbSkip())

		EndDo   

    EndIf

EndIf

RestArea(a_AreaSCK)
RestArea(a_Area)
*/
Return Nil 