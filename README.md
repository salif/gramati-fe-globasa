# Gramati fe Globasa

Translations of the Complete Globasa Grammar. Fell free to fork this repository and add new books or improve existing books. Human translations, LLM translations and unfinished books are accepted.

## Books

| language | book  | llm | version | source book |
| -------- | ----- | --- | ------- | ----------- |
| 🏴󠁧󠁢󠁥󠁮󠁧󠁿 English | [Complete Globasa Grammar](https://salif.github.io/gramati-fe-globasa/eng/) | none | 2025-01 | none |
| 🇪🇸 español | [Gramática completa de Globasa](https://salif.github.io/gramati-fe-globasa/spa/) | none | 2025-01 | none |
| 🇫🇷 français | [Grammaire de globasa](https://salif.github.io/gramati-fe-globasa/fr-gemini/) | Gemini 1.5 Pro Experimental 0827 | 2024-12 | spa |
| 🇵🇹 português | [Gramática da globasa](https://salif.github.io/gramati-fe-globasa/pt-gemini/) | Gemini 1.5 Pro Experimental 0827 | 2024-12 | spa |
| 🇹🇷 Türkçe | [Globasa dilbilgisi](https://salif.github.io/gramati-fe-globasa/tr-gemini/) | Gemini 1.5 Pro Experimental 0801 | 2024-12 | eng |
| 🇷🇺 русский | [Грамматика глобаса](https://salif.github.io/gramati-fe-globasa/ru-gemini/) | Gemini 1.5 Pro Experimental 0827 | 2024-12 | eng |
| 🇧🇬 български | [Граматика на глобаса](https://salif.github.io/gramati-fe-globasa/bg-gemini/) | Gemini 1.5 Pro | 2024-12 | eng |
| 🇧🇬 български | [Граматика на глобаса](https://salif.github.io/gramati-fe-globasa/bg-claude/) | Claude 3.5 Sonnet | 2024-09 | eng |
| 🟢 Esperanto | [Gramatiko de Globaso](https://salif.github.io/gramati-fe-globasa/eo-gemini/) | Gemini 1.5 Pro Experimental 0827 | 2024-12 | eng |
| 🇰🇷 한국어 | [글로바사 문법](https://salif.github.io/gramati-fe-globasa/ko-gemini/) | Gemini Experimental 1206 | 2024-12 | eng |
| 🇯🇵 日本語 | [グロバサ文法](https://salif.github.io/gramati-fe-globasa/ja-gemini/) | Gemini Experimental 1206 | 2024-12 | eng |

## Contributing

### Add new book

```sh
mdbook init ./books/new-book
just --yes sync_theme
just build
```

### Build all books

```sh
just --yes sync_theme
just del "all" build
# just serve
```

### Rebuild a book

```sh
just del "eng" build
```
