# Caminho do AutoHotkey v2. Outra máquina com outro caminho: `AHK=... just test`.
ahk := env_var_or_default("AHK", "C:/Program Files/AutoHotkey/v2/AutoHotkey64.exe")

# lista as tarefas
default:
    @just --list

# liga o popup de acentos
run:
    "{{ahk}}" accents.ahk

# roda os testes das funções puras
test:
    "{{ahk}}" tests/run_tests.ahk

# MSYS_NO_PATHCONV impede o Git Bash de transformar /validate em caminho de arquivo
# checa a sintaxe de todos os scripts — é o lint que o AutoHotkey tem
check:
    MSYS_NO_PATHCONV=1 "{{ahk}}" /ErrorStdOut /validate accents.ahk
    MSYS_NO_PATHCONV=1 "{{ahk}}" /ErrorStdOut /validate tests/run_tests.ahk
