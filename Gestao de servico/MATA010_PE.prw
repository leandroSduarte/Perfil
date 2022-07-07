#Include 'protheus.ch'
#Include 'parmtype.ch'
/*���������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������Ŀ��
���Programa  � MATA010_PE � Autor � Flavio Valentin dos Santos� Data � 29/01/19 ���
�������������������������������������������������������������������������������Ĵ��
���Descricao � Ponto de Entrada da rotina Cadastro de Produtos (MATA010).       ���
���          � ITEM - MVC. Obs.: Em substituicao ao PE mt010alt.prw.            ���
�������������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum.                                                          ���
�������������������������������������������������������������������������������Ĵ��
���Uso       � Perfil Refrigeracao.                                             ���
�������������������������������������������������������������������������������Ĵ��
���Retorno   � _xRet => (.T. / .F.), Array.                                     ���
�������������������������������������������������������������������������������Ĵ��
���Analista Resp.�  Data  � Manutencao Efetuada                                 ���
�������������������������������������������������������������������������������Ĵ��
���              �        �                                                     ���
��������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������
���������������������������������������������������������������������������������*/
User Function ITEM()

	Local _aParam 		:= PARAMIXB
	Local _xRet 		:= .T.
	Local _oObj 		:= ""
	Local _cIdPonto 	:= ""
	Local _cIdModel 	:= ""
	Local _lIsGrid 		:= .F.
	Local _l010Auto 	:= Iif(ValType(l010Auto)<>"L",.F.,l010Auto)


	If (_aParam <> Nil)

		_oObj 		:= _aParam[1]
		_cIdPonto 	:= _aParam[2]
		_cIdModel 	:= _aParam[3]
		_lIsGrid 	:= (Len(_aParam) > 3)

		If _cIdPonto == "FORMPRE"
			If (ALTERA)
				if (Len(_aParam) > 3)
					if valtype(_aParam[4])=='C'
						If (_aParam[4] == "SETVALUE")
							c_Msblql := SB1->B1_MSBLQL
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf

		If _cIdPonto == "MODELCOMMITNTTS" //Chamada apos a gravacao da tabela do formulario

			If (INCLUI)

				If !(SubStr(SB1->B1_COD,1,1) $ "2/6") .And. !(_l010Auto)
					u_PERFEXPROD(.F.)
				EndIf

			ElseIf (ALTERA)

				// S� deve ser enviada uma altera��o de Ativo/Inativo para WBC CAD
				//A variavel c_Msblql foi declarada no fonte AFTERLOGIN , pois o PE de PRODUTOS � o mesmo para todas as opera��es (valida�ao, grava��o,etc) -> MVC
				If SB1->B1_MSBLQL <> c_Msblql

					If !(SubStr(SB1->B1_COD,1,1) $ "2/6") .And. !(_l010Auto)
						u_PERFEXPROD(.F.)
						c_Msblql := ""
					EndIf

				EndIf

				//SO-
				DbSelectArea("AA3")
				AA3->(DbSetOrder(9))
				AA3->(DbGoTop())

				If DbSeek(xFilial("AA3")+SB1->B1_COD)

					While AA3->(!EOF()) .AND. AA3->AA3_CODPRO == SB1->B1_COD

						RecLock("AA3", .F.)
						AA3->AA3_XDESPR := SB1->B1_DESC
						AA3->(MsUnlock())

						AA3->(DbSkip())

					EndDo
				EndIf

			EndIf
		EndIf

	EndIf

Return(_xRet)
