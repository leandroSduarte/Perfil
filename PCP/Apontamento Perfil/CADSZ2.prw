
#INCLUDE "Protheus.ch"
#INCLUDE "RWMAKE.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "Font.ch"
#INCLUDE "FwBrowse.ch"



/*-------------------------------------------------------------------------------------
{Protheus.doc} CADSZ2

@Author  	   Felipe Aguiar - Focus Consultoria
@since		   03/2019
@version	   P12

@description Cadastro de Operadores
---------------------------------------------------------------------------------------
|Author                  | Date       | Description                                    |
|                        |            |                                                |
--------------------------------------------------------------------------------------*/
User Function CADSZ2()

Private cDelFunc	:= "U_VLDPSZ2(5)"
Private cCadastro 	:= "Cadastro de Operadores"

Private aRotina  	:= {{ "Pesquisar"		, "AxPesqui" 	                                                , 0, 1 },;
						{ "Visualizar"		, "AxVisual" 	                                                , 0, 2 },;
						{ "Incluir"			, 'AxInclui("SZ2",               , 3,,,,"U_VLDPSZ2(3)")'        , 0, 3 },;
						{ "Alterar"			, 'AxAltera("SZ2", SZ2->(Recno()), 4,,,,,"U_VLDPSZ2(4)")'       , 0, 4 },;
						{ "Excluir"			, 'AxDeleta("SZ2", SZ2->(Recno()), 5)'                          , 0, 5 }}

MBrowse(,,,,"SZ2",,,,,,)

Return Nil


/*****************************************************************************************/

User Function VLDPSZ2(n_Opc)

Local l_Ret := .T.

//Inclusao
If ( n_Opc == 3 )
	
	If Empty( M->Z2_NOME )
		
		l_Ret := .F.
		MsgStop("Obrigatório o preenchimento do campo 'Nome'.", "Atenção")
		
	EndIf

//Alteracao
ElseIf ( n_Opc == 4 )

	l_Ret := .T.

//Exclusao
ElseIf ( n_Opc == 5 )

    l_Ret := .T.
	
EndIf

Return l_Ret


