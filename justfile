#!/usr/bin/just -f

_:
	@just --list

[doc('Build Bulgarian books')]
build-bg: clean
	cd ./bg-claude && mdbook build
	mv ./bg-claude/book/ ./docs/bg-claude
	cd ./bg-gemini && mdbook build
	mv ./bg-gemini/book/ ./docs/bg-gemini

[doc('Build all books')]
build: clean build-bg
	cd ./eng && mdbook build
	mv ./eng/book/ ./docs/eng

[doc('Delete built books')]
clean:
	rm -rf ./docs/bg-claude
	rm -rf ./docs/bg-gemini
	rm -rf ./docs/eng

[doc('Apply theme changes to all books')]
sync-theme:
	cp -ft ./bg-claude/theme/ ./theme/*
	cp -ft ./bg-gemini/theme/ ./theme/*
	cp -ft ./eng/theme/ ./theme/*

[doc('Apply docs/README.md changes to README.md')]
sync-readme:
	cp -f ./docs/README.md ./README.md
	sed -i 's/(.\//(https:\/\/salif.github.io\/gramati-fe-globasa\//g' ./README.md

[confirm]
[doc('Publish to GitHub Pages')]
gh-pages:
	git switch gh-pages
	git rebase main
	just build
	git add ./docs
	git commit -m "Sync"
	git push --force-with-lease
	git switch -
