#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"
/*
O ponto de entrada: MT103UPC, permite manipular o campo: "Último Preço de Compra" que é gravado nas tabelas: SB1 - Campo: B1_UPRC e SBZ - Campo: BZ_UPRC quando a nota fiscal for do Tipo: Normal e Complemento Preço / Frete, e quando a TES estiver configurada para gravar o último preço de compra.Será sempre executado no momento da gravação da nota fiscal.
Programa Fonte
MATA103X.PRW e MATA190.PRX
*/
User function MT103UPC()
Local nPreco :=0  

lPrecoDes := .T.

nPreco:=  IIf(lPrecoDes,SD1->D1_VUNIT-(SD1->D1_VALDESC/SD1->D1_QUANT),SD1->D1_VUNIT)  //SD1->D1_VUNIT + SD1->D1_VALFRE + (SF1->F1_DESPESA / SD1->D1_QUANT)

dbSelectArea("SBM")
dbSetOrder(1)
if dbSeek( xFilial("SBM")  +  SB1->B1_GRUPO  )

	if SBM->BM_XINDPRC > 0 

		SB1->B1_PRV1 := nPreco +  ( nPreco * SBM->BM_XINDPRC )   / 100

		dbSelectArea("DA1")
		dbSetOrder(1)
		if dbSeek(xFilial("DA1") + padr("001" , tamsx3("DA1_CODTAB")[1]) + SB1->B1_COD )
			
			RecLock("DA1",.F.)

				DA1->DA1_PRCVEN :=   nPreco +  ( nPreco * SBM->BM_XINDPRC )   / 100

			MsUnlock()

		endif
		
	endif

ENDIF


  
Return nPreco
