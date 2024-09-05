# Gramati fe Globasa

- 🏴󠁧󠁢󠁥󠁮󠁧󠁿 _English:_
  - [Complete Globasa Grammar](https://salif.github.io/gramati-fe-globasa/eng/)

- 🇪🇸 _español:_
  - [Gramática completa de Globasa](https://salif.github.io/gramati-fe-globasa/spa/)

- 🇫🇷 _français:_
  - [Grammaire de globasa](https://salif.github.io/gramati-fe-globasa/fr-gemini/)

- 🇵🇹 _português:_
  - [Gramática da globasa](https://salif.github.io/gramati-fe-globasa/pt-gemini/)

- 🇹🇷 _Türkçe:_
  - [Globasa dilbilgisi](https://salif.github.io/gramati-fe-globasa/tr-gemini/)

- 🇷🇺 _русский:_
  - [Грамматика глобаса](https://salif.github.io/gramati-fe-globasa/ru-gemini/)

- 🇧🇬 _български:_
  - [Граматика на глобаса (Джемини)](https://salif.github.io/gramati-fe-globasa/bg-gemini/)
  - [Граматика на глобаса (Клод)](https://salif.github.io/gramati-fe-globasa/bg-claude/)

- 🟢 _Esperanto:_
  - [Gramatiko de Globaso](https://salif.github.io/gramati-fe-globasa/eo-gemini/)


## Contributing

Do not edit the root `README.md` file, edit [docs/README.md](docs/README.md) instead

### Add new book

```sh
mdbook init ./books/new-book
just --yes sync-theme
# Edit `docs/README.md` and run:
just sync-readme
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
just update-books eng update
just update-books-diff eng > new.diff
just update-books eng remove
```

