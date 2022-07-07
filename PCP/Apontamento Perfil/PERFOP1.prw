#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FONT.CH"
#INCLUDE "RWMAKE.CH"

/*-------------------------------------------------------------------------------------|
|{Protheus.doc} PERFOP01                                                               | 
|                                                                                      | 
|@                                                                                     | 
|@Author  	   Edson Estevam  - Delta Decisao                                          | 
|@since		   05/2021                                                                 | 
|@version	   P12                                                                     | 
|                                                                                      | 
|@description Parametros para impressao de Etiquetas de Ordem de Produção              |
|--------------------------------------------------------------------------------------|
|Author                  | Date       | Description                                    |
|                        |            |                                                |
--------------------------------------------------------------------------------------*/


User Function PERFOP01()
Local _aRetBox	:= {}
Local _cNumOp   := ""
Local cPorta	:= "LPT1"
Local _nQtde    := 0 
Local _cCodpro  := ""
Local _cDesc    := ""

	ParamBox({{1,"Ordem de Produção",Space(11),"","U_PEGAQTD() ","SC2","",0,.F.},;
	          {1,"Quantidade",0,"99999","","","",60,.T.}     },"Informe os Parâmetros.",@_aRetBox)

	If Len(_aRetBox) > 0
		_cNumOp  := _aRetBox[1]
		_nQtde   := _aRetBox[2]
		
	Else

	Return

	Endif

	_cOp    := Substr(_cNumOp,1,6)
	_cItem  := Substr(_cNumOp,7,2)
	_cSequen:= Substr(_cNumOp,9,3)
				
	DbSelectArea("SC2")
	DbSetOrder(1)   //C2_FILIAL, C2_NUM, C2_ITEM, C2_SEQUEN, C2_ITEMGRD, R_E_C_N_O_, D_E_L_E_T_
	If !SC2->(DbSeek(xFilial("SC2")+_cOp+_cItem+_cSequen))
			
			MsgStop("Ordem de Produção não Encontrada")
			Return
			
	Endif

	DbSelectArea("SB1")
	DbSetOrder(1)   
	SB1->(DbSeek(xFilial("SB1")+SC2->C2_PRODUTO))
    	
	_cCodpro := SB1->B1_COD
	_cDesc   := SB1->B1_DESC
			
	MSCBPRINTER("ZEBRA",cPorta,,173,.F.,,,,,,.T.,)
	MSCBCHKSTATUS(.T.)
	
	Do WHILE _nQtde > 0
		
		//MSCBBEGIN(nQtd,4)				 // Qtd de impressoes , Velocidade de impressao
		MSCBBEGIN(1,4)

		MSCBWRITE('^XA')
		MSCBWRITE('~TA000')
		MSCBWRITE('~JSN')
		MSCBWRITE('^LT0')
		MSCBWRITE('^MNW')
		MSCBWRITE('^MTT')
		MSCBWRITE('^PON')
		MSCBWRITE('^PMN')
		MSCBWRITE('^LH0,0')
		MSCBWRITE('^JMA')
		MSCBWRITE('^PR6,6')
		MSCBWRITE('~SD15')
		MSCBWRITE('^JUS')
		MSCBWRITE('^LRN')
		MSCBWRITE('^CI27')
		MSCBWRITE('^PA0,1,1,0')
		MSCBWRITE('^XZ')
		MSCBWRITE('##                            ^XA')
		MSCBWRITE('^MMT')
		MSCBWRITE('^PW559')
		MSCBWRITE('^LL240')
		MSCBWRITE('^LS0')
		MSCBWRITE('^FO6,3^GB547,233,8^FS')
		MSCBWRITE('^FT47,32^A0N,23,23^FH\^CI28^FDPerfil Refrigeracao Comercio e Servicos Ltda^FS^CI27')
		MSCBWRITE('^FO7,35^GB547,0,8^FS')
		MSCBWRITE('^FT422,143^A0N,20,20^FH\^CI28^FD'+ALLTRIM(DTOC(SC2->C2_EMISSAO))+'^FS^CI27')
		MSCBWRITE('^FT172,142^A0N,20,20^FH\^CI28^FD'+ALLTRIM(_cNumOp)+'^FS^CI27')
		MSCBWRITE('^FT114,112^A0N,20,18^FH\^CI28^FD'+ALLTRIM(_cDesc)+'^FS^CI27')
		MSCBWRITE('^FT271,76^A0N,32,20^FH\^CI28^FD'+ALLTRIM(_cCodpro)+'^FS^CI27')
		MSCBWRITE('^FT298,142^A0N,20,20^FH\^CI28^FDData Emissao^FS^CI27')
		MSCBWRITE('^FT17,142^A0N,20,20^FH\^CI28^FDOrdem Producao:^FS^CI27')
		MSCBWRITE('^FT17,112^A0N,20,20^FH\^CI28^FDDescricao:^FS^CI27')
		MSCBWRITE('^FT142,76^A0N,32,20^FH\^CI28^FDCod. Produto:^FS^CI27')
		MSCBWRITE('^BY2,3,50^FT146,209^BCN,,Y,N')
		MSCBWRITE('^FH\^FD>;'+ALLTRIM(_cCodpro)+'^FS')
		MSCBWRITE('^PQ1,0,1,Y')
		MSCBWRITE('^XZ')
		MSCBWRITE('##  ##')

		MSCBEND()
		_nQtde := _nQtde-1

		DbSkip()

	Enddo
	MSCBCLOSEPRINTER()
	
	U_PERFOP01()
Return

/*-------------------------------------------------------------------------------------|
|{Protheus.doc} U_PEGAQTD                                                               | 
|                                                                                      | 
|@                                                                                     | 
|@Author  	   Edson Estevam  - Delta Decisao                                          | 
|@since		   05/2021                                                                 | 
|@version	   P12                                                                     | 
|                                                                                      | 
|@description Parametros para impressao de Etiquetas de Ordem de Produção              |
|--------------------------------------------------------------------------------------|
|Author                  | Date       | Description                                    |
|                        |            |                                                |
--------------------------------------------------------------------------------------*/


User Function PEGAQTD ()

Local _cOp:= ""
Local _cItem := ""
Local _cSequen := ""

	If Empty(MV_PAR01)
	Return(.T.)
	EndIf

	_cOp    := Substr(MV_PAR01,1,6)
	_cItem  := Substr(MV_PAR01,7,2)
	_cSequen:= Substr(MV_PAR01,9,3)
				
	DbSelectArea("SC2")
	DbSetOrder(1)   //C2_FILIAL, C2_NUM, C2_ITEM, C2_SEQUEN, C2_ITEMGRD, R_E_C_N_O_, D_E_L_E_T_
	If SC2->(DbSeek(xFilial("SC2")+_cOp+_cItem+_cSequen))
			
	MV_PAR02 := SC2->C2_QUANT
			
	Endif

Return(.T.)
