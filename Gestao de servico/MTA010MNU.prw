#include 'protheus.ch'
#include 'parmtype.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | MTA010MNU  �Autor  � Gabriel Ver�ssimo � Data �  29/07/19  ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada para adicionar novas rotinas no MenuDef   ���
��			 � da rotina de cadastro de Produtos						  ���	
�������������������������������������������������������������������������͹��
���Uso       � Perfil		                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MTA010MNU()
	
	//Vari�vel aRotina � private no fonte MATA010
	AAdd(aRotina, {"Integra��o MaxView"			, "U_DDMAX12X"	, 0, 1})
	AAdd(aRotina, {"Integra��o MaxView Todos"	, "U_DDMAX12Z"	, 0, 1})
	AAdd(aRotina, {"Esquema Eletrico"			, "U_PERF001()" , 0, 2, 0, Nil})
	
Return Nil