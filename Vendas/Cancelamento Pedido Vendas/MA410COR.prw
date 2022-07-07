#Include "Protheus.ch"
#Include "TopConn.ch"


/*-------------------------------------------------------------------------------------
{Protheus.doc} MA410COR

@Author  	   Felipe Aguiar - Focus Consultoria
@since		   03/2019
@version	   P12

@description Adiciona novas legendas
---------------------------------------------------------------------------------------
|Author                  | Date       | Description                                    |
|                        |            |                                                |
--------------------------------------------------------------------------------------*/

User Function MA410COR()

Local aAux      := aClone(PARAMIXB)  
Local aNewCores := {}

aAdd(aNewCores, {'!Empty(C5_XDTCANC)' , 'BR_VIOLETA' , 'Pedido Cancelado' } )

For i:= 1 To Len(aAux)
    aAdd( aNewCores, { aAux[i][1] , aAux[i][2] , aAux[i][3] }) 
Next i 

Return aNewCores