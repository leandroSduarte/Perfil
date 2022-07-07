#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"
#Include "RWMAKE.CH"
#Include "TbiConn.ch"


User Function PERJOB03()

	//Preparar o Ambiente
	Prepare Environment Empresa "01" Filial "0101"

	conout("----------------------------------------------------------------------")
	conout("- Importa arquivo de estrutura integracao WBC CAD - INICIO : "+Time())
	conout("----------------------------------------------------------------------")

	U_PERFIMPEST(.T.)

	conout("-----------------------------------------------------------------")
	conout("- Importa arquivo de estrutura integracao WBC CAD - FIM : "+Time())
	conout("-----------------------------------------------------------------")

	Reset Environment

Return Nil



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PERFIMPEST ³ Autor ³ Flavio Valentin           ³ Data ³ 16/01/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa que gera a importacao da estrutura do produto.          ³±±
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
User Function PERFIMPEST(_lJob)
	Local lEnd			:= .F.
	Local _aArea		:= GetArea()
	//Local _cStartPat	:= CURDIR() // \System\
	//Local _cExtTemp		:= GetDBExtension()
	Local _lOk			:= .F.
	Private _lExecJob	:= Iif(ValType(_lJob)<>"L",.F.,_lJob) //.T. = Chamada originou de um Schedule do Protheus
	Private _cEstTmp1	:= GetNextAlias()
	Private _cEstTmp2	:= GetNextAlias()
	Private _oTmpEst1	:= Nil
	Private _oTmpEst2	:= Nil
	Private _cServFTP	:= GetNewPar("PR_FTPSRV2","192.168.3.18") //Server FTP
	Private _nPortFTP	:= GetNewPar("PR_FTPPOR2",21) //Port FTP
	Private _cUserFTP	:= GetNewPar("PR_FTPUSR2","teste") //Login FTP
	Private _cSenhFTP	:= GetNewPar("PR_FTPSEN2","tst") //Password FTP
	Private _cPastFTP	:= GetNewPar("PR_FTPPAS2","/teste/") //Pasta FTP
	Private _cMarkArq	:= GetNewPar("PR_FTPMSK2","arq*.txt") //Para filtrar os arquivos
	Private _cDirTXT  	:= GetNewpar("PR_WBCPAS2","\INTEG-WBCCAD\")
	//Private _cDirTXT2 	:= "ESTRPROD\"
	Private _cDirTXT2 	:= "PENDENTE\"
	//Private _cDirDest  	:= "PENDENTE\"
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
		_oProcess := MsNewProcess():New( { | lEnd | _lOk := FGETXTDIR(@lEnd)}, "Importacao do TXT Estruturas do PA", "Aguarde...", .F.)
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

/*
//Verifica se existe arquivo txt da estrutura no FTP e importa para a pasta do protheus
FTPDisconnect()
If FTPConnect(_cServFTP, _nPortFTP, _cUserFTP, _cSenhFTP)
 	If FTPDirChange(_cPastFTP)
  		_aDirFtp := FTPDIRECTORY(_cMarkArq,)
  		_nTamArr := Len(_aDirFtp)
  		If (_nTamArr > 0)
	  		For _nIni := 1 To _nTamArr
	  	  		If FTPDownLoad(_cDirTXT + _cDirTXT2 + _cDirDest+_aDirFtp[_nIni][1],_aDirFtp[_nIni][1])
					If File(_cDirTXT + _cDirTXT2 + _cDirDest+_aDirFtp[_nIni][1])
						Conout("Download de Arquivos .TXT - PERFIMPEST")
						If (FTPErase(_aDirFtp[_nIni][1]))
							Conout("O arquivo ["+_aDirFtp[_nIni][1]+"] foi excluido com sucesso do FTP - PERFIMPEST")
						Else
							Conout("Não foi possível excluir o arquivo ["+_aDirFtp[_nIni][1]+"] do FTP - PERFIMPEST")
						EndIf
					Else
						Conout("O arquivo "+AllTrim(_aDirFtp[_nIni][1])+ " não foi copiado para o diretório "+AllTrim(_cDirTXT + _cDirTXT2 + _cDirDest)+" - PERFIMPEST")
						FTPDisconnect()
	  	  				_lRet := .F.
					EndIf
				Else
	  	  			Conout("Arquivo .TXT - Erro na copia dos arquivos no FTP - PERFIMPEST")
	  	  		EndIf
	  	  	Next _nIni
  		Else
  			Conout(".TXT nao encontrados na pasta "+AllTrim(_cPastFTP)+" - PERFIMPEST")
  	  		FTPDisconnect()
  	  		_lRet := .F.
  		EndIf
  	Else
  		Conout("Diretorio inexistente no FTP - PERFIMPEST")
  	  	FTPDisconnect()
  	  	_lRet := .F.
  	EndIf
  	FTPDisconnect()
Else
	Conout("Erro ao Conectar no FTP - PERFIMPEST")
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

	FARQTEMP()//Cria as tabelas temporarias que serao utilizadas

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

	//_aDiret		:= Directory(_cDirTXT + _cDirTXT2 + _cDirDest + "*.###") //Pega os arquivos .TXT existentes na pasta
	_aDiret		:= Directory(_cDirTXT + _cDirTXT2 + "*_.###") //Pega os arquivos .TXT existentes na pasta
	_nTamDir	:= Len(_aDiret)
	_nIni		:= 0

	If (_nTamDir == 0)
		Conout("Não há arquivos na pasta "+_cDirTXT + _cDirTXT2 +" - PERFIMPEST")
		Return(.F.)
	EndIf

	_cPathFile	:= ""
	For _nIni	:= 1 To _nTamDir
		_cTxtNome	:= _aDiret[_nIni,1]
		If !(_lExecJob)
			_oProcess:IncRegua1("Leitura do arquivo "+_cTxtNome)
		EndIf
		_cPathFile	:= _cDirTXT + _cDirTXT2 + _cTxtNome
		Conout("Lendo o(s) arquivo(s) .TXT da pasta "+_cDirTXT + _cDirTXT2 + " - PERFIMPEST")
		If (_lRet)
			_lRet := FREADTXT()
		Else
			Conout("Não foi possível importar o arquivo "+_cTxtNome + " - PERFIMPEST")
			If !(_lExecJob)
				MsgStop("Não foi possível importar o arquivo "+_cTxtNome,"PERFIMPEST")
			EndIf
		EndIf
		If (_lRet)
			Conout("Movendo o arquivo para a pasta "+_cDirTXT + _cDirOk + _cTxtNome + " - PERFIMPEST")
			COPY File(_cPathFile) To (_cDirTXT + _cDirOk + _cTxtNome)
			If File(_cDirTXT + _cDirOk + _cTxtNome)
				fErase(_cPathFile)
			EndIf
		Else
			Conout("Movendo o arquivo para a pasta "+_cDirTXT + _cDirErro + _cTxtNome + " - PERFIMPEST")
			COPY File(_cPathFile) To (_cDirTXT  + _cDirErro + _cTxtNome)
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

	Local _lOk			:= .T.
	Local _cBuffer 		:= ""
	Local _nHandle		:= 0
	Local _aDadostxt	:= {}
	Local _nLin			:= 0
	Local _cTpReg		:= ""
	Local _cItem		:= ""
	Local _cCodAgrup	:= ""
	Local _cCodComp		:= ""
	Local _cCodCor		:= ""
	Local _nQuant		:= 0
	Local _cGrpSub		:= ""
	Local _cSetor		:= ""
	Local _nTamIt		:= 2 //TAMSX3("D1_ITEM")[1]
	Local _nTamGrpS		:= 5
	Local _nTamAgrp		:= 15
	Local _nTamComp		:= TAMSX3("G1_COMP")[1]
	Local _cChvTab1		:= ""
	Local _cChvTab2		:= ""
	Local c_Erro		:= ""
	Local _lCor			:= .T.
	Local _cOrcamen		:= ""

	//Abre o Arquivo
	_nHandle := Ft_fuse(_cPathFile)
	If _nHandle == -1  // Se houver erro de abertura abandona processamento
		Return(.F.)
	Endif

	//Numero de linhas do arquivo
	ProcRegua(Ft_fLastRec())

	//Vai para a primeira linha do arquivo
	Ft_FGoTop()
	_nLin 		:= 1
	_nRecno		:= 0
	_cHeader	:= ""
	_lOk		:= .T.
	While !Ft_fEof()

		If !(_lExecJob)
			_oProcess:IncRegua1("Leitura da "+AllTrim(STR(_nLin))+"ª linha do arquivo "+_cTxtNome)
		EndIf

		_cBuffer	:= Ft_fReadln()
		_nRecno		:= Ft_fRecno()
		_aDadostxt	:= {}
		_cTpReg		:= ""
		_cGrpSub	:= ""
		_cItem		:= ""
		_cCodAgrup	:= ""
		_cSetor		:= ""
		_cCodComp	:= ""
		_cCodCor	:= ""
		_nQuant		:= 0
		_aDadostxt	:= Iif(_nLin==1,StrTokArr(_cBuffer,"|"),StrTokArr(_cBuffer,";"))

		If Len(_aDadostxt)==0
			Ft_fSkip()
			Loop
		EndIf

		_cTpReg		:= _aDadostxt[1]

		If (AllTrim(_cTpReg) == "0")
			_cHeader := UPPER(AllTrim(_aDadostxt[4]))
		Else
			_cGrpSub	:= AllTrim(_aDadostxt[1])
			_cItem		:= AllTrim(_aDadostxt[2])
			_cItem		:= STRZERO(Val(_cItem),_nTamIt)
			_cCodAgrup 	:= AllTrim(_aDadostxt[3])
			_cSetor 	:= AllTrim(_aDadostxt[7])
			_cCodComp	:= AllTrim(_aDadostxt[8])
			_cCodCor	:= UPPER(AllTrim(_aDadostxt[12]))
			_nQuant		:= Val(_aDadostxt[13])
			_cChvTab1	:= ""
			_cChvTab2	:= ""
			_cOrcamen	:= AllTrim(_aDadostxt[14])

			If Empty(_cGrpSub)
				_lOk := .F.
				Exit
			EndIf

			If Empty(_cCodAgrup)
				_lOk := .F.
				Exit
			EndIf

			If Empty(_cCodComp)
				_lOk := .F.
				Exit
			EndIf

			If (_nQuant == 0)
				_lOk := .F.
				Exit
			EndIf

			c_Erro := ""

			dbSelectArea("SB1")
			dbSetOrder(1)

			If !(dbSeek(xFilial("SB1")+_cCodCor))
				_lCor  := .F.
				c_Erro := "Código de produto cor "+ALLTRIM(_cCodCor)+" no arquivo não existe no ERP."
			Endif

			_cChvTab1 := PadR(_cGrpSub,_nTamGrpS)+PadR(_cCodAgrup,_nTamAgrp)
			//******Cabecalho*********************
			dbSelectArea(_cEstTmp1)
			dbSetOrder(1)//GRPSUB+AGRUPA
			If !(_cEstTmp1)->(dbSeek(_cChvTab1))
				(_cEstTmp1)->(RecLock(_cEstTmp1,.T.))
				(_cEstTmp1)->GRPSUB		:= _cGrpSub
				(_cEstTmp1)->AGRUPA		:= _cCodAgrup
				(_cEstTmp1)->NOMEARQU	:= _cTxtNome
				(_cEstTmp1)->ORCAMEN	:= _cOrcamen
				(_cEstTmp1)->(MSUnlock())
			EndIf

			_cChvTab2 := PadR(_cCodAgrup,_nTamAgrp)+PadR(_cCodComp,_nTamComp)
			//**************Componentes******************
			//Produto PA, Produto (Componente), Cor, Quantidade
			dbSelectArea(_cEstTmp2)
			dbSetOrder(2)//AGRUPA+PRODFILH
			If !(_cEstTmp2)->(dbSeek(_cChvTab2))
				(_cEstTmp2)->(RecLock(_cEstTmp2,.T.))
				(_cEstTmp2)->GRPSUB		:= _cGrpSub
				(_cEstTmp2)->ITEM		:= _cItem
				(_cEstTmp2)->AGRUPA		:= _cCodAgrup
				(_cEstTmp2)->SETOR		:= _cSetor
				(_cEstTmp2)->PRODFILH	:= _cCodComp
				(_cEstTmp2)->CORPROD	:= _cCodCor
				(_cEstTmp2)->QUANT		:= _nQuant
				(_cEstTmp2)->NOMEARQU	:= _cTxtNome
				(_cEstTmp2)->MSGERR		:= c_Erro
				(_cEstTmp2)->ORCAMEN	:= _cOrcamen
				(_cEstTmp2)->(MSUnlock())
			Else
				If AllTrim((_cEstTmp2)->CORPROD) == AllTrim(_cCodCor)
					(_cEstTmp2)->(RecLock(_cEstTmp2,.F.))
					(_cEstTmp2)->QUANT += _nQuant
					(_cEstTmp2)->(MSUnlock())
				EndIf
			EndIf
		EndIf

		_nLin++

		Ft_fSkip()
	EndDo

	Ft_fuse() //Fecha o arquivo

	FGETCODPA()
	FGRVLOGEST(c_Erro)

	If !(_lCor)
		Return(.F.)
	EndIf

	If !(_lOk)
		Return(.F.)
	EndIf

	dbSelectArea(_cEstTmp1)
	If (_cEstTmp1)->(RecCount())==0
		Return(.F.)
	EndIf

	dbSelectArea(_cEstTmp2)
	If (_cEstTmp2)->(RecCount())==0
		Return(.F.)
	EndIf


	If !FCRIAEST()
		Return(.F.)
	EndIf

Return(.T.)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    | FGETCODPA ³ Autor ³ Flavio Valentin       ³ Data ³ 22/01/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pega o codigo do produto acabado no orcamento.              ³±±
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
Static Function FGETCODPA()

	Local _aArea 	:= GetArea()
	Local _cScript	:= ""
	Local _nRet

	_cScript := " UPDATE " + _oTmpEst2:GetRealName() + " SET CODPA=SZ4.Z4_CODPA "
	_cScript += " FROM " + _oTmpEst2:GetRealName() + " AS ITESTR " + CRLF
	_cScript += " INNER JOIN "+RetSqlName("SZ4")+" SZ4 " + CRLF
	_cScript += " ON SZ4.Z4_CODAGRP=ITESTR.AGRUPA " + CRLF
	_cScript += " AND SZ4.Z4_ITEMORC=ITESTR.ITEM " + CRLF
	_cScript += " AND SZ4.Z4_NUMORC = ITESTR.ORCAMEN" + CRLF
	_cScript += " AND SZ4.D_E_L_E_T_<>'*' " + CRLF
	_cScript += " WHERE " + CRLF
	_cScript += " ITESTR.D_E_L_E_T_<>'*' " + CRLF
	_nRet := TCSQLExec(_cScript)

	If (_nRet < 0)
		Return(.F.)
	EndIf

	RestArea(_aArea)

Return(.T.)



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FGRVLOGEST ³ Autor ³ Flavio Valentin           ³ Data ³ 08/02/19 ³±±
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
Static Function FGRVLOGEST(c_Msg)

	Local _aArea		:= GetArea()
	//Local _cCodPA		:= ""
	Local _cQuery		:= ""
	Local _cAliasQry	:= ""

	Default c_Msg		:= ""

	_cAliasQry	:= GetNextAlias()
	_cQuery := " SELECT " + CRLF
	_cQuery += " CABESTR.GRPSUB " + CRLF
	_cQuery += " ,CABESTR.AGRUPA " + CRLF
	_cQuery += " ,CABESTR.NOMEARQU " + CRLF
	_cQuery += " ,ITESTR.SETOR " + CRLF
	_cQuery += " ,ITESTR.CODPA " + CRLF
	_cQuery += " ,ITESTR.PRODFILH " + CRLF
	_cQuery += " ,ITESTR.ITEM " + CRLF
	_cQuery += " ,ITESTR.CORPROD " + CRLF
	_cQuery += " ,ITESTR.QUANT " + CRLF
	_cQuery += " ,ITESTR.MSGERR "+ CRLF
	_cQuery += " FROM " + _oTmpEst1:GetRealName() + " AS CABESTR " + CRLF
	_cQuery += " INNER JOIN " + _oTmpEst2:GetRealName() + " AS ITESTR " + CRLF
	_cQuery += " ON ITESTR.AGRUPA=CABESTR.AGRUPA " + CRLF
	_cQuery += " AND ITESTR.ORCAMEN=CABESTR.ORCAMEN" + CRLF
	_cQuery += " AND ITESTR.D_E_L_E_T_<>'*' " + CRLF
	_cQuery += " WHERE CABESTR.D_E_L_E_T_<>'*' " + CRLF
	_cQuery += " ORDER BY ITESTR.ITEM "
	_cQuery := ChangeQuery(_cQuery)

	If Select(_cAliasQRY) > 0
		dbSelectArea(_cAliasQRY)
		dbCloseArea()
	EndIf

	MPSysOpenQuery(_cQuery,_cAliasQry)
	TcSetField(_cAliasQry,"QUANT",TAMSX3("G1_QUANT")[3],TAMSX3("G1_QUANT")[1],TAMSX3("G1_QUANT")[2])

	dbSelectArea(_cAliasQry)
	(_cAliasQry)->(dbGoTop())

	c_Seq := GetSxeNum("SZ5","Z5_SEQUENC")

	While (_cAliasQry)->(!Eof())

		If !(_lExecJob)
			_oProcess:IncRegua1("Gravando o log da estrutura de produtos na tabela SZ5")
		EndIf


		dbSelectArea("SZ5")
		SZ5->(RecLock("SZ5",.T.))
		SZ5->Z5_FILIAL 	:= xFilial("SZ5")
		SZ5->Z5_GRPSUB 	:= (_cAliasQry)->GRPSUB
		SZ5->Z5_ITEM 	:= (_cAliasQry)->ITEM
		SZ5->Z5_CODAGRP	:= (_cAliasQry)->AGRUPA
		SZ5->Z5_SETOR 	:= (_cAliasQry)->SETOR
		SZ5->Z5_CODPA   := (_cAliasQry)->CODPA
		SZ5->Z5_CODFIL 	:= (_cAliasQry)->PRODFILH
		SZ5->Z5_COR 	:= (_cAliasQry)->CORPROD
		SZ5->Z5_QUANT	:= (_cAliasQry)->QUANT
		SZ5->Z5_ARQUIVO	:= (_cAliasQry)->NOMEARQU
		SZ5->Z5_DTIMP	:= ddatabase
		SZ5->Z5_USUARIO := cUserName
		SZ5->Z5_HORA 	:= Left(Time(),5)
		SZ5->Z5_MSG		:= (_cAliasQry)->MSGERR
		SZ5->Z5_SEQUENC := c_Seq
		SZ5->(MSUnlock())
		(_cAliasQry)->(dbskip())

	EndDo

	ConfirmSX8()

	RestArea(_aArea)

Return



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FCRIAEST   ³ Autor ³ Flavio Valentin           ³ Data ³ 22/01/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que grava estrutura de produtos via execauto.             ³±±
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
Static Function FCRIAEST()

	Local _aArea		:= GetArea()
	Local _lRet 		:= .T.
	Local _aCabSG1		:= {}
	Local _aAux			:= {}
	Local _aItensG1		:= {}
	Local _nQtdBase		:= GetNewPar("PR_QTDBAS",1)
	Local _dDtIni		:= ddatabase
	Local _dDtFim		:= CTOD("31/12/2049") //GetNewPar("MV_XDTFIM",MonthSum(MSDATE(),36))
	Local _nOpc			:= 3
	Local _cAliasQry	:= GetNextAlias()
	Local _cAliaQry2	:= GetNextAlias()
	Local _cQuery		:= ""
	Local _nBkpMod		:= 0
	Local _nTamCpo1		:= TAMSX3("G1_TRT")[1]

	//Faz o backup do modulo atual
	_nBkpMod := nModulo

	_cQuery := " SELECT DISTINCT ITESTR.ITEM, ITESTR.AGRUPA, ITESTR.CODPA " + CRLF
	_cQuery += " FROM " + _oTmpEst2:GetRealName() + " AS ITESTR " + CRLF
	_cQuery += " WHERE ITESTR.D_E_L_E_T_<>'*' " + CRLF
	_cQuery += " ORDER BY ITESTR.ITEM "
	_cQuery := ChangeQuery(_cQuery)


	If Select(_cAliasQRY) > 0
		dbSelectArea(_cAliasQRY)
		dbCloseArea()
	EndIf

	MPSysOpenQuery(_cQuery,_cAliasQry)

	dbSelectArea(_cAliasQry)
	(_cAliasQry)->(dbGoTop())
	_cCodPA 	:= ""
	_aCabSG1	:= {}
	While (_cAliasQry)->(!Eof())

		If !(_lExecJob)
			_oProcess:IncRegua1("... Cadastrando a estrutura do Produto: "+AllTrim((_cAliasQry)->CODPA)+" ... ")
		EndIf

		_aCabSG1 	:= {}
		_aItensG1	:= {}

		aAdd(_aCabSG1,{"G1_COD"		,(_cAliasQry)->CODPA	,Nil})
		aAdd(_aCabSG1,{"G1_QUANT"	,_nQtdBase				,Nil})
		aAdd(_aCabSG1,{"NIVALT"		,"N"					,Nil})

		_aAux 	:= {}
		_cCodPI	:= ""
		//_cCodPI := SubStr((_cAliasQry)->AGRUPA,1,At("#",(_cAliasQry)->AGRUPA)-1)
		/*_
	//Verifica se ja ha estrutura para para o PA + PI
	dbSelectArea("SG1")
	dbSetOrder(2)//G1_FILIAL, G1_COMP, G1_COD, R_E_C_N_O_, D_E_L_E_T_
	If SG1->(MSSeek(xFilial("SG1")+_cCodPI))
		aAdd(_aAux,{"G1_COD"	,(_cAliasQry)->CODPA		,Nil})
		aAdd(_aAux,{"G1_COMP"	,_cCodPI					,Nil})
		aAdd(_aAux,{"G1_TRT"	,Space(_nTamCpo1)			,Nil})
		aAdd(_aAux,{"G1_QUANT"	,_nQtdBase					,Nil})
		aAdd(_aAux,{"G1_PERDA"	,0							,Nil})
		aAdd(_aAux,{"G1_INI"	,_dDtIni					,Nil})
		aAdd(_aAux,{"G1_FIM"	,_dDtFim					,Nil})
		aAdd(_aItensG1,_aAux)
		If Len(_aCabSG1) > 0 .And. Len(_aItensG1) > 0
			_cExibeErr 	:= ""
			_nOpc 		:= 4
			nModulo 	:= 10 //Posiciona no modulo PCP
			lMsErroAuto := .F.
			MSExecAuto({|x,y,z| MATA200(x,y,z)},_aCabSG1,_aItensG1,_nOpc)
			If (lMsErroAuto)
				DisarmTransaction()
				If !(_lExecJob)
					//--MostraErro()
					_lRet := .F.
					_cExibeErr := AllTrim(FERRAUTO())
					Exit
				EndIf
			Else
				_lRet := .T.
				If !FGRAVAOP((_cAliasQry)->CODPA)
					_lRet := .F.
					Exit
				EndIf
			EndIf
			nModulo := _nBkpMod //Restaura o modulo
		Else
			_lRet := .F.
			Exit
		EndIf
	Else
		aAdd(_aAux,{"G1_COD"	,(_cAliasQry)->CODPA		,Nil})
		aAdd(_aAux,{"G1_COMP"	,_cCodPI					,Nil})
		aAdd(_aAux,{"G1_TRT"	,Space(_nTamCpo1)			,Nil})
		aAdd(_aAux,{"G1_QUANT"	,_nQtdBase					,Nil})
		aAdd(_aAux,{"G1_PERDA"	,0							,Nil})
		aAdd(_aAux,{"G1_INI"	,_dDtIni					,Nil})
		aAdd(_aAux,{"G1_FIM"	,_dDtFim					,Nil})
		aAdd(_aItensG1,_aAux)
		*/

		_cQuery := ""
		_cQuery += " SELECT " + CRLF
		_cQuery += " ITESTR.AGRUPA " + CRLF
		_cQuery += " ,ITESTR.CODPA " + CRLF
		_cQuery += " ,ITESTR.PRODFILH " + CRLF
		_cQuery += " ,ITESTR.CORPROD " + CRLF
		_cQuery += " ,ITESTR.QUANT " + CRLF
		_cQuery += " FROM " + _oTmpEst2:GetRealName() + " AS ITESTR " + CRLF
		_cQuery += " WHERE ITESTR.D_E_L_E_T_<>'*' " + CRLF
		_cQuery += " AND ITESTR.AGRUPA='"+(_cAliasQry)->AGRUPA+"' " + CRLF
		_cQuery += " AND ITESTR.CODPA='"+(_cAliasQry)->CODPA+"' " + CRLF
		_cQuery += " AND ITESTR.ITEM='"+(_cAliasQry)->ITEM+"' " + CRLF
		_cQuery := ChangeQuery(_cQuery)
		MPSysOpenQuery(_cQuery,_cAliaQry2)
		TcSetField(_cAliaQry2,"QUANT",TAMSX3("G1_QUANT")[3],TAMSX3("G1_QUANT")[1],TAMSX3("G1_QUANT")[2])

		cCodPI := (_cAliaQry2)->PRODFILH

		dbSelectArea(_cAliaQry2)
		(_cAliaQry2)->(dbGoTop())
		While (_cAliaQry2)->(!Eof())

			If !(_lExecJob)
				_oProcess:IncRegua2("...Adicionando Produto filho: "+AllTrim((_cAliaQry2)->PRODFILH)+" ... ")
			EndIf

			_aAux := {}
			aAdd(_aAux,{"G1_COD"	,(_cAliasQry)->CODPA		,Nil})
			aAdd(_aAux,{"G1_COMP"	,(_cAliaQry2)->PRODFILH		,Nil})
			aAdd(_aAux,{"G1_TRT"	,Space(_nTamCpo1)			,Nil})
			aAdd(_aAux,{"G1_QUANT"	,(_cAliaQry2)->QUANT		,Nil})
			aAdd(_aAux,{"G1_PERDA"	,0							,Nil})
			aAdd(_aAux,{"G1_INI"	,_dDtIni					,Nil})
			aAdd(_aAux,{"G1_FIM"	,_dDtFim					,Nil})
			aAdd(_aItensG1,_aAux)
			(_cAliaQry2)->(dbSkip())
		EndDo

		If Len(_aCabSG1) > 0 .And. Len(_aItensG1) > 0
			_cExibeErr 	:= ""
			_nOpc 		:= 3
			nModulo 	:= 10 //Posiciona no modulo PCP
			lMsErroAuto := .F.
			MSExecAuto({|x,y,z| MATA200(x,y,z)},_aCabSG1,_aItensG1,_nOpc)
			If (lMsErroAuto)
				DisarmTransaction()
				If !(_lExecJob)
					//--MostraErro()
					_lRet := .F.
					_cExibeErr := AllTrim(FERRAUTO())
					Exit
				EndIf
			Else
				_lRet := .T.

				/*If !FGRAVAOP((_cAliasQry)->CODPA)
					_lRet := .F.
					Exit
				EndIf*/
			EndIf
			nModulo := _nBkpMod //Restaura o modulo
		Else
			_lRet := .F.
			Exit
		EndIf
		//EndIf
		(_cAliasQry)->(dbSkip())
	EndDo


	If !(_lExecJob)
		If !(Empty(_cExibeErr))
			Alert(_cExibeErr)
		Endif
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

	Local _aArea		:= GetArea()
	Local _aStruEst1 	:= {}
	Local _aStruEst2 	:= {}
	Local _nTamIt		:= 2 //TAMSX3("D1_ITEM")[1]
	Local _nTamGrpS		:= 5
	Local _nTamAgrp		:= 15
	Local _nTamProd		:= TAMSX3("B1_COD")[1]
	Local _nTamComp		:= TAMSX3("G1_COMP")[1]
	Local _nTamQtde		:= TAMSX3("G1_QUANT")[1]
	Local _nTamSetor	:= 5
	Local _nTamCor		:= 15
	Local _nTamArq		:= 30
	Local _nTamOrc		:= 10

	If (_oTmpEst1 <> Nil)
		_oTmpEst1:Delete()
		_oTmpEst1 := Nil
	Endif

	//------------------------------------------------
	//Criacao do objeto
	//------------------------------------------------
	_oTmpEst1 := FWTemporaryTable():New(_cEstTmp1)

	//---------------------------------------------------------------------------------------
	//Monta os campos da tabela temporaria do cabecalho da Estrutura dos produtos
	//---------------------------------------------------------------------------------------
	//Array com estrutura da tabela temporaria
	//Campo, tipo, tamanho, decimal
	aAdd(_aStruEst1,{"GRPSUB"		,"C"	,_nTamGrpS	,0})
	aAdd(_aStruEst1,{"AGRUPA"		,"C"	,_nTamAgrp	,0})
	aAdd(_aStruEst1,{"NOMEARQU"		,"C"	,_nTamArq	,0})
	aAdd(_aStruEst1,{"ORCAMEN"		,"C"	,_nTamOrc	,0})

	_oTmpEst1:SetFields(_aStruEst1)
	_oTmpEst1:AddIndex("01",{"GRPSUB","AGRUPA"})

	//--------------------
	//Criacao da tabela
	//--------------------
	_oTmpEst1:Create()

	Conout("Tabela Temporaria Cabecalho da Estrutura de Produtos "+_oTmpEst1:GetRealName())

	If (_oTmpEst2 <> Nil)
		_oTmpEst2:Delete()
		_oTmpEst2 := Nil
	Endif

	//------------------------------------------------
	//Criacao do objeto
	//------------------------------------------------
	_oTmpEst2 := FWTemporaryTable():New(_cEstTmp2)

	//---------------------------------------------------------------------------------------
	//Monta os campos da tabela temporaria dos itens da Estrutura dos produtos
	//---------------------------------------------------------------------------------------
	//Campos que serao exibidos na Grid
	//Descricao do Campo, Campo, Tipo, Tamanho, Decimal, Picture
	aAdd(_aStruEst2,{"GRPSUB"	,"C"					,_nTamGrpS	,0						})
	aAdd(_aStruEst2,{"ITEM"		,"C" 					,_nTamIt 	,0 						})
	aAdd(_aStruEst2,{"AGRUPA"	,"C"					,_nTamAgrp	,0						})
	aAdd(_aStruEst2,{"SETOR"	,"C"					,_nTamSetor	,0						})
	aAdd(_aStruEst2,{"CODPA"	,TAMSX3("B1_COD")[3] 	,_nTamProd	,TAMSX3("B1_COD")[2] 	})
	aAdd(_aStruEst2,{"PRODFILH"	,TAMSX3("G1_COMP")[3] 	,_nTamComp 	,TAMSX3("G1_COMP")[2] 	})
	aAdd(_aStruEst2,{"QUANT"	,TAMSX3("G1_QUANT")[3] 	,_nTamQtde 	,TAMSX3("G1_QUANT")[2]	})
	aAdd(_aStruEst2,{"CORPROD"	,"C" 					,_nTamCor 	,0 						})
	aAdd(_aStruEst2,{"NOMEARQU"	,"C"					,_nTamArq	,0						})
	aAdd(_aStruEst2,{"MSGERR"	,"C"					,250    	,0						})
	aAdd(_aStruEst2,{"ORCAMEN"	,"C"					,_nTamOrc	,0						})

	_oTmpEst2:SetFields(_aStruEst2)
	_oTmpEst2:AddIndex("01",{"ITEM","AGRUPA","PRODFILH"})
	_oTmpEst2:AddIndex("02",{"AGRUPA","PRODFILH"})

	//--------------------
	//Criacao da tabela
	//--------------------
	_oTmpEst2:Create()

	Conout("Tabela Temporaria itens da estrutura "+_oTmpEst2:GetRealName())

	RestArea(_aArea)

Return(Nil)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FGRAVAOP   ³ Autor ³ Flavio Valentin           ³ Data ³ 08/02/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que inclui a Ordem de Producao via MSExecAuto.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ _cProduto => Codigo do Produto.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ _lRet => .T./.F.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Static Function FGRAVAOP(_cProduto)

	Local _aArea 		:= GetArea()
	Local _aOrdProd		:= {}
	Local _cArmaz		:= GetNewPar("PR_ARMPROD","05")
	Local _nQtdProd		:= 1
	Local _cObserv		:= "Incluida pelo Programa PERFIMPEST"
	Local _lRet			:= .T.
	Local _nBkpMod		:= 0
	Local _cExibeErr	:= ""
	Local _nOpc			:= 0

	//Faz o backup do modulo atual
	_nBkpMod := nModulo

	aAdd(_aOrdProd,{"C2_PRODUTO"	,_cProduto	,Nil})
	aAdd(_aOrdProd,{"C2_LOCAL"		,_cArmaz	,Nil})
	aAdd(_aOrdProd,{"C2_QUANT"		,_nQtdProd	,Nil})
	aAdd(_aOrdProd,{"C2_EMISSAO"	,ddatabase	,Nil})
	aAdd(_aOrdProd,{"C2_DATPRI"		,ddatabase+1,Nil})
	aAdd(_aOrdProd,{"C2_DATPRF"		,ddatabase+1,Nil})
	aAdd(_aOrdProd,{"C2_OBS"		,_cObserv	,Nil})
	aAdd(_aOrdProd,{"C2_TPOP"		,"F"		,Nil})
	aAdd(_aOrdProd,{"AUTEXPLODE"	,"S"		,Nil})

	If Len(_aOrdProd) > 0
		_cExibeErr 	:= ""
		_nOpc 		:= 3
		nModulo 	:= 10 //Posiciona no modulo PCP
		lMsErroAuto := .F.
		MSExecAuto({|x,Y|Mata650(x,Y)},_aOrdProd,_nOpc)
		If (lMsErroAuto)
			DisarmTransaction()
			If !(_lExecJob)
				_cExibeErr := AllTrim(FERRAUTO())
				Return(.F.)
			EndIf
		Else
			_lRet := .T.
		EndIf
		nModulo := _nBkpMod //Restaura o modulo
	EndIf

	RestArea(_aArea)

Return(_lRet)



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
