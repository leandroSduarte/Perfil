#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#include "TBICONN.ch"
#include "TBICODE.ch"
#INCLUDE "TOPCONN.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DDMAXI07 ºAutor  ³Gabriel Veríssimo   º Data ³  22/05/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de importação de horas MaxView			          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Perfil		                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DDMAXI07(nOpcao)

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

aadd(_aCampos, {"Tipo Registro"															,"Z6_TIPO"})
aadd(_aCampos, {"Identificador Interno ID da Tarefa"									,"Z6_IDMAXVI"})
aadd(_aCampos, {"Tarefa ID para Integração"												,"Z6_IDINTEG"})
aadd(_aCampos, {"Cod Execucao Atividade"												,"Z6_CODEXEC"})
aadd(_aCampos, {"Data Hora Tarefa"														,"Z6_DTHRTRF"})
aadd(_aCampos, {"Data Hora Inicio Execucao Atividade Gerada Pelo Sistema (Dim Tempo)"	,"Z6_DTHRINI"})
aadd(_aCampos, {"Data Hora Fim Execucao Atividade Gerada Pelo Sistema (Dim Tempo)"		,"Z6_DTHRFIM"})
aadd(_aCampos, {"Local Identificador alternativo"										,"Z6_LOCALT"})
aadd(_aCampos, {"Local Descrição"														,"Z6_LOCDESC"})
aadd(_aCampos, {"Execução de Tarefas Conferir GPS Coletado"								,"Z6_LATITUD;Z6_LONGITU"})
aadd(_aCampos, {"Pessoa ID para Integração"												,"Z6_USER"})
aadd(_aCampos, {"Pessoa Nome"															,"Z6_USRNAME"})
aadd(_aCampos, {"Atividades ID para integração"											,"Z6_CODATIV"})
aadd(_aCampos, {"Atividades Descrição"													,"Z6_DESATIV"})
aadd(_aCampos, {"Seção ID para integração"												,"Z6_CODSEC"})
aadd(_aCampos, {"Seção Descrição"														,"Z6_DESCSEC"})
aadd(_aCampos, {"Itens Identificador"													,"Z6_ITEM"})
aadd(_aCampos, {"Itens Descrição"														,"Z6_DESITEM"})
aadd(_aCampos, {"Data"																	,"Z6_DATA"})
aadd(_aCampos, {"Hora"																	,"Z6_HORA"})
aadd(_aCampos, {"Motivo"																,"Z6_MOTIVO"})
aadd(_aCampos, {"Foto"																	,"Z6_FOTO"})
aadd(_aCampos, {"Observação:"															,"Z6_OBS"})
aadd(_aCampos, {"Fim Hora Extra"														,"Z6_HRFIMEX"})
aadd(_aCampos, {"Início Hora Extra"														,"Z6_HRINIEX"})
aadd(_aCampos, {"Origem de O.S.?"														,"Z6_ORIGEM"})
aadd(_aCampos, {"Nº O.S.:"																,"Z6_NUMOS"})
aadd(_aCampos, {"Cliente / Loja"														,"Z6_CLINOME"})
aadd(_aCampos, {"Codigo Cliente / Loja"													,"Z6_CLIENTE;Z6_LOJA"})

DEFAULT nOpcao := "1"

RpcSetType(3)
RPCSetEnv("02","0101") //Alterado para empresa 02 - Gabriel Lakatos 19/06/19
ChkFile("SZ6")

_cServidor		:= GetNewPar("DD_MAXSER","files.umov.me")
_nPorta			:= GetNewPar("DD_MAXPOR",21)
_cUsuario		:= GetNewPar("DD_MAXUSR","master.maxperfil")
_cSenha			:= GetNewPar("DD_MAXPSW","max7318")
_cDir			:= GetNewPar("DD_MAXDIR","/exportacao")
_cLinha			:= ""

DbSelectArea("SX3")
/*DbSelectArea("SX5")
DBSetOrder(1)
If DBSeek(xFilial("SX5")+"ZZ")
	While !SX5->(Eof()) .AND. SX5->X5_TABELA == "ZZ"
		aadd(_aSX5,{alltrim(SX5->X5_CHAVE),alltrim(SX5->X5_DESCRI)})
		SX5->(DBSkip())
	EndDo
EndIf*/
               
If FTPConnect(_cServidor,_nPorta,_cUsuario,_cSenha)
	If FTPDirChange(_cDir)
		//_aDirFTP	:= FTPDirectory("Jornada-Extra*.csv")
		_aDirFTP	:= FTPDirectory("EX_JOR_EXT*.csv")
		_cPathSer	:= "MaxView\Mobile\"
		For nI := 1 to Len(_aDirFTP)
			Conout(_cPathSer+alltrim(_aDirFTP[nI][1]))
			If FTPDownload(_cPathSer+alltrim(_aDirFTP[nI][1]),alltrim(_aDirFTP[nI][1]))
				//Trato o arquivo
				cFileOpen := _cPathSer+alltrim(_aDirFTP[nI][1])
				If !File(cFileOpen)
					Conout("Arquivo: "+alltrim(_aDirFTP[nI][1])+" nao localizado! FTP MaxView - DDMAXI07")
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
						//FT_FSKIP() //Adicionado pois a linha de cabecalhos tem mais de 1024 caracteres, onde o FT_READLIN le somente 1024 gerando problema na importação.
					EndIf 

					_cLinha	:= FT_FREADLN()
					//_cLinha	:= DecodeUtf8(_cLinha)
					_cLinha	:= AjuStr(_cLinha)
					_aDados := WfTokenChar(_cLinha,";")
					conout(_cLinha)
					If Len(_aDados) < Len(_aCabec)
						For nX := 1 to (Len(_aCabec)-Len(_aDados))
							aadd(_aDados,"")
						Next 
					EndIf
					If _aDados[1] == "FIM"
						FT_FSKIP()
						Loop
					EndIf 

					DbSelectArea("SZ6")
					RecLock("SZ6",.T.)					
					For nY := 1 to Len(_aCabec)

						conout("DDMAXI07: " + alltrim(_aCabec[nY]))

						//Procuro o Campo do Cabecalho do Arquivo na matriz
						nPos := AsCan(_aCampos,{|x| alltrim(x[1]) == alltrim(_aCabec[nY]) })
						If nPos > 0
							If Empty(_aCampos[nPos][2]) //Campos nao Utilizados
								Loop
							EndIf
							aCabReg := WfTokenChar(_aCampos[nPos][2],";")
							conout(_aDados[nY])
							If Len(aCabReg) > 1
								If aCabReg[1] == "Z6_CLIENTE"
									//Campos cliente e loja estão juntos
									If !Empty(_aDados[nY])
										&("SZ6->"+aCabReg[1]) := Substr(PadL(_aDados[nY], 6, "0"), 1, 6)
										&("SZ6->"+aCabReg[2]) := Substr(_aDados[nY], 7, 4) //Clientes possuem lojas com até 4 digitos
									EndIf
								ElseIf aCabReg[1] == "Z6_LATITUD"
									//Campos latitude e longitude estão juntos
									conout(_aDados[nY])
									conout(strTran(alltrim(_aDados[nY])," ",";"))
									aDadReg := WfTokenChar(strTran(alltrim(_aDados[nY])," ",";"),";")
									If Len(aDadReg) >= 1
										&("SZ6->"+aCabReg[1]) := aDadReg[1]
									EndIf
									If Len(aDadReg) >= 2
										&("SZ6->"+aCabReg[2]) := aDadReg[2]
									EndIf
								Else
									//Campo data e hora juntos
									If !Empty(Substr(_aDados[nY],9,2)+"/"+Substr(_aDados[nY],6,2)+"/"+Substr(_aDados[nY],1,4))
										&("SZ6->"+aCabReg[1]) := CTOD(Substr(_aDados[nY],9,2)+"/"+Substr(_aDados[nY],6,2)+"/"+Substr(_aDados[nY],1,4))
									EndIf
									If !Empty(Substr(_aDados[nY],12,8))
										&("SZ6->"+aCabReg[2]) := Substr(_aDados[nY],12,8)
									EndIf
								EndIf
							Else
								//outros campos
								cTipo := GetAdvFVal("SX3","X3_TIPO",_aCampos[nPos][2],2)
								If cTipo == "D"
									If Empty(&("SZ6->"+_aCampos[nPos][2]))
										&("SZ6->"+_aCampos[nPos][2]) := CTOD(Substr(_aDados[nY],9,2)+"/"+Substr(_aDados[nY],6,2)+"/"+Substr(_aDados[nY],1,4))
									EndIf
								ElseIf cTipo == "N"
									If Empty(&("SZ6->"+_aCampos[nPos][2]))
										&("SZ6->"+_aCampos[nPos][2]) := Val(_aDados[nY])
									EndIf
								ElseIf cTipo == "C" .Or. cTipo == "M"
									If aCabReg[1] == "Z6_ORIGEM"
										If Empty(&("SZ6->"+_aCampos[nPos][2]))
											If Upper(_aDados[nY]) == "SIM"
												&("SZ6->"+_aCampos[nPos][2]) := "1"
											ElseIf Upper(_aDados[nY]) == "NAO"
												&("SZ6->"+_aCampos[nPos][2]) := "2"
											EndIf
										EndIf
									Else
										If Empty(&("SZ6->"+_aCampos[nPos][2]))
											&("SZ6->"+_aCampos[nPos][2]) := _aDados[nY]
										EndIf
									EndIf
								EndIf
							EndIf
						EndIf
					Next
					
					DbSelectArea("SZ6")
					MsUnlock()					
					
					FT_FSKIP()
				endDo
				FT_FUSE()
				cFileNewName := StrTran(alltrim(_aDirFTP[nI][1]),".csv",".success")
				cFileNewName := StrTran(alltrim(cFileNewName),".CSV",".success")
				FTPRENAMEFILE( alltrim(_aDirFTP[nI][1]) , cFileNewName )	
				//exit
			Else	
				Conout("Erro ao baixar arquivo: "+alltrim(_aDirFTP[nI][1])+" FTP MaxView - DDMAXI07")
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
			Conout("Erro ao desconectar do FTP MaxView - DDMAXI07")
		EndIf
	Else
		Conout("Erro ao setar diretorio no FTP MaxView - DDMAXI07")
	EndIf
Else
	Conout("Erro ao Conectar no FTP MaxView - DDMAXI07")
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
	Local cTexto := alltrim(_xTexto)
	
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
