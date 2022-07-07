#Include "Protheus.ch"
#Include "TopConn.ch"

/*------------------------------------------------------------------------------------- 
{Protheus.doc} A200GRVE

@Author  	   Felipe Aguiar - Focus Consultoria
@since		   05/2019
@version	   P12

@description PE PARA GRAVAR CODIGO REFERENCIA PARA TROCA DE COR - WBC CAD
---------------------------------------------------------------------------------------
|Author                  | Date       | Description                                    |
|                        |            |                                                |
--------------------------------------------------------------------------------------*/
User Function A200GRVE()
	
Local ExpN1 := ParamIxb[1]
Local ExpL1 := ParamIxb[2]
Local ExpA1 := ParamIxb[3]
Local ExpA2 := ParamIxb[4]
Local cRecnoP := ""// Recno do produto principal adicionado na estrutura
Local a_AreaSG1 := SG1->(GetArea())

If ExpN1 == 3 .OR. ExpN1 == 4 //Inclusão/Alteracao

    If Len(ExpA2) > 0

        For n := 1 TO Len(ExpA2)

            cRecnoP := ExpA2[n][1]

            DbSelectArea("SG1")
            DbGoto(cRecnoP)

            c_Cod := SG1->G1_COMP

            fGetPai(c_Cod)

        Next n 

    EndIf

EndIf


RestArea(a_AreaSG1)

Return Nil

/*********************************************************************************************************************/

Static Function fGetPai(c_Cod)

Local c_query := ""
Local a_AreaSG1 := SG1->(GetArea())

c_query := " WITH ESTRUT( CODIGO, COD_PAI, COD_COMP, QTD, PERDA, DT_INI, DT_FIM, NIVEL ) AS "
c_query += " ( "
c_query += "      SELECT G1_COD PAI, G1_COD, G1_COMP, G1_QUANT, G1_PERDA, G1_INI, G1_FIM, 1 AS NIVEL "
c_query += "        FROM SG1010 SG1 (NOLOCK) "
c_query += "     WHERE SG1.D_E_L_E_T_ = '' "
c_query += "       AND G1_FILIAL      = '"+xFilial("SG1")+"'" 
c_query += ""
c_query += "     UNION ALL "
c_query += ""
c_query += "      SELECT CODIGO, G1_COD, G1_COMP, QTD * G1_QUANT, G1_PERDA, G1_INI, G1_FIM, NIVEL + 1 "
c_query += "        FROM SG1010 SG1 (NOLOCK) "
c_query += "     INNER JOIN ESTRUT EST "
c_query += "        ON G1_COD = COD_COMP "
c_query += "     WHERE SG1.D_E_L_E_T_ =	''"
c_query += "       AND SG1.G1_FILIAL = '" +xFilial("SG1")+"'" 
c_query += ""
c_query += " ) "
c_query += " SELECT CODIGO , SB1_A.B1_DESC AS DESCRI, SB1_A.B1_TIPO AS TIPO , SB1_A.B1_GRUPO AS GRUPO, "
c_query += "       COD_PAI , SB1_B.B1_DESC AS DESC_PAI , SB1_B.B1_TIPO AS TIPO_PAI , SB1_B.B1_GRUPO AS GRUPO_PAI, "
c_query += "       COD_COMP, SB1_C.B1_DESC AS DESC_COMP, SB1_C.B1_TIPO AS TIPO_COMP, SB1_C.B1_GRUPO AS GRUPO_COMP, "
c_query += "       QTD     , PERDA, SB1_C.B1_UM AS UM_COMP, DT_INI, DT_FIM, NIVEL   "     
c_query += " FROM ESTRUT "
c_query += " INNER JOIN SB1010 SB1_A (NOLOCK) "
c_query += "    ON SB1_A.D_E_L_E_T_ = '' "
c_query += "   AND SB1_A.B1_FILIAL = '"+xFilial("SB1")+"'" 
c_query += "   AND SB1_A.B1_COD     = CODIGO "
c_query += "  "
c_query += " INNER JOIN SB1010 SB1_B (NOLOCK)" 
c_query += "    ON SB1_B.D_E_L_E_T_ = '' "
c_query += "   AND SB1_B.B1_FILIAL = '"+xFilial("SB1")+"'"
c_query += "   AND SB1_B.B1_COD     = COD_PAI "
c_query += " "
c_query += " INNER JOIN SB1010 SB1_C (NOLOCK) "
c_query += "    ON SB1_C.D_E_L_E_T_ = '' "
c_query += "   AND SB1_C.B1_FILIAL = '"+xFilial("SB1")+"'"
c_query += "   AND SB1_C.B1_COD     = COD_COMP "
c_query += " WHERE	ESTRUT.CODIGO = '"+c_Cod+"'"


If Select("QRY") > 0 
    QRY->(DbCloseArea())
Endif

TcQuery c_query New Alias "QRY"


DbSelectArea("QRY")
QRY->(DbGotop())

While QRY->(!EOF())

    If ALLTRIM(QRY->COD_COMP) == "000153"
        
        DbSelectArea("SG1")
        DbSetOrder(1) //G1_FILIAL, G1_COD, G1_COMP, G1_TRT, R_E_C_N_O_, D_E_L_E_T_

        If DbSeek(xFilial("SG1")+QRY->COD_PAI+QRY->COD_COMP)

            RECLOCK("SG1", .F.)
            //SG1->G1_XPRODFA := c_Cod
            SG1->G1_PRODFA := c_Cod
            SG1->(MSUNLOCK())
        EndIf

    EndIf

    QRY->(DbSkip())

EndDo        

RestArea(a_AreaSG1)

Return Nil


 