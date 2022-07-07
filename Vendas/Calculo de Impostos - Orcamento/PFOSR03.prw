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
#DEFINE VSPACE			013 //011
#DEFINE HSPACE			010
#DEFINE SAYVSPACE		008
#DEFINE SAYHSPACE		008
#DEFINE HMARGEM			030
#DEFINE VMARGEM			030
#DEFINE MAXITEM			030   // M�ximo de produtos para a primeira p�gina
#DEFINE MAXITP2			049   // M�ximo de produtos para a pagina 2 em diante
#DEFINE MAXITP2F		069   // M�ximo de produtos para a p�gina 2 em diante quando a p�gina n�o possui informa��es complementares
#DEFINE MAXITEMP3		025   // M�ximo de produtos para a pagina 2 em diante (caso utilize a op��o de impressao em verso) - Tratamento implementado para atender a legislacao que determina que a segunda pagina de ocupar 50%.
#DEFINE MAXITEMC		038   // M�xima de caracteres por linha de produtos/servi�os
#DEFINE MAXMENLIN		080   // M�ximo de caracteres por linha de dados adicionais
#DEFINE MAXMSG			013   // M�ximo de dados adicionais por p�gina
#DEFINE MAXVALORC		009   // M�ximo de caracteres por linha de valores num�ricos
#DEFINE MAXWIDTH		820	  //3168
#DEFINE MAXHEIGHT		2400
#DEFINE COLCAB1			002
#DEFINE COLINF1			110
#DEFINE ITEMP1			013   // Quantidade de itens que podem ser impressos na p�gina 1 + rodap�
#DEFINE MAXITP1			019   // M�ximo de itens que podem ser impressos na p�gina 1
#DEFINE ITEMP2			023   // Quantidade de itens que podem ser impressos na p�gina 2 + rodap�
#DEFINE MAXITP2			029   // M�ximo de itens que podem ser impressos na p�gina 2

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

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � PFOSR03 �Autor  � Gabriel Verissimo   � Data �  25/09/19   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina de Impressao do Or�amento					          ���
�������������������������������������������������������������������������͹��
���Uso       � Perfil                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function PFOSR03(_cFilial,_cOrc,_cCli,_cLoja,_lAbrePDF)

	Local cPath 				:= AllTrim(GetTempPath())

	Private nLinIni				:= 1
	Private nColIni				:= 2
	Private nLinAtu 			:= 0
	Private nColAtu 			:= 0 

	//Parametros para o FWMSPrinter
	Private _cFilePrintert		:= "PFOSR03"
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

	Private _cPFFilial			:= xFilial("AB3")//_cFilial
	Private _cPFOrc				:= AB3->AB3_NUMORC//_cOrc
	Private _cPFCli				:= AB3->AB3_CODCLI//_cCli
	Private _cPFLoja			:= AB3->AB3_LOJA//_cLoja
	Private _lPFAbrePDF			:= .F.

	Private nQtdPag				:= 1 //0
	Private nPagAtu				:= 1
	Private aItens				:= {}
	Private lQuebra				:= .F.
	Private nQtdImp				:= 1

	Default _lAbrePDF			:= .T.

	_lPFAbrePDF := _lAbrePDF

	if _lPFAbrePDF == .F.
		_lViewPDF := .F.
	endif

	_cTime := Time()
	_cTime := alltrim(StrTran(_cTime,":",""))
	_cFilePrintert := _cFilePrintert+"_"+Alltrim(_cPFFilial)+"_"+Alltrim(_cPFOrc)+"_"+DTOS(Date())+"_"+_cTime

	oPDF:= FWMsPrinter():New(_cFilePrintert,_nDevice,_lAdjustToLegacy,_cPathInServer,_lDisabeSetup,_lTReport,@_oPrintSetup,_cPrinter,_lServer,_lPDFAsPNG,_lRaw,_lViewPDF,_nQtdCopy )
	oPDF:SetResolution(78) //Tamanho estipulado para a Danfe
	oPDF:SetLandscape()
	oPDF:SetPaperSize(DMPAPER_A4)
	oPDF:SetMargin(60,60,60,60)
	oPDF:cPathPDF 	:= AllTrim(GetTempPath())

	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1") + _cPFCli + _cPFLoja))

	AB3->(DbSetOrder(1))
	_cChave := _cPFFilial + _cPFOrc //+ _cPFCli + _cPFLoja
	If AB3->(DbSeek(_cChave))
		If _lAbrePDF
			RptStatus({|lEnd| ImpDet(@oPDF)}, "Imprimindo Or�amento, aguarde...")
		Else
			ImpDet(@oPDF)
		EndIf
	EndIf

Return _cPathInServer + _cFilePrintert

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   � ImpDet   � Autor �Gabriel Verissimo   � Data �  25/09/19   ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Controle de Fluxo do Relatorio.                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto grafico de impressao                    (OPC) ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
	PRIVATE oFont16    := TFontEx():New(oPDF,"Arial",15,15,.F.,.T.,.F.)// 12
	PRIVATE OFONT16N   := TFontEx():New(oPDF,"Arial",15,15,.T.,.T.,.F.)// 12 
	PRIVATE oFont18    := TFontEx():New(oPDF,"Arial",17,17,.T.,.T.,.F.)// 18 
	PRIVATE oFont18N   := TFontEx():New(oPDF,"Arial",17,17,.T.,.T.,.F.)// 18 
	PRIVATE oFont22    := TFontEx():New(oPDF,"Arial",21,21,.T.,.T.,.F.)// 18 
	PRIVATE oFont22N   := TFontEx():New(oPDF,"Arial",21,21,.T.,.T.,.F.)// 18 

	PrtNFD(@oPDF)

Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PrtNFD   � Autor �Gabriel Verissimo   � Data �  25/09/19   ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Impressao do formulario NFD grafico conforme laytout no     ���
���          �formato retrato                                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PrtNFD()                                                   ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto grafico de impressao                          ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function PrtNFD(oPDF)

	Local nX			:= 0   

	Private cLogo		:= "perfil_logo.png"
	Private cStartPath	:= GetSrvProfString("Startpath","")
	Private lPreview	:= .T.
	Private aTotal		:= {0, 0, 0}

	//������������������������������������������������������������������������Ŀ
	//�Inicializacao do objeto grafico                                         �
	//��������������������������������������������������������������������������
	If oPDF == Nil
		lPreview := .T.
		oPDF 	:= FWMsPrinter():New(_cFilePrintert,_nDevice,_lAdjustToLegacy,_cPathInServer,_lDisabeSetup,_lTReport,@_oPrintSetup,_cPrinter,_lServer,_lPDFAsPNG,_lRaw,_lViewPDF,_nQtdCopy )
		oPDF:SetPortrait()
		oPDF:Setup()
	EndIf

	nLinIni := 0
	nColIni := 0
	nLinFim := 0

	//������������������������������������������������������������������������Ŀ
	//�Inicializacao da pagina do objeto grafico                               �
	//��������������������������������������������������������������������������

	_cItem := ""
	If AB4->(DbSeek(xFilial("AB4") + AB3->AB3_NUMORC))
		While !AB4->(EoF()) .And. AB4->AB4_FILIAL + AB4->AB4_NUMORC == _cChave
			If _cItem <> AB4->AB4_ITEM
				_cItem := AB4->AB4_ITEM
			EndIf
			oPDF:StartPage()
			//Retorna itens do apontamento (AB8)
			GetItens()
			
			//Imprime cabe�alho + dados do cliente
			PrtCabec(@oPDF)
			
			//Imprime dados da ordem de servi�o
			PrtCli(@oPDF)
			
			//Imprime dados da abertura da ordem de servi�o
			PrtMsg(@oPDF)			
			
			//Imprime cabe�alho do apontamento
			PrtCabIt(@oPDF)
			
			//Imprime itens do apontamento
			PrtItens(@oPDF)
			
			//Imprime rodap�
			PrtRodape(@oPDF)
			
			oPDF:EndPage()
			AB4->(DbSkip())
		End
	EndIf
	
	oPDF:Preview()
	Ms_Flush()
	FreeObj(oPDF)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PrtCabec � Autor � Gabriel Verissimo   � Data �  25/09/19  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao do Cabecalho do Relat�rio                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function PrtCabec(oPDF)

	oPDF:Box(0, 0, 608, 870)
	nColAtu := 0
	nLinAtu := 0
	
	//������������������������������������������������������������������������Ŀ
	//�Logotipo da Empresa													   �
	//��������������������������������������������������������������������������												
	If File(cLogo) .Or. Resource2File(cLogo, cStartPath + "system\" + cLogo)
		oPDF:SayBitmap(nLinAtu+005,nColAtu+005,cLogo, 080, 080)
	EndIf
	oPDF:Say(nLinAtu+010, nColAtu+810, "P�gina " + cValToChar(nPagAtu) + " de " + cValToChar(nQtdPag), oFont08:oFont)
	
	oPDF:Say(nLinAtu+=36		, nColAtu+400, "Or�amento", oFont22N:oFont)
	oPDF:Say(nLinAtu+=VSPACE	, nColAtu+620, "Nr. " + AB3->AB3_NUMORC, oFont16:oFont)
	oPDF:Say(nLinAtu+=VSPACE	, nColAtu+620, "S�o Paulo, " + cValToChar(Day(dDatabase)) + " de " + MesExtenso(Month(dDatabase)) + " de " + cValToChar(Year(dDatabase)), oFont16:oFont)
	oPDF:Say(nLinAtu+=VSPACE	, nColAtu+620, "Status do Pedido: Aberto", oFont16:oFont)
	oPDF:Say(nLinAtu+=VSPACE	, nColAtu+620, "Validade do Or�amento: 15 dias �teis", oFont16:oFont)
	nLinAtu := 110

	//DADOS DA EMPRESA
	SM0->(DbSetOrder(1))
	If !SM0->(DbSeek(cEmpAnt + cFilAnt))
		conout("N�o posicionou na SM0")
	EndIf
	
	//Primeira coluna
	nLinIni := nLinAtu
	oPDF:Say(nLinAtu+=VSPACE	, nColAtu+002, AllTrim(SM0->M0_NOMECOM), oFont16:oFont)
	oPDF:Say(nLinAtu+=VSPACE	, nColAtu+002, "Endere�o", oFont16:oFont)
	oPDF:Say(nLinAtu			, nColAtu+100, AllTrim(SM0->M0_ENDCOB) + " - " + AllTrim(SM0->M0_CIDCOB) + " - " + AllTrim(SM0->M0_ESTCOB), oFont16:oFont)
	oPDF:Say(nLinAtu+=VSPACE	, nColAtu+002, "CEP", oFont16:oFont)
	oPDF:Say(nLinAtu			, nColAtu+100, AllTrim(SM0->M0_CEPCOB), oFont16:oFont)
	oPDF:Say(nLinAtu+=VSPACE	, nColAtu+002, "CNPJ", oFont16:oFont)
	oPDF:Say(nLinAtu			, nColAtu+100, Transform(SM0->M0_CGC, "@R 99.999.999/9999-99"), oFont16:oFont)
	oPDF:Say(nLinAtu+=VSPACE	, nColAtu+002, "I.E.", oFont16:oFont)
	oPDF:Say(nLinAtu			, nColAtu+100, Transform(SM0->M0_INSC, "@R 9999.999.99"), oFont16:oFont)
	nLinFim := nLinAtu
	
	//Segunda coluna
	nLinAtu := nLinIni + VSPACE
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+500, "Contato"								, oFont16:oFont)
	oPDF:Say(nLinAtu		, nColAtu+620, AllTrim(AB3->AB3_ATEND)					, oFont16:oFont)
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+500, "Telefone"								, oFont16:oFont)
	oPDF:Say(nLinAtu		, nColAtu+620, AllTrim(SM0->M0_TEL) 					, oFont16:oFont)
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+500, "E-mail"									, oFont16:oFont)
	oPDF:Say(nLinAtu		, nColAtu+620, "rafael-santos@industriaperfil.ind.br"	, oFont16:oFont)
	
	If nLinAtu < nLinFim
		nLinAtu := nLinFim
	EndIf
	
	oPDF:Line(nLinAtu+=VSPACE, 0, nLinAtu, 870)
	
	nLinFim := nLinAtu

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PrtCli   � Autor � Gabriel Verissimo   � Data �  25/09/19  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao do Dados do Cliente	                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function PrtCli(oPDF)

	Local aEndere 	:= {}
	Local cEndere 	:= ""
	Local nX		:= 0
	Local nLinEnd	:= 0
	Local cConPag	:= ""
	Local cTpFrete	:= ""
	Local cTransp	:= ""
	Local aTransp	:= {}
	Local nI		:= 0

	//DADOS DO CLIENTE
	nLinAtu := nLinFim
	nColAtu := 0
		
	cEndere := AllTrim(SA1->A1_END) + " - " + AllTrim(SA1->A1_BAIRRO) + " - " + AllTrim(SA1->A1_MUN) + " - " + AllTrim(SA1->A1_EST)
	aEndere := QuebrTxt(cEndere, 50)
	cConPag := AB3->AB3_CONPAG + " - " + AllTrim(Posicione("SE4", 1, xFilial("SE4") + AB3->AB3_CONPAG, "E4_DESCRI"))
	
	If AB3->AB3_XTPFRE == "C"
		cTpFrete := "CIF"
	ElseIf AB3->AB3_XTPFRE == "F"
		cTpFrete := "FOB"
	ElseIf AB3->AB3_XTPFRE == "T"
		cTpFrete := "Por Conta Terceiros"
	ElseIf AB3->AB3_XTPFRE == "R"
		cTpFrete := "Por Conta Remetente"
	ElseIf AB3->AB3_XTPFRE == "D"
		cTpFrete := "Por Conta Destinat�rio"
	ElseIf AB3->AB3_XTPFRE == "S"
		cTpFrete := "Sem Frete"
	EndIf
	
	cTransp := AB3->AB3_XTRANS + " - " + AllTrim(Posicione("SA4", 1, xFilial("SA4") + AB3->AB3_XTRANS, "A4_NOME"))
	aTransp	:= QuebrTxt(cTransp, 30)
	
	//Primeira coluna
	nLinIni := nLinAtu
	oPDF:Say(nLinAtu+=20	, nColAtu+002, "Cliente"			, oFont16:oFont)
	oPDF:Say(nLinAtu		, nColAtu+100, AllTrim(SA1->A1_NOME), oFont16:oFont)
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+002, "Endere�o"			, oFont16:oFont)
	For nX := 1 To Len(aEndere)
		oPDF:Say(nLinAtu	, nColAtu+100, aEndere[nX] 			, oFont16:oFont)
		nLinAtu += VSPACE
	Next
	oPDF:Say(nLinAtu		, nColAtu+002, "CNPJ/CPF"										, oFont16:oFont)
	oPDF:Say(nLinAtu		, nColAtu+100, Transform(SA1->A1_CGC, "@R 99.999.999/9999-99")	, oFont16:oFont)
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+002, "I.E."											, oFont16:oFont)
	oPDF:Say(nLinAtu		, nColAtu+100, Transform(SA1->A1_INSCR, "@R 99.999.999/9999-99"), oFont16:oFont)
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+002, "Cond. Pgto."									, oFont16:oFont)
	oPDF:Say(nLinAtu		, nColAtu+100, cConPag											, oFont16:oFont)	
	nLinFim := nLinAtu
	
	//Segunda coluna
	nLinAtu := nLinIni
	oPDF:Say(nLinAtu+=20	, nColAtu+500, "Telefone"										, oFont16:oFont)
	oPDF:Say(nLinAtu		, nColAtu+620, AllTrim(SA1->A1_DDD) + " " + AllTrim(SA1->A1_TEL), oFont16:oFont)
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+500, "E-Mail"											, oFont16:oFont)
	oPDF:Say(nLinAtu		, nColAtu+620, Lower(AllTrim(SA1->A1_EMAIL))					, oFont16:oFont)
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+500, "Tipo do Frete"									, oFont16:oFont)
	oPDF:Say(nLinAtu		, nColAtu+620, AB3->AB3_XTPFRE + " - " + cTpFrete				, oFont16:oFont)
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+500, "Transportadora"									, oFont16:oFont)
	For nI := 1 To Len(aTransp)
		oPDF:Say(nLinAtu	, nColAtu+620, aTransp[nI]										, oFont16:oFont)
		nLinAtu+=VSPACE
	Next
	
	If nLinAtu < nLinFim
		nLinAtu := nLinFim
	EndIf
	
	oPDF:Line(nLinAtu+=VSPACE, 0, nLinAtu, 870)
	
	nLinFim := nLinAtu

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PrtMsg   � Autor � Gabriel Verissimo   � Data �  25/09/19  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao da mensagem do or�amento                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function PrtMsg(oPDF)

	//ABERTURA DA OS
	nLinAtu := nLinFim
	nColAtu := 0

	oPDF:Say(nLinAtu+=20	, nColAtu+002, "Prezado(a) Cliente,", oFont16:oFont)
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+002, "Conforme solicita��o, apresentamos or�amento para o fornecimento dos itens abaixo discriminados, visando o atendimento de vossa solicita��o", oFont16:oFont)
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+002, "de acordo com as refer�ncias dos produtos, descri��es, fabricantes/similiriadades (onde autorizados) e quantidade informadas.", oFont16:oFont)
	
	nLinFim := nLinAtu

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PrtCabIt � Autor � Gabriel Verissimo   � Data �  25/09/19  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao do cabe�alho dos itens                           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function PrtCabIt(oPDF)

	//CABE�ALHO DOS ITENS
	nLinAtu := nLinFim
	nColAtu := 0

	oPDF:Say(nLinAtu+=30, nColAtu+002, "Seq."			, oFont12N:oFont)
	oPDF:Say(nLinAtu	, nColAtu+046, "C�digo"			, oFont12N:oFont)
	oPDF:Say(nLinAtu	, nColAtu+118, "Refer�ncia"		, oFont12N:oFont)
	oPDF:Say(nLinAtu	, nColAtu+220, "Descri��o"		, oFont12N:oFont)
	oPDF:Say(nLinAtu	, nColAtu+344, "NCM"			, oFont12N:oFont)
	oPDF:Say(nLinAtu	, nColAtu+395, "UM"				, oFont12N:oFont)
	oPDF:Say(nLinAtu	, nColAtu+425, "Qtde"			, oFont12N:oFont)
	oPDF:Say(nLinAtu	, nColAtu+465, "ICMS"			, oFont12N:oFont)
	oPDF:Say(nLinAtu	, nColAtu+505, "PIS"			, oFont12N:oFont)
	oPDF:Say(nLinAtu	, nColAtu+545, "COFINS"			, oFont12N:oFont)
	oPDF:Say(nLinAtu	, nColAtu+615, "ST"				, oFont12N:oFont)
	oPDF:Say(nLinAtu	, nColAtu+655, "IPI"			, oFont12N:oFont)
	oPDF:Say(nLinAtu	, nColAtu+705, "ISS"    		, oFont12N:oFont)
	oPDF:Say(nLinAtu	, nColAtu+750, "Vlr Unit."		, oFont12N:oFont)
	oPDF:Say(nLinAtu	, nColAtu+820, "Total "		 	, oFont12N:oFont)

	nLinFim := nLinAtu

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PrtItens � Autor � Gabriel Verissimo   � Data �  25/09/19  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao dos itens do or�amento                           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function PrtItens(oPDF)
	
	Local nI := 0
	Local nX := 0
	
	//ITENS DA OS
	nLinAtu := nLinFim
	nColAtu := 0

	nLinAtu += VSPACE
	nQtdImp := 1
	For nI := 1 To Len(aItens)
		If nPagAtu == 1
			//Se for �ltimo item e consegue imprimir mais itens na p�gina, ir� imprimir totalizadores na pr�xima p�gina
			If nI + 1 > Len(aItens) .And. (nQtdImp <= MAXITP1 .And. nQtdImp > ITEMP1)
				lQuebra := .T.
			//Se a quantidade impressa ultrapassou o limite de itens da p�gina, faz a quebra para continuar impress�o
			ElseIf nQtdImp > MAXITP1
				QuebraPag()
				nLinAtu := nLinFim + VSPACE
			EndIf
		Else
			If nI + 1 > Len(aItens) .And. (nQtdImp <= MAXITP2 .And. nQtdImp > ITEMP2)
				lQuebra := .T.
			ElseIf nQtdImp > MAXITP2
				QuebraPag()
				nLinAtu := nLinFim + VSPACE
			EndIf
		EndIf

		For nX := 1 To Len(aItens[nI])
			oPDF:Say(nLinAtu, nColAtu+aItens[nI][nX][2], cValToChar(aItens[nI][nX][1]), oFont10C:oFont)
		Next
		nLinAtu += VSPACE
		nQtdImp++
	Next

	nLinFim := nLinAtu

	If lQuebra
		QuebraPag(.F.)
	EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PrtRodape � Autor � Gabriel Verissimo  � Data �  25/09/19  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao dos rodap� do or�amento                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function PrtRodape(oPDF)

	//Rodap�
	nLinAtu := nLinFim
	nColAtu := 0

	oPDF:Say(nLinAtu+=20	, nColAtu+630	, "Total Itens"																, oFont16:oFont)
	oPDF:Say(nLinAtu		, nColAtu+770	, "R$ " + Transform(aTotal[1], "@E 999,999.99") 							, oFont16:oFont)
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+630	, "Frete"																	, oFont16:oFont)
	oPDF:Say(nLinAtu		, nColAtu+770	, "R$ " + Transform(AB3->AB3_XVLFRE, "@E 999,999.99") 						, oFont16:oFont)
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+630	, "Impostos s/ frete"														, oFont16:oFont)
	oPDF:Say(nLinAtu		, nColAtu+770	, "R$ " + Transform(aTotal[2], "@E 999,999.99") 							, oFont16:oFont)
	oPDF:Say(nLinAtu+=VSPACE, nColAtu+630	, "Total"																	, oFont16:oFont)
	oPDF:Say(nLinAtu		, nColAtu+770	, "R$ " + Transform(aTotal[1]+aTotal[2]+AB3->AB3_XVLFRE, "@E 999,999.99")	, oFont16:oFont)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QuebraPag � Autor � Gabriel Verissimo  � Data �  25/09/19  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Quebrar p�gina do relat�rio    			                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
		PrtCabIt(@oPDF)
	EndIf

	nLinAtu := nLinFim

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GetItens � Autor � Gabriel Verissimo  � Data �  25/09/19  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Fun��o para retornar os itens da OS		                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function GetItens()

	aItens := {}		
	AB5->(DbSetOrder(1))
	SB1->(DbSetOrder(1))
	If AB5->(DbSeek(xFilial("AB5") + AB4->AB4_NUMORC + _cItem, .F.))
		cSeq := "01"
		While !AB5->(EoF()) .And. AB5->AB5_FILIAL + AB5->AB5_NUMORC + AB5->AB5_ITEM == AB4->AB4_FILIAL + AB4->AB4_NUMORC + _cItem
			If !SB1->(DbSeek(xFilial("SB1") + AB5->AB5_CODPRO))
				conout("PFOSR03 - n�o posicionou na SB1")
			EndIf
				AAdd( aItens, {{ cSeq														, 006 },; //Sequ�ncia
							  { AllTrim(AB5->AB5_CODPRO)									, 040 },; //C�digo
							  { AllTrim(SB1->B1_FABRIC)										, 115 },; //Refer�ncia
							  { AllTrim(AB5->AB5_DESPRO)									, 195 },; //Descri��o
							  { AllTrim(SB1->B1_EX_NCM)										, 337 },; //NCM
							  { SB1->B1_UM													, 398 },; //Unidade de Medida
							  { cValToChar(AB5->AB5_QUANT)									, 426 },; //Quantidade
							  { Transform(AB5->AB5_XVALIC, "999,999.99")					, 440 },; //ICMS
							  { Transform(AB5->AB5_XVALPI, "999,999.99")					, 478 },; //PIS
							  { Transform(AB5->AB5_XVALCO, "999,999.99")					, 533 },; //COFINS
							  { Transform(AB5->AB5_XVALIS, "999,999.99")					, 583 },; //ST
							  { Transform(AB5->AB5_XVALIP, "999,999.99")					, 625 },; //IPI			
							  { Transform(AB5->AB5_XVLISS, "999,999.99")					, 675 },; //ISS							 
							  { Transform(AB5->AB5_VUNIT, "999,999.99")						, 740 },; //Valor Unit�rio
							  { Transform(AB5->AB5_QUANT * AB5->AB5_XVALLI , "999,999.99")	, 807 }}) //Total */
					/*
					AAdd(aItens, {{cSeq													, 006},; //Sequ�ncia
							  {AllTrim(AB5->AB5_CODPRO)									, 040},; //C�digo
							  {AllTrim(SB1->B1_FABRIC)									, 115},; //Refer�ncia
							  {AllTrim(AB5->AB5_DESPRO)									, 195},; //Descri��o
							  {AllTrim(SB1->B1_EX_NCM)									, 337},; //NCM
							  {SB1->B1_UM												, 398},; //Unidade de Medida
							  {cValToChar(AB5->AB5_QUANT)								, 426},; //Quantidade
							  {Transform(AB5->AB5_VUNIT, "@E 999,999.99")					, 639},; //Valor Unit�rio
							  {Transform(AB5->AB5_QUANT * AB5->AB5_VUNIT, "@E 999,999.99")	, 797}}) //Total  */
				cSeq := Soma1(cSeq)
				aTotal[1] += AB5->AB5_QUANT * AB5->AB5_XVALLI //Total dos itens
				aTotal[2] += AB5->AB5_XVALIP + AB5->AB5_XVALIC + AB5->AB5_XVALPI + AB5->AB5_XVALCO + AB5->AB5_XVALIS + AB5->AB5_XVLISS //Impostos
			AB5->(DbSkip())
		End
	EndIf

	If Len(aItens) > ITEMP1
		nQtdPag++
		If Len(aItens) > MAXITP1
			If (Len(aItens) - MAXITP1) >= MAXITP1 
				nQtdPag += Ceiling((Len(aItens) - MAXITP2) / MAXITP2)
			EndIf
		Else
			nQtdPag := Ceiling(Len(aItens) / ITEMP1)
		EndIf 
	Else
		nQtdPag := 1
	EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QuebrTxt � Autor � Anderson Messias      � Data �12.07.2016���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Quebra de texto para impress�o no relatorio, deve-se passar���
���          � o texto inteiro e o tamanho a ser impresso por linha e a   ���
���          � funcao retorna um arrey com o texto quebrado em linhas     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function QuebrTxt(_cMsg, _nTam)

	Local aRet := {}
	Local cStr := ""
	Local cLin := ""
	Local nPos := 0 

	cLin := _cMsg
	While .T.
		cLin := alltrim(Substr(_cMsg,1,_nTam))
		nPos := RAT("|",cLin) //Pipe informa que � quebra de linha.
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