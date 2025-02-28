# Gramati fe Globasa

Translations of the Complete Globasa Grammar. Fell free to fork this repository and add new books or improve existing books. Human translations, LLM translations and unfinished books are accepted.

## Books

| language | book  | llm | version | source book |
| -------- | ----- | --- | ------- | ----------- |
| 🏴󠁧󠁢󠁥󠁮󠁧󠁿 Englisa | [Complete Globasa Grammar](https://salif.github.io/gramati-fe-globasa/eng/) | none | 2025-02 | none |
| 🇪🇸 Espanisa | [Gramática completa de Globasa](https://salif.github.io/gramati-fe-globasa/spa/) | none | 2025-02 | none |
| 🇫🇷 Fransesa | [Grammaire de globasa](https://salif.github.io/gramati-fe-globasa/fr-gemini/) | Gemini Pro Experimental | 2025-02 | spa |
| 🇵🇹 Portugalsa | [Gramática da globasa](https://salif.github.io/gramati-fe-globasa/pt-gemini/) | Gemini Pro Experimental | 2025-02 | spa |
| 🇩🇪 Doycisa | [Globasa Grammatik](https://salif.github.io/gramati-fe-globasa/de-gemini/) | Gemini Pro Experimental | 2025-02 | eng |
| 🇷🇺 Rusisa | [Грамматика глобаса](https://salif.github.io/gramati-fe-globasa/ru-gemini/) | Gemini Pro Experimental | 2025-02 | eng |
| 🇧🇬 Bulgarisa | [Граматика на глобаса](https://salif.github.io/gramati-fe-globasa/bg-gemini/) | Gemini Pro Experimental | 2025-02 | eng |
| 🇧🇬 Bulgarisa | [Граматика на глобаса](https://salif.github.io/gramati-fe-globasa/bg-claude/) | Claude Sonnet | 2025-02 | eng |
| 🇹🇷 Turkisa | [Globasa dilbilgisi](https://salif.github.io/gramati-fe-globasa/tr-gemini/) | Gemini Pro Experimental | 2025-02 | eng |
| 🟢 Esperanto | [Gramatiko de Globasa](https://salif.github.io/gramati-fe-globasa/eo-gemini/) | Gemini Pro Experimental | 2025-02 | eng |
| 🇮🇩 Indonesisa | [Tata Bahasa Globasa](https://salif.github.io/gramati-fe-globasa/id-gemini/) | Gemini Pro Experimental | 2025-02 | eng |
| 🇰🇷 Koreasa | [글로바사 문법](https://salif.github.io/gramati-fe-globasa/ko-gemini/) | Gemini Pro Experimental | 2025-02 | eng |
| 🇯🇵 Niponsa | [グロバサ文法](https://salif.github.io/gramati-fe-globasa/ja-gemini/) | Gemini Pro Experimental | 2025-02 | eng |
| 🇨🇳 Putunhwa | [格洛巴萨语法](https://salif.github.io/gramati-fe-globasa/zh-gemini/) | Gemini Pro Experimental | 2025-02 | eng |
| 🇮🇳 Hindi | [ग्लोबासा व्याकरण](https://salif.github.io/gramati-fe-globasa/hi-gemini/) | Gemini Pro Experimental | 2025-02 | eng |
| 🇻🇳 Vyetnamsa | [Ngữ pháp Globasa](https://salif.github.io/gramati-fe-globasa/vi-gemini/) | Gemini Pro Experimental | 2025-02 | eng |
| 🇹🇿 Swahilisa | [Sarufi ya Globasa](https://salif.github.io/gramati-fe-globasa/sw-gemini/) | Gemini Pro Experimental | 2025-02 | eng |

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
