#include 'protheus.ch'
#include 'parmtype.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | TC450ROT   �Autor  � Gabriel Ver�ssimo � Data �  12/07/19  ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada para a inclus�o de rotinas de usu�rio     ���
��			 � na rotina de Ordem de Servi�o							  ���
�������������������������������������������������������������������������͹��
���Uso       � Delta Decisao                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function TC450ROT()

	Local aRet := {}

	AAdd(aRet, {"Gerar Orcamento"			, "U_PFGS001"	, 0, 3})
	AAdd(aRet, {"Imp. O.S. Corretiva"		, "U_PFOSR01"	, 0, 1})
	AAdd(aRet, {"Imp. O.S. Preventiva"		, "U_PFOSR04"	, 0, 1})
	// AAdd(aRet, {"Integra��o MaxView"		, "U_DDMAXI8X"	, 0, 1})
	// AAdd(aRet, {"Integra��o MaxView Todos"	, "U_DDMAXI8Z"	, 0, 1})

Return aRet
