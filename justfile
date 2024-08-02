#!/usr/bin/just -f

_:
	@just --list

build:
	#!/usr/bin/bash
	cd ./bg-claude
	mdbook build
	rm -rf ../docs/bg-claude
	mv ./book/ ../docs/bg-claude
	cd ../bg-gemini
	mdbook build
	rm -rf ../docs/bg-gemini
	mv ./book/ ../docs/bg-gemini
	cd ../eng
	mdbook build
	rm -rf ../docs/eng
	mv ./book/ ../docs/eng
	cd ..

clean:
	rm -rf ./docs/bg-claude
	rm -rf ./docs/bg-gemini
	rm -rf ./docs/eng

gh-pages:
	git switch gh-pages
	git rebase main
	just build
	git add ./docs
	git commit -m "Sync"
	git push --force-with-lease
	git switch -
