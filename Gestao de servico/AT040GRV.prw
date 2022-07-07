#include 'protheus.ch'
#include 'parmtype.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | AT040GRV   �Autor  � Gabriel Ver�ssimo � Data �  22/07/19  ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada executado no final da grava��o            ���
��			 � da Base de Atendimento									  ���
�������������������������������������������������������������������������͹��
���Uso       � Perfil		                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function AT040GRV()
	
	//Chamada de integra��o do MaxView
	If !(Inclui .Or. Altera) 
		U_DDMAXI2X(.F., .T.)
		//Executo integra��o de clientes
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(xFilial("SA1") + AA3->AA3_CODCLI + AA3->AA3_LOJA))
			U_DDMAXI1X(.F.)
		EndIf
	Else
		U_DDMAXI2X(.F.)
		//Executo integra��o de clientes
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(xFilial("SA1") + AA3->AA3_CODCLI + AA3->AA3_LOJA))
			U_DDMAXI1X(.F.)
		EndIf
	EndIf
	
Return