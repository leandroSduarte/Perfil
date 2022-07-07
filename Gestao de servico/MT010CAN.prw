#include 'protheus.ch'
#include 'parmtype.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | MT010CAN   �Autor  � Gabriel Ver�ssimo � Data �  29/07/19  ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada localizado ao final da inclus�o/altera��o/���
��			 � exclus�o do cadastro de Produtos							  ���	
�������������������������������������������������������������������������͹��
���Uso       � Perfil		                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MT010CAN()

	Local nOpc := PARAMIXB[1]
	/* PARAMETRIZA��O DO PARAMIXB
	Inclus�o / Altera��o de produtos
	nOpc = 1 -> Fun��o executada OK.
	nOpc = 3 -> Fun��o Cancelada.

	Exclus�o de produtos
	nOpc = 2 -> Fun��o executada OK.
	nOpc = 1 -> Fun��o Cancelada.*/

	If !(Inclui .Or. Altera)
		If nOpc == 2
			u_DDMAX12X(.F., .T.)
		EndIf
	Else
		If nOpc == 1
			u_DDMAX12X(.F.)
		EndIf
	EndIf

Return