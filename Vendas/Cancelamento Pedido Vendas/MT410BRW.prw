#Include "Protheus.ch"
#Include "TopConn.ch"


/*-------------------------------------------------------------------------------------
{Protheus.doc} MT410BRW

@Author  	   Felipe Aguiar - Focus Consultoria
@since		   03/2019
@version	   P12

@description Adiciona botao Cancelar
---------------------------------------------------------------------------------------
|Author                  | Date       | Description                                    |
|                        |            |                                                |
--------------------------------------------------------------------------------------*/

User Function MT410BRW()

Local a_AreaATU	:= GetArea()                                   
 	
aadd(aRotina, {"Cancelar", "U_PFCANPV()", 0,1,0,.F.})   
 	
RestArea(a_AreaATU)

Return Nil 