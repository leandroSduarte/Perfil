#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | DDMAXI14 �Autor  � Gabriel Ver�ssimo  � Data �  10/12/19   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina de Cadastro de Status de Execu��o	                  ���
�������������������������������������������������������������������������͹��
���Uso       � Perfil	                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function DDMAXI14()

	Local lRet := .T.
	Local aArea := GetArea()

	Private oBrowse
	Private cChaveAux 	:= ""
	Private nOpc		:= 0

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SZG")
	oBrowse:SetDescription("Cadastro de Status de Execu��o")
	//oBrowse:DisableDetails()
	oBrowse:Activate()

	RestArea(aArea)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | MenuDef  �Autor  � Gabriel Ver�ssimo  � Data �  10/12/19   ���
�������������������������������������������������������������������������͹��
���Desc.     � MenuDef da Rotina                                          ���
�������������������������������������������������������������������������͹��
���Uso       � Perfil                                              		  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE "Pesquisar"  					ACTION 'PesqBrw' 	 	  	OPERATION 1 	ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" 					ACTION "VIEWDEF.DDMAXI14" 	OPERATION 2 	ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    					ACTION "VIEWDEF.DDMAXI14" 	OPERATION 3 	ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    					ACTION "VIEWDEF.DDMAXI14" 	OPERATION 4 	ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    					ACTION "VIEWDEF.DDMAXI14" 	OPERATION 5 	ACCESS 0
//	ADD OPTION aRotina TITLE "Imprimir" 					ACTION "VIEWDEF.DDMAXI14" 	OPERATION 8 	ACCESS 0
	ADD OPTION aRotina TITLE "Copiar" 						ACTION "VIEWDEF.DDMAXI14" 	OPERATION 9 	ACCESS 0
	ADD OPTION aRotina TITLE "Integra��o Maxview"			ACTION "u_DDMAX14X" 	  	OPERATION 9 	ACCESS 0
	ADD OPTION aRotina TITLE "Integra��o Maxview Todos" 	ACTION "u_DDMAX14Z" 		OPERATION 10 	ACCESS 0

Return aRotina

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | ViewDef  �Autor  � Gabriel Ver�ssimo  � Data �  10/12/19   ���
�������������������������������������������������������������������������͹��
���Desc.     � View da Rotina                                             ���
�������������������������������������������������������������������������͹��
���Uso       � Perfil                                              		  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef()
	Local oView
	Local oModel 	:= ModelDef()
	Local oStr1		:= FWFormStruct(2, 'SZG')

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados ser� utiliZGdo
	oView:SetModel(oModel)

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField('Formulario' , oStr1,'CamposSZG' )

	//Remove os campos que n�o ir�o aparecer	
	//oStr1:RemoveField( 'X5_DESCENG' )
	//oStr1:RemoveField( 'X5_DESCSPA' )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'PAI', 100)

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView('Formulario','PAI')
	oView:EnableTitleView('Formulario' , 'Cadastro de Status de Execu��o' )	
	oView:SetViewProperty('Formulario' , 'SETCOLUMNSEPARATOR', {10})

	//For�a o fechamento da janela na confirma��o
	oView:SetCloseOnOk({||.T.})

Return oView

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | ModelDef �Autor  � Gabriel Ver�ssimo  � Data �  10/12/19   ���
�������������������������������������������������������������������������͹��
���Desc.     � Model da Rotina                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Perfil                                              		  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()
	Local oModel
	Local oStr1:= FWFormStruct( 1, 'SZG', /*bAvalCampo*/,/*lViewUsado*/ ) // Constru��o de uma estrutura de dados

	//Cria o objeto do Modelo de Dados
	//Irie usar uma fun��o MVC001V que ser� acionada quando eu clicar no bot�o "Confirmar"
	oModel := MPFormModel():New('MVC014', /*bPreValidacao*/, { | oModel | MVC001V( oModel ) } , /*{ | oMdl | MVC001C( oMdl ) }*/ ,, /*bCancel*/ )
	oModel:SetDescription('Cadastro de Status de Execu��o')

	//Abaixo irei iniciar o campo X5_TABELA com o conteudo da sub-tabela
	//oStr1:SetProperty('X5_TABELA' , MODEL_FIELD_INIT,{||'21'} )

	//Abaixo irei bloquear/liberar os campos para edi��o
	//oStr1:SetProperty('X5_TABELA' , MODEL_FIELD_WHEN,{|| .F. })

	//Podemos usar as fun��es INCLUI ou ALTERA
	//oStr1:SetProperty('X5_CHAVE'  , MODEL_FIELD_WHEN,{|| INCLUI })

	//Ou usar a propriedade GetOperation que captura a opera��o que est� sendo executada
	//oStr1:SetProperty("X5_CHAVE"  , MODEL_FIELD_WHEN,{|oModel| oModel:GetOperation()== 3 })

	//oStr1:RemoveField( 'X5_DESCENG' )
	//oStr1:RemoveField( 'X5_DESCSPA' )
	//oStr1:RemoveField( 'X5_FILIAL' )

	// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
	oModel:addFields('CamposSZG',,oStr1,{|oModel| MVC001T(oModel)},,)

	//Define a chave primaria utiliZGda pelo modelo
	oModel:SetPrimaryKey({'ZG_FILIAL', 'ZG_COD' })

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:getModel('CamposSZG'):SetDescription('TabelaSZG')

Return oModel

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | MVC001T  �Autor  � Gabriel Ver�ssimo  � Data �  10/12/19   ���
�������������������������������������������������������������������������͹��
���Desc.     � Model da Rotina                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Perfil                                              		  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MVC001T( oModel )
	Local lRet      := .T.
	Local oModelSZG := oModel:GetModel( 'CamposSZG' )

	//cChaveAux := SZG->X5_CHAVE

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | MVC001V  �Autor  � Gabriel Ver�ssimo  � Data �  10/12/19   ���
�������������������������������������������������������������������������͹��
���Desc.     � Model da Rotina                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Perfil                                              		  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MVC001V( oModel )
	Local lRet      := .T.
	Local oModelSZG := oModel:GetModel( 'CamposSZG' )
	//Local nOpc      := oModel:GetOperation()
	Local aArea     := GetArea()

	nOpc      := oModel:GetOperation()

	//Capturar o conteudo dos campos
	//Local cChave	:= oModelSZG:GetValue('X5_CHAVE')
	//Local cTabela	:= oModelSZG:GetValue('X5_TABELA')
	//Local cDescri	:= oModelSZG:GetValue('X5_DESCRI')

	Begin Transaction

		If nOpc == 3 .or. nOpc == 4
			/*
			If Empty(cTabela)
			oModelSZG:SetValue('X5_TABELA','21')
			EndIf

			dbSelectArea("SZG")
			SZG->(dbSetOrder(1))
			SZG->(dbGoTop())
			If(SZG->(dbSeek(xFilial("SZG")+cTabela+cChave)))
			If cChaveAux != cChave
			SFCMsgErro("A chave "+Alltrim(cChave)+" ja foi informada!","MVC001")
			lRet := .F.
			EndIf
			EndIf

			If Empty(cChave)
			SFCMsgErro("O campo chave � obrigat�rio!","MVC001")
			lRet := .F.
			EndIf

			If Empty(cDescri)
			SFCMsgErro("O campo descri��o � obrigat�rio!","MVC001")
			lRet := .F.
			EndIf
			*/
		EndIf

		If !lRet
			DisarmTransaction()
		EndIf

	End Transaction

	RestArea(aArea)

	FwModelActive( oModel, .T. )

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | DDMAXI5X �Autor  � Gabriel Ver�ssimo  � Data �  10/12/19   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina de integra��o do Mobile                             ���
�������������������������������������������������������������������������͹��
���Uso       � Perfil                                              		  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function DDMAX14X(lMensagem, lDel)

	Local c_Url			:= ""
	Local n_TimeOut		:= 120
	Local a_HeadOut		:= {}
	Local c_HeadRet		:= ""
	Local s_PostRet		:= ""
	Local c_Error		:= ""
	Local c_Warning		:= ""
	Local o_Xml			:= Nil
	Local c_Errors		:= ""
	Local c_key			:= AllTrim(SuperGetMV("MV_XCHTASK",.F.,"",Nil))

	Local lDesen := GetNewPar("MV_XAPIDEV",.T.)
	Local cTabUmov := ""

	Default lMensagem 	:= .T.
	Default	lDel		:= .F.

	if lDesen
		cTabUmovPrev := "322668"
		cTabUmovCorr := "320904"
	else
		cTabUmovPrev := "325292"
		cTabUmovCorr := "270922"
	endif

	If ValType(lMensagem) <> "L"
		lMensagem := .T.
	EndIf
	
	If ValType(lDel) <> "L"
		lDel := .F.
	EndIf

	aAdd(a_HeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')
	aAdd(a_HeadOut,'Content-Type: application/x-www-form-urlencoded')

	if Empty(SZG->ZG_TIPOOS) //Nao integrar dados nao classificados
		Return
	endif

	If SZG->ZG_TIPOOS == "1" //Preventiva
		If !Empty(SZG->ZG_MAXIDP)
			cMaxId := AllTrim(SZG->ZG_MAXIDP)
			c_Url	:=	"https://api.umov.me/CenterWeb/api/"+AllTrim(c_key)+"/customEntity/"+cTabUmovPrev+"/customEntityEntry/"+cMaxId+".xml"
		Else
			c_Url	:=	"https://api.umov.me/CenterWeb/api/"+AllTrim(c_key)+"/customEntity/"+cTabUmovPrev+"/customEntityEntry.xml"
		EndIf
	ElseIf SZG->ZG_TIPOOS == "2" //Corretiva
		If !Empty(SZG->ZG_MAXID)
			cMaxId := AllTrim(SZG->ZG_MAXID)
			c_Url	:=	"https://api.umov.me/CenterWeb/api/"+AllTrim(c_key)+"/customEntity/"+cTabUmovCorr+"/customEntityEntry/"+cMaxId+".xml"
		Else
			c_Url	:=	"https://api.umov.me/CenterWeb/api/"+AllTrim(c_key)+"/customEntity/"+cTabUmovCorr+"/customEntityEntry.xml"
		EndIf
	Endif

	//DbSelectArea("SZG")
	//DbSetOrder(1)
	//DbSeek(xFilial("SZG") + SZG->ZG_COD, .F.)

	c_XML := ""
	c_XML += "data=<customEntityEntry>" + CRLF
	c_XML += "<description>" + Alltrim(AjuStr(SZG->ZG_DESC)) + "</description>"+CRLF
	c_XML += "<active>" + IIf(SZG->ZG_MSBLQL == "1" .Or. lDel, "false", "true") + "</active>"+CRLF 
	c_XML += "<alternativeIdentifier>" + Alltrim(SZG->ZG_COD) + "</alternativeIdentifier>"+CRLF
	c_XML += "  <customFields>" + CRLF
	If SZG->ZG_TIPOOS == "1" // Preventiva
		c_XML += "    <ALF__CATEG__STEXPREV>" + Alltrim(SZG->ZG_XCATEG) + "</ALF__CATEG__STEXPREV>" + CRLF
	ElseIf SZG->ZG_TIPOOS == "2" // Corretiva
		c_XML += "    <ALF__CATEG__STEXEC>" + Alltrim(SZG->ZG_XCATEG) + "</ALF__CATEG__STEXEC>" + CRLF
	endif
	c_XML += "  </customFields>" + CRLF
	c_XML += "</customEntityEntry>" + CRLF

	conout(c_Url)
	conout(c_XML)

	s_PostRet := HttpPost(c_Url, "", c_XML, n_TimeOut, a_HeadOut, @c_HeadRet)
	conout(s_PostRet)

	If ValType(s_PostRet) <> "U"
		o_Xml := Nil 
		o_Xml := XmlParser(s_PostRet, "_",@c_Error, @c_Warning) //Abre o xml

		c_IDMax := ""
		If XmlChildEx(o_xml:_RESULT,"_RESOURCEID")<>Nil
			c_IDMax := AllTrim(o_xml:_RESULT:_RESOURCEID:TEXT)
		Else	
			If XmlChildEx(o_xml:_RESULT,"_ERRORS")<>Nil
				c_Errors := StRTran(AllTrim(o_xml:_RESULT:_ERRORS:TEXT),";","")
			EndIf
		EndIf
	Else
		If ValType(s_PostRet) == "U"
			c_Errors := "Erro no m�todo HttpPost"
		Else
			c_Errors := "Erro na comunicacao com a API Maxview"
			If XmlChildEx(o_xml:_RESULT,"_ERRORS")<>Nil
				c_Errors += " - " + StRTran(AllTrim(o_xml:_RESULT:_ERRORS:TEXT),";","")
			EndIf
		EndIf
	EndIf

	If !Empty(c_Errors)
		Conout("N�o foi poss�vel enviar o Status de Execu��o "+AllTrim(SZG->ZG_COD)+" a Max View. Mensagem do erro: "+AllTrim(c_Errors))
		If lMensagem
			MsgStop("N�o foi poss�vel enviar o Status de Execu��o "+AllTrim(SZG->ZG_COD)+" a Max View. Mensagem do erro: "+AllTrim(c_Errors))
		EndIf
		Return(Nil)
	EndIf

	If !Empty(c_IDMax)
		dbSelectArea("SZG")
		SZG->(RecLock("SZG",.F.))
		If SZG->ZG_TIPOOS == "1" //Preventiva
			SZG->ZG_MAXIDP := c_IDMax
		elseIf SZG->ZG_TIPOOS == "2" //Corretiva
			SZG->ZG_MAXID := c_IDMax
		endif
		SZG->(MsUnlock())
	EndIf

	Conout("Status de Execu��o "+AllTrim(SZG->ZG_COD)+" enviado a Max View. "+IIf(!Empty(c_IDMax),"ID Max "+AllTrim(c_IDMax),""))
	If lMensagem
		MsgInfo("Status de Execu��o "+AllTrim(SZG->ZG_COD)+" enviado a Max View. "+IIf(!Empty(c_IDMax),"ID Max "+AllTrim(c_IDMax),""))
	EndIf

Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | DDMAXI5Z   �Autor  � Gabriel Ver�ssimo  � Data �  27/06/19 ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina de integra��o do Mobile Todos                       ���
�������������������������������������������������������������������������͹��
���Uso       � Perfil                                              		  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function DDMAX14Z()

	DBSelectArea("SZG")
	DBSetOrder(1)
	DBGoTop()

	While !SZG->(Eof())
		u_DDMAX14X(.F.)
		SZG->(DBSkip())
	EndDo

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | AjuStr   �Autor  � Gabriel Ver�ssimo  � Data �  27/06/19   ���
�������������������������������������������������������������������������͹��
���Desc.     � Tira Caracteres especiais                                  ���
�������������������������������������������������������������������������͹��
���Uso       � Perfil                                              		  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function AjuStr(_xTexto)
	Local cTexto := alltrim(_xTexto)

	cTexto:=Strtran(cTexto,"�"," ")
	cTexto:=Strtran(cTexto,"'"," ")
	cTexto:=Strtran(cTexto,"&","e")
	cTexto:=Strtran(cTexto,"�","C")
	cTexto:=Strtran(cTexto,"�","c")
	cTexto:=Strtran(cTexto,"�","A")
	cTexto:=Strtran(cTexto,chr(143),"A")
	cTexto:=Strtran(cTexto,"�","A")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,chr(144),"E")
	cTexto:=Strtran(cTexto,"�","e")
	cTexto:=Strtran(cTexto,"�","e")
	cTexto:=Strtran(cTexto,"�","i")
	cTexto:=Strtran(cTexto,chr(141),"i")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","u")
	cTexto:=Strtran(cTexto,chr(129),"u")
	cTexto:=Strtran(cTexto,"�","N")
	cTexto:=Strtran(cTexto,"�","n")
	cTexto:=Strtran(cTexto,"%","P")
	cTexto:=Strtran(cTexto,"$","S")
	cTexto:=Strtran(cTexto,"�","c")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","i")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","q")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","A")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","A")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","O")
	cTexto:=Strtran(cTexto,"�","c")
	cTexto:=Strtran(cTexto,"�","C")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","e")
	cTexto:=Strtran(cTexto,"�","i")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","u")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","e")
	cTexto:=Strtran(cTexto,"�","i")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","u")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","e")
	cTexto:=Strtran(cTexto,"�","i")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","u")
	cTexto:=Strtran(cTexto,"�","a")
	cTexto:=Strtran(cTexto,"�","e")
	cTexto:=Strtran(cTexto,"�","i")
	cTexto:=Strtran(cTexto,"�","o")
	cTexto:=Strtran(cTexto,"�","u")
	cTexto:=Strtran(cTexto,"�","A")
	cTexto:=Strtran(cTexto,"�","E")
	cTexto:=Strtran(cTexto,"�","I")
	cTexto:=Strtran(cTexto,"�","O")
	cTexto:=Strtran(cTexto,"�","U")
	cTexto:=Strtran(cTexto,"�","A")
	cTexto:=Strtran(cTexto,"�","E")
	cTexto:=Strtran(cTexto,"�","I")
	cTexto:=Strtran(cTexto,"�","O")
	cTexto:=Strtran(cTexto,"�","U")
	cTexto:=Strtran(cTexto,"�","A")
	cTexto:=Strtran(cTexto,"�","E")
	cTexto:=Strtran(cTexto,"�","I")
	cTexto:=Strtran(cTexto,"�","O")
	cTexto:=Strtran(cTexto,"�","U")
	cTexto:=Strtran(cTexto,"�","A")
	cTexto:=Strtran(cTexto,"�","E")
	cTexto:=Strtran(cTexto,"�","I")
	cTexto:=Strtran(cTexto,"�","O")
	cTexto:=Strtran(cTexto,"�","U")
	cTexto:=Strtran(cTexto,"�","-")
Return(cTexto)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | MVC005     �Autor  � Gabriel Ver�ssimo  � Data �  27/06/19 ���
�������������������������������������������������������������������������͹��
���Desc.     � Chamada dos pontos de entrada                              ���
�������������������������������������������������������������������������͹��
���Uso       � Perfil                                             		  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MVC014()

	Local aParam	:= PARAMIXB
	Local oObj
	Local cIdPonto	:= ""
	Local cIdModel	:= ""
	Local lRet		:= .T.

	If aParam <> NIL
		oObj		:= aParam[1]
		cIdPonto	:= aParam[2]
		cIdModel	:= aParam[3]

		If cIdPonto == "FORMCOMMITTTSPRE"
			If !(Inclui .Or. Altera)
				u_DDMAX14X(.F., .T.)
			EndIf
		ElseIf cIdPonto == "FORMCOMMITTTSPOS"
			If (Inclui .Or. Altera)
				u_DDMAX14X(.F.)
			EndIf
		EndIf
	EndIf

Return lRet
