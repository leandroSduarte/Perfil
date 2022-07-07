#include 'rwmake.ch'
#include 'protheus.ch'
#include 'topconn.ch'
#include "tbiconn.ch"
#include "TOTVS.CH"
#include "colors.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PFGS004 º Autor ³ Gabriel Veríssimo   º Data ³  22/05/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualização de dados da ordem de serviço em massa          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Deltadecisao                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function PFGS004()

Private oDlgAB6 := nil
Private oSBtn1
Private oBtn2
Private oBrw2
Private oBrwSA1	:= nil
Private aHeadSA1   := {}
Private aColsSA1   := {}
Private _cFileSA1
Private _aCampAB6  := {}
Private _aTituAB6  := {}

Private cMarca   	:= "XX"

private _nPercTela	:= 0.8
private _nPercGrp	:= 0.3
Private aPosObj	:= {}
Private aObjects	:= {}
Private aSize		:= MsAdvSize(.F.)
//aSize := {0,0,951.5,457.5,1903,915,0,5} //Temporario

Private aPosGet1	:= {}

aParam := {}
aRet := {}

MV_PAR01 := Space(TamSX3("A1_COD")[1])
MV_PAR02 := Space(TamSX3("A1_LOJA")[1])
MV_PAR03 := Repl('Z',TamSX3("A1_COD")[1])
MV_PAR04 := Repl('Z',TamSX3("A1_LOJA")[1])
MV_PAR05 := Space(TamSX3("AB6_NUMOS")[1])
MV_PAR06 := Repl('Z',TamSX3("AB6_NUMOS")[1])
MV_PAR07 := FirstDate(Date())
MV_PAR08 := LastDate(Date())

aAdd(aParam,{1,"Cliente De",MV_PAR01,"","","SA1",,50,.F.})
aAdd(aParam,{1,"Loja De",MV_PAR02,"","",,,50,.F.})
aAdd(aParam,{1,"Cliente Ate",MV_PAR03,"","","SA1",,50,.F.})
aAdd(aParam,{1,"Loja Ate",MV_PAR04,"","",,,50,.F.})
aAdd(aParam,{1,"Nr. OS De",MV_PAR05,"","",,,50,.F.})
aAdd(aParam,{1,"Nr. OS Ate",MV_PAR06,"","",,,50,.F.})
aAdd(aParam,{1,"Emissão De",MV_PAR07,"","",,,50,.F.})
aAdd(aParam,{1,"Emissão Ate",MV_PAR08,"","",,,50,.F.})

If ParamBox(aParam,"Atualização Ordem de Serviço",@aRet, , , , , , ,"PFGS004",.F.,.F.)

	aCposEnch := {}
	aAlterEnc := {}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula as Dimensoes da Tela.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd( aObjects, { 100, 100, .T., .T. } )
	
	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
	aPosObj := MsObjSize( aInfo, aObjects )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta as Dimensoes dos Objetos da Tela.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aPosGet1	:= { (aPosObj[1,1]*_nPercTela)+03, (aPosObj[1,2]*_nPercTela)+05, (aPosObj[1,3]*_nPercTela)-05, (aPosObj[1,4]*_nPercTela)-03 }
	aPosGet2	:= { (aPosObj[1,1]*_nPercGrp)+03, (aPosObj[1,2]*_nPercGrp)+05, (aPosObj[1,3]*_nPercGrp)/2, (aPosObj[1,4]*_nPercGrp)/4 }
	conout("aPosGet2")
	conout(aPosGet2[1])
	conout(aPosGet2[2])
	conout(aPosGet2[3])
	conout(aPosGet2[4])
	
	DEFINE MSDIALOG oDlgAB6 TITLE "Atualização Ordem de Serviço" From 00,00 to aSize[6]*_nPercTela,aSize[5]*_nPercTela Of oMainWnd Pixel
	
	fGetDados("TRBAB6",aHeadSA1,aColsSA1,.T.,.T.,@_aCampAB6,@_aTituAB6,"TAB6")
	DbSelectArea("TAB6")
	TAB6->(DbGoTop())
	lClasse 	:= .T.
	cClasse 	:= ""
	aItems1 	:= RetOpc(1, "AB6_XCLAOS")
	oGroup1		:= TGroup():New(aPosGet2[1],aPosGet2[2],aPosGet2[3]-27,aPosGet2[4]+25,'Classe OS',oDlgAB6,,,.T.)
	oCombo1		:= TComboBox():New(aPosGet2[1]+09,aPosGet2[2]+05,{|u|if(PCount()>0,cClasse:=u,cClasse)},aItems1,70,10,oGroup1,,,,,,.T.,,,,,,,,,'cClasse')
	oCheck1 	:= TCheckBox():New(aPosGet2[1],aPosGet2[2]+68,'',{||lClasse},oGroup1,100,210,,{||lClasse := !lClasse, oCombo1:lActive := lClasse},,,,,,.T.,,,)

	lClassif 	:= .T.
	cClassif 	:= ""
	aItems2 	:= RetOpc(1, "AB6_XCLFOS")
	oGroup2		:= TGroup():New(aPosGet2[1],aPosGet2[2]+85,aPosGet2[3]-27,aPosGet2[4]+110,'Classificação OS',oDlgAB6,,,.T.)
	oCombo2		:= TComboBox():New(aPosGet2[1]+09,aPosGet2[2]+90,{|u|if(PCount()>0,cClassif:=u,cClassif)},aItems2,70,10,oGroup2,,,,,,.T.,,,,,,,,,'cClassif')
	oCheck2 	:= TCheckBox():New(aPosGet2[1],aPosGet2[2]+153,'',{||lClassif},oGroup2,100,210,,{||lClassif := !lClassif, oCombo2:lActive := lClassif},,,,,,.T.,,,)

	lCond 		:= .T.
	cCond 		:= Space(3)
	oGroup3		:= TGroup():New(aPosGet2[1],aPosGet2[2]+170,aPosGet2[3]-27,aPosGet2[4]+167,'Cond. Pagto.',oDlgAB6,,,.T.)
	oTGet3		:= TGet():New( aPosGet2[1]+09,aPosGet2[2]+175,{|u| If(PCount()>0,cCond :=u,cCond)},oGroup3,042,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"SE4",cCond,,,, )
	oCheck3		:= TCheckBox():New(aPosGet2[1],aPosGet2[2]+210,'',{||lCond},oGroup2,100,210,,{||lCond := !lCond, oTGet3:lActive := lCond},,,,,,.T.,,,)

	lData 		:= .T.
	nDiasDe 	:= Space(2)
	nDiasAte 	:= Space(2)
	oGroup4		:= TGroup():New(aPosGet2[1],aPosGet2[2]+228,aPosGet2[3]-27,aPosGet2[4]+263,'Data Prg. De-Até',oDlgAB6,,,.T.)
	oTGet4 		:= TGet():New( aPosGet2[1]+09,aPosGet2[2]+233,{|u| If(PCount()>0,nDiasDe :=u,nDiasDe)},oGroup4,037,009,"@E 99", {|| val(nDiasDe) <= 31},0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"",nDiasDe,,,, )
	oTGet5 		:= TGet():New( aPosGet2[1]+09,aPosGet2[2]+275,{|u| If(PCount()>0,nDiasAte :=u,nDiasAte)},oGroup4,037,009,"@E 99",{|| val(nDiasAte) <= 31 .and. val(nDiasAte) >= val(nDiasDe)},0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"",nDiasAte,,,, )
	oCheck4 	:= TCheckBox():New(aPosGet2[1],aPosGet2[2]+303,'',{||lData},oGroup4,100,210,,{||lData := !lData, oTGet4:lActive := lData, oTGet5:lActive := lData},,,,,,.T.,,,)

	lCateg	 	:= .T.
	cCateg	 	:= ""
	aItems6 	:= RetOpc(1, "AB6_XCATEG")
	oGroup6		:= TGroup():New(aPosGet2[1],aPosGet2[2]+324,aPosGet2[3]-27,aPosGet2[4]+350,'Categoria OS',oDlgAB6,,,.T.)
	oCombo6		:= TComboBox():New(aPosGet2[1]+09,aPosGet2[2]+329,{|u|if(PCount()>0,cCateg:=u,cCateg)},aItems6,70,10,oGroup6,,,,,,.T.,,,,,,,,,'cCateg')
	oCheck6 	:= TCheckBox():New(aPosGet2[1],aPosGet2[2]+392,'',{||lCateg},oGroup6,100,210,,{||lCateg := !lCateg, oCombo6:lActive := lCateg},,,,,,.T.,,,)

	lEquipe	 	:= .T.
	cEquipe	 	:= space(3)
	oGroup7		:= TGroup():New(aPosGet2[1],aPosGet2[2]+410,aPosGet2[3]-27,aPosGet2[4]+408,'Equipe',oDlgAB6,,,.T.)
	oTGet7      := TGet():New( aPosGet2[1]+09,aPosGet2[2]+415,{|u| If(PCount()>0,cEquipe :=u,cEquipe)},oGroup7,042,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"AAX",cEquipe,,,, )
	oCheck7 	:= TCheckBox():New(aPosGet2[1],aPosGet2[2]+453,'',{||lEquipe},oGroup7,100,210,,{||lEquipe := !lEquipe, oCombo7:lActive := lEquipe},,,,,,.T.,,,)

	oBrwSA1		:= MsSelect():New( "TAB6","AB6_OK","",_aTituAB6,.F.,@cMarca,{aPosGet1[1]+35,aPosGet1[2],aPosGet1[3]-20,aPosGet1[4]},,,oDlgAB6 )
	
	oBtn1		:= TButton():New( aPosGet1[3]-15,aPosGet1[2]+05,"Marca/Desmarca Todas",oDlgAB6,{||MarcaTRB("TAB6","AB6_OK")},065,012,,,,.T.,,"",,,,.F. )
	oBtn2		:= TButton():New( aPosGet1[3]-15,aPosGet1[2]+75,"Atualizar Cadastros",oDlgAB6,{|| MsgRun("Atualizando dados, aguarde...",,{||fAtualiza()})},060,012,,,,.T.,,"",,,,.F. )
	oBtn2:SetCss(SetCssImg("","Primary"))
	oBtn3		:= TButton():New( aPosGet1[3]-15,aPosGet1[2]+140,"Sair",oDlgAB6,{||oDlgAB6:End()},030,012,,,,.T.,,"",,,,.F. )
	oBtn3:SetCss(SetCssImg("","Danger"))
	
	ACTIVATE MSDIALOG oDlgAB6 CENTERED

endif
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ fGetDadosºAutor  ³Anderson Messias    º Data ³ 13/05/2020  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Filtra Dados da Tabela informada                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Deltadecisao                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fGetDados(cAliasAux,aHeaderAux,aColsAux,lDados,lCriaTemp,aCampos,aTitulos,cTRBAux,cFileTRB)

Local	nUsado 	:= 0
Local	cQuery	:= ""

DEFAULT lDados		:= .T.
DEFAULT lCriaTemp	:= .F.
DEFAULT aCampos		:= {}
DEFAULT aTitulos	:= {}
DEFAULT cTRBAux		:= "TRB"
DEFAULT cFileTRB	:= "_cFileTRB"

conout("fGetDados = " + cAliasAux + "Inicio : "+Time())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aHeader.                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if cAliasAux == "TRBAB6"
	conout(aRet[1])
	conout(aRet[2])
	conout(aRet[3])
	conout(aRet[4])
	conout(aRet[5])
	conout(aRet[6])
	conout(aRet[7])
	conout(aRet[8])

	// cQuery := "SELECT AB6_CODCLI, AB6_LOJA, A1_NOME, AB6_NUMOS, AB6_XCLAOS, AB6_XCLFOS, AB6_CONPAG, AB6_XDTDE, AB6_XDTATE "+CRLF 
	cQuery := "SELECT AB6_CODCLI, AB6_LOJA, A1_NOME, AB6_NUMOS"+CRLF 
	cQuery += "FROM "+RetSQLName("AB6")+" AB6 "+CRLF
	cQuery += "LEFT JOIN "+RetSQLName("SA1")+" SA1 ON A1_COD = AB6_CODCLI AND A1_LOJA = AB6_LOJA AND SA1.D_E_L_E_T_ = '' "+CRLF
	cQuery += "WHERE AB6_FILIAL = '" + xFilial("AB6") +"' "+CRLF
	cQuery += "AND AB6.D_E_L_E_T_ = '' "+CRLF
	cQuery += "AND AB6_CODCLI BETWEEN '" +aRet[1] + "' AND '" + aRet[3] + "' "+CRLF
	cQuery += "AND AB6_LOJA BETWEEN '" + aRet[2] +"' AND '" + aRet[4] + "' "+CRLF
	cQuery += "AND AB6_NUMOS BETWEEN '" + aRet[5] +"' AND '" + aRet[6] + "' "+CRLF
	cQuery += "AND AB6_EMISSA BETWEEN '" + DtoS(aRet[7]) +"' AND '" + DtoS(aRet[8]) + "' "+CRLF
	cQuery += "ORDER BY AB6_NUMOS "+CRLF'

	Conout(cQuery)
	//Aviso("Query",cQuery,{"OK"},3)
endif

if cAliasAux == "TRBREL"
	cQuery := "SELECT AB6_CODCLI, AB6_LOJA, A1_NOME, AB6_NUMOS, AB6_XCLAOS, AB6_XCLFOS, AB6_CONPAG, AB6_XDTDE, AB6_XDTATE, AB6_XCATEG, AB6_XEQUIP,"+CRLF 
	cQuery += " '' as AB6_ZCLAOS, '' as AB6_ZCLFOS, '' as AB6_ZCONPAG, '' as AB6_ZDTDE, '' as AB6_ZDTATE, '' as AB6_ZCATEG, '' as AB6_ZEQUIP"+CRLF 	
	cQuery += "FROM "+RetSQLName("AB6")+" AB6 "+CRLF
	cQuery += "LEFT JOIN "+RetSQLName("SA1")+" SA1 ON A1_COD = AB6_CODCLI AND A1_LOJA = AB6_LOJA AND SA1.D_E_L_E_T_ = '' "+CRLF
	cQuery += "WHERE 1=2 "+CRLF
	//Aviso("Query",cQuery,{"OK"},3)
endif

if Select(cAliasAux)>0
	DBSelectArea(cAliasAux)
	DBCloseArea()
endif

//Aviso("Query",cQuery,{"OK"},3)
TCQUERY cQuery New ALIAS &cAliasAux

DBSelectArea(cAliasAux)
aStru := &(cAliasAux+"->(dbStruct())")

aHeaderAux := {}
aColsAux   := {}

aCampos    := {}
aTitulos   := {}

if cAliasAux == "TRBAB6"
	aadd(aTitulos,{"AB6_OK",    , "", "@!"})
	aadd(aCampos ,{"AB6_OK", "C", 02, 0   })
endif

DBSelectArea("SX3")
SX3->(DBSetOrder(2))

aHeadExc := {}
nUsado := 0

For nI := 1 To len(aStru)
	if SX3->(DBSeek(aStru[nI][1]))
		if lCriaTemp
			//If X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL //.AND. SX3->X3_BROWSE == "S"
				aadd(aTitulos,{Alltrim(SX3->X3_CAMPO),,SX3->X3_TITULO,SX3->X3_PICTURE})
				aadd(aCampos ,{Alltrim(SX3->X3_CAMPO),SX3->X3_TIPO, SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			//Endif
		else
			aADD(aHeaderAux,{;
					AllTrim(X3Titulo()),;
					SX3->X3_CAMPO,;
					SX3->X3_PICTURE,;
					SX3->X3_TAMANHO,;
					SX3->X3_DECIMAL,;
					SX3->X3_VALID,;
					SX3->X3_USADO,;
					SX3->X3_TIPO,;
					SX3->X3_F3,;
					"" } )
		endif
	else
		
		if alltrim(aStru[nI][1]) == "AB6_ZCLAOS"
			if SX3->(DBSeek("AB6_XCLAOS"))
				aADD(aHeaderAux,{;
				AllTrim(X3Titulo())+" ATUALIZADO",;
				"AB6_ZCLAOS",;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				"",;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_F3,;
				SX3->X3_CONTEXT })
			endif
		endif

		if alltrim(aStru[nI][1]) == "AB6_ZCLFOS"
			if SX3->(DBSeek("AB6_XCLFOS"))
				aADD(aHeaderAux,{;
				AllTrim(X3Titulo())+" ATUALIZADO",;
				"AB6_ZCLFOS",;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				"",;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_F3,;
				SX3->X3_CONTEXT })
			endif
		endif

		if alltrim(aStru[nI][1]) == "AB6_ZCONPAG"
			if SX3->(DBSeek("AB6_CONPAG"))
				aADD(aHeaderAux,{;
				AllTrim(X3Titulo())+" ATUALIZADO",;
				"AB6_ZCONPAG",;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				"",;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_F3,;
				SX3->X3_CONTEXT })
			endif
		endif

		if alltrim(aStru[nI][1]) == "AB6_ZDTDE"
			if SX3->(DBSeek("AB6_XDTDE"))
				aADD(aHeaderAux,{;
				AllTrim(X3Titulo())+" ATUALIZADO",;
				"AB6_ZDTDE",;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				"",;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_F3,;
				SX3->X3_CONTEXT })
			endif
		endif

		if alltrim(aStru[nI][1]) == "AB6_ZDTATE"
			if SX3->(DBSeek("AB6_XDTATE"))
				aADD(aHeaderAux,{;
				AllTrim(X3Titulo())+" ATUALIZADO",;
				"AB6_ZDTATE",;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				"",;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_F3,;
				SX3->X3_CONTEXT })
			endif
		endif

		if alltrim(aStru[nI][1]) == "AB6_ZCATEG"
			if SX3->(DBSeek("AB6_XCATEG"))
				aADD(aHeaderAux,{;
				AllTrim(X3Titulo())+" ATUALIZADO",;
				"AB6_ZCATEG",;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				"",;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_F3,;
				SX3->X3_CONTEXT })
			endif
		endif

		if alltrim(aStru[nI][1]) == "AB6_ZEQUIP"
			if SX3->(DBSeek("AB6_XEQUIP"))
				aADD(aHeaderAux,{;
				AllTrim(X3Titulo())+" ATUALIZADO",;
				"AB6_ZEQUIP",;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				"",;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_F3,;
				SX3->X3_CONTEXT })
			endif
		endif

	endif
Next

if lCriaTemp
	CriaTRB(cTRBAux,aCampos,cFileTRB)
endif

DBSelectArea(cAliasAux)
While !&(cAliasAux+"->(Eof())")
	if lCriaTemp
		DBSelectArea(cTRBAux)
		RecLock(cTRBAux,.T.)
		For nI := 1 to Len(aCampos)
			if cAliasAux == "TRBAB6" //Trazer o OK Preenchido
				if alltrim(aCampos[nI][1]) $ "AB6_OK"
					&(cTRBAux+"->"+aCampos[nI][1]) := cMarca
					Loop
				endif
			else
				if alltrim(aCampos[nI][1]) $ "AB6_OK"
					Loop
				endif
			endif
			&(cTRBAux+"->"+aCampos[nI][1]) := &(cAliasAux+"->"+aCampos[nI][1])
		Next
		MsUnlock()
	else
		aAdd(aColsAux, Array(Len(aHeaderAux)+1))
		nX := 1
		For nI := 1 to len(aHeaderAux)
			aColsAux[Len(aColsAux)][nX]	 := &(cAliasAux+"->"+aHeaderAux[nI][2])
			nX++
		Next
		aColsAux[Len(aColsAux)][len(aHeaderAux)+1] := .F.
	endif
	DBSelectArea(cAliasAux)
	&(cAliasAux+"->(DBSkip())")
EndDo

conout(Varinfo("aColsAux",aColsAux))

oDlgAB6:Refresh()

conout("fGetDados = " + cAliasAux + "Termino : "+Time())

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CriaTRB  ºAutor  ³ Anderson Messias   º Data ³ 13/05/2020  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que seleciona os enderecamentos pendentes           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Deltadecisao                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CriaTRB(cTRBAux,aCampos,cFileTRB)

If Select(cTRBAux) > 0
	DBSelectArea(cTRBAux)
	DBCloseArea()
	fErase(cFileTRB+OrdBagExt())
EndIf

cFileTRB := CriaTrab(aCampos,.T.)
dbUseArea( .T.,"CTREECDX", cFileTRB, cTRBAux, .T., .F. )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DelTTRB  ºAutor  ³ Anderson Messias   º Data ³ 13/05/2020  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que deleta aquivo temporario                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Deltadecisao                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function DelTRB(cFileTRB)

fErase(cFileTRB+OrdBagExt())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ MarcaTRB ºAutor  ³Anderson Messias    º Data ³ 13/05/2020  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Filtra Dados da Tabela informada                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Deltadecisao                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MarcaTRB(cTRBAux,cCampoOK)

Local cMarca := If(&(cTRBAux+"->"+cCampoOK) == SPACE(2),"XX","  ")

dbSelectArea(cTRBAux)
DBGoTop()

Do while !&(cTRBAux+"->(eof())")
	RecLock(cTRBAux,.F.)
	&(cTRBAux+"->"+cCampoOK) := cMarca
	MsUnlock()
	&(cTRBAux+"->(dbSkip())")
Enddo
&(cTRBAux+"->(DbGoTop())")

Return nil

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SetCssImg   ³ Autor ³Anderson Messias    ³ Data ³ 20/09/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para setar CSS e Imagem nos Botoes                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Deltadecisao                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SetCssImg(cImg,cTipo)

Local cCssRet := ""
DEFAULT cImg := "rpo:yoko_sair.png"
DEFAULT cTipo := "Botao Branco"

if cTipo == "Primary"  
	cCssRet := "QPushButton {"  
	cCssRet += " color:#fff;background-color:#007bff;border-color:#007bff "
	cCssRet += "}"
EndIf

if cTipo == "Danger"  
	cCssRet := "QPushButton {"  
	cCssRet += " color:#fff;background-color:#dc3545;border-color:#dc3545 "
	cCssRet += "}"
EndIf

if cTipo == "Success"  
	cCssRet := "QPushButton {"  
	cCssRet += " color:#fff;background-color:#28a745;border-color:#28a745 "
	cCssRet += "}"
EndIf

Return cCssRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ fAtualiza ºAutor  ³Anderson Messias    º Data ³ 13/05/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualiza Dados                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Deltadecisao                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fAtualiza()

Local cMarca   := "XX"
Local aRetCons := {}
Local aHeadTMP := {}
Local aColsTMP := {}
Private aHeadREL := {}
Private aColsREL := {}

fGetDados("TRBREL",@aHeadREL,@aColsREL,.T.,.F.)

dbSelectArea("TAB6")
TAB6->(DBGoTop())

Do while !TAB6->(Eof())
	
	if TAB6->AB6_OK == cMarca

		aAdd(aColsREL, Array(Len(aHeadREL)+1))

		AB6->(DbSetOrder(1))
		if AB6->(DbSeek(xFilial("AB6") + TAB6->AB6_NUMOS))

			// Define os valores que serão utilizados na planilha. Faço isso antes do RECLOCK pois assim tenho os valores antes de alterá-los
			aColsREL[Len(aColsREL)][1] := TAB6->AB6_CODCLI  
			aColsREL[Len(aColsREL)][2] := TAB6->AB6_LOJA  
			aColsREL[Len(aColsREL)][3] := TAB6->A1_NOME  
			aColsREL[Len(aColsREL)][4] := TAB6->AB6_NUMOS  
			aColsREL[Len(aColsREL)][5] := RetOpc(2, aHeadREL[5][2], AB6->AB6_XCLAOS) // Retorna o texto da opção escolhida
			aColsREL[Len(aColsREL)][6] := RetOpc(2, aHeadREL[6][2], AB6->AB6_XCLFOS) // Retorna o texto da opção escolhida
			aColsREL[Len(aColsREL)][7] := AB6->AB6_CONPAG  
			aColsREL[Len(aColsREL)][8] := AB6->AB6_XDTDE
			aColsREL[Len(aColsREL)][9] := AB6->AB6_XDTATE
			aColsREL[Len(aColsREL)][10] := RetOpc(2, aHeadREL[10][2], AB6->AB6_XCATEG)
			aColsREL[Len(aColsREL)][11] := AB6->AB6_XEQUIP

			AB6->(RecLock("AB6"), .F.)

			if lClasse
				AB6->AB6_XCLAOS := cClasse
				aColsREL[Len(aColsREL)][11] := RetOpc(2, aHeadREL[5][2], cClasse) // Retorna o texto da opção escolhida
			else
				aColsREL[Len(aColsREL)][11] := RetOpc(2, aHeadREL[5][2], AB6->AB6_XCLAOS)
			endif

			if lClassif
				AB6->AB6_XCLFOS := cClassif
				aColsREL[Len(aColsREL)][12] := RetOpc(2, aHeadREL[6][2], cClassif) // Retorna o texto da opção escolhida
			else
				aColsREL[Len(aColsREL)][12] := RetOpc(2, aHeadREL[6][2], AB6->AB6_XCLFOS)
			endif

			if lCond
				AB6->AB6_CONPAG := cCond
				aColsREL[Len(aColsREL)][13] := cCond
			else
				aColsREL[Len(aColsREL)][13] := AB6->AB6_CONPAG  
			endif

			if lData
				
				// Retorna a data programada da ordem de serviço
				dDtPrg := Posicione("ABE", 5, xFilial("ABE")+TAB6->AB6_NUMOS ,"ABE_DATA")
				
				dDtDe  := DtValid(dDtPrg, val(nDiasDe))
				dDtAte := DtValid(dDtPrg, val(nDiasAte))
				
				// Necessário verificar se a data é válida
				AB6->AB6_XDTDE 	:= dDtDe
				AB6->AB6_XDTATE := dDtAte

				aColsREL[Len(aColsREL)][14] := dDtDe
				aColsREL[Len(aColsREL)][15] := dDtAte
			else
				aColsREL[Len(aColsREL)][14] := AB6->AB6_XDTDE
				aColsREL[Len(aColsREL)][15] := AB6->AB6_XDTATE
			endif

			if lCateg
				AB6->AB6_XCATEG := cCateg
				aColsREL[Len(aColsREL)][16] := RetOpc(2, aHeadREL[10][2], cCateg) // Retorna o texto da opção escolhida
			else
				aColsREL[Len(aColsREL)][16] := RetOpc(2, aHeadREL[10][2], AB6->AB6_XCATEG)
			endif

			if lEquipe
				AB6->AB6_XEQUIP := cEquipe
				aColsREL[Len(aColsREL)][17] := cEquipe
			else
				aColsREL[Len(aColsREL)][17] := AB6->AB6_XEQUIP
			endif

			AB6->(MsUnlock())
		else
			conout("Não foi possível atualizar a ordem de serviço " + TAB6->AB6_NUMOS)
		endif

	endif
	
	TAB6->(DBSkip())
Enddo

TAB6->(DbGoTop())

// conout(Varinfo("aColsREL",aColsREL))
// conout(Varinfo("aHeadREL",aHeadREL))

ExpExcel("Dados","Atualização de Dados de Ordem de Serviço")

MsgInfo("Processo de atualização concluído com sucesso!")

DelTRB("TAB6")
oDlgAB6:End()

Return nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ExpExcel ºAutor  ³ Anderson Messias   º Data ³  02/08/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina que exporta dados para o excel                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Deltadecisao                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ExpExcel(cWork,cTabela)

Local oExcel := FWMSEXCEL():New()
Local nI, nX := 0
Local _cTipo := 0
Local _cAlign:= 0

DEFAULT cWork := "Dados"
DEFAULT cTabela := "Importacao XML"

oExcel:AddworkSheet(cWork)
oExcel:AddTable (cWork,cTabela)
For nI := 1 to Len(aHeadREL)
    if aHeadREL[nI][8] == "C"
       _cTipo := 1 
       _cAlign := 1
    elseif aHeadREL[nI][8] == "D"
       _cTipo := 4 
       _cAlign := 2
    elseif aHeadREL[nI][8] == "N"
       if aHeadREL[nI][5] > 0
           _cTipo := 3
           _cAlign := 3
       else
           _cTipo := 2
           _cAlign := 3
       endif 
    else
       _cTipo := 1 
       _cAlign := 1
    endif
    oExcel:AddColumn(cWork,cTabela,aHeadREL[nI][1],_cAlign,_cTipo,.F.)
Next

For nI := 1 to Len(aColsREL)
    aColExc := {}
    For nX := 1 to Len(aHeadREL)
       aadd(aColExc,aColsREL[nI][nX])
    Next
    oExcel:AddRow(cWork,cTabela,aClone(aColExc))
Next

oExcel:Activate()

cArqXML := CriaTrab(NIL,.F.)+".xml"
cPath := AllTrim(GetTempPath())
oExcel:GetXMLFile(cPath+cArqXML)

If !ApOleClient("MsExcel")
    MsgStop("Microsoft Excel nao instalado.") //--- Microsoft Excel nao instalado ---
    Return
EndIf

oExcelApp := NIL
oExcelApp := MsExcel():New()
oExcelApp:WorkBooks:Open(cPath+cArqXML)
oExcelApp:SetVisible(.T.)
oExcelApp := NIL

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RetOpc  ºAutor  ³ Gabriel Veríssimo   º Data ³  22/05/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina que retorna opções do comboBox do campo informado   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Deltadecisao                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RetOpc(nTipo, cCampo, cOpc)

	/* nTipo  = 1-Retorna array para usar no comboBox / 2-Retorna texto da opção selecionada 
	   cCampo = Campo do SX3 que terá as opções retornadas
	   cOpc   = Opção escolhida pelo usuário */

	Local cAreaSX3 := SX3->(GetArea())
	Local xRet

	SX3->(DbSetOrder(2))
	if SX3->(DbSeek(cCampo))
		if nTipo == 1
			// Converte as opções em array para ser utilizada em comboBox
			xRet := StrTokArr(X3CBox(), ";")
		else
			// Ajusta o texto para ser apresentado na planilha
			if len(alltrim(cOpc)) > 0
				xRet := SubStr(X3CBox(), At(cOpc+"=", X3CBox())+2, At(";", X3CBox())-2)
				xRet := StrTran(xRet, ";", "")
			else
				xRet := ""
			endif
		endif
	endif

	RestArea(cAreaSX3)

Return xRet

Static Function DtValid(dData, nDias)

	Local aMeses := {1, 3, 5, 7, 8, 10, 12} // Lista de meses que possuem 31 dias
	Local dDtPrg := dData
	
	// Se o mês informado não possuir 31 dias, diminui um dia do dia informado
	if nDias == 31 .and. aScan(aMeses, month(dDtPrg)) == 0
		nDias -= 1
	endif

	// Quando for fevereiro e dia maior que 28, muda para 28
	if month(dDtPrg) == 2 .and. nDias > 28
		nDias := "28"
	endif
	
	dDtPrg := StoD(cValToChar(Year(dDtPrg)) + StrZero(Month(dDtPrg), 2) + cValToChar(nDias))

Return dDtPrg
