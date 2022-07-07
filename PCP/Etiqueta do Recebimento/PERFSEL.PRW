#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FONT.CH"  
#INCLUDE "RWMAKE.CH"

/*-------------------------------------------------------------------------------------|
|{Protheus.doc} PERFSEL                                                                | 
|                                                                                      | 
|@                                                                                     | 
|@Author  	   Felipe Aguiar - Focus Consultoria                                       | 
|@since		   05/2019                                                                 | 
|@version	   P12                                                                     | 
|                                                                                      | 
|@description Parametros para impressao de Etiquetas do Recebimento                    |
|--------------------------------------------------------------------------------------|
|Author                  | Date       | Description                                    |
|                        |            |                                                |
--------------------------------------------------------------------------------------*/


User Function PERFSEL(nOrig)

Local   oSize
Local   cTitle      	:= "Impressão de Etiquetas"
Local   aButton			:= {}

Private cIniCpos		:= "+"
Private nFreeze      	:= 0
Private nMax         	:= 999
Private cCampoOk     	:= "AllwaysTrue"
Private cLinhaOk 		:= "AllwaysTrue"
Private cSuperApagar 	:= "AllwaysTrue"
Private cApagaOk		:= "AllwaysTrue"
Private cTudoOk 		:= "AllwaysTrue"
Private nOpc 			:= GD_UPDATE
Private	aAltera			:= {"CHECKBOL","X1_QTD"} 
Private aHeader			:= {}
Private aCols			:= {}
Private lChkSel    		:= .T.  
Private oChk
Private nOrigem			:= nOrig

cCadastro := "Selecione itens e Quantidades para impressão das etiquetas"

aCampos01 := {;
		{"D1_COD"    , "X1_COD"    , TamSX3("D1_COD")[1]    , .F., { AllTrim(RetTitle("D1_COD"))     , TamSX3("D1_COD")[3]      , TamSX3("D1_COD")[1]     , TamSX3("D1_COD")[2]     , PesqPict("SD1","D1_COD")        }},;
		{"B1_DESC"   , "X1_DESC"   , 60                     , .F., { AllTrim(RetTitle("B1_DESC"))    , TamSX3("B1_DESC")[3]     , TamSX3("B1_DESC")[1]    , TamSX3("B1_DESC")[2]    , PesqPict("SB1","B1_DESC")       }},;
		{"D1_QUANT"  , "X1_QTD"    , 3                      , .F., { "Quant. Imp."                   , TamSX3("D1_QUANT")[3]    , 3                       , 0                       , "@E 999"                        }},;
		{"DB_DOC"	 , "X1_DOC"    , TamSX3("DB_DOC")[1]    , .F., { AllTrim(RetTitle("DB_DOC"))     , TamSX3("DB_DOC")[3]      , TamSX3("DB_DOC")[1]     , TamSX3("DB_DOC")[2]     , PesqPict("SDB","DB_DOC")        }},;
		{"DB_NUMSERI", "X1_NSER"   , TamSX3("DB_NUMSERI")[1], .F., { AllTrim(RetTitle("DB_NUMSERI")) , TamSX3("DB_NUMSERI")[3]  , TamSX3("DB_NUMSERI")[1] , TamSX3("DB_NUMSERI")[2] , PesqPict("SDB","DB_NUMSERI")    }},;	    
		{"DB_LOTECTL", "X1_NLOT"   , TamSX3("DB_LOTECTL")[1], .F., { AllTrim(RetTitle("DB_LOTECTL")) , TamSX3("DB_LOTECTL")[3]  , TamSX3("DB_LOTECTL")[1] , TamSX3("DB_LOTECTL")[2] , PesqPict("SDB","DB_LOTECTL")    }},;
		{"DB_DATA"	 , "X1_DTREC"  , TamSX3("DB_DATA")[1]   , .F., { AllTrim(RetTitle("DB_DATA"))    , TamSX3("DB_DATA")[3]     , TamSX3("DB_DATA")[1]    , TamSX3("DB_DATA")[2]    , PesqPict("SDB","DB_DATA")       }}}

aHeader := U_fHDR(aCampos01)
aCols   := U_PosCols(aHeader)

If Len(aCols) == 0
	MsgStop("Não existem itens prontos para serem impressos.","Atenção")
	Return Nil
EndIf

oSize := FwDefSize():New( .F. )

If IsInCallStack("MATA103")

	Define MsDialog oDlg Title cTitle From 000,000 To 512,1150 Pixel 
		
		@ 033,007 checkbox oChk var lChkSel PROMPT "Selecionar todos" size 60,07 on CLICK Seleciona(lChkSel)
		
		oGetDados1  := MsNewGetDados():New(046,006,250,575,nOpc,cLinhaOk,cTudoOk,cIniCpos,aAltera,nFreeze,nMax,cCampoOk,cSuperApagar,cApagaOk,oDlg,aHeader,aCols)
		oGetDados1:oBrowse:bLDblClick := {|| IIF( oGetDados1:oBrowse:nColPos == 1  , ( oGetDados1:EditCell(), oGetDados1:aCols[oGetDados1:nAt,1] := iif(oGetDados1:aCols[oGetDados1:nAt,1] == 'LBOK','LBNO','LBOK') ) , IIF( oGetDados1:oBrowse:nColPos == 4 , oGetDados1:EditCell() , Nil ) ) }	

	Activate MsDialog oDlg Centered On Init EnchoiceBar(oDlg,{|| nOpca := 1,lRetTela := fValTela() , IIF(lRetTela == .T., MsAguarde({|| fImpEtq()}, "Gerando impressões. Por favor aguarde..."), Nil)},{|| nOpca := 0, oDlg:End() },, aButton)

Else

	MsAguarde({|| fImpEtq()}, "Gerando impressões. Por favor aguarde...")

EndIf

Return Nil 

/*-------------------------------------------------------------------------------------
{Protheus.doc} fHDR

@Author  	   Focus Consultoria
@since		   03/2019
@version	   P11

@description Função generica para montar Header da NewGetDados
--------------------------------------------------------------------------------------
|Author                  | Date       | Description                                    |
|                        |            |                                                |
--------------------------------------------------------------------------------------*/
User Function fHDR(aCpos)

	Local   aHead := {}          
	Default aCpos := {}            
                                 
    aadd(aHead,{''		  ,'CHECKBOL'     ,'@BMP', 2,0,,	             ,"C",     ,"V",,,'Seleciona','V','S'})
                                     
	DbSelectArea("SX3")                    
	SX3->(DbSetOrder(2))                               
	For nX := 1 to Len(aCpos)
		If SX3->(DbSeek(aCpos[nX,1]))
			nTam   :=  Iif(aCpos[nX,3] <= 0  , SX3->X3_TAMANHO, aCpos[nX,3])
			cValid :=  Iif(aCpos[nX,4] == .T., SX3->X3_VALID, "" )
		                                                            
			If ValType(aCpos[nX,5]) == "A"       
				nTam   :=  Iif(aCpos[nX,3] <= 0, aCpos[nX,5][3], aCpos[nX,3])

				Aadd(aHead, {aCpos[nX,5][1],aCpos[nX][2],aCpos[nX,5][5],nTam,aCpos[nX,5][4],cValid,SX3->X3_USADO,;
				             SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
			Else
				Aadd(aHead, {AllTrim(X3Titulo()),IIf(!Empty(aCpos[nX,2]), aCpos[nX,2], SX3->X3_CAMPO),SX3->X3_PICTURE,nTam,SX3->X3_DECIMAL,cValid,SX3->X3_USADO,;
				             SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
			Endif
		Else                                                                        
			If LEFT(aCpos[nX,1],5) == "XREGS"
				Aadd(aHead, {"Registro",aCpos[nX,1],"",10,0,"","","N","","","",""})
                                        
			ElseIf ValType(aCpos[nX,4]) == "A"
				nTam   :=  Iif(aCpos[nX,3] <= 0, aCpos[nX,5][3], aCpos[nX,3])
				
				Aadd(aHead, {aCpos[nX,4][1], aCpos[nX][1],aCpos[nX,4][5],nTam,aCpos[nX,4][4],"","",aCpos[nX,4][2],"","","",""})
			Endif
		Endif
	Next nX                 

Return(aHead)

/*-------------------------------------------------------------------------------------
{Protheus.doc} PosCols

@Author  	   Focus Consultoria
@since		   03/2019
@version	   P11

@description Função para montar o Array aCols da GetDados
--------------------------------------------------------------------------------------
|Author                  | Date       | Description                                    |
|                        |            |                                                |
--------------------------------------------------------------------------------------*/
User Function PosCols(aHeader)

Local aCols    	:= {}
Local c_Query	:= ""

nPosChk	 := aScan(aHeader, {|x| AllTrim(x[2])  == "CHECKBOL"	})
nPosPrd  := aScan(aHeader, {|x| AllTrim(x[2])  == "X1_COD"	    })
nPosDes  := aScan(aHeader, {|x| AllTrim(x[2])  == "X1_DESC"	    })
nPosQtd  := aScan(aHeader, {|x| AllTrim(x[2])  == "X1_QTD"	    })
nPosDoc  := aScan(aHeader, {|x| AllTrim(x[2])  == "X1_DOC"	    })
nPosNSr  := aScan(aHeader, {|x| AllTrim(x[2])  == "X1_NSER"	    })
nPosNlt  := aScan(aHeader, {|x| AllTrim(x[2])  == "X1_NLOT"	    })
nPosDtR  := aScan(aHeader, {|x| AllTrim(x[2])  == "X1_DTREC"	})

//Se a origem for pelo Documento de Entrada
If nOrigem == 1

	c_Query := " SELECT	D1.D1_COD AS 'PRODUTO', B1.B1_DESC AS 'DESC', D1_DOC AS 'DOC', '' AS 'NUMSERI', D1_LOTECTL AS 'LOTE', 0 AS 'QTD', D1_EMISSAO AS 'DATAREC' "
	c_Query += " FROM "	+ RetSqlName("SD1")+"(NOLOCK) D1 "
	c_Query += " INNER JOIN "	+ RetSqlName("SB1")+"(NOLOCK) B1 " 
	c_Query += " 	ON	D1.D1_COD = B1.B1_COD "
	c_Query += " 	AND B1.D_E_L_E_T_ = '' "
	c_Query += " WHERE	D1_FILIAL = '"+ xFilial("SD1") +"' "
	c_Query += " AND		D1_DOC = '"+ SF1->F1_DOC +"' "
	c_Query += " AND		D1_SERIE = '"+SF1->F1_SERIE+"' "
	c_Query += " AND		D1_FORNECE = '"+SF1->F1_FORNECE+"' "
	c_Query += " AND		D1_LOJA = '"+SF1->F1_LOJA+"' "
	c_Query += " AND		D1.D_E_L_E_T_ = ''"
	
//Se a origem for pelo Endereçamento - deve estar já endereçado [ saldo = 0]
ElseIf nOrigem == 2

	c_Query := " SELECT	DB.DB_PRODUTO AS 'PRODUTO', B1.B1_DESC AS 'DESC', DB_DOC AS 'DOC' , DB_NUMSERI AS 'NUMSERI' , DB_LOTECTL AS 'LOTE', 1 AS 'QTD', DB_DATA AS 'DATAREC' "
	c_Query += " FROM "	+ RetSqlName("SDB")+"(NOLOCK) DB "
	c_Query += " INNER JOIN "	+ RetSqlName("SB1")+"(NOLOCK) B1 " 
	c_Query += " 	ON	DB.DB_PRODUTO = B1.B1_COD "
	c_Query += " 	AND B1.D_E_L_E_T_ = '' "
	c_Query += " WHERE	DB_FILIAL = '"+ xFilial("SDB") +"' "
	c_Query += " AND		DB_DOC = '"+ SDA->DA_DOC +"' "
	c_Query += " AND		DB_SERIE = '"+SDA->DA_SERIE+"' "
	c_Query += " AND		DB_CLIFOR = '"+SDA->DA_CLIFOR+"' "
	c_Query += " AND		DB_LOJA = '"+SDA->DA_LOJA+"' "
	c_Query += " AND		DB_PRODUTO = '"+SDA->DA_PRODUTO+"' "
	c_Query += " AND		DB_ESTORNO = ''"
	c_Query += " AND		DB.D_E_L_E_T_ = ''"

EndIf

If Select("QRY") > 0 
	QRY->(DbCloseArea())
Endif

TcQuery c_Query New Alias "QRY"

i := 1

DbSelectArea("QRY")
QRY->(DbGoTop())

While QRY->(!Eof())
	
	AAdd(aCols, Array(Len(aHeader)+1))
		
	aCols[i][nPosChk]  := 'LBOK'
	aCols[i][nPosPrd]  := QRY->PRODUTO
	aCols[i][nPosDes]  := QRY->DESC
	aCols[i][nPosQtd]  := QRY->QTD 
	aCols[i][nPosDoc]  := QRY->DOC
	aCols[i][nPosNSr]  := QRY->NUMSERI
	aCols[i][nPosNlt]  := QRY->LOTE
	aCols[i][nPosDtR]  := DTOC(STOD(QRY->DATAREC))

	aCols[i][Len(aHeader)+1] := .F.

	i++     
	
	QRY->(DbSkip())

EndDo

Return aCols

/************************************************************/
Static Function Seleciona(lChkSel)

For i := 1 to Len(oGetDados1:aCols)
	If lChkSel
		oGetDados1:aCOLS[i,1] := 'LBOK'                                               
	Else
		oGetDados1:aCOLS[i,1] := 'LBNO'
	Endif	
Next     

oGetDados1:oBrowse:Refresh() 
oDlg:Refresh()

Return Nil

/**********************************************************************/
Static Function fValTela()

Local l_Ok 		:= .T.
Local l_Mark	:= 0
Local a_AreaSB1	:= SB1->(GetArea())

nPosChk	 := aScan(aHeader, {|x| AllTrim(x[2])  == "CHECKBOL"	})
nPosPrd  := aScan(aHeader, {|x| AllTrim(x[2])  == "X1_COD"	    })
nPosQtd  := aScan(aHeader, {|x| AllTrim(x[2])  == "X1_QTD"	    })


If IsInCallStack("MATA103")

	For n_Lin:= 1 To Len(oGetDados1:aCols)
		
		If oGetDados1:aCols[n_Lin,nPosChk] == 'LBOK'		
			
			l_Mark++ 
	
			If oGetDados1:aCols[n_Lin,nPosQtd] == 0
				MsgStop("Digite a quantidade para gerar impressão!", "ATENÇÃO")
				l_Ok := .F.
				Exit
			EndIf		
				
			DbSelectArea("SB1")
			DbSetOrder(1)
			
			If DbSeek(xFilial("SB1")+oGetDados1:aCols[n_Lin,nPosPrd])
			
				If SB1->B1_LOCALIZ == "S"
					MsgStop("O produto [ "+ ALLTRIM(oGetDados1:aCols[n_Lin,nPosPrd])+" ] possui controle de numero de série,"+CHR(13)+CHR(10);
							+"portanto a impressão da etiqueta deverá ser feita pela rotina de Enderaçamento."+CHR(13)+CHR(10);
							+"Desmarque este item para impressão dos demais.", "Atenção")
					l_Ok := .F.
					Exit
				EndIf
			
			EndIf 
					
		EndIf	

	Next n_Lin	

EndIf

If IsInCallStack("MATA103")
	If l_Mark == 0
		MsgStop("Marque ao menos um item para gerar impressão!", "ATENÇÃO")
		l_Ok := .F.
	EndIf
EndIf

RestArea(a_AreaSB1)

Return l_Ok

/**********************************************************************************************************/
Static Function fImpEtq()

nPosChk	 := aScan(aHeader, {|x| AllTrim(x[2])  == "CHECKBOL"	})
nPosPrd  := aScan(aHeader, {|x| AllTrim(x[2])  == "X1_COD"	    })
nPosQtd  := aScan(aHeader, {|x| AllTrim(x[2])  == "X1_QTD"	    })
nPosDoc  := aScan(aHeader, {|x| AllTrim(x[2])  == "X1_DOC"	    })
nPosNSr  := aScan(aHeader, {|x| AllTrim(x[2])  == "X1_NSER"	    })
nPosNlt  := aScan(aHeader, {|x| AllTrim(x[2])  == "X1_NLOT"	    })
nPosDtR  := aScan(aHeader, {|x| AllTrim(x[2])  == "X1_DTREC"	})

If IsInCallStack("MATA103") 
	aCols := oGetDados1:aCols
EndIf

For n_Lin:= 1 To Len(aCols)
	
    If aCols[n_Lin,nPosChk] == 'LBOK'	

       U_PERETREC(	aCols[n_Lin,nPosPrd],;
	   				+aCols[n_Lin,nPosQtd],;
					+aCols[n_Lin,nPosDoc],;
					+aCols[n_Lin,nPosNSr],;
					+aCols[n_Lin,nPosNlt],;
					+aCols[n_Lin,nPosDtR])
    EndIf	

Next n_Lin

Return Nil


/*-------------------------------------------------------------------------------------|
|{Protheus.doc} PERETREC                                                               | 
|                                                                                      | 
|@                                                                                     | 
|@Author  	   Felipe Aguiar - Focus Consultoria                                       | 
|@since		   05/2019                                                                 | 
|@version	   P12                                                                     | 
|                                                                                      | 
|@description Impressao de Etiqueta de Recebimento                                     |
|--------------------------------------------------------------------------------------|
|Author                  | Date       | Description                                    |
|                        |            |                                                |
--------------------------------------------------------------------------------------*/

User Function PERETREC(cProd,nQtd,c_NFiscal,c_NumSeri,c_Lote,c_DtReceb)

Local c_DescProd	:= GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+cProd,1,"")
Local c_Desc1Lin	:= Left(c_DescProd,31)
Local c_Desc2Lin	:= SubStr(c_DescProd,32,40)        
Local cPorta		:= "LPT1"

Default nQtd 		:= 1

If !IsPrinter(cPorta)
	
	Aviso("Impressora","Porta "+cPorta+" não encontrada. Por favor, verifique as configurações para utilizar esta rotina. ",{"OK"})
	
	Return Nil 

Endif

//MSCBloadGrf("logo2.pcx") 

MSCBPRINTER("ZEBRA",cPorta,,173,.F.,,,,,,.T.,)
MSCBCHKSTATUS(.T.)
MSCBBEGIN(nQtd,4)				 // Qtd de impressoes , Velocidade de impressao
MSCBBOX(003,003,097,120,006) //box contorno etiqueta

//MSCBGRAFIC(088,005,"logo2")

MSCBSAY(088,040,"PERFIL REFRIGERAÇÃO COMÉRCIO" ,"R","0","030,023")
MSCBSAY(083,060," E " ,"R","0","030,023")
MSCBSAY(077,050,"SERVIÇOS LTDA" ,"R","0","030,023")


MSCBLineV(073,003,120,006)  
MSCBSAY(065,006,"CÓDIGO PRODUTO: " 	,"R","0","030,023")
MSCBSAY(065,043, ALLTRIM(cProd) 	,"R","0","030,023")

MSCBLineV(063,003,120,006)
MSCBSAY(055,006,"DESCRIÇÃO: " 	,"R","0","030,023")      
MSCBSAY(055,043, c_Desc1Lin 	,"R","0","030,023") 

MSCBLineV(053,003,120,006)  
MSCBSAY(045,006,'NUM. SERIE: '  	,"R","0","030,023")
MSCBSAY(045,043, ALLTRIM(c_NumSeri) ,"R","0","030,023")


MSCBLineV(043,003,120,006)  
MSCBSAY(035,006,'NOTA FISCAL: '   	,"R","0","030,023")
MSCBSAY(035,043, ALLTRIM(c_NFiscal) ,"R","0","030,023")

    
MSCBSAY(035,066,'DATA RECEB.: ' 					 ,"R","0","030,023")
MSCBSAY(035,096, ALLTRIM(DTOC(STOD(c_DtReceb)))		 ,"R","0","030,023")
MSCBSAY(045,066,'       LOTE: ' 		        	 ,"R","0","030,023")
MSCBSAY(045,096, ALLTRIM(c_Lote)  	 				 ,"R","0","030,023")

MSCBLineH(033,063,053,006)
MSCBLineH(033,093,053,006)

MSCBLineV(033,003,120,006)  
MSCBSAY(018,006,'CÓD. BARRAS: ',"R","0","030,023")
MSCBSAYBAR(015,062, ALLTRIM(cProd) ,"R","C",10,.F.,.T.,.F.,,2,4,.F.) 

MSCBLineH(003,040,073,006)    

MSCBEND()
MSCBCLOSEPRINTER()

Return Nil

