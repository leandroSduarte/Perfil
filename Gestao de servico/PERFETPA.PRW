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

Local _aRetBox	:= {}
Local cPorta		:= "LPT1"
Local a_AreaSB1	    := SB1->(GetArea())
Local a_AreaSC5	    := SC5->(GetArea())
Local a_AreaSC6	    := SC6->(GetArea())
Local a_AreaSA1	    := SA1->(GetArea())
Local c_Pedido      := ""
Local c_ItemPv      := ""
Local _cSerie       := ""
Local _cPosicao     := ""
Local _nOpc         := 0
Local _nTotPot       := 0
Local _nTotA       := 0

ParamBox({{1,"Serie",Space(11),"","","","",0,.F.},;
{1,"Posicao",Space(03),"","","","",0,.F.},;
{3,"Layout",1,{"Novo","Anterior"},70,"",.F.}},"Informe os Parâmetros.",@_aRetBox)

If Len(_aRetBox) > 0
	_cSerie   := _aRetBox[1]
	_cPosicao := _aRetBox[2]
	_nOpc     := _aRetBox[3]
Else
	RestArea(a_AreaSA1)
	RestArea(a_AreaSC6)
	RestArea(a_AreaSC5)
	RestArea(a_AreaSB1)
	
	Return Nil
	
Endif

If !Empty(_cSerie)
	_cSerie := _aRetBox[1]
Else
	_cSerie := ALLTRIM(SC2->(C2_NUM+C2_ITEM+C2_SEQUEN))
Endif

If !Empty(_cPosicao)
	c_ItemPv := _cPosicao
Else
	If !(Empty(SC2->C2_PEDIDO))
		c_ItemPv := SC2->C2_ITEMPV
	Else
		c_ItemPv := SC2->C2_XITEPEM
	EndIf
Endif

If !(Empty(SC2->C2_PEDIDO))
	c_Pedido := SC2->C2_PEDIDO
Else
	c_Pedido := SC2->C2_XPEDMAN
EndIf

If !IsPrinter(cPorta)
	
	Aviso("Impressora","Porta "+cPorta+" não encontrada. Por favor, verifique as configurações para utilizar esta rotina. ",{"OK"})
	Return Nil
	
Endif

DbSelectArea("SB1")
DbSetOrder(1)
DbSeek(xFilial("SB1")+SC2->C2_PRODUTO)

//_nTotPot += Val(SB1->B1_XILUMIN)
//_nTotPot += SB1->B1_XVENTIL
//_nTotPot += SB1->B1_XRESQDR
//_nTotPot += SB1->B1_XRESPOR

//_nTotPot += SB1->B1_XRESDEG

//_nTotPot:= AllTrim(Transform(_nTotPot,PesqPict("SB2","B2_QATU")))
//Alert(_nTotPot)

If !(SB1->B1_TIPO == "PA")
	
	MsgStop("Impressão disponível apenas para produtos acabados.")
	Return Nil
	
EndIf
dbSelectArea("SM0")
dbSetOrder(1)
DbSeek(cEmpAnt+cFilAnt)

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

If _nOpc == 2// LAYOUT ANTIGO
	
	Alert("Antigo")
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
	MSCBSAY(050,045,"NUMBER: " +_cSerie ,"N","0","030,023")
	
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
	
ELSE // LAYOUT NOVO
	
	MSCBWRITE('CT~~CD,~CC^~CT~')
	MSCBWRITE('^XA~TA000~JSN^LT0^MNW^MTD^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ')
	MSCBWRITE('^XA')
	MSCBWRITE('^MMT')
	MSCBWRITE('^PW799')
	MSCBWRITE('^LL0999')
	MSCBWRITE('^LS0')
	MSCBWRITE('^FO0,0^GFA,06400,06400,00040,:Z64:')
	MSCBWRITE('eJztlEFu4kAQRcsmCIQUYRZZIo+89B2iDBLekwOMcpKInpt4aXEKH4FlFiHtI3jphRtP/WonQ+MEMptZ9ZcpFa32p7rqNUReXl5eXl5eXl7/oHnX1TTqWAF/lKTt/Ehd5e6b7XY7CjnsEHJJi1lBnDq6N8aoMYc2QCCkzZK/lO6+')
	MSCBWRITE('lN9XYiKm4l+k7KfcfVuup5qjqAmHI+rt6odm1KmhXy4msw+/PM3Dcz9dxni0fpm/0ZMmpOXTfqLP+sLnYr8CJy/YjNJCFjlzFHQlt+qh4TRuaNKRpFzx8dxP8dtiwiFkv1wWB34HRaZ83nO6rGl8oF81L5py+')
	MSCBWRITE('eruC8VPms9O7IKUF+UXTsQVcYkyzG1F8TFAOumUlOn44W3x49DP4b3ME3HTJvo32sedJP0y4ojFp727b4YJWFIwjjy04xngEmOoYK4Gfl2FIVdxO8AvfSdFnCw5ajbEBfg1YK5CMHTLobxvPsVPcLEMCi7cvAEuwE+')
	MSCBWRITE('BuVKC1Ku29QA/ayK4wMleF+DnbiOt3/jQGGb8GnDvJNXlED/4pz1+/OUCfmSZ48Bfto0sxmf42XPJMO1skYbSQdfPYB+')
	MSCBWRITE('YI2bwUJHZC5PL9txPisytqdyVr/BDPRXhTvDT40fb2t1nzyWTFTOpF7cObTwRk0Y0Yvw0mqfLkVayyAvOBZFz2T8WuSjWr7BjOlHcSpHCoCLgJ4tg0bkg6YcfTt7PIR36PeMtMNeODZGpbuEP/IxxTiyT6P+')
	MSCBWRITE('t/vrZW0L/UcGGNlGE5OfljVNS3/G7WTxmwWqVjbPsomGYECVJctXvLnuM1tn6LhpvLvpN8ZlO++xrRet1tLlZrxbB4uK+H2HIDyVhEl6tMbpY2UmN6lp1Xl5eXl5eXl7f0h81ZLmu:FEF9')
	MSCBWRITE('^FO15,15^GB768,977,8^FS')
	MSCBWRITE('^FT332,47^A0N,28,52^FH\^FDPerfil Refrigeracao^FS')
	MSCBWRITE('^FT417,81^A0N,28,28^FH\^FDAssistencia Tecnica ^FS')
	MSCBWRITE('^FT417,115^A0N,28,28^FH\^FD(11)4135-2089^FS')
	MSCBWRITE('^FT338,156^A0N,28,36^FH\^FDCliente^FS')
	MSCBWRITE('^FT26,196^A0N,28,43^FH\^FD'+ ALLTRIM(SA1->A1_NOME)+'^FS')
	MSCBWRITE('^FT291,300^A0N,19,28^FH\^FDDados do Expositor^FS')
	MSCBWRITE('^FT26,375^A0N,28,28^FH\^FDCNPJ:^FS')
	MSCBWRITE('^FT402,377^A0N,28,28^FH\^FDPeso:^FS')
	MSCBWRITE('^FT403,412^A0N,28,28^FH\^FDN Serie:^FS')
	MSCBWRITE('^FT27,339^A0N,28,28^FH\^FDFabricado por:^FS')
	MSCBWRITE('^FT26,411^A0N,28,28^FH\^FDGrau de Protecao:^FS')
	MSCBWRITE('^FT400,442^A0N,28,28^FH\^FDClasse de Isolacao:^FS')
	MSCBWRITE('^FT28,443^A0N,28,28^FH\^FDCarga:^FS')
	MSCBWRITE('^FT28,479^A0N,28,28^FH\^FDGas Refrigerante:^FS')
	MSCBWRITE('^FT30,513^A0N,28,28^FH\^FDAgente Expansor/Espuma Isolamento:^FS')
	MSCBWRITE('^FT398,477^A0N,28,28^FH\^FDClasse Climatica:^FS')
	MSCBWRITE('^FT30,549^A0N,28,28^FH\^FDAno de Fabricacao:^FS')
	MSCBWRITE('^FT251,668^A0N,28,28^FH\^FDCaracteristicas Eletricas^FS')
	MSCBWRITE('^FT121,711^A0N,28,28^FH\^FDCircuito^FS')
	MSCBWRITE('^FT304,715^A0N,28,28^FH\^FDPotencia (W)^FS')
	MSCBWRITE('^FT482,711^A0N,28,24^FH\^FDCorrente ^FS')
	MSCBWRITE('^FT482,745^A0N,28,24^FH\^FDNominal (A)^FS')
	MSCBWRITE('^FT634,727^A0N,28,28^FH\^FDTensao (A)^FS')
	MSCBWRITE('^FT28,789^A0N,28,28^FH\^FDIluminacao^FS')
	MSCBWRITE('^FT25,827^A0N,28,28^FH\^FDVentiladores^FS')
	MSCBWRITE('^FT27,862^A0N,28,28^FH\^FDResistencia a Quadro:^FS')
	MSCBWRITE('^FT26,895^A0N,28,28^FH\^FDResistencia Porta:^FS')
	MSCBWRITE('^FT26,934^A0N,28,28^FH\^FDResistencia Degelo:^FS')
	MSCBWRITE('^FO613,676^GB0,310,1^FS')
	MSCBWRITE('^FO471,680^GB0,307,1^FS')
	MSCBWRITE('^FO293,677^GB0,309,1^FS')
	MSCBWRITE('^FT30,236^A0N,28,28^FH\^FDCod. PN:^FS')
	MSCBWRITE('^FT396,230^A0N,28,28^FH\^FDProduto:^FS')
	MSCBWRITE('^FT30,264^A0N,28,28^FH\^FDDescricao^FS')
	MSCBWRITE('^FO21,198^GB758,0,5^FS')
	MSCBWRITE('^FO21,128^GB758,0,5^FS')
	MSCBWRITE('^FO25,567^GB759,0,5^FS')
	MSCBWRITE('^FO17,277^GB758,0,5^FS')
	MSCBWRITE('^FO22,306^GB759,0,4^FS')
	MSCBWRITE('^FO17,629^GB758,0,4^FS')
	MSCBWRITE('^FO22,677^GB758,0,4^FS')
	MSCBWRITE('^FO23,943^GB591,0,1^FS')
	MSCBWRITE('^FO20,905^GB588,0,1^FS')
	MSCBWRITE('^FO21,831^GB588,0,2^FS')
	MSCBWRITE('^FO22,867^GB588,0,1^FS')
	MSCBWRITE('^FO22,798^GB588,0,1^FS')
	MSCBWRITE('^FT26,619^A0N,28,28^FH\^FDPOSICAO:^FS')
	MSCBWRITE('^FO25,752^GB589,0,1^FS')
	MSCBWRITE('^FT396,619^A0N,28,28^FH\^FDPEDIDO:^FS')
	MSCBWRITE('^FT638,825^A0N,28,28^FH\^FDN Fases^FS')
	MSCBWRITE('^FT631,917^A0N,28,28^FH\^FDFrequencia^FS')
	MSCBWRITE('^FT659,778^A0N,28,28^FH\^FD'+ALLTRIM(SB1->B1_XTENSAO)+'^FS')
	MSCBWRITE('^FT665,959^A0N,28,28^FH\^FD'+ALLTRIM(SB1->B1_XFREQNO)+'^FS')
	MSCBWRITE('^FT663,868^A0N,28,28^FH\^FD'+SB1->B1_XFASE+'^FS')
	MSCBWRITE('^FT151,232^A0N,28,28^FH\^FD'+ALLTRIM(SB1->B1_XCODIPN)+'^FS')
	MSCBWRITE('^FT504,228^A0N,28,28^FH\^FD'+ALLTRIM(SC2->C2_PRODUTO)+'^FS')
	MSCBWRITE('^FT151,264^A0N,28,28^FH\^FD'+SUBSTR(SB1->B1_DESC,1,20)+'^FS')
	MSCBWRITE('^FT202,343^A0N,28,28^FH\^FD'+ALLTRIM(SM0->M0_NOMECOM)+'^FS')
	MSCBWRITE('^FT94,375^A0N,28,28^FH\^FD'+SM0->M0_CGC+'^FS')
	MSCBWRITE('^FT240,411^A0N,28,28^FH\^FD'+SB1->B1_XGRPROT+'^FS')
	MSCBWRITE('^FT467,380^A0N,28,28^FH\^FD'+AllTrim(Transform(SB1->B1_XPESOWB,PesqPict("SB1","B1_XRESQDR")))+'kg^FS')
	MSCBWRITE('^FT515,409^A0N,28,28^FH\^FD'+_cSerie+'^FS')
	MSCBWRITE('^FT293,788^A0N,28,28^FH\^FD'+SB1->B1_XILUMIN+'^FS')
	MSCBWRITE('^FT474,788^A0N,28,28^FH\^FD'+SB1->B1_XILUMI2+'^FS')
	_nTotPot += Val(SB1->B1_XILUMIN)
	_nTotA   += Val(SB1->B1_XILUMI2)
	MSCBWRITE('^FT499,618^A0N,28,28^FH\^FD'+ALLTRIM(c_Pedido)+'^FS')
	MSCBWRITE('^FT146,618^A0N,28,28^FH\^FD'+ALLTRIM(c_ItemPv)+'^FS')
	MSCBWRITE('^FT478,514^A0N,28,28^FH\^FD'+SB1->B1_XAGENTE+'^FS')
	MSCBWRITE('^FT603,478^A0N,28,28^FH\^FD'+SB1->B1_XCLASSE+'^FS')
	MSCBWRITE('^FT235,476^A0N,28,28^FH\^FD'+SB1->B1_XGASREF+'^FS')
	MSCBWRITE('^FT108,443^A0N,28,28^FH\^FD'+AllTrim(Transform(SB1->B1_XCARGA,PesqPict("SB1","B1_XCARGA")))+'g^FS')
	MSCBWRITE('^FT621,441^A0N,28,28^FH\^FD'+SB1->B1_XCLISOL+'^FS')
	MSCBWRITE('^FT262,551^A0N,28,28^FH\^FD'+SUBSTR(DTOC(SC2->C2_EMISSAO),4,7)+'^FS')
	MSCBWRITE('^FT295,825^A0N,28,28^FH\^FD'+AllTrim(Transform(SB1->B1_XVENTIL,PesqPict("SB1","B1_XVENTIL")))+'^FS')
	MSCBWRITE('^FT474,825^A0N,28,28^FH\^FD'+AllTrim(Transform(SB1->B1_XVENTIA,PesqPict("SB1","B1_XVENTIA")))+'^FS')
	_nTotPot += VAL(SB1->B1_XVENTIL)
	_nTotA   += Val(SB1->B1_XVENTIA)
	MSCBWRITE('^FT295,859^A0N,28,28^FH\^FD'+AllTrim(Transform(SB1->B1_XRESQDR,PesqPict("SB1","B1_XRESQDR")))+'^FS')
	MSCBWRITE('^FT474,859^A0N,28,28^FH\^FD'+AllTrim(Transform(SB1->B1_XRESQDA,PesqPict("SB1","B1_XRESQDA")))+'^FS')
	_nTotPot += VAL(SB1->B1_XRESQDR)
	_nTotA   += Val(SB1->B1_XRESQDA)
	MSCBWRITE('^FT296,898^A0N,28,28^FH\^FD'+AllTrim(Transform(SB1->B1_XRESPOR,PesqPict("SB1","B1_XRESPOR")))+'^FS')
	MSCBWRITE('^FT474,898^A0N,28,28^FH\^FD'+AllTrim(Transform(SB1->B1_XRESPOA,PesqPict("SB1","B1_XRESPOA")))+'^FS')
	_nTotPot += VAL(SB1->B1_XRESPOR)
	_nTotA   += Val(SB1->B1_XRESPOA)
	MSCBWRITE('^FT295,936^A0N,28,28^FH\^FD'+AllTrim(Transform(SB1->B1_XRESDEG,PesqPict("SB1","B1_XRESDEG")))+'^FS')
	MSCBWRITE('^FT474,936^A0N,28,28^FH\^FD'+AllTrim(Transform(SB1->B1_XRESDEA,PesqPict("SB1","B1_XRESDEA")))+'^FS')
	_nTotPot += VAL(SB1->B1_XRESDEG)
	_nTotA   += Val(SB1->B1_XRESDEA)
	_nTotPot:= AllTrim(Transform(SB1->B1_XPOTENC,PesqPict("SB1","B1_XRESDEG")))
	_nTotA:= AllTrim(Transform(SB1->B1_XCORRNO,PesqPict("SB1","B1_XRESDEG")))
	
	MSCBWRITE('^FT296,976^A0N,28,33^FH\^FD'+_nTotPot+'^FS')
	//MSCBWRITE('^FT474,976^A0N,28,28^FH\^FD'+SB1->B1_XCORRNO+'^FS')
	MSCBWRITE('^FT474,976^A0N,28,28^FH\^FD'+_nTotA+'^FS')
	MSCBWRITE('^PQ1,0,1,Y^XZ')
	
	MSCBEND()
	MSCBCLOSEPRINTER()
	
Endif

RestArea(a_AreaSA1)
RestArea(a_AreaSC6)
RestArea(a_AreaSC5)
RestArea(a_AreaSB1)

Return Nil
