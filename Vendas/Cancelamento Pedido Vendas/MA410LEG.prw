#Include "Protheus.ch"
#Include "TopConn.ch"


/*-------------------------------------------------------------------------------------
{Protheus.doc} MA410LEG

@Author  	   Felipe Aguiar - Focus Consultoria
@since		   03/2019
@version	   P12

@description Adiciona novas legendas
---------------------------------------------------------------------------------------
|Author                  | Date       | Description                                    |
|                        |            |                                                |
--------------------------------------------------------------------------------------*/

User Function MA410LEG()

Local aNewLegenda  := aClone(PARAMIXB)

aAdd(aNewLegenda,{'BR_VIOLETA'  , 'Pedido Cancelado'})

Return aNewLegenda