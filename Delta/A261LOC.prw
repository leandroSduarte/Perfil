#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  A261LOC    �Autor  �J�nior Conte            Data � 08/09/2021���
�������������������������������������������������������������������������͹��
���Desc.     � //trasnferencia mod 2                                      ���
���          � //                                                         ���
�������������������������������������������������������������������������͹��
���Uso       � Perfil                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


User function A261LOC()


Local CPROD     := PARAMIXB[1]
Local CLOC      := PARAMIXB[2]
Local NOPC      := PARAMIXB[3]

//aCols[nLinha,nPosLOCOri]



//alert("criando armazem")
IF NOPC == 2
    dbSelectArea("NNR")
    dbSetOrder(1)
    If !dbSeek(xFilial("NNR")+ ALLTRIM(  CLOC  ) )
    
            Reclock("NNR", .T. )
                    NNR->NNR_FILIAL := xFilial("NNR")
                    NNR->NNR_CODIGO := ALLTRIM( CLOC )
                    NNR->NNR_DESCRI := "Armazem " +  ALLTRIM( CLOC )
                    NNR->NNR_TIPO   := "1"
                    NNR->NNR_ANP45  := .F. 
            MsUnLock()
                    
    EndIf

    dbSelectArea("SB2")
    dbSetOrder(1)
    if !dbSeek(xFilial("SB2") +  CPROD + ALLTRIM( CLOC  ) )
        CriaSB2( CPROD  ,CLOC  )
    endif
ENDIF


Return

