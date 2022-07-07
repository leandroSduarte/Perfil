#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'

/*____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+--------------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ M030INC    ¦ Autor ¦  Marcio Gois      ¦  Data  ¦ 30/10/18    ¦¦¦
¦¦+----------+---------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ PE no cadastro de Cliente para cadastrar a Classe Valor       ¦¦¦
¦¦+----------+---------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Perfil         						     					 ¦¦¦
¦¦+----------+---------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function M030INC()   

Local aArea		:= GetArea()
Local cCLVL, cDesc01 := ""
Local cClasse := "2"
Local cNormal := "0"
Local cBloq   := "2"
Local dDTExis := CTOD("01/01/1980")

// Cadastro de Cliente
// Campo CTH_CLVL = Deverá ser preenchido com "C"+A1_COD+A1_LOJA, onde “C” é fixo, A1_COD é o código do Cliente e a A1_LOJA é a loja do Cliente.
// Campo CTH_DESC01 = Deverá ser preenchido com o campo A1_NREDUZ, onde o A1_NREDUZ é o nome reduzido do Cliente.

cCLVL	:= Padr("C"+SA1->(A1_COD+A1_LOJA),11)
cDesc01 := SA1->A1_NREDUZ

u_UPCADCTH(cCLVL, cDesc01, cClasse, cNormal, cBloq, dDTExis)

RestArea(aArea)

Return .T.
