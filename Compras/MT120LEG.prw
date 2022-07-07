#Include "Protheus.ch"
#Include "TopConn.ch"


/*-------------------------------------------------------------------------------------
{Protheus.doc} MT120LEG

@Author  	   Felipe Aguiar - Focus Consultoria
@since		   03/2019
@version	   P12

@description Adiciona botao Cancelar
---------------------------------------------------------------------------------------
|Author                  | Date       | Description                                    |
|                        |            |                                                |
--------------------------------------------------------------------------------------*/
User Function MT120LEG()

Local aNewLegenda  := aClone(PARAMIXB[1])

aAdd(aNewLegenda,{'BR_VIOLETA'  , 'Pedido Cancelado'})

Return aNewLegenda