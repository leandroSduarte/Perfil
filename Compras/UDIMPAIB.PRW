#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "Totvs.ch"
#INCLUDE "TCBROWSE.CH"
#Include "FILEIO.CH"

#define CMD_OPENWORKBOOK			1
#define CMD_CLOSEWORKBOOK		 	2
#define CMD_ACTIVEWORKSHEET  		3
#define CMD_READCELL				4

#DEFINE ENTER CHR(13)+CHR(10)   
#DEFINE cDirPad	"\tab_preco_forn\"

//Statics para funcionamento da EnchAuto
Static lAutoMode := .F.
Static lAutoVldUser

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ UDIMPAIB บ Autor ณ Marcio Gois        บ Data ณ  19/12/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Importacao de cadastro de Produtos                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ULMA                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function UDIMPAIB()

Local _Opcao      := .F.
Private cTitulo1  := "Selecione o arquivo"
Private cExtens   := "Arquivo XLS | *.xls*"
Private oDlgImp   := Nil
Private cEol      := CHR(13)+CHR(10)
Private aHeadErr  := {}
Private aColsErr  := {}
Private oGetErr	  := Nil
Private cFileOpen := ""
Private INCLUI    := .T.
Private cPerg := Padr("UDIMPAIB",10)

ValPerg() 

cCadastro := OemtoAnsi("Importa็ใo (AIB) "+Alltrim( PosAlias( "SX2", "AIB", "", "X2Nome()", 1, .F. ) ))

aADD(aHeadErr,{AllTrim("Linha Excel"),"ERR_EXCEL","",10,0,,,"C" } )
aADD(aHeadErr,{AllTrim("Status"),"ERR_STATUS","",4,0,,,"C" } )
aADD(aHeadErr,{AllTrim("Descricao do Erro"),"ERR_MEMO","",80,0,,,"M" } )

@ 0,0 TO 310,647 DIALOG oDlgImp TITLE cCadastro
@ 2,5 TO 135,320 LABEL "Valida็ใo da Importa็ใo"  OF oDlgImp PIXEL
oGetErr := MsNewGetDados():New(10,10,130,315,/*GD_INSERT+GD_UPDATE+GD_DELETE*/,/*"u_RatCCLOk"*/,/*"u_RatCCTok"*/,/*"+"+cSiglaTrb+"ITEM"*/,,,5,/*fieldok*/,/*superdel*/,/*delok*/,oDlgImp,aHeadErr,aColsErr)
@ 140,005 BUTTON OemToAnsi("Gerar Modelo Excel") SIZE 070,11 ACTION Processa({|| u_DIMPSB1C()},"Gerando Modelo de Importa็ใo, aguarde...") PIXEL
@ 140,080 BUTTON OemToAnsi("Parametros") SIZE 040,11 ACTION Pergunte(cPerg,.T.) PIXEL
@ 140,220 BUTTON OemToAnsi("Importa็ใo Excel") SIZE 050,11 ACTION Processa({|| u_DIMPSB1V()},"Validando Dados, aguarde...") PIXEL
@ 140,280 BUTTON OemToAnsi("Sair") SIZE 040,11 ACTION Close(oDlgImp) PIXEL
oGetErr:aCols := {}
oGetErr:refresh()
ACTIVATE DIALOG oDlgImp CENTERED

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DIMPSB1C บAutor  ณ Marcio Gois        บ Data ณ  19/12/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Sele็ใo dos campos a serem importados                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ULMA                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
User Function DIMPSB1C

local n_arq
local c_linha
local _cTemp
Local aCampos   := {}
Local cMemos := ""
Local aModCamp := {{0,"Outros"}}
Local aFields  := {} 
Local aNotFields := {"AIB_FILIAL","AIB_CODFOR","AIB_LOJFOR","AIB_CODTAB","AIB_ITEM","AIB_QTDLOT","AIB_INDLOT","AIB_FRETE","AIB_DATVIG","AIB_MOEDA"}  
Local aMark  := {;
{"OK"		, "C", 02, 0},;
{"CAMPO"	, "C", 15, 0},;
{"TITULO"	, "C", 25, 0},;
{"TIPO"		, "C", 01, 0},;
{"PASTA"	, "C", 25, 0},;
{"OBRIGA"	, "C", 05, 0},;
{"MODULO"	, "C", 20, 0};
}

Private cMarca    := ""
Private cCadastro := "Grupo: AIB - "+Alltrim( PosAlias( "SX2", "AIB", "", "X2Nome()", 1, .F. ) )
Private aRotina   := {}

If Select("fMark")>0
	fMark->(dbCloseArea())
EndIf

cFileMark :=Criatrab(,.F.)
MsCreate(cFileMark,aMark,"DBFCDX") // atribui a tabela temporแria ao alias TRB

dbUseArea(.T.,"DBFCDX",cFileMark,"fMark",.T.,.F.)
IndRegua("fMark",cFileMark,"OBRIGA+PASTA+CAMPO",,,"Criando Arquivo Trabalho...")

ProcRegua(0)
For nX := 1 To Len(aModCamp) 
	IncProc("Carregando Campos")
	DbSelectArea("SX3")
	DBSetOrder(1)
	If SX3->(DBSEEK("AIB"))
		Do While SX3->(!EOF()) .and. SX3->X3_ARQUIVO == "AIB"		
			if X3Uso(SX3->X3_USADO,aModCamp[nX][1]) .And. (SX3->X3_CONTEXT != "V" .Or. Alltrim(SX3->X3_CAMPO) $ cMemos )  
				_nPosFil := ASCAN(aNotFields, { |x| UPPER(x) == Alltrim(SX3->X3_CAMPO) })
				If _nPosFil <= 0
					//Verifica se o campo jแ existe para nใo duplicar
					_nPos := AScan(aFields, SX3->X3_CAMPO)
					If _nPos <= 0						
						AADD(aFields,SX3->X3_CAMPO)
						RecLock("fMARK",.T.)
						fMARK->OK 		:= Space(02)
						fMARK->CAMPO 	:= SX3->X3_CAMPO
						fMARK->TITULO 	:= SX3->X3_TITULO
						fMARK->TIPO 	:= SX3->X3_TIPO
						if X3Obrigat(SX3->X3_CAMPO)
							fMARK->OBRIGA 	:= "1-Sim"
						else
							fMARK->OBRIGA 	:= "1-Sim" //NESTE CASO TODOS CAMPOS SรO OBRIGATORIOS
						endif
						
						cFolder := Posicione("SXA",1,"AIB"+SX3->X3_FOLDER,"XA_DESCRIC")
						if Len(alltrim(cFolder)) == 0
							cFolder := 'OUTROS'
						endif
						fMARK->PASTA 	:= cFolder
						fMARK->MODULO	:= aModCamp[nX][2]
						fMARK->(MSUNLOCK())
					Endif
				Endif
			endif
			SX3->(DBSKIP())
		Enddo
	Endif
Next nX

AADD(aCampos,{"OK"		,,""})
AADD(aCampos,{"CAMPO"	,,"Campo"})
AADD(aCampos,{"TITULO"	,,"Titulo"})
AADD(aCampos,{"TIPO"	,,"Tipo"})
AADD(aCampos,{"PASTA"	,,"Pasta"})
AADD(aCampos,{"OBRIGA"	,,"Obrigatorio"})
AADD(aCampos,{"MODULO"	,,"Modulo"})

fMark->(DbGotop())
cMarca := GetMark()
Do While fMark->(!EOF())
	RecLock("fMark",.F.)
	fMark->OK := cMarca
	fMark->(MsUnlock())
	fMark->(DbSkip())
Enddo

fMark->(DbGotop())
cMarca := GetMark()

aAdd( aRotina ,{"Inverte Selec."  , "u_DIMPSB1S()" , 0, 1 })
aAdd( aRotina ,{"Gerar Planilha"  , "Processa({|| u_DIMPSB1P()()},'Gerando Modelo de Importa็ใo, aguarde...')" , 0 ,2 })

MARKBROWSE('fMark','OK',,aCampos,.F.,@cMarca,"u_MarkAllSB1()",,,,'u_DIMPSB1S()',{|| u_MarkAllSB1()})
DbCloseArea() // fecha a tabela temporแria
MsErase(cFileMark+GetDBExtension(),,"DBFCDX")	// apaga a tabela temporแria

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMarkAllSB1บAutor  ณ Marcio Gois        บ Data ณ  19/12/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Marcacao dos Campos.                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ULMA                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
User Function MarkAllSB1()
Local oMark := GetMarkBrow()
dbSelectArea('fMark')
dbGotop()
While !Eof()
	u_DIMPSB1S()
	dbSkip()
End
MarkBRefresh( )		// atualiza o browse
oMark:oBrowse:Gotop()	// for็a o posicionamento do browse no primeiro registro
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DIMPSB1P บAutor  ณ Marcio Gois        บ Data ณ  19/12/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Geracao de planilha modelo pra Importacao                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ULMA                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
User Function DIMPSB1P

Local cLinha := ""
Local aMemos:={{}}

ProcRegua(0)
cLinha :='<?xml version="1.0"?>'+cEol
cLinha +='<?mso-application progid="Excel.Sheet"?>'+cEol
cLinha +='<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"'+cEol
cLinha +=' xmlns:o="urn:schemas-microsoft-com:office:office"'+cEol
cLinha +=' xmlns:x="urn:schemas-microsoft-com:office:excel"'+cEol
cLinha +=' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"'+cEol
cLinha +=' xmlns:html="http://www.w3.org/TR/REC-html40">'+cEol
cLinha +=' <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">'+cEol
cLinha +='  <Author>DELTA</Author>'+cEol
cLinha +='  <LastAuthor>DELTA</LastAuthor>'+cEol
cLinha +='  <Created>2018-11-01T01:56:36Z</Created>'+cEol
cLinha +='  <Version>12.00</Version>'+cEol
cLinha +=' </DocumentProperties>'+cEol
cLinha +=' <ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">'+cEol
cLinha +='  <WindowHeight>7965</WindowHeight>'+cEol
cLinha +='  <WindowWidth>15315</WindowWidth>'+cEol
cLinha +='  <WindowTopX>120</WindowTopX>'+cEol
cLinha +='  <WindowTopY>150</WindowTopY>'+cEol
cLinha +='  <ProtectStructure>False</ProtectStructure>'+cEol
cLinha +='  <ProtectWindows>False</ProtectWindows>'+cEol
cLinha +=' </ExcelWorkbook>'+cEol
cLinha +=' <Styles>'+cEol
cLinha +='  <Style ss:ID="Default" ss:Name="Normal">'+cEol
cLinha +='   <Alignment ss:Vertical="Bottom"/>'+cEol
cLinha +='   <Borders/>'+cEol
cLinha +='   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>'+cEol
cLinha +='   <Interior/>'+cEol
cLinha +='   <NumberFormat/>'+cEol
cLinha +='   <Protection/>'+cEol
cLinha +='  </Style>'+cEol
cLinha +='  <Style ss:ID="s62">'+cEol
cLinha +='   <NumberFormat ss:Format="@"/>'+cEol
cLinha +='  </Style>'+cEol
cLinha +='  <Style ss:ID="s63">'+cEol
cLinha +='   <Borders>'+cEol
cLinha +='    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"'+cEol
cLinha +='     ss:Color="#FFFFFF"/>'+cEol
cLinha +='    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+cEol
cLinha +='    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"'+cEol
cLinha +='     ss:Color="#FFFFFF"/>'+cEol
cLinha +='    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+cEol
cLinha +='   </Borders>'+cEol
cLinha +='   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF"/>'+cEol
cLinha +='   <Interior ss:Color="#17375D" ss:Pattern="Solid"/>'+cEol
cLinha +='   <NumberFormat ss:Format="@"/>'+cEol
cLinha +='  </Style>'+cEol
cLinha +='  <Style ss:ID="s64">'+cEol
cLinha +='   <Borders>'+cEol
cLinha +='    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"'+cEol
cLinha +='     ss:Color="#FFFFFF"/>'+cEol
cLinha +='    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"'+cEol
cLinha +='     ss:Color="#FFFFFF"/>'+cEol
cLinha +='    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"'+cEol
cLinha +='     ss:Color="#FFFFFF"/>'+cEol
cLinha +='    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+cEol
cLinha +='   </Borders>'+cEol
cLinha +='   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF"/>'+cEol
cLinha +='   <Interior ss:Color="#17375D" ss:Pattern="Solid"/>'+cEol
cLinha +='   <NumberFormat ss:Format="@"/>'+cEol
cLinha +='  </Style>'+cEol
cLinha +='  <Style ss:ID="s65">'+cEol
cLinha +='   <Borders>'+cEol
cLinha +='    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"'+cEol
cLinha +='     ss:Color="#FFFFFF"/>'+cEol
cLinha +='    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"'+cEol
cLinha +='     ss:Color="#FFFFFF"/>'+cEol
cLinha +='    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"'+cEol
cLinha +='     ss:Color="#FFFFFF"/>'+cEol
cLinha +='    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+cEol
cLinha +='   </Borders>'+cEol
cLinha +='   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF"/>'+cEol
cLinha +='   <Interior ss:Color="#17375D" ss:Pattern="Solid"/>'+cEol
cLinha +='  </Style>'+cEol
cLinha +='  <Style ss:ID="s66">'+cEol
cLinha +='   <Borders>'+cEol
cLinha +='    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"'+cEol
cLinha +='     ss:Color="#FFFFFF"/>'+cEol
cLinha +='    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"'+cEol
cLinha +='     ss:Color="#FFFFFF"/>'+cEol
cLinha +='    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+cEol
cLinha +='   </Borders>'+cEol
cLinha +='   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF"/>'+cEol
cLinha +='   <Interior ss:Color="#17375D" ss:Pattern="Solid"/>'+cEol
cLinha +='  </Style>'+cEol
cLinha +='  <Style ss:ID="s67">'+cEol
cLinha +='   <Borders>'+cEol
cLinha +='    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"'+cEol
cLinha +='     ss:Color="#FFFFFF"/>'+cEol
cLinha +='    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+cEol
cLinha +='    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"'+cEol
cLinha +='     ss:Color="#FFFFFF"/>'+cEol
cLinha +='    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"'+cEol
cLinha +='     ss:Color="#FFFFFF"/>'+cEol
cLinha +='   </Borders>'+cEol
cLinha +='   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFF00"/>'+cEol
cLinha +='   <Interior ss:Color="#4F81BD" ss:Pattern="Solid"/>'+cEol
cLinha +='   <NumberFormat ss:Format="@"/>'+cEol
cLinha +='  </Style>'+cEol
cLinha +='  <Style ss:ID="s68">'+cEol
cLinha +='   <Borders>'+cEol
cLinha +='    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"'+cEol
cLinha +='     ss:Color="#FFFFFF"/>'+cEol
cLinha +='    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"'+cEol
cLinha +='     ss:Color="#FFFFFF"/>'+cEol
cLinha +='    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"'+cEol
cLinha +='     ss:Color="#FFFFFF"/>'+cEol
cLinha +='    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"'+cEol
cLinha +='     ss:Color="#FFFFFF"/>'+cEol
cLinha +='   </Borders>'+cEol
cLinha +='   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF"/>'+cEol
cLinha +='   <Interior ss:Color="#4F81BD" ss:Pattern="Solid"/>'+cEol
cLinha +='   <NumberFormat ss:Format="@"/>'+cEol
cLinha +='  </Style>'+cEol
cLinha +='  <Style ss:ID="s69">'+cEol
cLinha +='   <Borders>'+cEol
cLinha +='    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"'+cEol
cLinha +='     ss:Color="#FFFFFF"/>'+cEol
cLinha +='    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"'+cEol
cLinha +='     ss:Color="#FFFFFF"/>'+cEol
cLinha +='    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"'+cEol
cLinha +='     ss:Color="#FFFFFF"/>'+cEol
cLinha +='    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"'+cEol
cLinha +='     ss:Color="#FFFFFF"/>'+cEol
cLinha +='   </Borders>'+cEol
cLinha +='   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF"/>'+cEol
cLinha +='   <Interior ss:Color="#4F81BD" ss:Pattern="Solid"/>'+cEol
cLinha +='  </Style>'+cEol
cLinha +='  <Style ss:ID="s70">'+cEol
cLinha +='   <Borders>'+cEol
cLinha +='    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"'+cEol
cLinha +='     ss:Color="#FFFFFF"/>'+cEol
cLinha +='    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"'+cEol
cLinha +='     ss:Color="#FFFFFF"/>'+cEol
cLinha +='    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"'+cEol
cLinha +='     ss:Color="#FFFFFF"/>'+cEol
cLinha +='   </Borders>'+cEol
cLinha +='   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF"/>'+cEol
cLinha +='   <Interior ss:Color="#4F81BD" ss:Pattern="Solid"/>'+cEol
cLinha +='  </Style>'+cEol
cLinha +='  <Style ss:ID="s72">'+cEol
cLinha +='   <NumberFormat ss:Format="Standard"/>'+cEol
cLinha +='  </Style>'+cEol
cLinha +='  <Style ss:ID="s73">'+cEol
cLinha +='   <NumberFormat ss:Format="Short Date"/>'+cEol
cLinha +='  </Style>'+cEol
cLinha +='  <Style ss:ID="s75">'+cEol
cLinha +='   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>'+cEol
cLinha +='  </Style>'+cEol
cLinha +=' </Styles>'+cEol
cLinha +=' <Worksheet ss:Name="Importacao">'+cEol

fMark->(DbGotop())
nCols := 0
Do While fMark->(!EOF())
	nCols++
	fMark->(DbSkip())
Enddo

cLinha +='  <Table ss:ExpandedColumnCount="'+alltrim(str(nCols * 5))+'" ss:ExpandedRowCount="65536" x:FullColumns="1"'+cEol
cLinha +='   x:FullRows="1" ss:DefaultRowHeight="15">'+cEol
cLinha +='   <Column ss:StyleID="s62" ss:Width="50.25"/>'+cEol
cLinha +='   <Column ss:StyleID="s62" ss:Width="54.75"/>'+cEol
cLinha +='   <Column ss:Width="52.5"/>'+cEol
cLinha +='   <Column ss:Width="56.25"/>'+cEol

//Campo
cLinha +='   <Row ss:AutoFitHeight="0">'+cEol
fMark->(DbGotop())
Do While fMark->(!EOF())
	if fMark->OK <> cMarca
		fMark->(DbSkip())
		Loop
	endif
	
	if fMARK->TIPO == "N"
		cLinha +='    <Cell ss:StyleID="s65"><Data ss:Type="String">'+alltrim(fMARK->CAMPO)+'</Data></Cell>'+cEol
	elseif fMARK->TIPO == "D"
		cLinha +='    <Cell ss:StyleID="s66"><Data ss:Type="String">'+alltrim(fMARK->CAMPO)+'</Data></Cell>'+cEol
	else
		cLinha +='    <Cell ss:StyleID="s63"><Data ss:Type="String">'+alltrim(fMARK->CAMPO)+'</Data></Cell>'+cEol
	endif
	
	fMark->(DbSkip())
Enddo
cLinha +='   </Row>'+cEol

//Titulo
cLinha +='   <Row ss:AutoFitHeight="0">'+cEol
fMark->(DbGotop())
Do While fMark->(!EOF())
	if fMark->OK <> cMarca
		fMark->(DbSkip())
		Loop
	endif
	
	if fMARK->TIPO == "N"
		cLinha +='    <Cell ss:StyleID="s68"><Data ss:Type="String">'+alltrim(EnCodeUtf8(NoAcento(fMARK->TITULO)))+iif(fMARK->OBRIGA=='1-Sim',' (*)','')+'</Data></Cell>'+cEol
	elseif fMARK->TIPO == "D"
		cLinha +='    <Cell ss:StyleID="s68"><Data ss:Type="String">'+alltrim(EnCodeUtf8(NoAcento(fMARK->TITULO)))+iif(fMARK->OBRIGA=='1-Sim',' (*)','')+'</Data></Cell>'+cEol
	else
		cLinha +='    <Cell ss:StyleID="s68"><Data ss:Type="String">'+alltrim(EnCodeUtf8(NoAcento(fMARK->TITULO)))+iif(fMARK->OBRIGA=='1-Sim',' (*)','')+'</Data></Cell>'+cEol
	endif
	
	fMark->(DbSkip())
Enddo
cLinha +='   </Row>'+cEol

aLinhas := {}
aadd(aLinhas,cLinha)

_cQry := " SELECT TOP 1 * FROM "+RETSQLNAME("AIB")+" WHERE D_E_L_E_T_='' "

If Select ("TSQL")>0
	TSQL->(dbCloseArea())
Endif

TCQUERY _cQry NEW ALIAS "TSQL"

//Conteudo
dbSelectArea("TSQL")
TSQL->(dbGoTop())
While TSQL->(!Eof())
	IncProc("Gerando Planilha")	

	cMsg := ""
	cRows :='   <Row>'+cEol
	dbSelectArea("fMark")
	fMark->(DbGotop())
	Do While fMark->(!EOF())
		if fMark->OK <> cMarca
			fMark->(DbSkip())
			Loop
		endif
		if fMARK->TIPO == "N"
			cRows +='    <Cell ss:StyleID="s72"><Data ss:Type="Number">'+Alltrim(str(&("TSQL->"+fMARK->CAMPO)))+'</Data></Cell>'+cEol
		elseif fMARK->TIPO == "D"
			cRows +='    <Cell ss:StyleID="s73"><Data ss:Type="String">'+DTOC(STOD(&("TSQL->"+fMARK->CAMPO)))+'</Data></Cell>'+cEol
		elseif fMARK->TIPO == "M"
			_nPos := aScan(aMemos,{|x| upper(AllTrim(x[2]))==Alltrim(fMARK->CAMPO)})
			IF _nPos > 0
				cMsg := MSMM(&("SB1->"+aMemos[_nPos][1]))
			Endif
			cRows +='    <Cell ss:StyleID="s73"><Data ss:Type="String">'+cMsg+'</Data></Cell>'+cEol
		else
			cRows +='    <Cell><Data ss:Type="String">'+&("TSQL->"+fMARK->CAMPO)+'</Data></Cell>'+cEol
		endif
		fMark->(DbSkip())
	Enddo
	cRows +='   </Row>'+cEol
	aadd(aLinhas,cRows)
	
	dbSelectArea("TSQL")
	TSQL->(DbSkip())
Enddo

cLinha :='  </Table>'+cEol
cLinha +='  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">'+cEol
cLinha +='   <PageSetup>'+cEol
cLinha +='    <Header x:Margin="0.31496062000000002"/>'+cEol
cLinha +='    <Footer x:Margin="0.31496062000000002"/>'+cEol
cLinha +='    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"'+cEol
cLinha +='     x:Right="0.511811024" x:Top="0.78740157499999996"/>'+cEol
cLinha +='   </PageSetup>'+cEol
cLinha +='   <Unsynced/>'+cEol
cLinha +='   <Print>'+cEol
cLinha +='    <ValidPrinterInfo/>'+cEol
cLinha +='    <PaperSizeIndex>9</PaperSizeIndex>'+cEol
cLinha +='    <HorizontalResolution>1200</HorizontalResolution>'+cEol
cLinha +='    <VerticalResolution>1200</VerticalResolution>'+cEol
cLinha +='   </Print>'+cEol
cLinha +='   <Selected/>'+cEol
cLinha +='   <Panes>'+cEol
cLinha +='    <Pane>'+cEol
cLinha +='     <Number>3</Number>'+cEol
cLinha +='     <ActiveRow>5</ActiveRow>'+cEol
cLinha +='     <ActiveCol>4</ActiveCol>'+cEol
cLinha +='    </Pane>'+cEol
cLinha +='   </Panes>'+cEol
cLinha +='   <ProtectObjects>False</ProtectObjects>'+cEol
cLinha +='   <ProtectScenarios>False</ProtectScenarios>'+cEol
cLinha +='  </WorksheetOptions>'+cEol
cLinha +=' </Worksheet>'+cEol
cLinha +='</Workbook>'+cEol
aadd(aLinhas,cLinha)

cArqTxt := CriaTrab(NIL,.F.)
cArqTxt := Alltrim(cArqTxt)+".XML"
n_arq   := fcreate(cArqTxt)
cPath := AllTrim(GetTempPath())
cEol	:= CHR(13)+CHR(10)

For nI := 1 to len(aLinhas)
	cLinha := aLinhas[nI]
	fWrite(n_arq,cLinha+cEol)
Next
oExcelApp   := NIL
fclose(n_arq)
CpyS2T( cArqTxt, cPath, .F. )

oExcelApp	:= MsExcel():New()
oExcelApp	:WorkBooks:Open(cPath+cArqTxt)
oExcelApp	:SetVisible(.T.)
lIntExcel	:= .T.

CloseBrowse()
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DIMPSB1V บAutor  ณMarcio Gois         บ Data ณ  19/12/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina que Le o Excel e valida os produtos                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ULMA                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIMPSB1V()

Local cBuffer	:= ''
Local cFile		:= ''
Local aCells	:= {} //array com as celulas a serem lidas
Local nI		:= 0
Local nCelini   := 11 //posicao da primeira celula com valor
Local cPasta    := "Importacao" //nome da pasta dentro da planilha

Private bCampo	:= {|x| FieldName(x) }
Private aTela[0][0]
Private aGets[0]
Private aHeadAIB := {}
Private aColsAIB := {}
Private aImpAIB  := {}

aAltera := {}
aEncAlt := {}

Pergunte(cPerg,.F.)

//Validar Parametros
//	O c๓digo do Fornecedor deve ter a consulta padrใo para pesquisa na tabela, e ao digitar diretamente deverแ validar o conte๚do correto.
//	A data de validade final nใo pode ser menor que a data inicial, assim se o usuแrio digitar essa condi็ใo deverแ aparecer uma mensagem bloqueando o conte๚do.
//	A moeda deve ser vแlida conforme cadastro de moedas padrใo do sistema.
dbSelectArea("SA2")
dbSetOrder(1)
If !SA2->(dbSeek(xFilial("SA2")+MV_PAR01+MV_PAR02))
	MsgStop("","Fornecedor nใo encontrado, revise os parametros!")
	Return
Else
	If MV_PAR04 <= MV_PAR03
		MsgStop("","A data de validade final nใo pode ser menor que a data inicial, revise os parametros!")
		Return	
	Endif
Endif

cFileOpen := cGetFile(cExtens,cTitulo1,0,,.T.,GETF_ONLYSERVER+GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE+GETF_OVERWRITEPROMPT)
If !File(cFileOpen)
	MsgAlert("Arquivo : "+cFileOpen+" nใo localizado",cCadastro)
	Return
Endif

nHdl    := ExecInDLLOpen("readexcel.dll")
cBuffer := ''
nCelini := 3  //posicao da primeira celula com valor
cCel 	:= "A" //letra da celula com o produto
cProd   := Space(08)
nQtde   := 0
aCells	:= {}

ProcRegua(0)
If ( nHdl >= 0 )
	
	// Carrega o Excel e Abre o arquivo
	cBuffer := cFileOpen + Space(512)
	nBytes  := ExeDLLRun2(nHdl, CMD_OPENWORKBOOK, @cBuffer)
	
	If ( nBytes < 0 )
		// Erro critico na abertura do arquivo sem msg de erro
		MsgStop('Nใo foi possivel abrir o arquivo : ' + cFileOpen)
	ElseIf ( nBytes > 0 )
		// Erro critico na abertura do arquivo com msg de erro
		MsgStop(Subs(cBuffer, 1, nBytes))
	EndIf
	
	// Seleciona a worksheet
	cBuffer := cPasta + Space(512)
	ExeDLLRun2(nHdl, CMD_ACTIVEWORKSHEET, @cBuffer)
	if substr(cBuffer,1,24) == "unknown error in command"
		
		MsgAlert( "A WORKSHEET ativa do excel deve se chamar 'Importacao'",cCadastro)
		
		// Fecha o arquivo e remove o excel da memoria
		cBuffer := Space(512)
		ExeDLLRun2(nHdl, CMD_CLOSEWORKBOOK, @cBuffer)
		ExecInDLLClose(nHdl)
		
		Return
	endif
	
	cCel1 := ""
	cCel2 := "A"
	nLin  := 1
	nCol  := 1
	
	aHeadAIB := {}
	aColsAIB := {}
	
	//Leitura do Cabecalho a ser importado
	while .T.
		IncProc("Lendo Campos")	
		
		// Verifica o Preco Unitario na Planilha e armazena na variavel
		cBuffer := cCel1+cCel2+alltrim(Str(nLin))+Space(1024)
		nBytes = ExeDLLRun2(nHdl, CMD_READCELL, @cBuffer)
		cValor := Subs(cBuffer, 1, nBytes)
		if len(alltrim(cValor)) == 0
			exit
		else
			//Gerando leitura de celulas para consistir campos a serem importados
			nCol++
			
			//Gerando aheader com campos a serem importados
			DBSelectArea("SX3")
			DBSetOrder(2)
			if DBSeek(PADR(cValor,10))
				aadd(aHeadAIB,{cCel1+cCel2,SX3->X3_CAMPO,SX3->X3_TIPO, SX3->X3_TAMANHO,SX3->X3_DECIMAL})
			endif
			
			if cCel2 <> "Z"
				cCel2 := Soma1(cCel2)
			else
				if cCel1 == ""
					cCel1 := "A"
				else
					cCel1 := Soma1(cCel1)
				endif
				cCel2 := "A"
			endif
		endif
		
	enddo
	
	//Leitura do Conteudo a ser importado
	nLin := 3
	while .T.
	IncProc("Lendo Conteudo")	
		// Verifica o a celula tem valor, se nใo tiver abandona os itens
		cBuffer := aHeadAIB[1][1]+alltrim(Str(nLin))+Space(1024)
		nBytes = ExeDLLRun2(nHdl, CMD_READCELL, @cBuffer)
		cValor := Subs(cBuffer, 1, nBytes)
		if Len(alltrim(cValor))==0
			exit
		endif
		
		aCampos := {}
		for nI := 1 to len(aHeadAIB)
			
			// Verifica o Preco Unitario na Planilha e armazena na variavel
			cBuffer := aHeadAIB[nI][1]+alltrim(Str(nLin))+Space(1024)
			nBytes = ExeDLLRun2(nHdl, CMD_READCELL, @cBuffer)
			cValor := Subs(cBuffer, 1, nBytes)
			
			if aHeadAIB[nI][3] <> ValType(cValor)
				if aHeadAIB[nI][3] == "C"
					if ValType(cValor) == "N"
						cValor := Alltrim(str(cValor))
					elseif ValType(cValor) == "D"
						cValor := DTOS(cValor)
					else
						cValor := ""
					end
				elseif aHeadAIB[nI][3] == "N"
					if ValType(cValor) == "C"
						cValor := val(cValor)
					elseif ValType(cValor) == "D"
						cValor := val(DTOS(cValor))
					else
						cValor := 0
					end
				elseif aHeadAIB[nI][3] == "D"
					if ValType(cValor) == "C"
						cValor := CTOD(cValor)
					else
						cValor := CTOD("")
					end
				endif
			endif
			
			
			aadd( aCampos, {aHeadAIB[nI][2],cValor,nil})
			If Alltrim(aHeadAIB[nI][2]) <>"AIB_CODPRO"
				aadd( aAltera, {aHeadAIB[nI][2],cValor,nil})
			Endif
			
		Next
		aadd(aColsAIB,aCampos)
		aadd(aEncAlt,aAltera)
		nLin++		
	enddo

	lImporta := .T.
	aErros := {}
	For nI := 1 to len( aColsAIB )
		IncProc("Validando Campos")	
		_cProdut := ""
		_nPosProd  := Ascan(aColsAIB[nI],{ |x| UPPER(Alltrim(x[1])) == "AIB_CODPRO" } )
		
		If _nPosProd > 0
			_cProdut := PadR(aColsAIB[nI][_nPosProd][2],15)
		Endif
		
		_cChvSB1 := xFilial("SB1") + _cProdut
		dbSelectArea("SB1")
		SB1->(dbSetorder(1))   //B1_FILIAL + B1_COD
		SB1->(dbGoTop())
		If !SB1->(dbSeek(_cChvSB1))
			aadd(aErros,{StrZero(nI+2,6),"ERRO","Produto "+Alltrim(_cProdut)+" nใo localizado no cadastro.",.F.})
		Else
			AADD(aImpAIB, aColsAIB[nI])
		Endif
	Next
	
	// Fecha o arquivo e remove o excel da memoria
	cBuffer := Space(512)
	ExeDLLRun2(nHdl, CMD_CLOSEWORKBOOK, @cBuffer)
	
	ExecInDLLClose(nHdl)
Else
	MsgStop('Nao foi possivel carregar a DLL')
	Return
EndIf

oGetErr:aCols := aErros
oGetErr:refresh()

If Len(aErros) > 0
	_cMsgAviso := "O arquivo possui erros, verifique o Log"
Else
	_cMsgAviso := "Planilha Validada com Sucesso"
Endif

If MSGBOX("Confirma Importa็ใo?",_cMsgAviso,"YESNO")
	Processa({|| u_DIMPSB1I(cFileOpen)},"Importando Produtos, aguarde...")
endif

Return {lImporta,aErros}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DIMPSB1I บAutor  ณMarcio Gois         บ Data ณ  19/12/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de ExecAuto de Produtos                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ULMA                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIMPSB1I(cArqExcel)
Local _lErro 	:= .F.
Local aCabec    := {}
Local aItens	:= {}
Local nOpc		:= 3
PRIVATE lMsErroAuto := .F.
	
Pergunte(cPerg,.F.)

cFornec	  := MV_PAR01
cLoja	  := MV_PAR02
dDataDe   := MV_PAR03
dDataAte  := MV_PAR04
nMoeda	  := MV_PAR05
aRetCTab  := URETPTAB(cFornec,cLoja)
cTabAtu	  := aRetCTab[1]
cCodTab	  := aRetCTab[2]
cNomTab	  := cCodTab+" "+GetAdvfVal("SA2","A2_NOME",xFilial("SA2")+cFornec+cLoja,1,"") 

aCabec := {}
aadd(aCabec,{"AIA_CODFOR",	cFornec,})
aadd(aCabec,{"AIA_LOJFOR",	cLoja,})
aadd(aCabec,{"AIA_CODTAB",	cCodTab,})
aadd(aCabec,{"AIA_DESCRI",	cNomTab,})
aadd(aCabec,{"AIA_DATDE",	dDataDe,})
aadd(aCabec,{"AIA_DATATE",	dDataAte,})
aadd(aCabec,{"AIA_XARQUI",	cArqExcel,})

For nI := 1 to Len( aImpAIB )

	_nPosProd  := Ascan(aImpAIB[1],{ |x| UPPER(Alltrim(x[1])) == "AIB_CODPRO" } )
	_nPosPrec  := Ascan(aImpAIB[1],{ |x| UPPER(Alltrim(x[1])) == "AIB_PRCCOM" } )
		
	dbSelectArea("SB1")
	SB1->(dbSetorder(1)) //B1_FILIAL + B1_COD
	SB1->(dbSeek(xFilial("SB1")+PadR(aImpAIB[nI][_nPosProd][2],15)))
		
	aItAux := {}
	AAdd( aItAux, {"AIB_CODPRO" ,SB1->B1_COD	  			,Nil} ) // Numero do Item no Pedido
	AAdd( aItAux, {"AIB_DESCRI"	,SB1->B1_DESC				,Nil} ) // Codigo do Produto
	AAdd( aItAux, {"AIB_PRCCOM" ,aImpAIB[nI][_nPosPrec][2]	,Nil} ) // Quantidade Vendida
	AAdd( aItAux, {"AIB_DATVIG" ,dDataAte		   			,Nil} ) // PRECO DE LISTA
	AAdd( aItAux, {"AIB_MOEDA"  ,nMoeda						,Nil} ) // Localizacao							
	aAdd(aItens, aItAux )
Next

lMsErroAuto := .F.
MSExecAuto({|x,y,z| COMA010(x,y,z)},nOpc,aCabec,aItens)

If lMsErroAuto
	DisarmTransaction()
	MostraErro()
	_lErro := .T.
Else

	//Copiar o arquivo importado para pasta Protheus_data/Tab_Preco_Forn e renomear com usuแrio+data+hora+minuto+segundo.	
	//Cria o diret๓rio base caso nใo exista
	If !ExistDir( cDirPad )  //verifica se a pasta existe 
		MakeDir( cDirPad ) //cria a pasta
	Endif     	

	//Copia o arquivo para Pasta de Tab_Preco	
	_cArqImp := Substr(cArqExcel, RAT("\",cArqExcel)+1) 
	_cArqRename := cUserName+"_"+DTOS(date()) + '_' + StrTran(Time(),':','')+"_"+_cArqImp
	
	__CopyFile(cFileOpen, cDirPad+_cArqImp )
	Sleep(1000)
	
	//Renomeia o arquivo
	FRenameEx(cDirPad+_cArqImp, cDirPad+_cArqRename)
	

	//Ao importar uma nova tabela, inativar a tabela anterior.
	dbSelectArea("AIA")
	dbSetOrder(1) //AIA_FILIAL + AIA_CODFOR + AIA_LOJFOR + AIA_CODTAB
	cChvAIA := xFilial("AIA")+cFornec+cLoja+cTabAtu
	If AIA->(dbSeek( cChvAIA ))
		While AIA->(!Eof()) .And. AIA->(AIA_FILIAL + AIA_CODFOR + AIA_LOJFOR + AIA_CODTAB) == cChvAIA
			Reclock("AIA", .F.)
			AIA->AIA_DATATE := DATE()
			AIA->(msUnlock())
			AIA->(dbSkip())
		Enddo
	Endif
	
	dbSelectArea("AIB")
	dbSetOrder(1) //AIB_FILIAL + AIB_CODFOR + AIB_LOJFOR + AIB_CODTAB + AIB_ITEM
	cChvAIB := xFilial("AIB")+cFornec+cLoja+cTabAtu
	If AIB->(dbSeek( cChvAIB ))
		While AIB->(!Eof()) .And. AIB->(AIB_FILIAL + AIB_CODFOR + AIB_LOJFOR + AIB_CODTAB) == cChvAIB
			Reclock("AIB", .F.)
			AIB->AIB_DATVIG := DATE()
			AIB->(msUnlock())
			AIB->(dbSkip())
		Enddo
	Endif
	
	
	//Ao t้rmino da inclusใo da tabela a rotina deverแ pesquisar todos os produtos do fornecedor em questใo na 
	//tabela SA5 atualizando o campo Tab.Pre็o (A5_CODTAB) com a tabela que acabou de ser importada com sucesso.
	dbSelectArea("SA5")
	dbSetOrder(1) //A5_FILIAL + A5_FORNECE + A5_LOJA + A5_PRODUTO + A5_FABR + A5_FALOJA
	cChvSA5 := xFilial("SA5")+cFornec+cLoja
	If SA5->(dbSeek( cChvSA5 ))
		While SA5->(!Eof()) .And. SA5->(A5_FILIAL + A5_FORNECE + A5_LOJA) == cChvSA5
			Reclock("SA5", .F.)
			SA5->A5_CODTAB := cCodTab
			SA5->(msUnlock())
			SA5->(dbSkip())
		Enddo
	Endif	
			
EndIf

If !_lErro
	MsgAlert("","Importa็ใo Realizada com Sucesso!")
	oDlgImp:End()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DIMPSB1S บAutor  ณMarcio Gois         บ Data ณ  19/12/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de ExecAuto de Produtos                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ULMA                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function DIMPSB1S()

If IsMark("OK",cMarca)
	RecLock("fMARK",.F.)
	fMARK->OK := Space(02)
	fMARK->(MsUnlock())
Else
	RecLock("fMARK",.F.)
	fMARK->OK := cMarca
	fMARK->(MsUnlock())
Endif

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNoAcento  บAutor Marcio Gois           บ Data ณ  19/12/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retirada dos Acentos                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ULMA                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function NoAcento(cString)
Local cChar  := ""
Local nX     := 0 
Local nY     := 0
Local cVogal := "aeiouAEIOU"
Local cAgudo := "แ้ํ๓๚"+"มษอำฺ"
Local cCircu := "โ๊๎๔๛"+"ยสฮิÛ"
Local cTrema := "ไ๋๏๖ü"+"ฤหฯึÜ"
Local cCrase := "เ่์๒๙"+"ภศฬาู" 
Local cTio   := "ใ๕"
Local cCecid := "็ว"

For nX:= 1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
		nY:= At(cChar,cAgudo)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCircu)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTrema)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCrase)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf		
		nY:= At(cChar,cTio)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("ao",nY,1))
		EndIf		
		nY:= At(cChar,cCecid)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("cC",nY,1))
		EndIf
	Endif
Next
For nX:=1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	If Asc(cChar) < 32 .Or. Asc(cChar) > 123
		cString:=StrTran(cString,cChar,".")
	Endif
Next nX
Return cString


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ ValPerg ณ Autor ณ MARCIO GOIS            ณ Data ณ 10/06/13 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ IMPRESSAO DO RELATORIO                                      ฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ValPerg()

Local _sAlias	:= Alias()
Local aCposSX1	:= {}
Local aPergs	:= {}
Local nX 		:= 0
Local lAltera	:= .F.
Local nCondicao
Local cKey		:= ""
Local nJ		:= 0

Aadd(aPergs,{"Fornecedor          ?","","","mv_ch1","C",06,0,0,"G","Vazio() .Or. ExistCPO('SA2') ","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","SA2A","","","",""})
Aadd(aPergs,{"Loja                ?","","","mv_ch2","C",02,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Validade Inicial    ?","","","mv_ch3","D",08,0,0,"G","","MV_PAR03","","","","01/01/18","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Validade Final      ?","","","mv_ch4","D",08,0,0,"G","","MV_PAR04","","","","31/12/18","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Moeda               ?","","","mv_ch5","N",01,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

aCposSX1:={"X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO",;
			"X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID",;
			"X1_VAR01","X1_DEF01","X1_DEFSPA1","X1_DEFENG1","X1_CNT01",;
			"X1_VAR02","X1_DEF02","X1_DEFSPA2","X1_DEFENG2","X1_CNT02",;
			"X1_VAR03","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_CNT03",;
			"X1_VAR04","X1_DEF04","X1_DEFSPA4","X1_DEFENG4","X1_CNT04",;
			"X1_VAR05","X1_DEF05","X1_DEFSPA5","X1_DEFENG5","X1_CNT05",;
			"X1_F3", "X1_GRPSXG", "X1_PYME","X1_HELP" }

dbSelectArea("SX1")
dbSetOrder(1)
For nX:=1 to Len(aPergs)
	lAltera := .F.
	If MsSeek(cPerg+Right(aPergs[nX][11], 2))
		If (ValType(aPergs[nX][Len(aPergs[nx])]) = "B" .And.;
			Eval(aPergs[nX][Len(aPergs[nx])], aPergs[nX] ))
			aPergs[nX] := ASize(aPergs[nX], Len(aPergs[nX]) - 1)
			lAltera := .T.
		Endif
	Endif
	
	If ! lAltera .And. Found() .And. X1_TIPO <> aPergs[nX][5]
		lAltera := .T.		// Garanto que o tipo da pergunta esteja correto
	Endif
	
	If ! Found() .Or. lAltera
		RecLock("SX1",If(lAltera, .F., .T.))
		Replace X1_GRUPO with cPerg
		Replace X1_ORDEM with Right(aPergs[nX][11], 2)
		For nj:=1 to Len(aCposSX1)
			If 	Len(aPergs[nX]) >= nJ .And. aPergs[nX][nJ] <> Nil .And.;
				FieldPos(AllTrim(aCposSX1[nJ])) > 0
				Replace &(AllTrim(aCposSX1[nJ])) With aPergs[nx][nj]
			Endif
		Next nj
		MsUnlock()
		cKey := "P."+AllTrim(X1_GRUPO)+AllTrim(X1_ORDEM)+"."
		
		If ValType(aPergs[nx][Len(aPergs[nx])]) = "A"
			aHelpSpa := aPergs[nx][Len(aPergs[nx])]
		Else
			aHelpSpa := {}
		Endif
		
		If ValType(aPergs[nx][Len(aPergs[nx])-1]) = "A"
			aHelpEng := aPergs[nx][Len(aPergs[nx])-1]
		Else
			aHelpEng := {}
		Endif
		
		If ValType(aPergs[nx][Len(aPergs[nx])-2]) = "A"
			aHelpPor := aPergs[nx][Len(aPergs[nx])-2]
		Else
			aHelpPor := {}
		Endif
		
		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)
	Endif
Next

Return


Static Function URETPTAB(_cForce,_cLojFor)
Local cQry 		:= ""
Local cProxTab	:= "001"
Local cTabAtua	:= ""

cQry := " SELECT ISNULL(MAX(AIA_CODTAB),'000') AIA_CODTAB " 
cQry += " FROM "+RetSqlName("AIA")
cQry += " WHERE D_E_L_E_T_='' AND AIA_FILIAL='"+xFilial("AIA")+"' " 
cQry += " AND AIA_CODFOR='"+_cForce+"' AND AIA_LOJFOR='"+_cLojFor+"' "

If Select ("TSQLAIA")>0
	TSQLAIA->(dbCloseArea())
Endif

TCQUERY cQry NEW ALIAS "TSQLAIA"

dbSelectArea("TSQLAIA")
TSQLAIA->(dbGoTop())
If TSQLAIA->(Bof()) .And. TSQLAIA->(Eof())
	cProxTab	:= "001"
Else
	cTabAtua	:= TSQLAIA->AIA_CODTAB
	cProxTab	:= Soma1(TSQLAIA->AIA_CODTAB)
Endif
		
Return {cTabAtua, cProxTab} 

