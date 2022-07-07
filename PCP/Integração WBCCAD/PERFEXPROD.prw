#Include 'protheus.ch'
#Include 'parmtype.ch'
#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"
#Include "RWMAKE.CH"
#Include "TbiConn.ch"
#Include "TOTVS.ch"


User Function PERJOB01()

	//Preparar o Ambiente
	Prepare Environment Empresa "01" Filial "0101"

	conout("--------------------------------------------------")
	conout("- Gera arquivo de integracao WBC CAD - INICIO : "+Time())
	conout("--------------------------------------------------")

	U_PERFEXPROD(.T.)

	conout("--------------------------------------------------")
	conout("- Gera arquivo de integracao WBC CAD - FIM : "+Time())
	conout("--------------------------------------------------")

	Reset Environment

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PERFEXPROD ³ Autor ³ Flavio Valentin           ³ Data ³ 15/01/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa que gera um arquivo texto com o cadastro de produto.    ³±±
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
User Function PERFEXPROD(_lJob)

	Local _aArea		:= GetArea()
	Local _lRet			:= .T.
	Local _cQuery 		:= ""
	Local _cQryTot		:= ""
	Local _cOrdBy		:= ""
	Private _lExecJob	:= Iif(ValType(_lJob)<>"L",.F.,_lJob) //.T. = Chamada originou de um Schedule do Protheus
	Private _cAliasQRY	:= ""
	Private _cDirTXT  	:= GetNewpar("MV_XDIRAPP","\INTEG-WBCCAD\")
	Private _cDirTXT2  	:= "EXPORTA\"
	Private _cDirDest  	:= "PENDENTE\"
	Private _nQtdReg	:= 0
	Private _oProcess  	:= Nil
	Private _lPESB1 	:= (UPPER(AllTrim(FUNNAME())) == "MATA010") //IsInCallStack("U_ITEM") == .T. //Ponto de Entrada - MATA010_PE.prw
	Private __lProduca	:= (UPPER(AllTrim(GetEnvServer()))=="PERFIL" .Or. UPPER(AllTrim(GetEnvServer()))=="PERFIL_COMP" .Or. UPPER(AllTrim(GetEnvServer()))=="PERFIL_JOB" .Or. UPPER(AllTrim(GetEnvServer()))=="PERFIL_WS")

	If !ExistDir(_cDirTXT)
		MakeDir(_cDirTXT)
	EndIf

	If !ExistDir(_cDirTXT + _cDirTXT2)
		MakeDir(_cDirTXT + _cDirTXT2)
	EndIf

	If !ExistDir(_cDirTXT + _cDirTXT2 + _cDirDest)
		MakeDir(_cDirTXT + _cDirTXT2 + _cDirDest)
	EndIf

	//Tratamento para nao gerar o TXT duplicado porque o ponto de entrada esta sendo chamado duas vezes ao final da gravacao da inclusao de produto
	If Type("__lMATA010") == "U" .And. (_lPESB1)
		Public __lMATA010	:= .F.
		Public __cCodPro	:= ""
	ElseIf Type("__lMATA010") == "L" .And. (_lPESB1)
		If AllTrim(__cCodPro) == AllTrim(SB1->B1_COD)
			__lMATA010	:= .T.
		Else
			__lMATA010	:= .F.
		EndIf
	EndIf

	If Type("__lMATA010") == "L" .And. (_lPESB1)
		If (__lMATA010)
			Return(Nil)
		Else
			__lMATA010 	:= .T.
			__cCodPro	:= SB1->B1_COD
		EndIf
	EndIf

	_cQuery := "SELECT " + CRLF
	_cQuery += "B1_COD	" + CRLF
	_cQuery += ",B1_DESC " + CRLF
	_cQuery += ",B1_UM " + CRLF
	_cQuery += ",B1_MSBLQL " + CRLF
	_cQuery += ",B1_TIPO " + CRLF
	_cQuery += ",B1_POSIPI " + CRLF
	_cQuery += ",B1_PESO " + CRLF
	_cQuery += ",B1_PRV1 " + CRLF
	_cQuery += ",B1_UPRC " + CRLF
	_cQuery += "FROM "+RetSqlName("SB1")+" " + CRLF
	_cQuery += "WHERE "
	_cQuery += "B1_FILIAL='"+xFilial("SB1")+"' " + CRLF
	If (_lPESB1)
		_cQuery += "AND B1_COD='"+SB1->B1_COD+"' " + CRLF
	Else
		_cQuery += "AND SUBSTRING(B1_COD,1,1) NOT IN ('2','6') " + CRLF
		//_cQuery += "AND B1_TIPO<>'PA' " + CRLF
		_cQuery += "AND B1__WBCCAD<>'S' " + CRLF
	EndIf
	_cQuery += "AND D_E_L_E_T_='' " + CRLF

	//Conout("PERFEXPROD - Query: "+_cQuery)

	_cAliasQRY	:= GetNextAlias()
	_cQryTot	:= "SELECT COUNT(*) AS QTDREG FROM ("+AllTrim(_cQuery)+") AS RESULT "

	If Select(_cAliasQRY) > 0
		dbSelectArea(_cAliasQRY)
		dbCloseArea()
	EndIf

	_cQryTot := ChangeQuery(_cQryTot)
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,,_cQryTot),_cAliasQRY,.T.,.T.)

	_nQtdReg := (_cAliasQRY)->QTDREG

	If (_nQtdReg == 0)
		If !(_lExecJob)
			Help(" ",1,"PERFEXPROD",,"NAO FORAM ENCONTRADOS PRODUTOS PARA EXPORTAR.",4,1)
		EndIf
		Return(Nil)
	EndIf

	If Select(_cAliasQRY) > 0
		dbSelectArea(_cAliasQRY)
		dbCloseArea()
	EndIf

	_cOrdBy := "ORDER BY B1_COD "
	_cQuery := _cQuery + _cOrdBy
	_cQuery := ChangeQuery(_cQuery)
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,,_cQuery),_cAliasQRY,.T.,.T.)
	TcSetField(_cAliasQRY,"B1_PESO","N",TAMSX3("B1_PESO")[1],TAMSX3("B1_PESO")[2])
	TcSetField(_cAliasQRY,"B1_PRV1","N",TAMSX3("B1_PRV1")[1],TAMSX3("B1_PRV1")[2])
	TcSetField(_cAliasQRY,"B1_UPRC","N",TAMSX3("B1_UPRC")[1],TAMSX3("B1_UPRC")[2])

	If (_lExecJob)
		_lRet := FGERATXT()
	Else
		_oProcess := MsNewProcess():New( { | lEnd | _lRet := FGERATXT(@lEnd)}, "Exportacao produtos para o WBC-CAD ...", "Aguarde ...", .F.)
		_oProcess:Activate()
	EndIf

	If !(_lRet)
		Return(Nil)
	EndIf

	RestArea(_aArea)

Return(Nil)



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FGERATXT   ³ Autor ³ Flavio Valentin           ³ Data ³ 15/01/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que gera o arquivo TXT.                                   ³±±
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
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FGERATXT(lEnd)

	Local _aArea		:= GetArea()
	Local _lRet			:= .T.
	Local _cLinha1		:= ""
	Local _cLinha2		:= ""
	Local _cArqTxt1,_cArqTxt2
	Local _nArq1,_nArq2
	Local _cSystem		:= CURDIR()
	Local _cDescArq1,_cDescArq2
	Local _cDirOk		:= "enviado\"
	Local _nGerou		:= 0
	Local _aInfComp 	:= {}
	Local _cDescr		:= ""
	Local _cBase		:= ""
	Local _cDescCor		:= ""
	Local _cLista		:= ""
	Local _nTabPrc		:= 0
	Local _cPrdUpd		:= ""

	If !ExistDir(_cDirTXT + _cDirTXT2 + _cDirOk)
		MakeDir(_cDirTXT + _cDirTXT2 + _cDirOk)
	EndIf

	If !(_lExecJob)
		_oProcess:SetRegua1(8)
	EndIf

	dbSelectArea(_cAliasQRY)
	(_cAliasQRY)->(dbGoTop())
	_nGerou 	:= 0
	_aInfComp 	:= {}
	_cDescr		:= ""
	_cBase		:= ""
	_cDescCor	:= ""
	_cLista		:= ""
	_nPrcVend	:= 0
	_nTabPrc	:= 0
	_cPrdUpd	:= ""
	_cLinha1 	:= "Base;Codigo;Descricao;Unidade;Status;" + CRLF
	_cLinha2 	:= "Base;Lista;Codigo;Cor;Preco;" + CRLF
	While (_cAliasQRY)->(!Eof())

		If !(_lExecJob)
			_oProcess:IncRegua1("Selecionando os Produtos para geracao do arquivo TXT ...")
		EndIf

		_aInfComp	:= {}
		_cDescr		:= ""
		_nPrcVend 	:= 0
		_nTabPrc	:= 0
		_cBase		:= ""
		_cDescCor	:= ""
		_cLista		:= ""

		_nTabPrc := 500 //FGETPRC((_cAliasQRY)->B1_COD)

		If (_cAliasQRY)->B1_PRV1 <> 0
			_nPrcVend := (_cAliasQRY)->B1_PRV1
		ElseIf (_cAliasQRY)->B1_UPRC <> 0
			_nPrcVend := (_cAliasQRY)->B1_UPRC
		EndIf

		_cBloq := "A"
		If AllTrim((_cAliasQRY)->B1_MSBLQL)=="1"
			_cBloq := "I"
		EndIf

		_cDescr		:= AllTrim((_cAliasQRY)->B1_DESC)
		_aInfComp 	:= GETADVFVAL("SB5",{"B5_CEME","B5_PRV2","B5_PRV3","B5_PRV4"},xFilial("SB5")+AVKEY((_cAliasQRY)->B1_COD,"B5_COD"),1,{"",0,0,0})
		_cBase		:= "Perfil"
		_cLinha1 	+= _cBase+";"+AllTrim((_cAliasQRY)->B1_COD)+";"+_cDescr+";"+AllTrim((_cAliasQRY)->B1_UM)+";"+_cBloq + CRLF

		If Len(_aInfComp) > 0
			If _aInfComp[2]<>0 .Or. _aInfComp[3]<>0 .Or. _aInfComp[4]<>0
				If _aInfComp[2]<>0
					_nPrcVend := _aInfComp[2]
				ElseIf _aInfComp[3]<>0
					_nPrcVend := _aInfComp[3]
				ElseIf _aInfComp[4]<>0
					_nPrcVend := _aInfComp[4]
				EndIf
			EndIf
			If !Empty(_aInfComp[1])
				_cDescr	:= AllTrim(_aInfComp[1])
			EndIf
		EndIf

		//Se encontrou o preco da tabela de preco
		If (_nTabPrc <> 0)
			_nPrcVend := _nTabPrc
		EndIf

		_cDescCor 	:= "sem cor"
		_cLista		:= "001"

		_cLinha2 += _cBase+";"+_cLista+";"+AllTrim((_cAliasQRY)->B1_COD)+";"+_cDescCor+";"+AllTrim(CVALTOCHAR(_nPrcVend)) + CRLF

		_cPrdUpd += (_cAliasQRY)->B1_COD + Iif(_nGerou < _nQtdReg,";","")

		_nGerou++

		(_cAliasQRY)->(dbSkip())
	EndDo

	If (_nGerou > 0)
		_cArqTxt1 	:= CriaTrab(Nil,.F.)
		_cArqTxt1	:= Alltrim(_cArqTxt1)+".TXT"
		_nArq1   	:= fCreate(_cArqTxt1)
		If fWrite(_nArq1,Upper(_cLinha1),Len(_cLinha1)) != Len(_cLinha1) //Grava o arquivo no diretorio informado.
			Return(.F.)
		EndIf
		fClose(_nArq1)
		_cDescArq1	:= ""
		//--_cDescArq1	:= "INTERFACE-PRODUTOS-"+DtoS(MsDate())+Replace(Time(),":","")+".txt"
		_cDescArq1	:= "PRODUTO-"+DtoS(MsDate())+Replace(Time(),":","")+".txt"
		If File(_cSystem + _cArqTxt1)
			Conout("Arquivo "+_cArqTxt1+" gerado em "+_cSystem)
		Else
			Conout("O arquivo "+_cArqTxt1+" não foi gerado.")
			Return(.F.)
		EndIf

		_cArqTxt2 	:= CriaTrab(Nil,.F.)
		_cArqTxt2	:= Alltrim(_cArqTxt2)+".TXT"
		_nArq2   	:= fCreate(_cArqTxt2)
		If fWrite(_nArq2,Upper(_cLinha2),Len(_cLinha2)) != Len(_cLinha2) //Grava o arquivo no diretorio informado.
			Return(.F.)
		EndIf
		fClose(_nArq2)
		_cDescArq2	:= ""
		//_cDescArq2	:= "INTERFACE-PRECOS-"+DtoS(MsDate())+Replace(Time(),":","")+".txt"
		_cDescArq2	:= "PRECO-"+DtoS(MsDate())+Replace(Time(),":","")+".txt"

		Copy File(_cSystem + _cArqTxt1) To (_cDirTXT + _cDirTXT2 + _cDirDest + _cDescArq1)
		If File(_cDirTXT + _cDirTXT2 + _cDirDest + _cDescArq1)
			If !(_lExecJob)
				MsgInfo("Arquivo "+_cDescArq1+" copiado para "+_cDirTXT + _cDirTXT2 + _cDirDest)
			EndIf
			If File(_cSystem + _cArqTxt1)
				fErase(_cSystem + _cArqTxt1)
			EndIf
		Else
			Conout("O arquivo "+_cDescArq1+" não foi copiado para "+_cDirTXT + _cDirTXT2 + _cDirDest)
			Return(.F.)
		EndIf

		/*
	_lEnvFTP := .F.
	If (__lProduca) //Se estiver logado no ambiente PRODUCAO, JOB
		If FTPConnect(_cServidor,_nPorta,_cUsuario,_cSenha)
			If FTPUpLoad(_cDirTXT + _cDirTXT2 + _cDirDest + _cDescArq1)
				_lEnvFTP := .T.
			Else
				_lEnvFTP := .F.
				Conout("Erro no Envio do arquivo do cadastro de produtos - PERFEXPROD")
			EndIf
			FTPDISCONNECT()
		Else
			_lEnvFTP := .F.
			Conout("Erro ao Conectar no FTP - PERFEXPROD")
		EndIf
	Else
		_lEnvFTP := .T.
	EndIf

	If (_lEnvFTP)
		If (_lExecJob)
			Conout("Arquivo "+_cDescArq1+" disponibilizado no FTP.")
		Else
			MsgInfo("Arquivo "+_cDescArq1+" disponibilizado no FTP.")
		EndIf
		Copy File(_cDirTXT + _cDirTXT2 + _cDirDest + _cDescArq1) To (_cDirTXT + _cDirTXT2 + _cDirOk + _cDescArq1)
		If File(_cDirTXT + _cDirTXT2 + _cDirOk + _cDescArq1)
			fErase(_cDirTXT + _cDirTXT2 + _cDirDest + _cDescArq1)
		EndIf
	EndIf
		*/

		Copy File(_cSystem + _cArqTxt2) To (_cDirTXT + _cDirTXT2 + _cDirDest + _cDescArq2)
		If File(_cDirTXT + _cDirTXT2 + _cDirDest + _cDescArq2)
			If !(_lExecJob)
				MsgInfo("Arquivo "+_cDescArq2+" copiado para "+_cDirTXT + _cDirTXT2 + _cDirDest)
			EndIf
			If File(_cSystem + _cArqTxt2)
				fErase(_cSystem + _cArqTxt2)
			EndIf

			FMARKINTG(_cPrdUpd)
			EnvWF()

		Else
			Conout("O arquivo "+_cDescArq2+" não foi copiado para "+_cDirTXT + _cDirTXT2 + _cDirDest)
			Return(.F.)
		EndIf

		/*
	_lEnvFTP := .F.
	If (__lProduca) //Se estiver logado no ambiente PRODUCAO, JOB
		If FTPConnect(_cServidor,_nPorta,_cUsuario,_cSenha)
			If FTPUpLoad(_cDirTXT + _cDirTXT2 + _cDirDest + _cDescArq2)
				_lEnvFTP := .T.
			Else
				_lEnvFTP := .F.
				Conout("Erro no Envio do arquivo do cadastro de produtos - PERFEXPROD")
			EndIf
			FTPDISCONNECT()
		Else
			_lEnvFTP := .F.
			Conout("Erro ao Conectar no FTP - PERFEXPROD")
		EndIf
	Else
		_lEnvFTP := .T.
	EndIf

	If (_lEnvFTP)
		If (_lExecJob)
			Conout("Arquivo "+_cDescArq2+" disponibilizado no FTP.")
		Else
			MsgInfo("Arquivo "+_cDescArq2+" disponibilizado no FTP.")
		EndIf
		Copy File(_cDirTXT + _cDirTXT2 + _cDirDest + _cDescArq2) To (_cDirTXT + _cDirTXT2 + _cDirOk + _cDescArq2)
		If File(_cDirTXT + _cDirTXT2 + _cDirOk + _cDescArq2)
			fErase(_cDirTXT + _cDirTXT2 + _cDirDest + _cDescArq2)
		EndIf
	EndIf

	If (_lEnvFTP)
		FMARKINTG(_cPrdUpd)
	EndIf
		*/

	EndIf

	RestArea(_aArea)

Return(_lRet)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FGETPRC    ³ Autor ³ Flavio Valentin           ³ Data ³ 29/01/19 ³±±
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
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Static Function FGETPRC(_cCodPro)

	Local _aArea		:= GetArea()
	Local _cQuery		:= ""
	Local _cAliasQRY	:= ""
	Local _nRet 		:= 0

	_cAliasQRY	:= "XQRY" //GetNextAlias()
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

	RestArea(_aArea)

Return(_nRet)


ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FMARKINTG  ³ Autor ³ Flavio Valentin           ³ Data ³ 29/01/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que marca os produtos que foram integrados ao WBC-CAD.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ _cParam => Produtos.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil.                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FMARKINTG(_cParam)

	Local _aArea	:= GetArea()
	Local _cQryUpd	:= ""
	Local _cCodProd	:= SubStr(_cParam,1,RAT(";",_cParam)-1)
	Local _nStatus	:= 0

	_cQryUpd := "UPDATE "+RetSqlName("SB1")+" SET B1__WBCCAD='S' " + CRLF
	_cQryUpd += "WHERE " + CRLF
	_cQryUpd += "B1_FILIAL='"+xFilial("SB1")+"' " + CRLF
	_cQryUpd += "AND B1_COD IN "+FormatIn(_cCodProd,";")+" " + CRLF
	_cQryUpd += "AND SUBSTRING(B1_COD,1,1) NOT IN ('2','6') " + CRLF
	_cQryUpd += "AND B1__WBCCAD<>'S' " + CRLF
	_cQryUpd += "AND D_E_L_E_T_='' " + CRLF

	//--Conout("PERFEXPROD - _cQryUpd: "+_cQryUpd)

	_nStatus := TcSqlExec(_cQryUpd)

	RestArea(_aArea)

Return(Nil)




/*****************************************************************************************/
Static Function EnvWF()
	Local _nIni		:= 0
	Local cTo 		:= GetNewPar("MV_XEMWB", "faguiar@deltadecisao.com.br;irossoni@deltadecisao.com.br" )
	Local aArea	    := GetArea()
	Local _cDirTXT 	:= "\integ-wbccad\exporta\pendente\*.txt"

	oProcess := TWFProcess():New("WORKFLOW", "ARQWBCCAD")
	oProcess:NewTask("ARQWBCCAD",'\workflow\wbccad\HTML\ARQWBCCAD.htm')
	oHtml     := oProcess:oHtml
	oHtml:ValByName("Titulo", "Workflow de Arquivo Integração - WBC CAD")

	_aDiret		:= Directory( _cDirTXT ) //Pega os arquivos .TXT existentes na pasta
	_nTamDir	:= Len(_aDiret)

	For _nIni := 1 To _nTamDir

		AAdd((oHtml:ValByName("it1.1")), _aDiret[_nIni,1] )
		AAdd((oHtml:ValByName("it1.2")), DTOC(_aDiret[_nIni,3]) + " - " +_aDiret[_nIni,4 ] )
		AAdd((oHtml:ValByName("it1.3")), "\integ-wbccad\exporta\pendente" )

	Next _nIni

	oProcess:ClientName(cUserName)
	oProcess:cTo := cTo
	oProcess:cSubject := "Workflow de Arquivo Integração - WBC CAD "

	If _nTamDir > 0

		oProcess:Start()
		oProcess:Free()

	EndIf

	RestArea(aArea)

Return Nil
