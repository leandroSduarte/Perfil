#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"
#Include "RWMAKE.CH"
#Include "TbiConn.ch"

User Function PERJOB02()

	//Preparar o Ambiente
	Prepare Environment Empresa "01" Filial "0101"

	conout("----------------------------------------------------------------------")
	conout("- Importa arquivo de orcamento integracao WBC CAD - INICIO : "+Time())
	conout("----------------------------------------------------------------------")

	U_PERFIMPORC(.T.)

	conout("-----------------------------------------------------------------")
	conout("- Importa arquivo de orcamento integracao WBC CAD - FIM : "+Time())
	conout("-----------------------------------------------------------------")

	Reset Environment

Return Nil



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PERFIMPORC ³ Autor ³ Flavio Valentin           ³ Data ³ 16/01/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa que gera a importacao do Orcamento.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil.                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
User Function PERFIMPORC(_lJob)
	Local lEnd			:= .F.
	Local _aArea		:= GetArea()
	Local _lOk			:= .F.
	Private _lExecJob	:= Iif(ValType(_lJob)<>"L",.F.,_lJob) //.T. = Chamada originou de um Schedule do Protheus
	Private _cOrcTmp1	:= GetNextAlias()
	Private _cOrcTmp2	:= GetNextAlias()
	Private _oTmpOrc1	:= Nil
	Private _oTmpOrc2	:= Nil
	Private _cServFTP	:= GetNewPar("PR_FTPSRV3","192.168.12.13") // GetNewPar("PR_FTPSRV3","192.168.3.18") //Server FTP
	Private _nPortFTP	:= GetNewPar("PR_FTPPOR3",21) //Port FTP
	Private _cUserFTP	:= GetNewPar("PR_FTPUSR3","teste") //Login FTP
	Private _cSenhaFTP	:= GetNewPar("PR_FTPSEN3","tst") //Password FTP
	Private _cPastaFTP	:= GetNewPar("PR_FTPPAS3","/teste/") //Pasta FTP
	Private _cMarkArq 	:= GetNewPar("PR_FTPMSK3","arq*.txt") //Para filtrar os arquivos
	Private _cDirTXT  	:= GetNewpar("PR_WBCPAS3","\INTEG-WBCCAD\")
	//Private _cDirTXT2  	:= "ORCAMENTO\" 22/08
	Private _cDirTXT2  	:= "PENDENTE\"
	//Private _cDirDest  	:= "PENDENTE\" 22/08
	Private _cTxtNome	:= ""
	Private _oProcess  	:= Nil
	Private __lProduca	:= (UPPER(AllTrim(GetEnvServer()))=="PERFIL" .Or. UPPER(AllTrim(GetEnvServer()))=="PERFIL_COMP" .Or. UPPER(AllTrim(GetEnvServer()))=="PERFIL_JOB" .Or. UPPER(AllTrim(GetEnvServer()))=="PERFIL_WS")

	If !ExistDir(_cDirTXT)
		MakeDir(_cDirTXT)
	EndIf

	If !ExistDir(_cDirTXT + _cDirTXT2)
		MakeDir(_cDirTXT + _cDirTXT2)
	EndIf

	/*
If !ExistDir(_cDirTXT + _cDirTXT2 + _cDirDest)	22/08
	MakeDir(_cDirTXT + _cDirTXT2 + _cDirDest) 22/08
EndIf
	*/
	If (__lProduca)
		FGETARQ()
	EndIf

	If (_lExecJob)
		_lOk := FGETXTDIR(lEnd)
	Else
		_oProcess := MsNewProcess():New( { | lEnd | _lOk := FGETXTDIR(@lEnd)}, "Importacao do TXT do Orcamento", "Aguarde, selecionando informações ...", .F.)
		_oProcess:Activate()
	EndIf

	If !(_lOk)
		Return(Nil)
	EndIf

	RestArea(_aArea)

Return(Nil)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FGETARQ    ³ Autor ³ Flavio Valentin           ³ Data ³ 16/01/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que pega o arquivo posicao do pedido no ftp.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FGETARQ()

	Local _lRet		:= .T.
	//Local _aDirFtp	:= {}
	//Local _nIni		:= 0
	//Local _nTamArr	:= 0

	If !ExistDir(_cDirTXT)
		MakeDir(_cDirTXT)
	EndIf

	If !ExistDir(_cDirTXT + _cDirTXT2)
		MakeDir(_cDirTXT + _cDirTXT2)
	EndIf

	/*
If !ExistDir(_cDirTXT + _cDirTXT2 + _cDirDest)	22/08
	MakeDir(_cDirTXT + _cDirTXT2 + _cDirDest) 22/08
EndIf


FTPDisconnect()
If FTPConnect(_cServFTP, _nPortFTP, _cUserFTP, _cSenhaFTP)
 	If FTPDirChange(_cPastaFTP)
  		_aDirFtp := FTPDIRECTORY(_cMarkArq,)
  		_nTamArr := Len(_aDirFtp)
  		If (_nTamArr > 0)
	  		For _nIni := 1 To _nTamArr
	  	  		If FTPDownLoad(_cDirTXT + _cDirTXT2 + _cDirDest+_aDirFtp[_nIni][1],_aDirFtp[_nIni][1])
					If File(_cDirTXT + _cDirTXT2 + _cDirDest+_aDirFtp[_nIni][1])
						Conout("Download de Arquivos .TXT - PERFIMPORC")
						If (FTPErase(_aDirFtp[_nIni][1]))
							Conout("O arquivo ["+_aDirFtp[_nIni][1]+"] foi excluido com sucesso do FTP - PERFIMPORC")
						Else
							Conout("Não foi possível excluir o arquivo ["+_aDirFtp[_nIni][1]+"] do FTP - PERFIMPORC")
						EndIf
					Else
						Conout("O arquivo "+AllTrim(_aDirFtp[_nIni][1])+ " não foi copiado para o diretório "+AllTrim(_cDirTXT + _cDirTXT2 + _cDirDest)+" - PERFIMPORC")
						FTPDisconnect()
	  	  				_lRet := .F.
					EndIf
				Else
	  	  			Conout("Arquivo .TXT - Erro na copia dos arquivos no FTP - PERFIMPORC")
	  	  		EndIf
	  	  	Next _nIni
  		Else
  			Conout(".TXT nao encontrados na pasta "+AllTrim(_cPastaFTP)+" - PERFIMPORC")
  	  		FTPDisconnect()
  	  		_lRet := .F.
  		EndIf
  	Else
  		Conout("Diretorio inexistente no FTP - PERFIMPORC")
  	  	FTPDisconnect()
  	  	_lRet := .F.
  	EndIf
  	FTPDisconnect()
Else
	Conout("Erro ao Conectar no FTP - PERFIMPORC")
  	_lRet := .F.
EndIf
FTPDisconnect()
	*/

Return(_lRet)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FGETXTDIR  ³ Autor ³ Flavio Valentin           ³ Data ³ 16/01/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que faz a leitura do arquivo na pasta e o importa.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FGETXTDIR(lEnd)

	Local _aArea	:= GetArea()
	Local _lRet    	:= .T.
	Local _aDiret  	:= {}
	Local _nIni    	:= 0
	Local _nTamDir	:= 0
	Local _cDirOk	:= "processado\"
	Local _cDirErro	:= "erro\"

	FARQTEMP()

	/* 22/08
If !ExistDir(_cDirTXT + _cDirTXT2 + _cDirOk)
	MakeDir(_cDirTXT + _cDirTXT2 + _cDirOk)
EndIf

If !ExistDir(_cDirTXT + _cDirTXT2 + _cDirErro)
	MakeDir(_cDirTXT + _cDirTXT2 + _cDirErro)
EndIf
	*/

	If !ExistDir(_cDirTXT  + _cDirOk)
		MakeDir(_cDirTXT + _cDirOk)
	EndIf

	If !ExistDir(_cDirTXT  + _cDirErro)
		MakeDir(_cDirTXT  + _cDirErro)
	EndIf



	If !(_lExecJob)
		_oProcess:SetRegua1(8)
	EndIf

	//_aDiret 	:= Directory(_cDirTXT + _cDirTXT2 + _cDirDest + "*.###") //Pega os arquivos .TXT existentes na pasta
	_aDiret 	:= Directory(_cDirTXT + _cDirTXT2 + "*@.###") //Pega os arquivos .TXT existentes na pasta
	_nTamDir	:= Len(_aDiret)

	If (_nTamDir == 0)
		Conout("Não há arquivos na pasta "+_cDirTXT + _cDirTXT2 +" - PERFIMPORC")
		Return(.F.)
	EndIf

	_nIni		:= 0
	For _nIni := 1 To _nTamDir
		_cTxtNome	:= _aDiret[_nIni,1]
		If !(_lExecJob)
			_oProcess:IncRegua1("Leitura do arquivo "+_cTxtNome)
		EndIf

		_cPathFile	:= _cDirTXT + _cDirTXT2  + _cTxtNome
		Conout("Lendo o(s) arquivo(s) .TXT da pasta "+_cDirTXT + _cDirTXT2  + " - PERFIMPORC")

		_lRet := FREADTXT()

		If (_lRet)
			Conout("Movendo o arquivo para a pasta "+_cDirTXT + _cDirOk + _cTxtNome + " - PERFIMPORC")
			COPY File(_cPathFile) To (_cDirTXT + _cDirOk + _cTxtNome)
			If File(_cDirTXT + _cDirOk + _cTxtNome)
				fErase(_cPathFile)
			EndIf
		Else
			Conout("Movendo o arquivo para a pasta "+_cDirTXT + _cDirErro + _cTxtNome + " - PERFIMPORC")
			COPY File(_cPathFile) To (_cDirTXT + _cDirErro + _cTxtNome)
			If File(_cDirTXT + _cDirErro + _cTxtNome)
				fErase(_cPathFile)
			EndIf
		EndIf

		If !(_lRet)
			If !(_lExecJob)
				MsgStop("O Arquivo "+AllTrim(_cTxtNome)+" não foi importado.")
			EndIf
			Conout("O Arquivo "+AllTrim(_cTxtNome)+" não foi importado.")
		Else
			If !(_lExecJob)
				MsgInfo("O Arquivo "+AllTrim(_cTxtNome)+" foi importado com sucesso.")
			EndIf
			Conout("O Arquivo "+AllTrim(_cTxtNome)+" foi importado com sucesso.")
		EndIf
	Next _nIni

	RestArea(_aArea)

Return(_lRet)



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FREADTXT   ³ Autor ³ Flavio Valentin           ³ Data ³ 16/01/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que faz a importacao do txt com a situacao do Pedido      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ _lRet => .T./.F.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FREADTXT()

	Local _aArea		:= GetArea()
	Local _lOk 			:= .T.
	Local _cBuffer 		:= ""
	Local _nHandle		:= 0
	Local _aDadostxt	:= {}
	Local _cCodProd		:= ""
	Local _nLin			:= 0
	Local _cTpReg		:= ""
	Local _cNumOrc		:= ""
	Local _dDtEmis 		:= CTOD("/ /")
	Local _nTamIt		:= 2 //TAMSX3("C6_ITEM")[1]

	//Abre o Arquivo
	_nHandle := Ft_fuse(_cPathFile)
	If _nHandle == -1  // Se houver erro de abertura abandona processamento
		Return(.F.)
	Endif

	//Numero de linhas do arquivo
	ProcRegua(Ft_fLastRec())

	//Vai para a primeira linha do arquivo
	Ft_FGoTop()
	_cBuffer	:= ""
	_nLin 		:= 1
	_nRecno		:= 0
	_cNumOrc	:= ""
	_cCNPJ		:= ""
	_cNomeCli	:= ""
	_cCodCli 	:= ""
	_cLjClie 	:= ""
	_cNomeCli2	:= ""
	_lOk		:= .T.
	While !Ft_fEof()

		If !(_lExecJob)
			_oProcess:IncRegua1("Lendo a "+AllTrim(Str(_nLin))+"ª linha do arquivo "+_cTxtNome)
		EndIf

		_cBuffer	:= Ft_fReadln()
		_nRecno		:= Ft_fRecno()
		_aDadostxt	:= {}
		_cTpReg		:= ""
		_cItem		:= ""
		_cGrpSub	:= ""
		_cCodInt	:= ""
		_cCodGrp	:= ""
		_cCodProd	:= ""
		_cDescEsp	:= ""
		_nQuant		:= 0
		_nVlrItem	:= 0
		_nVlrList	:= 0
		_dDtEmis 	:= CTOD("/ /")
		_cBuffer	:= StrTran(_cBuffer,"|"," { ")
		_aDadostxt	:= StrTokArr(_cBuffer,"{")

		If Len(_aDadostxt)==0
			Ft_fSkip()
			Loop
		EndIf

		_cTpReg	:= AllTrim(_aDadostxt[1])

		If !(_cTpReg $ "0/1/2/3")
			_lOk := .F.
			Exit
		EndIf

		If (_cTpReg == "0")
			_cHeader := UPPER(AllTrim(_aDadostxt[4]))
		ElseIf (_cTpReg=="1")
			_cNumOrc 	:= AllTrim(_aDadostxt[2])
			_cNomeCli	:= AllTrim(_aDadostxt[4])
			_cCNPJ		:= AllTrim(_aDadostxt[11])
			_cCNPJ		:= STRTRAN(_cCNPJ,".","")
			_cCNPJ		:= STRTRAN(_cCNPJ,"/","")
			_cCNPJ		:= STRTRAN(_cCNPJ,"-","")
			If Empty(_cCNPJ)
				_lOk := .F.
				Exit
			EndIf
			//**************Informacoes do cliente******************

			dbSelectArea("SA1")
			dbSetOrder(3)//A1_FILIAL, A1_CGC, R_E_C_N_O_, D_E_L_E_T_
			If SA1->(MSSeek(xFilial("SA1")+_cCNPJ))
				_cCodCli 	:= SA1->A1_COD
				_cLjClie 	:= SA1->A1_LOJA
				_cNomeCli2	:= AllTrim(SA1->A1_NOME)
			EndIf

			dbSelectArea(_cOrcTmp1)
			(_cOrcTmp1)->(RecLock(_cOrcTmp1,.T.))
			(_cOrcTmp1)->NORCAM		:= _cNumOrc
			(_cOrcTmp1)->CODCLI		:= _cCodCli
			(_cOrcTmp1)->LOJACLI	:= _cLjClie
			(_cOrcTmp1)->CNPJ		:= _cCNPJ
			(_cOrcTmp1)->NOMECLI	:= Iif(!Empty(_cNomeCli2),_cNomeCli2,_cNomeCli)
			(_cOrcTmp1)->NOMEARQU	:= _cTxtNome
			(_cOrcTmp1)->(MSUnlock())
		ElseIf (_cTpReg=="2")
			_cItem		:= AllTrim(_aDadostxt[2])
			_cGrpSub	:= AllTrim(_aDadostxt[3])
			_cCodInt	:= AllTrim(_aDadostxt[4])
			_cCodGrp	:= AllTrim(_aDadostxt[5])
			_cCodProd 	:= AllTrim(_aDadostxt[6])
			_cDescEsp	:= AllTrim(_aDadostxt[7])
			_nQuant		:= VAL(AllTrim(_aDadostxt[8]))
			_nVlrItem	:= VAL(AllTrim(_aDadostxt[9]))
			_nVlrList	:= VAL(AllTrim(_aDadostxt[14]))

			If Empty(_cCodGrp)
				_lOk := .F.
				Exit
			EndIf
			If (_nQuant==0)
				_lOk := .F.
				Exit
			EndIf
			//**************Itens do Pedido******************
			dbSelectArea(_cOrcTmp2)
			(_cOrcTmp2)->(RecLock(_cOrcTmp2,.T.))
			(_cOrcTmp2)->NORCAM		:= _cNumOrc
			(_cOrcTmp2)->ITEMORC	:= STRZERO(Val(_cItem),_nTamIt)
			(_cOrcTmp2)->GRPSUB		:= _cGrpSub
			(_cOrcTmp2)->CODPROD	:= _cCodProd
			(_cOrcTmp2)->DESCRI		:= _cDescEsp
			(_cOrcTmp2)->CODINTE	:= _cCodInt
			(_cOrcTmp2)->CODAGRP	:= _cCodGrp
			(_cOrcTmp2)->QTDVEN		:= _nQuant
			(_cOrcTmp2)->PRCVEN		:= _nVlrItem
			(_cOrcTmp2)->PRUNIT		:= _nVlrList
			(_cOrcTmp2)->XVALOR		:= (_nVlrItem * _nQuant)
			(_cOrcTmp2)->NOMEARQU	:= _cTxtNome
			(_cOrcTmp2)->(MSUnlock())
		ElseIf (_cTpReg=="3")
			_dDtEmis := STOD(AllTrim(_aDadostxt[2]))
			If Empty(_dDtEmis)
				_lOk := .F.
				Exit
			EndIf
			dbSelectArea(_cOrcTmp1)
			dbSetOrder(1)//NORCAM
			If (_cOrcTmp1)->(dbSeek(_cNumOrc))
				(_cOrcTmp1)->(RecLock(_cOrcTmp1,.F.))
				(_cOrcTmp1)->DTEMIS := _dDtEmis
				(_cOrcTmp1)->(MSUnlock())
			EndIf
		EndIf
		_nLin++
		Ft_fSkip()
	EndDo

	Ft_fuse() //Fecha o arquivo

	If !(_lOk)
		Return(.F.)
	EndIf

	dbSelectArea(_cOrcTmp1)
	If (_cOrcTmp1)->(RecCount())==0
		Return(.F.)
	EndIf

	dbSelectArea(_cOrcTmp2)
	If (_cOrcTmp2)->(RecCount())==0
		Return(.F.)
	EndIf

	FGERACODPA()

	If !FCRIAPROD()
		Return(.F.)
	EndIf

	If !FCRIAPEDV()
		Return(.F.)
	EndIf

	FGRVLOGORC()

	RestArea(_aArea)

Return(.T.)



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FGERACODPA ³ Autor ³ Flavio Valentin           ³ Data ³ 08/02/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que ajusta o codigo do produto acabado para subir a SB1.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FGERACODPA()

	Local _aArea 	:= GetArea()
	Local _cCodPA	:= ""
	Local _cOrcam	:= ""
	Local _cItem	:= ""
	Local _nTamSeq	:= 3

	dbSelectArea(_cOrcTmp1)
	(_cOrcTmp1)->(dbGoTop())
	While (_cOrcTmp1)->(!Eof())
		dbSelectArea(_cOrcTmp2)
		dbSetOrder(1)//NORCAM+ITEMORC
		If (_cOrcTmp2)->(dbSeek((_cOrcTmp1)->NORCAM))
			While (_cOrcTmp2)->(!Eof()) .And. AllTrim((_cOrcTmp2)->NORCAM) == AllTrim((_cOrcTmp1)->NORCAM)
				_cOrcam	:= ""
				_cItem	:= ""
				_cCodPA	:= ""
				_cOrcam	:= AllTrim((_cOrcTmp1)->NORCAM)
				_cItem	:= AllTrim((_cOrcTmp2)->ITEMORC)
				_cCodPA	:= "IC"+AllTrim(SubStr(_cOrcam,3,2))+AllTrim(SubStr(_cOrcam,5,5))+"."+PadL(_cItem,_nTamSeq,"0")
				(_cOrcTmp2)->(RecLock(_cOrcTmp2,.F.))
				(_cOrcTmp2)->CODPA := _cCodPA
				(_cOrcTmp2)->(MSUnlock())
				(_cOrcTmp2)->(dbSkip())
			EndDo
		EndIf
		(_cOrcTmp1)->(dbSkip())
	EndDo

	RestArea(_aArea)

Return



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FCRIAPROD  ³ Autor ³ Flavio Valentin           ³ Data ³ 16/01/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que grava os produtos via execauto.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ _lRet => .T. / .F.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FCRIAPROD()

	Local _aArea		:= GetArea()
	Local _lRet 		:= .F.
	Local _cLocPad 		:= GetNewPar("PR_LOCPAD","05")
	Local _cUM			:= GetNewPar("PR_UNMED","UN")
	Local _aCabSB1		:= {}
	Local _nOpc 		:= 3
	Local _cPosIPI		:= ""
	Local _cTpPrd		:= ""
	Local _cQuery		:= ""
	Local _cAliasQry	:= GetNextAlias()

	_cQuery 	:= " SELECT " + CRLF
	_cQuery 	+= " CABEC.NORCAM " + CRLF
	_cQuery 	+= " ,CABEC.CODCLI " + CRLF
	_cQuery 	+= " ,CABEC.LOJACLI " + CRLF
	_cQuery 	+= " ,CABEC.CNPJ " + CRLF
	_cQuery 	+= " ,CABEC.NOMECLI " + CRLF
	_cQuery 	+= " ,CABEC.DTEMIS " + CRLF
	_cQuery 	+= " ,CABEC.NUMPED " + CRLF
	_cQuery 	+= " ,CABEC.NOMEARQU " + CRLF
	_cQuery 	+= " ,ITEM.GRPSUB " + CRLF
	_cQuery 	+= " ,ITEM.CODINTE " + CRLF
	_cQuery 	+= " ,ITEM.CODAGRP " + CRLF
	_cQuery 	+= " ,ITEM.CODPROD " + CRLF
	_cQuery 	+= " ,ITEM.ITEMORC " + CRLF
	_cQuery 	+= " ,ITEM.CODPA " + CRLF
	_cQuery 	+= " ,ITEM.DESCRI " + CRLF
	_cQuery 	+= " ,ITEM.QTDVEN " + CRLF
	_cQuery 	+= " ,ITEM.PRCVEN " + CRLF
	_cQuery 	+= " ,ITEM.PRUNIT " + CRLF
	_cQuery 	+= " ,ITEM.XVALOR " + CRLF
	_cQuery 	+= " ,ITEM.R_E_C_N_O_ AS RECNOIT " + CRLF
	_cQuery 	+= " FROM " + _oTmpOrc1:GetRealName() + " AS CABEC " + CRLF
	_cQuery 	+= " INNER JOIN " + _oTmpOrc2:GetRealName() + " AS ITEM " + CRLF
	_cQuery 	+= " ON ITEM.NORCAM=CABEC.NORCAM " + CRLF
	_cQuery 	+= " WHERE CABEC.D_E_L_E_T_<>'*' " + CRLF
	_cQuery 	+= " AND ITEM.D_E_L_E_T_<>'*' " + CRLF
	_cQuery 	+= " ORDER BY CABEC.NORCAM, ITEM.ITEMORC "
	_cQuery 	:= ChangeQuery(_cQuery)

	If Select(_cAliasQRY) > 0
		dbSelectArea(_cAliasQRY)
		dbCloseArea()
	EndIf

	MPSysOpenQuery(_cQuery,_cAliasQry)
	TcSetField(_cAliasQry,"DTEMIS","D")
	TcSetField(_cAliasQry,"QTDVEN",TAMSX3("C6_QTDVEN")[3],TAMSX3("C6_QTDVEN")[1],TAMSX3("C6_QTDVEN")[2])
	TcSetField(_cAliasQry,"PRUNIT",TAMSX3("C6_QTDVEN")[3],TAMSX3("C6_PRCVEN")[1],TAMSX3("C6_PRCVEN")[2])
	TcSetField(_cAliasQry,"RECNOIT","N",10,0)

	dbSelectArea(_cAliasQry)
	(_cAliasQry)->(dbGoTop())
	While (_cAliasQry)->(!Eof())

		If !(_lExecJob)
			_oProcess:IncRegua1("... Cadastrando o Produto Acabado: "+AllTrim((_cAliasQry)->CODPA)+" ... ")
		EndIf

		_lRet 		:= .F.
		_aCabSB1 	:= {}
		_cDescProd	:= ""
		dbSelectArea("SB1")
		dbSetOrder(1)//B1_FILIAL, B1_COD, R_E_C_N_O_, D_E_L_E_T_
		If SB1->(dbSeek(xFilial("SB1")+(_cAliasQry)->CODPA))
			_lRet := .T.
		Else
			_cTpPrd 	:= "PA"
			_cPosIPI 	:= "00000000"
			_cDescProd	:= SubStr((_cAliasQry)->DESCRI,8,TAMSX3("B1_DESC")[1])
			//_cDescProd	:= (_cAliasQry)->CODPA
			aAdd(_aCabSB1,{"B1_COD"		,(_cAliasQry)->CODPA	,Nil})
			aAdd(_aCabSB1,{"B1_DESC"	,_cDescProd				,Nil})
			aAdd(_aCabSB1,{"B1_TIPO"	,_cTpPrd				,Nil})
			aAdd(_aCabSB1,{"B1_UM"		,_cUM					,Nil})
			aAdd(_aCabSB1,{"B1_LOCPAD"	,_cLocPad				,Nil})
			aAdd(_aCabSB1,{"B1_POSIPI"	,_cPosIPI				,Nil})
			aAdd(_aCabSB1,{"B1_ORIGEM"	,"0"					,Nil})
		EndIf

		If (Len(_aCabSB1) > 0)
			_lRet 		:= .T.
			_cExibeErr	:= ""
			lMsErroAuto := .F.
			_nOpc 		:= 3
			MSExecAuto({|x,y| MATA010(x,y)},_aCabSB1,_nOpc) //Inclusao
			If (lMsErroAuto)
				DisarmTransaction()
				If !(_lExecJob)
					//--MostraErro()
					_cExibeErr := AllTrim(FERRAUTO())
					_lRet := .F.
					Exit
				EndIf
			EndIf
		EndIf
		(_cAliasQry)->(dbSkip())
	EndDo

	RestArea(_aArea)

Return(_lRet)



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FCRIAPEDV  ³ Autor ³ Flavio Valentin           ³ Data ³ 22/01/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que grava Pedido de Venda via execauto.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ _lRet => .T. / .F.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FCRIAPEDV()

	Local _aArea		:= GetArea()
	Local _lRet 		:= .F.
	Local _cAlmox		:= GetNewPar("PR_ALMPV","01")
	Local _cCond		:= GetNewPar("PR_CONDPG","002")
	//Local _cTransp		:= GetNewPar("PR_TRANPV","000001")
	Local _cTES			:= GetNewPar("PR_TESPV","779")
	//Local _cNaturez		:= GetNewPar("PR_NATURPV","1120101")
	Local _aCab			:= {}
	Local _cItem		:= ""
	Local _aLinha		:= {}
	Local _aItens		:= {}
	Local _nBkpMod		:= 0
	Local _nQtde		:= 0
	Local _nPrcVend 	:= 0
	Local _nPrcUnit 	:= 0
	Local _nVlrTot		:= 0
	Local _cAliasQry	:= GetNextAlias()
	Local _cAliaQry2	:= GetNextAlias()
	Local _cQuery		:= ""

	//Faz o backup do modulo atual
	_nBkpMod := nModulo

	_cQuery 	:= " SELECT " + CRLF
	_cQuery 	+= " CABEC.NORCAM " + CRLF
	_cQuery 	+= " ,CABEC.CODCLI " + CRLF
	_cQuery 	+= " ,CABEC.LOJACLI " + CRLF
	_cQuery 	+= " ,CABEC.CNPJ " + CRLF
	_cQuery 	+= " ,CABEC.NOMECLI " + CRLF
	_cQuery 	+= " ,CABEC.DTEMIS " + CRLF
	_cQuery 	+= " ,CABEC.NUMPED " + CRLF
	_cQuery 	+= " ,CABEC.NOMEARQU " + CRLF
	_cQuery 	+= " FROM " + _oTmpOrc1:GetRealName() + " AS CABEC " + CRLF
	_cQuery 	+= " WHERE CABEC.D_E_L_E_T_<>'*' " + CRLF
	_cQuery 	+= " ORDER BY CABEC.NORCAM "
	_cQuery 	:= ChangeQuery(_cQuery)

	If Select(_cAliasQRY) > 0
		dbSelectArea(_cAliasQRY)
		dbCloseArea()
	EndIf

	MPSysOpenQuery(_cQuery,_cAliasQry)
	TcSetField(_cAliasQry,"DTEMIS","D")

	dbSelectArea(_cAliasQRY)
	(_cAliasQRY)->(dbGoTop())
	While (_cAliasQRY)->(!Eof())

		If !(_lExecJob)
			//_oProcess:IncRegua1("Criando o Pedido de Venda... ") //+AllTrim((_cAliasQRY)->NORCAM)+" ...")
			_oProcess:IncRegua1("Criando o Orçamento... ") //+AllTrim((_cAliasQRY)->NORCAM)+" ...")
		EndIf

		_aCab 	:= {}
		_aItens	:= {}
		_aLinha := {}

		If FVLDORCAM((_cAliasQRY)->NORCAM)
			(_cAliasQRY)->(dbSkip())
			Loop
		EndIf

		//aAdd(_aCab,{"C5_TIPO" 		,"N"					,Nil})
		//aAdd(_aCab,{"C5_CLIENTE"	,(_cAliasQRY)->CODCLI	,Nil})
		//aAdd(_aCab,{"C5_LOJACLI"	,(_cAliasQRY)->LOJACLI	,Nil})
		//aAdd(_aCab,{"C5_LOJAENT"	,(_cAliasQRY)->LOJACLI	,Nil})
		//If !Empty(_cTransp)
		//aAdd(_aCab,{"C5_TRANSP"	,_cTransp				,Nil})
		//EndIf
		//aAdd(_aCab,{"C5_CONDPAG"	,_cCond					,Nil})
		//aAdd(_aCab,{"C5_EMISSAO"	,Iif(!Empty((_cAliasQRY)->DTEMIS),(_cAliasQRY)->DTEMIS,ddatabase),Nil})
		//If !Empty(_cNaturez)
		//aAdd(_aCab,{"C5_NATUREZ",_cNaturez				,Nil})
		//EndIf
		//aAdd(_aCab,{"C5__ORCWBC"	,(_cAliasQRY)->NORCAM	,Nil}) //22.01.2019 - Verificar se deve criar este campo no PV


		aadd(_aCab,{"CJ_EMISSAO"	,Iif(!Empty((_cAliasQRY)->DTEMIS),(_cAliasQRY)->DTEMIS,ddatabase)					,Nil})
		aadd(_aCab,{"CJ_CLIENTE"	,(_cAliasQRY)->CODCLI	,Nil})
		aadd(_aCab,{"CJ_LOJA"		,(_cAliasQRY)->LOJACLI	,Nil})
		aadd(_aCab,{"CJ_CLIENT"		,(_cAliasQRY)->CODCLI	,Nil})
		aadd(_aCab,{"CJ_LOJAENT"	,(_cAliasQRY)->LOJACLI	,Nil})
		aadd(_aCab,{"CJ_CONDPAG"	,_cCond					,Nil})
		aadd(_aCab,{"CJ_XVENDED"	,"000001"				,Nil})
		aadd(_aCab,{"CJ_XSEGMEN"	,"1"					,Nil})
		aadd(_aCab,{"CJ_COTCLI"		,(_cAliasQRY)->NORCAM	,Nil})
		aadd(_aCab,{"CJ__ORCWBC"	,(_cAliasQRY)->NORCAM	,Nil})

		_cQuery 	:= ""
		_cQuery 	:= " SELECT " + CRLF
		_cQuery 	+= " ITEM.ITEMORC " + CRLF
		_cQuery 	+= " ,ITEM.GRPSUB " + CRLF
		_cQuery 	+= " ,ITEM.CODINTE " + CRLF
		_cQuery 	+= " ,ITEM.CODAGRP " + CRLF
		_cQuery 	+= " ,ITEM.CODPROD " + CRLF
		_cQuery 	+= " ,ITEM.CODPA " + CRLF
		_cQuery 	+= " ,ITEM.DESCRI " + CRLF
		_cQuery 	+= " ,ITEM.QTDVEN " + CRLF
		_cQuery 	+= " ,ITEM.PRCVEN " + CRLF
		_cQuery 	+= " ,ITEM.PRUNIT " + CRLF
		_cQuery 	+= " ,ITEM.XVALOR " + CRLF
		_cQuery 	+= " ,ITEM.R_E_C_N_O_ AS RECNOIT " + CRLF
		_cQuery 	+= " FROM " + _oTmpOrc1:GetRealName() + " AS CABEC " + CRLF
		_cQuery 	+= " INNER JOIN " + _oTmpOrc2:GetRealName() + " AS ITEM " + CRLF
		_cQuery 	+= " ON ITEM.NORCAM=CABEC.NORCAM " + CRLF
		_cQuery 	+= " WHERE CABEC.D_E_L_E_T_<>'*' " + CRLF
		_cQuery 	+= " AND ITEM.D_E_L_E_T_<>'*' " + CRLF
		_cQuery 	+= " AND CABEC.NORCAM='"+(_cAliasQRY)->NORCAM+"' " + CRLF
		_cQuery 	+= " ORDER BY ITEM.ITEMORC "
		_cQuery 	:= ChangeQuery(_cQuery)

		If Select(_cAliaQry2) > 0
			dbSelectArea(_cAliaQry2)
			dbCloseArea()
		EndIf

		MPSysOpenQuery(_cQuery,_cAliaQry2)
		TcSetField(_cAliaQry2,"QTDVEN",TAMSX3("CK_QTDVEN")[3],TAMSX3("CK_QTDVEN")[1],TAMSX3("CK_QTDVEN")[2])
		TcSetField(_cAliaQry2,"PRUNIT",TAMSX3("CK_PRCVEN")[3],TAMSX3("CK_PRCVEN")[1],TAMSX3("CK_PRCVEN")[2])
		TcSetField(_cAliaQry2,"RECNOIT","N",10,0)

		dbSelectArea(_cAliaQry2)
		(_cAliaQry2)->(dbGoTop())
		While (_cAliaQry2)->(!Eof())
			_cItem		:= ""
			_nQtde		:= 0
			_nPrcVend 	:= 0
			_nPrcUnit 	:= 0
			_nVlrTot	:= 0
			//_cItem		:= STRZERO(Val((_cAliaQry2)->ITEMORC),TAMSX3("C6_ITEM")[1])
			_cItem		:= STRZERO(Val((_cAliaQry2)->ITEMORC),TAMSX3("CK_ITEM")[1])
			_nQtde		:= Iif((_cAliaQry2)->QTDVEN<>0,(_cAliaQry2)->QTDVEN,1)
			_nPrcVend	:= Iif((_cAliaQry2)->PRCVEN<>0,(_cAliaQry2)->PRCVEN,FGETPRC((_cAliaQry2)->CODPROD))
			_nPrcUnit 	:= Iif((_cAliaQry2)->PRUNIT<>0,(_cAliaQry2)->PRUNIT,_nPrcVend)
			_nPrcUnit	:= Iif(_nPrcUnit > _nPrcUnit,_nPrcUnit,1)
			_nVlrTot	:= Iif((_cAliaQry2)->XVALOR<>0,(_cAliaQry2)->XVALOR,(_nPrcVend*_nQtde))
			_aLinha 	:= {}

			//aAdd(_aLinha,{"C6_ITEM"    	,_cItem													,Nil})
			//aAdd(_aLinha,{"C6_PRODUTO"	,(_cAliaQry2)->CODPA									,Nil})
			//aAdd(_aLinha,{"C6_QTDVEN"  	,_nQtde													,Nil})
			//aAdd(_aLinha,{"C6_PRCVEN"  	,_nPrcVend												,Nil})
			//aAdd(_aLinha,{"C6_VALOR"  	,_nVlrTot												,Nil})
			//aAdd(_aLinha,{"C6_TES"    	,_cTES       											,Nil})
			//aAdd(_aLinha,{"C6_LOCAL"   	,_cAlmox	    										,Nil})
			//aAdd(_aLinha,{"C6_DESCRI"	,SubStr((_cAliaQry2)->DESCRI,8,TAMSX3("B1_DESC")[1])	,Nil})
			//aAdd(_aLinha,{"C6_PRUNIT"	,_nPrcUnit												,Nil})

			aadd(_aLinha,{"CK_ITEM"		,_cItem													,Nil})
			aadd(_aLinha,{"CK_PRODUTO"	,(_cAliaQry2)->CODPA									,Nil})
			aadd(_aLinha,{"CK_DESCRI"	,SubStr((_cAliaQry2)->DESCRI,8,TAMSX3("B1_DESC")[1])	,Nil})
			aadd(_aLinha,{"CK_QTDVEN"	,_nQtde													,Nil})
			aadd(_aLinha,{"CK_PRCVEN"	,_nPrcVend												,Nil})
			aadd(_aLinha,{"CK_VALOR"	,_nVlrTot												,Nil})
			aadd(_aLinha,{"CK_TES"		,_cTES													,Nil})
			aadd(_aLinha,{"CK_LOCAL"	,_cAlmox												,Nil})
			aadd(_aLinha,{"CK_PRUNIT"	,_nPrcUnit												,Nil})

			aAdd(_aItens, _aLinha)

			_aSavATU := GetArea()
			dbSelectArea("SB2")
			dbSetOrder(1)
			If !MSSeek(xFilial("SB2")+PadR((_cAliaQry2)->CODPA,TamSx3("B1_COD")[1])+_cAlmox)
				CriaSB2((_cAliaQry2)->CODPA,_cAlmox)
			EndIf
			RestArea(_aSavATU)

			(_cAliaQry2)->(dbSkip())
		EndDo
		If Len(_aCab) > 0 .And. Len(_aItens) > 0
			_cExibeErr 	:= ""
			nModulo 	:= 05 //Posiciona no modulo Faturamento
			lMsErroAuto	:= .F.
			//MSExecAuto({|x,y,z|Mata410(x,y,z)},_aCab,_aItens,3)

			MATA415(_aCab,_aItens,3)

			If (lMsErroAuto)
				If !(_lExecJob)
					//MostraErro()
					_cExibeErr := AllTrim(FERRAUTO())
					Exit
				EndIf
				_lRet := .F.
			Else
				_lRet := .T.
				//FGRVPED((_cAliasQRY)->NORCAM, SC5->C5_NUM)
				FGRVPED((_cAliasQRY)->NORCAM, SCJ->CJ_NUM)
				If !(_lExecJob)
					//MsgInfo("Pedido "+SC5->C5_NUM+" incluído com sucesso!")
					MsgInfo("Orçamento "+SCJ->CJ_NUM+" incluído com sucesso!")
				EndIf

			EndIf
			nModulo := _nBkpMod //Restaura o modulo
		EndIf
		(_cAliasQRY)->(dbSkip())
	EndDo

	RestArea(_aArea)

Return(_lRet)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FGETPRC    ³ Autor ³ Flavio Valentin           ³ Data ³ 30/01/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que busca o preco do produto na tabela de preco.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ _cCodPro => Codigo do Produto.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ _nRet => Preco encontrado na tabela de preco.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FGETPRC(_cCodPro)

	Local _aArea		:= GetArea()
	Local _cQuery		:= ""
	Local _cAliasQRY	:= ""
	Local _nRet 		:= 0

	_cAliasQRY	:= GetNextAlias()
	_cQuery 	:= "SELECT " + CRLF
	_cQuery 	+= "DA0.DA0_FILIAL " + CRLF
	_cQuery 	+= ",DA0.DA0_CODTAB " + CRLF
	_cQuery 	+= ",DA1.DA1_ITEM " + CRLF
	_cQuery 	+= ",DA1.DA1_CODPRO " + CRLF
	_cQuery 	+= ",DA1.DA1_PRCVEN " + CRLF
	_cQuery 	+= "FROM "+RetSqlName("DA1")+" DA1 (NOLOCK) " + CRLF
	_cQuery 	+= "INNER JOIN "+RetSqlName("DA0")+" DA0 (NOLOCK) " + CRLF
	_cQuery 	+= "ON DA0.DA0_FILIAL=DA1.DA1_FILIAL " + CRLF
	_cQuery 	+= "AND DA0.DA0_CODTAB=DA1.DA1_CODTAB " + CRLF
	_cQuery 	+= "AND DA0.D_E_L_E_T_='' " + CRLF
	_cQuery 	+= "WHERE " + CRLF
	_cQuery 	+= "DA1.DA1_FILIAL='"+xFilial("DA1")+"' " + CRLF
	_cQuery 	+= "AND DA1.DA1_CODPRO='"+_cCodPro+"' " + CRLF
	_cQuery 	+= "AND DA1.DA1_PRCVEN<>0 " + CRLF
	_cQuery 	+= "AND DA1.D_E_L_E_T_='' " + CRLF

	If Select(_cAliasQRY) > 0
		dbSelectArea(_cAliasQRY)
		dbCloseArea()
	EndIf

	_cQuery := ChangeQuery(_cQuery)

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,,_cQuery),_cAliasQRY,.T.,.T.)
	TcSetField(_cAliasQRY,"DA1_PRCVEN",TAMSX3("DA1_PRCVEN")[3],TAMSX3("DA1_PRCVEN")[1],TAMSX3("DA1_PRCVEN")[2])

	dbSelectArea(_cAliasQRY)
	If !(_cAliasQRY)->(Eof()) .And. !(_cAliasQRY)->(Bof())
		_nRet := (_cAliasQRY)->DA1_PRCVEN
	EndIf

	If (_nRet==0)
		dbSelectArea("SB1")
		dbSetOrder(1)//B1_FILIAL, B1_COD, R_E_C_N_O_, D_E_L_E_T_
		If SB1->(MSSeek(xFilial("SB1")+PadR(AllTrim(_cCodPro),TAMSX3("B1_COD")[1])))
			If (SB1->B1_PRV1 <> 0)
				_nRet := SB1->B1_PRV1
			ElseIf (SB1->B1_UPRC <> 0)
				_nRet := SB1->B1_UPRC
			Else
				_nRet := 1
			EndIf
		EndIf
	EndIf

	RestArea(_aArea)

Return(_nRet)



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FVLDORCAM  ³ Autor ³ Flavio Valentin           ³ Data ³ 30/01/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que verifica se o Orcamento ja fora incluido anteriormente³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ _cNumOrca => Numero do Orcamento.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ _lRet => .T. / .F.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FVLDORCAM(_cNumOrca)

	Local _aArea		:= GetArea()
	Local _lRet 		:= .F.
	Local _cQuery		:= ""
	Local _cAliasQRY	:= ""

	If Empty(_cNumOrca)
		Return(.F.)
	EndIf

	_cAliasQRY	:= GetNextAlias()
	/*
_cQuery 	:= " SELECT " + CRLF
_cQuery 	+= " COUNT(*) AS QTDREG " + CRLF
_cQuery 	+= " FROM "+RetSqlName("SC5")+" (NOLOCK) " + CRLF
_cQuery 	+= " WHERE " + CRLF
_cQuery 	+= " C5_FILIAL='"+xFilial("SC5")+"' " + CRLF
_cQuery 	+= " AND C5__ORCWBC='"+_cNumOrca+"' " + CRLF
_cQuery 	+= " AND D_E_L_E_T_='' " + CRLF
	*/

	_cQuery 	:= " SELECT " + CRLF
	_cQuery 	+= " COUNT(*) AS QTDREG " + CRLF
	_cQuery 	+= " FROM "+RetSqlName("SCJ")+" (NOLOCK) " + CRLF
	_cQuery 	+= " WHERE " + CRLF
	_cQuery 	+= " CJ_FILIAL='"+xFilial("SCJ")+"' " + CRLF
	_cQuery 	+= " AND CJ__ORCWBC='"+_cNumOrca+"' " + CRLF
	_cQuery 	+= " AND D_E_L_E_T_='' " + CRLF

	If Select(_cAliasQRY) > 0
		dbSelectArea(_cAliasQRY)
		dbCloseArea()
	EndIf

	_cQuery := ChangeQuery(_cQuery)
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,,_cQuery),_cAliasQRY,.T.,.T.)

	dbSelectArea(_cAliasQRY)
	If !(_cAliasQRY)->(Eof()) .And. !(_cAliasQRY)->(Bof())
		If ((_cAliasQRY)->QTDREG<>0)
			_lRet := .T.
		EndIf
	EndIf

	RestArea(_aArea)

Return(_lRet)



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    | FARQTEMP  ³ Autor ³ Flavio Valentin       ³ Data ³ 22/01/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria a tabela temporaria.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³              |        ³                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FARQTEMP()

	Local _aStruOrc1 	:= {}
	Local _aStruOrc2 	:= {}
	Local _nTamIt		:= 2 //TAMSX3("C6_ITEM")[1]

	If (_oTmpOrc1 <> Nil)
		_oTmpOrc1:Delete()
		_oTmpOrc1 := Nil
	Endif

	//------------------------------------------------
	//Criacao do objeto
	//------------------------------------------------
	_oTmpOrc1 := FWTemporaryTable():New(_cOrcTmp1)

	//---------------------------------------------------------------------------------------
	//Monta os campos da tabela temporaria do cabecalho do orcamento - Pedido de Venda
	//---------------------------------------------------------------------------------------
	//Array com estrutura da tabela temporaria
	//Campo, tipo, tamanho, decimal
	aAdd(_aStruOrc1,{"NORCAM"	,"C"					,10						,0						})
	aAdd(_aStruOrc1,{"CODCLI"	,TAMSX3("A1_COD")[3]	,TAMSX3("A1_COD")[1] 	,TAMSX3("A1_COD")[2]	})
	aAdd(_aStruOrc1,{"LOJACLI"	,TAMSX3("A1_LOJA")[3] 	,TAMSX3("A1_LOJA")[1] 	,TAMSX3("A1_LOJA")[2] 	})
	aAdd(_aStruOrc1,{"CNPJ"		,TAMSX3("A1_CGC")[3] 	,TAMSX3("A1_CGC")[1] 	,TAMSX3("A1_CGC")[2] 	})
	aAdd(_aStruOrc1,{"NOMECLI"	,TAMSX3("A1_NOME")[3] 	,TAMSX3("A1_NOME")[1] 	,TAMSX3("A1_NOME")[2] 	})
	aAdd(_aStruOrc1,{"DTEMIS" 	,TAMSX3("C5_EMISSAO")[3],TAMSX3("C5_EMISSAO")[1],TAMSX3("C5_EMISSAO")[2]})
	aAdd(_aStruOrc1,{"NUMPED"	,TAMSX3("C5_NUM")[3]	,TAMSX3("C5_NUM")[1] 	,TAMSX3("C5_NUM")[2]	})
	aAdd(_aStruOrc1,{"NOMEARQU"	,"C"					,30						,0						})

	_oTmpOrc1:SetFields(_aStruOrc1)
	_oTmpOrc1:AddIndex("01",{"NORCAM"})

	//---------------------------------------------------------------------------------------
	//Monta os campos da tabela temporaria dos itens do orcamento - Pedido de Venda
	//---------------------------------------------------------------------------------------
	_oTmpOrc1:Create()

	Conout("Tabela Temporaria Cabecalho Orcamento "+_oTmpOrc1:GetRealName())

	If (_oTmpOrc2 <> Nil)
		_oTmpOrc2:Delete()
		_oTmpOrc2 := Nil
	Endif

	//------------------------------------------------
	//Criacao do objeto
	//------------------------------------------------
	_oTmpOrc2 := FWTemporaryTable():New(_cOrcTmp2)

	//----------------------------------------
	//Monta os campos da tabela
	//-----------------------------------------
	aAdd(_aStruOrc2,{"NORCAM"	,"C"					,10						,0						})
	aAdd(_aStruOrc2,{"ITEMORC"	,"C"					,_nTamIt 				,0						})
	aAdd(_aStruOrc2,{"GRPSUB"	,"C"					,4						,0						})
	aAdd(_aStruOrc2,{"CODINTE"	,"C"					,6						,0						})
	aAdd(_aStruOrc2,{"CODAGRP"	,"C"					,15						,0						})
	aAdd(_aStruOrc2,{"CODPROD"	,"C"					,7						,0						})
	aAdd(_aStruOrc2,{"CODPA"	,TAMSX3("B1_COD")[3] 	,TAMSX3("B1_COD")[1] 	,TAMSX3("B1_COD")[2]	})
	aAdd(_aStruOrc2,{"DESCRI"	,"C"					,80						,0						})
	aAdd(_aStruOrc2,{"QTDVEN"	,TAMSX3("C6_QTDVEN")[3] ,TAMSX3("C6_QTDVEN")[1] ,TAMSX3("C6_QTDVEN")[2]	})
	aAdd(_aStruOrc2,{"PRCVEN"	,TAMSX3("C6_PRCVEN")[3] ,TAMSX3("C6_PRCVEN")[1] ,TAMSX3("C6_PRCVEN")[2]	})
	aAdd(_aStruOrc2,{"PRUNIT"	,TAMSX3("C6_PRUNIT")[3] ,TAMSX3("C6_PRUNIT")[1] ,TAMSX3("C6_PRUNIT")[2]	})
	aAdd(_aStruOrc2,{"XVALOR"	,TAMSX3("C6_VALOR")[3] 	,TAMSX3("C6_VALOR")[1] 	,TAMSX3("C6_VALOR")[2]	})
	aAdd(_aStruOrc2,{"NOMEARQU"	,"C"					,30						,0						})

	_oTmpOrc2:SetFields(_aStruOrc2)
	_oTmpOrc2:AddIndex("01",{"NORCAM","ITEMORC"})

	//--------------------
	//Criacao da tabela
	//--------------------
	_oTmpOrc2:Create()

	Conout("Tabela Temporaria Item Orcamento "+_oTmpOrc2:GetRealName())

Return(Nil)



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FGRVPED    ³ Autor ³ Flavio Valentin           ³ Data ³ 08/02/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para gravar o numero do pedido de venda no log.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ _cOrcam => Numero do Orcamento; _cPedVend => Numero do Pedido.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FGRVPED(_cOrcam, _cPedVend)

	Local _cScript := ""
	Local _nRet		:= 0

	_cScript 	:= " UPDATE " + _oTmpOrc1:GetRealName() + " SET NUMPED='"+_cPedVend+"' "
	_cScript 	+= " WHERE D_E_L_E_T_<>'*' "
	_cScript 	+= " AND NORCAM='"+_cOrcam+"' "
	_nRet 		:= TCSQLExec(_cScript)

/* COMENTADO VINICIUS
_cScript	:= ""
_nRet		:= 0
_cScript 	:= " UPDATE "+RetSqlName("SC5")+" SET C5_TRANSP='',C5_CONDPAG='',C5_NATUREZ='' "
_cScript 	+= " WHERE "
_cScript 	+= " C5_FILIAL='"+xFilial("SC5")+"' "
_cScript 	+= " AND C5__ORCWBC='"+_cOrcam+"' "
_cScript 	+= " AND D_E_L_E_T_<>'*' "
_nRet 		:= TCSQLExec(_cScript)

_cScript 	:= ""
_nRet		:= 0
_cScript 	:= " UPDATE "+RetSqlName("SC6")+" SET C6_TES='' "
_cScript 	+= " FROM "+RetSqlName("SC6")+" SC6 "
_cScript 	+= " INNER JOIN "+RetSqlName("SC5")+" SC5 ON SC5.C5_FILIAL=SC6.C6_FILIAL AND SC5.C5_NUM=SC6.C6_NUM AND SC6.D_E_L_E_T_='' "
_cScript 	+= " WHERE "
_cScript 	+= " SC5.C5_FILIAL='"+xFilial("SC5")+"' "
_cScript 	+= " AND SC5.C5__ORCWBC='"+_cOrcam+"' "
_cScript 	+= " AND SC5.D_E_L_E_T_<>'*' "
_nRet 		:= TCSQLExec(_cScript)
	*/
Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FGRVLOGORC ³ Autor ³ Flavio Valentin           ³ Data ³ 08/02/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que grava o log do Orcamento para geracao do ped. venda.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FGRVLOGORC()

	Local _aArea		:= GetArea()
	Local _cQuery		:= ""
	Local _cAliasQry	:= ""

	_cAliasQry	:= GetNextAlias()
	_cQuery 	:= " SELECT " + CRLF
	_cQuery 	+= " CABEC.NORCAM " + CRLF
	_cQuery 	+= " ,CABEC.CODCLI " + CRLF
	_cQuery 	+= " ,CABEC.LOJACLI " + CRLF
	_cQuery 	+= " ,CABEC.CNPJ " + CRLF
	_cQuery 	+= " ,CABEC.NOMECLI " + CRLF
	_cQuery 	+= " ,CABEC.DTEMIS " + CRLF
	_cQuery 	+= " ,CABEC.NUMPED " + CRLF
	_cQuery 	+= " ,CABEC.NOMEARQU " + CRLF
	_cQuery 	+= " ,ITEM.ITEMORC " + CRLF
	_cQuery 	+= " ,ITEM.GRPSUB " + CRLF
	_cQuery 	+= " ,ITEM.CODINTE " + CRLF
	_cQuery 	+= " ,ITEM.CODAGRP " + CRLF
	_cQuery 	+= " ,ITEM.CODPROD " + CRLF
	_cQuery 	+= " ,ITEM.CODPA " + CRLF
	_cQuery 	+= " ,ITEM.DESCRI " + CRLF
	_cQuery 	+= " ,ITEM.QTDVEN " + CRLF
	_cQuery 	+= " ,ITEM.PRCVEN " + CRLF
	_cQuery 	+= " ,ITEM.PRUNIT " + CRLF
	_cQuery 	+= " ,ITEM.XVALOR " + CRLF
	_cQuery 	+= " FROM " + _oTmpOrc1:GetRealName() + " AS CABEC " + CRLF
	_cQuery 	+= " INNER JOIN " + _oTmpOrc2:GetRealName() + " AS ITEM " + CRLF
	_cQuery 	+= " ON ITEM.NORCAM=CABEC.NORCAM " + CRLF
	_cQuery 	+= " WHERE CABEC.D_E_L_E_T_<>'*' " + CRLF
	_cQuery 	+= " AND ITEM.D_E_L_E_T_<>'*' " + CRLF
	_cQuery 	+= " ORDER BY CABEC.NORCAM, ITEM.ITEMORC "
	_cQuery 	:= ChangeQuery(_cQuery)

	If Select(_cAliasQRY) > 0
		dbSelectArea(_cAliasQRY)
		dbCloseArea()
	EndIf

	MPSysOpenQuery(_cQuery,_cAliasQry)
	TcSetField(_cAliasQry,"DTEMIS","D")
	TcSetField(_cAliasQry,"QTDVEN",TAMSX3("C6_QTDVEN")[3],TAMSX3("C6_QTDVEN")[1],TAMSX3("C6_QTDVEN")[2])
	TcSetField(_cAliasQry,"PRUNIT",TAMSX3("C6_QTDVEN")[3],TAMSX3("C6_PRCVEN")[1],TAMSX3("C6_PRCVEN")[2])

	dbSelectArea(_cAliasQry)
	(_cAliasQry)->(dbGoTop())
	While (_cAliasQry)->(!Eof())

		If !(_lExecJob)
			_oProcess:IncRegua1("Gravando o log do Orçamento na tabela SZ4")
		EndIf

		dbSelectArea("SZ4")
		SZ4->(RecLock("SZ4",.T.))
		SZ4->Z4_FILIAL 	:= xFilial("SZ4")
		SZ4->Z4_NUMORC	:= (_cAliasQry)->NORCAM
		SZ4->Z4_CNPJ    := (_cAliasQry)->CNPJ
		SZ4->Z4_NOME    := (_cAliasQry)->NOMECLI
		SZ4->Z4_ITEMORC := (_cAliasQry)->ITEMORC
		SZ4->Z4_GRPSUB  := (_cAliasQry)->GRPSUB
		SZ4->Z4_CODINTE := (_cAliasQry)->CODINTE
		SZ4->Z4_CODAGRP := (_cAliasQry)->CODAGRP
		SZ4->Z4_CODPRD  := (_cAliasQry)->CODPROD
		SZ4->Z4_DESCPRD := (_cAliasQry)->DESCRI
		SZ4->Z4_QUANT   := (_cAliasQry)->QTDVEN
		SZ4->Z4_VALOR   := (_cAliasQry)->PRUNIT
		SZ4->Z4_CODPA   := (_cAliasQry)->CODPA
		SZ4->Z4_DTEMISS := (_cAliasQry)->DTEMIS
		SZ4->Z4_NUMPED	:= (_cAliasQry)->NUMPED
		SZ4->Z4_ARQUIVO := (_cAliasQry)->NOMEARQU
		SZ4->Z4_DTIMP 	:= ddatabase
		SZ4->Z4_HORA 	:= Left(Time(),5)
		SZ4->Z4_USUARIO := cUserName
		SZ4->(MSUnlock())
		(_cAliasQry)->(dbskip())
	EndDo

	RestArea(_aArea)

Return



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FERRAUTO   ³ Autor ³ Flavio Valentin           ³ Data ³ 08/02/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que exibe o erro retornado pelo MSExecAuto.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ _cMens => Mensagem do MSExecAuto.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FERRAUTO()

	Local _cMens   		:= ""
	Local _cArq	   		:= "ErrImport_"+AllTrim(StrTran(Str(Seconds()),".","_"))+".log"
	Local _cStartPat	:= CURDIR()

	MostraErro(_cStartPat, _cArq)
	_cMens := MemoRead(_cStartPat + _cArq)
	_cMens := StrTran(_cMens,"<","")
	_cMens := StrTran(_cMens,CRLF,"")

	FErase(_cStartPat + _cArq)

Return(_cMens)
