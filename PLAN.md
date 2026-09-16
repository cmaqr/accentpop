# Plano — popup de acentos estilo macOS no Windows

Segurar uma letra abre uma janelinha com as variantes acentuadas (`á ã à â ä å æ`), igual ao macOS.
Escolhe por número, seta ou clique. `Esc` cancela. AutoHotkey v2, sem instalação, sem trocar layout de teclado.

Estado: protótipo funcionando em `acentos.ahk` (AutoHotkey 2.0.27), com dois bugs conhecidos descritos abaixo.

## Como funciona hoje

1. `Hotkey "$a"` intercepta a tecla e **engole** o evento nativo.
2. O script digita a letra na mão com `SendText` — a letra aparece na hora, como no Mac.
3. Se a tecla continuar pressionada por 400 ms, abre a `Gui` com as variantes.
4. `InputHook` captura a escolha (1–9, setas, Enter, Esc) ou o clique do mouse.
5. Escolheu: manda `{BS}` e digita o acento no lugar.

## Bug 1 — sai `aá`: o backspace não chega no app

Sintoma: segura o `a`, aparece **um** `a` só; escolhe o acento e o campo fica com `aá`.
A letra base é digitada certo — quem falha é o `{BS}` de [acentos.ahk:116](acentos.ahk#L116).

**Descartado: repetição de tecla.** `#MaxThreadsPerHotkey` vale 1 por padrão, então enquanto
`SegurarTecla` está rodando (o tempo inteiro em que o popup está aberto) os disparos repetidos do
hotkey são ignorados — por isso sai um `a` só. A guarda de `seq` ([acentos.ahk:41](acentos.ahk#L41))
não está protegendo nada: é código morto.

**Suspeita principal: o `g.Destroy()` acontece antes do envio.** Destruir a janelinha mexe no foco do
app de destino, e o primeiro evento enviado logo depois se perde. O `{BS}` é tecla de verdade (evento
de teclado) e é justamente o primeiro a sair; o acento vai como caractere Unicode (`SendText`), que é
entregue por outro caminho e não se perde. Isso explica o padrão exato: some o backspace, o acento fica.

**Segunda suspeita:** app Electron/Chromium (WhatsApp, Discord, navegador) processa tecla na thread do
renderer, e `SendInput` dispara backspace e texto rápido demais para ele acompanhar.

Dá para separar as duas testando o mesmo gesto no Bloco de Notas, no Chrome e no WhatsApp, com uma
versão que loga o horário de cada envio. Se funciona no Bloco de Notas e falha no WhatsApp, é corrida
de foco/renderer, não erro de lógica.

**Correções, nesta ordem**

1. Enviar `{BS}` + acento **antes** do `g.Destroy()` — ou, se a janelinha precisar sair primeiro,
   um `Sleep 15` entre destruir e enviar.
2. Backspace em modo Event (`SendEvent` com `SetKeyDelay 10, 10`) em vez de `SendInput`: mais devagar,
   mais parecido com digitação real, aceito por app que descarta rajada.
3. Trocar o backspace por seleção — `{Shift Down}{Left}{Shift Up}` e digitar o acento por cima.
4. Guardar o `hwnd` da janela de destino antes de abrir o popup e só enviar se ela ainda for a ativa;
   se o foco mudou, cancela em silêncio em vez de digitar no lugar errado.
5. Se algum app continuar teimoso: **modo sem backspace**, opção de config. Não digita nada na descida
   da tecla; digita a letra quando você solta sem segurar, e digita o acento direto quando você escolhe.
   Nunca precisa apagar nada, então não tem como falhar. Custo: a letra só aparece quando você solta.

**Ainda em aberto:** quando você clica na opção com o mouse e "não aparece a tecla", falta saber se o
que não apareceu foi o acento ou a janelinha. Se for o acento, é o mesmo bug acima; se for a janelinha,
é o bug 2 — ela abriu fora da tela ou longe do texto.

## Bug 2 — a janelinha tem que aparecer acima do cursor

Hoje ela aparece **abaixo**: `y + 28` ([acentos.ahk:73](acentos.ahk#L73)). No Mac ela fica logo acima da
linha que você está escrevendo, alinhada pela esquerda com o cursor.

**Correção**

- Mostrar a `Gui` escondida (`Show "Hide AutoSize"`) só para medir, ler o tamanho com `GetPos`,
  e então posicionar: `y = caretY - altura - 6`, `x = caretX`.
- **Quando não dá para achar o cursor** — `CaretGetPos` falha ou devolve lixo em vários apps
  (Electron/Chromium é o caso típico, justamente o WhatsApp). Nesses casos a janelinha abre perto
  do **mouse**. Cheguei a tentar adivinhar pela janela (canto de baixo, onde costuma ficar a barra
  de digitação), mas palpite que erra manda a janelinha para um lugar que o olho não procura;
  o mouse pelo menos é um ponto que você sabe onde está.
- Prender a janelinha na área útil do monitor (`MonitorGetWorkArea`): se não couber acima, abre abaixo;
  se vazar na direita, encosta na borda. Hoje ela pode abrir fora da tela.

## Fases

| Fase | Entrega |
|---|---|
| v0.1 | ✅ hotkeys, popup, escolha por número/seta/clique |
| v0.2 | ✅ estrutura do repositório, testes, CI; bug 2 resolvido e medido; bug 1 com a correção 1 e a 2 aplicadas — falta confirmar digitando de verdade em cada app |
| v0.3 | Config em arquivo (`config.ini`): tempo de espera, cores, tamanho da fonte, lista de acentos |
| v0.4 | Ícone na bandeja: pausar, recarregar, abrir config, sair |
| v0.5 | Empacotamento: `.exe` compilado e instruções de "iniciar com o Windows" |
| v1.0 | README com GIF, lista de apps testados, licença MIT |

## Estrutura de arquivos

Projeto pequeno: continua em poucos arquivos na raiz, sem pasta de pacote.

```
accent-popup/
  accents.ahk          # ponto de entrada: hotkeys e o fluxo principal
  lib/
    options.ahk        # BuildOptions(letter, upper) -> lista de variantes
    placement.ahk      # PlacePopup(caret, tamanho, área do monitor) -> x, y
    popup.ahk          # a Gui e o desenho
  tests/
    run_tests.ahk      # roda os testes das funções puras
  config.ini           # a partir da v0.3
  README.md
  .gitignore
  .github/workflows/check.yml
```

As duas funções que dá para testar de verdade (`BuildOptions` e `PlacePopup`) saem do meio do handler
e viram função pura: recebem valores, devolvem valores, não tocam em teclado nem em janela.

## Testes

AutoHotkey não tem framework de teste que valha a pena puxar como dependência: `tests/run_tests.ahk`
tem um `Check` de dez linhas e devolve código de saída 1 se algum falhar. Roda com `just test`.

Cada teste com uma linha em português dizendo o que ele protege. O que está coberto:

- `BuildOptions("a", false)` devolve a lista na ordem do Mac — quebra se alguém reordenar a `Map`.
- `BuildOptions("s", true)` não devolve `ß` — quebra se voltar o `ß` maiúsculo, que não existe.
- `BuildOptions("e", true)` devolve tudo maiúsculo — quebra se o `StrUpper` sumir.
- `PlacePopup` com cursor no meio da tela põe a janela **acima** — é o bug 2 virando regressão.
- `PlacePopup` com cursor colado no topo cai para baixo — quebra se o fallback sumir.
- `PlacePopup` com cursor na borda direita encosta na borda — quebra se a janela puder vazar da tela.

O resto (hotkey, `{BS}`, foco de janela) é teste manual, em checklist no README:
Bloco de Notas, WhatsApp Desktop, Chrome, VS Code, Word.

Checagem de sintaxe, que é o lint que o AutoHotkey tem (`just check` — devolve 0 se está ok e 2 com
o erro). O CI roda os dois passos no `windows-latest`, baixando o zip oficial do AHK v2 antes.

## Não-objetivos

- Não substitui layout de teclado nem o `US-International` — é um complemento.
- Não funciona em janela de admin sem o script também estar em admin (limitação do Windows, não tem volta).
- Não faz correção ortográfica, nem sugestão de palavra, nem emoji.
