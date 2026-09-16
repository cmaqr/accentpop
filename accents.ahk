; Popup de acentos estilo macOS: segure uma letra para escolher a variante acentuada.
#Requires AutoHotkey v2.0
#SingleInstance Force
InstallKeybdHook
CoordMode "Caret", "Screen"
CoordMode "Mouse", "Screen"
SetKeyDelay 10, 10   ; usado pelo SendEvent do backspace

#Include %A_ScriptDir%\lib\options.ahk
#Include %A_ScriptDir%\lib\placement.ahk
#Include %A_ScriptDir%\lib\popup.ahk

HOLD_SECONDS := 0.4   ; quanto tempo segurando até a janelinha abrir

for letter in ACCENTS {
    Hotkey "$" letter, OnLetterPressed
    Hotkey "$+" letter, OnLetterPressed
}

OnLetterPressed(hotkeyName) {
    letter := SubStr(hotkeyName, -1)
    upper := InStr(hotkeyName, "+") || GetKeyState("CapsLock", "T")
    base := upper ? StrUpper(letter) : letter

    target := WinExist("A")   ; a janela onde você está digitando
    SendText base

    ; Soltou antes do tempo: era digitação normal, acabou aqui.
    ; KeyWait devolve 1 quando a tecla é solta e 0 quando o tempo estoura.
    if KeyWait(letter, "T" HOLD_SECONDS)
        return

    options := BuildOptions(letter, upper)
    state := {clicked: 0, input: 0}   ; o clique do mouse e o InputHook escrevem aqui
    popup := CreatePopup(options, state)
    ShowPopupAtCaret(popup)

    KeyWait letter   ; espera soltar a letra para não misturar com a escolha
    choice := ReadChoice(popup, options, state)

    ; O envio sai ANTES do Destroy: destruir a janelinha mexe no foco do app e o primeiro
    ; evento mandado logo depois se perde — era isso que comia o backspace e deixava "aá".
    active := WinExist("A")
    if (active = target || active = popup.gui.Hwnd) {
        if (choice.accent != "") {
            SendEvent "{BS}"   ; modo Event: mais devagar que o padrão, aceito por app Electron
            SendText choice.accent
        }
        if (choice.extra != "")
            SendText choice.extra
    }

    popup.gui.Destroy()
}

; Espera a escolha: número, setas + Enter, clique ou Esc.
; Devolve {accent, extra} — `extra` é o caractere digitado quando não era uma das opções.
ReadChoice(popup, options, state) {
    selected := 0
    loop {
        state.input := InputHook("L1 T10", "{Esc}{Enter}{Left}{Right}")
        state.input.Start()
        state.input.Wait()

        if state.clicked
            return {accent: options[state.clicked], extra: ""}

        if (state.input.EndReason = "EndKey") {
            key := state.input.EndKey
            if (key = "Left") {
                selected := selected <= 1 ? options.Length : selected - 1
                HighlightBox(popup, selected)
                continue
            }
            if (key = "Right") {
                selected := selected >= options.Length ? 1 : selected + 1
                HighlightBox(popup, selected)
                continue
            }
            if (key = "Enter" && selected)
                return {accent: options[selected], extra: ""}
            return {accent: "", extra: ""}   ; Esc, ou Enter sem nada destacado
        }

        typed := state.input.Input
        if IsInteger(typed) {
            number := (typed = "0") ? 10 : Integer(typed)
            if (number >= 1 && number <= options.Length)
                return {accent: options[number], extra: ""}
        }

        return {accent: "", extra: typed}   ; digitou outra coisa: a letra base fica e o resto passa
    }
}
