#INCLUDE "FINR610.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE CRLF CHR(13)+CHR(10)

#DEFINE PREFIXO		1
#DEFINE TITULO		2
#DEFINE PARCELA		3                   
#DEFINE COD_CLI		4
#DEFINE LOJA			5
#DEFINE NOME_CLI		6                 
#DEFINE DT_EMIS		7
#DEFINE DT_VENC		8
#DEFINE VAL_TIT		9
#DEFINE COM_EMISS		10
#DEFINE COM_BAIXA		11
#DEFINE VAL_BASE		12
#DEFINE PERC			13
#DEFINE VAL_COMIS		14
#DEFINE PARC			15
#DEFINE CODFIL		16

Static _oFr610TRB


/*-------------------------------------------------------------------------------------
{Protheus.doc} PERFR610

@Author  	   Felipe Aguiar - Delta Decisao
@since	   	   08/2020
@version	   P12

@description  Relatorio Comissoes Perfil
              SO-20011258
----------------------------------------------------------------------------------------
|Author                  | Date       | Description                                    |
|                        |            |                                                |
----------------------------------------------------------------------------------------
*/

User Function PERFR610()
Local oReport

oReport := ReportDef()
oReport:PrintDialog()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ReportDef³ Autor ³ Daniel Batori         ³ Data ³ 28.08.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Definicao do layout do Relatorio									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ReportDef(void)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()
Local oReport
Local oSection1
Local cPictVal

oReport := TReport():New("FINR610",STR0003,"FIN610", {|oReport| ReportPrint(oReport)},STR0001+STR0002)

pergunte("FIN610",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Vari veis utilizadas para parametros                         ³
//³ mv_par01         // Do Vendedor                              ³
//³ mv_par02         // At‚ o Vendedor                           ³
//³ mv_par03         // Vencto de                                ³
//³ mv_par04         // Vencto At‚                               ³
//³ mv_par05         // Qual Moeda                               ³
//³ mv_par06         // Da emiss„o                               ³
//³ mv_par07         // At‚ a emiss„o                            ³
//³ mv_par08         // Comiss„o Zero                            ³
//³ mv_par09         // Considera P.Venda                        ³
//³ mv_par10         // Abate IR Comiss                          ³
//³ mv_par11         // Outras Moedas                            ³
//³ mv_par12         // Salta Pagina por Vendedor                ³
//³ mv_par13         // Nome cliente									  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cPictVal	:= PesqPict("SE1","E1_VLCRUZ")

oSection1 := TRSection():New(oReport,STR0024,{},) //"Registros"
TRCell():New(oSection1,"E1_FILORIG","SE1",STR0048,,,.F.,) //"FILIAL"
TRCell():New(oSection1,"E1_PREFIXO","SE1",STR0025,,,.F.,) //"PRF"
TRCell():New(oSection1,"E1_NUM","SE1",	STR0026+CRLF+STR0027,,,.F.,)//"TITULO" "PEDIDO"
TRCell():New(oSection1,"E1_PARCELA","SE1",STR0028,,3,.F.,)//"PRC"
TRCell():New(oSection1,"E1_CLIENTE"	,"SE1",STR0029+CRLF+STR0030,,,.F.,)//"CODIGO" "CLIENTE"
TRCell():New(oSection1,"E1_LOJA","SE1",STR0031,,,.F.,) //"LJ"
TRCell():New(oSection1,"A1_NOME","SA1",STR0032,,,.F.,) //"NOME"
TRCell():New(oSection1,"E1_EMISSAO","SE1",STR0033+CRLF+STR0034,,,.F.,) //"DATA DE""EMISSAO"
TRCell():New(oSection1,"E1_VENCREA","SE1",STR0035+CRLF+STR0036,,,.F.,) //"DATA""VENCTO"
TRCell():New(oSection1,"E1_VLCRUZ","SE1",STR0037+CRLF+STR0038,,,.F.,) //"VALOR""TITULO"
TRCell():New(oSection1,"VL_EMISS",,STR0039+CRLF+STR0040,cPictVal,13,.F.,) //"COMISSAO""P/EMISSAO"
TRCell():New(oSection1,"VL_BAIXA",,STR0039+CRLF+STR0041,cPictVal,13,.F.,) //"COMISSAO""P/BAIXA"
TRCell():New(oSection1,"VL_BASE",,STR0042+CRLF+STR0041,cPictVal,13,.F.,) //"VALOR BASE""P/BAIXA"
TRCell():New(oSection1,"PERC_COMI",,STR0043+CRLF+STR0044,"999.99",5,.F.,)//"%COMIS""TOTAL"
TRCell():New(oSection1,"VL_COMIS",,STR0045+CRLF+STR0046,cPictVal,13,.F.,) //"VALOR TOTAL""DA COMISSAO"
TRCell():New(oSection1,"PARC",,STR0047,,1,.F.,) //"P/T"

oSection1:Cell("E1_VLCRUZ"):SetHeaderAlign("RIGHT")
oSection1:Cell("VL_EMISS"):SetHeaderAlign("RIGHT")
oSection1:Cell("VL_BAIXA"):SetHeaderAlign("RIGHT")
oSection1:Cell("VL_BASE"):SetHeaderAlign("RIGHT")
oSection1:Cell("PERC_COMI"):SetHeaderAlign("RIGHT")
oSection1:Cell("VL_COMIS"):SetHeaderAlign("RIGHT")

oSection1:SetHeaderSection(.F.)

oReport:SetLandScape()

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³Daniel Batori          ³ Data ³22.08.06	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os  ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ReportPrint(oReport)

Local oSection1 := oReport:Section(1)
Local aDados[16]

Local cTitulo

LOCAL aCampos :={}
LOCAL cVendAnt:=Space(6)
LOCAL nComissao:=0.00
LOCAL nValTit :=0.00
LOCAL nComEnt :=0.00
LOCAL nComVen :=0.00
LOCAL nValBas :=0.00
LOCAL nPorc   :=0.00
LOCAL nVendComis :=0.00
LOCAL nTotTit :=0.00
LOCAL nTotEnt :=0.00
LOCAL nTotVen :=0.00
LOCAL nTotBas :=0.00
LOCAL nTotComis :=0.00
LOCAL lFirst:=.T.
LOCAL lPVen := .F.		// Flag diferenciador de pedido de venda
LOCAL aParcelas := {}	// Array das comissoes (geral)
LOCAL aParcItem := {}	// Array das comissoes (item)
LOCAL nVendSC5 := 0		// Codigo do vendedor no pedido
LOCAL nComiSC5 := 0		// Percentual Comissao no pedido
LOCAL nComiSC6 := 0		// Percentual comissao no item do pedido
LOCAL nPerComE := 0		// Percentual comissao na emissao vendedor
LOCAL nPerComB	:= 0		// Percentual comissao na Baixa vendedor
LOCAL nRegSC6	:= 0		// Registro do item de pedido
LOCAL nQtdItem := 0		// Quantidade de produtos nao entregues
LOCAL nPercItem:= 0		// Percentual a ser usado (pedido ou item)
LOCAL nVlTotPed:= 0		// Valor total do pedido nao entregue
LOCAL nIrEnt	:= 0		// Ir na Emissao
LOCAL nIrVen	:= 0		// Ir na Baixa
LOCAL nVendIr	:= 0		// total de Ir do vendedor
LOCAL nTotIrE	:= 0		// Total geral de IR na emissao
LOCAL nTotIrB	:= 0		// Total geral de IR na Baixa
LOCAL nTotIrVen:= 0		// Total geral de IR do relatorio
LOCAL nTotPorc := 0		// Percentual medio de comissoes do relatorio
LOCAL nTotCount:= 0
LOCAL nCount	:= 0
LOCAL nTotAbat := 0
Local aLiquid	:= {}
Local aSeqCont	:= {} //Controle de calculo de comissoes (Sequencia no SE5)
LOCAL aTam		:= {}
LOCAL aColu		:= {}
LOCAL nValMinRet	:= SuperGetMv( "MV_VLRETIR" ,,0) // Valor minimo para retencao do IR
Local nMoedaBco :=1, dDataConv
Local cTipo
Local cParcela
Local cPrefixo
Local cNum
Local cTipoFat
Local nBaseCom
Local nValorFat
Local nCond
Local JX
Local nIrrItem := 0
Local nInsItem := 0
Local nPisItem := 0
Local nCofItem := 0
Local nCslItem := 0
Local nIcmItem := 0
Local nIssItem := 0
Local nSolItem := 0
Local nRecOri	:= 0
Local nItem		:= 0
Local nTotImp	:= 0
Local nJurLiq	:= 0
Local nPerJur	:= 0
Local nDescLiq	:= 0
Local nPerDesc	:= 0
Local nVlrLiq	:= 0
Local nVendTit
Local nRecPrinc, nx1, ny1
Local lImpSub := .T.		// Imprime subtotal
Local lBxReneg	:=	.F.
Local lReneg		:=	.F.

Local aBaseFat := {}, aBaseFtAux, nX
Local aBaseAux := {}, nBaseAux, nPerAux
Local cNumLiq,_cEmp :=	""

Local lJuros   := .F. 
Local lDescont := .F. 

// Se a comissão será definida na liquidação ou na baixa (1 = Liq, 2 = Baixa)
Local lComiLiq 	:= SuperGetMv("MV_COMILIQ",,"1") == "2"
Local cA1Vend		:=	""
Local aSelFil		:= {}
Local cFilBack	:= cFilAnt
Local lTroca	:= .F.
Local cSeq		:= "00"
Local lGetParAut	:= FindFunction("GetParAuto")

Local lcomisir:= SuperGetMv("MV_COMISIR")    == "N"
Local lComiins:= GetNewPar("MV_COMIINS","N") == "N"
Local lComipis:= GetNewPar("MV_COMIPIS","N") == "N"
Local lComicof:= GetNewPar("MV_COMICOF","N") == "N"
Local lComicsl:= GetNewPar("MV_COMICSL","N") == "N"


Private nDecs   := MsDecimais(mv_par05)
Private nIndexSE5
Private aVendedor

//ESSA VALIDACAO É NECESSARIO APENAS PARA 
//RELEASE 12.1.7
If VALTYPE(MV_PAR16) != "C" 
	If MV_PAR16 == 1	// Considera Juros?
		lJuros := .T.
	Endif
Endif

If VALTYPE(MV_PAR17) != "C"
	If MV_PAR17 == 1	// Considera Desconto?
		lDescont := .T.
	Endif
Endif
//FIM VALIDACAO

If mv_par15 == 1 .And. !IsBlind()
	aAreaSM0 := SM0->(GetArea())
	_cEmp    :=FWSM0LayOut() //Funcao de Framework que retorna a configuracao da empresa no sigamat 
	If "E" $ _cEmP .OR. "U" $ _cEmP //Verifica se na configuracao Possui E - Empresa ou
	   aSelFil := FwSelectGC()		//U - Unidade de negocio.
	Else
		aSelFil := AdmGetFil(.F.,.F.,"SE5")
		If Empty(aSelFil)
			Aadd(aSelFil,cFilAnt)
		Endif
	Endif
ElseIf lGetParAut
	aRetAuto	:= GetParAuto("FINR610TestCase")
	aSelFil:= Iif(ValType(aRetAuto) == "A", aRetAuto, aSelFil)
	nRegSM0 := SM0->(Recno())
	SM0->(DbGoTo(nRegSM0))
Endif

If Empty(aSelFil)
	Aadd(aSelFil,cFilAnt)
EndIf

dbSelectArea("SE5")
nIndexSE5 := RetIndex("SE5")
dbSetOrder(nIndexSE5+1)
dbGoTop()

oSection1:Cell("E1_PREFIXO"):SetBlock( { || aDados[PREFIXO] })
oSection1:Cell("E1_NUM"):SetBlock( { || aDados[TITULO] })
oSection1:Cell("E1_PARCELA"):SetBlock( { || aDados[PARCELA] })
oSection1:Cell("E1_CLIENTE"):SetBlock( { || aDados[COD_CLI] })
oSection1:Cell("E1_LOJA"):SetBlock( { || aDados[LOJA] })
oSection1:Cell("A1_NOME"):SetBlock( { || aDados[NOME_CLI] })
oSection1:Cell("E1_EMISSAO"):SetBlock( { || aDados[DT_EMIS] })
oSection1:Cell("E1_VENCREA"):SetBlock( { || aDados[DT_VENC] })
oSection1:Cell("E1_VLCRUZ"):SetBlock( { || aDados[VAL_TIT] })
oSection1:Cell("VL_EMISS"):SetBlock( { || aDados[COM_EMISS] })
oSection1:Cell("VL_BAIXA"):SetBlock( { || aDados[COM_BAIXA] })
oSection1:Cell("VL_BASE"):SetBlock( { || aDados[VAL_BASE] })
oSection1:Cell("PERC_COMI"):SetBlock( { || aDados[PERC] })
oSection1:Cell("VL_COMIS"):SetBlock( { || aDados[VAL_COMIS] })
oSection1:Cell("PARC"):SetBlock( { || aDados[PARC] })
oSection1:Cell("E1_FILORIG"):SetBlock( { || aDados[CODFIL] })
oReport:OnPageBreak({ ||	oSection1:SetHeaderSection(.T.), ;
									aDados[TITULO] := " " , ;
									oSection1:SetHeaderSection(.T.) } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define array para arquivo de trabalho                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTam:=TamSX3("E1_FILORIG")
AADD(aCampos,{ "FILIAL" ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("E1_VEND1")
AADD(aCampos,{ "CODIGO" ,"C",aTam[1],aTam[2] } )
AADD(aCampos,{ "CHAVE"  ,"C",10,0 } )
AADD(aCampos,{ "NVEND"  ,"N",01,0 } )
AADD(aCampos,{ "PVEND"  ,"C",01,0 } )
AADD(aCampos,{ "CHVFAT" ,"N",10,0 } )
AADD(aCampos,{ "RECPRINC","N",10,0 } )
AADD(aCampos,{ "TABELA","C",03,0 } )

aTam := TamSX3("E1_CLIENTE")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de Trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If(_oFr610TRB <> NIL)
	
	_oFr610TRB:Delete()
	_oFr610TRB := NIL

EndIf

//Criando a tabela temporaria
_oFr610TRB := FwTemporaryTable():New("TRB")
//Setando as colunas
_oFr610TRB:SetFields(aCampos)
//Criando o indicie 
_oFr610TRB:AddIndex("1",{"CODIGO","FILIAL","CHAVE","TABELA"})
//Criando a Tabela Temporaria
_oFr610TRB:Create()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Defini‡„o dos cabe‡alhos                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitulo := oReport:Title() + STR0022 + GetMV("MV_MOEDA"+Str(mv_par05,1))
oReport:SetTitle(cTitulo)

dbSelectarea("TRB")
dbSetOrder(1)
dbGoTop()

dbSelectarea("SE1")
dbsetOrder(7)

oReport:SetMeter(SE1->(Reccount()))

If MV_PAR14 == 1
	Fr610ProcP(@oReport, ,aSelFil)
Else
	Fr610ProcF(@oReport, ,aSelFil)
Endif

dbSelectarea("TRB")
dbGotop()

oReport:SetMeter(TRB->(Reccount()))

oSection1:Init()
aFill(aDados,nil)

While TRB->(!Eof())

	lFirst  := .T.
	cVendAnt:= CODIGO
	nCount	:= 0
	
		While TRB->(!Eof()) .and. cVendAnt == CODIGO
					// Muda para a filial do título que irá tratar
					cFilAnt	:= TRB->FILIAL
					
					oReport:IncMeter()
			
					nComissao := 0
					nJurLiq		:= 0
					nPerJur		:= 0
					nDescLiq	:= 0
					nPerDesc	:= 0
					nVlrLiq		:= 0
					lImpSub := .T.
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se a previsao sera calculada por titulo ja gerado   ³
					//³ ou pedido de vendas.                                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If TRB->PVEND == "N"
						dbSelectArea("SE1")
						dbSetOrder(1)
						If TRB->CHVFAT > 0 .And. TRB->CHVFAT <> TRB->RECPRINC
							dbGOTO(TRB->CHVFAT)
						Else
							dbGoTo(Val(TRB->CHAVE))
							lTroca	:= .T.
						Endif
								
						// Títulos renegociados LIQUIDAÇÃO
						If MV_PAR14 == 2 .And. !Empty(SE1->E1_NUMLIQ) .And. ( !lJuros .Or. !lDescont )
							
							If cNumLiq != SE1->E1_NUMLIQ
								aLiquid 	:=	{}
								aSeqCont	:=	{}
								Fa440LiqSe1(SE1->E1_NUMLIQ,@aLiquid,,@aSeqCont)
								cNumLiq	:= SE1->E1_NUMLIQ
							EndIf
							
							aAreaSE1 := GetArea()
							For nX := 1 To Len(aLiquid)
								SE1->(DbGoTo(aLiquid[nX]))
								nJurLiq += F440JurLiq(SE1->(Recno()))
								nDescLiq += F440DesLiq(SE1->(Recno()))
								nVlrLiq  += SE1->E1_VLCRUZ
							Next nX
							RestArea(aAreaSE1)
							
							nVlrLiq := nVlrLiq + nJurLiq - nDescLiq
							nPerJur	:= IF( !lJuros, ((nJurLiq*1000)/nVlrLiq)/1000, 0)
							nPerDesc := IF( !lDescont, ((nDescLiq*1000)/nVlrLiq)/1000, 0)
							
						EndIf
			
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Calculo Bases, valores e percentuais de comissao.            ³
						//³ Constituicao de aBases{} retornada por FA440COMIS()          ³
						//³ Coluna 01    Vendedor        	       		                 ³
						//³ Coluna 02    Valor do Titulo    		                       ³
						//³ Coluna 03    Base Comissao Emissao			                    ³
						//³ Coluna 04    Base Comissao Baixa	                          ³
						//³ Coluna 05    Comissao Emissao										  ³
						//³ Coluna 06    Comissao Baixa                                  ³
						//³ Coluna 07    % Total da comissao                             ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						
						aBases  := Fa440Comis(SE1->(Recno()),.F.,.T.,,,TRB->RECPRINC)
						nBases 	:= aScan(aBases,{|x| x[1] == TRB->CODIGO })
						lBxReneg	:= .F.
						lReneg		:= .F.

                        aAreaSC5 := SC5->(GetArea())
                        DbSelectarea("SC5")
                        DbSetOrder(1)
                        If DbSeek(xFilial("SE1")+SE1->E1_PEDIDO)
                            aBases[Len(aBases)][4]  := aBases[Len(aBases)][4] - SC5->C5_XFRETE 
                            aBases[Len(aBases)][6]  := aBases[Len(aBases)][6] - ( SC5->C5_XFRETE * ( aBases[Len(aBases)][7] / 100 ) ) 
                        EndIf
                        RestArea(aAreaSC5)
                     						
						If lTroca
							dbGOTO(TRB->CHVFAT)
						EndIf
						If mv_par14 == 1
							If !Empty(SE1->E1_NUMLIQ) .Or. !Empty(SE1->E1_FATURA)
								lReneg	:= .T.
							EndIf 
						ElseIf	mv_par14 == 2 		
							If !Empty(SE1->E1_BAIXA)		
								SE5->(DbSetOrder(7))		//E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
								cSeq	:=	MaxSeqSe5(SE1->(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA))
								If SE5->(MSSeek(FWxFilial('SE5') + SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA + cSeq)))
									If SE5->E5_MOTBX == 'LIQ' .OR. SE5->E5_MOTBX ==	'FAT' 
										lBxReneg	:= .T.
									EndIf
								EndIf
							EndIf
						EndIf
						If lTroca
							dbGoTo(Val(TRB->CHAVE))
						EndIf
					
						If	!lBxReneg .And. !lReneg
						
							SE3->( dbSetOrder(3) )
							
							If Len(aBases) > 0
								If 	TRB->CHVFAT > 0 .And. (aBases[nBases][7] == 0 .or. IsFatura()) .And.;	// Existe mais de um percentual de comissao (comissao por produto)
									!SE3->( MsSeek( xFilial("SE3") + aBases[nBases,1]+SE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA) ) ) // Nao eh comissao realizada
									
									// Recalcula bases pelo total da nota de saida, sem considerar parcelas geradas.
									cA1Vend	:= Posicione("SA1",1,xFilial("SA1") + SE1->(E1_CLIENTE + E1_LOJA),"A1_VEND")
									
									If Empty(cA1Vend) .Or. (!Empty(cA1Vend) .And. cA1Vend == cVendAnt) 
										aBases := Fa440Comis(SE1->(Recno()),.F.,.T.,,.F./*Nao calcula por parcelas*/)
									EndIf										
									nBases 	:= aScan(aBases,{|x| x[1] == TRB->CODIGO })					
									If nBases > 0  //se encontrou vendendor
										If aBases[nBases][7] == 0
											aBaseAux := Fa440Comis(TRB->RECPRINC,.F.,.T.,,.F./*Nao calcula por parcelas*/)
											nBaseAux := aScan(aBaseAux,{|x| x[1] == TRB->CODIGO })
											If nBaseAux > 0
												If aBases[nBases][5]+aBases[nBases][6] == 0
												   If ( aBaseAux[nBaseAux][3]+aBaseAux[nBaseAux][4] ) > 0
													   nPerAux := ( aBases[nBases][3]+aBases[nBases][4] ) / ( aBaseAux[nBaseAux][3]+aBaseAux[nBaseAux][4] )
												   Else
													   nPerAux := 1
												   EndIf
												   aBases[nBases][5] := aBaseAux[nBaseAux][5]*nPerAux
												   aBases[nBases][6] := aBaseAux[nBaseAux][6]*nPerAux
												   If ( aBases[nBases][3]+aBases[nBases][4] ) > 0
													   aBases[nBases][7] := ( aBases[nBases][5]+aBases[nBases][6] ) / ( aBases[nBases][3]+aBases[nBases][4] ) * 100
												   EndIf
												EndIf
											EndIf
										EndIf
									EndIf
								EndIf
							EndIf
				
							If TRB->CHVFAT > 0
								dbGoTo(Val(TRB->CHAVE))
							Endif
							If nBases = 0
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Caso vendedor n„o seja encontrado...           ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								dbSelectArea("TRB")
								dbSkip()
								LOOP
							Endif
							cChaveSE3 := aBases[nBases,1]+SE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA)
							cTipo 	 := SE1->E1_TIPO
							cParcela	 := SE1->E1_PARCELA
				
							dbSelectArea("SE1")
							aAreaSE1 := GetArea()
							dbGoto(TRB->RECPRINC)
							nBaseCom	 := SE1->&("E1_BASCOM"+Str(TRB->NVEND,1)) // Utilizado para estornar a base de comissao do titulo
							nComissao := (SE1->&("E1_COMIS"+Str(TRB->NVEND,1))/100)*nBaseCom // Utilizado para estornar o valor da comissao do titulo
							RestArea(aAreaSE1)
				
							If !Empty(SE1->E1_FATURA) .And. AllTrim(SE1->E1_FATURA) != "NOTFAT"
								cTipoFat	:= SE1->E1_TIPOFAT
								// Localiza o titulo de fatura, pois no SE3 eh gerado o titulo de fatura
								// para verificar as comissoes que ja foram pagas.
								SE1->(MsSeek(xFilial("SE1")+E1_FATPREF+E1_FATURA)) // Localiza o titulo de fatura
								cPrefixo := SE1->E1_PREFIXO
								cNum	   := SE1->E1_NUM
								// Processar todas as parcelas da fatura gerada e verificar se a comissao
								// para a parcela nao foi paga.
								While xFilial("SE1")+SE1->(E1_PREFIXO+E1_NUM) == xFilial("SE1")+cPrefixo+cNum .And.;
										SE1->(!Eof())
									If SE1->E1_TIPO == cTipoFat
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ Verificar comissoes ja pagas                                 ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										cChaveSE3 := aBases[nBases,1]+SE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA)
										cTipo 	 := SE1->E1_TIPO
										cParcela	 := SE1->E1_PARCELA
										nValorFat := SE1->E1_VLCRUZ
										FA610ComPg(@aBases,cChaveSE3,nBases,cTipo,cParcela,nValorFat,nBaseCom,nComissao)
									Endif
									SE1->(DbSkip())
								End
								dbSelectArea("SE1")
								dbSetOrder(1)
								dbGOTO(Val(TRB->CHAVE))
							Else
								FA610ComPg(@aBases,cChaveSE3,nBases,cTipo,cParcela,SE1->E1_VLCRUZ,nBaseCom,nComissao)
							Endif
				
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Caso percentual de comissao seja retornado == a zero, devo   ³
							//³ calcular a media (Faturamento com comissao no item <> percen-³
							//³ tual do vendedor)                                            ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If aBases[nBases,7] == 0
								aBases[nBases,7] := (((aBases[nBases,5]+aBases[nBases,6])*100)/aBases[nBases,2])
							Endif
				
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Imprime o Vendedor caso possa imprimir Comiss„o Zero ou      ³
							//³ exista alguma comiss„o para o Vendedor                       ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If mv_par08 == 1 .or. aBases[nBases,6] != 0 .Or. aBases[nBases,5] != 0
								If lFirst
									dbSelectArea("SA3")
									dbSeek(cFilial+TRB->CODIGO)
				
									oReport:PrintText( PadR(STR0009 + TRB->CODIGO,16) + STR0010 + SA3->A3_NOME ) //"CODIGO : ""NOME : "
									oReport:SkipLine()
				
									dbSelectArea("TRB")
									lFirst := .F.
								Endif
								dbSelectArea("SE1")
								dbSetOrder(1)
								dbGOTO(Val(TRB->CHAVE))
								If cPaisLoc == "BRA"
								   nMoedaBco := 1
								   dDataConv := dDataBase
								Else
							   //	   nMoedaBco := SE1->E1_MOEDA
								   dDataConv := SE1->E1_EMISSAO
								EndIf
				
								aBases[nBases,2] := xMoeda(aBases[nBases,2],nMoedaBco,mv_par05,dDataConv,nDecs+1)
								aBases[nBases,4] := xMoeda(aBases[nBases,4],nMoedaBco,mv_par05,dDataConv,nDecs+1)
								aBases[nBases,5] := xMoeda(aBases[nBases,5],nMoedaBco,mv_par05,dDataConv,nDecs+1)
								aBases[nBases,6] := xMoeda(aBases[nBases,6],nMoedaBco,mv_par05,dDataConv,nDecs+1)
				
								aDados[PREFIXO]	:= E1_PREFIXO
								aDados[TITULO]	:= E1_NUM
								aDados[PARCELA]	:= E1_PARCELA
								aDados[COD_CLI]	:= E1_CLIENTE
								aDados[LOJA]		:= E1_LOJA
								aDados[CODFIL]	:= E1_FILORIG
								
								dbSelectArea("SA1")
								dbSeek(cFilial+SE1->E1_CLIENTE+SE1->E1_LOJA)
								aDados[NOME_CLI]	:= IF(mv_par13 == 1,SA1->A1_NREDUZ,SA1->A1_NOME)
								dbSelectArea("SE1")
								
								For nX := 1 To Len(aBases[nBases])
									If Str(nX,1) $ "2|4|5|6"
										aBases[nBases,nX] -= NoRound(aBases[nBases,nX] * nPerJur,nDecs)
										aBases[nBases,nX] += NoRound(aBases[nBases,nX] * nPerDesc,nDecs)
									EndIf
								Next nX
								
								nComissao := xMoeda(aBases[nBases,5] + aBases[nBases,6],nMoedaBco,mv_par05,dDataConv,nDecs+1)
				
								aDados[DT_EMIS]	:= E1_EMISSAO
								aDados[DT_VENC]	:= E1_VENCREA
								aDados[VAL_TIT]	:= E1_VALOR 
								aDados[COM_EMISS]	:= aBases[nBases,5]
								aDados[COM_BAIXA]	:= aBases[nBases,6]
								aDados[VAL_BASE]	:= aBases[nBases,4]
								aDados[PERC]		:= aBases[nBases,7]
								aDados[VAL_COMIS]	:= nComissao
								aDados[PARC]		:= "T"     // identificador de Titulo ou Pedido
								
								oSection1:PrintLine()
								aFill(aDados,nil)
				
							   	nValTit		+= E1_VALOR  
								nComEnt		+= aBases[nBases,5]
								nIrEnt		+= If(aBases[nBases,2] > nValMinRet,aBases[nBases,5] * (mv_par10/100),0)
								nComVen		+= aBases[nBases,6]
								nIrVen		+= If(aBases[nBases,2] > nValMinRet, aBases[nBases,6] * (mv_par10/100),0)
								nValBas		+= aBases[nBases,4]
								nPorc			+= aBases[nBases,7]
								nVendComis	+= nComissao
								nVendIr		+= If(aBases[nBases,2] > nValMinRet,(aBases[nBases,5]+aBases[nBases,6])* (mv_par10/100),0)
								nCount++
							Else
								lImpSub := .F.
							EndIf
						EndIf
						
					Else
						// calculo das comissoes p/ pedido venda
						dbSelectArea("SC5")
						dbSetOrder(1)
						DbGoto(Val(TRB->CHAVE))
						//Fecho os dados fiscais de um pedido antes de carregar um novo pedido
						MaFisEnd()
						//Inicializo a funcao fiscal
						MaFisIni(C5_CLIENTE,;// 1-Codigo Cliente/Fornecedor
									C5_LOJAENT,;		// 2-Loja do Cliente/Fornecedor
									IIf(C5_TIPO$'DB',"F","C"),;				// 3-C:Cliente , F:Fornecedor
									C5_TIPO,;				// 4-Tipo da NF
									C5_TIPOCLI,;		// 5-Tipo do Cliente/Fornecedor
									Nil,;
									Nil,;
									Nil,;
									Nil,;
									"MATA461")
			
						dbSelectArea("SC6")
						dbSetOrder(1)
						If dbSeek(xFilial("SC6")+SC5->C5_NUM)
							While !Eof() .and. SC6->C6_NUM == SC5->C5_NUM
								nRecOri := 0
								If !Empty(SC6->C6_NFORI) .And. !Empty(SC6->C6_ITEMORI)
									SD1->(dbSetOrder(1))
									If SD1->(MSSeek(xFilial("SD1")+SC6->C6_NFORI+SC6->C6_SERIORI+SC5->C5_CLIENTE+SC5->C5_LOJACLI+SC6->C6_PRODUTO+SC6->C6_ITEMORI))
										nRecOri := SD1->(Recno())
									Endif
								Endif
			
								MaFisAdd(C6_PRODUTO,;   	// 1-Codigo do Produto ( Obrigatorio )
									C6_TES,;	   	// 2-Codigo do TES ( Opcional )
									C6_QTDVEN,;  	// 3-Quantidade ( Obrigatorio )
									C6_PRCVEN,;		  	// 4-Preco Unitario ( Obrigatorio )
									a410Arred(C6_QTDVEN*C6_PRCVEN,"D2_DESCON")-C6_VALOR,; 	// 5-Valor do Desconto ( Opcional )
									"",;	   			// 6-Numero da NF Original ( Devolucao/Benef )
									"",;				// 7-Serie da NF Original ( Devolucao/Benef )
									nRecOri,;					// 8-RecNo da NF Original no arq SD1/SD2
									0,;					// 9-Valor do Frete do Item ( Opcional )
									0,;					// 10-Valor da Despesa do item ( Opcional )
									0,;					// 11-Valor do Seguro do item ( Opcional )
									0,;					// 12-Valor do Frete Autonomo ( Opcional )
									C6_VALOR ,;			// 13-Valor da Mercadoria ( Obrigatorio )
									0)					// 14-Valor da Embalagem ( Opiconal )
			
								SC6->(DBSkip())
							Enddo
						Endif
						nComissao	:= 0
						nVlTotPed	:= 0
						dbSelectArea("SC6")
						dbSetOrder(1)
						If dbSeek(xFilial("SC6")+SC5->C5_NUM)
							aParcelas	:= {}
							nVendSC5		:= SC5->(FieldPos("C5_VEND"+STR(TRB->NVEND,1)))
							nComiSC5		:= SC5->(FieldPos("C5_COMIS"+STR(TRB->NVEND,1)))
							nComiSC6		:= SC6->(FieldPos("C6_COMIS"+STR(TRB->NVEND,1)))
							dbSelectArea("SA3")
							dbSeek(xFilial("SA3")+SC5->(FieldGet(nVendsc5)))
							nPerComE		:= (SA3->A3_ALEMISS/100)
							nPerComB		:= (SA3->A3_ALBAIXA/100)
							dbSelectArea("SC6")
							nRegSC6 := Recno()
							// valor de nao entregues total no pedido
							bAcao:= {|| nVlTotPed += SC6->(C6_PRCVEN * (C6_QTDVEN - C6_QTDENT))}
							dbEval(bAcao,,{||!Eof() .and. SC6->C6_NUM == SC5->C5_NUM},,,.T.)
							dbGoto(nRegSC6)
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Constituicao de aParcelas{}				                       ³
							//³ Coluna 01    Data Vencto da Parcela			                 ³
							//³ Coluna 02    Valor da Parcela			                       ³
							//³ Coluna 03    Valor Comissao Emissao		                    ³
							//³ Coluna 04    Valor Comissao Baixa                            ³
							//³ Coluna 05    Base da Baixa                                   ³
							//³ Coluna 06    % Total da comissao                             ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							aParcelas := Condicao (nVlTotPed ,SC5->C5_CONDPAG,,SC5->C5_EMISSAO)
							aEval(aParcelas,{|elem| aadd(elem,0),aadd(elem,0),aadd(elem,0),aadd(elem,0),aadd(elem,0)})
							dbSelectArea("SC6")
							nItem		:= 0
							nTotImp	:= 0
							While !Eof() .and. SC6->C6_NUM == SC5->C5_NUM
								nItem++
								If SC6->C6_QTDENT >= SC6->C6_QTDVEN .Or.;
									!Empty(SC6->C6_BLOQUEI)          .Or.;
									Left(SC6->C6_BLQ,1) $ "RS"
									dbskip()
									Loop
								Endif
								nQtdItem := SC6->(C6_QTDVEN - C6_QTDENT)  // Qtde nao entregue
								nBasItem := SC6->(C6_PRCVEN * nQtdItem) 	// Valor ref. nao entregue
			
								nIrrItem := 0
								nInsItem := 0
								nPisItem := 0
								nCofItem := 0
								nCslItem := 0
								nIcmItem := 0
								nIssItem := 0
								nSolItem := 0
			
								If lcomisir
									nIrrItem := MafisRet(nItem, "IT_VALIRR")
									nBasItem -= nIrrItem
								Endif
								If lComiins
									nInsItem := MafisRet(nItem, "IT_VALINS")
									nBasItem -= nInsItem
								EndIf
								If lComipis
									nPisItem := MafisRet(nItem, "IT_VALPS2")// IT_VALPIS
									nBasItem -= nPisItem
								EndIf
								If lComicof
									nCofItem := MafisRet(nItem, "IT_VALCF2") // IT_VALCOF
									nBasItem -= nCofItem
								EndIf
								If lComicsl
									nCslItem := MafisRet(nItem, "IT_VALCSL")
									nBasItem -= nCslItem
								EndIf
			
								// Calcula abatimento de ISS e ICMS da base da comissao do vendedor
								SF4->(dbSetOrder(1))
								SF4->(MsSeek(xFilial("SF4")+SC6->C6_TES))
								If !(SF4->F4_ISS == "S")
									If ( SA3->A3_ICM == "N" )
										nIcmItem := MaFisRet(nItem, "IT_VALICM")
										nBasItem -= nIcmItem
									EndIf
								Else
									If ( SA3->A3_ISS == "N" )
										nIssItem := MaFisRet(nItem, "IT_VALISS")
										nBasItem -= nIssItem
									EndIf
								EndIf
								If ( SA3->A3_ICMSRET == "N" )
									nSolItem := MaFisRet(nItem, "IT_VALSOL")
									nBasItem -= nSolItem
								EndIf
                                           
								nPercItem:= IIF(SC6->(FieldGet(nComiSC6))== 0,;
													 SC5->(FieldGet(nComiSC5)),	 ;	// Percentual no Pedido
													 SC6->(FieldGet(nComiSC6)))		// Percentual no Item
								aParcItem:= Condicao(nBasItem,SC5->C5_CONDPAG,,SC5->C5_EMISSAO)
			
								//valor dos impostos do pedido
								nTotImp := nIrrItem + nInsItem + nPisItem + nCofItem + nCslItem + nIcmItem + nIssItem + nSolItem
			
								dbSelectArea("SC6")
								For nCond := 1 to Len(aParcItem)
									aParcelas[nCond,3] += ((aParcItem[nCond,2] * (nPercItem/100)) * nPerComE)
									aParcelas[nCond,4] += ((aParcItem[nCond,2] * (nPercItem/100)) * nPerComB) -  ( SC5->C5_XFRETE * (nPercItem/100) )
									aParcelas[nCond,5] += (aParcItem[nCond,2] * nPerComB) - ( SC5->C5_XFRETE * nPerComB )
 									aParcelas[nCond,7] += (nTotImp / Len(aParcItem))
								Next
								dbskip()
							Enddo
							For nCond := 1 to	Len(aParcelas)
								//aParcelas[nCond,6] += (((aParcelas[nCond,3]+aParcelas[nCond,4]) * 100) / (aParcelas[nCond,2] - aParcelas[nCond,7]))
								//Especifico Perfil , desconsiderar impostos/frete na base de comissao
								aParcelas[nCond,6] += (((aParcelas[nCond,3]+aParcelas[nCond,4]) * 100) / (aParcelas[nCond,5]))
								nComissao += (aParcelas[nCond,3]+aParcelas[nCond,4])
							Next
			
							// impressao das previsoes de comiss do ped venda
							If ( nComissao != 0 )
								If lFirst
									oReport:PrintText( PadR(STR0009 + TRB->CODIGO,16) + STR0010 + SA3->A3_NOME )
									oReport:SkipLine()
									dbSelectArea("TRB")
									lFirst := .F.
								Endif
			
								dbSelectArea("SC5")
								dbSetOrder(1)
								dbGOTO(Val(TRB->CHAVE))
			
								If cPaisLoc == "BRA"
								   nMoedaBco := 1
								   dDataConv := dDataBase
								Else
								   nMoedaBco := SC5->C5_MOEDA
								   dDataConv := SC5->C5_EMISSAO
								Endif
			
								For nCond := 1 to Len(aParcelas)
									If aParcelas[nCond,1] > mv_par03 .and.  ;
										aParcelas[nCond,1] < mv_par04
			
										aParcelas[nCond,2] := xMoeda(aParcelas[nCond,2],nMoedaBco,mv_par05,dDataConv,nDecs+1)
										aParcelas[nCond,3] := xMoeda(aParcelas[nCond,3],nMoedaBco,mv_par05,dDataConv,nDecs+1)
										aParcelas[nCond,4] := xMoeda(aParcelas[nCond,4],nMoedaBco,mv_par05,dDataConv,nDecs+1)
										aParcelas[nCond,5] := xMoeda(aParcelas[nCond,5],nMoedaBco,mv_par05,dDataConv,nDecs+1)
			
										aDados[TITULO]		:= C5_NUM
										aDados[PARCELA]	:= Str(nCond,3)
										aDados[COD_CLI]	:= C5_CLIENTE
										aDados[LOJA]		:= C5_LOJACLI
			
										dbSelectArea("SA1")
										dbSeek(cFilial+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
										aDados[NOME_CLI]	:= IF(mv_par13 == 1,SA1->A1_NREDUZ,SA1->A1_NOME)
										dbSelectArea("SC5")
			
										aDados[DT_EMIS]	:= C5_EMISSAO
										aDados[DT_VENC]	:= aParcelas[nCond,1]   //Vencto
										aDados[VAL_TIT]	:= aParcelas[nCond,2]
										aDados[COM_EMISS]	:= aParcelas[nCond,3]
										aDados[COM_BAIXA]	:= aParcelas[nCond,4]
										aDados[VAL_BASE]	:= aParcelas[nCond,5]
										aDados[PERC]		:= aParcelas[nCond,6]
										aDados[VAL_COMIS]	:= aParcelas[nCond,3]+aParcelas[nCond,4] //Total Comissao (Emissao+Baixa)
										aDados[PARC]		:= "P"     // identificador de Titulo ou Pedido
			
										oSection1:PrintLine()
										aFill(aDados,nil)
			
										nValTit		+= aParcelas[nCond,2]
										nComEnt		+= aParcelas[nCond,3]
										nIrEnt		+= If(aParcelas[nCond,2] > nValMinRet, aParcelas[nCond,3] * (mv_par10/100),0)
										nComVen		+= aParcelas[nCond,4]
										nIrVen		+= If(aParcelas[nCond,2] > nValMinRet, aParcelas[nCond,4] * (mv_par10/100),0)
										nValBas		+= aParcelas[nCond,5]
										nPorc			+= aParcelas[nCond,6]
										nVendComis	+= aParcelas[nCond,3]+aParcelas[nCond,4]
										nVendIr		+= If(aParcelas[nCond,2] > nValMinRet, aParcelas[nCond,3]+aParcelas[nCond,4] * (mv_par10/100),0)
										nCount++
									Endif
								Next
							Endif
						Endif
					EndIf
			dbSelectArea("TRB")
			dbSkip()
		End
		nTotTit  +=nValTit
		nTotEnt  +=nComEnt
		nTotIrE  +=nIrEnt
		nTotVen  +=nComVen
		nTotIrB  +=nIrVen
		nTotBas  +=nValBas
		nTotComis+=nVendComis
		nTotIrVen+=nVendIr
		nTotPorc += nPorc
		nTotCount+= nCount
	
		If ((nVendComis <> 0 .or. nTotCount > 0) .or. mv_par08 == 1 ) .And. lImpSub
			SubR4(nValTit,nComEnt,nComVen,nValBas,nPorc,nVendComis,nIrEnt,nIrVen,nVendIr,nCount,oReport,aDados)
		Endif
	
		nValTit		:= 0.00
		nComEnt		:= 0.00
		nIrEnt		:= 0.00
		nComVen		:= 0.00
		nIrVen		:= 0.00
		nValBas		:= 0.00
		nPorc 		:= 0
		nVendComis 	:= 0.00
		nVendIr		:= 0.00
	
		If mv_par12 == 1 // Salta Pagina por Vendedor? SIM/NAO
			oReport:EndPage()
		Endif
Enddo

If nTotComis <> 0
	TotR4(nTotTit,nTotEnt,nTotVen,nTotBas,nTotComis,nTotIrE,nTotIrB,nTotIrVen,nTotPorc,nTotCount,oReport,aDados)
Endif

//Fecho os dados fiscais de um pedido
MaFisEnd()

oSection1:Finish()

dbSelectarea("Trb")
dbCloseArea( )

dbSelectArea("SE3")
dbSetOrder(1)
DbSelectarea("SE1")
DbsetOrder(1)
dbClearFilter()
cFilAnt	:= cFilBack

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ SubR4		³ Autor ³  Daniel Tadashi Batori³ Data ³ 30.08.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime Sub-Total                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SubR4(void)		                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SubR4(nValTit,nComEnt,nComVen,nValBas,nPorc,nVendComis,nIrEnt,nIrVen,nVendIr,nCount,oReport,aDados)
Local oSection1 := oReport:Section(1)

oReport:SkipLine()

If mv_par10 > 0  // Aliquota IRRF
	aDados[NOME_CLI]	:= STR0013  //"SUBTOTAL DO VENDEDOR --->"
	aDados[VAL_TIT]	:= nValTit
	aDados[COM_EMISS]	:= nComEnt
	aDados[COM_BAIXA]	:= nComVen
	aDados[VAL_BASE]	:= nValBas
	aDados[PERC]		:= ""
	aDados[VAL_COMIS]	:= nVendComis

	oSection1:PrintLine()
	aFill(aDados,nil)

	aDados[NOME_CLI]	:= STR0014  //"TOTAL IR VENDEDOR    --->"
	aDados[COM_EMISS]	:= nIrEnt
	aDados[COM_BAIXA]	:= nIrVen
	aDados[PERC]		:= ""
	aDados[VAL_COMIS]	:= nVendIr

	oSection1:PrintLine()
	aFill(aDados,nil)

	aDados[NOME_CLI]	:= STR0011 // "TOTAL DO VENDEDOR    --->"
	aDados[VAL_TIT]	:= nValTit
	aDados[COM_EMISS]	:= nComEnt
	aDados[COM_BAIXA]	:= nComVen - nIrVen
	aDados[VAL_BASE]	:= nValBas
	aDados[PERC]		:= ""
	aDados[VAL_COMIS]	:= nVendComis - nVendiR
	oSection1:PrintLine()
	aFill(aDados,nil)

Else

	aDados[NOME_CLI]	:= STR0011 // "TOTAL DO VENDEDOR    --->"
	aDados[VAL_TIT]	:= nValTit
	aDados[COM_EMISS]	:= nComEnt
	aDados[COM_BAIXA]	:= nComVen
	aDados[VAL_BASE]	:= nValBas
	aDados[PERC]		:= ""
	aDados[VAL_COMIS]	:= nVendComis


	oSection1:PrintLine()
	aFill(aDados,nil)
EndIf

oReport:SkipLine()

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TOTR4		³ Autor ³  Paulo Boschetti      ³ Data ³ 30.08.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime Total De Comiss”es                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TotR4(void)		                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TotR4(nTotTit,nTotEnt,nTotVen,nTotBas,nTotComis,nTotIrE,nTotIrB,nTotIrVen,nTotPorc,nTotCount,oReport,aDados)
Local oSection1 := oReport:Section(1)

oReport:SkipLine()

If mv_par10 > 0  // Aliquota IRRF

	aDados[NOME_CLI]	:= STR0015   //"SUBTOTAL GERAL    --->"
	aDados[VAL_TIT]	:= nTotTit
	aDados[COM_EMISS]	:= nTotEnt
	aDados[COM_BAIXA]	:= nTotVen
	aDados[VAL_BASE]	:= nTotBas
	aDados[PERC]		:= ""
	aDados[VAL_COMIS]	:= nTotComis

	oSection1:PrintLine()
	aFill(aDados,nil)

	aDados[NOME_CLI]	:= STR0016  //"TOTAL GERAL IR    --->"
	aDados[COM_EMISS]	:= nTotIrE
	aDados[COM_BAIXA]	:= nTotIrB
	aDados[PERC]		:= ""
	aDados[VAL_COMIS]	:= nTotIrVen

	oSection1:PrintLine()
	aFill(aDados,nil)

	aDados[NOME_CLI]	:= STR0012  //"TOTAL  GERAL         --->"
	aDados[VAL_TIT]	:= nTotTit
	aDados[COM_EMISS]	:= nTotEnt
	aDados[COM_BAIXA]	:= nTotVen - nTotIrB
	aDados[VAL_BASE]	:= nTotBas
	aDados[PERC]		:= ""
	aDados[VAL_COMIS]	:= nTotComis - nTotIrVen

	oSection1:PrintLine()
	aFill(aDados,nil)

Else
	aDados[NOME_CLI]	:= STR0012  //"TOTAL  GERAL         --->"
	aDados[VAL_TIT]	:= nTotTit
	aDados[COM_EMISS]	:= nTotEnt
	aDados[COM_BAIXA]	:= nTotVen
	aDados[VAL_BASE]	:= nTotBas
	aDados[PERC]		:= ""
	aDados[VAL_COMIS]	:= nTotComis

	oSection1:PrintLine()
	aFill(aDados,nil)

EndIf

oReport:SkipLine()

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ GRAVACOM ³ Autor ³  Paulo Boschetti      ³ Data ³ 13.07.93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava Arquivo de Trabalho                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GRAVACOM(void)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GRAVACOM(nX,lPVen,nChvFat,cVend, nRecPrinc)
Local cAlias := Alias()
Local cTabela:= cAlias

Default nChvFat 	:= 0
Default cVend   	:= ""
Default nRecPrinc 	:= 0

dbSelectarea("TRB")
If Empty(cVend)
	cVend := IIf(lPVen,"SC5->C5_VEND","SE1->E1_VEND")+nX
	cVend := &cVend
Endif

nChave := AllTrim(Str(&(cAlias+"->(RECNO())")))

If TRB->(!DbSeek(cVend+cFilAnt+nChave+cTabela))  
	RecLock("TRB",.T.)
	Replace FILIAL With cFilAnt  
	Replace CODIGO With cVend
	Replace CHAVE  With AllTrim(Str(&(cAlias+"->(RECNO())")))
	Replace NVEND  With VAL(nX)
	Replace PVEND  With IIF(lPVen,"S","N")
	Replace RECPRINC With nRecPrinc
	If nChvFat > 0
		Replace CHVFAT With nChvFat
	Endif
	Replace TABELA With cTabela
	MsUnlock()
Endif
DbSelectarea(cAlias)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FA610COMPG³ Autor ³ Mauricio Pequim jr    ³ Data ³ 30.07.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica comissoes j  pagas								        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FA610COMPG(aBases,cChaveSE3)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                         	  	              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FA610ComPg(aBases,cChaveSE3,nBases,cTipo,cParcela,nValorFat,nBaseCom,nComissao)
Local nPercBase := 0
Local nPercEst

DEFAULT cTipo    := SE1->E1_TIPO
DEFAULT cParcela := SE1->E1_PARCELA
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Caso percentual de comissao seja retornado == a zero, devo   ³
//³ calcular a media (Faturamento com comissao no item <> percen-³
//³ tual do vendedor)                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aBases[nBases,7] == 0
	aBases[nBases,7] := (((aBases[nBases,5]+aBases[nBases,6])*100)/aBases[nBases,2])
Endif

dbSelectArea("SE3")
dbSetOrder(3)
If dbSeek(xFilial("SE3")+cChaveSE3)
	While !Eof() .and. xFilial("SE3")== SE3->E3_FILIAL .and.;
		SE3->E3_VEND+SE3->E3_CODCLI+SE3->E3_LOJA+SE3->E3_PREFIXO+SE3->E3_NUM+SE3->E3_PARCELA == cChaveSE3

		nPercEst	:= Abs(SE3->E3_BASE / nValorFat)
		   
	   If SE3->E3_BAIEMI == "E" .AND. EMPTY(SE3->E3_DATA) 
           If SE3->E3_COMIS < 0
				aBases[nBases,3] += SE3->E3_BASE
				aBases[nBases,5] += SE3->E3_COMIS
			Else
				If aBases[nBases,3] > 0 .and. SE3->E3_BASE <> aBases[nBases,3]
					nPercBase:= Round(NoRound((aBases[nBases,3] * 100) / SE3->E3_BASE, 3),2)
				Else
					nPercBase:= 100
				Endif
				aBases[nBases,3] -= Round(NoRound(SE3->E3_BASE  * (nPercBase/100) ,3),2)
				aBases[nBases,5] += Round(NoRound(SE3->E3_COMIS * (nPercBase/100) ,3),2)
			Endif
  		ElseIf !EMPTY(SE3->E3_DATA)
			If SE3->E3_BAIEMI == "B" .and. cTIPO+cPARCELA == SE3->E3_TIPO+SE3->E3_PARCELA .and. SE3->E3_COMIS > 0
				aBases[nBases,4] -= (nBaseCom*nPercEst)
				aBases[nBases,6] -= (nComissao*nPercEst)
			ElseIf SE3->E3_BAIEMI == "B" .and. cTIPO+cPARCELA == SE3->E3_TIPO+SE3->E3_PARCELA .and. SE3->E3_COMIS < 0
				aBases[nBases,4] += (nBaseCom*nPercEst)
				aBases[nBases,6] += (nComissao*nPercEst)
			Endif
		Endif
		SE3->(dbSkip())
	EndDo
EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Vendedor610 ³ Autor ³ Marcelo Celi Marques³Data ³ 18/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Complemento a função TitPrinc para retorno da array de     ³±±
±±³          ³ vendedores com dados de comissão de titulos principais     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Finr610.prx                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Vendedor610(cAliasSe1,nIndexSE5)
Local aAreaSe1 := GetArea()
Local aVend610	:= {{},{},{},{}}
TitPrinc(xFilial(cAliasSe1),(cAliasSe1)->e1_PREFIXO,(cAliasSe1)->e1_NUM,(cAliasSe1)->e1_PARCELA,(cAliasSe1)->e1_TIPO,"SE1",@aVend610,nIndexSE5)
RestArea(aAreaSe1)
Return aVend610

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Fr610ProcF  ³ Autor ³ Marcelo Celi Marques³Data ³ 23/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Trata o abastecimento do TRB a partir dos títulos filhos   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Finr610.prx                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Fr610ProcF(oReport,lEnd, aSelFil)
Local JX
Local nVendTit
Local nRecPrinc, nx1, ny1
// Se a comissão será definida na liquidação ou na baixa (1 = Liq, 2 = Baixa)
Local lComiLiq 	:= SuperGetMv("MV_COMILIQ",,"1") == "2"
Local nFilial	:= 0
Local cFilBack	:= cFilAnt
Local cFilSE1	:= ""
Local lFirstSE1	:= .T.

Default oReport := .F.
Default lEnd := .F.
Default aSelFil	:= { cFilAnt }

For nFilial := 1 to Len(aSelFil)
	cFilAnt	:= aSelFil[nFilial]
	cFilSE1	:= xFilial('SE1')

	If Empty(cFilSE1) .and. !lFirstSE1
		Loop	
	ElseIf Empty(cFilSE1)
		lFirstSE1	:= .F.	
	EndIf
	
	dbSeek(xFilial("SE1")+DtoS(mv_par03),.T.)	
	While SE1->(!Eof()) .and. xFilial("SE1") == SE1->E1_FILIAL .and. SE1->E1_VENCREA <= mv_par04
		lPVen := .F.
	
		If Valtype(oReport) <> "L"
			// chamado pelo r4
			oReport:IncMeter()
		Else
			// chamado pelo r3
			IF lEnd
				@PROW()+1,001 PSAY STR0008 // "CANCELADO PELO OPERADOR"
				Exit
			Endif
			IncRegua()
		Endif
	
		If E1_TIPO $ MVABATIM
			dbSkip()
			Loop
		Endif
	
		If E1_EMISSAO < mv_par06 .or. E1_EMISSAO > mv_par07
			dbSkip()
			Loop
		Endif
	
		// Despreza registros de outra moeda se escolhido nao imprimir
		If mv_par11 == 2 .AND. E1_MOEDA != mv_par05
			dbSkip()
			Loop
		Endif
	
		// Se título for uma liquidação e a comissão será gerada na liquidação
		If !Empty(E1_NUMLIQ) .And. !lComiLiq
			dbSkip()
			Loop
		Endif
		
		// Despreza Títulos originais pois parâmetro está setado para exibir somente renegociados.
		If mv_par14 == 2 .and. !Empty(E1_TIPOLIQ) .and. Empty(E1_NUMLIQ)
			dbSkip()
			Loop
		Endif
	
		aVendedor := Vendedor610("SE1",nIndexSE5)
	
		For nVendTit := 1 to len(aVendedor[1])
			For JX:=1 TO 5
				nx := Str(JX,1)
				cVendedor := aVendedor[1][nVendTit][JX]
				If !Empty(cVendedor)
	
					// Descobrir o recno() do titulo principal
					For nx1 := 1 to Len(aVendedor[1])
						nPos := aScan(aVendedor[1],{|x| x[nx1] == cVendedor})
						If nPos > 0
						   nx1 := Len(aVendedor[1])+1
						   dbSelectArea("SE1")
						   aAreaSE1 := GetArea()
						   dbSetOrder(1)
						   If dbSeek(aVendedor[4][nPos])
						      nRecPrinc := 0
						      For ny1 := 1 to 5
						      	If aVendedor[1][nPos][ny1] == cVendedor
						      	   nRecPrinc := SE1->(Recno())
						      	Endif
						      Next
						   Endif
						   RestArea(aAreaSE1)
						Endif
					Next
	
					If cVendedor >= mv_par01 .And. cVendedor <= mv_par02
						If !Empty(SE1->E1_FATURA) .And. (AllTrim(SE1->E1_FATURA) <> "NOTFAT")
							aAreaSE1 := GetArea()
							cCliente := E1_CLIENTE  //Declarar variaveis
							cLoja    := E1_LOJA
							cFatura  := E1_FATURA
							cFatPref := E1_FATPREF
							nChvFat  := SE1->(Recno())
							SE1->(dbSetOrder(1))
							SE1->(dbGotop())
							cChaveSE1 := xFilial("SE1") + cFatPref + cFatura
							SE1->(dbSeek(cChaveSE1))
							While(cChaveSE1 == xFilial("SE1") + E1_PREFIXO + E1_NUM)
								If SE1->E1_VENCREA >= mv_par03 .And. SE1->E1_VENCREA <= mv_par04
									If AllTrim(E1_FATURA) == "NOTFAT" .And. E1_SALDO > 0
										GravaCom(nX,lPVen,nChvFat,cVendedor,nRecPrinc)
				  					Endif
				  				Endif
				  				DbSkip()
							EndDo
							RestArea(aAreaSE1)
						Else
							GravaCom(nX,lPVen,,cVendedor,nRecPrinc)
						Endif
					Endif
				Endif
			Next
		Next
		SE1->(dbSkip())
	Enddo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se considera pedidos de venda                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par09 == 1  // Considera Ped. Venda
		
		cFilAnt	:= aSelFil[nFilial]
		
		lPVen := .T.
		dbSelectarea("SC5")
		dbsetOrder(2)
	
		If Valtype(oReport) <> "L"
			oReport:SetMeter(SC5->(Reccount()))
		Endif
	
		dbSeek(cFilial+DtoS(mv_par03),.T.)
		While !Eof() .and. cFilial == C5_FILIAL .and. C5_EMISSAO <= mv_par04
	
			If Valtype(oReport) <> "L"
				// chamado pelo r4
				oReport:IncMeter()
			Else
				// chamado pelo R3
				IF lEnd
					@PROW()+1,001 PSAY STR0008 // "CANCELADO PELO OPERADOR"
					Exit
				Endif
				IncRegua()
			Endif
	
			If C5_EMISSAO < mv_par06 .or. C5_EMISSAO > mv_par07
				dbSkip()
				Loop
			Endif
			For JX:=1 TO 5  // grava vendedores no arq TRB
				nx := Str(JX,1)
				IF !EMPTY(C5_VEND&nx.)
					If C5_VEND&nx. >= mv_par01 .and. C5_VEND&nx. <= mv_par02
						GravaCom(nX,lPVen)
					End
				End
			EndFor
			dbSkip()
		Enddo
	Endif
Next
cFilAnt	:= cFilBack
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Fr610ProcP  ³ Autor ³ Marcelo Celi Marques³Data ³ 23/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Trata o abastecimento do TRB a partir dos títulos pais     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Finr610.prx                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Fr610ProcP(oReport,lEnd, aSelFil)
Local JX
Local nVendTit
Local nRecPrinc, nx1, ny1,nJ
// Se a comissão será definida na liquidação ou na baixa (1 = Liq, 2 = Baixa)
Local lComiLiq 	:= SuperGetMv("MV_COMILIQ",,"1") == "2"
Local aTitulos := {}
Local lLiqui	 := .F.
Local cNumLiq  := ""
Local nFilial	:= 0
Local cFilSE1	:= ""
Local cFilBack	:= cFilAnt
Local lFirstSE1	:= .T.

Default oReport := .F.
Default lEnd := .F.
Default aSelFil	:= { cFilAnt }

For nFilial := 1 to Len(aSelFil)
	cFilAnt	:= aSelFil[nFilial]
	cFilSE1	:= xFilial('SE1')
	
	If (Empty(cFilSE1) .and. lFirstSE1) .or. !Empty(cFilSE1)
		lFirstSE1	:= .F.	
		dbSeek(xFilial("SE1")+DtoS(mv_par03),.T.)
		
		While SE1->(!Eof()) .and. xFilial("SE1") == SE1->E1_FILIAL .and. SE1->E1_VENCREA <= mv_par04		
			// Reposiciona filial para casos de compartilhamento do SE1
			cFilAnt	:= If(!Empty(SE1->E1_FILORIG),SE1->E1_FILORIG,cFilAnt)
					
			dbSelectArea("SE1")
			lPVen := .F.
			lLiqui := .F.
			aTitulos := {}
		
			If Valtype(oReport) <> "L"
				// chamado pelo r4
				oReport:IncMeter()
			Else
				// chamado pelo r3
				IF lEnd
					@PROW()+1,001 PSAY STR0008 // "CANCELADO PELO OPERADOR"
					Exit
				Endif
				IncRegua()
			Endif
		
			If E1_TIPO $ MVABATIM
				dbSkip()
				Loop
			Endif
		
			nRecSe1 	:= SE1->(Recno())

			dbSelectArea("SE1")
		
			If SE1->E1_EMISSAO < mv_par06 .or. SE1->E1_EMISSAO > mv_par07
				SE1->(dbSkip())
				Loop
			Endif
		
			// Despreza registros de outra moeda se escolhido nao imprimir
			If mv_par11 == 2 .AND. SE1->E1_MOEDA != mv_par05
				SE1->(dbSkip())
				Loop
			Endif
		
			nRecSe1 	:= SE1->(Recno())
			aArea       := GetArea()
			If SE1->E1_SALDO > 0
				dbSelectArea("SE5")
				dbSetOrder(10)
				If !Empty(SE1->E1_NUMLIQ) .AND. dbSeek(xFilial("SE5")+SE1->E1_NUMLIQ)
					lLiqui := .T.
					cNumLiq := SE1->E1_NUMLIQ
					dbSelectArea("SE1")
					SE1->(dbSetOrder(1))
					//Busca os titulos origens da liquidacao
					While SE5->(!Eof()) .And. xFilial("SE5") == SE5->E5_FILIAL .and. SubStr(SE5->E5_DOCUMEN,1,Len(cNumLiq)) == cNumLiq
						If SE5->E5_MOTBX = 'LIQ' .AND. SE5->E5_SITUACA != "C" .AND.  SE5->E5_TIPODOC == "BA"
							If ! SE1->(dbSeek(xFilial("SE1")+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO))
							   SE1->(dbGoto(nRecSe1))
							   aAdd(aTitulos, nRecSe1)
							Else
								aAdd(aTitulos, SE1->(Recno()))
							Endif
						EndIf
						SE5->(DBSkip())
					EndDo
				Endif
			Endif
			dbSelectArea("SE1")
			nRecSe1Pr	:= SE1->(Recno())
		
			SE1->(dbGoto(nRecSe1Pr))
			If "NOTFAT" $ SE1->E1_FATURA .And. Empty(Alltrim((E1_VEND1+E1_VEND2+E1_VEND3+E1_VEND4+E1_VEND5))) .And. SE1->E1_SALDO == 0
				cQuery := "SELECT * FROM " + RetSqlName("SE5") + " WHERE E5_FILIAL = '" + SE1->E1_FILIAL + "' AND "
				cQuery += "E5_FATURA = '" + SE1->E1_NUM + "' AND "
				cQuery += "D_E_L_E_T_=' ' "
				cQuery := ChangeQuery(cQuery)
				dbSelectArea("SE5")
				dbCloseArea()
				dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"SE5",.F., .T.)
				
				dbSelectArea("SE1")
				dbSetOrder(1)
				If (!Empty(SE5->E5_FATURA) .And. !("NOTFAT" $ SE5->E5_FATURA)) .And. dbSeek(xFilial("SE1")+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO)
					nRecSe1Pr := Recno()
				Else
					nRecSe1Pr := nRecSe1
				Endif
				dbSelectArea("SE5")
				dbCloseArea()
				ChKFile("SE5")
				dbSelectArea("SE5")
				dbSetOrder(1)
				
			ElseIf !Empty(SE1->E1_FATURA) .And. Empty(Alltrim((E1_VEND1+E1_VEND2+E1_VEND3+E1_VEND4+E1_VEND5))) .And. SE1->E1_SALDO == 0
		
			    dbSelectArea("SE3")
			    dbSetOrder(1)
			    If dbSeek(xFilial("SE3")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA)
					dbSelectArea("SE1")
					RestArea(aArea)
					SE1->(dbSkip())
			    	Loop
			    Endif
		
			    dbSelectArea("SE5")
			    dbSetOrder(10)
				If !Empty(SE1->E1_NUMLIQ) .AND. dbSeek(xFilial("SE5")+SE1->E1_NUMLIQ)
			    	dbSelectarea("SE1")
			    	dbSetOrder(1)
				    If ! dbSeek(xFilial("SE1")+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO)
					   SE1->(dbGoto(nRecSe1))
					Endif
				Endif
				dbSelectArea("SE1")
				nRecSe1Pr	:= SE1->(Recno())
			Endif
			If !lLiqui
				aadd(aTitulos, nRecSe1Pr)
			EndIf
		
			RestArea(aArea)
		
			For nJ := 1 To Len(aTitulos)
		
				For JX:=1 TO 5
					nx := Str(JX,1)
		
					dbSelectArea("SE1")
					SE1->(dbGoto(aTitulos[nJ]))
					//SE1->(dbGoto(nRecSe1Pr))
		
					IF !EMPTY(E1_VEND&nx.)
						If E1_VEND&nx. >= mv_par01 .and. E1_VEND&nx. <= mv_par02
		
							cVend    := E1_VEND&nx
							If !lLiqui
								RestArea(aArea)
							Endif
		
							If !Empty(SE1->E1_FATURA) .And. (AllTrim(SE1->E1_FATURA) <> "NOTFAT")
								aAreaSE1 := GetArea()
								cCliente := E1_CLIENTE  //Declarar variaveis
								cLoja    := E1_LOJA
								cFatura  := E1_FATURA
								cFatPref := E1_FATPREF
								cLiquid  := "/"
								nChvFat  := SE1->(Recno())
								SE1->(dbSetOrder(1))
								SE1->(dbGotop())
								cChaveSE1 := xFilial("SE1") + cFatPref + cFatura
								SE1->(dbSeek(cChaveSE1))
		
								While((cChaveSE1 == xFilial("SE1") + E1_PREFIXO + E1_NUM))
		
										If AllTrim(E1_FATURA) == "NOTFAT" .And. SE1->E1_SALDO > 0 .And. (If(!lComiLiq,If(Empty(E1_NUMLIQ),.T.,.F.),.T.))
										   	GravaCom(nX,lPVen,nChvFat,cVend,nRecSe1Pr)
					  					ElseIf AllTrim(E1_FATURA) == "NOTFAT" .And. SE1->E1_SALDO == 0 .And. !Empty(SE1->E1_TIPOLIQ)
					  						dbSelectArea("SE5")
					  						dbSetOrder(7)
					  						If dbSeek(xFilial("SE5")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE)
					  							nRegSE1 := SE1->(Recno())
					  							dbSelectarea("SE1")
					  							dbSetOrder(15)
					  							dbSeek(xFilial("SE1")+SE5->E5_DOCUMEN)
					  							cChaveLiq := SE1->E1_FILIAL+SE1->E1_NUMLIQ
					  							Do While cChaveLiq == SE1->E1_FILIAL+SE1->E1_NUMLIQ .And. !Eof()
					  								If SE1->E1_SALDO > 0 .And. (If(!lComiLiq,If(Empty(E1_NUMLIQ),.T.,.F.),.T.))
					  									GravaCom(nX,lPVen,nChvFat,cVend,nRecSe1Pr)
					  								Endif
					  								dbSkip()
					  							Enddo
					  							SE1->(dbGoto(nRegSE1))
					  							dbSetOrder(1)
					  						Endif
					  						dbSelectArea("SE1")
					  					Endif
		
					  				DbSkip()
								EndDo
		
								RestArea(aAreaSE1)
							Else
								If (lComiLiq .OR. ( !lComiLiq .And. Empty(E1_NUMLIQ) ))
									If ( Alltrim(SE1->E1_FATURA) <> "NOTFAT"   .and. SE1->E1_SALDO > 0) .or. (lLiqui .and. SE1->E1_SALDO == 0)
										//VERIFICAR SE DATA VENCTO ESTA NO RANGE DE/ATE
										If SE1->E1_VENCREA >= mv_par03 .And. SE1->E1_VENCREA <= mv_par04
											GravaCom(nX,lPVen,,cVend,nRecSe1Pr)
										EndIf
									Else
										aAreaSE1 := GetArea()
										dbSelectArea("SE3")
										dbSetOrder(1)
										If dbSeek(xFilial("SE1")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA))
											While SE3->(E3_FILIAL+E3_PREFIXO+E3_NUM+E3_PARCELA) == xFilial("SE1")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA)
												//VERIFICAR SE DATA VENCTO ESTA NO RANGE DE/ATE
												If SE1->E1_VENCREA >= mv_par03 .And. SE1->E1_VENCREA <= mv_par04
													//VERIFICAR SE E3_DATA ESTA PREENCHIDO
											       	If Empty(E3_DATA)
											       		RestArea(aAreaSE1)
														GravaCom(nX,lPVen,,cVend,nRecSe1Pr)
													EndIf
												EndIf
												SE3->(DbSkip())
											EndDo
										EndIf
									EndIf
								Endif
							Endif
						Endif
					Endif
				Next nX
			Next nJ
			RestArea(aArea)
			SE1->(dbSkip())
		Enddo
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se considera pedidos de venda                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par09 == 1  // Considera Ped. Venda
		
		cFilAnt	:= aSelFil[nFilial]
		
		lPVen := .T.
		dbSelectarea("SC5")
		dbsetOrder(2)
	
		If Valtype(oReport) <> "L"
			oReport:SetMeter(SC5->(Reccount()))
		Endif
	
		dbSeek(cFilial+DtoS(mv_par03),.T.)
		While !Eof() .and. cFilial == C5_FILIAL .and. C5_EMISSAO <= mv_par04
	
			If Valtype(oReport) <> "L"
				// chamado pelo r4
				oReport:IncMeter()
			Else
				// chamado pelo R3
				IF lEnd
					@PROW()+1,001 PSAY STR0008 // "CANCELADO PELO OPERADOR"
					Exit
				Endif
				IncRegua()
			Endif
	
			If C5_EMISSAO < mv_par06 .or. C5_EMISSAO > mv_par07
				dbSkip()
				Loop
			Endif
			For JX:=1 TO 5  // grava vendedores no arq TRB
				nx := Str(JX,1)
				IF !EMPTY(C5_VEND&nx.)
					If C5_VEND&nx. >= mv_par01 .and. C5_VEND&nx. <= mv_par02
						GravaCom(nX,lPVen)
					End
				End
			EndFor
			dbSkip()
		Enddo
	Endif
Next

cFilAnt := cFilBack
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IsFatura  ºAutor  ³Microsiga           º Data ³  03/08/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna se o titulo posicionado eh fatura                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function IsFatura()
Local lFatura	 := ( alltrim(SE1->E1_FATURA)=="NOTFAT")
Return(lFatura)

//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MaxSeqSe5

Função para verificação dda maior sequencia de baixa do título

@author    Rodrigo Oliveira
@version   12
@since     21/08/2017

@return cSeq - retorna a maior sequencia de baixa do título 
/*/
//-----------------------------------------------------------------------------------------------------

Static Function MaxSeqSe5(cChave)
Local cSeq		:= "01"
Local aAreaSE5	:= SE5->(GetArea())

SE5->(DbSetOrder(7))

If SE5->(DbSeek(cChave))

	While SE5->(!Eof()) .And. ;
		cChave == SE5->E5_FILIAL + SE5->E5_PREFIXO + SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_TIPO + SE5->E5_CLIENTE + SE5->E5_LOJA
		If cSeq < SE5->E5_SEQ
			cSeq	:= SE5->E5_SEQ
		EndIf
		SE5->(DbSkip())
	EndDo			
EndIf

RestArea(aAreaSE5)

Return cSeq