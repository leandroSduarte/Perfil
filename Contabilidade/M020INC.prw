#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'

/*____________________________________________________________________________
��������������������������������������������������������������������������������
��+--------------------------------------------------------------------------+��
���Programa  � M020INC    � Autor �  Marcio Gois      �  Data  � 30/10/18    ���
��+----------+---------------------------------------------------------------���
���Descricao � PE no cadastro de Fornecedor para cadastrar a Classe Valor    ���
��+----------+---------------------------------------------------------------���
���Uso       � Perfil         										         ���
��+----------+---------------------------------------------------------------���
��������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
User Function M020INC()   

Local aArea		:= GetArea()
Local cCLVL, cDesc01 := ""
Local cClasse := "2"
Local cNormal := "0"
Local cBloq   := "2"
Local dDTExis := CTOD("01/01/1980")

// Cadastro de Fornecedor
// Campo CTH_CLVL = Dever� ser preenchido com "F"+A2_COD+A2_LOJA, onde �F� � fixo, A2_COD � o c�digo do Fornecedor e a A2_LOJA � a loja do Fornecedor.
// Campo CTH_DESC01 = Dever� ser preenchido com o campo A2_NREDUZ, onde o A2_NREDUZ � o nome reduzido do Fornecedor.

cCLVL	:= Padr("F"+SA2->(A2_COD+A2_LOJA),11)
cDesc01 := SA2->A2_NREDUZ

u_UPCADCTH(cCLVL, cDesc01, cClasse, cNormal, cBloq, dDTExis)

RestArea(aArea)

Return nil
