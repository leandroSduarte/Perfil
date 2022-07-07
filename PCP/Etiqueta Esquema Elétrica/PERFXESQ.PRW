#INCLUDE "Protheus.ch"
#INCLUDE "RWMAKE.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "TbiConn.ch" 
#INCLUDE "Font.ch"
#INCLUDE "FwBrowse.ch"

/*-------------------------------------------------------------------------------------
{Protheus.doc} PERF001

@Author  	   Felipe Aguiar - Focus Consultoria
@since		   03/2019
@version	   P12

@description Funcao de visualizacao do Esquema Eletrico
---------------------------------------------------------------------------------------
|Author                  | Date       | Description                                    |
|                        |            |                                                |
--------------------------------------------------------------------------------------*/
User Function PERF001()

Local c_Image   := SB1->B1_XESQELE
Local cPorta    := "LPT1"

If !IsPrinter(cPorta)
	
	Aviso("Impressora","Porta "+cPorta+" não encontrada. Por favor, verifique as configurações para utilizar esta rotina. ",{"OK"})
	
	Return Nil 

Endif

MSCBPRINTER("ZEBRA","LPT1",,)
MSCBCHKSTATUS(.F.)
MSCBBEGIN(1,4)
MSCBWrite(c_Image)

MSCBEND()
MSCBCLOSEPRINTER()

Return Nil
