#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

User Function PRFGAT001()

Local cQuery, cQuery1    := "" 
Local cPedido  := M->C5_NUM   
Local nItem    := aScan(aHeader, {|x| AllTrim(x[2])=="C6_ITEM"})
Local cItem    := GdFieldGet("C6_ITEM")
Local cQtdLib  := 0
Local aArea    := GetArea()

cQuery := " select sum(C9_QTDLIB) AS C9_QTDLIB from " + RetSqlName("SC9")+ " where C9_FILIAL = '" + xFilial("SC9") + "' and C9_PEDIDO = '"+ cPedido +"' AND C9_ITEM = '" + cItem + "' and D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRYSC9",.F.,.T.)

dbSelectArea("QRYSC9")
QRYSC9->(dbGotop())

While QRYSC9->(!Eof())
	
	cQtdLib := QRYSC9->C9_QTDLIB
	                   

	QRYSC9->(DBSkip())
	
Enddo

QRYSC9->(DBCloseArea())
RestArea(aArea)    

Return(cQtdLib)


