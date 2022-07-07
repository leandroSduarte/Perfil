#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "rwMake.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
#include 'Ap5Mail.ch'

/*/{Protheus.doc} ZJOBF001
description
@type function
@version
@author caiom
@since 21/12/2021
@param _cEmp, variant, param_description
@param _cFil, variant, param_description
@return variant, return_description
/*/
User Function ZJOBF001()
	lOCAL _lAut			 := .f.

	Default _cEmp := "01"
	Default _cFil := "0101"

	If SELECT("SX2") == 0
		_lAut := .T.
		ConOut("Abre o ambiente")
		//RPCSetType(3)
		RpcSetEnv(_cEmp,_cFil)
	EndIf
	IF _lAut
		ZJOBF00A(_lAut)
		ZJOBF00B(_lAut)
	ELSE
		Processa({|| ZJOBF00A(_lAut) },"Endereçamento de Produto do Local 02","Aguarde...")
		Processa({|| ZJOBF00B(_lAut) },"Endereçamento de Produto do Local 05","Aguarde...")
	ENDIF
	If _lAut
		RpcClearEnv()
	EndIf
RETURN
//-------------------------------------------------------------------
/*/{Protheus.doc} ZJOBF00A
Rotina para efetuar o endereçamento para o armazem conforme parametros
@author  Leandro Duarte
@since   28/04/2022
@version 1.0
/*/
//-------------------------------------------------------------------
STATIC FUNCTION ZJOBF00A(_lAut)
	Local _cQry          := ""
	Local _aCabSDA       := {}
	Local _aItSDB        := {}
	Local _aItensSDB     := {}
	Local nTotReg		 := 0
	Private lMsErroAuto := .F.
	Private _cEndAut   := ""
	Private _cLocFil   := ""

	fCriaPara()

	_cEndAut   := GetNewPar("ES_ENDFAB","FABRICA")
	_cLocFil   := GetNewPar("ES_LOCFAB","02")

	ConOut("------------------------------------------------------")
	ConOut("[ZJOBF001 - INICIO: "+DTOC(DATE())+" "+TIME()+"] FILIAL "+CFILANT)
	ConOut("------------------------------------------------------")

	ConOut("ENDERECAMENTO AUTOMATICO DO ARMAZEM "+_cLocFil+" NO ENDERECO "+_cEndAut)

	_cAlias := getNextAlias()
	iif(select(_cAlias),(_cAlias)->(dbclosearea()),nil)
	_cQry := " SELECT * " + CRLF
	_cQry += " FROM "+ RETSQLNAME("SDA") + " SDA " + CRLF
	_cQry += " WHERE DA_LOCAL  =   '"+_cLocFil+"' " + CRLF
	_cQry += " AND DA_SALDO > 0   " + CRLF
	_cQry += " AND SDA.D_E_L_E_T_ <> '*' " + CRLF
	_cQry += " AND DA_FILIAL  =   '"+FWxFilial("SDA")+"' " + CRLF
	_cQry := ChangeQuery( _cQry )

	DbUseArea(.T., "TOPCONN",TCGenQry(,,_cQry),_cAlias,.F., .T.)

	if !_lAut
		DbSelectArea(_cAlias)
		(_cAlias)->( DbEval( { || nTotReg++ },,{ || !Eof() } ) )
		(_cAlias)->( DbGoTop() )
		ProcRegua( nTotReg )
	endif
	DbSelectArea(_cAlias)
	(_cAlias)->(DbGoTop())

	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())
			if !_lAut
				IncProc( "Produto: "+(_cAlias)->DA_PRODUTO+" Local "+_cEndAut )
			endif
			_aCabSDA       := {}
			_aItSDB        := {}
			_aItensSDB     := {}
			lMsErroAuto    := .F.

			//Cabecalho com a informaçãoo do item e NumSeq que sera endereçado.
			_aCabSDA := {{"DA_PRODUTO" ,(_cAlias)->DA_PRODUTO,Nil},;
				{"DA_NUMSEQ"  ,(_cAlias)->DA_NUMSEQ,Nil}}

			//Dados do item que será endereçado
			_aItSDB := {{"DB_ESTORNO"  ," "       ,Nil},;
				{"DB_LOCALIZ"  ,_cEndAut    ,Nil},;
				{"DB_DATA"    ,dDataBase   ,Nil},;
				{"DB_QUANT"  ,(_cAlias)->DA_SALDO ,Nil}}
			aadd(_aItensSDB,_aItSDB)

			//Executa o endere?amento do item
			MATA265( _aCabSDA, _aItensSDB, 3)
			If lMsErroAuto
				ConOut("ERRO NO ENDEREÇAMENTO: Produto "+Alltrim((_cAlias)->DA_PRODUTO)+" NUM SEQ "+(_cAlias)->DA_NUMSEQ+"!")
				//MostraErro()
			else
				ConOut("Produto "+Alltrim((_cAlias)->DA_PRODUTO)+" NUM SEQ "+(_cAlias)->DA_NUMSEQ+" endereçado com sucesso!")
			Endif

			(_cAlias)->(DbSkip())

		EndDo

	EndIf


	ConOut("------------------------------------------------------")
	ConOut("[ZJOBF001 - FIM: "+DTOC(DATE())+" "+TIME()+"] FILIAL "+CFILANT)
	ConOut("------------------------------------------------------")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ZJOBF00B
Rotina para efetuar o endereçamento para o armazem conforme parametros
@author  Leandro Duarte
@since   28/04/2022
@version 1.0
/*/
//-------------------------------------------------------------------
STATIC FUNCTION ZJOBF00B(_lAut)
	Local _cQry          := ""
	Local _aCabSDA       := {}
	Local _aItSDB        := {}
	Local _aItensSDB     := {}
	Local nTotReg		 := 0

	Private lMsErroAuto := .F.
	Private _cEndAut   := ""
	Private _cLocFil   := ""

	fCriaPara()

	_cEndAut   := GetNewPar("ES_ENDFAB2","GERAL")
	_cLocFil   := GetNewPar("ES_LOCFAB2","05")

	ConOut("------------------------------------------------------")
	ConOut("[ZJOBF001 - INICIO: "+DTOC(DATE())+" "+TIME()+"] FILIAL "+CFILANT)
	ConOut("------------------------------------------------------")

	ConOut("ENDERECAMENTO AUTOMATICO DO ARMAZEM "+_cLocFil+" NO ENDERECO "+_cEndAut)
	
	_cAlias := getNextAlias()
	iif(select(_cAlias),(_cAlias)->(dbclosearea()),nil)
	_cQry := " SELECT * " + CRLF
	_cQry += " FROM "+ RETSQLNAME("SDA") + " SDA " + CRLF
	_cQry += " WHERE DA_LOCAL  =   '"+_cLocFil+"' " + CRLF
	_cQry += " AND DA_SALDO > 0   " + CRLF
	_cQry += " AND SDA.D_E_L_E_T_ <> '*' " + CRLF
	_cQry += " AND DA_FILIAL  =   '"+FWxFilial("SDA")+"' " + CRLF
	_cQry := ChangeQuery( _cQry )


	DbUseArea(.T., "TOPCONN",TCGenQry(,,_cQry),_cAlias,.F., .T.)

	if !_lAut
		DbSelectArea(_cAlias)
		(_cAlias)->( DbEval( { || nTotReg++ },,{ || !Eof() } ) )
		(_cAlias)->( DbGoTop() )
		ProcRegua( nTotReg )
	endif
	DbSelectArea(_cAlias)
	(_cAlias)->(DbGoTop())

	If (_cAlias)->(!Eof())

		While (_cAlias)->(!Eof())
			if !_lAut
				IncProc( "Produto: "+(_cAlias)->DA_PRODUTO+" Local "+_cEndAut )
			endif
			_aCabSDA       := {}
			_aItSDB        := {}
			_aItensSDB     := {}
			lMsErroAuto    := .F.

			//Cabecalho com a informaçãoo do item e NumSeq que sera endereçado.
			_aCabSDA := {{"DA_PRODUTO" ,(_cAlias)->DA_PRODUTO,Nil},;
				{"DA_NUMSEQ"  ,(_cAlias)->DA_NUMSEQ,Nil}}

			//Dados do item que será endereçado
			_aItSDB := {{"DB_ESTORNO"  ," "       ,Nil},;
				{"DB_LOCALIZ"  ,_cEndAut    ,Nil},;
				{"DB_DATA"    ,dDataBase   ,Nil},;
				{"DB_QUANT"  ,(_cAlias)->DA_SALDO ,Nil}}
			aadd(_aItensSDB,_aItSDB)

			//Executa o endere?amento do item
			MATA265( _aCabSDA, _aItensSDB, 3)
			If lMsErroAuto
				ConOut("ERRO NO ENDEREÇAMENTO: Produto "+Alltrim((_cAlias)->DA_PRODUTO)+" NUM SEQ "+(_cAlias)->DA_NUMSEQ+"!")
				//MostraErro()
			else
				ConOut("Produto "+Alltrim((_cAlias)->DA_PRODUTO)+" NUM SEQ "+(_cAlias)->DA_NUMSEQ+" endereçado com sucesso!")
			Endif

			(_cAlias)->(DbSkip())

		EndDo

	EndIf

	ConOut("------------------------------------------------------")
	ConOut("[ZJOBF001 - FIM: "+DTOC(DATE())+" "+TIME()+"] FILIAL "+CFILANT)
	ConOut("------------------------------------------------------")

Return

/*/{Protheus.doc} fCriaPara
description
@type function
@version
@author ERPSERV
@since 02/12/2021
@return variant, return_description
/*/
Static Function fCriaPara()

	SX6->(DbSetOrder(1))
	If !SX6->(DbSeek(Space(Len(cFilAnt))+"ES_ENDFAB"))
		RecLock("SX6",.T.)
		SX6->X6_VAR     := "ES_ENDFAB"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Defini o endereço automatico"
		SX6->X6_DESC1   := ""
		SX6->X6_CONTEUD := "FABRICA"
		SX6->X6_PROPRI  := "U"
		SX6->(MsUnlock())
	EndIf

	SX6->(DbSetOrder(1))
	If !SX6->(DbSeek(Space(Len(cFilAnt))+"ES_LOCFAB"))
		RecLock("SX6",.T.)
		SX6->X6_VAR     := "ES_LOCFAB"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Define o local de filtro "
		SX6->X6_DESC1   := ""
		SX6->X6_CONTEUD := "02"
		SX6->X6_PROPRI  := "U"
		SX6->(MsUnlock())
	EndIf

	SX6->(DbSetOrder(1))
	If !SX6->(DbSeek(Space(Len(cFilAnt))+"ES_LOCFAB2"))
		RecLock("SX6",.T.)
		SX6->X6_VAR     := "ES_LOCFAB2"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Define o local de filtro "
		SX6->X6_DESC1   := ""
		SX6->X6_CONTEUD := "05"
		SX6->X6_PROPRI  := "U"
		SX6->(MsUnlock())
	EndIf

	SX6->(DbSetOrder(1))
	If !SX6->(DbSeek(Space(Len(cFilAnt))+"ES_ENDFAB2"))
		RecLock("SX6",.T.)
		SX6->X6_VAR     := "ES_ENDFAB2"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Defini o endereço automatico"
		SX6->X6_DESC1   := ""
		SX6->X6_CONTEUD := "GERAL"
		SX6->X6_PROPRI  := "U"
		SX6->(MsUnlock())
	EndIf
Return
