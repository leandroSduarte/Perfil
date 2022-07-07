#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#include "TBICONN.ch"
#include "TBICODE.ch"
#INCLUDE "TOPCONN.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � DDMAXI09 �Autor  �Gabriel Ver�ssimo   � Data �  22/05/19   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina de importa��o de O.S. MaxView				          ���
�������������������������������������������������������������������������͹��
���Uso       � Perfil		                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function DDMAXI09(nOpcao)

	Local lUploadFile		:= .F. 
	Local lGerouArquivo		:= .F.
	Local nI, nX, nY		:= 0
	Local _aStru			:= {}
	Local _cServidor
	Local _nPorta
	Local _cUsuario
	Local _cSenha
	Local _cDir
	Local _cLinha			:= ""
	Local _cPath 			:= ""
	Local _aCampos			:= {}
	Local _aSX5				:= {}

	aAdd(_aCampos, {"Tipo Registro"															,"ZF_TIPO"})
	aAdd(_aCampos, {"Identificador Interno ID da Tarefa"									,"ZF_IDMAX"})
	aAdd(_aCampos, {"Tarefa ID para Integra��o"												,"ZF_IDINTEG"})
	aAdd(_aCampos, {"Cod Execucao Atividade"												,"ZF_CODEXEC"})
	aAdd(_aCampos, {"Data Hora Tarefa"														,"ZF_DTHRTRF"})
	aAdd(_aCampos, {"Data Hora Inicio Execucao Atividade Gerada Pelo Sistema (Dim Tempo)"	,"ZF_DTHRINI"})
	aAdd(_aCampos, {"Data Hora Fim Execucao Atividade Gerada Pelo Sistema (Dim Tempo)"		,"ZF_DTHRFIM"})
	aAdd(_aCampos, {"Cliente Identificador alternativo"										,"ZF_CLIALT"})
	aAdd(_aCampos, {"Cliente Descri��o"														,"ZF_CLIDESC"})
	aAdd(_aCampos, {"Execu��o de Tarefas Conferir GPS Coletado"								,"ZF_LATITUD;ZF_LONGITU"})
	aAdd(_aCampos, {"Pessoa ID para Integra��o"												,"ZF_USER"})
	aAdd(_aCampos, {"Pessoa Nome"															,"ZF_USRNAME"})
	aAdd(_aCampos, {"Atividades ID para integra��o"											,"ZF_CODATIV"})
	aAdd(_aCampos, {"Atividades Descri��o"													,"ZF_DESATIV"})
	aAdd(_aCampos, {"Se��o ID para integra��o"												,"ZF_CODSEC"})
	aAdd(_aCampos, {"Se��o Descri��o"														,"ZF_DESCSEC"})
	aAdd(_aCampos, {"Itens Identificador"													,"ZF_ITEM"})
	aAdd(_aCampos, {"Itens Descri��o"														,"ZF_DESITEM"})
	aAdd(_aCampos, {"Data:"																	,"ZF_DATA"})
	aAdd(_aCampos, {"Hora:"																	,"ZF_HORA"})
	aAdd(_aCampos, {"Placa:"																,"ZF_PLACA"})
	aAdd(_aCampos, {"KM In�cio:"															,"ZF_KMINI"})
	aAdd(_aCampos, {"O.S.:"																	,"ZF_NUMOS"})
	aAdd(_aCampos, {"KM Final:"																,"ZF_KMFIM"})
	aAdd(_aCampos, {"Dist�ncia para o Cliente:"												,"ZF_DISTANC"})
	aAdd(_aCampos, {"Ativo"																	,"ZF_ATIVO"})
	aAdd(_aCampos, {"Confirma Ativo:"														,"ZF_ATIVOK"})
	aAdd(_aCampos, {"C�digo Ativo Correto:"													,"ZF_ATIVCOR"})
	aAdd(_aCampos, {"Ativo Correto:"														,"ZF_DESCCOR"})
	aAdd(_aCampos, {"Grupo:"																,"ZF_DESCGRP"})
	aAdd(_aCampos, {"C�digo Grupo"															,"ZF_CODGRP"})
	aAdd(_aCampos, {"Causa:"																,"ZF_DESCLOC"})
	aAdd(_aCampos, {"C�digo Localiza��o"													,"ZF_CODLOC"})
	aAdd(_aCampos, {"Identifica��o:"														,"ZF_DESIDEN"})
	aAdd(_aCampos, {"C�digo Identifica��o"													,"ZF_CODIDEN"})
	aAdd(_aCampos, {"Foto:"																	,"ZF_FOTO"})
	aAdd(_aCampos, {"Quantidade:"															,"ZF_QUANT"})
	aAdd(_aCampos, {"Status:"																,"ZF_STATUS"})
	aAdd(_aCampos, {"Execu��o:"																,"ZF_DESMEXE"})
	aAdd(_aCampos, {"C�digo Execu��o"														,"ZF_IDMEXEC"})
	aAdd(_aCampos, {"Cliente:"																,"ZF_CLIENTE"})
	aAdd(_aCampos, {"Assinatura do Cliente:"												,"ZF_ASSINA"})
	aAdd(_aCampos, {"Status da Execu��o:"													,"ZF_DESSTEX"})
	aAdd(_aCampos, {"C�digo Status Execu��o"												,"ZF_IDSTXEC"})
	aAdd(_aCampos, {"Observa��o:"															,"ZF_OBSERV"})
	
	Default nOpcao := "1"

	RpcSetType(3)
	RPCSetEnv("02","0101") //Alterado para empresa 02 - Gabriel Lakatos 19/06/19
	ChkFile("SZF")

	_cServidor		:= GetNewPar("DD_MAXSER","files.umov.me")
	_nPorta			:= GetNewPar("DD_MAXPOR",21)
	_cUsuario		:= GetNewPar("DD_MAXUSR","master.maxperfildesen")
	_cSenha			:= GetNewPar("DD_MAXPSW","max7318")
	_cDir			:= GetNewPar("DD_MAXDIR","/exportacao")
	_cLinha			:= ""

	DbSelectArea("SX3")
	/*DbSelectArea("SX5")
	DBSetOrder(1)
	If DBSeek(xFilial("SX5")+"ZZ")
	While !SX5->(Eof()) .AND. SX5->X5_TABELA == "ZZ"
	aAdd(_aSX5,{AllTrim(SX5->X5_CHAVE),AllTrim(SX5->X5_DESCRI)})
	SX5->(DBSkip())
	EndDo
	EndIf*/

	If FTPConnect(_cServidor,_nPorta,_cUsuario,_cSenha)
		If FTPDirChange(_cDir)
			//_aDirFTP	:= FTPDirectory("Jornada-Extra*.csv")
			_aDirFTP	:= FTPDirectory("OS_CORRETIVA*.csv")
			_cPathSer	:= "MaxView\Mobile\"
			For nI := 1 to Len(_aDirFTP)
				conout(_cPathSer+AllTrim(_aDirFTP[nI][1]))
				If FTPDownload(_cPathSer+AllTrim(_aDirFTP[nI][1]),AllTrim(_aDirFTP[nI][1]))
					//Trato o arquivo
					cFileOpen := _cPathSer+AllTrim(_aDirFTP[nI][1])
					If !File(cFileOpen)
						conout("Arquivo: "+AllTrim(_aDirFTP[nI][1])+" nao localizado! FTP MaxView - DDMAXI09")
						Loop
					EndIf
					FT_FUSE(cFileOpen)                	//ABRIR
					FT_FGOTOP()                     	//PONTO NO TOPO
					lFirst := .T.
					conout("")
					While !FT_FEOF()
						If lFirst //Despreso a primeira linha
							FT_FSKIP()
							lFirst	:= .F.
							//Cabecalho
							_cLinha	:= FT_FREADLN()
							//_cLinha	:= DecodeUtf8(_cLinha)
							conout(_cLinha)
							_aCabec	:= WfTokenChar(_cLinha,";") 
							FT_FSKIP()
							//Comentado linha abaixo pois estava pulando primeiro registro
							//FT_FSKIP() //Adicionado pois a linha de cabecalhos tem mais de 1024 caracteres, onde o FT_READLIN le somente 1024 gerando problema na importa��o.
						EndIf 

						_cLinha	:= FT_FREADLN()
						//_cLinha	:= DecodeUtf8(_cLinha)
						_cLinha	:= AjuStr(_cLinha)
						_aDados := WfTokenChar(_cLinha,";")
						conout(_cLinha)
						If Len(_aDados) < Len(_aCabec)
							For nX := 1 to (Len(_aCabec)-Len(_aDados))
								aAdd(_aDados,"")
							Next 
						EndIf
						If _aDados[1] == "FIM"
							FT_FSKIP()
							Loop
						EndIf 

						DbSelectArea("SZF")
						RecLock("SZF",.T.)					
						For nY := 1 to Len(_aCabec)

							conout("DDMAXI09: " + AllTrim(_aCabec[nY]))
							SZF->ZF_FILIAL := xFilial("SZF")
							//Procuro o Campo do Cabecalho do Arquivo na matriz
							nPos := AsCan(_aCampos,{|x| AllTrim(x[1]) == AllTrim(_aCabec[nY]) })
							If nPos > 0
								If Empty(_aCampos[nPos][2]) //Campos nao Utilizados
									Loop
								EndIf
								aCabReg := WfTokenChar(_aCampos[nPos][2],";")
								conout(_aDados[nY])
								If Len(aCabReg) > 1
									If aCabReg[1] == "ZF_LATITUD"
										//Campos latitude e longitude est�o juntos
										conout(_aDados[nY])
										conout(strTran(AllTrim(_aDados[nY])," ",";"))
										aDadReg := WfTokenChar(strTran(AllTrim(_aDados[nY])," ",";"),";")
										If Len(aDadReg) >= 1
											&("SZF->"+aCabReg[1]) := aDadReg[1]
										EndIf
										If Len(aDadReg) >= 2
											&("SZF->"+aCabReg[2]) := aDadReg[2]
										EndIf
									Else
										//Campo data e hora juntos
										If !Empty(Substr(_aDados[nY],9,2)+"/"+Substr(_aDados[nY],6,2)+"/"+Substr(_aDados[nY],1,4))
											&("SZF->"+aCabReg[1]) := CTOD(Substr(_aDados[nY],9,2)+"/"+Substr(_aDados[nY],6,2)+"/"+Substr(_aDados[nY],1,4))
										EndIf
										If !Empty(Substr(_aDados[nY],12,8))
											&("SZF->"+aCabReg[2]) := Substr(_aDados[nY],12,8)
										EndIf
									EndIf
								Else
									//Outros campos
									cTipo := GetAdvFVal("SX3","X3_TIPO",_aCampos[nPos][2],2)
									If cTipo == "D"
										If Empty(&("SZF->"+_aCampos[nPos][2]))
											&("SZF->"+_aCampos[nPos][2]) := CTOD(Substr(_aDados[nY],9,2)+"/"+Substr(_aDados[nY],6,2)+"/"+Substr(_aDados[nY],1,4))
										EndIf
									ElseIf cTipo == "N"
										If Empty(&("SZF->"+_aCampos[nPos][2]))
											&("SZF->"+_aCampos[nPos][2]) := Val(_aDados[nY])
										EndIf
									ElseIf cTipo == "C" .Or. cTipo == "M"
										If aCabReg[1] == "ZF_ATIVOK"
											If Empty(&("SZF->"+_aCampos[nPos][2]))
												If Upper(AjuStr(_aDados[nY])) == "SIM"
													&("SZF->"+_aCampos[nPos][2]) := "1"
												ElseIf Upper(AjuStr(_aDados[nY])) == "NAO"
													&("SZF->"+_aCampos[nPos][2]) := "2"
												EndIf
											EndIf
										Else
											If Empty(&("SZF->"+_aCampos[nPos][2]))
												&("SZF->"+_aCampos[nPos][2]) := _aDados[nY]
											EndIf
										EndIf
									EndIf
								EndIf
							EndIf
						Next

						DbSelectArea("SZF")
						MsUnlock()					

						FT_FSKIP()
					EndDo
					FT_FUSE()
					cFileNewName := StrTran(AllTrim(_aDirFTP[nI][1]),".csv",".success")
					cFileNewName := StrTran(AllTrim(cFileNewName),".CSV",".success")
					FTPRENAMEFILE( AllTrim(_aDirFTP[nI][1]) , cFileNewName )	
					//exit
				Else	
					conout("Erro ao baixar arquivo: "+AllTrim(_aDirFTP[nI][1])+" FTP MaxView - DDMAXI09")
				EndIf
			Next

			/*
			cQuery := "EXEC DDMAXI02 @Opcao=1"

			If Select("TMAX")>0
			DbSelectArea("TMAX")
			DBCloseArea()
			EndIf

			TCQUERY cQuery NEW ALIAS "TMAX"

			If Select("TMAX")>0
			DbSelectArea("TMAX")
			DBCloseArea()
			EndIf
			*/

			If !FTPDISCONNECT()
				conout("Erro ao desconectar do FTP MaxView - DDMAXI09")
			EndIf
			
			conout("Inicio processo DDMAXI13")
			U_DDMAXI13()
			conout("Fim processo DDMAXI13")
			
		Else
			conout("Erro ao setar diretorio no FTP MaxView - DDMAXI09")
		EndIf
	Else
		conout("Erro ao Conectar no FTP MaxView - DDMAXI09")
	EndIf

	RPCClearEnv() //Fecho o ambiente

	conout("Fim da Rotina")

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} AjuStr
Remove caracteres especiais

@author    Jonatas C. de Almeida
@version   1.xx
@since     17/06/2015
/*/
//-----------------------------------------------------------------------
Static Function AjuStr(_xTexto)
	Local cTexto := AllTrim(_xTexto)

	//	cTexto:=Strtran(cTexto,"@"," ")
	cTexto:=Strtran(cTexto,"�"," ")
	cTexto:=Strtran(cTexto,"'"," ")
	//	cTexto:=Strtran(cTexto,"&","e")
	cTexto:=Strtran(cTexto,"�","C")
	cTexto:=Strtran(cTexto,"�","c")
	cTexto:=Strtran(cTexto,"�","A")
	cTexto:=Strtran(cTexto,chr(143),"A")
	cTexto:=Strtran(cTexto,"�","A")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,chr(144),"E")
	cTexto:=Strtran(cTexto,"�","e")
	cTexto:=Strtran(cTexto,"�","e")
	cTexto:=Strtran(cTexto,"�","i")
	cTexto:=Strtran(cTexto,chr(141),"i")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","u")
	cTexto:=Strtran(cTexto,chr(129),"u")
	cTexto:=Strtran(cTexto,"�","N")
	cTexto:=Strtran(cTexto,"�","n")
	cTexto:=Strtran(cTexto,"%","P")
	cTexto:=Strtran(cTexto,"$","S")
	cTexto:=Strtran(cTexto,"�","c")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","i")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","q")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","A")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","A")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","O")
	cTexto:=Strtran(cTexto,"�","c")
	cTexto:=Strtran(cTexto,"�","C")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","e")
	cTexto:=Strtran(cTexto,"�","i")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","u")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","e")
	cTexto:=Strtran(cTexto,"�","i")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","u")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","e")
	cTexto:=Strtran(cTexto,"�","i")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","u")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","e")
	cTexto:=Strtran(cTexto,"�","i")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","u")
	cTexto:=Strtran(cTexto,"�","A")
	cTexto:=Strtran(cTexto,"�","E")
	cTexto:=Strtran(cTexto,"�","I")
	cTexto:=Strtran(cTexto,"�","O")
	cTexto:=Strtran(cTexto,"�","U")
	cTexto:=Strtran(cTexto,"�","A")
	cTexto:=Strtran(cTexto,"�","E")
	cTexto:=Strtran(cTexto,"�","I")
	cTexto:=Strtran(cTexto,"�","O")
	cTexto:=Strtran(cTexto,"�","U")
	cTexto:=Strtran(cTexto,"�","A")
	cTexto:=Strtran(cTexto,"�","E")
	cTexto:=Strtran(cTexto,"�","I")
	cTexto:=Strtran(cTexto,"�","O")
	cTexto:=Strtran(cTexto,"�","U")
	cTexto:=Strtran(cTexto,"�","A")
	cTexto:=Strtran(cTexto,"�","E")
	cTexto:=Strtran(cTexto,"�","I")
	cTexto:=Strtran(cTexto,"�","O")
	cTexto:=Strtran(cTexto,"�","U")
	cTexto:=Strtran(cTexto,"�","-")
	cTexto:=Strtran(cTexto,chr(13)+chr(10),"")
Return(cTexto)
