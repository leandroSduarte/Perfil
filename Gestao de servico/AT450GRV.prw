#include 'protheus.ch'
#include 'parmtype.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | AT450GRV   �Autor  � Gabriel Ver�ssimo � Data �  12/07/19  ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada executado no final da grava��o            ���
��			 � das Ordens de Servi�o									  ���
�������������������������������������������������������������������������͹��
���Uso       � Perfil		                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function AT450GRV()

	Local cNumAB8	:= ""
	Local aArea		:= GetArea()
	Local aAreaAB7	:= AB7->(GetArea())
	Local aAreaAB8	:= AB8->(GetArea())
	Local aAreaSC6	:= SC6->(GetArea())
	
	/* cNumAB8 := AB8->AB8_NUMOS
	AB8->(DbSetOrder(1)) //AB8_FILIAL+AB8_NUMOS+AB8_ITEM+AB8_SUBITE
	if AB8->(DbSeek(xFilial("AB8") + cNumAB8))
		while !AB8->(EoF()) .And. AB8->AB8_FILIAL + AB8->AB8_NUMOS == xFilial("AB8") + cNumAB8
			AB8->(RecLock("AB8", .F.))
			AB8->(DbDelete())
			AB8->(MsUnlock())
			AB8->(DbSkip())
		end
	endif */
	
	SC6->(DbSetOrder(11)) // C6_FILIAL+C6_CLI+C6_LOJA+C6_PEDCLI
	if SC6->(DbSeek(xFilial("SC6") + AB6->AB6_CODCLI + AB6->AB6_LOJA + AB6->AB6_NUMOS))
		AB6->(RecLock("AB6", .F.))
		AB6->AB6_STATUS := "A"
		AB6->AB6_XNUMPV := SC6->C6_NUM
		AB6->(MsUnlock())

		AB7->(DbSetOrder(1)) // AB7_FILIAL+AB7_NUMOS+AB7_ITEM
		if AB7->(DbSeek(xFilial("AB7") + AB6->AB6_NUMOS))
			AB7->(RecLock("AB7", .F.))
			AB7->AB7_TIPO := "1"
			AB7->(MsUnlock())
		endif
	endif
	
	// Realiza integra��o com MaxView
	// Para ordem de servi�o corretiva, n�o h� nenhuma regra -> deve sempre ser integrada
	if AB6->AB6_XCLAOS == "1"
		U_DDMAXI8X(.F.)
	// Para ordem de servi�o preventiva, deve respeitar as regras abaixo
	elseif AB6->AB6_XCLAOS == "2"
		// Quando o campo 't�cnico' estiver preenchido, deve integrar a ordem de servi�o normalmente
		if (Inclui .Or. Altera) .And. Len(AllTrim(AB6->AB6_XIDTEC)) > 0
			U_DDMAXI8X(.F.)
		endif
	endif

	
	RestArea(aAreaAB7)
	RestArea(aAreaAB8)
	RestArea(aAreaSC6)
	RestArea(aArea)
	
Return