#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "FWMVCDEF.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | MATA035    �Autor  � Gabriel Ver�ssimo � Data �  11/07/19  ���
�������������������������������������������������������������������������͹��
���Desc.     � Chamada dos pontos de entrada do cadastro de Grupo de Prod.���
�������������������������������������������������������������������������͹��
���Uso       � Perfil                                               	  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MATA035()

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
			If !(Inclui .Or. Altera)
				u_DDMAX11X(.F., .T.)
			EndIf
		ElseIf cIdPonto == "FORMCOMMITTTSPOS"
			u_DDMAX11X(.F.)
		EndIf
	EndIf

Return lRet