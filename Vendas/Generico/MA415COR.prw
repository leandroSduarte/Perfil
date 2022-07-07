#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FONT.CH"  
#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������d
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MA415COR  �Autor  �Vinicius Belini     � Data �  10/12/2019 ���
���Programa  �          �       �Delta Decisao       �      �             ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada utilizada para ajustar o led do browse     ���
���          �da tela de orcamento. Led Violeta = Pedido Perdido          ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 12.1.17 - Equipe de Vendas/Orcamento              ���
���Usuario   � Gabriel Carvalho/Vendas                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MA415COR()

Local aCores1	:= aClone(PARAMIXB)          


Aadd(aCores1,{'SCJ->CJ_STATUS=="P"',"BR_VIOLETA"	})


Return (aCores1)
