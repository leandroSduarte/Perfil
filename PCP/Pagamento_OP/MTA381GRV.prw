#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥ MTA381GRV ≥ Autor ≥ Edson Estevam              ≥ Data ≥ 21/01/19 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ O ponto de entrada para devolver saldo de produtos para ArmazÈm  ≥±±
±±≥            de Origem quando o processo for estorno de empenhos gerados pela ≥±±
±±≥            Rotina de Pagamento de OP                                        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ Nenhum.                                                          ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥ Nil.                                                             ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Analista Resp.≥  Data  ≥ Edson Estevam                                       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥              ≥        ≥                                                     ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹*/
User Function MTA381GRV()

Local aArea    := GetArea()
Local ExpL1:= PARAMIXB[1]  // Inclus„o
Local ExpL2:= PARAMIXB[2]  // AlteraÁ„o
Local ExpL3:= PARAMIXB[3]  // Exclus„o
Local _cArmProd := Alltrim(GetMV("MV_XLOCPRO"))
Local _cEndProd := PADR(GETMV("MV_XENDPRO"),TamSX3("BF_LOCALIZ")[1])
Local aItem		:= {}
Local aAuto		:= {}
Local _cDoc      := ""
Local _cProd   := ""
Local _cDescri := ""
Local _cUM := ""
Local _cLocal  := ""
Local _cLocaliz := ""
Local _cLocDest := ""
Local _cNumSeri := ""
Local _cLote := ""
Local _cNumLot := ""
Local _dDataVl := ""
Local _cOp := ""
Local _cOpOrig := ""
Local _cTrt   := ""
Local cOPTra	:= ""
Local _nQuant := 0
Local nSaldo := 0

If ExpL3
	
	nPOscProd   := aScan(aHeader,{|x| AllTrim(x[2]) == "D4_COD"})
	nPoscLocal  := aScan(aHeader,{|x| AllTrim(x[2]) == "D4_LOCAL"})
	nPoscLote   := aScan(aHeader,{|x| AllTrim(x[2]) == "D4_LOTECTL"})
	nPoscNumLot := aScan(aHeader,{|x| AllTrim(x[2]) == "D4_NUMLOTE"})
	nPOsdDataVl := aScan(aHeader,{|x| AllTrim(x[2]) == "D4_DTVALID"})
	nPosnQuant  := aScan(aHeader,{|x| AllTrim(x[2]) == "D4_QUANT"})
	nPoscTrt    := aScan(aHeader,{|x| AllTrim(x[2]) == "D4_TRT"})
	nPosOpOrig  := aScan(aHeader,{|x| AllTrim(x[2]) == "D4_OPORIG"}) 
	
	For i := 1 To Len(aCols)
		_cLocal  := aCols[i][nPosLocal]
		
		If _cLocal $ _cArmProd
			
			If (aCols[i,Len(aHeader)+1])
				
				DbSelectArea("SB2")
				DbSeek(xFilial("SB2")+aCols[i][nPOscProd]+_cLocal)
				nSaldo := SaldoSB2()
				If nSaldo >= aCols[i][nPosnQuant] 
					_cProd   := aCols[i][nPOscProd]
					_cLote   := aCols[i][nPoscLote]
					_cNumLot := aCols[i][nPoscNumLot]
					_dDataVl := aCols[i][nPOsdDataVl]
					_cOp     := cOp
					_cTrt    := aCols[i][nPoscTrt]
					_nQuant  := aCols[i][nPosnQuant]
					_cOpOrig := aCols[i][nPosOpOrig]
					//Realiza a TransferÍncia de ArmazÈm para itens deletados.
					
					DbSelectArea("SZ1")
					DbSetOrder(1) // Z1_FILIAL, Z1_COD, Z1_OP, Z1_TRT, Z1_LOTECTL, Z1_NUMLOTE, R_E_C_N_O_, D_E_L_E_T_
					If Dbseek(xFilial("SZ1")+_cProd+_cOp+_cTrt+_cLote+_cNumLot)
						_cLocDest := SZ1->Z1_LOCAL
					Else
						MsgAlert("N„o Identificado o Destino na SZ1")
					Endif
					
					DbSelectArea("SB1")
					DbSetOrder(1)
					Dbseek(xFilial("SB1")+_cProd)
					cDescri := SB1->B1_DESC
					_cUM     := SB1->B1_UM
					
					If SB1->B1_LOCALIZ = "S"
						
						// Busca as informaÁıes do Empenho inicial
						cQuery:=" SELECT * " + CRLF
						cQuery+=" FROM " + RetSQLName("SDC") + " SDC  " + CRLF
						cQuery+=" WHERE SDC.D_E_L_E_T_ <> '*'  " + CRLF
						cQuery+="  AND DC_FILIAL = '"+xFilial("SDC")+"' " + CRLF
						cQuery+="  AND DC_OP = '"+_cOp+"' " + CRLF
						cQuery+="  AND DC_PRODUTO = '"+_cProd+"' " + CRLF
						cQuery+="  AND DC_LOCAL = '01' " + CRLF // ArmazÈm de Origem
						cQuery+="  AND DC_LOTECTL = '"+_cLote+"' " + CRLF
						
						If Select("TMP") > 0
							TMP->(dbCloseArea())
						EndIf
						
						TcQuery cQuery new alias "TMP"
						dbSelectArea("TMP")
						TMP->(dbGotop())
						
						_cLocaliz := TMP->DC_LOCALIZ // EndereÁo de Origem
						_cLocDest := TMP->DC_LOCAL   // Local de Origem
						_cNumSeri := TMP->DC_NUMSERI // SÈrie de Origem
						
					Else
						
						_cLocDest = SB1->B1_LOCPAD
						
					Endif
					
					_cDoc		:= GetSxENum("SD3","D3_DOC")
					CONFIRMSX8()
					
					If Len(aAuto) == 0
						aAdd(aAuto, {_cDoc, dDataBase} )
					EndIf
					
					// Localizacao Destino
					If Empty(_cLocaliz)
						_cLocaliz := Criavar('DC_LOCALIZ')
					EndIf
					
					If Empty(_cEndProd)
						_cEndAtu  := Criavar('DC_LOCALIZ')
					Endif
					
					aAdd(aItem,{"D3_COD"		,_cProd					,Nil})	//D3_COD ORIGEM ***
					aAdd(aItem,{"D3_DESCRI"		,_cDescri				,Nil})	//D3_DESCRI ORIGEM
					aAdd(aItem,{"D3_UM"			,_cUM					,Nil})	//D3_UM ORIGEM
					aAdd(aItem,{"D3_LOCAL"		,_cLocal				,Nil})	//D3_Local ORIGEM
					aAdd(aItem,{"D3_LOCALIZ"	,_cEndProd				,Nil})	//D3_LocalIZ ORIGEM
					aAdd(aItem,{"D3_COD"		,_cProd					,Nil})	//D3_COD DESTINO ***
					aAdd(aItem,{"D3_DESCRI"		,_cDescri				,Nil})	//D3_DESCRI DESTINO
					aAdd(aItem,{"D3_UM"			,_cUM					,Nil})	//D3_UM DESTIBNO
					aAdd(aItem,{"D3_LOCAL"		,_cLocDest				,Nil})	//D3_Local DESTINO
					aAdd(aItem,{"D3_LOCALIZ"	,_cLocaliz				,Nil})	//D3_LocalIZ DESTINO
					aAdd(aItem,{"D3_NUMSERI"	,_cNumSeri				,Nil})	//D3_NUMSERI
					aAdd(aItem,{"D3_LOTECTL"	,_cLote					,Nil})	//D3_LOTECTL
					aAdd(aItem,{"D3_NUMLOTE"	,_cNumLot				,Nil})	//D3_NUMLOTE
					aAdd(aItem,{"D3_DTVALID"	,_dDataVl				,Nil})	//D3_DTVALID
					aAdd(aItem,{"D3_POTENCI"	,Criavar("D3_POTENCI")	,Nil})	//D3_POTENCI
					aAdd(aItem,{"D3_QUANT"		,_nQuant					,Nil})	//D3_QUANT
					aAdd(aItem,{"D3_QTSEGUM"	,Criavar("D3_QTSEGUM")	,Nil})	//D3_QTSEGUM
					aAdd(aItem,{"D3_ESTORNO"	,Criavar("D3_ESTORNO")	,Nil})  //D3_ESTORNO
					aAdd(aItem,{"D3_NUMSEQ"		,Criavar("D3_NUMSEQ")	,Nil})  //D3_NUMSEQ
					aAdd(aItem,{"D3_LOTECTL"	,Criavar("D3_LOTECTL")	,Nil}) 	//D3_LOTECTL   - cLote
					aAdd(aItem,{"D3_DTVALID"	,_dDataVl				,Nil})	//D3_DTVALID
					aAdd(aItem,{"D3_ITEMGRD"	,Criavar("D3_ITEMGRD")	,Nil})	//D3_ITEMGRD
					aAdd(aItem,{"D3_OBS"		,Criavar("D3_OBS")		,Nil})	//D3_OBS
					//aAdd(aItem,{"D3_OPTRA"		,_cOPTra					,Nil})	//D3_OPTRA
					aAdd(aAuto,aItem)
					aItem := {}
					
					Conout("Linha de Transferencia")
					Conout(_cProd)
					Conout(_cDescri)
					Conout(_cUM)
					Conout(_cLocal)
					Conout(_cLocaliz)
					Conout(_cArmProd)
					Conout(_cLocDest)
					Conout(_cNumSeri)
					Conout(_cNumLot)
					Conout(_nQuant)
					Conout(_dDataVl)
					
					If Len(aAuto) > 0
						lMsErroAuto := .F.
						MSExecAuto( { |x,y| mata261(x,y) }, aAuto, 3)
						If (lMsErroAuto)
							MostraErro()
							_lRet := .F.
						Else
							_cDoc  := Soma1(_cDoc,TamSX3("D3_DOC")[1])
							aAuto := {}
							_lRet  := .T.
						EndIf
						If _lRet // Atualiza empenho no Arm de Destino no estorno
							
							//Inclui Empenho
							GravaEmp(_cProd,;  //-- 01.C¢digo do Produto
							_cLocDest,;    //-- 02.Local
							_nQuant,;   //-- 03.Quantidade
							_nQuant,;  //-- 04.Quantidade
							_cLote,;  //-- 05.Lote
							Nil,;  //-- 06.SubLote
							_cLocaliz,;  //-- 07.Localizaá∆o
							_cNumSeri,; //-- 08.Numero de SÇrie
							_cOp,;         //-- 09.OP
							Nil,;         //-- 10.Seq. do Empenho/Liberaá∆o do PV (Pedido de Venda)
							Nil,;      //-- 11.PV
							NIL,;         //-- 12.Item do PV
							NIl,;       //-- 13.Origem do Empenho
							_cOpOrig,;         //-- 14.OP Original
							dDatabase,;         //-- 15.Data da Entrega do Empenho
							NIl,;    //-- 16.Array para Travamento de arquivos
							.F. ,;     //-- 17.Estorna Empenho?
							Nil,;         //-- 18.ê chamada da Projeá∆o de Estoques?
							.T.,;         //-- 19.Empenha no SB2?
							.T.,;         //-- 20.Grava SD4?
							.F.,;         //-- 21.Considera Lotes Vencidos?
							.T.,;         //-- 22.Empenha no SB8/SBF?
							.T.)          //-- 23.Cria SDC?
							
						Endif
						
					EndIf
				Endif
			EndIf
			
		Endif
	Next i
Endif

RestArea(aArea)

Return
