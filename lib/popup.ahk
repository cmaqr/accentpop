; Cores no estilo escuro do macOS.
BG_COLOR     := "232323"
TEXT_COLOR   := "F5F5F5"
NUMBER_COLOR := "8E8E93"
SELECT_COLOR := "0A84FF"

; Monta a janelinha com as variantes e devolve {gui, boxes}.
; `boxes` são os quadradinhos de cada letra, guardados para dar destaque depois.
; `state` é o objeto do fluxo principal: o clique do mouse escreve nele.
CreatePopup(options, state) {
    ; E0x08000000 é WS_EX_NOACTIVATE: a janelinha aparece sem roubar o foco de onde você digita.
    window := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000")
    window.BackColor := BG_COLOR
    window.MarginX := 10
    window.MarginY := 8

    boxes := []
    for index, character in options {
        window.SetFont("s18 c" TEXT_COLOR, "Segoe UI")
        position := (index = 1) ? "xm ym" : "x+4 ym"
        box := window.AddText(position " w40 h38 Center 0x200 Background" BG_COLOR, character)
        box.OnEvent("Click", OnBoxClick.Bind(state, index))
        boxes.Push(box)

        window.SetFont("s8 c" NUMBER_COLOR, "Segoe UI")
        window.AddText("xp y+0 w40 Center Background" BG_COLOR, index = 10 ? 0 : index)
    }

    RoundTheCorners(window.Hwnd)
    return {gui: window, boxes: boxes}
}

; Mostra a janelinha já no lugar certo: mede escondida, calcula a posição, aí mostra.
ShowPopupAtCaret(popup) {
    popup.gui.Show("Hide AutoSize")
    popup.gui.GetPos(, , &width, &height)

    caret := GetCaretScreenPos()
    spot := PlacePopup(caret.x, caret.y, width, height, GetWorkAreaAt(caret.x, caret.y))

    popup.gui.Show("NoActivate x" spot.x " y" spot.y " w" width " h" height)
}

; Pinta de azul a opção escolhida pelas setas.
HighlightBox(popup, selected) {
    for index, box in popup.boxes {
        box.Opt("+Background" (index = selected ? SELECT_COLOR : BG_COLOR))
        box.SetFont("c" TEXT_COLOR)
        box.Redraw()
    }
}

OnBoxClick(state, index, *) {
    state.clicked := index
    ; O fluxo principal está parado esperando tecla; o clique precisa acordar ele.
    if state.input
        state.input.Stop()
}

RoundTheCorners(hwnd) {
    rounded := 2      ; DWMWCP_ROUND
    borderColor := 0x3A3A3A
    try DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", hwnd, "Int", 33, "Int*", &rounded, "Int", 4)
    try DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", hwnd, "Int", 34, "Int*", &borderColor, "Int", 4)
}
