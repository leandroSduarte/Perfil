#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  | DDMAXI04 บAutor  ณ Gabriel Verํssimo  บ Data ณ  27/06/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de Cadastro de Causa		                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Perfil	                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function DDMAXI06()

	Local lRet := .T.
	Local aArea := GetArea()

	Private oBrowse
	Private cChaveAux := ""
	Private nOpc		:= 0

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SZE")
	oBrowse:SetDescription("Cadastro de Causa")
	//oBrowse:DisableDetails()
	oBrowse:Activate()

	RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  | MenuDef  บAutor  ณ Gabriel Verํssimo  บ Data ณ  27/06/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ MenuDef da Rotina                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Perfil	                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE "Pesquisar"  					ACTION 'PesqBrw' 	 	  	OPERATION 1 	ACCESS 0
	ADD OPTION aRotina TITLE "Visualizarr" 					ACTION "VIEWDEF.DDMAXI06" 	OPERATION 2 	ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    					ACTION "VIEWDEF.DDMAXI06" 	OPERATION 3 	ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    					ACTION "VIEWDEF.DDMAXI06" 	OPERATION 4 	ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    					ACTION "VIEWDEF.DDMAXI06" 	OPERATION 5 	ACCESS 0
//	ADD OPTION aRotina TITLE "Imprimir" 					ACTION "VIEWDEF.DDMAXI06" 	OPERATION 8 	ACCESS 0
	ADD OPTION aRotina TITLE "Copiar" 						ACTION "VIEWDEF.DDMAXI06" 	OPERATION 9 	ACCESS 0
	ADD OPTION aRotina TITLE "Integra็ใo Maxview"			ACTION "u_DDMAXI6X" 	  	OPERATION 9 	ACCESS 0
	ADD OPTION aRotina TITLE "Integra็ใo Maxview Todos" 	ACTION "u_DDMAXI6Z" 		OPERATION 10 	ACCESS 0

Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  | ViewDef  บAutor  ณ Gabriel Verํssimo  บ Data ณ  27/06/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ View da Rotina                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Perfil	                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ViewDef()
	Local oView
	Local oModel := ModelDef()
	Local oStr1:= FWFormStruct(2, 'SZE')

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados serแ utiliZEdo
	oView:SetModel(oModel)

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField('Formulario' , oStr1,'CamposSZE' )

	//Remove os campos que nใo irใo aparecer	
	//oStr1:RemoveField( 'X5_DESCENG' )
	//oStr1:RemoveField( 'X5_DESCSPA' )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'PAI', 100)

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView('Formulario','PAI')
	oView:EnableTitleView('Formulario' , 'Cadastro de Causa' )	
	oView:SetViewProperty('Formulario' , 'SETCOLUMNSEPARATOR', {10})

	//For็a o fechamento da janela na confirma็ใo
	oView:SetCloseOnOk({||.T.})

Return oView

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  | ModelDef บAutor  ณ Gabriel Verํssimo  บ Data ณ  27/06/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Model da Rotina                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Perfil	                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ModelDef()
	Local oModel
	Local oStr1:= FWFormStruct( 1, 'SZE', /*bAvalCampo*/,/*lViewUsado*/ ) // Constru็ใo de uma estrutura de dados

	//Cria o objeto do Modelo de Dados
	//Irie usar uma fun็ใo MVC001V que serแ acionada quando eu clicar no botใo "Confirmar"
	oModel := MPFormModel():New('MVC006', /*bPreValidacao*/, { | oModel | MVC001V( oModel ) } , /*{ | oMdl | MVC001C( oMdl ) }*/ ,, /*bCancel*/ )
	oModel:SetDescription('Cadastro de Causa')

	//Abaixo irei iniciar o campo X5_TABELA com o conteudo da sub-tabela
	//oStr1:SetProperty('X5_TABELA' , MODEL_FIELD_INIT,{||'21'} )

	//Abaixo irei bloquear/liberar os campos para edi็ใo
	//oStr1:SetProperty('X5_TABELA' , MODEL_FIELD_WHEN,{|| .F. })

	//Podemos usar as fun็๕es INCLUI ou ALTERA
	//oStr1:SetProperty('X5_CHAVE'  , MODEL_FIELD_WHEN,{|| INCLUI })

	//Ou usar a propriedade GetOperation que captura a opera็ใo que estแ sendo executada
	//oStr1:SetProperty("X5_CHAVE"  , MODEL_FIELD_WHEN,{|oModel| oModel:GetOperation()== 3 })

	//oStr1:RemoveField( 'X5_DESCENG' )
	//oStr1:RemoveField( 'X5_DESCSPA' )
	//oStr1:RemoveField( 'X5_FILIAL' )

	// Adiciona ao modelo uma estrutura de formulแrio de edi็ใo por campo
	oModel:addFields('CamposSZE',,oStr1,{|oModel| MVC001T(oModel)},,)

	//Define a chave primaria utiliZEda pelo modelo
	oModel:SetPrimaryKey({'ZE_FILIAL', 'ZE_COD' })

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:getModel('CamposSZE'):SetDescription('TabelaSZE')

Return oModel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  | MVC001T  บAutor  ณ Gabriel Verํssimo  บ Data ณ  27/06/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Model da Rotina                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Perfil	                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MVC001T( oModel )
	Local lRet      := .T.
	Local oModelSZE := oModel:GetModel( 'CamposSZE' )

	//cChaveAux := SZE->X5_CHAVE

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  | MVC001V  บAutor  ณ Gabriel Verํssimo  บ Data ณ  27/06/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Model da Rotina                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Perfil	                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MVC001V( oModel )
	Local lRet      := .T.
	Local oModelSZE := oModel:GetModel( 'CamposSZE' )
	//Local nOpc      := oModel:GetOperation()
	Local aArea     := GetArea()

	nOpc      := oModel:GetOperation()

	//Capturar o conteudo dos campos
	//Local cChave	:= oModelSZE:GetValue('X5_CHAVE')
	//Local cTabela	:= oModelSZE:GetValue('X5_TABELA')
	//Local cDescri	:= oModelSZE:GetValue('X5_DESCRI')

	Begin Transaction

		if nOpc == 3 .or. nOpc == 4
			/*
			if Empty(cTabela)
			oModelSZE:SetValue('X5_TABELA','21')
			Endif

			dbSelectArea("SZE")
			SZE->(dbSetOrder(1))
			SZE->(dbGoTop())
			If(SZE->(dbSeek(xFilial("SZE")+cTabela+cChave)))
			if cChaveAux != cChave
			SFCMsgErro("A chave "+Alltrim(cChave)+" ja foi informada!","MVC001")
			lRet := .F.
			Endif
			Endif

			if Empty(cChave)
			SFCMsgErro("O campo chave ้ obrigat๓rio!","MVC001")
			lRet := .F.
			Endif

			if Empty(cDescri)
			SFCMsgErro("O campo descri็ใo ้ obrigat๓rio!","MVC001")
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  | DDMAXI6X   บAutor  ณ Anderson Messias บ Data ณ  23/11/18   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de integra็ใo do Mobile                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Perfil	                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DDMAXI6X(lMensagem, lDel)

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
		cTabUmov := "320901"
	else
		cTabUmov := "219430"
	endif

	if ValType(lMensagem) <> "L"
		lMensagem := .T.
	endif
	
	If ValType(lDel) <> "L"
		lDel := .F.
	EndIf

	aAdd(a_HeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')
	aAdd(a_HeadOut,'Content-Type: application/x-www-form-urlencoded')

	If !Empty(SZE->ZE_MAXID)
		c_Url	:=	"https://api.umov.me/CenterWeb/api/"+AllTrim(c_key)+"/customEntity/"+cTabUmov+"/customEntityEntry/"+AllTrim(SZE->ZE_MAXID)+".xml"
	Else
		c_Url	:=	"https://api.umov.me/CenterWeb/api/"+AllTrim(c_key)+"/customEntity/"+cTabUmov+"/customEntityEntry.xml"
	EndIf

	DbSelectArea("SZE")
	DbSetOrder(1)
	DbSeek(xFilial("SZE") + SZE->ZE_COD, .F.)

	c_XML := ""
	c_XML += "data=<customEntityEntry>" + CRLF
	c_XML += "<description>" + Alltrim(AjuStr(SZE->ZE_DESC)) + "</description>"+CRLF
	c_XML += "<active>" + IIf(SZE->ZE_MSBLQL == "1" .Or. lDel, "false", "true") + "</active>"+CRLF
	c_XML += "<alternativeIdentifier>" + Alltrim(SZE->ZE_COD) + "</alternativeIdentifier>"+CRLF
	c_XML += "  <customFields>" + CRLF
	c_XML += "    <ALF_CATEG_CAUSA>" + Alltrim(SZE->ZE_XCATEG) + "</ALF_CATEG_CAUSA>" + CRLF
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
			c_Errors := "Erro no m้todo HttpPost"
		Else
			c_Errors := "Erro na comunicacao com a API Maxview"
			If XmlChildEx(o_xml:_RESULT,"_ERRORS")<>Nil
				c_Errors += " - " + StRTran(AllTrim(o_xml:_RESULT:_ERRORS:TEXT),";","")
			EndIf
		EndIf
	EndIf

	If !Empty(c_Errors)
		Conout("Nใo foi possํvel enviar a Causa "+AllTrim(SZE->ZE_COD)+" a Max View. Mensagem do erro: "+AllTrim(c_Errors))
		if lMensagem
			MsgStop("Nใo foi possํvel enviar a Causa "+AllTrim(SZE->ZE_COD)+" a Max View. Mensagem do erro: "+AllTrim(c_Errors))
		endif
		Return(Nil)
	EndIf

	if !Empty(c_IDMax)
		dbSelectArea("SZE")
		SZE->(RecLock("SZE",.F.))
		SZE->ZE_MAXID := c_IDMax
		SZE->(MsUnlock())
	endif

	Conout("Causa "+AllTrim(SZE->ZE_COD)+" enviada a Max View. "+Iif(!Empty(c_IDMax),"ID Max "+AllTrim(c_IDMax),""))
	if lMensagem
		MsgInfo("Causa "+AllTrim(SZE->ZE_COD)+" enviada a Max View. "+Iif(!Empty(c_IDMax),"ID Max "+AllTrim(c_IDMax),""))
	endif

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  | DDMAXI6Z   บAutor  ณ Anderson Messias บ Data ณ  23/11/18   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de integra็ใo do Mobile Todos                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Perfil	                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DDMAXI6Z()

	DBSelectArea("SZE")
	DBSetOrder(1)
	DBGoTop()

	While !SZE->(Eof())
		u_DDMAXI6X(.F.)
		SZE->(DBSkip())
	EndDo

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  | AjuStr     บAutor  ณ Anderson Messias บ Data ณ  23/11/18   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tira Caracteres especiais                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Perfil	                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AjuStr(_xTexto)
	Local cTexto := alltrim(_xTexto)

	cTexto:=Strtran(cTexto,"ด"," ")
	cTexto:=Strtran(cTexto,"'"," ")
	cTexto:=Strtran(cTexto,"&","e")
	cTexto:=Strtran(cTexto,"€","C")
	cTexto:=Strtran(cTexto,"","c")
	cTexto:=Strtran(cTexto,"","A")
	cTexto:=Strtran(cTexto,chr(143),"A")
	cTexto:=Strtran(cTexto,"ล","A")
	cTexto:=Strtran(cTexto,"…","a")
	cTexto:=Strtran(cTexto,"","a")
	cTexto:=Strtran(cTexto," ","a")
	cTexto:=Strtran(cTexto,"","a")
	cTexto:=Strtran(cTexto,"ฆ","a")
	cTexto:=Strtran(cTexto,"ๅ","a")
	cTexto:=Strtran(cTexto,chr(144),"E")
	cTexto:=Strtran(cTexto,"","e")
	cTexto:=Strtran(cTexto,"","e")
	cTexto:=Strtran(cTexto,"ก","i")
	cTexto:=Strtran(cTexto,chr(141),"i")
	cTexto:=Strtran(cTexto,"“","o")
	cTexto:=Strtran(cTexto,"”","o")
	cTexto:=Strtran(cTexto,"•","o")
	cTexto:=Strtran(cTexto,"ข","o")
	cTexto:=Strtran(cTexto,"ง","o")
	cTexto:=Strtran(cTexto,"๐","o")
	cTexto:=Strtran(cTexto,"ฃ","u")
	cTexto:=Strtran(cTexto,chr(129),"u")
	cTexto:=Strtran(cTexto,"ั","N")
	cTexto:=Strtran(cTexto,"๑","n")
	cTexto:=Strtran(cTexto,"%","P")
	cTexto:=Strtran(cTexto,"$","S")
	cTexto:=Strtran(cTexto,"þ","c")
	cTexto:=Strtran(cTexto,"๗","o")
	cTexto:=Strtran(cTexto,"Ý","i")
	cTexto:=Strtran(cTexto,"ฐ","o")
	cTexto:=Strtran(cTexto,"ฌ","q")
	cTexto:=Strtran(cTexto,"","a")
	cTexto:=Strtran(cTexto,"","a")
	cTexto:=Strtran(cTexto,"ฦ","a")
	cTexto:=Strtran(cTexto,"ต","a")
	cTexto:=Strtran(cTexto,"ถ","A")
	cTexto:=Strtran(cTexto,"บ","o")
	cTexto:=Strtran(cTexto,"ช","a")
	cTexto:=Strtran(cTexto,"ใ","a")
	cTexto:=Strtran(cTexto,"ร","A")
	cTexto:=Strtran(cTexto,"๕","o")
	cTexto:=Strtran(cTexto,"ี","O")
	cTexto:=Strtran(cTexto,"็","c")
	cTexto:=Strtran(cTexto,"ว","C")
	cTexto:=Strtran(cTexto,"แ","a")
	cTexto:=Strtran(cTexto,"้","e")
	cTexto:=Strtran(cTexto,"ํ","i")
	cTexto:=Strtran(cTexto,"๓","o")
	cTexto:=Strtran(cTexto,"๚","u")
	cTexto:=Strtran(cTexto,"เ","a")
	cTexto:=Strtran(cTexto,"่","e")
	cTexto:=Strtran(cTexto,"์","i")
	cTexto:=Strtran(cTexto,"๒","o")
	cTexto:=Strtran(cTexto,"๙","u")
	cTexto:=Strtran(cTexto,"โ","a")
	cTexto:=Strtran(cTexto,"๊","e")
	cTexto:=Strtran(cTexto,"๎","i")
	cTexto:=Strtran(cTexto,"๔","o")
	cTexto:=Strtran(cTexto,"๛","u")
	cTexto:=Strtran(cTexto,"ไ","a")
	cTexto:=Strtran(cTexto,"๋","e")
	cTexto:=Strtran(cTexto,"๏","i")
	cTexto:=Strtran(cTexto,"๖","o")
	cTexto:=Strtran(cTexto,"ü","u")
	cTexto:=Strtran(cTexto,"ม","A")
	cTexto:=Strtran(cTexto,"ษ","E")
	cTexto:=Strtran(cTexto,"อ","I")
	cTexto:=Strtran(cTexto,"ำ","O")
	cTexto:=Strtran(cTexto,"ฺ","U")
	cTexto:=Strtran(cTexto,"ภ","A")
	cTexto:=Strtran(cTexto,"ศ","E")
	cTexto:=Strtran(cTexto,"ฬ","I")
	cTexto:=Strtran(cTexto,"า","O")
	cTexto:=Strtran(cTexto,"ู","U")
	cTexto:=Strtran(cTexto,"ย","A")
	cTexto:=Strtran(cTexto,"ส","E")
	cTexto:=Strtran(cTexto,"ฮ","I")
	cTexto:=Strtran(cTexto,"ิ","O")
	cTexto:=Strtran(cTexto,"Û","U")
	cTexto:=Strtran(cTexto,"ฤ","A")
	cTexto:=Strtran(cTexto,"ห","E")
	cTexto:=Strtran(cTexto,"ฯ","I")
	cTexto:=Strtran(cTexto,"ึ","O")
	cTexto:=Strtran(cTexto,"Ü","U")
	cTexto:=Strtran(cTexto,"–","-")
Return(cTexto)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  | MVC006     บAutor  ณ Gabriel Verํssimo  บ Data ณ  27/06/19 บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Chamada dos pontos de entrada                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Perfil                                             		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function MVC006()

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
				u_DDMAXI6X(.F., .T.)
			EndIf
		ElseIf cIdPonto == "FORMCOMMITTTSPOS"
			If (Inclui .Or. Altera)
				u_DDMAXI6X(.F.)
			EndIf
		EndIf
	EndIf

Return lRet
