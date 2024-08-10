# Gramati fe Globasa

- 🏴󠁧󠁢󠁥󠁮󠁧󠁿 _English:_
  - [Complete Globasa Grammar](https://salif.github.io/gramati-fe-globasa/eng/)

- 🇧🇬 _български:_
  - [Граматика на глобаса (Gemini)](https://salif.github.io/gramati-fe-globasa/bg-gemini/)
  - [Граматика на глобаса (Claude)](https://salif.github.io/gramati-fe-globasa/bg-claude/)

- 🇹🇷 _Türkçe_:
  - [Globasa dilbilgisi (Gemini)](https://salif.github.io/gramati-fe-globasa/tr-gemini/)

<!--
- *español:*
  - [Gramática completa de Globasa](https://salif.github.io/gramati-fe-globasa/spa/)
-->


## Contributing

Do not edit the root `README.md` file, edit `docs/README.md` instead

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

