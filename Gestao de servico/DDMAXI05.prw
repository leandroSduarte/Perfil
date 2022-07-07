#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | DDMAXI05 �Autor  � Gabriel Ver�ssimo  � Data �  27/06/19   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina de Cadastro de Identifica��o		                  ���
�������������������������������������������������������������������������͹��
���Uso       � Perfil	                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function DDMAXI05()

	Local lRet := .T.
	Local aArea := GetArea()

	Private oBrowse
	Private cChaveAux := ""
	Private nOpc		:= 0

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SZD")
	oBrowse:SetDescription("Cadastro de Identifica��o")
	//oBrowse:DisableDetails()
	oBrowse:Activate()

	RestArea(aArea)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | MenuDef  �Autor  � Gabriel Ver�ssimo  � Data �  27/06/19   ���
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
	ADD OPTION aRotina TITLE "Visualizar" 					ACTION "VIEWDEF.DDMAXI05" 	OPERATION 2 	ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    					ACTION "VIEWDEF.DDMAXI05" 	OPERATION 3 	ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    					ACTION "VIEWDEF.DDMAXI05" 	OPERATION 4 	ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    					ACTION "VIEWDEF.DDMAXI05" 	OPERATION 5 	ACCESS 0
//	ADD OPTION aRotina TITLE "Imprimir" 					ACTION "VIEWDEF.DDMAXI05" 	OPERATION 8 	ACCESS 0
	ADD OPTION aRotina TITLE "Copiar" 						ACTION "VIEWDEF.DDMAXI05" 	OPERATION 9 	ACCESS 0
	ADD OPTION aRotina TITLE "Integra��o Maxview"			ACTION "u_DDMAXI5X" 	  	OPERATION 9 	ACCESS 0
	ADD OPTION aRotina TITLE "Integra��o Maxview Todos" 	ACTION "u_DDMAXI5Z" 		OPERATION 10 	ACCESS 0

Return aRotina

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | ViewDef  �Autor  � Gabriel Ver�ssimo  � Data �  27/06/19   ���
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
	Local oModel := ModelDef()
	Local oStr1:= FWFormStruct(2, 'SZD')

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados ser� utiliZDdo
	oView:SetModel(oModel)

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField('Formulario' , oStr1,'CamposSZD' )

	//Remove os campos que n�o ir�o aparecer	
	//oStr1:RemoveField( 'X5_DESCENG' )
	//oStr1:RemoveField( 'X5_DESCSPA' )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'PAI', 100)

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView('Formulario','PAI')
	oView:EnableTitleView('Formulario' , 'Cadastro de Identifica��o' )	
	oView:SetViewProperty('Formulario' , 'SETCOLUMNSEPARATOR', {10})

	//For�a o fechamento da janela na confirma��o
	oView:SetCloseOnOk({||.T.})

Return oView

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | ModelDef �Autor  � Gabriel Ver�ssimo  � Data �  27/06/19   ���
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
	Local oStr1:= FWFormStruct( 1, 'SZD', /*bAvalCampo*/,/*lViewUsado*/ ) // Constru��o de uma estrutura de dados

	//Cria o objeto do Modelo de Dados
	//Irie usar uma fun��o MVC001V que ser� acionada quando eu clicar no bot�o "Confirmar"
	oModel := MPFormModel():New('MVC005', /*bPreValidacao*/, { | oModel | MVC001V( oModel ) } , /*{ | oMdl | MVC001C( oMdl ) }*/ ,, /*bCancel*/ )
	oModel:SetDescription('Cadastro de Identifica��o')

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
	oModel:addFields('CamposSZD',,oStr1,{|oModel| MVC001T(oModel)},,)

	//Define a chave primaria utiliZDda pelo modelo
	oModel:SetPrimaryKey({'ZD_FILIAL', 'ZD_COD' })

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:getModel('CamposSZD'):SetDescription('TabelaSZD')

Return oModel

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | MVC001T  �Autor  � Gabriel Ver�ssimo  � Data �  27/06/19   ���
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
	Local oModelSZD := oModel:GetModel( 'CamposSZD' )

	//cChaveAux := SZD->X5_CHAVE

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | MVC001V  �Autor  � Gabriel Ver�ssimo  � Data �  27/06/19   ���
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
	Local oModelSZD := oModel:GetModel( 'CamposSZD' )
	//Local nOpc      := oModel:GetOperation()
	Local aArea     := GetArea()

	nOpc      := oModel:GetOperation()

	//Capturar o conteudo dos campos
	//Local cChave	:= oModelSZD:GetValue('X5_CHAVE')
	//Local cTabela	:= oModelSZD:GetValue('X5_TABELA')
	//Local cDescri	:= oModelSZD:GetValue('X5_DESCRI')

	Begin Transaction

		if nOpc == 3 .or. nOpc == 4
			/*
			if Empty(cTabela)
			oModelSZD:SetValue('X5_TABELA','21')
			Endif

			dbSelectArea("SZD")
			SZD->(dbSetOrder(1))
			SZD->(dbGoTop())
			If(SZD->(dbSeek(xFilial("SZD")+cTabela+cChave)))
			if cChaveAux != cChave
			SFCMsgErro("A chave "+Alltrim(cChave)+" ja foi informada!","MVC001")
			lRet := .F.
			Endif
			Endif

			if Empty(cChave)
			SFCMsgErro("O campo chave � obrigat�rio!","MVC001")
			lRet := .F.
			Endif

			if Empty(cDescri)
			SFCMsgErro("O campo descri��o � obrigat�rio!","MVC001")
			lRet := .F.
			Endif
			*/
		Endif

		if !lRet
			DisarmTransaction()
		Endif

	End Transaction

	RestArea(aArea)

	FwModelActive( oModel, .T. )

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | DDMAXI5X �Autor  � Gabriel Ver�ssimo  � Data �  27/06/19   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina de integra��o do Mobile                             ���
�������������������������������������������������������������������������͹��
���Uso       � Perfil                                              		  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function DDMAXI5X(lMensagem, lDel)

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
		cTabUmovPrev := "322666"
		cTabUmovCorr := "320902"
	else
		cTabUmovPrev := "325290"
		cTabUmovCorr := "219447"
	endif

	if ValType(lMensagem) <> "L"
		lMensagem := .T.
	endif
	
	If ValType(lDel) <> "L"
		lDel := .F.
	EndIf

	aAdd(a_HeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')
	aAdd(a_HeadOut,'Content-Type: application/x-www-form-urlencoded')

	if Empty(SZD->ZD_TIPOOS) //Nao integrar dados nao classificados
		Return
	endif

	If SZD->ZD_TIPOOS == "1" // Preventiva
		If !Empty(SZD->ZD_MAXIDP)
			cMaxId := AllTrim(SZD->ZD_MAXIDP)
			c_Url	:=	"https://api.umov.me/CenterWeb/api/"+AllTrim(c_key)+"/customEntity/"+cTabUmovPrev+"/customEntityEntry/"+cMaxId+".xml"
		Else
			c_Url	:=	"https://api.umov.me/CenterWeb/api/"+AllTrim(c_key)+"/customEntity/"+cTabUmovPrev+"/customEntityEntry.xml"
		EndIf
	ElseIf SZD->ZD_TIPOOS == "2" // Corretiva
		If !Empty(SZD->ZD_MAXID)
			cMaxId := AllTrim(SZD->ZD_MAXID)
		  c_Url	:=	"https://api.umov.me/CenterWeb/api/"+AllTrim(c_key)+"/customEntity/"+cTabUmovCorr+"/customEntityEntry/"+cMaxId+".xml"
		Else
			c_Url	:=	"https://api.umov.me/CenterWeb/api/"+AllTrim(c_key)+"/customEntity/"+cTabUmovCorr+"/customEntityEntry.xml"
		EndIf
	Endif

	DbSelectArea("SZD")
	DbSetOrder(1)
	DbSeek(xFilial("SZD") + SZD->ZD_COD, .F.)

	c_XML := ""
	c_XML += "data=<customEntityEntry>" + CRLF
	c_XML += "<description>" + Alltrim(AjuStr(SZD->ZD_DESC)) + "</description>"+CRLF
	c_XML += "<active>" + IIf(SZD->ZD_MSBLQL == "1" .Or. lDel, "false", "true") + "</active>"+CRLF 
	c_XML += "<alternativeIdentifier>" + Alltrim(SZD->ZD_COD) + "</alternativeIdentifier>"+CRLF
	c_XML += "  <customFields>" + CRLF
	If SZD->ZD_TIPOOS == "1" // Preventiva
		c_XML += "    <ALF_CATEG_IDPREV>" + Alltrim(SZD->ZD_XCATEG) + "</ALF_CATEG_IDPREV>" + CRLF
	ElseIf SZD->ZD_TIPOOS == "2" // Corretiva
		c_XML += "    <ALF_CATEG_IDENT>" + Alltrim(SZD->ZD_XCATEG) + "</ALF_CATEG_IDENT>" + CRLF
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
		Conout("N�o foi poss�vel enviar a Identifica��o "+AllTrim(SZD->ZD_COD)+" a Max View. Mensagem do erro: "+AllTrim(c_Errors))
		if lMensagem
			MsgStop("N�o foi poss�vel enviar a Identifica��o "+AllTrim(SZD->ZD_COD)+" a Max View. Mensagem do erro: "+AllTrim(c_Errors))
		endif
		Return(Nil)
	EndIf

	if !Empty(c_IDMax)
		dbSelectArea("SZD")
		SZD->(RecLock("SZD",.F.))
		If SZD->ZD_TIPOOS == "1" // Preventiva
			SZD->ZD_MAXIDP := c_IDMax
		elseIf SZD->ZD_TIPOOS == "2" // Corretiva
			SZD->ZD_MAXID := c_IDMax
		endif
		SZD->(MsUnlock())
	endif

	Conout("Identifica��o "+AllTrim(SZD->ZD_COD)+" enviado a Max View. "+Iif(!Empty(c_IDMax),"ID Max "+AllTrim(c_IDMax),""))
	if lMensagem
		MsgInfo("Identifica��o "+AllTrim(SZD->ZD_COD)+" enviado a Max View. "+Iif(!Empty(c_IDMax),"ID Max "+AllTrim(c_IDMax),""))
	endif

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
User Function DDMAXI5Z()

	DBSelectArea("SZD")
	DBSetOrder(1)
	DBGoTop()

	While !SZD->(Eof())
		u_DDMAXI5X(.F.)
		SZD->(DBSkip())
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

User Function MVC005()

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
				u_DDMAXI5X(.F., .T.)
			EndIf
		ElseIf cIdPonto == "FORMCOMMITTTSPOS"
			If (Inclui .Or. Altera)
				u_DDMAXI5X(.F.)
			EndIf
		EndIf
	EndIf

Return lRet
