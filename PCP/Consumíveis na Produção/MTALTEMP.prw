#Include "Protheus.ch"
#Include "TopConn.ch"


/*-------------------------------------------------------------------------------------
{Protheus.doc} MTALTEMP

@Author  	   Felipe Aguiar - Focus Consultoria
@since		   04/2019
@version	   P12

@description Altera empenho gerado
---------------------------------------------------------------------------------------
|Author                  | Date       | Description                                    |
|                        |            |                                                |
--------------------------------------------------------------------------------------*/
User Function MTALTEMP()

Local a_Ret := PARAMIXB

/*
PARAMIXB[1] - C�digo do Produto que ser� gravado	
PARAMIXB[2] - Armaz�m selecionado para o produto	
PARAMIXB[3] - Quantidade do produto a ser gravada no empenho	
PARAMIXB[4] - Quantidade na Segunda Unidade de Medida	
PARAMIXB[5] - N�mero do lote que ser� gravado	
PARAMIXB[6] - N�mero do sub-lote que ser� gravado	
PARAMIXB[7] - Endere�o do produto	
PARAMIXB[8] - N�mero de S�rie do produto	
PARAMIXB[9] - N�mero da OP	
PARAMIXB[10] - Sequ�ncia do produto na estrutura	
PARAMIXB[11] - N�mero do Pedido de Vendas	
PARAMIXB[12] - Item do Pedido de Vendas	
PARAMIXB[13] - Origem do Empenho	
PARAMIXB[14] - Vari�vel L�gica - Determina se a opera��o � um estorno	
PARAMIXB[15] - Vetor de campos que foi carregado na altera��o de empenhos	
PARAMIXB[16] - Posi��o do elemento do vetor de campos
*/

If SB1->B1_XCONS == "S"
    a_Ret[2] := GetMV("MV_XLCEMP")
EndIf

Return a_Ret