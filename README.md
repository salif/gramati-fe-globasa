# Gramati fe Globasa

- 🏴󠁧󠁢󠁥󠁮󠁧󠁿 _English:_
  - [Complete Globasa Grammar](https://salif.github.io/gramati-fe-globasa/eng/)

- 🇪🇸 _español_:
  - [Gramática completa de Globasa](https://salif.github.io/gramati-fe-globasa/spa/)

- 🇧🇬 _български:_
  - [Граматика на глобаса (Джемини)](https://salif.github.io/gramati-fe-globasa/bg-gemini/)
  - [Граматика на глобаса (Клод)](https://salif.github.io/gramati-fe-globasa/bg-claude/)

- 🇹🇷 _Türkçe_:
  - [Globasa dilbilgisi](https://salif.github.io/gramati-fe-globasa/tr-gemini/)

- 🇫🇷 _français_:
  - [Grammaire de la globasa](https://salif.github.io/gramati-fe-globasa/fr-gemini/)


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
just build
# just serve
```

