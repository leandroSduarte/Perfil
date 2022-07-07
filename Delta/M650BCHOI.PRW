#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FONT.CH"  
#INCLUDE "RWMAKE.CH" 

/*-------------------------------------------------------------------------------------|
|{Protheus.doc} M650BCHOI                                                              | 
|                                                                                      | 
|@                                                                                     | 
|@Author  	   Felipe Aguiar - Focus Consultoria                                       | 
|@since		   05/2019                                                                 | 
|@version	   P12                                                                     | 
|                                                                                      | 
|@description Adiciona botoes na Mbrowse da Tela de OP                                 |
|--------------------------------------------------------------------------------------|
|Author                  | Date       | Description                                    |
|                        |            |                                                |
--------------------------------------------------------------------------------------*/

User Function M650BCHOI()

Local cBitMap  := "RELATORIO"
Local cHint    := "Imprimir Etiqueta"
Local aButtons := {{cBitMap,{|| fImpEtq()  },cHint}}

Return aButtons 

/**********************************************************************************/
Static Function fImpEtq()

MsAguarde({|| U_PERFETPA()}, "Gerando etiqueta. Por favor aguarde...")

Return Nil 