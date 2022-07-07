#INCLUDE "PROTHEUS.CH"

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )

#DEFINE CSSBOTAO	"QPushButton { color: #024670; "+;
"    border-image: url(rpo:fwstd_btn_nml.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"+;
"QPushButton:pressed {	color: #FFFFFF; "+;
"    border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"

//--------------------------------------------------------------------
/*/{Protheus.doc} UPDVOL
Função de update de dicionários para compatibilização

@author TOTVS Protheus
@since  09/07/2019
@obs    Gerado por EXPORDIC - V.6.0.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
User Function UPDVOL( cEmpAmb, cFilAmb )

Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS"
Local   cDesc1    := "Esta rotina tem como função fazer  a atualização  dos dicionários do Sistema ( SX?/SIX )"
Local   cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja não podem haver outros"
Local   cDesc3    := "usuários  ou  jobs utilizando  o sistema.  É EXTREMAMENTE recomendavél  que  se  faça um"
Local   cDesc4    := "BACKUP  dos DICIONÁRIOS  e da  BASE DE DADOS antes desta atualização, para que caso "
Local   cDesc5    := "ocorram eventuais falhas, esse backup possa ser restaurado."
Local   cDesc6    := ""
Local   cDesc7    := ""
Local   cMsg      := ""
Local   lOk       := .F.
Local   lAuto     := ( cEmpAmb <> NIL .or. cFilAmb <> NIL )

Private oMainWnd  := NIL
Private oProcess  := NIL

#IFDEF TOP
    TCInternal( 5, "*OFF" ) // Desliga Refresh no Lock do Top
#ENDIF

__cInterNet := NIL
__lPYME     := .F.

Set Dele On

// Mensagens de Tela Inicial
aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )
aAdd( aSay, cDesc4 )
aAdd( aSay, cDesc5 )
//aAdd( aSay, cDesc6 )
//aAdd( aSay, cDesc7 )

// Botoes Tela Inicial
aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

If lAuto
	lOk := .T.
Else
	FormBatch(  cTitulo,  aSay,  aButton )
EndIf

If lOk

	If FindFunction( "MPDicInDB" ) .AND. MPDicInDB()
		cMsg := "Este update NÃO PODE ser executado neste Ambiente." + CRLF + CRLF + ;
				"Os arquivos de dicionários se encontram no Banco de Dados e este update está preparado " + ;
				"para atualizar apenas ambientes com dicionários no formato ISAM (.dbf ou .dtc)."

		If lAuto
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( "LOG DA ATUALIZAÇÃO DOS DICIONÁRIOS" )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( cMsg )
			ConOut( DToC(Date()) + "|" + Time() + cMsg )
		Else
			MsgInfo( cMsg )
		EndIf

		Return NIL
	EndIf

	If lAuto
		aMarcadas :={{ cEmpAmb, cFilAmb, "" }}
	Else

		If !FWAuthAdmin()
			Final( "Atualização não Realizada." )
		EndIf

		aMarcadas := EscEmpresa()
	EndIf

	If !Empty( aMarcadas )
		If lAuto .OR. MsgNoYes( "Confirma a atualização dos dicionários ?", cTitulo )
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas, lAuto ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
			oProcess:Activate()

			If lAuto
				If lOk
					MsgStop( "Atualização Realizada.", "UPDVOL" )
				Else
					MsgStop( "Atualização não Realizada.", "UPDVOL" )
				EndIf
				dbCloseAll()
			Else
				If lOk
					Final( "Atualização Realizada." )
				Else
					Final( "Atualização não Realizada." )
				EndIf
			EndIf

		Else
			Final( "Atualização não Realizada." )

		EndIf

	Else
		Final( "Atualização não Realizada." )

	EndIf

EndIf

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSTProc
Função de processamento da gravação dos arquivos

@author TOTVS Protheus
@since  09/07/2019
@obs    Gerado por EXPORDIC - V.6.0.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSTProc( lEnd, aMarcadas, lAuto )
Local   aInfo     := {}
Local   aRecnoSM0 := {}
Local   cAux      := ""
Local   cFile     := ""
Local   cFileLog  := ""
Local   cMask     := "Arquivos Texto" + "(*.TXT)|*.txt|"
Local   cTCBuild  := "TCGetBuild"
Local   cTexto    := ""
Local   cTopBuild := ""
Local   lOpen     := .F.
Local   lRet      := .T.
Local   nI        := 0
Local   nPos      := 0
Local   nRecno    := 0
Local   nX        := 0
Local   oDlg      := NIL
Local   oFont     := NIL
Local   oMemo     := NIL

Private aArqUpd   := {}

If ( lOpen := MyOpenSm0(.T.) )

	dbSelectArea( "SM0" )
	dbGoTop()

	While !SM0->( EOF() )
		// Só adiciona no aRecnoSM0 se a empresa for diferente
		If aScan( aRecnoSM0, { |x| x[2] == SM0->M0_CODIGO } ) == 0 ;
		   .AND. aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } ) > 0
			aAdd( aRecnoSM0, { Recno(), SM0->M0_CODIGO } )
		EndIf
		SM0->( dbSkip() )
	End

	SM0->( dbCloseArea() )

	If lOpen

		For nI := 1 To Len( aRecnoSM0 )

			If !( lOpen := MyOpenSm0(.F.) )
				MsgStop( "Atualização da empresa " + aRecnoSM0[nI][2] + " não efetuada." )
				Exit
			EndIf

			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

			RpcSetType( 3 )
			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( "LOG DA ATUALIZAÇÃO DOS DICIONÁRIOS" )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )
			AutoGrLog( " Dados Ambiente" )
			AutoGrLog( " --------------------" )
			AutoGrLog( " Empresa / Filial...: " + cEmpAnt + "/" + cFilAnt )
			AutoGrLog( " Nome Empresa.......: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " Nome Filial........: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " DataBase...........: " + DtoC( dDataBase ) )
			AutoGrLog( " Data / Hora Ínicio.: " + DtoC( Date() )  + " / " + Time() )
			AutoGrLog( " Environment........: " + GetEnvServer()  )
			AutoGrLog( " StartPath..........: " + GetSrvProfString( "StartPath", "" ) )
			AutoGrLog( " RootPath...........: " + GetSrvProfString( "RootPath" , "" ) )
			AutoGrLog( " Versão.............: " + GetVersao(.T.) )
			AutoGrLog( " Usuário TOTVS .....: " + __cUserId + " " +  cUserName )
			AutoGrLog( " Computer Name......: " + GetComputerName() )

			aInfo   := GetUserInfo()
			If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
				AutoGrLog( " " )
				AutoGrLog( " Dados Thread" )
				AutoGrLog( " --------------------" )
				AutoGrLog( " Usuário da Rede....: " + aInfo[nPos][1] )
				AutoGrLog( " Estação............: " + aInfo[nPos][2] )
				AutoGrLog( " Programa Inicial...: " + aInfo[nPos][5] )
				AutoGrLog( " Environment........: " + aInfo[nPos][6] )
				AutoGrLog( " Conexão............: " + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) ) )
			EndIf
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )

			If !lAuto
				AutoGrLog( Replicate( "-", 128 ) )
				AutoGrLog( "Empresa : " + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF )
			EndIf

			oProcess:SetRegua1( 8 )

			//------------------------------------
			// Atualiza o dicionário SX2
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de arquivos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX2()

			//------------------------------------
			// Atualiza o dicionário SX3
			//------------------------------------
			FSAtuSX3()

			//------------------------------------
			// Atualiza o dicionário SIX
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de índices" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSIX()

			oProcess:IncRegua1( "Dicionário de dados" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			oProcess:IncRegua2( "Atualizando campos/índices" )

			// Alteração física dos arquivos
			__SetX31Mode( .F. )

			If FindFunction(cTCBuild)
				cTopBuild := &cTCBuild.()
			EndIf

			For nX := 1 To Len( aArqUpd )

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					If ( ( aArqUpd[nX] >= "NQ " .AND. aArqUpd[nX] <= "NZZ" ) .OR. ( aArqUpd[nX] >= "O0 " .AND. aArqUpd[nX] <= "NZZ" ) ) .AND.;
						!aArqUpd[nX] $ "NQD,NQF,NQP,NQT"
						TcInternal( 25, "CLOB" )
					EndIf
				EndIf

				If Select( aArqUpd[nX] ) > 0
					dbSelectArea( aArqUpd[nX] )
					dbCloseArea()
				EndIf

				X31UpdTable( aArqUpd[nX] )

				If __GetX31Error()
					Alert( __GetX31Trace() )
					MsgStop( "Ocorreu um erro desconhecido durante a atualização da tabela : " + aArqUpd[nX] + ". Verifique a integridade do dicionário e da tabela.", "ATENÇÃO" )
					AutoGrLog( "Ocorreu um erro desconhecido durante a atualização da estrutura da tabela : " + aArqUpd[nX] )
				EndIf

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					TcInternal( 25, "OFF" )
				EndIf

			Next nX

			//------------------------------------
			// Atualiza o dicionário SX7
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de gatilhos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX7()

			//------------------------------------
			// Atualiza o dicionário SXA
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de pastas" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSXA()

			//------------------------------------
			// Atualiza o dicionário SXB
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de consultas padrão" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSXB()

			//------------------------------------
			// Atualiza o dicionário SX9
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de relacionamentos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSX9()

			//------------------------------------
			// Atualiza os helps
			//------------------------------------
			oProcess:IncRegua1( "Helps de Campo" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuHlp()

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time() )
			AutoGrLog( Replicate( "-", 128 ) )

			RpcClearEnv()

		Next nI

		If !lAuto

			cTexto := LeLog()

			Define Font oFont Name "Mono AS" Size 5, 12

			Define MsDialog oDlg Title "Atualização concluida." From 3, 0 to 340, 417 Pixel

			@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
			oMemo:bRClicked := { || AllwaysTrue() }
			oMemo:oFont     := oFont

			Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
			Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
			MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel

			Activate MsDialog oDlg Center

		EndIf

	EndIf

Else

	lRet := .F.

EndIf

Return lRet


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX2
Função de processamento da gravação do SX2 - Arquivos

@author TOTVS Protheus
@since  09/07/2019
@obs    Gerado por EXPORDIC - V.6.0.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX2()
Local aEstrut   := {}
Local aSX2      := {}
Local cAlias    := ""
Local cCpoUpd   := "X2_ROTINA /X2_UNICO  /X2_DISPLAY/X2_SYSOBJ /X2_USROBJ /X2_POSLGT /"
Local cEmpr     := ""
Local cPath     := ""
Local nI        := 0
Local nJ        := 0

AutoGrLog( "Ínicio da Atualização" + " SX2" + CRLF )

aEstrut := { "X2_CHAVE"  , "X2_PATH"   , "X2_ARQUIVO", "X2_NOME"   , "X2_NOMESPA", "X2_NOMEENG", "X2_MODO"   , ;
             "X2_TTS"    , "X2_ROTINA" , "X2_PYME"   , "X2_UNICO"  , "X2_DISPLAY", "X2_SYSOBJ" , "X2_USROBJ" , ;
             "X2_POSLGT" , "X2_CLOB"   , "X2_AUTREC" , "X2_MODOEMP", "X2_MODOUN" , "X2_MODULO" }


dbSelectArea( "SX2" )
SX2->( dbSetOrder( 1 ) )
SX2->( dbGoTop() )
cPath := SX2->X2_PATH
cPath := IIf( Right( AllTrim( cPath ), 1 ) <> "\", PadR( AllTrim( cPath ) + "\", Len( cPath ) ), cPath )
cEmpr := Substr( SX2->X2_ARQUIVO, 4 )

//
// Tabela SZ7
//
aAdd( aSX2, { ;
	'SZ7'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'SZ7'+cEmpr																, ; //X2_ARQUIVO
	'CABECALHO VOLUMES'														, ; //X2_NOME
	'CABECALHO VOLUMES'														, ; //X2_NOMESPA
	'CABECALHO VOLUMES'														, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Tabela SZ8
//
aAdd( aSX2, { ;
	'SZ8'																	, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	'SZ8'+cEmpr																, ; //X2_ARQUIVO
	'ITENS VOLUMES'															, ; //X2_NOME
	'ITENS VOLUMES'															, ; //X2_NOMESPA
	'ITENS VOLUMES'															, ; //X2_NOMEENG
	'E'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	''																		, ; //X2_PYME
	''																		, ; //X2_UNICO
	''																		, ; //X2_DISPLAY
	''																		, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	''																		, ; //X2_POSLGT
	''																		, ; //X2_CLOB
	''																		, ; //X2_AUTREC
	'E'																		, ; //X2_MODOEMP
	'E'																		, ; //X2_MODOUN
	0																		} ) //X2_MODULO

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX2 ) )

dbSelectArea( "SX2" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX2 )

	oProcess:IncRegua2( "Atualizando Arquivos (SX2)..." )

	If !SX2->( dbSeek( aSX2[nI][1] ) )

		If !( aSX2[nI][1] $ cAlias )
			cAlias += aSX2[nI][1] + "/"
			AutoGrLog( "Foi incluída a tabela " + aSX2[nI][1] )
		EndIf

		RecLock( "SX2", .T. )
		For nJ := 1 To Len( aSX2[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				If AllTrim( aEstrut[nJ] ) == "X2_ARQUIVO"
					FieldPut( FieldPos( aEstrut[nJ] ), SubStr( aSX2[nI][nJ], 1, 3 ) + cEmpAnt +  "0" )
				Else
					FieldPut( FieldPos( aEstrut[nJ] ), aSX2[nI][nJ] )
				EndIf
			EndIf
		Next nJ
		MsUnLock()

	Else

		If  !( StrTran( Upper( AllTrim( SX2->X2_UNICO ) ), " ", "" ) == StrTran( Upper( AllTrim( aSX2[nI][12]  ) ), " ", "" ) )
			RecLock( "SX2", .F. )
			SX2->X2_UNICO := aSX2[nI][12]
			MsUnlock()

			If MSFILE( RetSqlName( aSX2[nI][1] ),RetSqlName( aSX2[nI][1] ) + "_UNQ"  )
				TcInternal( 60, RetSqlName( aSX2[nI][1] ) + "|" + RetSqlName( aSX2[nI][1] ) + "_UNQ" )
			EndIf

			AutoGrLog( "Foi alterada a chave única da tabela " + aSX2[nI][1] )
		EndIf

		RecLock( "SX2", .F. )
		For nJ := 1 To Len( aSX2[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				If PadR( aEstrut[nJ], 10 ) $ cCpoUpd
					FieldPut( FieldPos( aEstrut[nJ] ), aSX2[nI][nJ] )
				EndIf

			EndIf
		Next nJ
		MsUnLock()

	EndIf

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX2" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX3
Função de processamento da gravação do SX3 - Campos

@author TOTVS Protheus
@since  09/07/2019
@obs    Gerado por EXPORDIC - V.6.0.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX3()
Local aEstrut   := {}
Local aSX3      := {}
Local cAlias    := ""
Local cAliasAtu := ""
Local cMsg      := ""
Local cSeqAtu   := ""
Local cX3Campo  := ""
Local cX3Dado   := ""
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nPosArq   := 0
Local nPosCpo   := 0
Local nPosOrd   := 0
Local nPosSXG   := 0
Local nPosTam   := 0
Local nPosVld   := 0
Local nSeqAtu   := 0
Local nTamSeek  := Len( SX3->X3_CAMPO )

AutoGrLog( "Ínicio da Atualização" + " SX3" + CRLF )

aEstrut := { { "X3_ARQUIVO", 0 }, { "X3_ORDEM"  , 0 }, { "X3_CAMPO"  , 0 }, { "X3_TIPO"   , 0 }, { "X3_TAMANHO", 0 }, { "X3_DECIMAL", 0 }, { "X3_TITULO" , 0 }, ;
             { "X3_TITSPA" , 0 }, { "X3_TITENG" , 0 }, { "X3_DESCRIC", 0 }, { "X3_DESCSPA", 0 }, { "X3_DESCENG", 0 }, { "X3_PICTURE", 0 }, { "X3_VALID"  , 0 }, ;
             { "X3_USADO"  , 0 }, { "X3_RELACAO", 0 }, { "X3_F3"     , 0 }, { "X3_NIVEL"  , 0 }, { "X3_RESERV" , 0 }, { "X3_CHECK"  , 0 }, { "X3_TRIGGER", 0 }, ;
             { "X3_PROPRI" , 0 }, { "X3_BROWSE" , 0 }, { "X3_VISUAL" , 0 }, { "X3_CONTEXT", 0 }, { "X3_OBRIGAT", 0 }, { "X3_VLDUSER", 0 }, { "X3_CBOX"   , 0 }, ;
             { "X3_CBOXSPA", 0 }, { "X3_CBOXENG", 0 }, { "X3_PICTVAR", 0 }, { "X3_WHEN"   , 0 }, { "X3_INIBRW" , 0 }, { "X3_GRPSXG" , 0 }, { "X3_FOLDER" , 0 }, ;
             { "X3_CONDSQL", 0 }, { "X3_CHKSQL" , 0 }, { "X3_IDXSRV" , 0 }, { "X3_ORTOGRA", 0 }, { "X3_TELA"   , 0 }, { "X3_POSLGT" , 0 }, { "X3_IDXFLD" , 0 }, ;
             { "X3_AGRUP"  , 0 }, { "X3_MODAL"  , 0 }, { "X3_PYME"   , 0 } }

aEval( aEstrut, { |x| x[2] := SX3->( FieldPos( x[1] ) ) } )


//
// Campos Tabela SB1
//
aAdd( aSX3, { ;
	'SB1'																	, ; //X3_ARQUIVO
	'U9'																	, ; //X3_ORDEM
	'B1_XVOLUME'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Volume?'																, ; //X3_TITULO
	'Volume?'																, ; //X3_TITSPA
	'Volume?'																, ; //X3_TITENG
	'Gera Volume'															, ; //X3_DESCRIC
	'Gera Volume'															, ; //X3_DESCSPA
	'Gera Volume'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=SIM;2=NAO'															, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela SZ7
//
aAdd( aSX3, { ;
	'SZ7'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'Z7_FILIAL'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	4																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Sucursal'																, ; //X3_TITSPA
	'Branch'																, ; //X3_TITENG
	'Filial do Sistema'														, ; //X3_DESCRIC
	'Sucursal'																, ; //X3_DESCSPA
	'Branch of the System'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'033'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	''																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ7'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'Z7_NUMVOL'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'N° Volume'																, ; //X3_TITULO
	'N° Volume'																, ; //X3_TITSPA
	'N° Volume'																, ; //X3_TITENG
	'Numero do Volume'														, ; //X3_DESCRIC
	'Numero do Volume'														, ; //X3_DESCSPA
	'Numero do Volume'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ7'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'Z7_PEDIDO'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Pedido'																, ; //X3_TITULO
	'Pedido'																, ; //X3_TITSPA
	'Pedido'																, ; //X3_TITENG
	'Pedido de Venda'														, ; //X3_DESCRIC
	'Pedido de Venda'														, ; //X3_DESCSPA
	'Pedido de Venda'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'XVOLUM'																, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	'U_VLDITEM()'															, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ7'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'Z7_ITEM'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Item'																	, ; //X3_TITULO
	'Item'																	, ; //X3_TITSPA
	'Item'																	, ; //X3_TITENG
	'Item do Pedido de Venda'												, ; //X3_DESCRIC
	'Item do Pedido de Venda'												, ; //X3_DESCSPA
	'Item do Pedido de Venda'												, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ7'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'Z7_CLIENTE'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Cliente'																, ; //X3_TITULO
	'Cliente'																, ; //X3_TITSPA
	'Cliente'																, ; //X3_TITENG
	'Cliente'																, ; //X3_DESCRIC
	'Cliente'																, ; //X3_DESCSPA
	'Cliente'																, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ7'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'Z7_LOJA'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	4																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Loja'																	, ; //X3_TITULO
	'Loja'																	, ; //X3_TITSPA
	'Loja'																	, ; //X3_TITENG
	'Loja'																	, ; //X3_DESCRIC
	'Loja'																	, ; //X3_DESCSPA
	'Loja'																	, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ7'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'Z7_EXPEDID'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	1																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Expedido ?'															, ; //X3_TITULO
	'Expedido ?'															, ; //X3_TITSPA
	'Expedido ?'															, ; //X3_TITENG
	'Expedido'																, ; //X3_DESCRIC
	'Expedido'																, ; //X3_DESCSPA
	'Expedido'																, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'2'																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	'1=SIM;2=NAO'															, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ7'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'Z7_EMISSAO'															, ; //X3_CAMPO
	'D'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Dt. Emissao'															, ; //X3_TITULO
	'Dt. Emissao'															, ; //X3_TITSPA
	'Dt. Emissao'															, ; //X3_TITENG
	'Data de Emissao'														, ; //X3_DESCRIC
	'Data de Emissao'														, ; //X3_DESCSPA
	'Data de Emissao'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'DATE()'																, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ7'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'Z7_OP'																	, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	11																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Ord. Produc'															, ; //X3_TITULO
	'Ord. Produc'															, ; //X3_TITSPA
	'Ord. Produc'															, ; //X3_TITENG
	'Ordem de Producao'														, ; //X3_DESCRIC
	'Ordem de Producao'														, ; //X3_DESCSPA
	'Ordem de Producao'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SC2'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	'€'																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ7'																	, ; //X3_ARQUIVO
	'10'																	, ; //X3_ORDEM
	'Z7_OBS'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	100																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Obs.'																	, ; //X3_TITULO
	'Obs.'																	, ; //X3_TITSPA
	'Obs.'																	, ; //X3_TITENG
	'Observacao'															, ; //X3_DESCRIC
	'Observacao'															, ; //X3_DESCSPA
	'Observacao'															, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

//
// Campos Tabela SZ8
//
aAdd( aSX3, { ;
	'SZ8'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'Z8_FILIAL'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	4																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Sucursal'																, ; //X3_TITSPA
	'Branch'																, ; //X3_TITENG
	'Filial do Sistema'														, ; //X3_DESCRIC
	'Sucursal'																, ; //X3_DESCSPA
	'Branch of the System'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'033'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	''																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ8'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'Z8_NUMVOL'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nº Volume'																, ; //X3_TITULO
	'Nº Volume'																, ; //X3_TITSPA
	'Nº Volume'																, ; //X3_TITENG
	'Nnumero do Volume'														, ; //X3_DESCRIC
	'Nnumero do Volume'														, ; //X3_DESCSPA
	'Nnumero do Volume'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ8'																	, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	'Z8_PEDIDO'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Pedido'																, ; //X3_TITULO
	'Pedido'																, ; //X3_TITSPA
	'Pedido'																, ; //X3_TITENG
	'Pedido de Venda'														, ; //X3_DESCRIC
	'Pedido de Venda'														, ; //X3_DESCSPA
	'Pedido de Venda'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ8'																	, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	'Z8_ITEM'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Item'																	, ; //X3_TITULO
	'Item'																	, ; //X3_TITSPA
	'Item'																	, ; //X3_TITENG
	'Item Pedido de Venda'													, ; //X3_DESCRIC
	'Item Pedido de Venda'													, ; //X3_DESCSPA
	'Item Pedido de Venda'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ8'																	, ; //X3_ARQUIVO
	'05'																	, ; //X3_ORDEM
	'Z8_PRODUTO'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	15																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Produto'																, ; //X3_TITULO
	'Produto'																, ; //X3_TITSPA
	'Produto'																, ; //X3_TITENG
	'Produto'																, ; //X3_DESCRIC
	'Produto'																, ; //X3_DESCSPA
	'Produto'																, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	'SB1'																	, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	'S'																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ8'																	, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	'Z8_DESC'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	50																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Descricao'																, ; //X3_TITULO
	'Descricao'																, ; //X3_TITSPA
	'Descricao'																, ; //X3_TITENG
	'Descricao do produto'													, ; //X3_DESCRIC
	'Descricao do produto'													, ; //X3_DESCSPA
	'Descricao do produto'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	'IIF( INCLUI ,"",  POSICIONE("SB1", 1, XFILIAL("SB1") + SZ8->Z8_PRODUTO , "B1_DESC") )', ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ8'																	, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	'Z8_LOCAL'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Armazem'																, ; //X3_TITULO
	'Armazem'																, ; //X3_TITSPA
	'Armazem'																, ; //X3_TITENG
	'Armazem'																, ; //X3_DESCRIC
	'Armazem'																, ; //X3_DESCSPA
	'Armazem'																, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ8'																	, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	'Z8_QTDEMP'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Qtd. Empenho'															, ; //X3_TITULO
	'Qtd. Empenho'															, ; //X3_TITSPA
	'Qtd. Empenho'															, ; //X3_TITENG
	'Quantidade Empenho'													, ; //X3_DESCRIC
	'Quantidade Empenho'													, ; //X3_DESCSPA
	'Quantidade Empenho'													, ; //X3_DESCENG
	'@E 9,999,999,999,999.99'												, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ8'																	, ; //X3_ARQUIVO
	'09'																	, ; //X3_ORDEM
	'Z8_SALDO'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Saldo'																	, ; //X3_TITULO
	'Saldo'																	, ; //X3_TITSPA
	'Saldo'																	, ; //X3_TITENG
	'Saldo do Empenho'														, ; //X3_DESCRIC
	'Saldo do Empenho'														, ; //X3_DESCSPA
	'Saldo do Empenho'														, ; //X3_DESCENG
	'@E 9,999,999,999,999.99'												, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ8'																	, ; //X3_ARQUIVO
	'10'																	, ; //X3_ORDEM
	'Z8_LOTE'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Lote'																	, ; //X3_TITULO
	'Lote'																	, ; //X3_TITSPA
	'Lote'																	, ; //X3_TITENG
	'Lote'																	, ; //X3_DESCRIC
	'Lote'																	, ; //X3_DESCSPA
	'Lote'																	, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ8'																	, ; //X3_ARQUIVO
	'11'																	, ; //X3_ORDEM
	'Z8_NUMSERI'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	20																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nº Serie'																, ; //X3_TITULO
	'Nº Serie'																, ; //X3_TITSPA
	'Nº Serie'																, ; //X3_TITENG
	'Numero de Serie'														, ; //X3_DESCRIC
	'Numero de Serie'														, ; //X3_DESCSPA
	'Numero de Serie'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SZ8'																	, ; //X3_ARQUIVO
	'12'																	, ; //X3_ORDEM
	'Z8_QTDVOL'																, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	2																		, ; //X3_DECIMAL
	'Quantidade'															, ; //X3_TITULO
	'Quantidade'															, ; //X3_TITSPA
	'Quantidade'															, ; //X3_TITENG
	'Quantidade do item'													, ; //X3_DESCRIC
	'Quantidade do item'													, ; //X3_DESCSPA
	'Quantidade do item'													, ; //X3_DESCENG
	'@E 9,999,999,999,999.99'												, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME


//
// Atualizando dicionário
//
nPosArq := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ARQUIVO" } )
nPosOrd := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ORDEM"   } )
nPosCpo := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_CAMPO"   } )
nPosTam := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_TAMANHO" } )
nPosSXG := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_GRPSXG"  } )
nPosVld := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_VALID"   } )

aSort( aSX3,,, { |x,y| x[nPosArq]+x[nPosOrd]+x[nPosCpo] < y[nPosArq]+y[nPosOrd]+y[nPosCpo] } )

oProcess:SetRegua2( Len( aSX3 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )
cAliasAtu := ""

For nI := 1 To Len( aSX3 )

	//
	// Verifica se o campo faz parte de um grupo e ajusta tamanho
	//
	If !Empty( aSX3[nI][nPosSXG] )
		SXG->( dbSetOrder( 1 ) )
		If SXG->( MSSeek( aSX3[nI][nPosSXG] ) )
			If aSX3[nI][nPosTam] <> SXG->XG_SIZE
				aSX3[nI][nPosTam] := SXG->XG_SIZE
				AutoGrLog( "O tamanho do campo " + aSX3[nI][nPosCpo] + " NÃO atualizado e foi mantido em [" + ;
				AllTrim( Str( SXG->XG_SIZE ) ) + "]" + CRLF + ;
				" por pertencer ao grupo de campos [" + SXG->XG_GRUPO + "]" + CRLF )
			EndIf
		EndIf
	EndIf

	SX3->( dbSetOrder( 2 ) )

	If !( aSX3[nI][nPosArq] $ cAlias )
		cAlias += aSX3[nI][nPosArq] + "/"
		aAdd( aArqUpd, aSX3[nI][nPosArq] )
	EndIf

	If !SX3->( dbSeek( PadR( aSX3[nI][nPosCpo], nTamSeek ) ) )

		//
		// Busca ultima ocorrencia do alias
		//
		If ( aSX3[nI][nPosArq] <> cAliasAtu )
			cSeqAtu   := "00"
			cAliasAtu := aSX3[nI][nPosArq]

			dbSetOrder( 1 )
			SX3->( dbSeek( cAliasAtu + "ZZ", .T. ) )
			dbSkip( -1 )

			If ( SX3->X3_ARQUIVO == cAliasAtu )
				cSeqAtu := SX3->X3_ORDEM
			EndIf

			nSeqAtu := Val( RetAsc( cSeqAtu, 3, .F. ) )
		EndIf

		nSeqAtu++
		cSeqAtu := RetAsc( Str( nSeqAtu ), 2, .T. )

		RecLock( "SX3", .T. )
		For nJ := 1 To Len( aSX3[nI] )
			If     nJ == nPosOrd  // Ordem
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), cSeqAtu ) )

			ElseIf aEstrut[nJ][2] > 0
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), aSX3[nI][nJ] ) )

			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

		AutoGrLog( "Criado campo " + aSX3[nI][nPosCpo] )

	EndIf

	oProcess:IncRegua2( "Atualizando Campos de Tabelas (SX3)..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX3" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSIX
Função de processamento da gravação do SIX - Indices

@author TOTVS Protheus
@since  09/07/2019
@obs    Gerado por EXPORDIC - V.6.0.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSIX()
Local aEstrut   := {}
Local aSIX      := {}
Local lAlt      := .F.
Local lDelInd   := .F.
Local nI        := 0
Local nJ        := 0

AutoGrLog( "Ínicio da Atualização" + " SIX" + CRLF )

aEstrut := { "INDICE" , "ORDEM" , "CHAVE", "DESCRICAO", "DESCSPA"  , ;
             "DESCENG", "PROPRI", "F3"   , "NICKNAME" , "SHOWPESQ" }

//
// Tabela SZ7
//
aAdd( aSIX, { ;
	'SZ7'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'Z7_FILIAL+Z7_NUMVOL+Z7_PEDIDO+Z7_ITEM'									, ; //CHAVE
	'Pedido+Item+N° Volume+Pedido+Item'										, ; //DESCRICAO
	'Pedido+Item+N° Volume+Pedido+Item'										, ; //DESCSPA
	'Pedido+Item+N° Volume+Pedido+Item'										, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SZ7'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'Z7_FILIAL+Z7_PEDIDO+Z7_ITEM'											, ; //CHAVE
	'Pedido+Item'															, ; //DESCRICAO
	'Pedido+Item'															, ; //DESCSPA
	'Pedido+Item'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SZ7'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'Z7_FILIAL+Z7_OP'														, ; //CHAVE
	'Ord. Produc'															, ; //DESCRICAO
	'Ord. Produc'															, ; //DESCSPA
	'Ord. Produc'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Tabela SZ8
//
aAdd( aSIX, { ;
	'SZ8'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'Z8_FILIAL+Z8_NUMVOL+Z8_PEDIDO+Z8_ITEM'									, ; //CHAVE
	'Nº Volume+Pedido+Item'													, ; //DESCRICAO
	'Nº Volume+Pedido+Item'													, ; //DESCSPA
	'Nº Volume+Pedido+Item'													, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SZ8'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'Z8_FILIAL+Z8_PEDIDO+Z8_ITEM'											, ; //CHAVE
	'Pedido+Item'															, ; //DESCRICAO
	'Pedido+Item'															, ; //DESCSPA
	'Pedido+Item'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SZ8'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'Z8_FILIAL+Z8_NUMVOL+Z8_PEDIDO+Z8_ITEM+Z8_PRODUTO'						, ; //CHAVE
	'Nº Volume+Pedido+Item+Produto'											, ; //DESCRICAO
	'Nº Volume+Pedido+Item+Produto'											, ; //DESCSPA
	'Nº Volume+Pedido+Item+Produto'											, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSIX ) )

dbSelectArea( "SIX" )
SIX->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSIX )

	lAlt    := .F.
	lDelInd := .F.

	If !SIX->( dbSeek( aSIX[nI][1] + aSIX[nI][2] ) )
		AutoGrLog( "Índice criado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] )
	Else
		lAlt := .T.
		aAdd( aArqUpd, aSIX[nI][1] )
		If !StrTran( Upper( AllTrim( CHAVE )       ), " ", "" ) == ;
		    StrTran( Upper( AllTrim( aSIX[nI][3] ) ), " ", "" )
			AutoGrLog( "Chave do índice alterado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] )
			lDelInd := .T. // Se for alteração precisa apagar o indice do banco
		EndIf
	EndIf

	RecLock( "SIX", !lAlt )
	For nJ := 1 To Len( aSIX[nI] )
		If FieldPos( aEstrut[nJ] ) > 0
			FieldPut( FieldPos( aEstrut[nJ] ), aSIX[nI][nJ] )
		EndIf
	Next nJ
	MsUnLock()

	dbCommit()

	If lDelInd
		TcInternal( 60, RetSqlName( aSIX[nI][1] ) + "|" + RetSqlName( aSIX[nI][1] ) + aSIX[nI][2] )
	EndIf

	oProcess:IncRegua2( "Atualizando índices..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SIX" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX7
Função de processamento da gravação do SX7 - Gatilhos

@author TOTVS Protheus
@since  09/07/2019
@obs    Gerado por EXPORDIC - V.6.0.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX7()
Local aEstrut   := {}
Local aAreaSX3  := SX3->( GetArea() )
Local aSX7      := {}
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nTamSeek  := Len( SX7->X7_CAMPO )

AutoGrLog( "Ínicio da Atualização" + " SX7" + CRLF )

aEstrut := { "X7_CAMPO", "X7_SEQUENC", "X7_REGRA", "X7_CDOMIN", "X7_TIPO", "X7_SEEK", ;
             "X7_ALIAS", "X7_ORDEM"  , "X7_CHAVE", "X7_PROPRI", "X7_CONDIC" }

//
// Campo Z7_ITEM
//
aAdd( aSX7, { ;
	'Z7_ITEM'																, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'U_SZ7NUM()'															, ; //X7_REGRA
	'Z7_NUMVOL'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo Z7_OP
//
aAdd( aSX7, { ;
	'Z7_OP'																	, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'u_fExpEst(M->Z7_OP)'													, ; //X7_REGRA
	'Z7_OP'																	, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Campo Z8_PRODUTO
//
aAdd( aSX7, { ;
	'Z8_PRODUTO'															, ; //X7_CAMPO
	'001'																	, ; //X7_SEQUENC
	'POSICIONE("SB1", 1, xFilial("SB1") + M->Z8_PRODUTO , "B1_DESC")'		, ; //X7_REGRA
	'Z8_DESC'																, ; //X7_CDOMIN
	'P'																		, ; //X7_TIPO
	'N'																		, ; //X7_SEEK
	''																		, ; //X7_ALIAS
	0																		, ; //X7_ORDEM
	''																		, ; //X7_CHAVE
	'U'																		, ; //X7_PROPRI
	''																		} ) //X7_CONDIC

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX7 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )

dbSelectArea( "SX7" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX7 )

	If !SX7->( dbSeek( PadR( aSX7[nI][1], nTamSeek ) + aSX7[nI][2] ) )

		If !( aSX7[nI][1] $ cAlias )
			cAlias += aSX7[nI][1] + "/"
			AutoGrLog( "Foi incluído o gatilho " + aSX7[nI][1] + "/" + aSX7[nI][2] )
		EndIf

		RecLock( "SX7", .T. )
		For nJ := 1 To Len( aSX7[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX7[nI][nJ] )
			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

		If SX3->( dbSeek( SX7->X7_CAMPO ) )
			RecLock( "SX3", .F. )
			SX3->X3_TRIGGER := "S"
			MsUnLock()
		EndIf

	EndIf
	oProcess:IncRegua2( "Atualizando Arquivos (SX7)..." )

Next nI

RestArea( aAreaSX3 )

AutoGrLog( CRLF + "Final da Atualização" + " SX7" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSXA
Função de processamento da gravação do SXA - Pastas

@author TOTVS Protheus
@since  09/07/2019
@obs    Gerado por EXPORDIC - V.6.0.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSXA()
Local aEstrut   := {}
Local aSXA      := {}
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nPosAgr   := 0
Local lAlterou  := .F.

AutoGrLog( "Ínicio da Atualização" + " SXA" + CRLF )

aEstrut := { "XA_ALIAS"  , "XA_ORDEM"  , "XA_DESCRIC", "XA_DESCSPA", "XA_DESCENG", "XA_AGRUP"  , "XA_TIPO"   , ;
             "XA_PROPRI" }


//
// Tabela SB1
//
aAdd( aSXA, { ;
	'SB1'																	, ; //XA_ALIAS
	'1'																		, ; //XA_ORDEM
	'Cadastrais'															, ; //XA_DESCRIC
	'De registro'															, ; //XA_DESCSPA
	'Records'																, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'S'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'SB1'																	, ; //XA_ALIAS
	'2'																		, ; //XA_ORDEM
	'Impostos'																, ; //XA_DESCRIC
	'Impuestos'																, ; //XA_DESCSPA
	'Taxes'																	, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'S'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'SB1'																	, ; //XA_ALIAS
	'3'																		, ; //XA_ORDEM
	'MRP / Suprimentos'														, ; //XA_DESCRIC
	'MRP / Suministros'														, ; //XA_DESCSPA
	'MRP / Supplies'														, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'S'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'SB1'																	, ; //XA_ALIAS
	'4'																		, ; //XA_ORDEM
	'C.Q.'																	, ; //XA_DESCRIC
	'C.C.'																	, ; //XA_DESCSPA
	'Q.C.'																	, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'S'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'SB1'																	, ; //XA_ALIAS
	'5'																		, ; //XA_ORDEM
	'Atendimento'															, ; //XA_DESCRIC
	'Atencion'																, ; //XA_DESCSPA
	'Servicing'																, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'S'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'SB1'																	, ; //XA_ALIAS
	'6'																		, ; //XA_ORDEM
	'Direitos autorais'														, ; //XA_DESCRIC
	'Derechos de Autor'														, ; //XA_DESCSPA
	'Copyright'																, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'S'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'SB1'																	, ; //XA_ALIAS
	'7'																		, ; //XA_ORDEM
	'Mat / Med'																, ; //XA_DESCRIC
	'Mat. / Med.'															, ; //XA_DESCSPA
	'Medical materials'														, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'S'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'SB1'																	, ; //XA_ALIAS
	'8'																		, ; //XA_ORDEM
	'Garantia Estendida'													, ; //XA_DESCRIC
	'Garantia Extendida'													, ; //XA_DESCSPA
	'Ext.Warranty'															, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'S'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'SB1'																	, ; //XA_ALIAS
	'9'																		, ; //XA_ORDEM
	'Contabil'																, ; //XA_DESCRIC
	'Contabil'																, ; //XA_DESCSPA
	'Contabil'																, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'SB1'																	, ; //XA_ALIAS
	'A'																		, ; //XA_ORDEM
	'Etiqueta'																, ; //XA_DESCRIC
	'Etiqueta'																, ; //XA_DESCSPA
	'Etiqueta'																, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

nPosAgr := aScan( aEstrut, { |x| AllTrim( x ) == "XA_AGRUP" } )

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSXA ) )

dbSelectArea( "SXA" )
dbSetOrder( 1 )

For nI := 1 To Len( aSXA )

	If SXA->( dbSeek( aSXA[nI][1] + aSXA[nI][2] ) )

		lAlterou := .F.

		While !SXA->( EOF() ).AND.  SXA->( XA_ALIAS + XA_ORDEM ) == aSXA[nI][1] + aSXA[nI][2]

			If SXA->XA_AGRUP == aSXA[nI][nPosAgr]
				RecLock( "SXA", .F. )
				For nJ := 1 To Len( aSXA[nI] )
					If FieldPos( aEstrut[nJ] ) > 0 .AND. Alltrim(AllToChar(SXA->( FieldGet( nJ ) ))) <> Alltrim(AllToChar(aSXA[nI][nJ]))
						FieldPut( FieldPos( aEstrut[nJ] ), aSXA[nI][nJ] )
						lAlterou := .T.
					EndIf
				Next nJ
				dbCommit()
				MsUnLock()
			EndIf

			SXA->( dbSkip() )

		End

		If lAlterou
			AutoGrLog( "Foi alterada a pasta " + aSXA[nI][1] + "/" + aSXA[nI][2] + "  " + aSXA[nI][3] )
		EndIf

	Else

		RecLock( "SXA", .T. )
		For nJ := 1 To Len( aSXA[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSXA[nI][nJ] )
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()

		AutoGrLog( "Foi incluída a pasta " + aSXA[nI][1] + "/" + aSXA[nI][2] + "  " + aSXA[nI][3] )

	EndIf

oProcess:IncRegua2( "Atualizando Arquivos (SXA)..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SXA" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSXB
Função de processamento da gravação do SXB - Consultas Padrao

@author TOTVS Protheus
@since  09/07/2019
@obs    Gerado por EXPORDIC - V.6.0.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSXB()
Local aEstrut   := {}
Local aSXB      := {}
Local cAlias    := ""
Local cMsg      := ""
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0

AutoGrLog( "Ínicio da Atualização" + " SXB" + CRLF )

aEstrut := { "XB_ALIAS"  , "XB_TIPO"   , "XB_SEQ"    , "XB_COLUNA" , "XB_DESCRI" , "XB_DESCSPA", "XB_DESCENG", ;
             "XB_WCONTEM", "XB_CONTEM" }


//
// Consulta SB1
//
aAdd( aSXB, { ;
	'SB1'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Produto'																, ; //XB_DESCRI
	'Producto'																, ; //XB_DESCSPA
	'Product'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SB1FA093SB1();Config;SBP->BP_BASE'										} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Descrição'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Grupo'																	, ; //XB_DESCRI
	'Grupo'																	, ; //XB_DESCSPA
	'Group'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Registra nuevo'														, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01#A010INCLUI#A010VISUL'												} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'B1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descrição'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'B1_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Código'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Code'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'B1_COD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Descrição'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'B1_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Grupo'																	, ; //XB_DESCRI
	'Grupo'																	, ; //XB_DESCSPA
	'Group'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'B1_GRUPO'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Descrição'																, ; //XB_DESCRI
	'Descripcion'															, ; //XB_DESCSPA
	'Description'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'B1_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SB1'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SB1->B1_COD'															} ) //XB_CONTEM

//
// Consulta SC2
//
aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Ordem de Produção'														, ; //XB_DESCRI
	'Orden de Produccion'													, ; //XB_DESCSPA
	'Production Order'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SC2'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'N·mero'																, ; //XB_DESCRI
	'Numero'																, ; //XB_DESCSPA
	'Number'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Produto'																, ; //XB_DESCRI
	'Producto'																, ; //XB_DESCSPA
	'Product'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'N·mero'																, ; //XB_DESCRI
	'Numero'																, ; //XB_DESCSPA
	'Number'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C2_NUM'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Item'																	, ; //XB_DESCRI
	'Item'																	, ; //XB_DESCSPA
	'Item'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C2_ITEM'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Sequência'																, ; //XB_DESCRI
	'Secuencia'																, ; //XB_DESCSPA
	'Sequence'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C2_SEQUEN'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Produto'																, ; //XB_DESCRI
	'Producto'																, ; //XB_DESCSPA
	'Product'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C2_PRODUTO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Saldo'																	, ; //XB_DESCRI
	'Saldo'																	, ; //XB_DESCSPA
	'Balance'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'aSC2Sld()'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Inic.Prev'																, ; //XB_DESCRI
	'Inicio Previsto'														, ; //XB_DESCSPA
	'Estimated Start'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C2_DATPRI'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'Entr.Prev'																, ; //XB_DESCRI
	'Entrega Prevista'														, ; //XB_DESCSPA
	'Estimated Delivery'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C2_DATPRF'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'08'																	, ; //XB_COLUNA
	'Entr.Real'																, ; //XB_DESCRI
	'Entrega Real'															, ; //XB_DESCSPA
	'Real Delivery'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C2_DATRF'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'09'																	, ; //XB_COLUNA
	'It. Grade'																, ; //XB_DESCRI
	'Item Cuadricula'														, ; //XB_DESCSPA
	'Grid item'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C2_ITEMGRD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'N·mero'																, ; //XB_DESCRI
	'Numero'																, ; //XB_DESCSPA
	'Number'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C2_NUM'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Item'																	, ; //XB_DESCRI
	'Item'																	, ; //XB_DESCSPA
	'Item'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C2_ITEM'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Sequência'																, ; //XB_DESCRI
	'Secuencia'																, ; //XB_DESCSPA
	'Sequence'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C2_SEQUEN'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Produto'																, ; //XB_DESCRI
	'Producto'																, ; //XB_DESCSPA
	'Product'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C2_PRODUTO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Saldo'																	, ; //XB_DESCRI
	'Saldo'																	, ; //XB_DESCSPA
	'Balance'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'aSC2Sld()'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Inic.Prev'																, ; //XB_DESCRI
	'Inicio Previsto'														, ; //XB_DESCSPA
	'Estimated Start'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C2_DATPRI'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'07'																	, ; //XB_COLUNA
	'Entr.Prev'																, ; //XB_DESCRI
	'Entrega Prevista'														, ; //XB_DESCSPA
	'Estimated Delivery'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C2_DATPRF'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'08'																	, ; //XB_COLUNA
	'Entr.Real'																, ; //XB_DESCRI
	'Entrega Real'															, ; //XB_DESCSPA
	'Real Delivery'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C2_DATRF'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'09'																	, ; //XB_COLUNA
	'It. Grade'																, ; //XB_DESCRI
	'Item Cuadricula'														, ; //XB_DESCSPA
	'Grid item'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C2_ITEMGRD'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SC2'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_ITEMGRD'				} ) //XB_CONTEM

//
// Consulta XVOLUM
//
aAdd( aSXB, { ;
	'XVOLUM'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'ITENS VOLUMES'															, ; //XB_DESCRI
	'ITENS VOLUMES'															, ; //XB_DESCSPA
	'ITENS VOLUMES'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SC6'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'XVOLUM'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Num. Pedido + Item +'													, ; //XB_DESCRI
	'Nro Pedido + Item +'													, ; //XB_DESCSPA
	'Order Number + Item'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'XVOLUM'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Num. Pedido'															, ; //XB_DESCRI
	'Nro Pedido'															, ; //XB_DESCSPA
	'Order Number'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C6_NUM'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'XVOLUM'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Item'																	, ; //XB_DESCRI
	'Item'																	, ; //XB_DESCSPA
	'Item'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C6_ITEM'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'XVOLUM'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Produto'																, ; //XB_DESCRI
	'Produto'																, ; //XB_DESCSPA
	'Produto'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C6_PRODUTO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'XVOLUM'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C6_DESCRI'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'XVOLUM'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Cliente'																, ; //XB_DESCRI
	'Cliente'																, ; //XB_DESCSPA
	'Cliente'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C6_CLI'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'XVOLUM'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Tienda'																, ; //XB_DESCSPA
	'Unit'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'C6_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'XVOLUM'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SC6->C6_NUM'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'XVOLUM'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SC6->C6_ITEM'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'XVOLUM'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SC6->C6_CLI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'XVOLUM'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'SC6->C6_LOJA'															} ) //XB_CONTEM

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSXB ) )

dbSelectArea( "SXB" )
dbSetOrder( 1 )

For nI := 1 To Len( aSXB )

	If !Empty( aSXB[nI][1] )

		If !SXB->( dbSeek( PadR( aSXB[nI][1], Len( SXB->XB_ALIAS ) ) + aSXB[nI][2] + aSXB[nI][3] + aSXB[nI][4] ) )

			If !( aSXB[nI][1] $ cAlias )
				cAlias += aSXB[nI][1] + "/"
				AutoGrLog( "Foi incluída a consulta padrão " + aSXB[nI][1] )
			EndIf

			RecLock( "SXB", .T. )

			For nJ := 1 To Len( aSXB[nI] )
				If FieldPos( aEstrut[nJ] ) > 0
					FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
				EndIf
			Next nJ

			dbCommit()
			MsUnLock()

		Else

			//
			// Verifica todos os campos
			//
			For nJ := 1 To Len( aSXB[nI] )

				//
				// Se o campo estiver diferente da estrutura
				//
				If aEstrut[nJ] == SXB->( FieldName( nJ ) ) .AND. ;
					!StrTran( AllToChar( SXB->( FieldGet( nJ ) ) ), " ", "" ) == ;
					 StrTran( AllToChar( aSXB[nI][nJ]            ), " ", "" )

					cMsg := "A consulta padrão " + aSXB[nI][1] + " está com o " + SXB->( FieldName( nJ ) ) + ;
					" com o conteúdo" + CRLF + ;
					"[" + RTrim( AllToChar( SXB->( FieldGet( nJ ) ) ) ) + "]" + CRLF + ;
					", e este é diferente do conteúdo" + CRLF + ;
					"[" + RTrim( AllToChar( aSXB[nI][nJ] ) ) + "]" + CRLF +;
					"Deseja substituir ? "

					If      lTodosSim
						nOpcA := 1
					ElseIf  lTodosNao
						nOpcA := 2
					Else
						nOpcA := Aviso( "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS", cMsg, { "Sim", "Não", "Sim p/Todos", "Não p/Todos" }, 3, "Diferença de conteúdo - SXB" )
						lTodosSim := ( nOpcA == 3 )
						lTodosNao := ( nOpcA == 4 )

						If lTodosSim
							nOpcA := 1
							lTodosSim := MsgNoYes( "Foi selecionada a opção de REALIZAR TODAS alterações no SXB e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma a ação [Sim p/Todos] ?" )
						EndIf

						If lTodosNao
							nOpcA := 2
							lTodosNao := MsgNoYes( "Foi selecionada a opção de NÃO REALIZAR nenhuma alteração no SXB que esteja diferente da base e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma esta ação [Não p/Todos]?" )
						EndIf

					EndIf

					If nOpcA == 1
						RecLock( "SXB", .F. )
						FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
						dbCommit()
						MsUnLock()

							If !( aSXB[nI][1] $ cAlias )
								cAlias += aSXB[nI][1] + "/"
								AutoGrLog( "Foi alterada a consulta padrão " + aSXB[nI][1] )
							EndIf

					EndIf

				EndIf

			Next

		EndIf

	EndIf

	oProcess:IncRegua2( "Atualizando Consultas Padrões (SXB)..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SXB" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX9
Função de processamento da gravação do SX9 - Relacionamento

@author TOTVS Protheus
@since  09/07/2019
@obs    Gerado por EXPORDIC - V.6.0.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX9()
Local aEstrut   := {}
Local aSX9      := {}
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nTamSeek  := Len( SX9->X9_DOM )

AutoGrLog( "Ínicio da Atualização" + " SX9" + CRLF )

aEstrut := { "X9_DOM"    , "X9_IDENT"  , "X9_CDOM"   , "X9_EXPDOM" , "X9_EXPCDOM", "X9_PROPRI" , "X9_LIGDOM" , ;
             "X9_LIGCDOM", "X9_CONDSQL", "X9_USEFIL" , "X9_VINFIL" , "X9_CHVFOR" , "X9_ENABLE" }


//
// Domínio SB1
//
aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'001'																	, ; //X9_IDENT
	'ED6'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'ED6_PROD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'002'																	, ; //X9_IDENT
	'VO8'																	, ; //X9_CDOM
	'B1_GRUPO+B1_CODITE'													, ; //X9_EXPDOM
	'VO8_GRUITE+VO8_CODITE'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'003'																	, ; //X9_IDENT
	'VS3'																	, ; //X9_CDOM
	'B1_GRUPO+B1_CODITE'													, ; //X9_EXPDOM
	'VS3_GRUITE+VS3_CODITE'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'004'																	, ; //X9_IDENT
	'VSD'																	, ; //X9_CDOM
	'B1_GRUPO+B1_CODITE'													, ; //X9_EXPDOM
	'VSD_GRUITE+VSD_CODITE'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'005'																	, ; //X9_IDENT
	'SCT'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CT_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'006'																	, ; //X9_IDENT
	'SD4'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'D4_COD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'007'																	, ; //X9_IDENT
	'SD8'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'D8_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'008'																	, ; //X9_IDENT
	'SFM'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'FM_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'009'																	, ; //X9_IDENT
	'AJC'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AJC_COD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'010'																	, ; //X9_IDENT
	'SG2'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'G2_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'011'																	, ; //X9_IDENT
	'ABG'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'ABG_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'012'																	, ; //X9_IDENT
	'QEA'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'QEA_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'013'																	, ; //X9_IDENT
	'AB7'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AB7_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'014'																	, ; //X9_IDENT
	'STG'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TG_CODIGO'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#TG_TIPOREG='P'"														, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'015'																	, ; //X9_IDENT
	'TOH'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TOH_CODEPI'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'016'																	, ; //X9_IDENT
	'VE3'																	, ; //X9_CDOM
	'B1_GRUPO+B1_CODITE'													, ; //X9_EXPDOM
	'VE3_GRUITE+VE3_CODITE'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'017'																	, ; //X9_IDENT
	'VE4'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'VE4_CDPRFD'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#VE4_CDPRFD<>'               '"										, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'018'																	, ; //X9_IDENT
	'AAB'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AAB_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'019'																	, ; //X9_IDENT
	'AFJ'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AFJ_COD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'020'																	, ; //X9_IDENT
	'AIC'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AIC_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'021'																	, ; //X9_IDENT
	'RA1'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'RA1_PROD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'022'																	, ; //X9_IDENT
	'EDA'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'EDA_ITEM'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'023'																	, ; //X9_IDENT
	'N06'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'N06_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'024'																	, ; //X9_IDENT
	'N07'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'N07_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'025'																	, ; //X9_IDENT
	'VO9'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'VO9_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'026'																	, ; //X9_IDENT
	'CFC'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CFC_CODPRD'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'027'																	, ; //X9_IDENT
	'TE0'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TE0_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'028'																	, ; //X9_IDENT
	'TDD'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TDD_COLET'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'029'																	, ; //X9_IDENT
	'VVT'																	, ; //X9_CDOM
	'B1_GRUPO+B1_CODITE'													, ; //X9_EXPDOM
	'VVT_GRUITE+VVT_CODITE'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'030'																	, ; //X9_IDENT
	'AFO'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AFO_COD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'031'																	, ; //X9_IDENT
	'MDD'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'MDD_PROD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'032'																	, ; //X9_IDENT
	'TBA'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TBA_CODRES'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'033'																	, ; //X9_IDENT
	'TBA'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TBA_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'034'																	, ; //X9_IDENT
	'AJI'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AJI_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'035'																	, ; //X9_IDENT
	'TQI'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TQI_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'036'																	, ; //X9_IDENT
	'TAX'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TAX_CODRES'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'037'																	, ; //X9_IDENT
	'TB0'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TB0_CODRES'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'038'																	, ; //X9_IDENT
	'SCW'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CW_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'039'																	, ; //X9_IDENT
	'DTK'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DTK_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'040'																	, ; //X9_IDENT
	'ACR'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'ACR_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'041'																	, ; //X9_IDENT
	'SLK'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'LK_CODIGO'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'042'																	, ; //X9_IDENT
	'TE2'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TE2_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'043'																	, ; //X9_IDENT
	'SA8'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'A8_COD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'044'																	, ; //X9_IDENT
	'CLY'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CLY_COD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'045'																	, ; //X9_IDENT
	'NK8'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'NK8_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'046'																	, ; //X9_IDENT
	'TL0'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TL0_EPIFIL'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'047'																	, ; //X9_IDENT
	'CZG'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CZG_CDAC'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'N'																		, ; //X9_USEFIL
	'N'																		, ; //X9_VINFIL
	'N'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'048'																	, ; //X9_IDENT
	'CZI'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CZI_PROD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'049'																	, ; //X9_IDENT
	'AB5'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AB5_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'050'																	, ; //X9_IDENT
	'NKO'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'NKO_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'051'																	, ; //X9_IDENT
	'SC0'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'C0_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'052'																	, ; //X9_IDENT
	'AFI'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AFI_COD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'053'																	, ; //X9_IDENT
	'F06'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'F06_CODINS'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'054'																	, ; //X9_IDENT
	'F06'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'F06_PRODEL'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'055'																	, ; //X9_IDENT
	'SBZ'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'BZ_COD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'N'																		, ; //X9_USEFIL
	'N'																		, ; //X9_VINFIL
	'N'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'056'																	, ; //X9_IDENT
	'MFJ'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'MFJ_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'057'																	, ; //X9_IDENT
	'CNE'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CNE_PRODSV'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'058'																	, ; //X9_IDENT
	'DCT'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DCT_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'059'																	, ; //X9_IDENT
	'TWA'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TWA_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'060'																	, ; //X9_IDENT
	'F2Q'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'F2Q_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'061'																	, ; //X9_IDENT
	'VV6'																	, ; //X9_CDOM
	'B1_GRUPO+B1_CODITE'													, ; //X9_EXPDOM
	'VV6_GRUITE+VV6_CODITE'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'062'																	, ; //X9_IDENT
	'FOL'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'FOL_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'063'																	, ; //X9_IDENT
	'VG8'																	, ; //X9_CDOM
	'B1_CODITE'																, ; //X9_EXPDOM
	'VG8_ITECAU'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'064'																	, ; //X9_IDENT
	'DCG'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DCG_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'065'																	, ; //X9_IDENT
	'SD2'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'D2_PRODFIN'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'066'																	, ; //X9_IDENT
	'VSS'																	, ; //X9_CDOM
	'B1_CODITE'																, ; //X9_EXPDOM
	'VSS_CODITE'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'067'																	, ; //X9_IDENT
	'TJB'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TJB_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'068'																	, ; //X9_IDENT
	'TUT'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TUT_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'069'																	, ; //X9_IDENT
	'BA3'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'BA3_CODSB1'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'070'																	, ; //X9_IDENT
	'DCN'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DCN_PROD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'071'																	, ; //X9_IDENT
	'SB8'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'B8_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'072'																	, ; //X9_IDENT
	'SBB'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'BB_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'073'																	, ; //X9_IDENT
	'SC3'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'C3_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'074'																	, ; //X9_IDENT
	'SC7'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'C7_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'075'																	, ; //X9_IDENT
	'SD6'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'D6_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'076'																	, ; //X9_IDENT
	'SD2'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'D2_COD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'077'																	, ; //X9_IDENT
	'ABH'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'ABH_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'078'																	, ; //X9_IDENT
	'ACQ'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'ACQ_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'079'																	, ; //X9_IDENT
	'ALR'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'ALR_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'080'																	, ; //X9_IDENT
	'SGR'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'GR_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'N'																		, ; //X9_USEFIL
	'N'																		, ; //X9_VINFIL
	'N'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'081'																	, ; //X9_IDENT
	'TD2'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TD2_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'082'																	, ; //X9_IDENT
	'VZ7'																	, ; //X9_CDOM
	'B1_CODITE'																, ; //X9_EXPDOM
	'VZ7_CODITE'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'083'																	, ; //X9_IDENT
	'QF2'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'QF2_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'084'																	, ; //X9_IDENT
	'SB3'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'B3_COD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'085'																	, ; //X9_IDENT
	'VG8'																	, ; //X9_CDOM
	'B1_GRUPO+B1_CODITE'													, ; //X9_EXPDOM
	'VG8_GRUITE+VG8_ITECAU'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'086'																	, ; //X9_IDENT
	'VG5'																	, ; //X9_CDOM
	'B1_GRUPO+B1_CODITE'													, ; //X9_EXPDOM
	'VG5_GRUITE+VG5_CODITE'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#VG5_GRUITE<>'    ' OR #VG5_CODITE<>'                           '"		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'087'																	, ; //X9_IDENT
	'SCL'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CL_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'088'																	, ; //X9_IDENT
	'DA1'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DA1_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'089'																	, ; //X9_IDENT
	'CNE'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CNE_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'090'																	, ; //X9_IDENT
	'QPB'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'QPB_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'091'																	, ; //X9_IDENT
	'ACL'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'ACL_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'092'																	, ; //X9_IDENT
	'AAC'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AAC_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'093'																	, ; //X9_IDENT
	'N55'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'N55_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'N'																		, ; //X9_USEFIL
	'N'																		, ; //X9_VINFIL
	'N'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'094'																	, ; //X9_IDENT
	'ED1'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'ED1_PROD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'095'																	, ; //X9_IDENT
	'DXE'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DXE_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'N'																		, ; //X9_USEFIL
	'N'																		, ; //X9_VINFIL
	'N'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'096'																	, ; //X9_IDENT
	'DXF'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DXF_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'N'																		, ; //X9_USEFIL
	'N'																		, ; //X9_VINFIL
	'N'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'097'																	, ; //X9_IDENT
	'BG9'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'BG9_CODSB1'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'098'																	, ; //X9_IDENT
	'ED8'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'ED8_COD_I'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'099'																	, ; //X9_IDENT
	'QPC'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'QPC_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'100'																	, ; //X9_IDENT
	'QP6'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'QP6_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'101'																	, ; //X9_IDENT
	'DCP'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DCP_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'102'																	, ; //X9_IDENT
	'TNX'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TNX_EPI'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'103'																	, ; //X9_IDENT
	'ABI'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'ABI_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'104'																	, ; //X9_IDENT
	'SG7'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'G7_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'105'																	, ; //X9_IDENT
	'ACP'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'ACP_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'106'																	, ; //X9_IDENT
	'SFK'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'FK_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'107'																	, ; //X9_IDENT
	'TP9'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TP9_CODEST'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'108'																	, ; //X9_IDENT
	'SAI'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AI_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#AI_PRODUTO<>'*              '"										, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'109'																	, ; //X9_IDENT
	'SB6'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'B6_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'110'																	, ; //X9_IDENT
	'AB8'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AB8_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'111'																	, ; //X9_IDENT
	'TFJ'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TFJ_GRPRH'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'112'																	, ; //X9_IDENT
	'TFJ'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TFJ_GRPMI'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'113'																	, ; //X9_IDENT
	'TFJ'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TFJ_GRPMC'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'114'																	, ; //X9_IDENT
	'TEZ'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TEZ_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'115'																	, ; //X9_IDENT
	'TEZ'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TEZ_ITPROD'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'116'																	, ; //X9_IDENT
	'SB2'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'B2_COD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'117'																	, ; //X9_IDENT
	'QE0'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'QE0_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'118'																	, ; //X9_IDENT
	'TDQ'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TDQ_CODEQP'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'119'																	, ; //X9_IDENT
	'TEK'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TEK_CODRES'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'120'																	, ; //X9_IDENT
	'QEC'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'QEC_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'121'																	, ; //X9_IDENT
	'QF3'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'QF3_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'122'																	, ; //X9_IDENT
	'TJZ'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TJZ_CODRES'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'123'																	, ; //X9_IDENT
	'MB8'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'MB8_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'124'																	, ; //X9_IDENT
	'CBA'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CBA_PROD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'125'																	, ; //X9_IDENT
	'CD0'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CD0_COD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'126'																	, ; //X9_IDENT
	'CLR'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CLR_PRDMOV'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'127'																	, ; //X9_IDENT
	'CLR'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CLR_PROD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'128'																	, ; //X9_IDENT
	'DE5'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DE5_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'129'																	, ; //X9_IDENT
	'NJJ'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'NJJ_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'130'																	, ; //X9_IDENT
	'NK6'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'NK6_CODPRC'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'131'																	, ; //X9_IDENT
	'NK6'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'NK6_CODPRP'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'132'																	, ; //X9_IDENT
	'G6A'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'G6A_CODPRD'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'133'																	, ; //X9_IDENT
	'SWD'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'WD_B1_COD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'134'																	, ; //X9_IDENT
	'SWD'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'WD_PRDSIS'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'135'																	, ; //X9_IDENT
	'CLU'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CLU_PROD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'136'																	, ; //X9_IDENT
	'TVJ'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TVJ_PROD01'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'137'																	, ; //X9_IDENT
	'TVJ'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TVJ_PROD02'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'138'																	, ; //X9_IDENT
	'TVJ'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TVJ_PROD03'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'139'																	, ; //X9_IDENT
	'TVJ'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TVJ_PROD04'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'140'																	, ; //X9_IDENT
	'TVJ'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TVJ_PROD05'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'141'																	, ; //X9_IDENT
	'TVJ'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TVJ_PROD06'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'142'																	, ; //X9_IDENT
	'TVJ'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TVJ_PROD07'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'143'																	, ; //X9_IDENT
	'CLU'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CLU_PRDINS'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'144'																	, ; //X9_IDENT
	'D13'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'D13_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'145'																	, ; //X9_IDENT
	'EES'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'EES_COD_I'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'146'																	, ; //X9_IDENT
	'D08'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'D08_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'147'																	, ; //X9_IDENT
	'VQG'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'VQG_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'148'																	, ; //X9_IDENT
	'NNI'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'NNI_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'149'																	, ; //X9_IDENT
	'TET'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TET_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'150'																	, ; //X9_IDENT
	'SDX'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DX_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'151'																	, ; //X9_IDENT
	'CGA'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CGA_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'152'																	, ; //X9_IDENT
	'SUB'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'UB_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'153'																	, ; //X9_IDENT
	'AI2'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AI2_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'154'																	, ; //X9_IDENT
	'MFU'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'MFU_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'N'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'155'																	, ; //X9_IDENT
	'COC'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'COC_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'156'																	, ; //X9_IDENT
	'ST9'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'T9_CODESTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'157'																	, ; //X9_IDENT
	'SAB'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AB_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'158'																	, ; //X9_IDENT
	'SHE'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'HE_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'159'																	, ; //X9_IDENT
	'SGC'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'GC_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'160'																	, ; //X9_IDENT
	'AA4'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AA4_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'161'																	, ; //X9_IDENT
	'AA7'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AA7_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'162'																	, ; //X9_IDENT
	'SBL'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'BL_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'163'																	, ; //X9_IDENT
	'SCQ'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CQ_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'164'																	, ; //X9_IDENT
	'SDA'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DA_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'165'																	, ; //X9_IDENT
	'AA4'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AA4_PRODAC'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'166'																	, ; //X9_IDENT
	'AAL'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AAL_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'167'																	, ; //X9_IDENT
	'AAL'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AAL_CODCOM'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'168'																	, ; //X9_IDENT
	'AAO'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AAO_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'169'																	, ; //X9_IDENT
	'DCF'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DCF_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'170'																	, ; //X9_IDENT
	'CD4'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CD4_COD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'171'																	, ; //X9_IDENT
	'BLR'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'BLR_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'172'																	, ; //X9_IDENT
	'NJT'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'NJT_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'173'																	, ; //X9_IDENT
	'NNH'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'NNH_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'174'																	, ; //X9_IDENT
	'NNO'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'NNO_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'175'																	, ; //X9_IDENT
	'NK3'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'NK3_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'176'																	, ; //X9_IDENT
	'QQK'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'QQK_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'177'																	, ; //X9_IDENT
	'VQH'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'VQH_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'178'																	, ; //X9_IDENT
	'NL0'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'NL0_PROD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'N'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'N'																		, ; //X9_USEFIL
	'N'																		, ; //X9_VINFIL
	'N'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'179'																	, ; //X9_IDENT
	'NNK'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'NNK_PROALT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'180'																	, ; //X9_IDENT
	'D0Q'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'D0Q_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'181'																	, ; //X9_IDENT
	'D0Q'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'D0Q_PRDORI'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'182'																	, ; //X9_IDENT
	'VVW'																	, ; //X9_CDOM
	'B1_GRUPO+B1_CODITE'													, ; //X9_EXPDOM
	'VVW_GRUITE+VVW_CODITE'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#VVW_GRUITE<>'    ' OR #VVW_CODITE<>'                           '"		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'183'																	, ; //X9_IDENT
	'VSJ'																	, ; //X9_CDOM
	'B1_CODITE'																, ; //X9_EXPDOM
	'VSJ_CODITE'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'184'																	, ; //X9_IDENT
	'DH9'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DH9_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'N'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'185'																	, ; //X9_IDENT
	'D0G'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'D0G_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'186'																	, ; //X9_IDENT
	'DCF'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DCF_PRDORI'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'187'																	, ; //X9_IDENT
	'QE6'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'QE6_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'188'																	, ; //X9_IDENT
	'EE9'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'EE9_COD_I'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'189'																	, ; //X9_IDENT
	'SW1'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'W1_COD_I'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'190'																	, ; //X9_IDENT
	'N38'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'N38_CODIGO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'N'																		, ; //X9_USEFIL
	'N'																		, ; //X9_VINFIL
	'N'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'191'																	, ; //X9_IDENT
	'QQ6'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'QQ6_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'192'																	, ; //X9_IDENT
	'N08'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'N08_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'193'																	, ; //X9_IDENT
	'SS5'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'S5_COD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'194'																	, ; //X9_IDENT
	'EX5'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'EX5_COD_I'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'195'																	, ; //X9_IDENT
	'VE8'																	, ; //X9_CDOM
	'B1_GRUPO+B1_CODITE'													, ; //X9_EXPDOM
	'VE8_GRUITE+VE8_CODITE'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'196'																	, ; //X9_IDENT
	'VE8'																	, ; //X9_CDOM
	'B1_GRUPO+B1_CODITE'													, ; //X9_EXPDOM
	'VE8_GRUKIT+VE8_CODKIT'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#VE8_GRUKIT<>'    ' OR #VE8_CODKIT<>'                           '"		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'197'																	, ; //X9_IDENT
	'VEN'																	, ; //X9_CDOM
	'B1_GRUPO+B1_CODITE'													, ; //X9_EXPDOM
	'VEN_GRUITE+VEN_CODITE'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#VEN_GRUITE<>'    ' OR #VEN_CODITE<>'                           '"		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'198'																	, ; //X9_IDENT
	'COO'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'COO_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'199'																	, ; //X9_IDENT
	'FL7'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'FL7_PROD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'200'																	, ; //X9_IDENT
	'FL9'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'FL9_PROD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'201'																	, ; //X9_IDENT
	'SFT'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'FT_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'202'																	, ; //X9_IDENT
	'AGW'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AGW_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'203'																	, ; //X9_IDENT
	'VZZ'																	, ; //X9_CDOM
	'B1_CODITE'																, ; //X9_EXPDOM
	'VZZ_CODITE'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'204'																	, ; //X9_IDENT
	'VEN'																	, ; //X9_CDOM
	'B1_CODITE'																, ; //X9_EXPDOM
	'VEN_CODITE'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'205'																	, ; //X9_IDENT
	'AH5'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AH5_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'206'																	, ; //X9_IDENT
	'TCQ'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TCQ_CODRES'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'207'																	, ; //X9_IDENT
	'CX1'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CX1_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'208'																	, ; //X9_IDENT
	'MGB'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'MGB_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'N'																		, ; //X9_USEFIL
	'N'																		, ; //X9_VINFIL
	'N'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'209'																	, ; //X9_IDENT
	'F0H'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'F0H_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'210'																	, ; //X9_IDENT
	'CLV'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CLV_PROD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'211'																	, ; //X9_IDENT
	'CLV'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CLV_PRDINS'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'212'																	, ; //X9_IDENT
	'ADC'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'ADC_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'213'																	, ; //X9_IDENT
	'VE3'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'VE3_CODITE'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'214'																	, ; //X9_IDENT
	'VS3'																	, ; //X9_CDOM
	'B1_CODITE'																, ; //X9_EXPDOM
	'VS3_CODITE'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'215'																	, ; //X9_IDENT
	'TC0'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TC0_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'216'																	, ; //X9_IDENT
	'TLW'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TLW_CODEPI'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'217'																	, ; //X9_IDENT
	'ALN'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'ALN_PROIND'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'218'																	, ; //X9_IDENT
	'TPK'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TPK_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'219'																	, ; //X9_IDENT
	'STR'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TR_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#TR_TIPOPRO='S'"														, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'220'																	, ; //X9_IDENT
	'TNF'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TNF_CODEPI'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'221'																	, ; //X9_IDENT
	'SGF'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'GF_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'222'																	, ; //X9_IDENT
	'SGF'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'GF_COMP'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'223'																	, ; //X9_IDENT
	'STL'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TL_CODIGO'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#TL_TIPOREG='P'"														, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'224'																	, ; //X9_IDENT
	'CPI'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CPI_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'225'																	, ; //X9_IDENT
	'FLA'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'FLA_PROD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'226'																	, ; //X9_IDENT
	'MG3'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'MG3_CODPRD'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'227'																	, ; //X9_IDENT
	'SDF'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DF_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'228'																	, ; //X9_IDENT
	'NJC'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'NJC_PROD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'229'																	, ; //X9_IDENT
	'TGU'																	, ; //X9_CDOM
	'B1_FILIAL+B1_COD'														, ; //X9_EXPDOM
	'TGU_FILIAL+TGU_PROD'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'230'																	, ; //X9_IDENT
	'D38'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'D38_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'N'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'231'																	, ; //X9_IDENT
	'DHE'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DHE_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'N'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'232'																	, ; //X9_IDENT
	'DCY'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DCY_PROD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'233'																	, ; //X9_IDENT
	'SL2'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'L2_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'234'																	, ; //X9_IDENT
	'GHQ'																	, ; //X9_CDOM
	'B1_FILIAL+B1_COD'														, ; //X9_EXPDOM
	'GHQ_FILIAL+GHQ_PRODGE'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'N'																		, ; //X9_USEFIL
	'N'																		, ; //X9_VINFIL
	'N'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'235'																	, ; //X9_IDENT
	'F0Q'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'F0Q_CODIGO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'236'																	, ; //X9_IDENT
	'MBF'																	, ; //X9_CDOM
	'B1_FILIAL+B1_COD'														, ; //X9_EXPDOM
	'MBF_FILIAL+MBF_PRDGAR'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'N'																		, ; //X9_USEFIL
	'N'																		, ; //X9_VINFIL
	'N'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'237'																	, ; //X9_IDENT
	'CF8'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CF8_ITEM'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'N'																		, ; //X9_USEFIL
	'N'																		, ; //X9_VINFIL
	'N'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'238'																	, ; //X9_IDENT
	'NJF'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'NJF_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'239'																	, ; //X9_IDENT
	'NZG'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'NZG_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'240'																	, ; //X9_IDENT
	'D11'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'D11_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'241'																	, ; //X9_IDENT
	'D11'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'D11_PRDORI'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'242'																	, ; //X9_IDENT
	'D11'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'D11_PRDCMP'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'243'																	, ; //X9_IDENT
	'TZZ'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TZZ_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'244'																	, ; //X9_IDENT
	'NJR'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'NJR_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'245'																	, ; //X9_IDENT
	'AHG'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AHG_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'246'																	, ; //X9_IDENT
	'MBF'																	, ; //X9_CDOM
	'B1_FILIAL+B1_COD'														, ; //X9_EXPDOM
	'MBF_FILIAL+MBF_PRODPR'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'N'																		, ; //X9_USEFIL
	'N'																		, ; //X9_VINFIL
	'N'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'247'																	, ; //X9_IDENT
	'F04'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'F04_PROD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'248'																	, ; //X9_IDENT
	'F0M'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'F0M_CODIGO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'249'																	, ; //X9_IDENT
	'AH2'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AH2_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'250'																	, ; //X9_IDENT
	'NKN'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'NKN_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'251'																	, ; //X9_IDENT
	'D0E'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'D0E_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'252'																	, ; //X9_IDENT
	'D12'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'D12_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'253'																	, ; //X9_IDENT
	'D0F'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'D0F_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'254'																	, ; //X9_IDENT
	'DH7'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DH7_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'N'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'255'																	, ; //X9_IDENT
	'SYQ'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'YQ_PRDSIS'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'256'																	, ; //X9_IDENT
	'D09'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'D09_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'257'																	, ; //X9_IDENT
	'SUG'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'UG_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'258'																	, ; //X9_IDENT
	'ABC'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'ABC_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'259'																	, ; //X9_IDENT
	'SDD'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DD_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'260'																	, ; //X9_IDENT
	'NJV'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'NJV_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'261'																	, ; //X9_IDENT
	'NJV'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'NJV_CODSPD'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'262'																	, ; //X9_IDENT
	'ABE'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'ABE_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'263'																	, ; //X9_IDENT
	'SG1'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'G1_COD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'264'																	, ; //X9_IDENT
	'SG1'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'G1_COMP'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'265'																	, ; //X9_IDENT
	'SG4'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'G4_CODIGO'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'266'																	, ; //X9_IDENT
	'NKG'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'NKG_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'267'																	, ; //X9_IDENT
	'EC6'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'EC6_PRDSIS'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'268'																	, ; //X9_IDENT
	'CGB'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CGB_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'269'																	, ; //X9_IDENT
	'SL3'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'L3_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'270'																	, ; //X9_IDENT
	'NNT'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'NNT_PROD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'271'																	, ; //X9_IDENT
	'NNT'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'NNT_PRODD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'272'																	, ; //X9_IDENT
	'ADZ'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'ADZ_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'273'																	, ; //X9_IDENT
	'NPH'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'NPH_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'274'																	, ; //X9_IDENT
	'SHF'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'HF_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'275'																	, ; //X9_IDENT
	'TJ9'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TJ9_CODEPI'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'276'																	, ; //X9_IDENT
	'BQC'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'BQC_CODSB1'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'277'																	, ; //X9_IDENT
	'DCZ'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DCZ_PROD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'278'																	, ; //X9_IDENT
	'SCA'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CA_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'279'																	, ; //X9_IDENT
	'CPJ'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CPJ_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'280'																	, ; //X9_IDENT
	'SBA'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'BA_COD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'281'																	, ; //X9_IDENT
	'SD5'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'D5_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#D5_ESTORNO=' '"														, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'282'																	, ; //X9_IDENT
	'QEN'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'QEN_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'283'																	, ; //X9_IDENT
	'ADB'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'ADB_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'284'																	, ; //X9_IDENT
	'EE8'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'EE8_COD_I'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'285'																	, ; //X9_IDENT
	'EXH'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'EXH_COD_I'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'286'																	, ; //X9_IDENT
	'ED3'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'ED3_PROD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'287'																	, ; //X9_IDENT
	'VB8'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'VB8_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'288'																	, ; //X9_IDENT
	'VO3'																	, ; //X9_CDOM
	'B1_CODITE'																, ; //X9_EXPDOM
	'VO3_CODITE'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'289'																	, ; //X9_IDENT
	'EJX'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'EJX_ITEM'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'N'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'290'																	, ; //X9_IDENT
	'VV2'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'VV2_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'291'																	, ; //X9_IDENT
	'VAJ'																	, ; //X9_CDOM
	'B1_CODITE'																, ; //X9_EXPDOM
	'VAJ_CODPEC'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'292'																	, ; //X9_IDENT
	'SDW'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DW_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'293'																	, ; //X9_IDENT
	'MEU'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'MEU_CODIGO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'294'																	, ; //X9_IDENT
	'CO2'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CO2_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'295'																	, ; //X9_IDENT
	'DVJ'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DVJ_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'296'																	, ; //X9_IDENT
	'TFJ'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TFJ_GRPLE'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'297'																	, ; //X9_IDENT
	'CD6'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CD6_COD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'298'																	, ; //X9_IDENT
	'DW1'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DW1_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'299'																	, ; //X9_IDENT
	'TLY'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TLY_CODEPI'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'300'																	, ; //X9_IDENT
	'MEV'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'MEV_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'301'																	, ; //X9_IDENT
	'F01'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'F01_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'302'																	, ; //X9_IDENT
	'D0S'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'D0S_PRDORI'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'303'																	, ; //X9_IDENT
	'D0S'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'D0S_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'304'																	, ; //X9_IDENT
	'DV1'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DV1_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'305'																	, ; //X9_IDENT
	'NJA'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'NJA_PROD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'306'																	, ; //X9_IDENT
	'NJX'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'NJX_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'307'																	, ; //X9_IDENT
	'BO6'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'BO6_CODBRD'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'308'																	, ; //X9_IDENT
	'CE1'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CE1_PROISS'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'309'																	, ; //X9_IDENT
	'CDN'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CDN_PROD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'310'																	, ; //X9_IDENT
	'TW9'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TW9_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'311'																	, ; //X9_IDENT
	'D32'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'D32_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'N'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'312'																	, ; //X9_IDENT
	'SB1'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'B1_CODANT'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'313'																	, ; //X9_IDENT
	'VMB'																	, ; //X9_CDOM
	'B1_GRUPO+B1_CODITE'													, ; //X9_EXPDOM
	'VMB_GRUITE+VMB_CODITE'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'314'																	, ; //X9_IDENT
	'SC4'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'C4_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'315'																	, ; //X9_IDENT
	'SB1'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'B1_PRDORI'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'316'																	, ; //X9_IDENT
	'SB1'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'B1_ALTER'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'317'																	, ; //X9_IDENT
	'SBE'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'BE_CODPRO'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'318'																	, ; //X9_IDENT
	'SCE'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CE_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'319'																	, ; //X9_IDENT
	'SA5'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'A5_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'320'																	, ; //X9_IDENT
	'SUD'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'UD_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'321'																	, ; //X9_IDENT
	'SC8'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'C8_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'322'																	, ; //X9_IDENT
	'AAI'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AAI_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'323'																	, ; //X9_IDENT
	'SC1'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'C1_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'324'																	, ; //X9_IDENT
	'VE6'																	, ; //X9_CDOM
	'B1_GRUPO+B1_CODITE'													, ; //X9_EXPDOM
	'VE6_GRUITE+VE6_CODITE'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'325'																	, ; //X9_IDENT
	'VO3'																	, ; //X9_CDOM
	'B1_GRUPO+B1_CODITE'													, ; //X9_EXPDOM
	'VO3_GRUITE+VO3_CODITE'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'326'																	, ; //X9_IDENT
	'VAJ'																	, ; //X9_CDOM
	'B1_GRUPO+B1_CODITE'													, ; //X9_EXPDOM
	'VAJ_GRUPEC+VAJ_CODPEC'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'327'																	, ; //X9_IDENT
	'ED7'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'ED7_DE'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'328'																	, ; //X9_IDENT
	'ED7'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'ED7_PARA'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'329'																	, ; //X9_IDENT
	'TE1'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TE1_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'330'																	, ; //X9_IDENT
	'MEK'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'MEK_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'331'																	, ; //X9_IDENT
	'MFT'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'MFT_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'N'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'N'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'332'																	, ; //X9_IDENT
	'COP'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'COP_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'333'																	, ; //X9_IDENT
	'STT'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TT_CODIGO'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#TT_TIPOREG='P'"														, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'334'																	, ; //X9_IDENT
	'ACV'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'ACV_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'335'																	, ; //X9_IDENT
	'CNB'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CNB_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'336'																	, ; //X9_IDENT
	'VFB'																	, ; //X9_CDOM
	'B1_GRUPO+B1_CODITE'													, ; //X9_EXPDOM
	'VFB_GRUITE+VFB_CODITE'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#VFB_GRUITE<>'    ' OR #VFB_CODITE<>'                           '"		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'337'																	, ; //X9_IDENT
	'QQ2'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'QQ2_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'338'																	, ; //X9_IDENT
	'FL8'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'FL8_PROD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'339'																	, ; //X9_IDENT
	'TIK'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TIK_EPI'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'340'																	, ; //X9_IDENT
	'SS9'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'S9_CODPRD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'341'																	, ; //X9_IDENT
	'SE1'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'E1_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'342'																	, ; //X9_IDENT
	'DJ5'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DJ5_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'343'																	, ; //X9_IDENT
	'DH6'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DH6_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'N'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'344'																	, ; //X9_IDENT
	'CNB'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CNB_PRODSV'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'345'																	, ; //X9_IDENT
	'AF9'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AF9_PRODFA'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'346'																	, ; //X9_IDENT
	'SCY'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CY_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'347'																	, ; //X9_IDENT
	'AA6'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AA6_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'348'																	, ; //X9_IDENT
	'AAN'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AAN_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'349'																	, ; //X9_IDENT
	'EDD'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'EDD_ITEM'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'350'																	, ; //X9_IDENT
	'EDD'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'EDD_PROD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'351'																	, ; //X9_IDENT
	'ED4'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'ED4_ITEM'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'352'																	, ; //X9_IDENT
	'AIB'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AIB_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'353'																	, ; //X9_IDENT
	'AA6'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AA6_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'354'																	, ; //X9_IDENT
	'AB2'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AB2_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'355'																	, ; //X9_IDENT
	'ABA'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'ABA_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'356'																	, ; //X9_IDENT
	'SD1'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'D1_COD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'357'																	, ; //X9_IDENT
	'SU1'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'U1_ACESSOR'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'358'																	, ; //X9_IDENT
	'SDB'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DB_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'359'																	, ; //X9_IDENT
	'SUF'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'UF_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'360'																	, ; //X9_IDENT
	'SS6'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'S6_COD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'361'																	, ; //X9_IDENT
	'SGI'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'GI_PRODORI'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'362'																	, ; //X9_IDENT
	'SGI'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'GI_PRODALT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'363'																	, ; //X9_IDENT
	'TC8'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TC8_CODRES'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'364'																	, ; //X9_IDENT
	'TCP'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TCP_CODRES'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'365'																	, ; //X9_IDENT
	'CDW'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CDW_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'366'																	, ; //X9_IDENT
	'CDU'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CDU_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'367'																	, ; //X9_IDENT
	'SH3'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'H3_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'368'																	, ; //X9_IDENT
	'ACX'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'ACX_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'369'																	, ; //X9_IDENT
	'TPY'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TPY_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'370'																	, ; //X9_IDENT
	'STY'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TY_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#TY_TIPOPRO='S'"														, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'371'																	, ; //X9_IDENT
	'EX6'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'EX6_COD_I'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'372'																	, ; //X9_IDENT
	'EXN'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'EXN_PROD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'373'																	, ; //X9_IDENT
	'AH4'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AH4_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'374'																	, ; //X9_IDENT
	'DT0'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DT0_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'375'																	, ; //X9_IDENT
	'DT1'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DT1_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'376'																	, ; //X9_IDENT
	'AH1'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AH1_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'377'																	, ; //X9_IDENT
	'TAS'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TAS_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'378'																	, ; //X9_IDENT
	'VG6'																	, ; //X9_CDOM
	'B1_GRUPO+B1_CODITE'													, ; //X9_EXPDOM
	'VG6_GRUITE+VG6_CODITE'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#VG6_GRUITE<>'    ' OR #VG6_CODITE<>'                           '"		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'379'																	, ; //X9_IDENT
	'ED2'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'ED2_ITEM'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'380'																	, ; //X9_IDENT
	'ED2'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'ED2_PROD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'381'																	, ; //X9_IDENT
	'VEH'																	, ; //X9_CDOM
	'B1_GRUPO+B1_CODITE'													, ; //X9_EXPDOM
	'VEH_GRUKIT+VEH_CODKIT'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'382'																	, ; //X9_IDENT
	'TPG'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TPG_CODIGO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#TPG_TIPORE='P'"														, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'383'																	, ; //X9_IDENT
	'CF6'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CF6_ITEM'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'384'																	, ; //X9_IDENT
	'NZC'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'NZC_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'385'																	, ; //X9_IDENT
	'ADJ'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'ADJ_PROD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'386'																	, ; //X9_IDENT
	'CZJ'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CZJ_PROD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'387'																	, ; //X9_IDENT
	'G3Q'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'G3Q_PROD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'388'																	, ; //X9_IDENT
	'TWY'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TWY_CODINT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'N'																		, ; //X9_USEFIL
	'N'																		, ; //X9_VINFIL
	'N'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'389'																	, ; //X9_IDENT
	'TWY'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TWY_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'N'																		, ; //X9_USEFIL
	'N'																		, ; //X9_VINFIL
	'N'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'390'																	, ; //X9_IDENT
	'QPA'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'QPA_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'391'																	, ; //X9_IDENT
	'SD3'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'D3_COD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'392'																	, ; //X9_IDENT
	'AB4'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AB4_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'393'																	, ; //X9_IDENT
	'AF3'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AF3_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'394'																	, ; //X9_IDENT
	'AE8'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AE8_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'395'																	, ; //X9_IDENT
	'SC6'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'C6_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'396'																	, ; //X9_IDENT
	'AD1'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AD1_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'397'																	, ; //X9_IDENT
	'FLB'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'FLB_PROD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'398'																	, ; //X9_IDENT
	'AE8'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AE8_PRDREA'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'399'																	, ; //X9_IDENT
	'MFL'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'MFL_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'400'																	, ; //X9_IDENT
	'TC4'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TC4_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'401'																	, ; //X9_IDENT
	'SC6'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'C6_PRODFIN'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'402'																	, ; //X9_IDENT
	'VZ6'																	, ; //X9_CDOM
	'B1_CODITE'																, ; //X9_EXPDOM
	'VZ6_CODITE'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'403'																	, ; //X9_IDENT
	'VG6'																	, ; //X9_CDOM
	'B1_CODITE'																, ; //X9_EXPDOM
	'VG6_CODITE'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'404'																	, ; //X9_IDENT
	'SG5'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'G5_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'405'																	, ; //X9_IDENT
	'TY8'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TY8_CODEPI'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'406'																	, ; //X9_IDENT
	'NN1'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'NN1_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'407'																	, ; //X9_IDENT
	'SH6'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'H6_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'408'																	, ; //X9_IDENT
	'N3A'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'N3A_CODIGO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'409'																	, ; //X9_IDENT
	'DX0'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DX0_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'410'																	, ; //X9_IDENT
	'DXI'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DXI_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'N'																		, ; //X9_USEFIL
	'N'																		, ; //X9_VINFIL
	'N'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'411'																	, ; //X9_IDENT
	'DXL'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DXL_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'412'																	, ; //X9_IDENT
	'CD7'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CD7_COD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'413'																	, ; //X9_IDENT
	'SB0'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'B0_COD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'414'																	, ; //X9_IDENT
	'AE2'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AE2_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'415'																	, ; //X9_IDENT
	'EYY'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'EYY_D1PROD'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'416'																	, ; //X9_IDENT
	'TEM'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TEM_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'417'																	, ; //X9_IDENT
	'AA3'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AA3_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'418'																	, ; //X9_IDENT
	'VQ3'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'VQ3_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'419'																	, ; //X9_IDENT
	'CON'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CON_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'420'																	, ; //X9_IDENT
	'SAE'																	, ; //X9_CDOM
	'B1_ADMIN'																, ; //X9_EXPDOM
	'AE_COD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'421'																	, ; //X9_IDENT
	'MFR'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'MFR_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'422'																	, ; //X9_IDENT
	'TF5'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TF5_CODRES'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'N'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'423'																	, ; //X9_IDENT
	'F3K'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'F3K_PROD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'424'																	, ; //X9_IDENT
	'AJA'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AJA_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'425'																	, ; //X9_IDENT
	'QI2'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'QI2_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'426'																	, ; //X9_IDENT
	'SB9'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'B9_COD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'427'																	, ; //X9_IDENT
	'SB5'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'B5_COD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'428'																	, ; //X9_IDENT
	'BA1'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'BA1_CODSB1'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'429'																	, ; //X9_IDENT
	'BT5'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'BT5_CODSB1'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'430'																	, ; //X9_IDENT
	'AAH'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AAH_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'431'																	, ; //X9_IDENT
	'AFA'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AFA_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'432'																	, ; //X9_IDENT
	'SS4'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'S4_CODANT'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'433'																	, ; //X9_IDENT
	'SCP'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CP_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'434'																	, ; //X9_IDENT
	'AAK'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AAK_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'435'																	, ; //X9_IDENT
	'AAK'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AAK_CODCOM'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'436'																	, ; //X9_IDENT
	'SLN'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'LN_COD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'437'																	, ; //X9_IDENT
	'CD2'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CD2_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'438'																	, ; //X9_IDENT
	'DXC'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DXC_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'N'																		, ; //X9_USEFIL
	'N'																		, ; //X9_VINFIL
	'N'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'439'																	, ; //X9_IDENT
	'NT3'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'NT3_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'440'																	, ; //X9_IDENT
	'EJZ'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'EJZ_ITEM'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'N'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'441'																	, ; //X9_IDENT
	'SDU'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DU_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'442'																	, ; //X9_IDENT
	'SGQ'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'GQ_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'443'																	, ; //X9_IDENT
	'SDR'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DR_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'444'																	, ; //X9_IDENT
	'DVC'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DVC_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'445'																	, ; //X9_IDENT
	'TI3'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TI3_CODEPI'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'446'																	, ; //X9_IDENT
	'SS4'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'S4_PRDORI'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'447'																	, ; //X9_IDENT
	'VOK'																	, ; //X9_CDOM
	'B1_GRUPO+B1_CODITE'													, ; //X9_EXPDOM
	'VOK_GRUITE+VOK_CODITE'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'448'																	, ; //X9_IDENT
	'EDC'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'EDC_ITEM'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'449'																	, ; //X9_IDENT
	'EDC'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'EDC_PROD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'450'																	, ; //X9_IDENT
	'N30'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'N30_VACINA'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'451'																	, ; //X9_IDENT
	'TCI'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TCI_CODRES'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'452'																	, ; //X9_IDENT
	'VE9'																	, ; //X9_CDOM
	'B1_GRUPO+B1_CODITE'													, ; //X9_EXPDOM
	'VE9_GRUITE+VE9_ITEANT'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#VE9_GRUITE<>'    ' OR #VE9_ITEANT<>'                           '"		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'453'																	, ; //X9_IDENT
	'VF8'																	, ; //X9_CDOM
	'B1_GRUPO+B1_CODITE'													, ; //X9_EXPDOM
	'VF8_GRUITE+VF8_CODITE'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'454'																	, ; //X9_IDENT
	'SBH'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'BH_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'455'																	, ; //X9_IDENT
	'SJ3'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'J3_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'456'																	, ; //X9_IDENT
	'NJM'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'NJM_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'457'																	, ; //X9_IDENT
	'CLT'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CLT_INSUMO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'458'																	, ; //X9_IDENT
	'CLT'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CLT_PRDDST'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'459'																	, ; //X9_IDENT
	'CLW'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CLW_PROD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	''																		, ; //X9_USEFIL
	''																		, ; //X9_VINFIL
	''																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'460'																	, ; //X9_IDENT
	'DXC'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DXC_PRDPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'N'																		, ; //X9_USEFIL
	'N'																		, ; //X9_VINFIL
	'N'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'461'																	, ; //X9_IDENT
	'GW3'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'GW3_PRITDF'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'N'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'462'																	, ; //X9_IDENT
	'MG8'																	, ; //X9_CDOM
	'B1_FILIAL+B1_COD'														, ; //X9_EXPDOM
	'MG8_FILIAL+MG8_PRDSB1'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'N'																		, ; //X9_USEFIL
	'N'																		, ; //X9_VINFIL
	'N'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'463'																	, ; //X9_IDENT
	'MG8'																	, ; //X9_CDOM
	'B1_FILIAL+B1_COD'														, ; //X9_EXPDOM
	'MG8_FILIAL+MG8_PRDSF'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'N'																		, ; //X9_USEFIL
	'N'																		, ; //X9_VINFIL
	'N'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'464'																	, ; //X9_IDENT
	'NJH'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'NJH_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'465'																	, ; //X9_IDENT
	'AON'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AON_CHAVE'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	"#AON_ENTIDA='SB1'"														, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'466'																	, ; //X9_IDENT
	'D14'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'D14_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'467'																	, ; //X9_IDENT
	'D07'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'D07_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'468'																	, ; //X9_IDENT
	'VQM'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'VQM_PRODB1'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'469'																	, ; //X9_IDENT
	'D14'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'D14_PRDORI'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'470'																	, ; //X9_IDENT
	'SC9'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'C9_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'471'																	, ; //X9_IDENT
	'AB9'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'AB9_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'472'																	, ; //X9_IDENT
	'SC2'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'C2_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'473'																	, ; //X9_IDENT
	'SU2'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'U2_COD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'474'																	, ; //X9_IDENT
	'ACN'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'ACN_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'475'																	, ; //X9_IDENT
	'SUW'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'UW_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'476'																	, ; //X9_IDENT
	'SA7'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'A7_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'477'																	, ; //X9_IDENT
	'SCK'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'CK_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'478'																	, ; //X9_IDENT
	'QEB'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'QEB_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'479'																	, ; //X9_IDENT
	'SBC'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'BC_CODDEST'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'480'																	, ; //X9_IDENT
	'SBD'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'BD_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'481'																	, ; //X9_IDENT
	'DCH'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'DCH_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'482'																	, ; //X9_IDENT
	'SD7'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'D7_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'483'																	, ; //X9_IDENT
	'SBC'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'BC_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'484'																	, ; //X9_IDENT
	'ABD'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'ABD_CODPRO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'485'																	, ; //X9_IDENT
	'D0B'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'D0B_PRDORI'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'486'																	, ; //X9_IDENT
	'D0B'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'D0B_PRODUT'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'487'																	, ; //X9_IDENT
	'CPY'																	, ; //X9_CDOM
	'B1_FILIAL+B1_COD'														, ; //X9_EXPDOM
	'CPY_FILIAL+CPY_CODPRO'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'488'																	, ; //X9_IDENT
	'SB0'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'B0_ECPAIAN'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'489'																	, ; //X9_IDENT
	'SBG'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'BG_PRODUTO'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'490'																	, ; //X9_IDENT
	'TN3'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TN3_CODEPI'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'491'																	, ; //X9_IDENT
	'TNB'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'TNB_CODEPI'															, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'002'																	, ; //X9_IDENT
	'D3E'																	, ; //X9_CDOM
	'B1_FILIAL+B1_COD'														, ; //X9_EXPDOM
	'D3E_FILIAL+D3E_COD'													, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'001'																	, ; //X9_IDENT
	'D3K'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'D3K_COD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'005'																	, ; //X9_IDENT
	'SD4'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'D4_PRDORG'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'003'																	, ; //X9_IDENT
	'SVK'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'VK_COD'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'1'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

aAdd( aSX9, { ;
	'SB1'																	, ; //X9_DOM
	'004'																	, ; //X9_IDENT
	'SVK'																	, ; //X9_CDOM
	'B1_COD'																, ; //X9_EXPDOM
	'VK_PRDORI'																, ; //X9_EXPCDOM
	'S'																		, ; //X9_PROPRI
	'1'																		, ; //X9_LIGDOM
	'N'																		, ; //X9_LIGCDOM
	''																		, ; //X9_CONDSQL
	'S'																		, ; //X9_USEFIL
	'S'																		, ; //X9_VINFIL
	'S'																		, ; //X9_CHVFOR
	'S'																		} ) //X9_ENABLE

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX9 ) )

dbSelectArea( "SX9" )
dbSetOrder( 2 )

For nI := 1 To Len( aSX9 )

	If !SX9->( dbSeek( PadR( aSX9[nI][3], nTamSeek ) + PadR( aSX9[nI][1], nTamSeek ) ) )

		If !( aSX9[nI][1]+aSX9[nI][3] $ cAlias )
			cAlias += aSX9[nI][1]+aSX9[nI][3] + "/"
		EndIf

		RecLock( "SX9", .T. )
		For nJ := 1 To Len( aSX9[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX9[nI][nJ] )
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()

		AutoGrLog( "Foi incluído o relacionamento " + aSX9[nI][1] + "/" + aSX9[nI][3] )

		oProcess:IncRegua2( "Atualizando Arquivos (SX9)..." )

	EndIf

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX9" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuHlp
Função de processamento da gravação dos Helps de Campos

@author TOTVS Protheus
@since  09/07/2019
@obs    Gerado por EXPORDIC - V.6.0.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuHlp()
Local aHlpPor   := {}
Local aHlpEng   := {}
Local aHlpSpa   := {}

AutoGrLog( "Ínicio da Atualização" + " " + "Helps de Campos" + CRLF )


oProcess:IncRegua2( "Atualizando Helps de Campos ..." )

//
// Helps Tabela SB1
//
//
// Helps Tabela SZ7
//
aHlpPor := {}
aAdd( aHlpPor, 'Código que identifica a filial da' )
aAdd( aHlpPor, 'empre-sa usuária do sistema.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZ7_FILIAL ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "Z7_FILIAL" )

aHlpPor := {}
aAdd( aHlpPor, 'Código do Cliente.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZ7_CLIENTE", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "Z7_CLIENTE" )

aHlpPor := {}
aAdd( aHlpPor, 'Data da emissão do Boletim de' )
aAdd( aHlpPor, 'Faturamen-to e variaçöes.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZ7_EMISSAO", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "Z7_EMISSAO" )

//
// Helps Tabela SZ8
//
aHlpPor := {}
aAdd( aHlpPor, 'Código que identifica a filial da' )
aAdd( aHlpPor, 'empre-sa do sistema.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PZ8_FILIAL ", aHlpPor, aHlpEng, aHlpSpa, .T. )
AutoGrLog( "Atualizado o Help do campo " + "Z8_FILIAL" )

AutoGrLog( CRLF + "Final da Atualização" + " " + "Helps de Campos" + CRLF + Replicate( "-", 128 ) + CRLF )

Return {}


//--------------------------------------------------------------------
/*/{Protheus.doc} EscEmpresa
Função genérica para escolha de Empresa, montada pelo SM0

@return aRet Vetor contendo as seleções feitas.
             Se não for marcada nenhuma o vetor volta vazio

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function EscEmpresa()

//---------------------------------------------
// Parâmetro  nTipo
// 1 - Monta com Todas Empresas/Filiais
// 2 - Monta só com Empresas
// 3 - Monta só com Filiais de uma Empresa
//
// Parâmetro  aMarcadas
// Vetor com Empresas/Filiais pré marcadas
//
// Parâmetro  cEmpSel
// Empresa que será usada para montar seleção
//---------------------------------------------
Local   aRet      := {}
Local   aSalvAmb  := GetArea()
Local   aSalvSM0  := {}
Local   aVetor    := {}
Local   cMascEmp  := "??"
Local   cVar      := ""
Local   lChk      := .F.
Local   lOk       := .F.
Local   lTeveMarc := .F.
Local   oNo       := LoadBitmap( GetResources(), "LBNO" )
Local   oOk       := LoadBitmap( GetResources(), "LBOK" )
Local   oDlg, oChkMar, oLbx, oMascEmp, oSay
Local   oButDMar, oButInv, oButMarc, oButOk, oButCanc

Local   aMarcadas := {}


If !MyOpenSm0(.F.)
	Return aRet
EndIf


dbSelectArea( "SM0" )
aSalvSM0 := SM0->( GetArea() )
dbSetOrder( 1 )
dbGoTop()

While !SM0->( EOF() )

	If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO} ) == 0
		aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL } )
	EndIf

	dbSkip()
End

RestArea( aSalvSM0 )

Define MSDialog  oDlg Title "" From 0, 0 To 280, 395 Pixel

oDlg:cToolTip := "Tela para Múltiplas Seleções de Empresas/Filiais"

oDlg:cTitle   := "Selecione a(s) Empresa(s) para Atualização"

@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", " ", "Empresa" Size 178, 095 Of oDlg Pixel
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
aVetor[oLbx:nAt, 2], ;
aVetor[oLbx:nAt, 4]}}
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. // NoScroll

@ 112, 10 CheckBox oChkMar Var  lChk Prompt "Todos" Message "Marca / Desmarca"+ CRLF + "Todos" Size 40, 007 Pixel Of oDlg;
on Click MarcaTodos( lChk, @aVetor, oLbx )

// Marca/Desmarca por mascara
@ 113, 51 Say   oSay Prompt "Empresa" Size  40, 08 Of oDlg Pixel
@ 112, 80 MSGet oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
Message "Máscara Empresa ( ?? )"  Of oDlg
oSay:cToolTip := oMascEmp:cToolTip

@ 128, 10 Button oButInv    Prompt "&Inverter"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Inverter Seleção" Of oDlg
oButInv:SetCss( CSSBOTAO )
@ 128, 50 Button oButMarc   Prompt "&Marcar"    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Marcar usando" + CRLF + "máscara ( ?? )"    Of oDlg
oButMarc:SetCss( CSSBOTAO )
@ 128, 80 Button oButDMar   Prompt "&Desmarcar" Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Desmarcar usando" + CRLF + "máscara ( ?? )" Of oDlg
oButDMar:SetCss( CSSBOTAO )
@ 112, 157  Button oButOk   Prompt "Processar"  Size 32, 12 Pixel Action (  RetSelecao( @aRet, aVetor ), IIf( Len( aRet ) > 0, oDlg:End(), MsgStop( "Ao menos um grupo deve ser selecionado", "UPDVOL" ) ) ) ;
Message "Confirma a seleção e efetua" + CRLF + "o processamento" Of oDlg
oButOk:SetCss( CSSBOTAO )
@ 128, 157  Button oButCanc Prompt "Cancelar"   Size 32, 12 Pixel Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) ;
Message "Cancela o processamento" + CRLF + "e abandona a aplicação" Of oDlg
oButCanc:SetCss( CSSBOTAO )

Activate MSDialog  oDlg Center

RestArea( aSalvAmb )
dbSelectArea( "SM0" )
dbCloseArea()

Return  aRet


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaTodos
Função auxiliar para marcar/desmarcar todos os ítens do ListBox ativo

@param lMarca  Contéudo para marca .T./.F.
@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaTodos( lMarca, aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := lMarca
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} InvSelecao
Função auxiliar para inverter a seleção do ListBox ativo

@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function InvSelecao( aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := !aVetor[nI][1]
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} RetSelecao
Função auxiliar que monta o retorno com as seleções

@param aRet    Array que terá o retorno das seleções (é alterado internamente)
@param aVetor  Vetor do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function RetSelecao( aRet, aVetor )
Local  nI    := 0

aRet := {}
For nI := 1 To Len( aVetor )
	If aVetor[nI][1]
		aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
	EndIf
Next nI

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaMas
Função para marcar/desmarcar usando máscaras

@param oLbx     Objeto do ListBox
@param aVetor   Vetor do ListBox
@param cMascEmp Campo com a máscara (???)
@param lMarDes  Marca a ser atribuída .T./.F.

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
Local cPos1 := SubStr( cMascEmp, 1, 1 )
Local cPos2 := SubStr( cMascEmp, 2, 1 )
Local nPos  := oLbx:nAt
Local nZ    := 0

For nZ := 1 To Len( aVetor )
	If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
		If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
			aVetor[nZ][1] := lMarDes
		EndIf
	EndIf
Next

oLbx:nAt := nPos
oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} VerTodos
Função auxiliar para verificar se estão todos marcados ou não

@param aVetor   Vetor do ListBox
@param lChk     Marca do CheckBox do marca todos (referncia)
@param oChkMar  Objeto de CheckBox do marca todos

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function VerTodos( aVetor, lChk, oChkMar )
Local lTTrue := .T.
Local nI     := 0

For nI := 1 To Len( aVetor )
	lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MyOpenSM0
Função de processamento abertura do SM0 modo exclusivo

@author TOTVS Protheus
@since  09/07/2019
@obs    Gerado por EXPORDIC - V.6.0.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MyOpenSM0(lShared)
Local lOpen := .F.
Local nLoop := 0

If FindFunction( "OpenSM0Excl" )
	For nLoop := 1 To 20
		If OpenSM0Excl(,.F.)
			lOpen := .T.
			Exit
		EndIf
		Sleep( 500 )
	Next nLoop
Else
	For nLoop := 1 To 20
		dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )

		If !Empty( Select( "SM0" ) )
			lOpen := .T.
			dbSetIndex( "SIGAMAT.IND" )
			Exit
		EndIf
		Sleep( 500 )
	Next nLoop
EndIf

If !lOpen
	MsgStop( "Não foi possível a abertura da tabela " + ;
	IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATENÇÃO" )
EndIf

Return lOpen


//--------------------------------------------------------------------
/*/{Protheus.doc} LeLog
Função de leitura do LOG gerado com limitacao de string

@author TOTVS Protheus
@since  09/07/2019
@obs    Gerado por EXPORDIC - V.6.0.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function LeLog()
Local cRet  := ""
Local cFile := NomeAutoLog()
Local cAux  := ""

FT_FUSE( cFile )
FT_FGOTOP()

While !FT_FEOF()

	cAux := FT_FREADLN()

	If Len( cRet ) + Len( cAux ) < 1048000
		cRet += cAux + CRLF
	Else
		cRet += CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		cRet += "Tamanho de exibição maxima do LOG alcançado." + CRLF
		cRet += "LOG Completo no arquivo " + cFile + CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		Exit
	EndIf

	FT_FSKIP()
End

FT_FUSE()

Return cRet


/////////////////////////////////////////////////////////////////////////////
