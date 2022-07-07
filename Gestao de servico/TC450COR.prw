User Function TC450COR()

    Local aCores := PARAMIXB

    aCores[1][1] := "AB6_STATUS=='A' .and. !Empty(AB6_XNUMPV)"
    aCores[1][2] := "BR_AZUL"
    aadd(aCores, {"AB6_STATUS='A'", 'ENABLE'})

Return aCores