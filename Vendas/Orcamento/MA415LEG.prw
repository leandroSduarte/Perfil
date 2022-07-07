#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FONT.CH"  
#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MA415LEG  �Autor  �Vinicius Belini     � Data �  10/12/2019 ���
���Programa  �          �       �Delta Decisao       �      �             ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada utilizada para adiconar legenda no browse  ���
���          �da tela de orcamento. Legenda Violeta = Pedido Perdido      ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 12.1.17 - Equipe de Vendas/Orcamento              ���
���Usuario   � Gabriel Carvalho/Vendas                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MA415LEG()
 
Local aNewLegenda  := aClone(PARAMIXB)
 

aAdd(aNewLegenda,{'BR_VIOLETA'  , 'Orcamento Perdido'})
 

Return aNewLegenda