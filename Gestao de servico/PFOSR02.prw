#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#include 'parmtype.ch'

#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FILEIO.CH"

#DEFINE IMP_SPOOL 2

#DEFINE VBOX			080
#DEFINE VSPACE			011
#DEFINE HSPACE			010
#DEFINE SAYVSPACE		008
#DEFINE SAYHSPACE		008
#DEFINE HMARGEM			030
#DEFINE VMARGEM			030
#DEFINE MAXITEM			030   // Máximo de produtos para a primeira página
#DEFINE ITEMP1			018   // Quantidade de itens que podem ser impressos na página 1 + rodapé
#DEFINE MAXITEMP1		026   // Máximo de itens que podem ser impressos na página 1
#DEFINE MAXITEMP2		049   // Máximo de produtos para a pagina 2 em diante
#DEFINE MAXITEMP2F		069   // Máximo de produtos para a página 2 em diante quando a página não possui informações complementares
#DEFINE MAXITEMP3		025   // Máximo de produtos para a pagina 2 em diante (caso utilize a opção de impressao em verso) - Tratamento implementado para atender a legislacao que determina que a segunda pagina de ocupar 50%.
#DEFINE MAXITEMC		038   // Máxima de caracteres por linha de produtos/serviços
#DEFINE MAXMENLIN		080   // Máximo de caracteres por linha de dados adicionais
#DEFINE MAXMSG			013   // Máximo de dados adicionais por página
#DEFINE MAXVALORC		009   // Máximo de caracteres por linha de valores numéricos
#DEFINE MAXWIDTH		820//3168
#DEFINE MAXHEIGHT		2400
#DEFINE COLCAB1			002
#DEFINE COLCAB2			500
#DEFINE COLINF1			110
#DEFINE COLINF2			620
#DEFINE ITEMP1			1
#DEFINE MAXITP1			1
#DEFINE ITEMP2			46
#DEFINE MAXITP2			55
#DEFINE MAXGRP1			4

#DEFINE PD1_FILIAL		01
#DEFINE PD1_DOC			02
#DEFINE PD1_SERIE		03
#DEFINE PD1_FORNECE		04
#DEFINE PD1_LOJA		05
#DEFINE PD1_PEDIDO		06
#DEFINE PD1_ITEMPC		07
#DEFINE PD1_COD			08
#DEFINE PD1_UM			09
#DEFINE PD1_QUANT		10
#DEFINE PD1_VUNIT		11
#DEFINE PD1_TOTAL		12
#DEFINE PC7_PRECO		13
#DEFINE PC7_TOTAL		14
#DEFINE PDIFERENC		15
#DEFINE PD1_PICM		16
#DEFINE PD1_IPI			17
#DEFINE PD1_ALQCOF		18
#DEFINE PD1_ALQPIS		19
#DEFINE PD1_LOCAL		20
#DEFINE QBRTXT			70


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PFOSR02 ºAutor  ³ Gabriel Verissimo   º Data ³  25/09/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de Impressao da Ordem de Serviço Preventiva         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Perfil                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PFOSR02(_cFilial, _cOS, _cCli, _cLoja, _lAbrePDF)

	Local lRet  				:= .F.
	Local cPath 				:= AllTrim(GetTempPath())

	Private oPrinter
	Private nLinIni				:= 1
	Private nColIni				:= 2
	Private nLinAtu 			:= 0
	Private nColAtu 			:= 0 

	Private nConsNeg 			:= 0.4 // Constante para concertar o cálculo retornado pelo GetTextWidth para fontes em negrito.
	Private nConsTex 			:= 0.5 // Constante para concertar o cálculo retornado pelo GetTextWidth.
	Private aXML				:= {}

	//Parametros para o FWMSPrinter
	Private _cFilePrintert		:= "PFOSR02"
	Private _nDevice			:= IMP_PDF
	Private _lAdjustToLegacy	:= .F.
	Private _cPathInServer		:= AllTrim(GetTempPath())
	Private _lDisabeSetup		:= .T.
	Private _lTReport			:= .F.
	Private _oPrintSetup		:= nil
	Private _cPrinter			:= nil
	Private _lServer			:= .T.
	Private _lPDFAsPNG			:= .T.
	Private _lRaw				:= nil
	Private _lViewPDF			:= .T.
	Private _nQtdCopy			:= nil
	Private oSetup				:= nil

	Private _cPFFilial			:= xFilial("AB6")	//_cFilial
	Private _cPFOS				:= AB6->AB6_NUMOS	//_cOS
	Private _cPFCli				:= AB6->AB6_CODCLI	//_cCli
	Private _cPFLoja			:= AB6->AB6_LOJA	//_cLoja
	Private _lPFAbrePDF			:= .F.

	Private nQtdPag				:= 1 //0
	Private nPagAtu				:= 1
	Private aItens				:= {}
	Private nItens				:= 1
	Private lQuebra				:= .F.
	Private nTotal				:= 0
	Private lImpTotal			:= .T.
	Private nQtdItem			:= 0
	Private nQtdImp				:= 1
	Private aDadosEx			:= {}
	Private nIniImp	:= 486 // Linha final da seção acima e aonde começará imprimir a seção da execução (alterar essa linha caso a seção mude de lugar)

	Default _lAbrePDF			:= .T.

	_lPFAbrePDF := _lAbrePDF

	if _lPFAbrePDF == .F.
		_lViewPDF := .F.
	endif

	_cTime := Time()
	_cTime := alltrim(StrTran(_cTime,":",""))
	_cFilePrintert := _cFilePrintert+"_"+Alltrim(_cPFFilial)+"_"+Alltrim(_cPFOS)+"_"+DTOS(Date())+"_"+_cTime

	oPDF:= FWMsPrinter():New(_cFilePrintert,_nDevice,_lAdjustToLegacy,_cPathInServer,_lDisabeSetup,_lTReport,@_oPrintSetup,_cPrinter,_lServer,_lPDFAsPNG,_lRaw,_lViewPDF,_nQtdCopy )
	oPDF:SetResolution(78) //Tamanho estipulado para a Danfe
	oPDF:SetLandscape()
	oPDF:SetPaperSize(DMPAPER_A4)
	oPDF:SetMargin(60,60,60,60)
	oPDF:cPathPDF 	:= AllTrim(GetTempPath())

	Private PixelX := oPDF:nLogPixelX()
	Private PixelY := oPDF:nLogPixelY()

	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1") + _cPFCli + _cPFLoja))

	AB6->(DbSetOrder(1))
	_cChave := _cPFFilial + _cPFOS + _cPFCli + _cPFLoja
	If AB6->(DbSeek(_cChave))
		if AB6->AB6_XCLAOS <> "2"
			//Exibe HELP caso a OS posicionada não seja do tipo 'Preventiva'
			Help(NIL, NIL, "PFOSR02", NIL, "Ordem de Serviço não é do tipo preventiva", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Posicione em uma Ordem de Serviço do tipo preventiva para realizar a impressão deste relatório"})
			//Descarrega o spool de impressão
			Ms_Flush()
			//Elimina da memória a instância do objeto oPDF
			FreeObj(oPDF) 
			Return .F.
		endif
		If _lAbrePDF
			RptStatus({|lEnd| ImpDet(@oPDF)}, "Imprimindo Ordem de Serviço Preventiva, aguarde...")
		Else
			ImpDet(@oPDF)
		EndIf
	EndIf

Return _cPathInServer+_cFilePrintert

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ ImpDet   ³ Autor ³Gabriel Verissimo   º Data ³  25/09/19   º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Controle de Fluxo do Relatorio.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto grafico de impressao                    (OPC) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpDet(oPDF)

	PRIVATE oFont07    := TFontEx():New(oPDF,"Arial",06,06,.F.,.T.,.F.)// 7
	PRIVATE oFont07N   := TFontEx():New(oPDF,"Arial",06,06,.T.,.T.,.F.)// 7
	PRIVATE oFont08    := TFontEx():New(oPDF,"Arial",07,07,.F.,.T.,.F.)// 8
	PRIVATE oFont08C   := TFontEx():New(oPDF,"Courier New",07,07,.F.,.T.,.F.)// 8
	PRIVATE oFont08N   := TFontEx():New(oPDF,"Arial",06,06,.T.,.T.,.F.)// 8
	PRIVATE oFont09    := TFontEx():New(oPDF,"Arial",08,08,.F.,.T.,.F.)// 9
	PRIVATE oFont09N   := TFontEx():New(oPDF,"Arial",08,08,.T.,.T.,.F.)// 9
	PRIVATE oFont10    := TFontEx():New(oPDF,"Arial",09,09,.F.,.T.,.F.)// 10
	PRIVATE oFont10C   := TFontEx():New(oPDF,"Courier New",09,09,.F.,.T.,.F.)// 10
	PRIVATE oFont10N   := TFontEx():New(oPDF,"Arial",08,08,.T.,.T.,.F.)// 10
	PRIVATE oFont11    := TFontEx():New(oPDF,"Arial",10,10,.F.,.T.,.F.)// 11
	PRIVATE oFont11N   := TFontEx():New(oPDF,"Arial",10,10,.T.,.T.,.F.)// 11
	PRIVATE oFont12    := TFontEx():New(oPDF,"Arial",11,11,.F.,.T.,.F.)// 12
	PRIVATE OFONT12N   := TFontEx():New(oPDF,"Arial",11,11,.T.,.T.,.F.)// 12
	PRIVATE oFont14    := TFontEx():New(oPDF,"Arial",13,13,.F.,.T.,.F.)// 14
	PRIVATE oFont14N   := TFontEx():New(oPDF,"Arial",13,13,.T.,.T.,.F.)// 14 
	PRIVATE oFont16    := TFontEx():New(oPDF,"Arial",15,15,.F.,.T.,.F.)// 16
	PRIVATE oFont16N   := TFontEx():New(oPDF,"Arial",15,15,.T.,.T.,.F.)// 16 
	PRIVATE oFont18    := TFontEx():New(oPDF,"Arial",17,17,.T.,.T.,.F.)// 18 
	PRIVATE oFont18N   := TFontEx():New(oPDF,"Arial",17,17,.T.,.T.,.F.)// 18 
	PRIVATE oFont22    := TFontEx():New(oPDF,"Arial",21,21,.T.,.T.,.F.)// 18 
	PRIVATE oFont22N   := TFontEx():New(oPDF,"Arial",21,21,.T.,.T.,.F.)// 18 
	//PRIVATE lUsaColab	:=  UsaColaboracao("1")

	PrtNFD(@oPDF)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PrtNFD   ³ Autor ³Gabriel Verissimo   º Data ³  25/09/19   º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do formulario NFD grafico conforme laytout no     ³±±
±±³          ³formato retrato                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PrtNFD()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto grafico de impressao                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrtNFD(oPDF)

	Local nDetImp		:= 0
	Local nS			:= 0
	Local nX			:= 0
	Local nY			:= 0
	Local nL			:= 0
	Local nJ			:= 0
	Local nW			:= 0
	Local nTamanho		:= 0
	Local nFolha		:= 1
	Local nFolhas		:= 0
	Local nZ		    := 0 
	Local nMaxCod	    := 10
	Local nMaxDes	    := MAXITEMC 
	Local nLinhavers	:= 0
	Local nMaxItemP2	:= MAXITEM // Variável utilizada para tratamento de quantos itens devem ser impressos na página corrente 

	Private cLogo		:= "perfil_logo.png"
	Private cStartPath	:= GetSrvProfString("Startpath","")
	Private lPreview	:= .T.
	Private _aTotais	:= {0,0,0,0,0,0}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializacao do objeto grafico                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If oPDF == Nil
		lPreview := .T.
		oPDF 	:= FWMsPrinter():New(_cFilePrintert,_nDevice,_lAdjustToLegacy,_cPathInServer,_lDisabeSetup,_lTReport,@_oPrintSetup,_cPrinter,_lServer,_lPDFAsPNG,_lRaw,_lViewPDF,_nQtdCopy )
		oPDF:SetPortrait()
		oPDF:Setup()
	EndIf

	nLinIni := 0
	nColIni := 0
	nLinFim := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializacao da pagina do objeto grafico                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Posiciona no cadastro de Equipe
	AAX->(DbSetOrder(1)) //AAX_FILIAL+AAX_CODEQU
	If !AAX->(DbSeek(xFilial("AAX") + AB6->AB6_XEQUIP))
		conout("PFOSR02 - não localizou AAX")
	EndIf

	SZI->(DbSetOrder(1)) //ZI_FILIAL+ZI_NUMOS
	if !SZI->(DbSeek(xFilial("SZI") + AB6->AB6_NUMOS))
		conout("PFOSR02 - não localizou SZI")
	endif
	
	_cItem := ""
	AB7->(DbSetOrder(1)) //AB7_FILIAL+AB7_NUMOS+AB7_ITEM
	If AB7->(DbSeek(AB6->AB6_FILIAL + AB6->AB6_NUMOS))
		While !AB7->(EoF()) .And. AB7->AB7_FILIAL + AB7->AB7_NUMOS + AB7->AB7_CODCLI + AB7->AB7_LOJA == _cChave
			If _cItem <> AB7->AB7_ITEM
				_cItem := AB7->AB7_ITEM
			EndIf
			AB9->(DbSetOrder(1)) //AB9_FILIAL+AB9_NUMOS+AB9_CODTEC+AB9_SEQ
			If !AB9->(DbSeek(xFilial("AB9") + AB7->AB7_NUMOS + _cItem))
				conout("PFOSR02 - não localizou AB9")
				//Exibe HELP caso não encontre o registro de Atendimento da Ordem de Serviço 
				Help(NIL, NIL, "PFOSR02", NIL, "Atendimento não localizado", 1, 0, NIL, NIL, NIL, NIL, NIL, {"É necessário realizar o atendimento da Ordem de Serviço antes da impressão"})
				//Descarrega o spool de impressão
				Ms_Flush()
				//Elimina da memória a instância do objeto oPDF
				FreeObj(oPDF) 
				Return .F.
			EndIf
			oPDF:StartPage()
			
			GetExec()
			
			//Retorna itens do apontamento (AB8)
			GetItens()

			//Imprime cabeçalho + dados do cliente
			PrtCabec(@oPDF)
			
			//Imprime dados da ordem de serviço
			PrtDados(@oPDF)
			
			//Imprime dados da abertura da ordem de serviço
			PrtAtend(@oPDF)
			
			//Imprime dados do atendimento da ordem de serviço (AB9)
			PrtEquip(@oPDF)
			
			//Imprime cabeçalho do apontamento
			PrtCabEx(@oPDF)
			
			//Imprime itens do apontamento
			PrtProd(@oPDF)

			PrtItens(@oPDF)
			
			//Imprime rodapé
			PrtRodape(@oPDF)
			
			oPDF:EndPage()
			AB7->(DbSkip())
		End
	EndIf

	oPDF:Preview()
	Ms_Flush() //Descarrega o spool de impressão
	FreeObj(oPDF) //Elimina da memória a instância do objeto oPDF

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PrtCabec ³ Autor ³ Gabriel Verissimo   º Data ³  25/09/19  º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao do Cabecalho do Relatório                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrtCabec(oPDF)

	Local aMail := {}
	Local nI	:= 0

//	oPDF:Box(0, 0, 860, 605)
	oPDF:Box(0, 0, 608, 870)
	nColAtu := 0
	nLinAtu := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Logotipo da Empresa													   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ												
	If File(cLogo) .or. Resource2File ( cLogo, cStartPath+"system\"+cLogo)
		oPDF:SayBitmap(nLinAtu+005,nColAtu+005,cLogo, 150, 70)
	EndIf
	//**CORRIGIR CONTAGEM DE PÁGINAS**
	oPDF:Say(nLinAtu+010, nColAtu+810, "Página " + cValToChar(nPagAtu) + " de " + cValToChar(nQtdPag), oFont08:oFont)
	// oPDF:Say(nLinAtu+010, nColAtu+810, "Página " + cValToChar(nPagAtu) + " de 3" , oFont08:oFont)
	
	oPDF:Say(nLinAtu+=36	, nColAtu+352, "Ordem de Serviço Preventiva", oFont22N:oFont)
	oPDF:Say(nLinAtu+=50	, nColAtu+710, "OS - Nr. " + AB6->AB6_NUMOS, oFont18N:oFont)
	nLinAtu := 110

	//DADOS DO CLIENTE
	oPDF:Say(nLinAtu+=30	, nColAtu+002, "DADOS DO CLIENTE", oFont18N:oFont)
	oPDF:Line(nLinAtu+=003, 0, nLinAtu, 870)

	//Primeira Coluna
	nLinIni := nLinAtu
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB1, "Sigla/Número"							, oFont14:oFont)
	oPDF:Say(nLinAtu		, nColAtu+COLINF1, SA1->A1_COD + " - " + SA1->A1_NOME		, oFont14:oFont)
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB1, "Bandeira"								, oFont14:oFont)
	oPDF:Say(nLinAtu		, nColAtu+COLINF1, SA1->A1_LOJA								, oFont14:oFont)
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB1, "Loja"									, oFont14:oFont)
	oPDF:Say(nLinAtu		, nColAtu+COLINF1, AllTrim(SA1->A1_BAIRRO)					, oFont14:oFont)
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB1, "Endereço"								, oFont14:oFont)
	oPDF:Say(nLinAtu		, nColAtu+COLINF1, AllTrim(SA1->A1_END)						, oFont14:oFont)
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB1, "CEP"									, oFont14:oFont)
	oPDF:Say(nLinAtu		, nColAtu+COLINF1, Transform(SA1->A1_CEP, "@R 99.999-999")	, oFont14:oFont)
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB1, "Cidade"									, oFont14:oFont)
	oPDF:Say(nLinAtu		, nColAtu+COLINF1, AllTrim(SA1->A1_MUN)						, oFont14:oFont)
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB1, "Estado"									, oFont14:oFont)
	oPDF:Say(nLinAtu		, nColAtu+COLINF1, AllTrim(SA1->A1_EST)						, oFont14:oFont)
	nLinFim := nLinAtu

	//Segunda Coluna
	nLinAtu := nLinIni
	aMail := QuebrTxt(StrTran(AllTrim(SA1->A1_XMAILGE), ";", " "), 39)
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB2, "CNPJ"											, oFont14:oFont)
	oPDF:Say(nLinAtu		, nColAtu+COLINF2, Transform(SA1->A1_CGC, "@R 99.999.999/9999-99")	, oFont14:oFont)
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB2, "I.E."											, oFont14:oFont)
	oPDF:Say(nLinAtu		, nColAtu+COLINF2, Transform(SA1->A1_INSCR, "@R 9999.999.99")		, oFont14:oFont)
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB2, "Solicitante"									, oFont14:oFont)
	oPDF:Say(nLinAtu		, nColAtu+COLINF2, AB6->AB6_XSOLIC									, oFont14:oFont)
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB2, "E-Mail"											, oFont14:oFont)
	//oPDF:Say(nLinAtu		, nColAtu+COLINF2, AllTrim(SA1->A1_XMAILGE), oFont14:oFont)
	For nI := 1 To Len(aMail)
		oPDF:Say(nLinAtu	, nColAtu+COLINF2, aMail[nI], oFont14:oFont)
		nLinAtu+=VSPACE
	Next

	//Caso a segunda coluna seja maior que a primeira, atualizar a posição da linha atual
	If nLinAtu < nLinFim
		nLinAtu := nLinFim
	EndIf
	nLinFim := nLinAtu



Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PrtDados ³ Autor ³ Gabriel Verissimo   º Data ³  25/09/19  º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao do Dados da OS 		                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PrtDados(oPDF)

	Local cCateg	:= ""
	Local cTipo		:= ""

	//DADOS DA ORDEM DE SERVIÇO
	nLinAtu := nLinFim
	nColAtu := 0

	if AB6->AB6_XCATEG == "1"
		cCateg := "Refrigeração"
	elseif AB6->AB6_XCATEG == "2"
		cCateg := "Ar Condicionado"
	endif
	
	if AB6->AB6_XCLFOS == "1"
		cTipo := "Contrato"
	elseif AB6->AB6_XCLFOS == "2"
		cTipo := "Garantia"
	elseif AB6->AB6_XCLFOS == "3"
		cTipo := "Avulso"
	endif

	oPDF:Say(nLinAtu+=30, nColAtu+002, "DADOS DA ORDEM DE SERVIÇO", oFont18N:oFont)

	oPDF:Line(nLinAtu+=003, 0, nLinAtu, 870)

	oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB1, "Sigla/Número"							, oFont14:oFont)
	oPDF:Say(nLinAtu		, nColAtu+COLINF1, SA1->A1_COD + " - " + SA1->A1_NOME		, oFont14:oFont)

	oPDF:Say(nLinAtu+=VSPACE, nColAtu+002, "Categoria"		, oFont14N:oFont)
	oPDF:Say(nLinAtu		, nColAtu+100, "Tipo"			, oFont14N:oFont)
	oPDF:Say(nLinAtu		, nColAtu+230, "Data Início"	, oFont14N:oFont)
	oPDF:Say(nLinAtu		, nColAtu+320, "Hora Início"	, oFont14N:oFont)
	oPDF:Say(nLinAtu		, nColAtu+420, "Data Término"	, oFont14N:oFont)
	oPDF:Say(nLinAtu		, nColAtu+520, "Hora Término"	, oFont14N:oFont)
						
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+002, cCateg		  	, oFont14:oFont)
	oPDF:Say(nLinAtu		, nColAtu+100, cTipo		  	, oFont14:oFont)
	oPDF:Say(nLinAtu		, nColAtu+230, DtoC(dDatabase)	, oFont14:oFont)
	oPDF:Say(nLinAtu		, nColAtu+320, "10:00"		  	, oFont14:oFont)
	oPDF:Say(nLinAtu		, nColAtu+420, DtoC(dDatabase)	, oFont14:oFont)
	oPDF:Say(nLinAtu		, nColAtu+520, "14:00"		  	, oFont14:oFont)

	nLinAtu+=VSPACE
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+002, "Equipe"			, oFont14:oFont)
	oPDF:Say(nLinAtu		, nColAtu+100, AAX->AAX_XMAILM	, oFont14:oFont)
	oPDF:Say(nLinAtu		, nColAtu+320, AAX->AAX_XMAILV	, oFont14:oFont)
	oPDF:Say(nLinAtu		, nColAtu+540, AAX->AAX_XMAILR	, oFont14:oFont)

	nLinFim := nLinAtu

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PrtAtend ³ Autor ³ Gabriel Verissimo   º Data ³  25/09/19  º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao do Dados do Atendente da OS                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PrtAtend(oPDF)
	//ABERTURA DA OS
	nLinAtu := nLinFim
	nColAtu := 0

	oPDF:Say(nLinAtu+=30, nColAtu+002, "TÉCNICO", oFont18N:oFont)
	
	oPDF:Line(nLinAtu+=003, 0, nLinAtu, 870)

	// oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB1, AB6->AB6_XIDTEC, oFont14:oFont)
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB1, AllTrim(AB6->AB6_XCOLAB), oFont14:oFont)

	nLinFim := nLinAtu

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PrtExec ³ Autor ³ Gabriel Verissimo   º Data ³  25/09/19   º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao do Dados do Equipamento da OS                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PrtEquip(oPDF)

	Local cImgAtiv := ""
	//EXECUÇÃO DA OS
	nLinAtu := nLinFim
	nColAtu := 0

	oPDF:Say(nLinAtu+=30	, nColAtu+002, "DADOS DO EQUIPAMENTO", oFont18N:oFont)
	oPDF:Line(nLinAtu+=003, 0, nLinAtu, 870)
	xLinIni := nLinAtu

	SB1->(DbSetOrder(1))
	if !SB1->(DbSeek(xFilial("SB1") + AB7->AB7_CODPRO))
		conout("Não foi possível localizar produto no cadadstro")
	endif
	
	//Primeira coluna
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB1, "Ativo",oFont14:oFont)
	oPDF:Say(nLinAtu		, nColAtu+COLINF1, AB7->AB7_NUMSER,oFont14:oFont)
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB1, "Equipamento",oFont14:oFont)
	oPDF:Say(nLinAtu		, nColAtu+COLINF1, SB1->B1_DESC,oFont14:oFont)
	
	oPDF:Box(xLinIni+003, nColAtu+450, nLinAtu+=090, nColAtu+750)
	//Retorna caminho da imagem do ativo do Atendimento da Ordem de Serviço
	cImgAtiv := GetUrlImg(AllTrim(AB9->AB9_XFOTO), 2)
	If File(cImgAtiv) .or. Resource2File (cLogo, cStartPath+"system\"+cImgAtiv)
		oPDF:SayBitmap(378, nColAtu+451, cImgAtiv, 250, 109)
	EndIf
	//Caso a segunda coluna seja maior que a primeira, atualizar a posição da linha atual
	If nLinAtu < nLinFim
		nLinAtu := nLinFim
	EndIf
	nLinFim := nLinAtu
	conout("linha final do equipamento")
	conout(nLinAtu)

Return

Static Function GetExec()

	Local cGrupo 	:= ""
	Local cConj		:= ""
	Local cIdent	:= ""
	Local cExec		:= ""
	Local cStatus	:= ""
	// Local aDadosEx	:= {}
	Local nZ		:= 0
	Local nPosGrp	:= 0
	Local nLinTot	:= 0
	// Local nIniImp	:= 486 // Linha final da seção acima e aonde começará imprimir a seção da execução (alterar essa linha caso a seção mude de lugar)
	Local cGrpImp 	:= ""
	Local aChkList	:= {}
	Local aExec		:= {}
	Local aStExec	:= {}
	Local nLinIni	:= 0

	SZI->(DbSetOrder(1)) //ZI_FILIAL+ZI_NUMOS
	if SZI->(DbSeek(xFilial("SZI") + AB6->AB6_NUMOS))
		while !SZI->(EoF()) .And. SZI->ZI_NUMOS == AB6->AB6_NUMOS
			// Conjunto/Peça
			SZH->(DbSetOrder(1)) // ZH_FILIAL+ZH_COD
			if SZH->(DbSeek(xFilial("SZH") + SZI->ZI_CONJUN))
				
				cConj := AllTrim(SZH->ZH_XDESC) //AllTrim(SZH->ZH_DESC)
				if empty(alltrim(cConj))					
					cConj := AllTrim(SZH->ZH_DESC) //AllTrim(SZH->ZH_DESC)
				endif

				if SZH->ZH_GRUPREV == "1"
					cGrupo := "MECÂNICO"
				elseif SZH->ZH_GRUPREV == "2"
					cGrupo := "ELÉTRICA"
				elseif SZH->ZH_GRUPREV == "3"
					cGrupo := "STATUS DO EQUIPAMENTO"
				elseif SZH->ZH_GRUPREV == "4"
					cGrupo := "AUTOMAÇÃO"
				endif
			endif

			// Identificação
			SZD->(DbSetOrder(1))
			if SZD->(DbSeek(xFilial("SZD") + SZI->ZI_IDENTIF))
				cIdent := AllTrim(SZD->ZD_DESC)
			endif

			// Execução
			SZB->(DbSetOrder(1))
			if SZB->(DbSeek(xFilial("SZB") + SZI->ZI_EXEC))
				cExec := AllTrim(SZB->ZB_DESC)
			endif

			// Status da Execução
			SZG->(DbSetOrder(1))
			if SZG->(DbSeek(xFilial("SZG") + SZI->ZI_STEXEC))
				cStatus := AllTrim(SZG->ZG_DESC)
			endif

			// Adiciona todas as variáveis dentro do array que será percorrido e impresso
			aAdd(aDadosEx, {cGrupo, cConj, cIdent, cExec, cStatus})

			SZI->(DbSkip())
		end
	endif

	// oPDF:Say(nLinAtu+=030	, nColAtu+002, "EXECUÇÃO DA ORDEM DE SERVIÇO", oFont18N:oFont)
	// oPDF:Line(nLinAtu+=003, 0, nLinAtu, 870)
	nIniImp += 033
	For nI := 1 To Len(aDadosEx)
		If nIniImp >= 576
			nQtdPag++
			nIniImp := 220
			nIniImp += 003
		EndIf
		if aDadosEx[nI][1] <> cGrpImp
			cGrpImp := aDadosEx[nI][1]
			nIniImp += VSPACE
			nIniImp += 003
			nIniImp += VSPACE
			nIniImp += 003
		endif

		aChkList 	:= QuebrTxt(aDadosEx[nI][2], QBRTXT)
		aExec 		:= QuebrTxt(aDadosEx[nI][3], QBRTXT)
		aStExec 	:= QuebrTxt(aDadosEx[nI][4], QBRTXT)

		nIniImp += VSPACE
		nLinIni := nIniImp
		For nX := 1 To Len(aChkList)
			nIniImp += VSPACE
		Next nX
		nLinMax := nIniImp
		nIniImp := nLinIni
		For nX := 1 To Len(aExec)
			nIniImp += VSPACE
		Next nX
		// nLinMax := nIniImp
		nLinMax := iif(nIniImp > nLinMax, nIniImp, nLinMax)
		nIniImp := nLinIni
		For nX := 1 To Len(aStExec)
			nIniImp += VSPACE
		Next nX
		if nLinMax > nIniImp
			nIniImp := nLinMax
		endif
		nIniImp += 003
	Next nI

	conout("linha final de impressão após dados de execução")
	conout(nIniImp)
	
	conout("fim getExec")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PrtCabEx ³ Autor ³ Gabriel Verissimo   º Data ³  25/09/19  º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao do cabeçalho dos dados de execução da OS         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PrtCabEx(oPDF)

	Local nI		:= 0
	Local aChkList	:= {}
	Local aExec		:= {}
	Local aStExec	:= {}
	Local cGrpImp	:= ""
	
	//CABEÇALHO DOS ITENS
	nLinAtu := nLinFim
	nColAtu := 0

	// conout(VarInfo("aDadosEx", aDadosEx,,.F.))
	// Impressão do cabeçalho
	oPDF:Say(nLinAtu+=030	, nColAtu+002, "EXECUÇÃO DA ORDEM DE SERVIÇO", oFont18N:oFont)
	oPDF:Line(nLinAtu+=003, 0, nLinAtu, 870)
	For nI := 1 To Len(aDadosEx)
		If nLinAtu >= 576
			QuebraPag()
			nLinAtu+=003
		EndIf
		oPDF:Line(nLinAtu, 0, nLinAtu, 870) 
		if AllTrim(aDadosEx[nI][1]) <> AllTrim(cGrpImp)
			cGrpImp := aDadosEx[nI][1]
			// Impressão do grupo da preventiva
			oPDF:Say(nLinAtu+=VSPACE, nColAtu+420	, "GRUPO: " + aDadosEx[nI][1], oFont14N:oFont)
			oPDF:Line(nLinAtu+=003, 0, nLinAtu, 870)
			oPDF:Say(nLinAtu+=VSPACE, nColAtu+002, "Checklist",oFont14N:oFont)
			oPDF:Say(nLinAtu		, nColAtu+150, "Identificação",oFont14N:oFont)
			oPDF:Say(nLinAtu		, nColAtu+400, "Execução",oFont14N:oFont)
			oPDF:Say(nLinAtu		, nColAtu+620, "Status da Execução",oFont14N:oFont)
			oPDF:Line(nLinAtu+=003, 0, nLinAtu, 870)
		endif
		aChkList := QuebrTxt(aDadosEx[nI][2], QBRTXT)
		aExec := QuebrTxt(aDadosEx[nI][3], QBRTXT)
		aStExec := QuebrTxt(aDadosEx[nI][4], QBRTXT)
		oPDF:Say(nLinAtu+=VSPACE, nColAtu+002, aDadosEx[nI][1], oFont14:oFont) // Conjunto/Peça
		// oPDF:Say(nLinAtu		, nColAtu+150, aDadosEx[nI][2], oFont14:oFont) // Identificação
		nLinIni := nLinAtu
		For nX := 1 To Len(aChkList)
			oPDF:Say(nLinAtu	, nColAtu+400, aChkList[nX] 		 , oFont14:oFont) // Execução
			nLinAtu += VSPACE
		Next nX
		nLinMax := nLinAtu
		nLinAtu := nLinIni
		For nX := 1 To Len(aExec)
			oPDF:Say(nLinAtu	, nColAtu+400, aExec[nX] 		 , oFont14:oFont) // Execução
			nLinAtu += VSPACE
		Next nX
		// nLinMax := nLinAtu
		nLinMax := iif(nLinAtu > nLinMax, nLinAtu, nLinMax)
		nLinAtu := nLinIni
		For nX := 1 To Len(aStExec)
			oPDF:Say(nLinAtu	, nColAtu+620, aStExec[nX] 		 , oFont14:oFont) // Status de Execução
			nLinAtu += VSPACE
		Next nX
		if nLinMax > nLinAtu
			nLinAtu := nLinMax
		endif
		// oPDF:Say(nLinAtu		, nColAtu+620, aDadosEx[nI][4], oFont14:oFont) // Status daExecução
		nLinAtu += 003
	Next nI

	nLinFim := nLinAtu

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PrtItEx ³ Autor ³ Gabriel Verissimo   º Data ³  25/09/19   º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao dos itens da execução da OS                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/* Static Function PrtItEx(oPDF)
	
	Local aTeste := {{"Válvula de expansão", "Vazamento", "Sem intervenção", "Não finalizado nesta ordem de serviço por falta de material"},;
					{"Resistencial (orvalho)", "Queimado", "Identificado e executado paliativo", "Não finalizado nesta ordem de serviço por falta de material Não finalizado nesta ordem de serviço por falta de material"},;
					{"Controlador", "Danificado", "Identificado e não realizado", "Não finalizado nesta ordem de serviço por falta de material"},;
					{"Prateleiras e bandejas", "Pontos de ferrugem", "Identificado e informado para o responsável", "Não realizado nesta ordem de serviço não liberado"}}
	Local nI	:= 0
	Local nX	:= 0
	Local aTxt	:= {}
	//CABEÇALHO DOS ITENS
	nColAtu := 0
	
	If nLinAtu >= 576
		QuebraPag()
	EndIf

	oPDF:Say(nLinAtu+=VSPACE, nColAtu+002, "Conjunto/Peça",oFont14N:oFont)
	oPDF:Say(nLinAtu		, nColAtu+150, "Identificação",oFont14N:oFont)
	oPDF:Say(nLinAtu		, nColAtu+280, "Execução",oFont14N:oFont)
	oPDF:Say(nLinAtu		, nColAtu+500, "Status da Execução",oFont14N:oFont)
	oPDF:Line(nLinAtu+=003, 0, nLinAtu, 870)
	/*oPDF:Say(nLinAtu+=VSPACE, nColAtu+002, "Válvula de expansão",oFont14:oFont)
	oPDF:Say(nLinAtu		, nColAtu+150, "Vazamento",oFont14:oFont)
	oPDF:Say(nLinAtu		, nColAtu+280, "Sem intervenção",oFont14:oFont)
	oPDF:Say(nLinAtu		, nColAtu+500, "Não finalizado nesta ordem de serviço por falta de material",oFont14:oFont)*/
	/* For nI := 1 To Len(aTeste)
		If nLinAtu >= 576
			QuebraPag()
			oPDF:Line(nLinAtu+=003, 0, nLinAtu, 870)
		EndIf
		aTxt := QuebrTxt(aTeste[nI][4], QBRTXT)
		oPDF:Say(nLinAtu+=VSPACE, nColAtu+002, aTeste[nI][1],oFont14:oFont)
		oPDF:Say(nLinAtu		, nColAtu+150, aTeste[nI][2],oFont14:oFont)
		oPDF:Say(nLinAtu		, nColAtu+280, aTeste[nI][3],oFont14:oFont)
		//oPDF:Say(nLinAtu		, nColAtu+500, aTeste[nI][4],oFont14:oFont)
		For nX := 1 To Len(aTxt)
			oPDF:Say(nLinAtu	, nColAtu+500, aTxt[nX] 			, oFont14:oFont)
			nLinAtu += VSPACE
		Next
	Next
	nLinAtu += 003
	
Return */

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PrtProd ³ Autor ³ Gabriel Verissimo   º Data ³  25/09/19   º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao do produto da OS                      			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PrtProd(oPDF)

	// Local aProd := {{"1", "UN", "100690", "CONTROLADOR ELET EVOLUTION (EVD0000E50)", "Aplicado"}}
	Local aProd 	:= {}
	Local nI		:= 0
	Local cUn		:= ""
	Local cStatus	:= ""
	
	nLinAtu := nLinFim
	nColAtu := 0
	
	If nLinAtu >= 576
		QuebraPag()
	EndIf
	
	oPDF:Line(nLinAtu+=VSPACE, 0, nLinAtu, 870)
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+002, "Quant."		,oFont14N:oFont)
	oPDF:Say(nLinAtu		, nColAtu+100, "Unid."		,oFont14N:oFont)
	oPDF:Say(nLinAtu		, nColAtu+200, "Código"		,oFont14N:oFont)
	oPDF:Say(nLinAtu		, nColAtu+300, "Descrição"	,oFont14N:oFont)
	oPDF:Say(nLinAtu		, nColAtu+750, "Status"		,oFont14N:oFont)

	oPDF:Line(nLinAtu+=003, 0, nLinAtu, 870)

	nLinFim := nLinAtu

Return

Static Function PrtItens(oPDF)
	//ITENS DA OS
	Local nI := 0
	Local nX := 0
	
	nLinAtu := nLinFim
	nColAtu := 0
	
	nLinAtu += VSPACE
	For nI := 1 To Len(aItens)
		For nX := 1 To Len(aItens[nI])
			oPDF:Say(nLinAtu, nColAtu+aItens[nI][nX][2], cValToChar(aItens[nI][nX][1]), oFont10C:oFont)
		Next
		
		nLinAtu += VSPACE

		If nLinAtu >= 576
			QuebraPag()
			nLinAtu+=003
			oPDF:Line(nLinAtu+=VSPACE, 0, nLinAtu, 870)
			nLinAtu += VSPACE
		EndIf
	Next

	// oPDF:Line(nLinAtu+=005, 0, nLinAtu, 605)

	/* nLinFim := nLinAtu

	If lQuebra
		QuebraPag(.F.)
	EndIf */

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o  ³ PrtRodape ³ Autor ³ Gabriel Verissimo   º Data ³  25/09/19   º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao do rodapé da OS                      			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PrtRodape(oPDF)
	//Rodapé
	nLinAtu := 600 //Fixado para sempre imprimir no final da página
	nColAtu := 0

	/* If nLinAtu >= 576
		QuebraPag()
		nLinAtu+=003
		oPDF:Line(nLinAtu+=VSPACE, 0, nLinAtu, 870)
		nLinAtu += VSPACE
	EndIf */

	cSign := GetUrlImg(AllTrim(AB7->AB7_XASSIN), 1)
	If File(cSign) .Or. Resource2File(cLogo, cStartPath + "system\" + cSign)
		// oPDF:SayBitmap(775, nColAtu+260, cSign, 080, 067)
		oPDF:SayBitmap(530, nColAtu+400, cSign, 080, 067)
	EndIf
	oPDF:Say(nLinAtu	, nColAtu+384	, "Assinatura do Cliente", oFont14:oFont)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QuebraPag ³ Autor ³ Gabriel Verissimo  º Data ³  25/09/19  º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Quebrar página do relatório    			                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function QuebraPag(lCabec)

	Default lCabec := .T.

	nQtdImp := 1
	nColAtu := 0
	nLinAtu += VSPACE

	oPDF:EndPage()
	oPDF:StartPage()
	nPagAtu++
	PrtCabec(@oPDF)
	If lCabec
		//PrtCabIt(@oPDF)
	EndIf

	nLinAtu := nLinFim

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GetItens ³ Autor ³ Gabriel Verissimo  º Data ³  25/09/19  º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função para retornar os itens da OS		                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GetItens()

	Local nX := 0

	aItens := {}		
	AB8->(DbSetOrder(1))
	if AB8->(DbSeek(xFilial("AB8") + AB7->AB7_NUMOS + AB7->AB7_ITEM))
		while !AB8->(EoF()) .And. AB8->AB8_FILIAL == AB7->AB7_FILIAL .And. AB8->AB8_NUMOS == AB7->AB7_NUMOS .And. AB8->AB8_ITEM == AB7->AB7_ITEM
			cUn		:= GetAdvFVal("SB1", "B1_UM", xFilial("SB1") + AB8->AB8_CODPRO, 1)
			cStatus := IIf(AB8->AB8_XSTATUS == "1", "Solicitado", "Aplicado")
			AAdd(aItens, {{cValToChar(AB8->AB8_QUANT)	, 002},;
						{cUn							, 100},;
						{AllTrim(AB8->AB8_CODPRO)		, 200},;
						{AllTrim(AB8->AB8_DESPRO)		, 300},;
						{cStatus						, 750}})
			AB8->(DbSkip())
		End
	EndIf

	for nI := 1 to len(aItens)
		if nIniImp > 576
			nQtdPag++
			nIniImp := 220
		endif

		nIniImp += VSPACE
	next nI

	if nIniImp > 576
		nQtdPag++
	endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QuebrTxt ³ Autor ³ Anderson Messias      ³ Data ³12.07.2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Quebra de texto para impressão no relatorio, deve-se passar³±±
±±³          ³ o texto inteiro e o tamanho a ser impresso por linha e a   ³±±
±±³          ³ funcao retorna um arrey com o texto quebrado em linhas     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QuebrTxt(_cMsg, _nTam)

	Local aRet := {}
	Local cStr := ""
	Local cLin := ""
	Local nPos := 0 

	cLin := _cMsg
	While .T.
		cLin := alltrim(Substr(_cMsg,1,_nTam))
		nPos := RAT("|",cLin) //Pipe informa que é quebra de linha.
		if nPos == 0 //se nao acho o pipe, procuro o ultimo caracter de espaco em branco
			if Len(cLin) >= ((_nTam*80)/100) 
				nPos := RAT(" ",cLin)
			else
				nPos := 0
			endif
		endif
		if nPos > 0
			cStr := Substring(cLin,1,nPos-1)
			aadd(aRet,cStr)
		else
			cStr := cLin
			aadd(aRet,cStr)
			Exit
		endif
		_cMsg := Substring(_cMsg,nPos+1,Len(_cMsg)) //Copio do Espaco em branco para frente.
	EndDo

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GetUrlImg ³ Autor ³ Gabriel Verissimo  º Data ³  25/09/19  º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Função para retornar imagem importada do MaxView           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GetUrlImg(cUrl, nOpc)

	Local cHtml 	:= ''
	Local cCaminho 	:= ''
	Local cPath    	:= '\importacao_os\'
	Local cPrefix	:= IIF(nOpc == 1, "_ASSINA", "_ATIVO")

	cHtml := HttpGet(cUrl)

	cCaminho := cPath + AB7->AB7_NUMOS + AB7->AB7_ITEM + cPrefix + ".png"
	If !Empty(cHtml)
		If !ExistDir(cPath)
			MakeDir(cPath)
		EndIf
		MemoWrite( cCaminho, cHtml )
	EndIf

Return cCaminho

//Gabriel
User Function P(cPos)
Return Val(U_GetProperty(cPos,,"testes.properties",.T.))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetProperty ºAutor  ³Vinícius Gregório   º Data ³  27/10/10    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para pegar informações de propriedade com a estrutura  º±±
±±º          ³ chave = valor                                                 º±±
±±º          ³                                                               º±±
±±º          ³ Exp1:= Caracter: nome da propriedade a retornar o valor       º±±
±±º          ³ Exp2:= Caracter: nome do parâmetro que contém o diretório     º±±
±±º          ³ de arquivos de propriedade                                    º±±
±±º          ³ Exp3:= Caracter: nome do arquivo .properties                  º±±
±±º          ³ Exp4:= Lógico: Se exibe ou não mensagem de erro para o        º±±
±±º          ³ usuário                                                       º±±
±±º          ³                                                               º±±
±±º          ³ Retorno: Caracter: valor da propriedade                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Genérico                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function getProperty(cPropr,cParam,cArq,lMensagem)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Declaração de variáveis³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea		:= GetArea()
	Local cRetorno	:= ""
	Local cBarra	:= If(IsSrvUnix(), "/", "\")
	Local cPath		:= ""
	Local cBuffer	:= ""
	Local nHdlArq	:= 0

	DEFAULT cParam 	:= "MV_XPROPER"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Pega a pasta a partir do parâmetro³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//cPath := Alltrim(GetMV(cParam))
	cPath := Alltrim(SuperGetMV(cParam, .F., "\properties\"))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o diretório contido no parâmetro existe³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lIsDir(cPath)

		If lMensagem
			Aviso(	"Inconsistência","O diretório informado no parâmetro "+cParam+" não existe. Informe o seu administrador de sistemas.",{"&Continua"},,"Atenção" )
		Endif

		Return cRetorno
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o Path termina com a Barra³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SubStr(cPath,Len(cPath)-1)!=cBarra
		cPath	:= cPath+cBarra
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Abre o arquivo texto                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nHdlArq := FT_FUSE(cPath+cArq)

	If nHdlArq <> Nil .and. nHdlArq <= 0

		If lMensagem
			Aviso(	"Inconsistência","Não foi possivel a abertura do arquivo "+cArq+" para leitura.",{"&Continua"},,"Atenção" )
		Endif

		FT_FUSE()
		Return cRetorno
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Realiza a leitura do arquivo CSV                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FT_FGOTOP()
	While !FT_FEOF()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Realiza a leitura da linha                                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cBuffer := Alltrim(FT_FREADLN())

		If Empty(cBuffer) .or. At("=",cBuffer) == 0
			FT_FSKIP()
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se é a propriedade procurada³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If At(cPropr,SubStr(cBuffer,1,At("=",cBuffer))) > 0
				cRetorno := Alltrim(Substr(cBuffer,At("=",cBuffer)+1))
			Endif

			FT_FSKIP()
		Endif

	EndDo
	FT_FUSE()

	RestArea(aArea)
Return cRetorno
