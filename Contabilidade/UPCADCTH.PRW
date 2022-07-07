#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'

/*____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+--------------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ UPCADCTH   ¦ Autor ¦  Marcio Gois      ¦  Data  ¦ 30/10/18    ¦¦¦
¦¦+----------+---------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Cadastro da Classe Valor                                      ¦¦¦
¦¦+----------+---------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Perfil         										         ¦¦¦
¦¦+----------+---------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function UPCADCTH(cCLVL, cDesc01, cClasse, cNormal, cBloq, dDTExis)
                           
dbSelectArea("CTH")
dbSetOrder(2) //CTH_FILIAL+CTH_CLASSE+CTH_CLVL
If !CTH->(dbSeek(xFilial("CTH")+cClasse+cCLVL))
	Reclock("CTH", .T.)
	CTH->CTH_FILIAL := xFilial("CTH")
	CTH->CTH_CLVL   := cCLVL
	CTH->CTH_CLASSE := cClasse
	CTH->CTH_NORMAL := cNormal
	CTH->CTH_DESC01 := cDesc01
	CTH->CTH_BLOQ   := cBloq
	CTH->CTH_DTEXIS := dDTExis
	CTH->(msUnlock())
Endif

Return
