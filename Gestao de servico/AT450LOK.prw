#include 'protheus.ch'
#include 'parmtype.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | AT450LOK   �Autor  � Gabriel Ver�ssimo � Data �  17/02/20  ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada para valida��o da linha digitada          ���
��			 � na Ordem de Servi�o									      ���
�������������������������������������������������������������������������͹��
���Uso       � Perfil		                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function AT450LOK

    Local lRet  := .T.

    if !(aCols[n][Len(aHeader)+1]) .And. n <> 1
        Help(NIL, NIL, "AT450LOK", NIL, "N�o � permitido a inclus�o de mais de uma linha na Ordem de Servi�o", 1, 0, NIL,;
             NIL, NIL, NIL, NIL, {"Para incluir outro equipamento � necess�rio gerar uma nova Ordem de Servi�o."})
        lRet := .F.
    endif

Return lRet