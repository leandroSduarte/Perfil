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
PARAMIXB[1] - Código do Produto que será gravado	
PARAMIXB[2] - Armazém selecionado para o produto	
PARAMIXB[3] - Quantidade do produto a ser gravada no empenho	
PARAMIXB[4] - Quantidade na Segunda Unidade de Medida	
PARAMIXB[5] - Número do lote que será gravado	
PARAMIXB[6] - Número do sub-lote que será gravado	
PARAMIXB[7] - Endereço do produto	
PARAMIXB[8] - Número de Série do produto	
PARAMIXB[9] - Número da OP	
PARAMIXB[10] - Sequência do produto na estrutura	
PARAMIXB[11] - Número do Pedido de Vendas	
PARAMIXB[12] - Item do Pedido de Vendas	
PARAMIXB[13] - Origem do Empenho	
PARAMIXB[14] - Variável Lógica - Determina se a operação é um estorno	
PARAMIXB[15] - Vetor de campos que foi carregado na alteração de empenhos	
PARAMIXB[16] - Posição do elemento do vetor de campos
*/

If SB1->B1_XCONS == "S"
    a_Ret[2] := GetMV("MV_XLCEMP")
EndIf

Return a_Ret