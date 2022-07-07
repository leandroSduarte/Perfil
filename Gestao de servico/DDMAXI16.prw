#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#include "TBICONN.ch"
#include "TBICODE.ch"
#INCLUDE "TOPCONN.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DDMAXI16 ºAutor  ³Gabriel Veríssimo   º Data ³  11/03/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de importação de O.S. Preventiva MaxView	          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Perfil		                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DDMAXI16(nOpcao)

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

	aAdd(_aCampos, {"Tipo Registro"															,"ZJ_TIPO"})
	aAdd(_aCampos, {"Identificador Interno ID da Tarefa"									,"ZJ_IDMAX"})
	aAdd(_aCampos, {"Tarefa ID para Integração"												,"ZJ_IDINTEG"})
	aAdd(_aCampos, {"Cod Execucao Atividade"												,"ZJ_CODEXEC"})
	aAdd(_aCampos, {"Data Hora Tarefa"														,"ZJ_DTHRTRF"})
	aAdd(_aCampos, {"Data Hora Inicio Execucao Atividade Gerada Pelo Sistema (Dim Tempo)"	,"ZJ_DTHRINI"})
	aAdd(_aCampos, {"Data Hora Fim Execucao Atividade Gerada Pelo Sistema (Dim Tempo)"		,"ZJ_DTHRFIM"})
	aAdd(_aCampos, {"Cliente Identificador alternativo"										,"ZJ_CLIALT"})
	aAdd(_aCampos, {"Cliente Descrição"														,"ZJ_CLIDESC"})
	aAdd(_aCampos, {"Execução de Tarefas Conferir GPS Coletado"								,"ZJ_LATITUD;ZJ_LONGITU"})
	aAdd(_aCampos, {"Pessoa ID para Integração"												,"ZJ_USER"})
	aAdd(_aCampos, {"Pessoa Nome"															,"ZJ_USRNAME"})
	aAdd(_aCampos, {"Atividades ID para integração"											,"ZJ_CODATIV"})
	aAdd(_aCampos, {"Atividades Descrição"													,"ZJ_DESATIV"})
	aAdd(_aCampos, {"Seção ID para integração"												,"ZJ_CODSEC"})
	aAdd(_aCampos, {"Seção Descrição"														,"ZJ_DESCSEC"})
	aAdd(_aCampos, {"Subgrupo de Item Descrição"											,"ZJ_SUBDESC"})
	aAdd(_aCampos, {"Itens Identificador"													,"ZJ_ITEM"})
	aAdd(_aCampos, {"Itens Descrição"														,"ZJ_DESITEM"})
	aAdd(_aCampos, {"Ordem_de_Servico_Preventiva"											,"ZJ_OSPREV"})
	aAdd(_aCampos, {"Distancia_para_o_Cliente"												,"ZJ_DISTANC"})
	aAdd(_aCampos, {"Data_"																	,"ZJ_DATA"})
	aAdd(_aCampos, {"Hora_"																	,"ZJ_HORA"})
	aAdd(_aCampos, {"Ativo"																	,"ZJ_ATIVO"})
	aAdd(_aCampos, {"Confirma_Ativo"														,"ZJ_ATIVOK"})
	aAdd(_aCampos, {"Ativo_Correto"															,"ZJ_DESCCOR"})
	aAdd(_aCampos, {"Codigo_Ativo_Correto"													,"ZJ_ATIVCOR"})
	aAdd(_aCampos, {"Foto"																	,"ZJ_FOTO"})
	aAdd(_aCampos, {"OS_"																	,"ZJ_NUMOS"})
	aAdd(_aCampos, {"Check_List_Preventiva"													,"ZJ_CHKLIST"})
	aAdd(_aCampos, {"Data"																	,"ZJ_DATA"})
	aAdd(_aCampos, {"Hora"																	,"ZJ_HORA"})
	aAdd(_aCampos, {"Codigo_Identificacao"													,"ZJ_CODIDEN"})
	aAdd(_aCampos, {"Codigo_Execucao"														,"ZJ_CODEXE"})
	aAdd(_aCampos, {"Codigo_Status_Execucao"												,"ZJ_CODSTEX"})
	aAdd(_aCampos, {"OS"																	,"ZJ_NUMOS"})
	// aAdd(_aCampos, {"Ordem_de_Servico"														,"ZJ_NUMOS"}) // VERIFICAR SE RETORNARÁ PREENCHIDO - CRIAR CAMPO
	aAdd(_aCampos, {"Quantidade_"															,"ZJ_QUANT"})
	aAdd(_aCampos, {"Status_"																,"ZJ_STATUS"})
	aAdd(_aCampos, {"Cliente_"																,"ZJ_CLIENTE"})
	aAdd(_aCampos, {"Assinatura_do_Cliente"													,"ZJ_ASSINA"})
	aAdd(_aCampos, {"Observacao"															,"ZJ_OBSERV"})
	
	Default nOpcao := "1"

	RpcSetType(3)
	RPCSetEnv("02","0101") //Alterado para empresa 02 - Gabriel Lakatos 19/06/19
	ChkFile("SZJ")

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
		conout("Conectou no FTP")
		If FTPDirChange(_cDir)
			conout("Encontrou diretório no FTP")
			//_aDirFTP	:= FTPDirectory("Jornada-Extra*.csv")
			_aDirFTP	:= FTPDirectory("OS_PREVENTIVA*.csv")
			_cPathSer	:= "MaxView\Mobile\"
			conout("Len(_aDirFTP)")
			conout(Len(_aDirFTP))
			For nI := 1 to Len(_aDirFTP)
				conout("Encontrou arquivo no FTP")
				conout(_cPathSer+AllTrim(_aDirFTP[nI][1]))
				If FTPDownload(_cPathSer+AllTrim(_aDirFTP[nI][1]),AllTrim(_aDirFTP[nI][1]))
					conout("Baixou arquivo")
					//Trato o arquivo
					cFileOpen := _cPathSer+AllTrim(_aDirFTP[nI][1])
					If !File(cFileOpen)
						conout("Arquivo: "+AllTrim(_aDirFTP[nI][1])+" nao localizado! FTP MaxView - DDMAXI16")
						Loop
					EndIf
					FT_FUSE(cFileOpen)                	//ABRIR
					FT_FGOTOP()                     	//PONTO NO TOPO
					lFirst := .T.
					conout("")
					While !FT_FEOF()
						If lFirst //Despreso a primeira linha
							// conout("Iniciando leitura do arquivo")
							FT_FSKIP()
							lFirst	:= .F.
							//Cabecalho
							_cLinha	:= FT_FREADLN()
							//_cLinha	:= DecodeUtf8(_cLinha)
							// conout(_cLinha)
							_aCabec	:= WfTokenChar(_cLinha,";") 
							FT_FSKIP()
							//Comentado linha abaixo pois estava pulando primeiro registro
							//FT_FSKIP() //Adicionado pois a linha de cabecalhos tem mais de 1024 caracteres, onde o FT_READLIN le somente 1024 gerando problema na importação.
						EndIf 

						_cLinha	:= FT_FREADLN()
						//_cLinha	:= DecodeUtf8(_cLinha)
						_cLinha	:= AjuStr(_cLinha)
						_aDados := WfTokenChar(_cLinha,";")
						// conout(_cLinha)
						If Len(_aDados) < Len(_aCabec)
							For nX := 1 to (Len(_aCabec)-Len(_aDados))
								aAdd(_aDados,"")
							Next 
						EndIf
						If _aDados[1] == "FIM"
							FT_FSKIP()
							Loop
						EndIf 

						DbSelectArea("SZJ")
						RecLock("SZJ",.T.)					
						For nY := 1 to Len(_aCabec)

							// conout("DDMAXI16: " + AllTrim(_aCabec[nY]))
							SZJ->ZJ_FILIAL := xFilial("SZJ")
							//Procuro o Campo do Cabecalho do Arquivo na matriz
							nPos := AsCan(_aCampos,{|x| AllTrim(x[1]) == AllTrim(_aCabec[nY]) })
							If nPos > 0
								If Empty(_aCampos[nPos][2]) //Campos nao Utilizados
									Loop
								EndIf
								aCabReg := WfTokenChar(_aCampos[nPos][2],";")
								// conout(_aDados[nY])
								If Len(aCabReg) > 1
									If aCabReg[1] == "ZJ_LATITUD"
										//Campos latitude e longitude estão juntos
										aDadReg := WfTokenChar(strTran(AllTrim(_aDados[nY])," ",";"),";")
										If Len(aDadReg) >= 1
											&("SZJ->"+aCabReg[1]) := aDadReg[1]
										EndIf
										If Len(aDadReg) >= 2
											&("SZJ->"+aCabReg[2]) := aDadReg[2]
										EndIf
									EndIf
								Else
									//Outros campos
									cTipo := GetAdvFVal("SX3","X3_TIPO",_aCampos[nPos][2],2)
									If cTipo == "D"
										If Empty(&("SZJ->"+_aCampos[nPos][2]))
											&("SZJ->"+_aCampos[nPos][2]) := CTOD(Substr(_aDados[nY],9,2)+"/"+Substr(_aDados[nY],6,2)+"/"+Substr(_aDados[nY],1,4))
										EndIf
									ElseIf cTipo == "N"
										If Empty(&("SZJ->"+_aCampos[nPos][2]))
											&("SZJ->"+_aCampos[nPos][2]) := Val(_aDados[nY])
										EndIf
									ElseIf cTipo == "C" .Or. cTipo == "M"
										If aCabReg[1] == "ZJ_ATIVOK"
											If Empty(&("SZJ->"+_aCampos[nPos][2]))
												If Upper(AjuStr(_aDados[nY])) == "SIM"
													&("SZJ->"+_aCampos[nPos][2]) := "1"
												ElseIf Upper(AjuStr(_aDados[nY])) $ "NAO"
													&("SZJ->"+_aCampos[nPos][2]) := "2"
												EndIf
											EndIf
										Else
											If Empty(&("SZJ->"+_aCampos[nPos][2]))
												&("SZJ->"+_aCampos[nPos][2]) := _aDados[nY]
											EndIf
										EndIf
									EndIf
								EndIf
							EndIf
						Next

						DbSelectArea("SZJ")
						MsUnlock()					

						FT_FSKIP()
					EndDo
					FT_FUSE()
					cFileNewName := StrTran(AllTrim(_aDirFTP[nI][1]),".csv",".success")
					cFileNewName := StrTran(AllTrim(cFileNewName),".CSV",".success")
					FTPRENAMEFILE( AllTrim(_aDirFTP[nI][1]) , cFileNewName )	
					//exit
				Else	
					conout("Erro ao baixar arquivo: "+AllTrim(_aDirFTP[nI][1])+" FTP MaxView - DDMAXI16")
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
				conout("Erro ao desconectar do FTP MaxView - DDMAXI16")
			EndIf
			
			conout("Inicio processo DDMAXI17")
			U_DDMAXI17()
			conout("Fim processo DDMAXI17")
			
		Else
			conout("Erro ao setar diretorio no FTP MaxView - DDMAXI16")
		EndIf
	Else
		conout("Erro ao Conectar no FTP MaxView - DDMAXI16")
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
	cTexto:=Strtran(cTexto,"´"," ")
	cTexto:=Strtran(cTexto,"'"," ")
	//	cTexto:=Strtran(cTexto,"&","e")
	cTexto:=Strtran(cTexto,"€","C")
	cTexto:=Strtran(cTexto,"‡","c")
	cTexto:=Strtran(cTexto,"Ž","A")
	cTexto:=Strtran(cTexto,chr(143),"A")
	cTexto:=Strtran(cTexto,"Å","A")
	cTexto:=Strtran(cTexto,"…","a")
	cTexto:=Strtran(cTexto,"†","a")
	cTexto:=Strtran(cTexto," ","a")
	cTexto:=Strtran(cTexto,"„","a")
	cTexto:=Strtran(cTexto,"¦","a")
	cTexto:=Strtran(cTexto,"å","a")
	cTexto:=Strtran(cTexto,chr(144),"E")
	cTexto:=Strtran(cTexto,"ˆ","e")
	cTexto:=Strtran(cTexto,"‚","e")
	cTexto:=Strtran(cTexto,"¡","i")
	cTexto:=Strtran(cTexto,chr(141),"i")
	cTexto:=Strtran(cTexto,"“","o")
	cTexto:=Strtran(cTexto,"”","o")
	cTexto:=Strtran(cTexto,"•","o")
	cTexto:=Strtran(cTexto,"¢","o")
	cTexto:=Strtran(cTexto,"§","o")
	cTexto:=Strtran(cTexto,"ð","o")
	cTexto:=Strtran(cTexto,"£","u")
	cTexto:=Strtran(cTexto,chr(129),"u")
	cTexto:=Strtran(cTexto,"Ñ","N")
	cTexto:=Strtran(cTexto,"ñ","n")
	cTexto:=Strtran(cTexto,"%","P")
	cTexto:=Strtran(cTexto,"$","S")
	cTexto:=Strtran(cTexto,"þ","c")
	cTexto:=Strtran(cTexto,"÷","o")
	cTexto:=Strtran(cTexto,"Ý","i")
	cTexto:=Strtran(cTexto,"°","o")
	cTexto:=Strtran(cTexto,"¬","q")
	cTexto:=Strtran(cTexto,"ƒ","a")
	cTexto:=Strtran(cTexto,"Ÿ","a")
	cTexto:=Strtran(cTexto,"Æ","a")
	cTexto:=Strtran(cTexto,"µ","a")
	cTexto:=Strtran(cTexto,"¶","A")
	cTexto:=Strtran(cTexto,"º","o")
	cTexto:=Strtran(cTexto,"ª","a")
	cTexto:=Strtran(cTexto,"ã","a")
	cTexto:=Strtran(cTexto,"Ã","A")
	cTexto:=Strtran(cTexto,"õ","o")
	cTexto:=Strtran(cTexto,"Õ","O")
	cTexto:=Strtran(cTexto,"ç","c")
	cTexto:=Strtran(cTexto,"Ç","C")
	cTexto:=Strtran(cTexto,"á","a")
	cTexto:=Strtran(cTexto,"é","e")
	cTexto:=Strtran(cTexto,"í","i")
	cTexto:=Strtran(cTexto,"ó","o")
	cTexto:=Strtran(cTexto,"ú","u")
	cTexto:=Strtran(cTexto,"à","a")
	cTexto:=Strtran(cTexto,"è","e")
	cTexto:=Strtran(cTexto,"ì","i")
	cTexto:=Strtran(cTexto,"ò","o")
	cTexto:=Strtran(cTexto,"ù","u")
	cTexto:=Strtran(cTexto,"â","a")
	cTexto:=Strtran(cTexto,"ê","e")
	cTexto:=Strtran(cTexto,"î","i")
	cTexto:=Strtran(cTexto,"ô","o")
	cTexto:=Strtran(cTexto,"û","u")
	cTexto:=Strtran(cTexto,"ä","a")
	cTexto:=Strtran(cTexto,"ë","e")
	cTexto:=Strtran(cTexto,"ï","i")
	cTexto:=Strtran(cTexto,"ö","o")
	cTexto:=Strtran(cTexto,"ü","u")
	cTexto:=Strtran(cTexto,"Á","A")
	cTexto:=Strtran(cTexto,"É","E")
	cTexto:=Strtran(cTexto,"Í","I")
	cTexto:=Strtran(cTexto,"Ó","O")
	cTexto:=Strtran(cTexto,"Ú","U")
	cTexto:=Strtran(cTexto,"À","A")
	cTexto:=Strtran(cTexto,"È","E")
	cTexto:=Strtran(cTexto,"Ì","I")
	cTexto:=Strtran(cTexto,"Ò","O")
	cTexto:=Strtran(cTexto,"Ù","U")
	cTexto:=Strtran(cTexto,"Â","A")
	cTexto:=Strtran(cTexto,"Ê","E")
	cTexto:=Strtran(cTexto,"Î","I")
	cTexto:=Strtran(cTexto,"Ô","O")
	cTexto:=Strtran(cTexto,"Û","U")
	cTexto:=Strtran(cTexto,"Ä","A")
	cTexto:=Strtran(cTexto,"Ë","E")
	cTexto:=Strtran(cTexto,"Ï","I")
	cTexto:=Strtran(cTexto,"Ö","O")
	cTexto:=Strtran(cTexto,"Ü","U")
	cTexto:=Strtran(cTexto,"–","-")
	cTexto:=Strtran(cTexto,chr(13)+chr(10),"")
Return(cTexto)
