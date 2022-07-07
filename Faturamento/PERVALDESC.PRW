
// VALIDAÇÃO DA DIGITAÇÃO DO CAMPO AB5_XDESC
USER FUNCTION PERVALDESC
LRET := .T. 

IF M->AB3_DESC1 > 0 .AND.  M->AB5_XDESC > 0
    LRET := .F. 
    ALERT("Percentual de desconto informado no cabeçalho do orçamento.")
ENDIF

//validação cadastro usuarios x desconto

//alert(cUserName)
//alert(upper(cUserName))
dbSelectArea("ZB1")
dbSetOrder(1)
IF dbSeek( xFilial("ZB1") +  alltrim( cUserName ))
    If M->AB5_XDESC > ZB1->ZB1_PER
        LRET := .F. 
        ALERT("Desconto acima do valor permitido.")
    ENDIF

    IF M->AB3_DESC1 > ZB1->ZB1_PER
         LRET := .F. 
        ALERT("Desconto acima do valor permitido.")
    ENDIF
else
    LRET := .F. 
    ALERT("Usuário sem permissão para incluir desconto.")
endif

RETURN LRET


// VALIDAÇÃO DA DIGITAÇÃO DO CAMPO AB5_XDESC
USER FUNCTION PERVALAB3
LRET := .T. 


//validação cadastro usuarios x desconto

//alert(cUserName)
//alert(upper(cUserName))
dbSelectArea("ZB1")
dbSetOrder(1)
IF dbSeek( xFilial("ZB1") +  alltrim( cUserName ))
    IF M->AB3_DESC1 > ZB1->ZB1_PER
         LRET := .F. 
        ALERT("Desconto acima do valor permitido.")
    ENDIF
else
    LRET := .F. 
    ALERT("Usuário sem permissão para incluir desconto.")
endif

RETURN LRET

// VALIDAÇÃO DA DIGITAÇÃO DO CAMPO AB5_VUNIT
USER FUNCTION PERVUNIT(NPRCUNIT)
LRET := .T. 

//ALERT(NPRCUNIT)

IF M->AB3_DESC1 > 0 .OR.  M->AB5_XDESC > 0
    
    LRET := .F. 
    ALERT("Percentual de desconto informado no orçamento.")
    RETURN .F. 

ENDIF

//validação cadastro usuarios x desconto
dbSelectArea("ZB1")
dbSetOrder(1)
IF dbSeek( xFilial("ZB1") +  alltrim( cUserName ))

    NPRCLISTA :=  aCols[n][GDFieldPos("AB5_PRCLIS")]
   // NPRCUNIT  :=  aCols[n][GDFieldPos("AB5_VUNIT")]

    
    NPERC     :=  ( ( NPRCLISTA  - NPRCUNIT ) / NPRCLISTA ) * 100  
    
    If NPERC > ZB1->ZB1_PER
        LRET := .F.        
        ALERT("Desconto acima do valor permitido.")
        RETURN .F. 
    ENDIF
    
else
    
    LRET := .F. 
    ALERT("Usuário sem permissão para incluir desconto.")

     RETURN .F. 

endif

RETURN LRET

// VALIDAÇÃO DA DIGITAÇÃO DO CAMPO AB5_VUNIT
USER FUNCTION PERVTOTAL(nquant, ntotal,  nplist )
LRET := .T. 

IF M->AB3_DESC1 > 0 .OR.  M->AB5_XDESC > 0
    
    LRET := .F. 
    ALERT("Percentual de desconto informado no orçamento.")
    RETURN .F. 

ENDIF

//validação cadastro usuarios x desconto
dbSelectArea("ZB1")
dbSetOrder(1)
IF dbSeek( xFilial("ZB1") +  alltrim( cUserName )) 

   nquant  :=  aCols[n][GDFieldPos("AB5_QUANT")]
   // ntotal  :=  aCols[n][GDFieldPos("AB5_TOTAL")]
    nplist  :=  aCols[n][GDFieldPos("AB5_PRCLIS")]
     
    NUNIT  := 0
    NUNIT  :=  (  ntotal  /  nquant  )
    NPERC  :=  ( (nplist - NUNIT ) / nplist ) * 100   

    
    If NPERC > ZB1->ZB1_PER
        LRET := .F. 
        ALERT("Desconto acima do valor permitido.")
        RETURN  .F. 
    ENDIF
    
else
    
    LRET := .F. 
    ALERT("Usuário sem permissão para incluir desconto.")
    RETURN  .F. 

endif

RETURN LRET

// CALCULA O PERCENTUAL DE DESCONTO NO  VALOR UNITARIO
USER FUNCTION CALCDESU(NPLIST, NVUNIT)
NPERDESC :=    0

NPERDESC :=   ( ( (NPLIST - NVUNIT )  * 100 )  /  NPLIST   )

RETURN  NPERDESC

// CALCULA O PERCENTUAL DE DESCONTO NO  VALOR TOTAL 
USER FUNCTION CALCDTOT(NPLIST, NTOTAL, NQUANT)
NPERDESC  := 0
NVUNIT    := 0
NVUNIT    := ( NTOTAL /  NQUANT)

NPERDESC :=   ( ( (NPLIST - NVUNIT )  * 100 )  /  NPLIST   )

RETURN  NPERDESC


