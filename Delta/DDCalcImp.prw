#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH" 

/*-------------------------------------------------------------------------------------
{Protheus.doc} DDCalcImp

@Author  	   Felipe Aguiar - Delta Decisao
@since	   	   11/2019
@version	   P12

@description  Função para calculo de impostos
----------------------------------------------------------------------------------------
|Author                  | Date       | Description                                    |
|                        |            |                                                |
----------------------------------------------------------------------------------------
*/

User Function DDCalcImp(_cImpProd, _cImpLocal, _cImpQuant, _cImpTES,_cValUnit,_cValTot,_OutImpostos,c_Cliente,c_loja,c_Tipo,d_Emissao,c_Cond,n_Frete,n_Seguro,n_Fretaut,n_Despesa,n_Pdescab,n_Descont,l_Prosp)
       
Local aSavAtu            := GetArea()
//Local aSavTMP1 := TMP1->(GetArea())
Local nValLiq            := 0

Local aArea              := GetArea()
Local aAreaSA1           := SA1->(GetArea())
//Local aAreaTMP1 := TMP1->(GetArea())
Local aTitles            := {"Nota Fiscal","Duplicatas","Rentabilidade"} //"Nota Fiscal"###"Duplicatas###"Rentabilidade"
Local aDupl              := {}
Local aFlHead            := { "Vencimento","Valor" } //"Vencimento"###"Valor"
Local aVencto            := {}
Local aRFHead            := { RetTitle("C6_PRODUTO"),RetTitle("C6_VALOR"),"C.M.V","Vlr.Presente","Lucro Bruto","Margem de Contribuição(%)"}//"C.M.V"###"Vlr.Presente"###"Lucro Bruto"###"Margem de Contribuição(%)"
Local aRentab            := {}
Local nX                 := 0
Local nAcerto            := 0
Local nPrcLista          := 0
Local nValMerc           := 0
Local nDesconto          := 0
Local nAcresFin          := 0
Local nQtdPeso           := 0
Local nItem              := 0
Local cParc              := ""
Local dDataCnd           := ""
Local lCondVenda         := .F.  // Template GEM - Se existe condicao de venda
Local lM415Ipi           := ExistBlock("M415IPI")
Local lM415Icm           := ExistBlock("M415ICM")
Local lM415Soli          := ExistBlock("M415SOLI")
Local oDlg  
Local oDupl
Local oFolder
Local oRentab
Local nValTotal          := 0 //Valor total utilizado no retorno quando lRetTotal for .T.
Local lProspect          := .F.
Local cTipo              := ""
Local a_Ret              := {}

Default _cImpProd        := cZM_CODGEN
Default _cImpLocal       := ""
Default _cImpQuant       := 1
Default _cImpTES         := cZM_TES
Default _OutImpostos     := {} 

Default c_Cliente       := ""
Default c_loja          := ""
Default c_Tipo          := ""
Default d_Emissao       := Date()
Default c_Cond          := ""
Default l_Prosp         := .F.

Default n_Frete          := 0
Default n_Seguro         := 0
Default n_Fretaut        := 0
Default n_Despesa        := 0
Default n_Pdescab        := 0
Default n_Descont        := 0


_nValIpi     := 0
_nValIcm     := 0
_nValPIS     := 0
_nValCOF     := 0
_nValST      := 0
_nValISS     := 0
_nValMer     := 0
_nValPS2     := 0
_nValCF2     := 0
_nValFec     := 0
_nValDifal   := 0
_nTotal      := 0

_nAliqIpi    := 0
_nAliqIcm    := 0
_nAliqPIS    := 0
_nAliqCOF    := 0
_nAliqST     := 0
_nAliqISS    := 0
_nAliqPS2    := 0
_nAliqCF2    := 0
_nAliqMargem := 0
_nAliqDest   := 0
_nAliqOrig   := 0
_nAliqFec    := 0


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona Registros                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 


dbSelectArea("SA1")
dbSetOrder(1)
MsSeek(xFilial("SA1")+c_Cliente+c_loja)

dbSelectArea("SE4")
dbSetOrder(1)
MsSeek(xFilial("SE4")+c_Cond)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa a funcao fiscal                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If l_Prosp
      If !Empty(SCJ->CJ_PROSPE) .And. !Empty(SCJ->CJ_LOJPRO)
            cTipo := Posicione("SUS",1,xFilial("SUS") + SCJ->CJ_PROSPE + SCJ->CJ_LOJPRO,"US_TIPO")
            lProspect := .T.
      Endif
EndIf

MaFisSave()
MaFisEnd()
MaFisIni(   SA1->A1_COD ,;// 1-Codigo Cliente/Fornecedor
            SA1->A1_LOJA ,;            // 2-Loja do Cliente/Fornecedor
            "C",;                      // 3-C:Cliente , F:Fornecedor
            "N",;                      // 4-Tipo da NF
            c_Tipo,;            // 5-Tipo do Cliente/Fornecedor 
            Nil,;
            Nil,;
            Nil,;
            Nil,;
            "MATA461",;
            Nil,;
            Nil,;
            IiF(lProspect,SCJ->CJ_PROSPE+SCJ->CJ_LOJPRO,""))

       //Iif(lProspect,cTipo,SA1->A1_TIPO),;         // 5-Tipo do Cliente/Fornecedor


//Na argentina o calculo de impostos depende da serie.
If cPaisLoc == 'ARG'
       MaFisAlt('NF_SERIENF',LocXTipSer('SA1',MVNOTAFIS))
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Agrega os itens para a funcao fiscal         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//dbSelectArea("TMP1")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a linha foi deletada                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( !Empty(_cImpProd) )
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³Posiciona Registros                          ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       SB1->(dbSetOrder(1))
       If SB1->(MsSeek(xFilial("SB1")+_cImpProd))
             nQtdPeso := _cImpQuant*SB1->B1_PESO
       EndIf
       
       if Empty(_cImpLocal)
             _cImpLocal := SB1->B1_LOCPAD
       endif
       
       if Empty(_cImpTES)
             _cImpTES := SB1->B1_TS
       endif
             
       SB2->(dbSetOrder(1))
       SB2->(MsSeek(xFilial("SB2")+_cImpProd+_cImpLocal))
       SF4->(dbSetOrder(1))
       SF4->(MsSeek(xFilial("SF4")+_cImpTES))
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³Calcula o preco de lista                     ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       nValMerc  := _cValTot
       nPrcLista := _cValUnit
       nQtdPeso  := 0
       nItem++
       If ( nPrcLista == 0 )
             nPrcLista := A410Arred(nValMerc/_cImpQuant,"CK_PRCVEN")
       EndIf
       nAcresFin := A410Arred(nValMerc*SE4->E4_ACRSFIN/100,"D2_PRCVEN")
       nValMerc  += A410Arred(nAcresFin*_cImpQuant,"D2_TOTAL")
       nDesconto := A410Arred(nPrcLista*_cImpQuant,"D2_DESCON")-nValMerc
       //nDesconto := IIf(nDesconto==0,TMP1->CK_VALDESC,nDesconto)
       nDesconto := Max(0,nDesconto)
       nPrcLista += nAcresFin
       
       //Para os outros paises, este tratamento e feito no programas que calculam os impostos.
       If cPaisLoc=="BRA"
             nValMerc  += nDesconto
       Endif
       
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³Verifica a data de entrega para as duplicatas³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       /*
       If ( TMP1->(FieldPos("CK_ENTREG"))>0 )
             If ( dDataCnd > TMP1->CK_ENTREG .And. !Empty(TMP1->CK_ENTREG) )
                    dDataCnd := TMP1->CK_ENTREG
             EndIf
       Else
       */
             dDataCnd  :=  d_Emissao
       /*EndIf*/
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³Agrega os itens para a funcao fiscal         ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       MaFisAdd(_cImpProd,;// 1-Codigo do Produto ( Obrigatorio )
       _cImpTES,;                // 2-Codigo do TES ( Opcional )
       _cImpQuant,;               // 3-Quantidade ( Obrigatorio )
       nPrcLista,;                // 4-Preco Unitario ( Obrigatorio )
       nDesconto,;         // 5-Valor do Desconto ( Opcional )
       "",;                       // 6-Numero da NF Original ( Devolucao/Benef )
       "",;                       // 7-Serie da NF Original ( Devolucao/Benef )
       0,;                               // 8-RecNo da NF Original no arq SD1/SD2
       0,;                               // 9-Valor do Frete do Item ( Opcional )
       0,;                               // 10-Valor da Despesa do item ( Opcional )
       0,;                               // 11-Valor do Seguro do item ( Opcional )
       0,;                               // 12-Valor do Frete Autonomo ( Opcional )
       nValMerc,;                 // 13-Valor da Mercadoria ( Obrigatorio )
       0)                                // 14-Valor da Embalagem ( Opiconal )
       
       SB1->(dbSetOrder(1))
       If SB1->(MsSeek(xFilial("SB1")+_cImpProd))
             nQtdPeso := _cImpQuant*SB1->B1_PESO
       Endif
       
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³Calculo do ISS                               ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       If SA1->A1_INCISS == "N"
             If ( SF4->F4_ISS=="S" )
                    nPrcLista := a410Arred(nPrcLista/(1-(MaAliqISS(nItem)/100)),"D2_PRCVEN")
                    nValMerc  := a410Arred(nValMerc/(1-(MaAliqISS(nItem)/100)),"D2_PRCVEN")
                    MaFisAlt("IT_PRCUNI",nPrcLista,nItem)
                    MaFisAlt("IT_VALMERC",nValMerc,nItem)
             EndIf
       EndIf
       
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³Altera peso para calcular frete              ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       MaFisAlt("IT_PESO",nQtdPeso,nItem)
       MaFisAlt("IT_PRCUNI",nPrcLista,nItem)
       MaFisAlt("IT_VALMERC",nValMerc,nItem)
       
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
       //³Analise da Rentabilidade                     ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       If SF4->F4_DUPLIC=="S"
             nY := aScan(aRentab,{|x| x[1] == _cImpProd})
             If nY == 0
                    aadd(aRenTab,{_cImpProd,0,0,0,0,0})
                    nY := Len(aRenTab)
             EndIf
             
             If cPaisLoc=="BRA"
                    aRentab[nY][2] += (nValMerc - nDesconto)
             Else
                    aRentab[nY][2] += nValMerc
             Endif
             aRentab[nY][3] += _cImpQuant*SB2->B2_CM1
       EndIf
       If lM415Ipi .Or. lM415Icm .Or. lM415Soli
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³Ponto de Entrada M415IPI para alterar os valores do IPI referente a palnilha financeira           ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             If lM415Ipi
                    VALORIPI    := MaFisRet(nItem,"IT_VALIPI")
                    BASEIPI     := MaFisRet(nItem,"IT_BASEIPI")
                    QUANTIDADE  := MaFisRet(nItem,"IT_QUANT")
                    ALIQIPI     := MaFisRet(nItem,"IT_ALIQIPI")
                    BASEIPIFRETE:= MaFisRet(nItem,"IT_FRETE")
                    MaFisAlt("IT_VALIPI",ExecBlock("M415IPI",.F.,.F.,{ nItem }),nItem,.T.)
                    MaFisLoad("IT_BASEIPI",BASEIPI ,nItem)
                    MaFisLoad("IT_ALIQIPI",ALIQIPI ,nItem)
                    MaFisLoad("IT_FRETE"  ,BASEIPIFRETE,nItem,"11")
                    MaFisEndLoad(nItem,1)
             EndIf
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³Ponto de Entrada M415ICM para alterar os valores do ICM referente a palnilha financeira           ³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             If lM415Icm
                    _BASEICM    := MaFisRet(nItem,"IT_BASEICM")
                    _ALIQICM    := MaFisRet(nItem,"IT_ALIQICM")
                    _QUANTIDADE := MaFisRet(nItem,"IT_QUANT")
                    _VALICM     := MaFisRet(nItem,"IT_VALICM")
                    _FRETE      := MaFisRet(nItem,"IT_FRETE")
                    _VALICMFRETE:= MaFisRet(nItem,"IT_ICMFRETE")
                    _DESCONTO   := MaFisRet(nItem,"IT_DESCONTO")
                    ExecBlock("M415ICM",.F.,.F., { nItem } )
                    MaFisLoad("IT_BASEICM" ,_BASEICM    ,nItem)
                    MaFisLoad("IT_ALIQICM" ,_ALIQICM    ,nItem)
                    MaFisLoad("IT_VALICM"  ,_VALICM     ,nItem)
                    MaFisLoad("IT_FRETE"   ,_FRETE      ,nItem)
                    MaFisLoad("IT_ICMFRETE",_VALICMFRETE,nItem)
                    MaFisLoad("IT_DESCONTO",_DESCONTO   ,nItem)
                    MaFisEndLoad(nItem,1)
             EndIf
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
             //³Ponto de Entrada M415SOLI para alterar os valores do ICM Solidario referente a palnilha financeira³
       //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
             If lM415Soli
                    ICMSITEM    := MaFisRet(nItem,"IT_VALICM")           // variavel para ponto de entrada
                    QUANTITEM   := MaFisRet(nItem,"IT_QUANT")            // variavel para ponto de entrada
                    BASEICMRET  := MaFisRet(nItem,"IT_BASESOL")       // criado apenas para o ponto de entrada
                    MARGEMLUCR  := MaFisRet(nItem,"IT_MARGEM")           // criado apenas para o ponto de entrada
                    aSolid := ExecBlock("M415SOLI",.f.,.f.,{nItem})
                    aSolid := IIF(ValType(aSolid) == "A" .And. Len(aSolid) == 2, aSolid,{})
                    If !Empty(aSolid)
                           MaFisLoad("IT_BASESOL",NoRound(aSolid[1],2),nItem)
                           MaFisLoad("IT_VALSOL" ,NoRound(aSolid[2],2),nItem)
                           MaFisEndLoad(nItem,1)
                    Endif
             EndIf
       EndIf

       //Bases
       _nBaseIpi    := MaFisRet(1,"IT_BASEIPI") //Base de calculo do IPI
       _nBaseIcm    := MaFisRet(1,"IT_BASEICM") //Base de calculo do ICMS
       _nBasePIS    := MaFisRet(1,"IT_BASEPIS") //Base de calculo do PIS
       _nBaseCOF    := MaFisRet(1,"IT_BASECOF") //Base de calculo do COFINS
       _nBaseST     := MaFisRet(1,"IT_BASESOL") //Base do ICMS Solidario
       _nBaseISS    := MaFisRet(1,"IT_BASEISS") //Base de calculo do ISS
       _nBasePS2    := MaFisRet(1,"IT_BASEPS2") //Base de calculo do PIS Apuracao
       _nBaseCF2    := MaFisRet(1,"IT_BASECF2") //Base de calculo do COFINS Apuracao

       //Aliquotas
       _nAliqIpi    := MaFisRet(1,"IT_ALIQIPI") //Aliquota de calculo do IPI
       _nAliqIcm    := MaFisRet(1,"IT_ALIQICM") //Aliquota de calculo do ICMS
       _nAliqPIS    := MaFisRet(1,"IT_ALIQPIS") //Aliquota de calculo do PIS
       _nAliqCOF    := MaFisRet(1,"IT_ALIQCOF") //Aliquota de calculo do COFINS
       _nAliqST     := MaFisRet(1,"IT_ALIQSOL") //Aliquota do ICMS Solidario
       _nAliqISS    := MaFisRet(1,"IT_ALIQISS") //Aliquota de ISS
       _nAliqPS2    := MaFisRet(1,"IT_ALIQPS2") //Aliquota de calculo do PIS Apuracao
       _nAliqCF2    := MaFisRet(1,"IT_ALIQCF2") //Aliquota de calculo do COFINS Apuracao
       
       //Valores
       _nValIpi     := MaFisRet(1,"IT_VALIPI") //Valor do IPI
       _nValIcm     := MaFisRet(1,"IT_VALICM") //Valor do ICMS
       _nValPIS     := MaFisRet(1,"IT_VALPIS") //Valor do PIS
       _nValCOF     := MaFisRet(1,"IT_VALCOF") //Valor do COFINS
       _nValST      := MaFisRet(1,"IT_VALSOL") //Valor do ICMS Solidario
       _nValST      += MaFisRet(1,"IT_VALCMP") //Valor do ICMS Complementar
       _nValISS     := MaFisRet(1,"IT_VALISS") //Valor do ISS
       _nValMer     := MaFisRet(1,"IT_VALMERC") //Valor da mercadoria
       _nValPS2     := MaFisRet(1,"IT_VALPS2") //Valor do PIS Apuracao
       _nValCF2     := MaFisRet(1,"IT_VALCF2") //Valor do COFINS Apuracao

      // Tratamento para PIS e COFINS de retenção x apuração - Gabriel Veríssimo 04/08/2020
      if _nBasePIS == 0 .and. _nBasePS2 > 0
            _nBasePIS := _nBasePS2
      endif

      if _nBaseCOF == 0 .and. _nBaseCF2 > 0
            _nBaseCOF := _nBaseCF2
      endif

      if _nValPIS == 0 .and. _nValPS2 > 0
            _nValPIS := _nValPS2
      endif

      if _nValCOF == 0 .and. _nValCF2 > 0
            _nValCOF := _nValCF2
      endif

       if MaFisRet(1,"IT_VALFECP") > 0
             _nValFec     := MaFisRet(1,"IT_VALFECP") //Valor do FECP
             _nAliqFec    := MaFisRet(1,"IT_ALIQFECP") //Aliquota de calculo do FECP
       endif

       if MaFisRet(1,"IT_VFECPST") > 0
             _nValFec     := MaFisRet(1,"IT_VFECPST") //Valor do FECP
             _nAliqFec    := MaFisRet(1,"IT_ALFCST") //Aliquota de calculo do FECP
       endif
       
       if MaFisRet(1,"IT_VFCPDIF") > 0
             _nValFec     := MaFisRet(1,"IT_VFCPDIF") //Valor do FECP
             _nAliqFec    := MaFisRet(1,"IT_ALFCCMP") //Aliquota de calculo do FECP
       endif
       
       if MaFisRet(1,"IT_DIFAL") > 0
             _nValDifal := MaFisRet(1,"IT_DIFAL") 
       endif  
       
       _nTotal := MaFisRet(1,"IT_TOTAL") 

       //Aliquotas
       if _nValIpi > 0
             _nAliqIpi    := MaFisRet(1,"IT_ALIQIPI") //Aliquota de calculo do IPI
       endif
       if _nValIcm > 0
             _nAliqIcm    := MaFisRet(1,"IT_ALIQICM") //Aliquota de calculo do ICMS
       endif
       if _nValPIS > 0
             _nAliqPIS    := MaFisRet(1,"IT_ALIQPIS") //Aliquota de calculo do PIS
       endif
       if _nValCOF > 0
             _nAliqCOF    := MaFisRet(1,"IT_ALIQCOF") //Aliquota de calculo do COFINS
       endif
       if _nValISS > 0
             _nAliqISS    := MaFisRet(1,"IT_ALIQISS") //Aliquota de ISS
       endif
       if _nValPS2 > 0
             _nAliqPS2    := MaFisRet(1,"IT_ALIQPS2") //Aliquota de calculo do PIS Apuracao
       endif
       if _nValCF2 > 0
             _nAliqCF2    := MaFisRet(1,"IT_ALIQCF2") //Aliquota de calculo do COFINS Apuracao
       endif
       If _nValST
             _nAliqST     := MaFisRet(1,"IT_ALIQSOL") //Aliquota de calculo do ST Solidario
             _nAliqMargem := MaFisRet(1,"IT_MARGEM") //Aliquota de calculo do IVA
       endif
       
       _nAliqDest := MaFisRet(1,"IT_ALIQCMP")

       aadd(_OutImpostos,MaFisRet(1,"IT_BASESOL"))          //1
       aadd(_OutImpostos,MaFisRet(1,"IT_ALIQSOL"))          //2
       aadd(_OutImpostos,MaFisRet(1,"IT_VALSOL"))           //3
       aadd(_OutImpostos,MaFisRet(1,"IT_DIFAL"))            //4
       aadd(_OutImpostos,MaFisRet(1,"IT_ALIQFECP"))         //5
       aadd(_OutImpostos,MaFisRet(1,"IT_VALFECP"))          //6
       aadd(_OutImpostos,MaFisRet(1,"IT_VFECPST"))          //7
       aadd(_OutImpostos,MaFisRet(1,"IT_VALCMP"))           //8
       aadd(_OutImpostos,MaFisRet(1,"IT_VFCPDIF"))          //9
       aadd(_OutImpostos,MaFisRet(1,"IT_BASEDES"))          //10
       aadd(_OutImpostos,MaFisRet(1,"IT_MARGEM"))           //11
       aadd(_OutImpostos,MaFisRet(1,"IT_ALFCST"))           //12
       aadd(_OutImpostos,MaFisRet(1,"IT_ALFCCMP"))          //13
       aadd(_OutImpostos,MaFisRet(1,"IT_FCPAUX"))           //14
       aadd(_OutImpostos,MaFisRet(1,"IT_ALIQCMP"))          //15
       aadd(_OutImpostos,MaFisRet(1,"IT_PDDES"))            //16
       
EndIf
             
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Indica os valores do cabecalho               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MaFisAlt("NF_FRETE", n_Frete )
MaFisAlt("NF_SEGURO", n_Seguro )
MaFisAlt("NF_AUTONOMO", n_Fretaut )
MaFisAlt("NF_DESPESA", n_Despesa )
MaFisAlt("NF_DESCONTO",MaFisRet(,"NF_DESCONTO")+MaFisRet(,"NF_VALMERC")*n_Pdescab /100)
MaFisAlt("NF_DESCONTO",MaFisRet(,"NF_DESCONTO")+n_Descont )
MaFisWrite(1)

MaFisEnd()
MaFisRestore()

//RestArea(aAreaTMP1)
RestArea(aAreaSA1)
RestArea(aArea)
//RestArea(aSavTMP1)
RestArea(aSavAtu)

aAdd( a_Ret , { _nAliqIpi,_nAliqIcm,_nAliqPIS,_nAliqCOF,_nAliqST,_nAliqISS,_nBaseIpi,_nBaseIcm,_nBasePIS,_nBaseCOF,_nBaseST,_nBaseISS,_nValIpi,_nValIcm,_nValPIS,_nValCOF,_nValST,_nValISS,_nValMer} )
// conout(varinfo("a_Ret", a_Ret,,.F.))

Return a_Ret
