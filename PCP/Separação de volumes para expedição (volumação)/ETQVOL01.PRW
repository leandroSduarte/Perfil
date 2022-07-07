#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FONT.CH"  
#INCLUDE "RWMAKE.CH"

/*-------------------------------------------------------------------------------------|
|{Protheus.doc} ETQVOL01                                                               | 
|                                                                                      | 
|@                                                                                     | 
|@Author  	   Felipe Aguiar - Focus Consultoria                                       | 
|@since		   05/2019                                                                 | 
|@version	   P12                                                                     | 
|                                                                                      | 
|@description Impressao de Etiqueta de Volumes                                         |
|--------------------------------------------------------------------------------------|
|Author                  | Date       | Description                                    |
|                        |            |                                                |
--------------------------------------------------------------------------------------*/
User Function ETQVOL01(cVol,cPedido,cItem,cOp)
       
Local cPorta		:= "LPT1"
Local nQtd          := 1

If !IsPrinter(cPorta)
	
	Aviso("Impressora","Porta "+cPorta+" não encontrada. Por favor, verifique as configurações para utilizar esta rotina. ",{"OK"})
	
	Return Nil 

Endif

DbSelectArea("SC5")
DbSetOrder(1)
DbSeek(xFilial("SC5")+cPedido)

DbSelectArea("SA1")
DbSetOrder(1)
DbSeek(xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI))

//MSCBloadGrf("logo2.pcx") 

MSCBPRINTER("ZEBRA",cPorta,,173,.F.,,,,,,.T.,)
MSCBCHKSTATUS(.T.)
MSCBBEGIN(nQtd,4)				 // Qtd de impressoes , Velocidade de impressao
MSCBBOX(003,003,097,120,006) //box contorno etiqueta

//MSCBGRAFIC(088,005,"logo2")

MSCBSAY(088,051,"PERFIL REFRIGERAÇÃO" ,"R","0","035,028")
//MSCBSAY(083,060," E " ,"R","0","035,028")
MSCBSAY(077,050,"VOLUMES DA EXPEDIÇÃO" ,"R","0","035,028")


MSCBLineV(073,003,120,006)  
MSCBSAY(065,006,"NUM VOLUME: " 	                    ,"R","0","035,028")
MSCBSAY(065,043, ALLTRIM(cVol) 	                    ,"R","0","035,028")

MSCBLineV(063,003,120,006)
MSCBSAY(055,006,"PEDIDO: " 	                        ,"R","0","035,028")      
MSCBSAY(055,043, cPedido     	                    ,"R","0","035,028") 

MSCBLineV(053,003,120,006)  
MSCBSAY(045,006,'CLIENTE: '  	                       ,"R","0","035,028")
MSCBSAY(045,043, ALLTRIM(SA1->(A1_COD+" - "+A1_NOME))  ,"R","0","035,028")

MSCBLineV(043,003,120,006)  
MSCBSAY(035,006,'LOJA: '   	                         ,"R","0","035,028")
MSCBSAY(035,043, ALLTRIM(SA1->A1_LOJA)               ,"R","0","035,028")

MSCBSAY(065,066,'       OP: ' 		        	     ,"R","0","035,028")
MSCBSAY(065,096, ALLTRIM(cOp)  	 	    			 ,"R","0","035,028")
MSCBSAY(055,066,'ITEM.: ' 					         ,"R","0","035,028")
MSCBSAY(055,096, ALLTRIM(cItem)		                 ,"R","0","035,028")

MSCBLineH(053,063,073,006)
MSCBLineH(053,093,073,006)

MSCBLineV(033,003,120,006)  
MSCBSAY(018,006,'CÓD. BARRAS: ',"R","0","035,028")
MSCBSAYBAR(015,062, ALLTRIM(cVol+cPedido+cItem)      ,"R","C",10,.F.,.T.,.F.,,2,4,.F.) 

MSCBLineH(003,040,073,006)    

MSCBEND()
MSCBCLOSEPRINTER()

Return Nil

