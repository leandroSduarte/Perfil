#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | PERDESAGE �Autor  � J�nior Conte        � Data �  04/05/21 ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina para finalizar alarmes                             ���
�������������������������������������������������������������������������͹��
���Uso       � Perfil	                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function PERDESAGE()

	Local lRet := .T.
	Local aArea := GetArea()

	Private oBrowse
	Private cChaveAux := ""
	Private nOpc		:= 0

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZA1")
	oBrowse:SetDescription("Alarmes")
	//oBrowse:DisableDetails()
    //oBrowse:SetFilterDefault("ZA1_DTFIM =  '' .AND. ZA1_HRFIM")	
	oBrowse:Activate()

	RestArea(aArea)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | MenuDef  �Autor  � J�nior Conte       � Data �  27/06/19   ���
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
	//ADD OPTION aRotina TITLE "Visualizar" 					ACTION "VIEWDEF.PERDESAGE" 	OPERATION 2 	ACCESS 0
	//ADD OPTION aRotina TITLE "Incluir"    					ACTION "VIEWDEF.PERDESAGE" 	OPERATION 3 	ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    					ACTION "VIEWDEF.PERDESAGE" 	OPERATION 4 	ACCESS 0
	//ADD OPTION aRotina TITLE "Excluir"    					ACTION "VIEWDEF.PERDESAGE" 	OPERATION 5 	ACCESS 0
	//ADD OPTION aRotina TITLE "Copiar" 						ACTION "VIEWDEF.PERDESAGE" 	OPERATION 9 	ACCESS 0

Return aRotina

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | ViewDef  �Autor  � J�nior Conte  � Data �  27/06/19   ���
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
	Local oStr1:= FWFormStruct(2, 'ZA1')

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados ser� utiliZDdo
	oView:SetModel(oModel)

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField('Formulario' , oStr1,'CamposZA1' )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'PAI', 100)

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView('Formulario','PAI')
	oView:EnableTitleView('Formulario' , 'Alarmes ' )	
	oView:SetViewProperty('Formulario' , 'SETCOLUMNSEPARATOR', {10})

	//For�a o fechamento da janela na confirma��o
	oView:SetCloseOnOk({||.T.})

Return oView

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | ModelDef �Autor  � J�nior Conte       � Data �  27/06/19   ���
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
	Local oStr1:= FWFormStruct( 1, 'ZA1', /*bAvalCampo*/,/*lViewUsado*/ ) // Constru��o de uma estrutura de dados

	//Cria o objeto do Modelo de Dados
	//Irie usar uma fun��o MVC001V que ser� acionada quando eu clicar no bot�o "Confirmar"
	oModel := MPFormModel():New('MVC018', /*bPreValidacao*/, { | oModel | MVC001V( oModel ) } , /*{ | oMdl | MVC001C( oMdl ) }*/ ,, /*bCancel*/ )
	oModel:SetDescription('Alarmes')

	// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
	oModel:addFields('CamposZA1',,oStr1,{|oModel| MVC001T(oModel)},,)

	//Define a chave primaria utiliZDda pelo modelo
	oModel:SetPrimaryKey({'ZA1_FILIAL', 'ZA1_USER'})

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:getModel('CamposZA1'):SetDescription('TabelaZA1')

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
	Local oModelZB1 := oModel:GetModel( 'CamposZA1' )

	
Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | MVC001V  �Autor  � J�nior Conte  � Data �  27/06/19   ���
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
	Local oModelZ45 := oModel:GetModel( 'CamposZA1' )
	//Local nOpc      := oModel:GetOperation()
	Local aArea     := GetArea()

	nOpc      := oModel:GetOperation()

	Begin Transaction

		if nOpc == 3 .or. nOpc == 4
	
		Endif

		if !lRet
			DisarmTransaction()
		Endif

	End Transaction

	RestArea(aArea)

	FwModelActive( oModel, .T. )

Return lRet

