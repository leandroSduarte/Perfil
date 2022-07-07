#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FONT.CH"  
#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MA415BUT  �Autor  �Vinicius Belini     � Data �  10/12/2019 ���
���Programa  �          �       �Delta Decisao       �      �             ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de entrada utilizado para adiconar opcao em Outras    ���
���          �Acoes na tela de Orcamento. O usuario ira acionalo para     ���  
���          �alterar o status do Orcamento para Pedido Perdido.          ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 12.1.17 - Equipe de Vendas/Orcamento              ���
���Usuario   � Gabriel Carvalho/Vendas                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MA415MNU ()

Local aAreaAtu     := GetArea()
          

Aadd(aRotina,{"Perdido", "U_AjStatus",0,1,0,NIL})
RestArea(aAreaAtu)                                    

Return(aRotina)



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AjStatus  �Autor  �Vinicius Belini     � Data �  10/12/2019 ���
���Programa  �          �       �Delta Decisao       �      �             ���
�������������������������������������������������������������������������͹��
���Desc.     �Fonte utilizado para o ajuste do campo STATUS               ���
�������������������������������������������������������������������������͹��
���Uso       � Protheus 12.1.17 - Equipe de Vendas/Orcamento              ���
���Usuario   � Gabriel Carvalho/Vendas                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function AjStatus()
                     
      
If MsgYesNo("O or�amento ser� alterado para Perdido, confirma?","Aten��o")      
	RecLock("SCJ",.F.)
	SCJ->CJ_STATUS :=	"P"
	MsUnlock()
Endif

	
Return()