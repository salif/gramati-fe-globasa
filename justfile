#!/usr/bin/just -f

_:
	@just --list

build-bg: clean
	cd ./bg-claude && mdbook build
	mv ./bg-claude/book/ ./docs/bg-claude
	cd ./bg-gemini && mdbook build
	mv ./bg-gemini/book/ ./docs/bg-gemini

build: clean build-bg
	cd ./eng && mdbook build
	mv ./eng/book/ ./docs/eng

clean:
	rm -rf ./docs/bg-claude
	rm -rf ./docs/bg-gemini
	rm -rf ./docs/eng

sync-readme:
	cp -f ./docs/README.md ./README.md
	sed -i 's/(.\//(https:\/\/salif.github.io\/gramati-fe-globasa\//g' ./README.md

gh-pages:
	git switch gh-pages
	git rebase main
	just build
	git add ./docs
	git commit -m "Sync"
	git push --force-with-lease
	git switch -
