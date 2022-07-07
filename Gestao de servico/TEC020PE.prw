#include 'protheus.ch'
#include 'parmtype.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | TECA020    �Autor  � Gabriel Ver�ssimo � Data �  11/07/19  ���
�������������������������������������������������������������������������͹��
���Desc.     � Pontos de Entrada da rotina TECA020                        ���
�������������������������������������������������������������������������͹��
���Uso       � Delta Decisao                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function TECA020()

	Local aParam	:= PARAMIXB
	Local oObj
	Local cIdPonto	:= ""
	Local cIdModel	:= ""
	Local lRet		:= .T.

	If aParam <> NIL
		oObj		:= aParam[1]
		cIdPonto	:= aParam[2]
		cIdModel	:= aParam[3]

		If cIdPonto == "FORMCOMMITTTSPRE"
			conout("TECA020 - FORMCOMMITTTSPRE")
			//Integra��o quando excluir registro
			If !(Inclui .Or. Altera)
				u_DDMAX10X(.F., .T.)
			EndIf
		ElseIf cIdPonto == "FORMCOMMITTTSPOS"
			conout("TECA020 - FORMCOMMITTTSPOS")
			//Integra��o quando incluir ou alterar registro
			If (Inclui .Or. Altera)
				u_DDMAX10X(.F.)
			EndIf
		EndIf
	EndIf

Return lRet