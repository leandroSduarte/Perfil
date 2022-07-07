#Include "Protheus.ch"
#Include "TopConn.ch"

User Function EMP650()

Local cProdPai  := Substr(PARAMIXB[1],1,15) 
Local cProdFant := "" 
Local cProdEst  := Substr(PARAMIXB[1],16,15)  
Local cCodCor   := "" 
Local cQry      := ""
Local cCodPad   := ALLTRIM(GetMV("MV_XCORPAD", .F., "000153"))

/*****************************************************************  

cProdPai  => Produto Principal -> Gerado na integração WBC CAD
cProdFant => Produto Fantasma que contem a cor na integração
cProdEst  => Produto que empenha a cor 
cCodCor   => Codigo da cor que será buscada para a troca 
cCodPad   => Codigo da cor padrão, utilizada em todas as estruturas

******************************************************************/


For nI := 1 to len(aCols)
	
	If ALLTRIM(aCols[nI][nPosCod]) == cCodPad
		//cProdFant := GetAdvFVal("SG1","G1_XPRODFA", xFilial("SG1")+cProdEst+aCols[nI,nPosCod],1,"")
        cProdFant := GetAdvFVal("SG1","G1_PRODFA", xFilial("SG1")+cProdEst+aCols[nI,nPosCod],1,"")
	
        If !Empty(cProdFant)

            //BUsco na tabela de integracao com o WBC CAD, qual a cor que deve ser empenhada
            cQry  := " SELECT   TOP(1) * "
            cQry  += " FROM	"+RetSqlName("SZ5")+"(NOLOCK)"
            cQry  += " WHERE	Z5_CODPA = '" +cProdPai+ "'"   
            cQry  += " AND		Z5_CODFIL = '" +cProdFant+ "'"
            cQry  += " AND		D_E_L_E_T_ = ''"
        
            If Select("QRY") > 0 
                QRY->(DbCloseArea())
            Endif

            TcQuery cQry New Alias "QRY"
       
            cCodCor := QRY->Z5_COR

            If !Empty(cCodCor)
                aCols[nI][nPosCod] := cCodCor
            Endif

        EndIf
       
    Endif

Next nI

Return Nil
