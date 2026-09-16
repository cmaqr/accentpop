; Onde a janelinha abre: acima da linha que está sendo digitada, alinhada pela esquerda
; com o cursor, sem nunca sair da área útil do monitor.
; Função pura: só contas. É o que os testes cobrem.
; `work` é um objeto {left, top, right, bottom} com a área útil do monitor.
PlacePopup(caretX, caretY, popupWidth, popupHeight, work) {
    GAP := 6
    LINE_HEIGHT := 24   ; o Windows não informa a altura do cursor; isso é um chute bom para texto comum

    x := caretX
    y := caretY - popupHeight - GAP

    ; Não cabe em cima (cursor perto do topo da tela): abre embaixo da linha.
    if (y < work.top)
        y := caretY + LINE_HEIGHT + GAP

    if (x + popupWidth > work.right)
        x := work.right - popupWidth
    if (x < work.left)
        x := work.left
    if (y + popupHeight > work.bottom)
        y := work.bottom - popupHeight
    if (y < work.top)
        y := work.top

    return {x: x, y: y}
}

; Posição do cursor de texto, em coordenadas de tela.
; CaretGetPos falha em app Electron/Chromium (WhatsApp, Discord, navegador), que desenha
; o próprio cursor e não conta para o Windows — por isso os planos B e C.
GetCaretScreenPos() {
    if CaretGetPos(&caretX, &caretY)
        return {x: caretX, y: caretY}

    ; Plano B: parte de baixo da janela ativa. Em app de conversa é onde fica a barra de digitação.
    if (hwnd := WinExist("A")) {
        WinGetClientPos(&windowX, &windowY, &windowWidth, &windowHeight, hwnd)
        return {x: windowX + 12, y: windowY + windowHeight - 40}
    }

    ; Plano C: o mouse.
    MouseGetPos(&mouseX, &mouseY)
    return {x: mouseX, y: mouseY}
}

; Área útil (sem a barra de tarefas) do monitor que contém o ponto.
GetWorkAreaAt(x, y) {
    loop MonitorGetCount() {
        MonitorGet(A_Index, &left, &top, &right, &bottom)
        if (x >= left && x < right && y >= top && y < bottom) {
            MonitorGetWorkArea(A_Index, &left, &top, &right, &bottom)
            return {left: left, top: top, right: right, bottom: bottom}
        }
    }

    MonitorGetWorkArea(MonitorGetPrimary(), &left, &top, &right, &bottom)
    return {left: left, top: top, right: right, bottom: bottom}
}
