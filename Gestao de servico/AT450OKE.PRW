

//-------------------------------------------------------------------
/*/{Protheus.doc} AT450OKE
VALIDAÇÃO EFETIVAÇÃO DA OS PARA GERAR PEDIDO DE VENDA

@author JÚNIOR CONTE - DELTA SISTEMAS
@since 26/04/21
/*/
//-------------------------------------------------------------------

USER FUNCTION AT450OKE 
LRET :=  .T. 
IF ! EMPTY(AB6->AB6_XNUMPV)
    LRET :=  .F. 
    ALERT("Não permitido gerar mais de um pedido de venda para uma OS.")
ENDIF


RETURN  LRET
