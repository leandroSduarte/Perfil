#Include 'rwmake.ch'
#Include "protheus.ch"
#Include 'parmtype.ch'
#Include "APVT100.CH"
#Include 'topconn.ch'
#Include "tbiconn.ch"
#Include "TOTVS.CH"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PERFCOL01  ³ Autor ³ Flavio Valentin           ³ Data ³ 01/02/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Este programa realiza o apontamento de OP a partir da leitura    ³±±
±±³          ³ do codigo de barras.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Perfil Refrigeracao.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Manutencao Efetuada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function PERFCOL01()

Local _aArea		:= GetArea()
Local _aButtons		:= {} 
Local _aItems   	:= {'T=Total','P=Parcial'}
Local _aSH6			:= {}
Private _oDlgCol	:= Nil
Private _nOpc		:= 0
Private _cNumOP		:= Space(TAMSX3("H6_OP")[1])
Private _cCodOper	:= Space(TAMSX3("H6_OPERAC")[1])
Private _cCodProd	:= Space(TAMSX3("H6_PRODUTO")[1])
Private _cDescPro	:= Space(TAMSX3("B1_DESC")[1])
Private _cRecurs	:= Space(TAMSX3("H6_RECURSO")[1])
Private _cNRecur	:= Space(30)
Private _dtApont	:= ddatabase 
Private _dDtInic 	:= ddatabase 
Private _dDtFin 	:= ddatabase 
Private _cHrInic	:= Left(Time(),5) 
Private _cHrFin		:= Left(Time(),5) 
Private _nQtApon	:= 0 
Private _nQtPerda	:= 0 
Private _cOperador	:= Space(TAMSX3("H6_OPERADO")[1])
Private _cArmaz		:= Space(TAMSX3("H6_LOCAL")[1])
Private _cParcTot	:= Space(TAMSX3("H6_PT")[1])
Private _cRoteiro	:= ""

Define MSDialog _oDlgCol Title "Apontamento da Ordem de Produção" From 00,00 To 250,1020 Of _oDlgCol Pixel

@ 38,10 Say AllTrim(RetTitle("H6_OP")) Size 45,8 Pixel Of _oDlgCol //Ordem de Producao
@ 38,50 MSGet _cNumOP F3 "SC2TMP" Picture "@!" VALID FVLDINF(1) Size 70,10 Pixel Of _oDlgCol

@ 38,140 Say AllTrim(RetTitle("H6_PRODUTO")) Size 45,8 Pixel Of _oDlgCol //Produto
@ 38,175 MSGet _cCodProd F3 "SB1" Picture "@!" VALID FVLDINF(2) Size 80,10 Pixel Of _oDlgCol

@ 38,290 Say "Descr.Produto" Size 45,8 Pixel Of _oDlgCol //Descricao do Produto
@ 38,330 MSGet _cDescPro Picture "@!" Size 170,10 Pixel Of _oDlgCol When .F.

@ 52,10  Say AllTrim(RetTitle("H6_OPERAC")) Size 45,8 Pixel Of _oDlgCol //Operacao
@ 52,51 MSGet _cCodOper Picture "@!" Valid NaoVazio() Size 20,10 Pixel Of _oDlgCol

@ 52,140 Say AllTrim(RetTitle("H6_RECURSO")) Size 45,8 Pixel Of _oDlgCol //Recurso
@ 52,175 MSGet _cRecurs  F3 "SH1" Picture "@!" VALID FVLDINF(3) Size 20,10 Pixel Of _oDlgCol

@ 52,290 Say "Descr.Recurso" Size 45,8 Pixel Of _oDlgCol
@ 52,330 MSGet _cNRecur  Picture "@!" Size 170,10 Pixel Of _oDlgCol When .F.

@ 66,10 Say AllTrim(RetTitle("H6_DATAINI"))  Size 45,8 Pixel Of _oDlgCol
@ 66,50 MSGet _dDtInic Picture "@!" Size 50,10 Pixel Of _oDlgCol

@ 66,140 Say AllTrim(RetTitle("H6_HORAINI")) Size 45,8 Pixel Of _oDlgCol
@ 66,175 MSGet _cHrInic Picture "99:99" Size 25,10 Pixel Of _oDlgCol 

@ 66,290 Say AllTrim(RetTitle("H6_DATAFIN")) Size 45,8 Pixel Of _oDlgCol
@ 66,330 MSGet _dDtFin Picture "@!" Size 50,10 Pixel Of _oDlgCol 

@ 66,440 Say AllTrim(RetTitle("H6_HORAFIN")) Size 45,8 Pixel Of _oDlgCol
@ 66,470 MSGet _cHrFin Picture "99:99" Size 25,10 Pixel Of _oDlgCol 

@ 80,10 Say AllTrim(RetTitle("H6_QTDPROD")) Size 45,8 Pixel Of _oDlgCol
@ 80,50 MSGet _nQtApon Picture "@E 99,999,999.99" Size 65,9 Pixel Of _oDlgCol 

@ 80,140 Say AllTrim(RetTitle("H6_QTDPERD")) Size 45,8 Pixel Of _oDlgCol
@ 80,175 MSGet _nQtPerda Picture "@E 99,999,999.99" Size 65,9 Pixel Of _oDlgCol 

@ 80,290 Say AllTrim(RetTitle("H6_PT")) Size 45,8 Pixel Of _oDlgCol   
_oCombo1 := TComboBox():New(80,330,{|u|if(PCount()>0,_cParcTot:=u,_cParcTot)},_aItems,50,14,_oDlgCol,,{||},,,,.T.,,,,,,,,,'cCombo1')

@ 80,410 Say AllTrim(RetTitle("H6_DTAPONT")) Size 45,8 Pixel Of _oDlgCol
@ 80,450 MSGet _dtApont Picture "@!" Size 50,10 Pixel Of _oDlgCol 

@ 94,10 Say AllTrim(RetTitle("H6_OPERADO")) Size 45,8 Pixel Of _oDlgCol
@ 94,50 MSGet _cOperador Picture "@!" Size 70,10 Pixel Of _oDlgCol 

@ 94,140 Say AllTrim(RetTitle("H6_LOCAL")) Size 45,8 Pixel Of _oDlgCol
@ 94,175 MSGet _cArmaz Picture "@!" Size 30,10 Pixel Of _oDlgCol When .F.

Activate MSDialog _oDlgCol On Init EnchoiceBar(_oDlgCol,{ || If(FVLDCPOS(),(_nOpc:=1,_oDlgCol:End()),_nOpc:=0)},{ || _nOpc:=0,_oDlgCol:End()},,a_Botao )

If (_nOpc == 1)
	aAdd(_aSH6,{"H6_OP"			,_cNumOP	,Nil})
	aAdd(_aSH6,{"H6_PRODUTO"	,_cCodProd	,Nil})
	aAdd(_aSH6,{"H6_OPERAC"		,_cCodOper	,Nil})
	aAdd(_aSH6,{"H6_RECURSO"	,_cRecurs	,Nil})
	aAdd(_aSH6,{"H6_DATAINI"	,_dDtInic	,Nil}) 
	aAdd(_aSH6,{"H6_HORAINI"	,_cHrInic	,Nil})
	aAdd(_aSH6,{"H6_DATAFIN"	,_dDtFin	,Nil}) 
	aAdd(_aSH6,{"H6_HORAFIN"	,_cHrFin	,Nil})
	aAdd(_aSH6,{"H6_QTDPROD"	,_nQtApon	,Nil})
	If (_nQtPerda<>0)
		aAdd(_aSH6,{"H6_QTDPERD",_nQtPerda	,Nil})
	EndIf
	aAdd(_aSH6,{"H6_PT"			,_cParcTot	,Nil})
	aAdd(_aSH6,{"H6_DTAPONT"	,_dtApont	,Nil})
	aAdd(_aSH6,{"H6_OPERADO"	,_cOperador	,Nil})
	aAdd(_aSH6,{"H6_LOCAL"		,_cArmaz	,Nil})
	
	If Len(_aSH6) > 0
		lMsErroAuto := .F.
		//Apontamento de Producao baseado no Roteiro de Operacoes 
		MSExecAuto({|x| mata681(x)},_aSH6)  // inclusao
		If (lMsErroAuto)
			Mostraerro()
		Else
			MsgInfo("Apontamento realizado com sucesso!")
		EndIf           
	EndIf
EndIf

RestArea(_aArea)

Return
  

/*/ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FVLDINF   ºAutor  | Flavio Valentin    º Data ³  01/02/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que valida os campos.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Perfil Refrigeracao.                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function FVLDINF(_nCpo)

Local _aArea 	:= GetArea()

If (_nCpo == 1)
	If Empty(_cNumOP)
		Help(" ",1,"INCONSISTENCIA",,"ORDEM DE PRODUCAO NAO INFORMADA.",4,1)
		Return(.F.)
	EndIf
	dbSelectArea("SC2")
	dbSetOrder(1)//C2_FILIAL, C2_NUM, C2_ITEM, C2_SEQUEN, C2_ITEMGRD, R_E_C_N_O_, D_E_L_E_T_
	If SC2->(MSSeek(xFilial("SC2")+_cNumOP))
		_cRoteiro := SC2->C2_ROTEIRO
	Else
		Help(" ",1,"INCONSISTENCIA",,"ORDEM DE PRODUCAO NAO ENCONTRADA.",4,1)
		Return(.F.)
	EndIf
	dbSelectArea("SC2")
	dbSetOrder(1)//C2_FILIAL, C2_NUM, C2_ITEM, C2_SEQUEN, C2_ITEMGRD, R_E_C_N_O_, D_E_L_E_T_
	If SC2->(MSSeek(xFilial("SC2")+_cNumOP))
		If !Empty(SC2->C2_DATRF)
			Help(" ",1,"INCONSISTENCIA",,"ORDEM DE PRODUCAO ENCERRADA.",4,1)
			Return(.F.)
		EndIf
	EndIf
ElseIf (_nCpo == 2)
	dbSelectArea("SB1")
	dbSetOrder(1)//B1_FILIAL, B1_COD, R_E_C_N_O_, D_E_L_E_T_
	If SB1->(MSSeek(xFilial("SB1")+_cCodProd))
		If (SB1->B1_MSBLQL<>"1")
			_cDescPro := AllTrim(SB1->B1_COD)
			_cRoteiro := Iif(!Empty(_cRoteiro),_cRoteiro,SB1->B1_OPERPAD)
		Else
			Help(" ",1,"INCONSISTENCIA",,"PRODUTO BLOQUEADO.",4,1)
			Return(.F.)
		EndIf
	Else
		Help(" ",1,"INCONSISTENCIA",,"PRODUTO NAO LOCALIZADO.",4,1)
		Return(.F.)
	EndIf
ElseIf (_nCpo == 3)
	If Empty(_cRecurs)
		Help(" ",1,"INCONSISTENCIA",,AllTrim(RetTitle("H6_RECURSO"))+" NAO INFORMADO.",4,1)
		Return(.F.)
	EndIf
	dbSelectArea("SH1")
	dbSetOrder(1)//H1_FILIAL, H1_CODIGO, R_E_C_N_O_, D_E_L_E_T_
	If SH1->(MSSeek(xFilial("SH1")+_cRecurs))
		_cNRecur := AllTrim(SH1->H1_DESCRI)
	Else
		Help(" ",1,"INCONSISTENCIA",,AllTrim(RetTitle("H6_RECURSO"))+" NAO INFORMADO.",4,1)
		Return(.F.)
	EndIf
EndIf

RestArea(_aArea)           

Return(.T.)


/*/ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FVLDCPOS  ºAutor  | Flavio Valentin    º Data ³  01/02/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que valida os campos.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Perfil Refrigeracao.                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function FVLDCPOS()

Local _aArea 	:= GetArea()
Local _lVldOper	:= (GetMV("MV_VLDOPER") == "S") 

If Empty(_cNumOP)
	Help(" ",1,"INCONSISTENCIA",,"ORDEM DE PRODUCAO NAO INFORMADA.",4,1)
	Return(.F.)
EndIf

dbSelectArea("SC2")
dbSetOrder(1)//C2_FILIAL, C2_NUM, C2_ITEM, C2_SEQUEN, C2_ITEMGRD, R_E_C_N_O_, D_E_L_E_T_
If SC2->(MSSeek(xFilial("SC2")+_cNumOP))
	_cRoteiro := SC2->C2_ROTEIRO
Else
	Help(" ",1,"INCONSISTENCIA",,"ORDEM DE PRODUCAO NAO ENCONTRADA.",4,1)
	Return(.F.)
EndIf

dbSelectArea("SC2")
dbSetOrder(1)//C2_FILIAL, C2_NUM, C2_ITEM, C2_SEQUEN, C2_ITEMGRD, R_E_C_N_O_, D_E_L_E_T_
If SC2->(MSSeek(xFilial("SC2")+_cNumOP))
	If !Empty(SC2->C2_DATRF)
		Help(" ",1,"INCONSISTENCIA",,"ORDEM DE PRODUCAO ENCERRADA.",4,1)
		Return(.F.)
	EndIf
EndIf

If Empty(_cCodOper)
	Help(" ",1,"INCONSISTENCIA",,AllTrim(RetTitle("H6_OPERAC"))+" NAO INFORMADO.",4,1)
	Return(.F.)
EndIf

If Empty(_cCodProd)
	Help(" ",1,"INCONSISTENCIA",,"PRODUTO NAO INFORMADO.",4,1)
	Return(.F.)
EndIf

dbSelectArea("SB1")
dbSetOrder(1)//B1_FILIAL, B1_COD, R_E_C_N_O_, D_E_L_E_T_
If SB1->(MSSeek(xFilial("SB1")+_cCodProd))
	If (SB1->B1_MSBLQL="1")
		Help(" ",1,"INCONSISTENCIA",,"PRODUTO BLOQUEADO.",4,1)
		Return(.F.)
	EndIf
Else
	Help(" ",1,"INCONSISTENCIA",,"PRODUTO NAO LOCALIZADO.",4,1)
	Return(.F.)
EndIf

If Empty(_cRecurs)
	Help(" ",1,"INCONSISTENCIA",,AllTrim(RetTitle("H6_RECURSO"))+" NAO INFORMADO.",4,1)
	Return(.F.)
EndIf

dbSelectArea("SH1")
dbSetOrder(1)//H1_FILIAL, H1_CODIGO, R_E_C_N_O_, D_E_L_E_T_
If !SH1->(MSSeek(xFilial("SH1")+_cRecurs))
	Help(" ",1,"INCONSISTENCIA",,AllTrim(RetTitle("H6_RECURSO"))+" NAO LOCALIZADO.",4,1)
	Return(.F.)
EndIf

If !a630SeekSG2(1,_cCodProd,xFilial("SG2")+_cCodProd+_cRoteiro+_cCodOper)
	If (_lVldOper)
		Help(' ',1,'OPERACAO')
		Return(.F.)
	EndIf
EndIf

If (_nQtApon==0)
	Help(" ",1,"INCONSISTENCIA",,AllTrim(RetTitle("H6_QTDPROD"))+" NAO INFORMADO.",4,1)
	Return(.F.)
EndIf

If Empty(_cParcTot)
	Help(" ",1,"INCONSISTENCIA",,AllTrim(RetTitle("H6_PT"))+" NAO INFORMADO.",4,1)
	Return(.F.)
EndIf

RestArea(_aArea)

Return(.T.)