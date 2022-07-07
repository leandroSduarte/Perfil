#INCLUDE "MATR820.CH"
#INCLUDE "FIVEWIN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE 'TOPCONN.CH'
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#include 'topconn.ch'
#include "tbiconn.ch"
#include "TOTVS.CH"

#define DMPAPER_A4 9 // A4 210 x 297 mm

Static cAliasTop

/*/
+---------------------------------------------------------------------------+
| Programa  | UPRELOP01  | Autor | Marcio Gois            | Data | 12/12/18 |
|-----------+---------------------------------------------------------------|
| Descrição | Impressão da Ordem de Produção com Roteiro de Operações       |
|-----------+---------------------------------------------------------------|
| Uso       | Perfil Refrigeração                                           |
+---------------------------------------------------------------------------+*/

User Function UPRELOP01()
Local lAdjustToLegacy 	:= .T.
Local lDisableSetup 	:= .T.
Local cLocal        	:= GetTempPath()

Private lViewPDF        := .T.
Private _oPrint, _oFont, _oFontN, oFontNCab, oFontCab
Private _nLinha 		:= 0
Private nLinBar			:= 0   
Private aArray	 		:= {}
Private _nColun			:= 50
Private _nCol2			:= 700
Private _nPulo			:= 40
Private nPagAtu			:= 1
Private cTitle			:= ""
Private _cObserv         := ""
Private cPerg 			:= Padr("UPRELOP01",10)
Private l_ImpEtq		:= .F.
Private l_ImpDes		:= .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as Perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_oFont  	:= TFont():New("Courier New",12,12,,.F.,,,,.T.,.F.)
_oFontN 	:= TFont():New("Courier New",12,12,,.T.,,,,.T.,.F.)//Negrito
oFontNCab	:= TFont():New("Arial",13,13,,.T.,,,,.T.,.F.) //Negrito
oFontCab	:= TFont():New("Arial",13,13,,.F.,,,,.T.,.F.) //Normal
oFontN14	:= TFont():New("Arial",14,14,,.T.,,,,.T.,.F.) //Negrito
_oFontAr  	:= TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)
_oFontArN 	:= TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)//Negrito

ValPerg()

If !Pergunte(cPerg,.T.)
	Return
Endif

_oPrint := FWMSPrinter():New(Alltrim(MV_PAR01)+".rel", IMP_PDF, lAdjustToLegacy,cLocal, lDisableSetup, , , , , , .F., lViewPDF )

_oPrint:cPathPDF := cLocal

_oPrint:SetPortrait()
//_oPrint:SetLandScape()
_oPrint:SetPaperSize(DMPAPER_A4)  
_oPrint:SetMargin(10,0,10,0)

Processa( {|lEnd| UPRELIMP(@lEnd)}, "Imprimindo...", "Aguarde...", .T.)

If MsgYesNo("Deseja imprimir relatório de separação?")
	U_RELPSEP( 2, MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04 )
EndIf


If MsgYesNo("Deseja imprimir etiquetas de P.A. ?")
	l_ImpEtq := .T.
EndIf



Return

/*/
+---------------------------------------------------------------------------+
| Programa  | UPRELIMP   | Autor | Marcio Gois            | Data | 12/12/18 |
|-----------+---------------------------------------------------------------|
| Descrição | Impressão da Ordem de Produção com Roteiro de Operações       |
|-----------+---------------------------------------------------------------|
| Uso       | Perfil Refrigeração                                           |
+---------------------------------------------------------------------------+*/
Static Function UPRELIMP(lCancel)

Local cPorta  := "LPT1"
Local _cNumPV := ""
Local c_ItemPv := ""

Pergunte(cPerg,.F.)

ProcRegua(0)

cAliasTop := GetNextAlias()

cQuery := "	SELECT SC2.C2_FILIAL, SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN, SC2.C2_ITEMGRD, SC2.C2_DATPRF, "
cQuery += "	SC2.C2_DATRF, SC2.C2_PRODUTO, SC2.C2_DESTINA, SC2.C2_PEDIDO, SC2.C2_ROTEIRO, SC2.C2_QUJE, "
cQuery += "	SC2.C2_PERDA, SC2.C2_QUANT, SC2.C2_DATPRI,SC2.C2_SEQPAI,C2_TPOP,SC2.C2_EMISSAO, "
cQuery += "	SC2.C2_OBS, C2_PEDIDO, C2_ITEMPV,"
cQuery += "	SC2.R_E_C_N_O_  SC2RECNO, SC2.C2_XPEDMAN,SC2.C2_XITEPEM "
	
cQuery += "	FROM "+RetSqlName("SC2")+" SC2, "+RetSqlName("SB1")+" SB1 "
	
cQuery += "	WHERE SB1.B1_COD = SC2.C2_PRODUTO AND "
cQuery += "	SB1.D_E_L_E_T_ = '' AND "
cQuery += "	SC2.C2_TPOP = 'F' AND "
cQuery += "	SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND "
cQuery += "	SC2.C2_FILIAL = '"+xFilial("SC2")+"' AND " 
//cQuery += "	SC2.C2_NUM >= '"+Left(mv_par01,6)+"' AND SC2.C2_NUM <= '"+Left(mv_par02,6)+"' AND "
//cQuery += "	SC2.C2_ITEM >= '"+Substr(mv_par01,7,2)+"' AND SC2.C2_ITEM <= '"+Substr(mv_par02,7,2)+"' AND "
//cQuery += "	SC2.C2_SEQUEN >= '"+Substr(mv_par01,9,3)+"' AND SC2.C2_SEQUEN <= '"+Substr(mv_par02,9,3)+"' AND "
// Alterado a sequência comentada acima para a linha abaixo afim de evitar problemas de filtro conforme parametros do usuário - Edson Rodrigues - 01/03/19
cQuery += " SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN BETWEEN '"+ALLTRIM(mv_par01)+"' AND'"+ALLTRIM(mv_par02)+"' AND  "
cQuery += "	SC2.C2_ITEMGRD >= '"+SubStr(mv_par01,12,2)+"' AND SC2.C2_ITEMGRD <= '"+SubStr(mv_par02,12,2)+"' AND "
cQuery += "	SC2.C2_DATPRF BETWEEN '"+ DTOS(mv_par03)+ "' AND '"+ DTOS(mv_par04)+"' AND "
cQuery += "	SC2.D_E_L_E_T_ = '' "
cQuery += "	ORDER BY SC2.C2_FILIAL, SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN, SC2.C2_ITEMGRD"

//memowrite("C:\Users\junio\Desktop\Delta Decisão\Perfil\queryperfilop.txt",cQuery )
	
IF SELECT(cAliasTop) > 0
	DbSelectArea(cAliasTop)
	DbCloseArea()
Endif

TCQUERY cQuery NEW ALIAS &cAliasTop
TcSetField(cAliasTop,"C2_DATRF"   ,"D",8,0)
TcSetField(cAliasTop,"C2_DATPRI"  ,"D",8,0)
TcSetField(cAliasTop,"C2_DATPRF"  ,"D",8,0)
TcSetField(cAliasTop,"C2_EMISSAO" ,"D",8,0)

dbSelectArea(cAliasTop)
While !(cAliasTop)->(Eof())

	//-- Valida se a OP deve ser Impressa ou nao
	If !MtrAvalOP(1,"SC2",cAliasTop)
		dbSkip()
		Loop
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Definindo o titulo do Relatorio³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTitle := (STR0010+" "+(cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)) //" O R D E M   D E   P R O D U C A O       NRO :"	
	
	//Imprime o cabecalho
	_oPrint:StartPage()
	_nLinha := UPRELCAB(nPagAtu,cTitle)
	
//	For nCntFor := 1 to 4
//		_nLinha += _nPulo
//	Next nCntFor
	
//	nLinBar := _nLinha / 70
//	cCode := Trim((cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD))
	
//	_oPrint:FWMSBAR("CODE128" /*cTypeBar*/,nLinBar/*nRow*/ ,0.7/*nCol*/ ,cCode  /*cCode*/,_oPrint/*oPrint*/,/*lCheck*/,/*Color*/,/*lHorz*/, /*nWidth*/,1.0/*nHeigth*/,/*lBanner*/,/*cFont*/,/*cMode*/,.F./*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/,/*lCmtr2Pix*/)

	aOPPAI := RETOPPAI((cAliasTop)->(C2_NUM+C2_ITEM+"001"+C2_ITEMGRD))  
	
	If !Empty(aOPPAI[3])
		_cNumPV  := aOPPAI[3]
		c_ItemPv := aOPPAI[4]	
	Else
		If !(Empty((cAliasTop)->C2_PEDIDO))
			_cNumPV  := (cAliasTop)->C2_PEDIDO
			c_ItemPv := (cAliasTop)->C2_ITEMPV
		Else
			_cNumPV  := (cAliasTop)->C2_XPEDMAN
			c_ItemPv := (cAliasTop)->C2_XITEPEM
		EndIf
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posicionamento das tabelas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SB1")
	SB1->(dbSeek(xFilial("SB1")+(cAliasTop)->C2_PRODUTO ))
	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	SC5->(dbSeek( xFilial("SC5")+_cNumPV))
	dbSelectArea("SC6")
	SC6->(dbSetOrder(1))
	SC6->(dbSeek( xFilial("SC6")+_cNumPV+c_ItemPv))
	dbSelectArea("SA1")
	SA1->(dbSeek( xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI ))

	//Impressao da Section 1	
	nHres := _oPrint:nHorzRes()/2
	nHresTot := _oPrint:nHorzRes()	
			
	_nLinha += _nPulo		
	_nLinha += _nPulo		
	
	cUserImp := "Data Geração da OP: "
	_oPrint:Say( _nLinha, _nColun, cUserImp, _oFontAr )
	cUserImp := DTOC((cAliasTop)->C2_EMISSAO)
	_oPrint:Say( _nLinha, _nColun + 290, cUserImp, _oFontAr )
	
	cUserImp := "Usuario de Impressão: " 
	_oPrint:Say( _nLinha, _nCol2, cUserImp, _oFontAr )
	cUserImp := Alltrim(Substr(cUsuario,7,15))
	_oPrint:Say( _nLinha, _nCol2 + 310, cUserImp, _oFontAr )
	_oPrint:Say( _nLinha, nHresTot - 550, "Data de Entrega: "+DTOC((cAliasTop)->C2_DATPRF), oFontN14 ) 	
	_nLinha += _nPulo	
		
	cImpLin := "Pedido/Item:   "+_cNumPV+"/"+c_ItemPv
	_oPrint:Say( _nLinha, _nColun, cImpLin, _oFontArN )
	
	cImpLin := "Cliente:   "+SC5->C5_CLIENTE+"    Loja: "+SC5->C5_LOJACLI+"    Nome: "+LEFT(Alltrim(SA1->A1_NOME),40)
	_oPrint:Say( _nLinha, _nCol2, cImpLin, _oFontArN )
	//_oPrint:Say( _nLinha, nHresTot - 550, "Semana: "+SC5->C5_XNUMSEM, oFontN14 ) 	
	_oPrint:Say( _nLinha, nHresTot - 550, "Semana: "+PADL(retsem((cAliasTop)->C2_DATPRF),2,"0"), oFontN14 )

	_nLinha += _nPulo		

	
	cImpLin := "Produto:"
	_oPrint:Say( _nLinha, _nColun, cImpLin, _oFontAr )
	cImpLin := Alltrim((cAliasTop)->C2_PRODUTO) 
	_oPrint:Say( _nLinha, _nColun + 140, cImpLin, _oFontArN )

	//alert(SD4->D4_COD)

	aDesenhos := {}
	cCaminho := ""
	cCaminho := "V:\9 - FABRICA\1-Desenhos Liberados\"   

	cdirserv := "\Desenhos\"   

	CpyT2S( cCaminho + Alltrim((cAliasTop)->C2_PRODUTO)  +  ".png" , cdirserv )
	//\\192.168.12.3\dados-02\9 - FABRICA\1-Desenhos Liberados
	//if file("\Desenhos\" +  Alltrim((cAliasTop)->C2_PRODUTO)  +  ".png" )
	if file(cdirserv +  Alltrim((cAliasTop)->C2_PRODUTO)  +  ".png" )
	//	aadd(aDesenhos, { Alltrim((cAliasTop)->C2_PRODUTO) ,Alltrim(SB1->B1_DESC) ,  "\desenhos\" +  Alltrim((cAliasTop)->C2_PRODUTO) +  ".png"  })

	aadd(aDesenhos, { Alltrim((cAliasTop)->C2_PRODUTO) ,Alltrim(SB1->B1_DESC) ,  cdirserv +  Alltrim((cAliasTop)->C2_PRODUTO) +  ".png"  })
	endif

	if len(aDesenhos) ==  0

		_cQuery := "SELECT * " 
		_cQuery += CRLF + "FROM " + RetSqlName('SG1') + " SG1 (NOLOCK)  "
		_cQuery += CRLF + "WHERE SG1.G1_FILIAL = '" + xFilial("SG1") + "' "
		_cQuery += CRLF + "AND SG1.D_E_L_E_T_   = ' '  "
		_cQuery += CRLF + "AND SG1.G1_COD       = '" + Alltrim((cAliasTop)->C2_PRODUTO) + "'  " 
		//memowrite("D:\TOTVS12\Producao\protheus_data\queryapt\empenho3.txt", _cQuery )           
		TCQUERY _cQuery NEW ALIAS "_SG1"

		While _SG1->(!Eof())

			if file(cdirserv +  Alltrim(_SG1->G1_COMP)  +  ".png" )
				aadd(aDesenhos, {  Alltrim(_SG1->G1_COMP) ,Alltrim(SB1->B1_DESC) ,  cdirserv +  Alltrim(_SG1->G1_COMP) +  ".png"  })
				//aadd(aDesenhos, { "TESTE" ,Alltrim(SB1->B1_DESC) ,  "\desenhos\" +  "TESTE" +  ".jpg"  })
			endif

			dbSelectArea('_SG1')
			dbSkip()

		EndDo

		dbSelectArea('_SG1')
		dbCloseArea()	
	endif
	
	cImpLin := "Descricao: "
	_oPrint:Say( _nLinha, _nCol2, cImpLin, _oFontAr )
	cImpLin := Alltrim(SB1->B1_DESC) 
	_oPrint:Say( _nLinha, _nCol2 + 170, cImpLin, _oFontArN )
	_nLinha += _nPulo	

	OpQuant := (cAliasTop)->C2_QUANT
	cQtde := "Quantidade:" 
	_oPrint:Say( _nLinha, _nColun, cQtde, _oFontAr )
	cQtde := Alltrim(Transform(OpQuant,PesqPict("SC2","C2_QUANT"))) 
	_oPrint:Say( _nLinha, _nColun + 175, cQtde, _oFontArN )	
	 
	cQtde := "Un. Medida: "
	_oPrint:Say( _nLinha, _nCol2, cQtde, _oFontAr )
	cQtde := SB1->B1_UM
	_oPrint:Say( _nLinha, _nCol2 + 190, cQtde, _oFontArN ) 
	_nLinha += _nPulo              
    
    _cObserv:= IIF(ALLTRIM((cAliasTop)->C2_ITEM )+ALLTRIM((cAliasTop)->C2_SEQUEN ) =='01001',ALLTRIM((cAliasTop)->C2_OBS),IIF(empty(_cObserv),ALLTRIM((cAliasTop)->C2_OBS),_cObserv))
    _oPrint:Say( _nLinha, _nColun, "OBS: "+_cObserv, _oFontAr )
	
	_nLinha += _nPulo
	_oPrint:Line( _nLinha,10,_nLinha,_oPrint:nHorzRes()-10,,"-4" )
		
	_nLinha += _nPulo
	//_nLinha += _nPulo	

	//aDesenhos := {}


	
	// Secao 2 - EMPENHOS
	aEmpenhos := {}
	dbSelectArea("SD4")
	dbSetOrder(2)
	cSeekSD4 := xFilial("SD4")+(cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)
	dbSeek(cSeekSD4)
	While SD4->(!Eof()) .And. D4_FILIAL+D4_OP == cSeekSD4
	
		If SD4->D4_QUANT > 0 
			dbSelectArea("SB1")
			dbSeek(xFilial("SB1")+SD4->D4_COD)   

			dbSelectArea("SBM")
			dbSetOrder(1)
			dbSeek(xFilial("SBM") +  SB1->B1_GRUPO )

			
			
			dbSelectArea("NNR")
			dbSeek(xFilial("NNR")+SD4->D4_LOCAL) 		
			
			_cNumSeri := ""
			cKey := SD4->D4_FILIAL+SD4->D4_COD+SD4->D4_LOCAL+SD4->D4_OP+SD4->D4_TRT+SD4->D4_LOTECTL+SD4->D4_NUMLOTE
			
			//Busca o numero de serie
			DbSelectArea("SDC")
			DbSetOrder(2)
			DbSeek(cKey)
			If SDC->(!Eof()) .And. SDC->(DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_OP+DC_TRT+DC_LOTECTL+DC_NUMLOTE) == cKey 
				_cNumSeri  := SDC->DC_NUMSERI      
			EndIf	


			                     
			//Efetua a quebra da Descricao                                                                        
			If Len(Alltrim(SB1->B1_DESC)) > 40
				//               D4_COD     ,B1_DESC              ,COR     ,D4_QUANT     ,B1_UM      ,D4_LOCAL    ,NNR_DESCRI      ,D4_LOTECTL     ,SERIE
				AADD(aEmpenhos, {SD4->D4_COD,Subs(Alltrim(SB1->B1_DESC),1,40),""      ,SD4->D4_QUANT,SB1->B1_UM,SD4->D4_LOCAL,NNR->NNR_DESCRI ,SD4->D4_LOTECTL,_cNumSeri, SBM->BM_GRUPO, SBM->BM_DESC})
				AADD(aEmpenhos, {"",Subs(Alltrim(SB1->B1_DESC),41,10),"",,"","","","","",SBM->BM_GRUPO , SBM->BM_DESC})
			Else
				//               D4_COD     ,B1_DESC              ,COR     ,D4_QUANT     ,B1_UM      ,D4_LOCAL    ,NNR_DESCRI      ,D4_LOTECTL     ,SERIE
				AADD(aEmpenhos, {SD4->D4_COD,Alltrim(SB1->B1_DESC),""      ,SD4->D4_QUANT,SB1->B1_UM,SD4->D4_LOCAL,NNR->NNR_DESCRI ,SD4->D4_LOTECTL,_cNumSeri, SBM->BM_GRUPO, SBM->BM_DESC})		
			Endif

		
		endif
		dbSelectArea("SD4")
		dbSkip()
	Enddo

	
	
	//Impressao da Secao 2 Empenhos
	If Len(aEmpenhos) > 0 


		aSort( aEmpenhos,,, { | x, y | x[10] < y[10] } )

		_nLinha += _nPulo + _nPulo -20
		_oPrint:Say( _nLinha, nHres-150, "E M P E N H O S", oFontNCab )
		_nLinha += _nPulo
		
		_cCabEmp := "Produto" + Space(7)
		_cCabEmp += "Descricao" + Space(33)
		_cCabEmp += "Cor" + Space(9)
		_cCabEmp += "Qtde" + Space(6)
		_cCabEmp += "UM" + Space(2)
		_cCabEmp += "Amz" + Space(2)
		_cCabEmp += "Desc.Amz" + Space(8)
		_cCabEmp += "Lote" + Space(7)
		_cCabEmp += "Grupo" 
		//_cCabEmp += "Num.Serie"
		_oPrint:Say( _nLinha, _nColun , _cCabEmp , _oFontN )
		_nLinha += _nPulo - 20
		_oPrint:Line( _nLinha,10,_nLinha,_oPrint:nHorzRes()-10,,"-4" )
		_nLinha += _nPulo
		
		//ASort(aEmpenhos,,,{|aX,aY| aX[6] < aY[6]})
		xGrupo := ""
		For nY := 1 to Len(aEmpenhos)

			/*
			if xGrupo == "" .or. xGrupo <>  aEmpenhos[nY][10] 
				xGrupo := aEmpenhos[nY][10] 

				_cCabEmp := "Grupo" + Space(7)
				_cCabEmp += "Descricao" + Space(33)
				
				_oPrint:Say( _nLinha, _nColun , _cCabEmp , _oFontN )
				_nLinha += _nPulo //- 20

				_cPrtLin := PADR(aEmpenhos[nY][10],14) //Grupo
				_cPrtLin += PADR(Alltrim(aEmpenhos[nY][11]),33) //Descricao
				_oPrint:Say( _nLinha, _nColun , _cPrtLin , _oFont )
			    _nLinha += _nPulo
				//_oPrint:Line( _nLinha,10,_nLinha,_oPrint:nHorzRes()-10,,"-4" )
				//_nLinha += _nPulo
			endif
			*/
			_cPrtLin := PADR(aEmpenhos[nY][1],14) //Produto
			_cPrtLin += PADR(Alltrim(aEmpenhos[nY][2]),42) //Descricao
			_cPrtLin += PADR(Alltrim(aEmpenhos[nY][3]),12) //Cor
			_cPrtLin += PADR(Alltrim(Transform(aEmpenhos[nY][4],"@E 99999.99")),10) //Qtde
			_cPrtLin += PADR(aEmpenhos[nY][5],4) //UM
			_cPrtLin += PADR(aEmpenhos[nY][6],5) //Amz
			_cPrtLin += PADR(aEmpenhos[nY][7],16) //Desc.Amz
			_cPrtLin += PADR(aEmpenhos[nY][8],13) //Lote
			_cPrtLin += PADR(aEmpenhos[nY][10],6) //grupo
			_cPrtLin += alltrim(aEmpenhos[nY][11])   // desc Grupo
			//_cPrtLin += aEmpenhos[nY][9] //Serie				
			
			//Impressao 			
			_oPrint:Say( _nLinha, _nColun , _cPrtLin , _oFont )
			_nLinha += _nPulo
			
			//Verifica se uma nova pagina deve ser iniciada
			nVertSize := _oPrint:nVertRes() - 250
			If _nLinha >= nVertSize
				_oPrint:EndPage() // Finaliza a pagina
				_oPrint:StartPage()
			     nPagAtu++
				_nLinha := UPRELCAB(nPagAtu,cTitle)
				_nLinha += _nPulo
			Endif			
		Next nY     
		 	
	Endif
	_nLinha += _nPulo
	_nLinha += _nPulo	
	
	
	If !Empty((cAliasTop)->C2_ROTEIRO)
		// Secao 3 - ROTEIRO DE OPERAÇÕES
		_cPrtLin := "Recurso"+Space(33)+"Ferramenta"+Space(30)+"Operacao"
		_oPrint:Say( _nLinha, _nColun , _cPrtLin , _oFontN )
		_nLinha += _nPulo
		_oPrint:Line( _nLinha,10,_nLinha,_oPrint:nHorzRes()-10,,"-4" )
		_nLinha += _nPulo		
			
		//Imprimindo Roteiro de Operações
		UPRELROT(cAliasTop) 				
	Endif
	
	If l_ImpEtq
		If IsPrinter(cPorta) //Impressao de Etiqueta, caso a maquina logada nao esteja plugada na impressora termica, nao executa

			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+(cAliasTop)->C2_PRODUTO ))
			If SB1->B1_TIPO == "PA"
				DbSelectArea("SC2")
				SC2->(DbSetOrder(1))
				SC2->(DbSeek(xFilial("SC2")+(cAliasTop)->C2_NUM+(cAliasTop)->C2_ITEM+(cAliasTop)->C2_SEQUEN ))
				U_PERFETPA()	
			EndIf
		
		EndIf
	EndIf

	//Impressao da Secao desenho

	/*
	If MsgYesNo("Deseja imprimir o Desenho do P.A. ?")
		If Len(aDesenhos) > 0 
		ny := 0
			for ny:=1 to len(aDesenhos)
				cPathLocal  := GetTempPath()
				If CpyS2T( aDesenhos[nY][3] ,cPathLocal,.T.)

					ShellExecute("Open",  cPathLocal + alltrim((cAliasTop)->C2_PRODUTO) + ".pdf" , " /k dir", GetTempPath(), 1 )

				Endif
			next
		endif
	endif

	*/
	If Len(aDesenhos) > 0 

		_oPrint:EndPage() // Finaliza a pagina
		_oPrint:StartPage()
		
		nPagAtu++
		_nLinha := 15//UPRELCAB(nPagAtu,cTitle)
		_nLinha += _nPulo


		_nLinha += _nPulo + _nPulo -20
		_oPrint:Say( _nLinha, nHres-150, "D E S E N H O ", oFontNCab )
		_nLinha += _nPulo
		
		_cCabEmp := "Produto" + Space(7)
		_cCabEmp += "Descricao" + Space(33)
		
		_oPrint:Say( _nLinha, _nColun , _cCabEmp , _oFontN )
		_nLinha += _nPulo - 20
		_oPrint:Line( _nLinha,10,_nLinha,_oPrint:nHorzRes()-10,,"-4" )
		_nLinha += _nPulo
		
		//ASort(aEmpenhos,,,{|aX,aY| aX[6] < aY[6]})
		For nY := 1 to Len(aDesenhos)
			_cPrtLin := PADR(aDesenhos[nY][1],14) //Produto
			_cPrtLin += PADR(Alltrim(aDesenhos[nY][2]),42) //Descricao			
			
			//Impressao 			
			_oPrint:Say( _nLinha, _nColun , _cPrtLin , _oFont )
			_nLinha += _nPulo
			_nLinha += _nPulo

			_oPrint:SayBitmap(_nLinha , _nColun, aDesenhos[nY][3] , 2300 ,2700 )
			
			_nLinha += _nPulo
			//_oPrint:EndPage() // Finaliza a pagina
		    //_oPrint:StartPage()
			//nPagAtu++
			//_nLinha := UPRELCAB(nPagAtu,cTitle)
			//_nLinha += _nPulo
		
		Next nY     
		 	
	Endif


	_oPrint:EndPage() // Finaliza a pagina
	dbSelectArea(cAliasTop)
	(cAliasTop)->(dbSkip())
	
	//Reinicia a numeracao de pagina qdo trocar de OP
	nPagAtu := 1

Enddo

//ConvPdfJpg("000012", "000012")


	
_oPrint:EndPage()     // Finaliza a pagina
_oPrint:Setup()
_oPrint:SetPortrait() //Retrato
_oPrint:SetPaperSize(DMPAPER_A4)
_oPrint:SetMargin(10,0,10,0)

If _oPrint:nModalResult == PD_OK
	_oPrint:Preview()
	_oPrint:SetViewPDF(.T.)
EndIf



Return

/*/
+---------------------------------------------------------------------------+
| Programa  | UPRELCAB   | Autor | Marcio Gois            | Data | 12/12/18 |
|-----------+---------------------------------------------------------------|
| Descrição | Impressão da Ordem de Produção com Roteiro de Operações       |
|-----------+---------------------------------------------------------------|
| Uso       | Perfil Refrigeração                                           |
+---------------------------------------------------------------------------+*/
Static Function UPRELCAB(nPagAtu,cTitle)
Local cContrat	:= ""
Local cCliente	:= ""
Local nCol		:= 50
Local nLin		:= 80
Local nPulo		:= 40

_oPrint:Line( 05,10,05,_oPrint:nHorzRes()-10,,"-4" )

nHres := _oPrint:nHorzRes()/2

_cArq := "\system\LGMID.png"
_oPrint:SayBitmap( nLin-70,nCol,_cArq,160,75 )
_oPrint:Say( nLin, _oPrint:nHorzRes()-340, "Pag. "+StrZero(nPagAtu,2) , oFontCab )

nLin += nPulo

_oPrint:Say( nLin, nCol, "Hora: "+Time(), oFontCab )
_oPrint:Say( nLin, nHres -490, cTitle, oFontNCab )
_oPrint:Say( nLin, _oPrint:nHorzRes()-340, "Emissão: "+DTOC(Date()) , oFontCab )

nLin += nPulo
_oPrint:Say( nLin, nCol, "Empresa: "+Alltrim(FWFilialName())+" / Filial: "+Alltrim(FWFilialName()), oFontCab )

nLin += nPulo
_oPrint:Line( nLin,10,nLin,_oPrint:nHorzRes()-10,,"-4" )

Return (nLin)


/*/
+---------------------------------------------------------------------------+
| Função    | UPRELROT   | Autor | Marcio Gois            | Data | 12/12/18 |
|-----------+---------------------------------------------------------------|
| Descrição | Impressão da Ordem de Produção com Roteiro de Operações       |
|-----------+---------------------------------------------------------------|
| Uso       | Perfil Refrigeração                                           |
+---------------------------------------------------------------------------+*/
Static Function URLOTSER()
Local _cRetSerie  	:= ""
Local cKey    		:= ""

//Posicionado no Empenho
dbSelectArea("SD4")
cKey := SD4->D4_FILIAL+SD4->D4_COD+SD4->D4_LOCAL+SD4->D4_OP+SD4->D4_TRT+SD4->D4_LOTECTL+SD4->D4_NUMLOTE

DbSelectArea("SDC")
DbSetOrder(2)
DbSeek(xFilial("SDC")+cKey)
If SDC->(!Eof()) .And. SDC->(DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_OP+DC_TRT+DC_LOTECTL+DC_NUMLOTE) == cKey 
	_cRetSerie  := SDC->DC_NUMSERI      
EndIf

dbSelectArea("SD4")

Return


/*/
+---------------------------------------------------------------------------+
| Função    | UPRELROT   | Autor | Marcio Gois            | Data | 12/12/18 |
|-----------+---------------------------------------------------------------|
| Descrição | Impressão da Ordem de Produção com Roteiro de Operações       |
|-----------+---------------------------------------------------------------|
| Uso       | Perfil Refrigeração                                           |
+---------------------------------------------------------------------------+*/

Static Function UPRELROT(cAliasTop)

Local cRoteiro	 := ""
Local cSeekWhile := ""
Local lSH6 		 := .F.
Local aArea   	 := GetArea()
Local nLin		 := 0

nLinBar	:= 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se imprime ROTEIRO da OP ou PADRAO do produto    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty((cAliasTop)->C2_ROTEIRO)
	cRoteiro:=(cAliasTop)->C2_ROTEIRO
Else
	If !Empty(SB1->B1_OPERPAD)
		cRoteiro:=SB1->B1_OPERPAD
	Else
		If a630SeekSG2(1,(cAliasTop)->C2_PRODUTO,xFilial("SG2")+(cAliasTop)->C2_PRODUTO+"01")
			dbSelectArea("SB1")
			RecLock("SB1",.F.)
			Replace B1_OPERPAD With "01"
			MsUnLock()
			cRoteiro:="01"
		EndIf
	EndIf
EndIf
            
lPag := .F.

cSeekWhile := "SG2->(G2_FILIAL+G2_PRODUTO+G2_CODIGO)"
If a630SeekSG2(1,(cAliasTop)->C2_PRODUTO,xFilial("SG2")+(cAliasTop)->C2_PRODUTO+cRoteiro,@cSeekWhile)
	
	While SG2->(!Eof()) .And. Eval(&cSeekWhile)
		SH6->(dbSetOrder(1))
		If SH6->(dbSeek(xFilial("SH6")+(cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)+(cAliasTop)->C2_PRODUTO+SG2->G2_OPERAC))
			lSH6 := .T.
		EndIf
		                                         
		If lSH6
			While SH6->(!Eof()) .And. SH6->(H6_FILIAL+H6_OP+H6_OPERAC) == xFilial("SH6")+(cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)+SG2->G2_OPERAC
				SH1->(dbSeek(xFilial("SH1")+SH6->H6_RECURSO))
				SH4->(dbSeek(xFilial("SH4")+SG2->G2_FERRAM))
				
				//Verifica se uma nova pagina deve ser iniciada
				nVertSize := _oPrint:nVertRes() - 300
				If _nLinha >= nVertSize
					_oPrint:EndPage() // Finaliza a pagina
					_oPrint:StartPage()
				     nPagAtu++	     
					_nLinha := UPRELCAB(nPagAtu,cTitle)
					_nLinha += _nPulo
				Endif							

				_cPrtLin := PADR(Alltrim(SH6->H6_RECURSO) + Space(2) + Alltrim(SH1->H1_DESCRI),40)
				_cPrtLin += PADR(Alltrim(SG2->G2_FERRAM)  + Space(2) + Alltrim(SH4->H4_DESCRI),40)
				_cPrtLin += PADR(Alltrim(SG2->G2_OPERAC)  + Space(2) + Alltrim(SG2->G2_DESCRI),40)
				
				_oPrint:Say( _nLinha, _nColun , _cPrtLin , _oFont )
				nBarra := _nLinha / 42
				_oPrint:FWMSBAR("CODE128" /*cTypeBar*/,nBarra/*nRow*/ ,30.5/*nCol*/ ,(cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)+SG2->G2_OPERAC  /*cCode*/,_oPrint/*oPrint*/,/*lCheck*/,/*Color*/,/*lHorz*/, 0.020/*nWidth*/,0.7/*nHeigth*/,/*lBanner*/,/*cFont*/,/*cMode*/,.F./*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/,/*lCmtr2Pix*/)								
				_nLinha += _nPulo	
				
				cDTHRINI := DTOC(SH6->H6_DATAINI)+Space(03)+SH6->H6_HORAINI            
				cDTHRFIM := DTOC(SH6->H6_DATAFIN)+Space(03)+SH6->H6_HORAFIN
				
				_cPrtLin := "Operador: "+ SH6->H6_OPERADO
				_oPrint:Say( _nLinha, _nColun , _cPrtLin , _oFont )
				_nLinha += _nPulo	

				_cPrtLin := "INICIO  REAL: "+ cDTHRINI + Space(8)
				_cPrtLin += "TERMINO REAL: "+ cDTHRFIM 
				_oPrint:Say( _nLinha, _nColun , _cPrtLin , _oFont )
				_nLinha += _nPulo				

				_cPrtLin := "Quantidade: "+ Alltrim(Transform(aSC2Sld(cAliasTop),PesqPict("SC2","C2_QUANT")))+Space(4) 
				_cPrtLin += "Quantidade Produzida: " + Alltrim(Transform(SH6->H6_QTDPROD,PesqPict("SH6","H6_QTDPROD")))+ Space(4) 
				_cPrtLin += "Perdas: "+ Alltrim(Transform(SH6->H6_QTDPERD,PesqPict("SH6","H6_QTDPERD")))
				_oPrint:Say( _nLinha, _nColun , _cPrtLin , _oFont )	
				
				_nLinha += _nPulo
				_oPrint:Line( _nLinha,10,_nLinha,_oPrint:nHorzRes()-10,,"-4" )	
				_nLinha += _nPulo
			
				SH6->(dbSkip())
			EndDo
		Else
			SH1->(dbSeek(xFilial("SH1")+SG2->G2_RECURSO))
			SH4->(dbSeek(xFilial("SH4")+SG2->G2_FERRAM))

			//Verifica se uma nova pagina deve ser iniciada
			nVertSize := _oPrint:nVertRes() - 300
			If _nLinha >= nVertSize
				_oPrint:EndPage() // Finaliza a pagina
				_oPrint:StartPage()
			     nPagAtu++   
				_nLinha := UPRELCAB(nPagAtu,cTitle)
				_nLinha += _nPulo
			Endif		

			_cPrtLin := PADR(Alltrim(SG2->G2_RECURSO) + Space(2) + Alltrim(SH1->H1_DESCRI),40)
			_cPrtLin += PADR(Alltrim(SG2->G2_FERRAM)  + Space(2) + Alltrim(SH4->H4_DESCRI),40)
			_cPrtLin += PADR(Alltrim(SG2->G2_OPERAC)  + Space(2) + Alltrim(SG2->G2_DESCRI),40)
			
			_oPrint:Say( _nLinha, _nColun , _cPrtLin , _oFont )
			
			nBarra := _nLinha / 42
			_oPrint:FWMSBAR("CODE128" /*cTypeBar*/,nBarra/*nRow*/ ,30.5/*nCol*/ ,(cAliasTop)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)+SG2->G2_OPERAC  /*cCode*/,_oPrint/*oPrint*/,/*lCheck*/,/*Color*/,/*lHorz*/, /*nWidth*/,0.7/*nHeigth*/,/*lBanner*/,/*cFont*/,/*cMode*/,.F./*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/,/*lCmtr2Pix*/)
			
			_nLinha += _nPulo				
			 
			_cPrtLin := "Operador: "
			_oPrint:Say( _nLinha, _nColun , _cPrtLin , _oFont )
			_nLinha += _nPulo	

			_cPrtLin := "INICIO  REAL:  ___/___/_____  ____:____" + Space(2)
			_cPrtLin += "TERMINO REAL:  ___/___/_____  ____:____" 
			_oPrint:Say( _nLinha, _nColun , _cPrtLin , _oFont )
			_nLinha += _nPulo				

			_cPrtLin := "Quantidade: "+ Alltrim(Transform(aSC2Sld(cAliasTop),PesqPict("SC2","C2_QUANT")))+Space(4)
			_cPrtLin += "Quantidade Produzida: 0,00" + Space(12) + "Perdas: 0,00"
			_oPrint:Say( _nLinha, _nColun , _cPrtLin , _oFont )				
				
			_nLinha += _nPulo
			_oPrint:Line( _nLinha,10,_nLinha,_oPrint:nHorzRes()-10,,"-4" )
			_nLinha += _nPulo
		 
		Endif
		lSH6 := .F.
		SG2->(dbSkip())
	EndDo
Endif

RestArea(aArea)

Return Nil


/*/
+---------------------------------------------------------------------------+
| Função    | ValPerg    | Autor | Marcio Gois            | Data | 12/12/18 |
|-----------+---------------------------------------------------------------|
| Descrição | Impressão da Ordem de Produção com Roteiro de Operações       |
|-----------+---------------------------------------------------------------|
| Uso       | Perfil Refrigeração                                           |
+---------------------------------------------------------------------------+*/
Static Function ValPerg()

Local _sAlias	:= Alias()
Local aCposSX1	:= {}
Local aPergs	:= {}
Local nX 		:= 0
Local lAltera	:= .F.
Local nCondicao
Local cKey		:= ""
Local nJ		:= 0

Aadd(aPergs,{"Da O.P. ?                     ?","","","mv_ch1","C",14,0,0,"G","","MV_PAR01","","","","      ","","","","","","","","","","","","","","","","","","","","","SC2","","","",""})
Aadd(aPergs,{"Ate a O.P. ?                  ?","","","mv_ch2","C",14,0,0,"G","","MV_PAR02","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","SC2","","","",""})
Aadd(aPergs,{"Da data ?                     ?","","","mv_ch3","D",08,0,0,"G","","MV_PAR03","","","","01/01/18","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate a data ?                  ?","","","mv_ch4","D",08,0,0,"G","","MV_PAR04","","","","31/12/18","","","","","","","","","","","","","","","","","","","","","","","","",""})

aCposSX1:={"X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO",;
			"X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID",;
			"X1_VAR01","X1_DEF01","X1_DEFSPA1","X1_DEFENG1","X1_CNT01",;
			"X1_VAR02","X1_DEF02","X1_DEFSPA2","X1_DEFENG2","X1_CNT02",;
			"X1_VAR03","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_CNT03",;
			"X1_VAR04","X1_DEF04","X1_DEFSPA4","X1_DEFENG4","X1_CNT04",;
			"X1_VAR05","X1_DEF05","X1_DEFSPA5","X1_DEFENG5","X1_CNT05",;
			"X1_F3", "X1_GRPSXG", "X1_PYME","X1_HELP" }

dbSelectArea("SX1")
dbSetOrder(1)
For nX:=1 to Len(aPergs)
	lAltera := .F.
	If MsSeek(cPerg+Right(aPergs[nX][11], 2))
		If (ValType(aPergs[nX][Len(aPergs[nx])]) = "B" .And.;
			Eval(aPergs[nX][Len(aPergs[nx])], aPergs[nX] ))
			aPergs[nX] := ASize(aPergs[nX], Len(aPergs[nX]) - 1)
			lAltera := .T.
		Endif
	Endif
	
	If ! lAltera .And. Found() .And. X1_TIPO <> aPergs[nX][5]
		lAltera := .T.		// Garanto que o tipo da pergunta esteja correto
	Endif
	
	If ! Found() .Or. lAltera
		RecLock("SX1",If(lAltera, .F., .T.))
		Replace X1_GRUPO with cPerg
		Replace X1_ORDEM with Right(aPergs[nX][11], 2)
		For nj:=1 to Len(aCposSX1)
			If 	Len(aPergs[nX]) >= nJ .And. aPergs[nX][nJ] <> Nil .And.;
				FieldPos(AllTrim(aCposSX1[nJ])) > 0
				Replace &(AllTrim(aCposSX1[nJ])) With aPergs[nx][nj]
			Endif
		Next nj
		MsUnlock()
		cKey := "P."+AllTrim(X1_GRUPO)+AllTrim(X1_ORDEM)+"."
		
		If ValType(aPergs[nx][Len(aPergs[nx])]) = "A"
			aHelpSpa := aPergs[nx][Len(aPergs[nx])]
		Else
			aHelpSpa := {}
		Endif
		
		If ValType(aPergs[nx][Len(aPergs[nx])-1]) = "A"
			aHelpEng := aPergs[nx][Len(aPergs[nx])-1]
		Else
			aHelpEng := {}
		Endif
		
		If ValType(aPergs[nx][Len(aPergs[nx])-2]) = "A"
			aHelpPor := aPergs[nx][Len(aPergs[nx])-2]
		Else
			aHelpPor := {}
		Endif
		
		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)
	Endif
Next

Return

/*/
+---------------------------------------------------------------------------+
| Função    | RETOPPAI   | Autor | Marcio Gois            | Data | 22/12/18 |
|-----------+---------------------------------------------------------------|
| Descrição | Impressão da Ordem de Produção com Roteiro de Operações       |
|-----------+---------------------------------------------------------------|
| Uso       | Perfil Refrigeração                                           |
+---------------------------------------------------------------------------+*/
Static Function RETOPPAI(cOp)

Local aDados := {"","",""}

cQuery := " SELECT C2_OBS,C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD AS C2_OPPAI,C2_PEDIDO,C2_ITEMPV,C2_SEQUEN,C2_XPEDMAN,C2_XITEPEM
cQuery += " FROM " +RetSqlName("SC2")
cQuery += " WHERE D_E_L_E_T_='' AND C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD ='"+cOp+"' "

If Sele("TOPP")	<> 0
	TOPP->(DbCloseArea())
Endif

TCQUERY cQuery NEW ALIAS "TOPP"

dbSelectArea("TOPP")
TOPP->(dbGoTop())
If !TOPP->(Bof()) .And. !TOPP->(Eof())
	If !Empty(TOPP->C2_PEDIDO)
		aDados := {TOPP->C2_OBS,TOPP->C2_OPPAI,TOPP->C2_PEDIDO,TOPP->C2_ITEMPV,TOPP->C2_SEQUEN}
    Else                                                                                       
    	aDados := {TOPP->C2_OBS,TOPP->C2_OPPAI,TOPP->C2_XPEDMAN,TOPP->C2_XITEPEM,TOPP->C2_SEQUEN}
    Endif

Endif

Return aDados   



/*
Static Function YOFATA22D(cArqPDF)
local  xdir    :=  "\Desenhos Liberados"// GetMv("MV_DIRCSV")
cPathLocal  := GetTempPath()

If CpyS2T(alltrim(xdir)+"\"+ cArqPDF,cPathLocal,.T.)

    ShellExecute("Open",  cPathLocal + cArqPDF, " /k dir", GetTempPath(), 1 )

Endif
Return
*/







