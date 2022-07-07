#include 'protheus.ch'
#include 'parmtype.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AT460GRV �Autor  � Gabriel Ver�ssimo  � Data �  07/06/19   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada disparado ap�s a atualiza��o do 	      ���
��			 � atendimento da OS			                       		  ���
�������������������������������������������������������������������������͹��
���Uso       � PERFIL                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function AT460GRV()
	
	Local nOpc := PARAMIXB[1] //1=Inclus�o, 2=Altera��o, 3=Exclus�o	
	
	If nOpc == 3
		//Deleta apontamentos da ordem de servi�o
		AB8->(DbSetOrder(1)) //AB8_FILIAL+AB8_NUMOS+AB8_ITEM+AB8_SUBITE
		If AB8->(DbSeek(xFilial("AB8") + AB9->AB9_NUMOS))
			While !AB8->(EoF()) .And. AB8->AB8_FILIAL + AB8->AB8_NUMOS + AB8->AB8_ITEM == xFilial("AB8") + AB9->AB9_NUMOS 
				AB8->(RecLock("AB8", .F.))
				AB8->(DbDelete())
				AB8->(MsUnlock())
				AB8->(DbSkip())
			End
		EndIf
	EndIf
	
Return