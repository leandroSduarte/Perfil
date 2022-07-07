#INCLUDE "PROTHEUS.CH"

/*-------------------------------------------------------------------------------------|
|{Protheus.doc} MTA103MNU                                                              | 
|                                                                                      | 
|@                                                                                     | 
|@Author  	   Felipe Aguiar - Focus Consultoria                                       | 
|@since		   05/2019                                                                 | 
|@version	   P12                                                                     | 
|                                                                                      | 
|@description Inclusao de Botoes no Documento de Entrada                               |
|--------------------------------------------------------------------------------------|
|Author                  | Date       | Description                                    |
|                        |            |                                                |
--------------------------------------------------------------------------------------*/
User Function MTA103MNU()

Local a_AreaATU	:= GetArea()

aAdd(aRotina , {"Etiqueta de Identificação", "U_PERFSEL(1)", 0 , 1, 0, .F.}) 

RestArea(a_AreaATU)

Return Nil