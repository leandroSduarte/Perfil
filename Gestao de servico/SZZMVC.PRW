//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
 
//Variáveis Estáticas
Static cTitulo := " Plano de Movimentação - Customizada"
 
/*/{Protheus.doc} SZZMVC
Função para cadastro de planos de movimentação - customizada
@author Alexander Leite
@since 14/04/2021
@version 1.0
    @return Nil, Função não tem retorno
    @example
    u_SZGMVG()
    @obs Não se pode executar função MVC dentro do fórmulas
/*/
 
User Function SZZMVC()
    Local aArea   := GetArea()
    Local oBrowse
     
    //Instânciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMBrowse():New()
     
    //Setando a tabela de cadastro de Autor/Interprete
    oBrowse:SetAlias("SZZ")
 
    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)
     
    //Ativa a Browse
    oBrowse:Activate()  
     
    RestArea(aArea)
Return Nil
 
/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Alexander Leite                                               |
 | Data:  17/08/2015                                                   |
 | Desc:  Criação do menu MVC                                          |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function MenuDef()
    Local aRot := {}
     
    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.SZZMVC' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    //ADD OPTION aRot TITLE 'Legenda'    ACTION 'u_zMVC01Leg'     OPERATION 6                      ACCESS 0 //OPERATION X
    //ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.zMVCMd1' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    //ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.zMVCMd1' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.SZZMVC' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
 
Return aRot
 
/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Alexander Leite                                                |
 | Data:  17/08/2015                                                   |
 | Desc:  Criação do modelo de dados MVC                               |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function ModelDef()
    //Criação do objeto do modelo de dados
    Local oModel := Nil
     
    //Criação da estrutura de dados utilizada na interface
    Local oStSZZ := FWFormStruct(1, "SZZ")
     
    //Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("SZZM",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
     
    //Atribuindo formulários para o modelo
    oModel:AddFields("SZZCAB",/*cOwner*/,oStSZZ)
     
    //Setando a chave primária da rotina
    oModel:SetPrimaryKey({'ZZ_FILIAL','ZZ_NUMOS'})
     
    //Adicionando descrição ao modelo
    oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)
     
    //Setando a descrição do formulário
    oModel:GetModel("SZZCAB"):SetDescription("Formulário do Cadastro "+cTitulo)
Return oModel
 
/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Alexander Leite                                                |
 | Data:  17/08/2015                                                   |
 | Desc:  Criação da visão MVC                                         |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function ViewDef()
    //Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
    Local oModel := FWLoadModel("SZZMVC")
     
    //Criação da estrutura de dados utilizada na interface do cadastro de Autor
    Local oStSZZ := FWFormStruct(2, "SZZ")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SBM_NOME|SBM_DTAFAL|'}
     
    //Criando oView como nulo
    Local oView := Nil
 
    //Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Atribuindo formulários para interface
    oView:AddField("VIEW_SZZ", oStSZZ, "FORMSZZ")
     
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)
     
    //Colocando título do formulário
    oView:EnableTitleView('VIEW_SZZ', 'Dados dos Planos' )  
     
    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})
     
    //O formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_SZZ","TELA")
Return oView
