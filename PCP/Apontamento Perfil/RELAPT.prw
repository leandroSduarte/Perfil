#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TbiConn.ch"

/*-------------------------------------------------------------------------------------
{Protheus.doc} RELAPT

@Author  	   Felipe Aguiar - Focus Consultoria
@since		   03/2019
@version	   P12

@description Relatorio Apontamentos de OP
---------------------------------------------------------------------------------------
|Author                  | Date       | Description                                    |
|                        |            |                                                |
--------------------------------------------------------------------------------------*/
User Function RELAPT(a_Dados)

Local a_Area     	    := GetArea()
Local c_EOL     	 	:= CHR(13) + CHR(10)
Local a_Cpos    		:= {}
Local c_ArqTrab
Local c_Order                                	
Local c_StartPat		:= CURDIR() // \System\
Local c_ExtTemp 		:= ".DBF" 

Private a_PosCpo 	:= {}

If Select("TBTMPA") > 0
	dbSelectArea("TBTMPA") //Fecha a tabela temporaria
	dbCloseArea()
EndIf


aAdd(a_Cpos,{"OP"	    ,"C",14,00}) 
aAdd(a_Cpos,{"PRODUTO"	,"C",15,00}) 
aAdd(a_Cpos,{"DESCRI"	,"C",50,00})
aAdd(a_Cpos,{"OPERAC"	,"C",02,00})
aAdd(a_Cpos,{"DESC" 	,"C",20,00})
aAdd(a_Cpos,{"RECURSO"	,"C",06,00})
aAdd(a_Cpos,{"DTINI"	,"D",08,00})
aAdd(a_Cpos,{"HRINI"	,"C",05,00})
aAdd(a_Cpos,{"DTFIN"	,"D",08,00})
aAdd(a_Cpos,{"HRFIN"	,"C",05,00})
aAdd(a_Cpos,{"TEMPO"	,"C",06,00})
aAdd(a_Cpos,{"QTD"	    ,"N",16,02})
aAdd(a_Cpos,{"OPERAD"	,"C",10,00})
aAdd(a_Cpos,{"NOME"	    ,"C",50,00})

c_Order   := "OP"


c_ArqTrab := CriaTrab(a_Cpos,.T.)
dbUseArea(.T.,__LocalDriver,c_ArqTrab,"TBTMPA")
IndRegua("TBTMPA",c_ArqTrab+OrdBagExt(),c_Order) 

For n_item := 1 To Len(a_Dados)
		  		  
    Reclock("TBTMPA",.T.)
                
        TBTMPA->OP	            := a_Dados[n_item][1]
        TBTMPA->PRODUTO         := a_Dados[n_item][2]      
        TBTMPA->DESCRI	        := a_Dados[n_item][3]
        TBTMPA->OPERAC	        := a_Dados[n_item][4]
        TBTMPA->DESC	        := a_Dados[n_item][5]
        TBTMPA->RECURSO         := a_Dados[n_item][6]
        TBTMPA->DTINI	        := STOD(a_Dados[n_item][7])
        TBTMPA->HRINI	        := a_Dados[n_item][8]
        TBTMPA->DTFIN	        := STOD(a_Dados[n_item][9])
        TBTMPA->HRFIN	        := a_Dados[n_item][10]
        TBTMPA->TEMPO	        := a_Dados[n_item][11]
        TBTMPA->QTD	            := a_Dados[n_item][12]
        TBTMPA->OPERAD          := a_Dados[n_item][13]
        TBTMPA->NOME	        := a_Dados[n_item][14]

    TBTMPA->( MSUnlock() )		
			
Next n_item
	
If TBTMPA->( RecCount() ) > 0
	o_Report:= PERRELPORT()
	o_Report:PrintDialog()
Else
	MsgStop("Esta pesquisa não trouxe resultados","Vazio")
	Return(Nil)
EndIf	

If Select("TBTMPA") > 0
	dbSelectArea("TBTMPA") //Fecha a tabela temporaria
	dbCloseArea()
	FErase(c_StartPat+c_ArqTrab+c_ExtTemp) //Apaga o arquivo .dbf (tabela temporaria) gerado na \Sigaadv\
	FErase(c_StartPat+c_ArqTrab+OrdBagExt()) //Apaga o arquivo .idx (indice da tabela temporaria) gerado na \Sigaadv\
EndIf

RestArea(a_Area)  

Return Nil

/*-------------------------------------------------------------------------------------
{Protheus.doc} PERRELPORT³

@Author  	   Felipe Aguiar - Focus Consultoria
@since		   03/2019
@version	   P12

@description Chama o TReport para Impressao do relatorio.
---------------------------------------------------------------------------------------
|Author                  | Date       | Description                                    |
|                        |            |                                                |
--------------------------------------------------------------------------------------*/
Static Function PERRELPORT()

Local o_Report 
Local o_Section1
Local c_TitRel   := "Relatório - Apontamentos de Produção"

aAdd(a_PosCpo,{"OP"	    ,"OP"           ,"",14}) 
aAdd(a_PosCpo,{"PRODUTO","PRODUTO"      ,"",15}) 
aAdd(a_PosCpo,{"DESCRI"	,"DESCRICAO"    ,"",50})
aAdd(a_PosCpo,{"OPERAC"	,"OPERACAO"     ,"",02})
aAdd(a_PosCpo,{"DESC" 	,"DESCRICAO"    ,"",20})
aAdd(a_PosCpo,{"RECURSO","RECURSO"      ,"",06})
aAdd(a_PosCpo,{"DTINI"	,"DATA INICIAL" ,"",08})
aAdd(a_PosCpo,{"HRINI"	,"HORA INICIAL" ,"",05})
aAdd(a_PosCpo,{"DTFIN"	,"DATA FINAL"   ,"",08})
aAdd(a_PosCpo,{"HRFIN"	,"HORA FINAL"   ,"",05})
aAdd(a_PosCpo,{"TEMPO"	,"TEMPO"        ,"",06})
aAdd(a_PosCpo,{"QTD"	,"QUANTIDADE"   ,"",16})
aAdd(a_PosCpo,{"OPERAD"	,"OPERADOR"     ,"",10})
aAdd(a_PosCpo,{"NOME"	,"NOME"         ,"",50})

o_Report:= TReport():New("RELPORT",c_TitRel,,{ |o_Report| PERREPRINT(o_Report)},c_TitRel) 
o_Report:SetLandscape()
o_Report:SetTotalInLine(.F.)
o_Report:ShowHeader()

o_Section1:=TRSection():New(o_Report,c_TitRel,{"TBTMPA"})
o_Report:SetTotalInLine(.F.)


For i := 1 to Len(a_PosCpo)
	TRCell():New(o_Section1,a_PosCpo[i][1],"TBTMPA",a_PosCpo[i][2],a_PosCpo[i][3],a_PosCpo[i][4],,)
Next i


Return(o_Report)      


/*-------------------------------------------------------------------------------------
{Protheus.doc} PERREPRINT

@Author  	   Felipe Aguiar - Focus Consultoria
@since		   03/2019
@version	   P12

@description Carrega as variaveis para impressao do relatorio.
---------------------------------------------------------------------------------------
|Author                  | Date       | Description                                    |
|                        |            |                                                |
--------------------------------------------------------------------------------------*/
Static Function PERREPRINT(o_Report)

Local o_Section1 := o_Report:Section(1)

o_Section1:Init()


dbSelectArea("TBTMPA")
TBTMPA->( dbGotop() )

o_Report:SetMeter(TBTMPA->(RecCount()))


While TBTMPA->( !Eof() )

	For i := 1 to Len(a_PosCpo)
		o_Section1:Cell(a_PosCpo[i][1]):SetValue(&("TBTMPA->" + a_PosCpo[i][1]))
		o_Section1:Cell(a_PosCpo[i][1]):SetAlign("LEFT")	
	Next i
	
	o_Section1:PrintLine()
	TBTMPA->( dbSkip() )
		
EndDo
	
o_Section1:Finish()

Return