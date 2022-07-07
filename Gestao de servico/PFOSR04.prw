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
//#DEFINE MAXITEMP1		026   // Máximo de itens que podem ser impressos na página 1
//#DEFINE MAXITEMP2		049   // Máximo de produtos para a pagina 2 em diante
//#DEFINE MAXITEMP2F		069   // Máximo de produtos para a página 2 em diante quando a página não possui informações complementares
//#DEFINE MAXITEMP3		025   // Máximo de produtos para a pagina 2 em diante (caso utilize a opção de impressao em verso) - Tratamento implementado para atender a legislacao que determina que a segunda pagina de ocupar 50%.
#DEFINE MAXITEMC		038   // Máxima de caracteres por linha de produtos/serviços
#DEFINE MAXMENLIN		080   // Máximo de caracteres por linha de dados adicionais
#DEFINE MAXMSG			013   // Máximo de dados adicionais por página
#DEFINE MAXVALORC		009   // Máximo de caracteres por linha de valores numéricos
#DEFINE MAXWIDTH		820//3168
#DEFINE MAXHEIGHT		2400
#DEFINE COLCAB1			002
#DEFINE COLCAB2			340
#DEFINE COLINF1			110
#DEFINE COLINF2			428
#DEFINE ITEMP1			17//18
#DEFINE MAXITP1			25//26
#DEFINE ITEMP2			46
#DEFINE MAXITP2			55

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
±±ºPrograma  ³ PFOSR04 ºAutor  ³ Gabriel Verissimo   º Data ³  25/09/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de Impressao da Ordem de Serviço Preventiva         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Perfil                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PFOSR04(_cFilial, _cOS, _cCli, _cLoja, _lAbrePDF)

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
	Private _cFilePrintert		:= "PFOSR04"
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
	Private _cMsgRodape			:= "Declaramos para os devidos fins, conforme dispositivo no Caput do Art.63, inciso VII do Decreto 45.490/00 do RICMS/SP e Art.166 do Codigo Tributario Nacional (CNT), nao havermos aproveitado ou temos anulado pelo sistema mecanizado de estorno do credito dos impostos incidentes na nota fiscal acima descrita. Podendo V.Sas, conforme legislacao citada, pleitear a restituicao dos impostos constantes neste documento junto as autoridades competentes.|Para evitar-se qualquer sansao fiscal, solicitamos acusarem o recebimento desta, na copia que a acompanha devendo a via de V.S.(as) ficar arquivada juntamente com a nota fiscal em questao.|Sem outro Motivo para o momento, subscrevemo-nos."

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
	
	Private aEquip				:= {}
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
	oPDF:SetPortrait()
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
			Help(NIL, NIL, "PFOSR04", NIL, "Ordem de Serviço não é do tipo preventiva", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Posicione em uma Ordem de Serviço do tipo preventiva para realizar a impressão deste relatório"})
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
	PRIVATE oFont16    := TFontEx():New(oPDF,"Arial",15,15,.F.,.T.,.F.)// 12
	PRIVATE OFONT16N   := TFontEx():New(oPDF,"Arial",15,15,.T.,.T.,.F.)// 12 
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
		conout("PFOSR04 - não localizou AAX")
	EndIf

	SZI->(DbSetOrder(1)) //ZI_FILIAL+ZI_NUMOS
	if !SZI->(DbSeek(xFilial("SZI") + AB6->AB6_NUMOS))
		conout("PFOSR04 - não localizou SZI")
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
				conout("PFOSR04 - não localizou AB9")
				//Exibe HELP caso não encontre o registro de Atendimento da Ordem de Serviço 
				Help(NIL, NIL, "PFOSR04", NIL, "Atendimento não localizado", 1, 0, NIL, NIL, NIL, NIL, NIL, {"É necessário realizar o atendimento da Ordem de Serviço antes da impressão"})
				//Descarrega o spool de impressão
				Ms_Flush()
				//Elimina da memória a instância do objeto oPDF
				FreeObj(oPDF) 
				Return .F.
			EndIf
			oPDF:StartPage()
			
			GetExec()

			// //Retorna itens do apontamento (AB8)
			GetItens()
			
			//Imprime cabeçalho + dados do cliente
			PrtCabec(@oPDF,.T.)
			
			//Imprime dados da ordem de serviço
			PrtDados(@oPDF)

			//Imprime dados da abertura da ordem de serviço
			PrtAtend(@oPDF)

			//Imprime dados do atendimento da ordem de serviço (AB9)
			PrtEquip(@oPDF)

			//Imprime cabeçalho do apontamento
			PrtCabEx(@oPDF)

			//PrtProd(@oPDF)
			
			// //Imprime dados da abertura da ordem de serviço
			//PrtAbert(@oPDF)

			// //Imprime cabeçalho do apontamento
			PrtCabIt(@oPDF)
			
			// //Imprime itens do apontamento
			PrtItens(@oPDF)
			
			// //Imprime rodapé
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
Static Function PrtCabec(oPDF, lCliente)

	Local aMail := {}
	Local nI	:= 0
	
	DEFAULT lCliente := .F.

	oPDF:Box(0, 0, 860, 605)
	nColAtu := 0
	nLinAtu := 0
	oPDF:Say(nLinAtu+=36	, nColAtu+225, "Ordem de Serviço Preventiva", oFont22N:oFont)
	oPDF:Say(nLinAtu+=50	, nColAtu+475, "OS - Nr. " + AB6->AB6_NUMOS, oFont18N:oFont)

	if lCliente
		nLinAtu := 70
		//DADOS DO CLIENTE
		oPDF:Say(nLinAtu+=30	, nColAtu+002, "DADOS DO CLIENTE", oFont18N:oFont)
		oPDF:Line(nLinAtu+=003, 0, nLinAtu, 605)
	
		//Primeira Coluna
		nLinIni := nLinAtu
		oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB1, "Sigla/Número"							, oFont12:oFont)
		oPDF:Say(nLinAtu		, nColAtu+COLINF1, SA1->A1_COD + " - " + SA1->A1_NOME		, oFont12:oFont)
		oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB1, "Bandeira"								, oFont12:oFont)
		oPDF:Say(nLinAtu		, nColAtu+COLINF1, SA1->A1_LOJA								, oFont12:oFont)
		oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB1, "Loja"									, oFont12:oFont)
		oPDF:Say(nLinAtu		, nColAtu+COLINF1, AllTrim(SA1->A1_BAIRRO)					, oFont12:oFont)
		oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB1, "Endereço"								, oFont12:oFont)
		oPDF:Say(nLinAtu		, nColAtu+COLINF1, AllTrim(SA1->A1_END)						, oFont12:oFont)
		oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB1, "CEP"									, oFont12:oFont)
		oPDF:Say(nLinAtu		, nColAtu+COLINF1, Transform(SA1->A1_CEP, "@R 99.999-999")	, oFont12:oFont)
		oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB1, "Cidade"									, oFont12:oFont)
		oPDF:Say(nLinAtu		, nColAtu+COLINF1, AllTrim(SA1->A1_MUN)						, oFont12:oFont)
		oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB1, "Estado"									, oFont12:oFont)
		oPDF:Say(nLinAtu		, nColAtu+COLINF1, AllTrim(SA1->A1_EST)						, oFont12:oFont)
		nLinFim := nLinAtu
	
		//Segunda Coluna
		nLinAtu := nLinIni
		cMail := StrTran(AllTrim(SA1->A1_XMAILGE), ";", " ")
		aMail := QuebrTxt(cMail, 39)
		oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB2, "CNPJ"											, oFont12:oFont)
		oPDF:Say(nLinAtu		, nColAtu+COLINF2, Transform(SA1->A1_CGC, "@R 99.999.999/9999-99")	, oFont12:oFont)
		oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB2, "I.E."											, oFont12:oFont)
		oPDF:Say(nLinAtu		, nColAtu+COLINF2, Transform(SA1->A1_INSCR, "@R 9999.999.99")		, oFont12:oFont)
		/* oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB2, "Solicitante"									, oFont12:oFont)
		oPDF:Say(nLinAtu		, nColAtu+COLINF2, AB6->AB6_XSOLIC									, oFont12:oFont) */
		oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB2, "E-Mail"											, oFont12:oFont)
		For nI := 1 To Len(aMail)
			oPDF:Say(nLinAtu	, nColAtu+COLINF2, aMail[nI], oFont12:oFont)
			//Não é necessário somar linha caso seja último item (estava causando problema no layout)
			If nI < Len(aMail)
				nLinAtu+=VSPACE
			EndIf
		Next

	else
		nLinIni := nLinAtu
		nLinFim := nLinAtu
		//oPDF:Line(nLinAtu+=003, 0, nLinAtu, 605)
	endif
	//Caso a primeira coluna seja maior que a segunda, atualizar a posição da linha atual
	//If nLinAtu < nLinFim
	//	nLinAtu := nLinFim
	//EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Logotipo da Empresa													   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ												
	nLinAtu := 0
	nColAtu := 0

	If File(cLogo) .or. Resource2File ( cLogo, cStartPath+"system\"+cLogo)
		oPDF:SayBitmap(nLinAtu+005,nColAtu+005,cLogo, 150, 70)
	EndIf
	oPDF:Say(nLinAtu+010, nColAtu+552, "Página " + cValToChar(nPagAtu) + " de " + cValToChar(nQtdPag), oFont08:oFont)

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
	Local aEquipe	:= {}
	Local nI 		:= 0

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

	aAdd(aEquipe, AAX->AAX_XMAILM)
	aAdd(aEquipe, AAX->AAX_XMAILV)
	aAdd(aEquipe, AAX->AAX_XMAILR)

	//oPDF:Say(nLinAtu+=30	, nColAtu+002, "DADOS DA ORDEM DE SERVIÇO", oFont18N:oFont)
	oPDF:Say(nLinAtu+=30	, nColAtu+002, "DADOS DA OS", oFont18N:oFont)
	oPDF:Line(nLinAtu+=003, 0, nLinAtu, 605)
	//oPDF:Say(nLinAtu+=VSPACE, nColAtu+002, "Categoria", oFont12:oFont)
	// oPDF:Say(nLinAtu+=VSPACE, nColAtu+002, IIF(AB6->AB6_XCATEG == "1", "Refrigeração", "Ar Condicionado"), oFont12:oFont)

	nLinIni := nLinAtu
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB1, "Categoria"				, oFont12:oFont)
	oPDF:Say(nLinAtu		, nColAtu+COLINF1, cCateg					, oFont12:oFont)
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB1, "Tipo"					, oFont12:oFont)
	oPDF:Say(nLinAtu		, nColAtu+COLINF1, cTipo					, oFont12:oFont)
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB1, "Data Início"			, oFont12:oFont)
	oPDF:Say(nLinAtu		, nColAtu+COLINF1,  DtoC(AB6->AB6_EMISSAO)	, oFont12:oFont)
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB1, "Hora Início"			, oFont12:oFont)
	oPDF:Say(nLinAtu		, nColAtu+COLINF1, AB6->AB6_HORA			, oFont12:oFont)
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB1, "Data Término"			, oFont12:oFont)
	oPDF:Say(nLinAtu		, nColAtu+COLINF1, DtoC(AB9->AB9_DTFIM)		, oFont12:oFont)
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB1, "Hora Término"			, oFont12:oFont)
	oPDF:Say(nLinAtu		, nColAtu+COLINF1, AB9->AB9_HRFIM			, oFont12:oFont)
	nLinFim := nLinAtu

	nLinAtu := nLinIni
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB2, "Equipe"		, oFont14:oFont)
	For nI := 1 To Len(aEquipe)
		oPDF:Say(nLinAtu	, nColAtu+COLINF2, aEquipe[nI]	, oFont12:oFont)
		nLinAtu+=VSPACE
	Next

	If nLinAtu < nLinFim
		nLinAtu := nLinFim
	EndIf

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

	oPDF:Say(nLinAtu+=30, nColAtu+002, "COLABORADOR", oFont18N:oFont)
	
	oPDF:Line(nLinAtu+=003, 0, nLinAtu, 605)

	// oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB1, AB6->AB6_XIDTEC, oFont14:oFont)
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB1, AllTrim(AB6->AB6_XCOLAB), oFont14:oFont)

	nLinFim := nLinAtu

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PrtAbert ³ Autor ³ Gabriel Verissimo   º Data ³  25/09/19  º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao do Dados de Abertura da OS                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PrtEquip(oPDF)

	Local nLinBkp := 0

	//ABERTURA DA OS
	nLinAtu := nLinFim
	nColAtu := 0

	oPDF:Say(nLinAtu+=30	, nColAtu+002, "DADOS DO EQUIPAMENTO", oFont18N:oFont)
	oPDF:Line(nLinAtu+=003, 0, nLinAtu, 605)
	nLinBkp := nLinAtu

	SB1->(DbSetOrder(1))
	If !SB1->(DbSeek(xFilial("SB1") + AB7->AB7_CODPRO))
		conout("PFOSR04 - não localizou SB1")
	EndIf

	//Primeira coluna
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB1, "Ativo",oFont14:oFont)
	oPDF:Say(nLinAtu		, nColAtu+COLINF1, AB7->AB7_NUMSER,oFont14:oFont)
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB1, "Equipamento",oFont14:oFont)
	oPDF:Say(nLinAtu		, nColAtu+COLINF1, SB1->B1_DESC,oFont14:oFont)

	//Retorna caminho da imagem do ativo do Atendimento da Ordem de Serviço
	//nLinAtu := nLinBkp
	/* oPDF:Box(nLinAtu+010, nColAtu+414, nLinAtu+=151, nColAtu+595)
	cImgAtiv := GetUrlImg(AllTrim(AB9->AB9_XFOTO), 2)
	If File(cImgAtiv) .Or. Resource2File (cLogo, cStartPath+"system\"+cImgAtiv)
		oPDF:SayBitmap(nLinBkp+011, nColAtu+415, cImgAtiv, 179, 139)
	EndIf */

	nLinFim := nLinAtu

Return

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
	oPDF:Say(nLinAtu+=030	, nColAtu+002, "EXECUÇÃO DA OS", oFont18N:oFont)
	oPDF:Line(nLinAtu+=003, 0, nLinAtu, 605)
	For nI := 1 To Len(aDadosEx)
		If nLinAtu >= 786 // 828
			QuebraPag()
			nLinAtu+=003
		EndIf
		oPDF:Line(nLinAtu, 0, nLinAtu, 605) 
		if AllTrim(aDadosEx[nI][1]) <> AllTrim(cGrpImp)
			cGrpImp := aDadosEx[nI][1]
			// Impressão do grupo da preventiva
			oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB1	, "GRUPO: " + aDadosEx[nI][1], oFont14N:oFont)
			oPDF:Line(nLinAtu+=003, 0, nLinAtu, 605)
		endif
		oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB1, "Checklist",oFont14:oFont)
		// oPDF:Say(nLinAtu		, nColAtu+COLINF1, aDadosEx[nI][2], oFont14:oFont) // Checklist
		aChkList := QuebrTxt(aDadosEx[nI][2], QBRTXT)
		For nX := 1 To Len(aChkList)
			oPDF:Say(nLinAtu	, nColAtu+COLINF1, aChkList[nX], oFont14:oFont) // Checklist
			if nX < Len(aChkList)
				nLinAtu+=VSPACE
			endif
		Next nX

		oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB1, "Identificação",oFont14:oFont)
		oPDF:Say(nLinAtu		, nColAtu+COLINF1, aDadosEx[nI][3], oFont14:oFont) // Identificação

		oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB1, "Execução",oFont14:oFont)
		aExec := QuebrTxt(aDadosEx[nI][4], QBRTXT)
		For nX := 1 To Len(aExec)
			oPDF:Say(nLinAtu	, nColAtu+COLINF1, aExec[nX], oFont14:oFont) // Execução
			if nX < Len(aExec)
				nLinAtu+=VSPACE
			endif
		Next nX

		aStExec := QuebrTxt(aDadosEx[nI][5], QBRTXT)
		oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB1, "Status da Execução",oFont14:oFont)
		For nX := 1 To Len(aStExec)
			oPDF:Say(nLinAtu	, nColAtu+COLINF1, aStExec[nX] 		 , oFont14:oFont) // Execução
			if nX < Len(aStExec)
				nLinAtu+=VSPACE
			endif
		Next nX

		aObserv := QuebrTxt(AB9->AB9_XOBS, QBRTXT)
		oPDF:Say(nLinAtu+=VSPACE, nColAtu+COLCAB1, "Observação",oFont14:oFont)
		For nX := 1 To Len(aObserv)
			oPDF:Say(nLinAtu	, nColAtu+COLINF1, aObserv[nX] 		 , oFont14:oFont) // Execução
			if nX < Len(aObserv)
				nLinAtu+=VSPACE
			endif
		Next nX


		nLinMax := nLinAtu
		nLinAtu := nLinIni
		if nLinMax > nLinAtu
			nLinAtu := nLinMax
		endif
		// oPDF:Say(nLinAtu		, nColAtu+620, aDadosEx[nI][4], oFont14:oFont) // Status daExecução
		nLinAtu += 003
	Next nI

	nLinFim := nLinAtu
	conout("nLinAtu")
	conout(nLinAtu)

Return

/*
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
	
	conout("nLinAtu")
	conout(nLinAtu)
	oPDF:Line(nLinAtu+=VSPACE, 0, nLinAtu, 605)
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+002, "Quant."		,oFont14N:oFont)
	oPDF:Say(nLinAtu		, nColAtu+070, "Unid."		,oFont14N:oFont)
	oPDF:Say(nLinAtu		, nColAtu+130, "Código"		,oFont14N:oFont)
	oPDF:Say(nLinAtu		, nColAtu+250, "Descrição"	,oFont14N:oFont)
	oPDF:Say(nLinAtu		, nColAtu+500, "Status"		,oFont14N:oFont)

	oPDF:Line(nLinAtu+=003, 0, nLinAtu, 870)

	nLinFim := nLinAtu

Return
*/

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
		//oPDF:Say(nLinAtu, 700, alltrim(str(nLinAtu)), oFont10C:oFont)
		
		nLinAtu += VSPACE

		If nLinAtu >= 786
			QuebraPag()
			PrtCabIt(@oPDF)
			nLinAtu+=003
			oPDF:Line(nLinAtu+=VSPACE, 0, nLinAtu, 870)
			nLinAtu += VSPACE
		EndIf
	Next

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PrtCabIt ³ Autor ³ Gabriel Verissimo   º Data ³  25/09/19  º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao do cabeçalho dos itens da OS                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PrtCabIt(oPDF)
	//CABEÇALHO DOS ITENS
	nLinAtu := nLinFim
	nColAtu := 0

	//oPDF:Say(nLinAtu+=30	, nColAtu+002, "MATERIAIS", oFont12N:oFont)
	oPDF:Say(nLinAtu+=30	, nColAtu+002, "MATERIAIS", oFont18N:oFont)
	oPDF:Line(nLinAtu+=003, 0, nLinAtu, 605)
	oPDF:Say(nLinAtu+=VSPACE	, nColAtu+002	, "Quant."				, oFont12N:oFont)
	oPDF:Say(nLinAtu			, nColAtu+062	, "Unid."				, oFont12N:oFont)
	oPDF:Say(nLinAtu			, nColAtu+122	, "Código"				, oFont12N:oFont)
	oPDF:Say(nLinAtu			, nColAtu+242	, "Descrição do Produto", oFont12N:oFont)
	oPDF:Say(nLinAtu			, nColAtu+557	, "Status"				, oFont12N:oFont)
	oPDF:Line(nLinAtu+=003, 0, nLinAtu, 605)

	nLinFim := nLinAtu

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PrtRodape ³ Autor ³ Gabriel Verissimo  º Data ³  25/09/19  º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao dos rodapé da OS    			                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PrtRodape(oPDF)

	// If nLinAtu > 760
	If nLinAtu > 700
		QuebraPag()
		nLinAtu+=003
		oPDF:Line(nLinAtu+=VSPACE, 0, nLinAtu, 870)
	EndIf

	//Rodapé
	nLinAtu := 760 //Fixado para sempre imprimir no final da página
	nColAtu := 0
	//oPDF:Line(nLinAtu, 0, nLinAtu, 605)

	//Retorna caminho da imagem da assinatura da Ordem de Serviço 
	cSign := GetUrlImg(AllTrim(AB7->AB7_XASSIN), 1)
	If File(cSign) .Or. Resource2File(cLogo, cStartPath + "system\" + cSign)
		oPDF:SayBitmap(nLinAtu, nColAtu+100, cSign, 080, 067)
	EndIf
	oPDF:Say(nLinAtu+90, nColAtu+100	, "Assinatura do Cliente", oFont11:oFont)

	//Retorna caminho da imagem do ativo 
	nLinAtu := 700 //Fixado para sempre imprimir no final da página
	nColAtu := 0
	oPDF:Box(nLinAtu+010, nColAtu+350, nLinAtu+151, nColAtu+550)
	cImgAtiv := GetUrlImg(AllTrim(AB9->AB9_XFOTO), 2)
	If File(cImgAtiv) .Or. Resource2File (cLogo, cStartPath+"system\"+cImgAtiv)
		oPDF:SayBitmap(nLinAtu+011, nColAtu+351, cImgAtiv, 199, 139)
	EndIf
	// oPDF:Say(nLinAtu+5, nColAtu+350	, "Imagem do Equipamento", oFont11:oFont)

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
	PrtCabec(@oPDF,.F.)
	If lCabec
		// PrtCabIt(@oPDF)
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
						{cUn							, 062},;
						{AllTrim(AB8->AB8_CODPRO)		, 122},;
						{AllTrim(AB8->AB8_DESPRO)		, 242},;
						{cStatus						, 557}})
			AB8->(DbSkip())
		End
	EndIf

	for nI := 1 to len(aItens)
		if nIniImp > 786
			nQtdPag++
			nIniImp := 180
		endif

		nIniImp += VSPACE
	next nI

	if nIniImp > 786
		nQtdPag++
	endif

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
				if SZH->ZH_GRUPREV == "2"
					cGrupo := "MECÂNICO"
				elseif SZH->ZH_GRUPREV == "3"
					cGrupo := "ELÉTRICA"
				elseif SZH->ZH_GRUPREV == "1"
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
	aSort(aDadosEx,,, { |x, y| x[1]+x[2] < y[1]+y[2] })

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
		aExec := QuebrTxt(aDadosEx[nI][3], QBRTXT)
		aStExec := QuebrTxt(aDadosEx[nI][4], QBRTXT)

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
	Local cEol := CHR(10) + CHR(13)
	Local nXi
	
	nLinhas := MLCount(_cMsg, _nTam)
	For nXi:= 1 To nLinhas
		cStr := MemoLine(_cMsg, _nTam, nXi)
		aAdd(aRet, cStr)
	Next nXi

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
