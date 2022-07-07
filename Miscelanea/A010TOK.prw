#INCLUDE "Rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} A010TOK
Função A010TOK
Validação para inclusão ou alteração do Produto.
@author Delta
@version Protheus 12
@since 19/10/2021
/*/

User function A010TOK()

lRetorno := .T.

if altera .and. M->B1_PRV1  > 0
        
        dbSelectArea("DA1")
		dbSetOrder(1)
		if  dbSeek(xFilial("DA1") + padr("001" , tamsx3("DA1_CODTAB")[1]) + M->B1_COD )
			
			RecLock("DA1",.F.)
			 	DA1->DA1_PRCVEN :=  M->B1_PRV1 
			MsUnlock()

		endif

endif

if inclui .and. M->B1_PRV1 > 0 

//ALERT(M->B1_COD)

        /*
	    dbSelectArea("DA1")
		dbSetOrder(1)
		if ! dbSeek(xFilial("DA1") + padr("001" , tamsx3("DA1_CODTAB")[1]) + M->B1_COD )
			
			RecLock("DA1",.T.)

			 //	DA1->DA1_PRCVEN :=   nPreco +  ( nPreco * SBM->BM_XINDPRC )   / 100

			MsUnlock()

		endif

        */

        cQuery := " SELECT  TOP 1 DA1_ITEM " 
        cQuery += "  FROM "+RetSqlName("DA1")+" "
        cQuery += "  WHERE DA1_FILIAL = '"+ xFilial("DA1") +"' "
        cQuery += "    AND DA1_CODTAB = '001' "
        cQuery += " 	AND D_E_L_E_T_ = ' ' "
        cQuery += "    ORDER BY  DA1_ITEM DESC "
        
        TcQuery cQuery New Alias "TMP1"     
        nItem  := Val(TMP1->DA1_ITEM)
        TMP1->(dbCloseArea())                                        
                        
        Begin Transaction				 	
				
            nItem += 1	
            //
            //GRAVAÇÃO DO DA1
            //

            dbSelectArea("DA0")
            dbSetOrder(1)
            if dbSeek( xFilial("DA0")  +   padr("001" , tamsx3("DA1_CODTAB")[1])   )                
                
                DbSelectArea("DA1")	                                
                RecLock("DA1",.T.)
                    DA1->DA1_FILIAL		:= xFilial("DA1")
                    DA1->DA1_ITEM		:= StrZero(nItem,4)
                    DA1->DA1_CODTAB		:= '001'
                    DA1->DA1_TIPPRE		:= '1'
                    DA1->DA1_CODPRO		:= M->B1_COD
                    DA1->DA1_PRCVEN		:= M->B1_PRV1
                    DA1->DA1_ATIVO		:= "1"
                    DA1->DA1_TPOPER		:= "4"
                    DA1->DA1_MOEDA		:= 1
                    DA1->DA1_DATVIG		:= dDataBase                    
                    DA1->DA1_QTDLOT		:= 999999.99
                    DA1->DA1_INDLOT		:= StrZero(999999.99,18,2)
                MsUnLock()
            ENDIF
								
		End Transaction 

endif

Return lRetorno
