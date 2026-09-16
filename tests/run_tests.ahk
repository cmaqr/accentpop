; Testes das funções puras: as que só recebem valores e devolvem valores.
; Teclado, janela e foco não dá para testar aqui — isso está no checklist manual do README.
#Requires AutoHotkey v2.0
#Include %A_ScriptDir%\..\lib\options.ahk
#Include %A_ScriptDir%\..\lib\placement.ahk

results := {passed: 0, failed: 0}
SCREEN := {left: 0, top: 0, right: 1920, bottom: 1040}   ; monitor de mentira, com barra de tarefas embaixo

; Esse quebra se alguém mexer na ordem das variantes — a ordem é o que decide qual número dá qual acento.
Check(results, Join(BuildOptions("a", false)) = "á ã à â a ª ä å æ",
    "BuildOptions devolve as variantes de 'a' na ordem do macOS")

; Esse quebra se o ß voltar para a lista em maiúscula: ß maiúsculo de uma letra só não existe.
Check(results, Join(BuildOptions("s", true)) = "Ś Š",
    "BuildOptions tira o ß quando a letra é maiúscula")

; Esse quebra se alguém esquecer o StrUpper e a janelinha oferecer minúscula para tecla maiúscula.
Check(results, Join(BuildOptions("e", true)) = "É Ê E È Ę Ė Ē Ë",
    "BuildOptions devolve tudo maiúsculo quando a letra é maiúscula")

; Esse é o bug 2 virando regressão: a janelinha tem que abrir ACIMA da linha, alinhada pela esquerda.
above := PlacePopup(500, 600, 400, 60, SCREEN)
Check(results, above.x = 500 && above.y = 534,
    "PlacePopup abre acima do cursor e alinhado com ele")

; Esse quebra se o fallback sumir e a janelinha for parar fora da tela quando o texto está no topo.
noRoomAbove := PlacePopup(500, 10, 400, 60, SCREEN)
Check(results, noRoomAbove.y = 40,
    "PlacePopup desce para baixo da linha quando não cabe em cima")

; Esse quebra se a janelinha puder vazar pela direita do monitor.
nearRightEdge := PlacePopup(1800, 600, 400, 60, SCREEN)
Check(results, nearRightEdge.x = 1520,
    "PlacePopup encosta na borda direita em vez de vazar da tela")

Report(results)

Check(results, passed, name) {
    if passed {
        results.passed += 1
        FileAppend("  ok     " name "`n", "*")
        return
    }
    results.failed += 1
    FileAppend("  FALHOU " name "`n", "*")
}

Report(results) {
    FileAppend("`n" results.passed " passou, " results.failed " falhou`n", "*")
    ExitApp(results.failed ? 1 : 0)
}

Join(list) {
    text := ""
    for item in list
        text .= (text = "" ? "" : " ") item
    return text
}
