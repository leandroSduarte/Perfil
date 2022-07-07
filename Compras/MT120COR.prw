#Include "Protheus.ch"
#Include "TopConn.ch"


/*-------------------------------------------------------------------------------------
{Protheus.doc} MT120COR

@Author  	   Felipe Aguiar - Focus Consultoria
@since		   03/2019
@version	   P12

@description Adiciona botao Cancelar
---------------------------------------------------------------------------------------
|Author                  | Date       | Description                                    |
|                        |            |                                                |
--------------------------------------------------------------------------------------*/
User Function MT120COR()

Local aAux      := aClone(PARAMIXB[1])  
Local aNewCores := {}

aAdd(aNewCores, {'!Empty(C7_XDTCANC)' , 'BR_VIOLETA'} )

For i:= 1 To Len(aAux)
    aAdd( aNewCores, { aAux[i][1] , aAux[i][2] }) 
Next i 

Return aNewCores