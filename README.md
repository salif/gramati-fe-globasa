# Gramati fe Globasa

- *English:*
  - [Complete Globasa Grammar](https://salif.github.io/gramati-fe-globasa/eng/)

- *български:*
  - [Граматика на глобаса (Gemini)](https://salif.github.io/gramati-fe-globasa/bg-gemini/)
  - [Граматика на глобаса (Claude)](https://salif.github.io/gramati-fe-globasa/bg-claude/)

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
```

