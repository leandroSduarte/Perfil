#include 'protheus.ch'
#include 'parmtype.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AT400APN �Autor  � Gabriel Ver�ssimo  � Data �  07/06/19   ���
�������������������������������������������������������������������������͹��
���Desc.     � O ponto de entrada existente na fun��o AT400F4 � disparado ���
��			 � na confirma��o do apontamento                       		  ���
�������������������������������������������������������������������������͹��
���Uso       � PERFIL                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function AT400APN()
	
	Local nI := 0
	
	//Ajusta array aColsAB5 que cont�m os apontamentos. Todos os apontamentos est�o na �ltima posi��o do array
	If IsInCallStack("U_PFGS001")
		For nI := 1 To Len(aColsAB5)
			If nI <> Len(aColsAB5)
				aColsAB5[nI][1] := aColsAB5[Len(aColsAB5)][nI]
			EndIf
		Next
	EndIf
	
Return .T.