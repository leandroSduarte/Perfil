#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH" 

/*-------------------------------------------------------------------------------------
{Protheus.doc} F440CBASE

@Author  	   Felipe Aguiar - Delta Decisao
@since	   	   08/2020
@version	   P12

@description  Ponto de entrada para alterar base de calculo de comissao
              SO-20011258
----------------------------------------------------------------------------------------
|Author                  | Date       | Description                                    |
|                        |            |                                                |
----------------------------------------------------------------------------------------
*/

User Function F440ABAS()
 
Local a_Base     := ParamIxb
Local i          := 0
Local a_AreaSD2  := SD2->(GetArea()) 
Local a_AreaSC5  := SC5->(GetArea()) 

/*
/ Dados ParamIxb
[1]  [Código do Vendedor]  
[2]  [Base da Comissão]                             
[3]  [Base na Emissão ]                              
[4]  [Base na Baixa   ]                             
[5]  [Vlr  na Emissão ]                              
[6]  [Vlr  na Baixa   ]                              
[7]  [% da Comissão/Se "Zero" diversos %'s]
[8]  [ posicao sem documentacao ]
[9]  [ posicao sem documentacao ]
[10] [ posicao sem documentacao ]
[11] [ posicao sem documentacao ]
*/ 

DbSelectArea("SD2")
DbSetOrder(3)//D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM, R_E_C_N_O_, D_E_L_E_T_
If DbSeek(xFilial("SE1")+SE1->(E1_NUM+E1_PREFIXO+E1_CLIENTE+E1_LOJA)) 

    DbSelectArea("SC5")
    DbSetOrder(1)//C5_FILIAL, C5_NUM, R_E_C_N_O_, D_E_L_E_T_
    If DbSeek(xFilial("SD2")+SD2->D2_PEDIDO) 

        For i := 1 To Len(a_Base)
            a_Base[i][4] := a_Base[i][4] - SC5->C5_XFRETE
        Next i    
    
    EndIf

EndIf

RestArea(a_AreaSC5)
RestArea(a_AreaSD2)

Return a_Base