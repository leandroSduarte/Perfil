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

	/* 
		Validar grupo default (9999) e n�o permitir excluir esse grupo
	   	Validar se a descri��o do grupo j� foi utilizada em algum outro grupo (registrados deletados ou n�o) e n�o permitir caso j� tenho sido utilizado
	*/

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
			if Inclui .or. Altera
				u_DDMAX11X(.F.)
			endif
		EndIf
	EndIf

Return lRet