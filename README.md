# Gramati fe Globasa

Translations of the Complete Globasa Grammar. Fell free to fork this repository and add new books or improve existing books. Human translations, LLM translations and unfinished books are accepted.

## Books

| language | book  | llm | version | source book |
| -------- | ----- | --- | ------- | ----------- |
| 🏴󠁧󠁢󠁥󠁮󠁧󠁿 English | [Complete Globasa Grammar](https://salif.github.io/gramati-fe-globasa/eng/) | none | Mesi 11 2024 | none |
| 🇪🇸 español | [Gramática completa de Globasa](https://salif.github.io/gramati-fe-globasa/spa/) | none | Mesi 11 2024 | none |
| 🇫🇷 français | [Grammaire de globasa](https://salif.github.io/gramati-fe-globasa/fr-gemini/) | Gemini 1.5 Pro Experimental 0827 | Mesi 08 2024 | spa |
| 🇵🇹 português | [Gramática da globasa](https://salif.github.io/gramati-fe-globasa/pt-gemini/) | Gemini 1.5 Pro Experimental 0827 | Mesi 08 2024 | spa |
| 🇹🇷 Türkçe | [Globasa dilbilgisi](https://salif.github.io/gramati-fe-globasa/tr-gemini/) | Gemini 1.5 Pro Experimental 0801 | Mesi 08 2024 | eng |
| 🇷🇺 русский | [Грамматика глобаса](https://salif.github.io/gramati-fe-globasa/ru-gemini/) | Gemini 1.5 Pro Experimental 0827 | Mesi 08 2024 | eng |
| 🇧🇬 български | [Граматика на глобаса](https://salif.github.io/gramati-fe-globasa/bg-gemini/) | Gemini 1.5 Pro | Mesi 09 2024 | eng |
| 🇧🇬 български | [Граматика на глобаса](https://salif.github.io/gramati-fe-globasa/bg-claude/) | Claude 3.5 Sonnet | Mesi 09 2024 | eng |
| 🟢 Esperanto | [Gramatiko de Globaso](https://salif.github.io/gramati-fe-globasa/eo-gemini/) | Gemini 1.5 Pro Experimental 0827 | Mesi 08 2024 | eng |

## Contributing

### Add new book

```sh
mdbook init ./books/new-book
just --yes sync-theme
just build
```

### Build books

```sh
just --yes sync-theme
just clean-all build
# just serve
```

### Rebuild a book

```sh
just clean eng build
```

### Fetch upstream

```sh
just update-book eng update
just update-book-diff eng > new.diff
just update-book eng remove
```
