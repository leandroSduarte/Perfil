User function M410VIS()

Local cQuery1   := "" 
Local cQuery2   := "" 
Local cQuery3   := ""  
Local nLinha    := 1
Local cPedido  := M->C5_NUM   
Local nxQtdLib := aScan(aHeader, {|x| AllTrim(x[2])=="C6_XQTDLIB"}) 
Local nItem    := aScan(aHeader, {|x| AllTrim(x[2])=="C6_ITEM"})
Local cItem    := GdFieldGet("C6_ITEM")
Local cQtdLib  := 0
Local aArea    := GetArea()
         
For i := 1 to len(aCols)		                      	
		cQuery2 := " select C9_PEDIDO, C9_ITEM, sum(C9_QTDLIB) as C9_QTDLIBC9_PEDIDO,C9_ITEM, C9_PRODUTO,SUM(C9_QTDLIB) AS C9_QTDLIB from " + RetSqlName("SC9")+ " where C9_FILIAL = '" + xFilial("SC9") + "' and C9_PEDIDO = '"+ SC5->C5_NUM +"' and C9_ITEM = '"+ aCols[i][1] + "' AND D_E_L_E_T_ = ' ' group by  C9_PEDIDO, C9_ITEM, C9_PRODUTO "
		cQuery2 := ChangeQuery(cQuery2)
   		DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery2),"QRYSC9",.F.,.T.) 
   		
   		dbSelectArea("QRYSC9")
		QRYSC9->(dbGotop())
		
		While QRYSC9->(!Eof())
			
			If QRYSC9->C9_QTDLIB > 0 
			   	  
						dbSelectArea("SC6")
						dbSetOrder(1)
						dbSeek(xFilial("SC6")+QRYSC9->C9_PEDIDO+QRYSC9->C9_ITEM+QRYSC9->C9_PRODUTO)
						If Found()
   					   		Reclock("SC6",.F.)
      				   		SC6->C6_XQTDLIB :=   QRYSC9->C9_QTDLIB 
      				   	
      				   		
      				   		MsUnlock()    
      				   		
      				   		aCols[i][10] := QRYSC9->C9_QTDLIB  
     			
      				   		
      				   	EndIf	
   			EndIf   		

			
			QRYSC9->(DBSkip())
			nLinha++
   		Enddo      
   		QRYSC9->(DBCloseArea()) 
   		

   		
Next i
   		

RestArea(aArea)
return()         

