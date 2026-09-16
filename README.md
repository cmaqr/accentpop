<h1 align="center">Acentos</h1>

<p align="center">
  <b>O jeito do Mac de acentuar, no Windows.</b><br>
  Segure a letra, a janelinha abre em cima do que você está escrevendo, escolhe pelo número.
</p>

<p align="center">
  <img alt="AutoHotkey v2" src="https://img.shields.io/badge/AutoHotkey-v2.0-2C3E50?style=flat-square">
  <img alt="Windows 10 e 11" src="https://img.shields.io/badge/Windows-10%20e%2011-0A84FF?style=flat-square">
  <img alt="sem instalação" src="https://img.shields.io/badge/instala%C3%A7%C3%A3o-nenhuma-4CAF50?style=flat-square">
  <img alt="tamanho" src="https://img.shields.io/badge/c%C3%B3digo-300%20linhas-8E8E93?style=flat-square">
</p>

```
                               ╭──────────────────────────────╮
                               │   á    ã    à    â    a    ä │
                               │   1    2    3    4    5    6 │
                               ╰──────────────────────────────╯
   ╭──────────────────────────────────────────────────────────────╮
   │  tô fazendo a sobremesa   a▏                                 │
   ╰──────────────────────────────────────────────────────────────╯
```

<!-- Grave um GIF de uns 5 segundos e troque este comentário por: ![demo](docs/demo.gif) -->

---

## A dor

Teclado bom quase sempre vem no layout americano. Mecânico, compacto, importado, o que você achar
numa promoção: é ANSI, sem `ç`, sem a tecla de acento. O teclado ABNT resolveria — só que aí você
escolhe o teclado pelo layout, não pelo teclado.

As saídas que o Windows oferece nunca me agradaram:

- **Layout US-Internacional**, com as teclas mortas. Você ganha o acento e perde a aspa e o
  apóstrofo: toda vez que digita `'` ou `"` tem que bater espaço depois para o caractere sair.
  Quem escreve código o dia inteiro sente isso em uma hora de uso.
- **Alt + código numérico**. Ninguém decora `Alt+0227` para escrever `ã`.
- **Copiar e colar de outro lugar**, que é onde a maioria acaba parando. Não é solução, é rotina.

No Mac isso nunca foi problema: você segura a letra, aparece uma lista pequena **do lado de onde você
está escrevendo**, e você bate o número. Não tira a mão do lugar, não tira o olho da frase. É essa
sensação que este script traz para o Windows.

## Por que não o PowerToys

O [Quick Accent](https://learn.microsoft.com/en-us/windows/powertoys/quick-accent) faz o trabalho, e
para muita gente está ótimo. Para mim, dois detalhes estragam:

|                        | Quick Accent                                          | aqui                                     |
| ---------------------- | ----------------------------------------------------- | ---------------------------------------- |
| Onde a lista aparece   | num canto fixo da tela (padrão: topo, no meio)        | logo acima da linha que você está digitando |
| Como você escolhe      | anda de um em um, com espaço ou setas, até chegar     | número direto, `1` a `9`                 |
| Mouse                  | seleção é pelo teclado                                 | dá para clicar na opção                   |
| Tamanho                | parte de um pacote grande da Microsoft                 | um script, ~300 linhas, que você lê inteiro |

O primeiro item é o que mais incomoda: olhar para o topo da tela para escolher um acento quebra a
frase na cabeça. A lista tem que estar onde o olho já está.

## Como usa

Segure qualquer letra de `a e i o u c n s y z l` por 0,4 s. Quando a janelinha abrir:

| Tecla        | O que faz                                    |
| ------------ | -------------------------------------------- |
| `1` … `9`    | escolhe direto pelo número (`0` para a décima opção, que só o `o` tem) |
| `←` `→`      | anda pelas opções, `Enter` confirma          |
| clique       | escolhe a opção clicada                      |
| `Esc`        | fecha e deixa a letra sem acento             |

Soltar antes dos 0,4 s digita a letra normal — digitação rápida não muda em nada.
Maiúscula funciona igual: `Shift` + letra segurada oferece `Á Ã À Â`.

## Instalação

1. Instale o [AutoHotkey v2](https://www.autohotkey.com/) (testado no 2.0.27).
2. Baixe este repositório.
3. Dois cliques em `accents.ahk`. Um ícone verde aparece na bandeja: está rodando.

Para ligar junto com o Windows: `Win+R` → `shell:startup` → jogue um atalho do `accents.ahk` ali.

Pelo terminal, com [just](https://github.com/casey/just):

```sh
just run      # liga o popup
just test     # roda os testes
just check    # checa a sintaxe dos scripts
```

## Como é por dentro

```
accents.ahk           hotkeys e o fluxo de uma escolha, do começo ao fim
lib/options.ahk       quais variantes cada letra oferece, na ordem do macOS
lib/placement.ahk     onde a janelinha abre e onde está o cursor de texto
lib/popup.ahk         a janelinha em si
tests/run_tests.ahk   testes das funções que dá para testar sozinhas
PLAN.md               o que falta, e o porquê de cada decisão
```

Teclado, foco de janela e posição do cursor não dá para testar em automação: depois de mexer no envio
de teclas, passe o checklist manual — Bloco de Notas, WhatsApp, Chrome, VS Code e Word — conferindo
que segurar `a` e escolher `2` deixa só `ã` no campo, e que a janelinha abre acima do texto.

## Limitações

- Em janela aberta como administrador, o script precisa estar como administrador também. É o Windows
  que bloqueia; não tem contorno.
- Em app Electron/Chromium o Windows não informa onde está o cursor de texto. Sem essa referência a
  janelinha abre perto do mouse; com ela, abre logo acima da caixinha onde você está escrevendo.
