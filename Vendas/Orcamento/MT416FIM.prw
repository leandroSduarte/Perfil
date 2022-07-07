#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

//------------------------------------------------------------------------------------//
//Empresa...: PERFIL REFRIGERACAO
//Funcao....: MT416FIM
//Autor.....: FELIPE LIMA DE AGUIAR 
//Data......: 27/12/19
//Uso.......: 
//Descricao.: P.E. efetivacao do orcamento
//Versao....: 
//------------------------------------------------------------------------------------//

User Function MT416FIM()

    RecLock("SC5", .F.)
    SC5->C5_VEND1     := CJ_XVENDED 
    SC5->C5_XSEGMEN   := CJ_XSEGMEN 
    SC5->(MsUnlock())

Return Nil
