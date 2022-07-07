#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FONT.CH"  
#INCLUDE "RWMAKE.CH" 

/*-------------------------------------------------------------------------------------|
|{Protheus.doc} PERFETPA                                                               | 
|                                                                                      | 
|@                                                                                     | 
|@Author  	   Felipe Aguiar - Focus Consultoria                                       | 
|@since		   05/2019                                                                 | 
|@version	   P12                                                                     | 
|                                                                                      | 
|@description Impressao de Etiqueta de PA                                              |
|--------------------------------------------------------------------------------------|
|Author                  | Date       | Description                                    |
|                        |            |                                                |
--------------------------------------------------------------------------------------*/

User Function PERFETPA()

Local cPorta		:= "LPT1"
Local a_AreaSB1	    := SB1->(GetArea())
Local a_AreaSC5	    := SC5->(GetArea())
Local a_AreaSC6	    := SC6->(GetArea())
Local a_AreaSA1	    := SA1->(GetArea())
Local c_Pedido      := ""
Local c_ItemPv      := ""

If !(Empty(SC2->C2_PEDIDO))
    c_Pedido := SC2->C2_PEDIDO
    c_ItemPv := SC2->C2_ITEMPV
Else
    c_Pedido := SC2->C2_XPEDMAN
    c_ItemPv := SC2->C2_XITEPEM
EndIf     

If !IsPrinter(cPorta)
	
	Aviso("Impressora","Porta "+cPorta+" não encontrada. Por favor, verifique as configurações para utilizar esta rotina. ",{"OK"})
	Return Nil 

Endif

DbSelectArea("SB1")
DbSetOrder(1)
DbSeek(xFilial("SB1")+SC2->C2_PRODUTO)

If !(SB1->B1_TIPO == "PA")

    MsgStop("Impressão disponível apenas para produtos acabados.")
    Return Nil

EndIf

DbSelectArea("SC5")
DbSetOrder(1)
DbSeek(xFilial("SC5")+c_Pedido)

DbSelectArea("SA1")
DbSetOrder(1)
DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)

DbSelectArea("SC6")
DbSetOrder(1)
DbSeek(xFilial("SC6")+c_Pedido+c_ItemPv)

MSCBPRINTER("ZEBRA",cPorta,,173,.F.,,,,,,.T.,)
MSCBCHKSTATUS(.T.)

//MSCBloadGrf("LOG2.grf")
MSCBBEGIN(1,5)				 // Qtd de impressoes , Velocidade de impressao
MSCBBOX(003,003,097,120,006) //box contorno etiqueta
//MSCBGRAFIC(092,005,"LOG2")

//BOX CABECALHO 
//MSCBSAY(035,006,"ASSISTENCIA TECNICA"  ,"N","0","030,023")
MSCBSAY(008,006,"PERFIL REFRIGERAÇÃO - ASSISTÊNCIA TÉCNICA"  ,"N","0","030,023")
MSCBSAY(037,011,"(11) 4135 - 2089"    ,"N","0","030,023")
MSCBSAY(008,016,"RUA IFEMA - 650 , VARGEM GRANDE PAULISTA - SP, CEP 06730-000"  ,"N","0","030,023")

//BOX 1
MSCBSAY(005,030,"PRODUTO: " + ALLTRIM(SC2->C2_PRODUTO)                  ,"N","0","030,023")
MSCBSAY(005,035,"CLIENTE: " + ALLTRIM(SA1->A1_NOME)                     ,"N","0","030,023")
MSCBSAY(005,040,"DESC: " + SUBSTR(SB1->B1_DESC,1,20)                    ,"N","0","030,023")
MSCBSAY(005,045,"CODIGO PN: "                                           ,"N","0","030,023")
MSCBSAY(050,040,"SERIAL"                                                ,"N","0","030,023")
MSCBSAY(050,045,"NUMBER: " +ALLTRIM(SC2->(C2_NUM+C2_ITEM+C2_SEQUEN))    ,"N","0","030,023")

//BOX 2
MSCBSAY(005,055,"TENSÃO: " + ALLTRIM(SB1->B1_XTENSAO)       ,"N","0","030,023")
MSCBSAY(005,060,"FREQUÊNCIA"                                ,"N","0","030,023")
MSCBSAY(005,065,"NOMINAL: " + ALLTRIM(SB1->B1_XFREQNO)      ,"N","0","030,023")
MSCBSAY(005,070,"AREA DE"                                   ,"N","0","030,023")
MSCBSAY(005,075,"EXPOS.: "  + ALLTRIM(SB1->B1_XAREAEX)      ,"N","0","030,023")
MSCBSAY(005,080,"GÁS"                                       ,"N","0","030,023")
MSCBSAY(005,085,"REFRIGERANTE: " + ALLTRIM(SB1->B1_XGASREF) ,"N","0","030,023")
MSCBSAY(005,090,"PESO: "  + ALLTRIM(STR(SB1->B1_XPESOWB))   ,"N","0","030,023")

//BOX 3
MSCBSAY(050,055,"CLASSE: "   + ALLTRIM(SB1->B1_XCLASSE)     ,"N","0","030,023")
MSCBSAY(050,060,"CORRENTE"                                  ,"N","0","030,023")
MSCBSAY(050,065,"NOMINAL: " + ALLTRIM(SB1-> B1_XCORRNO)     ,"N","0","030,023")
MSCBSAY(050,070,"ILUMINAÇÃO: " + ALLTRIM(SB1->B1_XILUMIN)   ,"N","0","030,023")
MSCBSAY(050,075,"AGENTE"                                    ,"N","0","030,023")
MSCBSAY(050,080,"EXPANSOR: "  + ALLTRIM(SB1->B1_XAGENTE)    ,"N","0","030,023")
MSCBSAY(050,085,"POTÊNCIA"                                  ,"N","0","030,023")
MSCBSAY(050,090,"NOMINAL: " + ALLTRIM(SB1->B1_XPOTENC)      ,"N","0","030,023")

//RODAPE
MSCBSAY(012,100,"POSIÇÃO: "          ,"N","0","030,023")
MSCBSAY(015,110,ALLTRIM(c_ItemPv)    ,"N","0","040,033") 
MSCBSAY(042,100,"PEDIDO: "           ,"N","0","030,023")
MSCBSAY(042,110, ALLTRIM(c_Pedido)   ,"N","0","040,033") 
MSCBSAY(070,100,"ANO FABRICAÇÃO:"    ,"N","0","030,023")
MSCBSAY(075,110, SUBSTR(DTOC(SC2->C2_EMISSAO),4,7),"N","0","040,033")

MSCBLineV(047,050,095,006)  
MSCBLineV(032,095,120,006)
MSCBLineV(063,095,120,006)

MSCBLineH(003,025,097,006)
MSCBLineH(003,050,097,006) 
MSCBLineH(003,095,097,006) 

MSCBEND()
MSCBCLOSEPRINTER()

RestArea(a_AreaSA1)
RestArea(a_AreaSC6)
RestArea(a_AreaSC5)
RestArea(a_AreaSB1)

Return Nil