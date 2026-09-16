; Quais variantes cada letra oferece, na mesma ordem que o macOS usa em Português (Brasil).
; A ordem importa: é ela que define qual número escolhe qual acento.
ACCENTS := Map(
  "a", ["á", "ã", "à", "â", "a", "ª", "ä", "å", "æ"],
  "e", ["é", "ê", "e", "è", "ę", "ė", "ē", "ë"],
  "i", ["í", "i", "î", "ì", "ï", "į", "ī"],
  "o", ["ó", "õ", "ô", "o", "ò", "º", "ö", "œ", "ø", "ō"],
  "u", ["ú", "u", "ü", "ù", "û", "ū"],
  "c", ["ç", "c"],
  "n", ["n", "ñ"],
  "s", ["ß", "ś", "š"],
  "y", ["ÿ"],
  "z", ["ž", "ź", "ż"],
  "l", ["ł"]
)

; Devolve as variantes da letra, já em maiúscula quando a tecla foi digitada em maiúscula.
BuildOptions(letter, upper) {
    options := []
    for character in ACCENTS[letter] {
        ; ß não tem versão maiúscula de uma letra só, então some da lista.
        if (upper && character == "ß")
            continue
        options.Push(upper ? StrUpper(character) : character)
    }
    return options
}
