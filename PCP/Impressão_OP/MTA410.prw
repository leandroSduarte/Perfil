#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"
#Include "RWMAKE.CH"
#Include "MSOLE.CH"
#Include "TbiConn.ch"

/*���������������������������������������������������������������������������������
�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������Ŀ��
���Programa  � MTA410   � Autor � Victor		              � Data � 30/01/19 ���
�������������������������������������������������������������������������������Ĵ��
���Descricao � Rotina para mostrar valor do pedido de Venda				        ���
�������������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum.                                                          ���
�������������������������������������������������������������������������������Ĵ��
���Retorno   � Nil.                                                             ���
�������������������������������������������������������������������������������Ĵ��
���Analista Resp.�  Data  � Manutencao Efetuada                                 ���
�������������������������������������������������������������������������������Ĵ��
���              �        �                                                     ���
��������������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������������
���������������������������������������������������������������������������������*/

User Function MTA410()
	
Local nTotal  := 0                             
Local cdsema  := space(2)
Local nValor  := Ascan(aHeader,{|x|Alltrim(X[2])=="C6_VALOR"}) //busca a posi��o do campo C6_VALOR      
Local nposent := Ascan(aHeader,{|x|Alltrim(X[2])=="C6_ENTREG"}) //busca a posi��o do campo C6_ENTREG
Local dtprog  := M->C5_XDTPROG
Local _lrefresh := .f.


//peccore os itens de venda para somar o valor
For nI:=1 To Len(aCols)
     //verifica se a linha n�o esta deletada
     If !aCols[nI][Len(aHeader)+1]
          nTotal := nTotal + aCols[nI][nValor]     
     EndIf
Next nI

//Grava na mem�ria do campo o total
M->C5_XTOTAL := nTotal       

//altera o campo C6_ENTREG com a data digitada no campo C5_XDTPROG - Edson Rodrigues - 01/03/19
If Altera .and. !Empty(dtprog)            
   u_altdtprg(_lrefresh)               
Endif  
Return .T. 


//altera o campo C6_ENTREG com a data digitada no campo C5_XDTPROG - Edson Rodrigues - 01/03/19
User Function altdtprg(_lrefresh)
   Local nposent := Ascan(aHeader,{|x|Alltrim(X[2])=="C6_ENTREG"}) //busca a posi��o do campo C6_ENTREG
   Local dtprog  := M->C5_XDTPROG
    

   For nI:=1 To Len(aCols) 
		     
		     If !aCols[nI][Len(aHeader)+1] //verifica se a linha n�o esta deletada
		          aCols[nI][nposent] := dtprog
		     EndIf
   Next nI
   M->C5_XNUMSEM := PADL(retsem(dtprog),2,"0")      
   
   If _lrefresh
      oGetDad:oBrowse:Refresh() 
      oGetDad:Refresh() 
   Endif

   
return .t.