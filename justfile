#!/usr/bin/env -S just -f

args := ""

_:
	@just --list

[doc('Build books')]
build:
	@cd books && \
	for d in *; do \
		if ! test -d "../docs/$d"; then \
			echo "Building $d"; \
			(cd "$d" && mdbook build && mv book "../../docs/$d"); \
		else echo "Skipping $d"; fi; \
	done

[doc('Delete built books')]
clean-all:
	@cd books && find . -maxdepth 1 -mindepth 1 -type d -exec \
		rm -rf "../docs/{}" \;

[doc('Delete a built book')]
clean book:
	@if ! test -d "./docs/{{book}}"; then \
		echo "Skipping docs/{{book}}; not a directory."; \
	else rm -r "./docs/{{book}}"; fi

[confirm]
[doc('Apply theme changes to all books')]
sync-theme:
	@cd books && \
	for d in */; do \
		rm -rf "./${d}theme"; \
		mkdir -p "./${d}theme"; \
		cp -ft "./${d}theme/" ../theme/*; \
	done

[doc('Apply docs/README.md changes to README.md')]
sync-readme:
	-chmod +w ./README.md
	cp -f ./docs/README.md ./README.md
	sed -i -e 's/(.\//(https:\/\/salif.github.io\/gramati-fe-globasa\//g' -e 's/<\!---//g' -e 's/--->//g' ./README.md
	-chmod -w ./README.md

[private]
serve-init:
	cd docs && bundle install

[doc('Jekyll serve')]
serve:
	cd docs && if ! bundle check; then just serve-init; fi && \
		bundle exec jekyll serve {{args}}

[confirm]
[doc('Publish to GitHub Pages')]
gh-pages:
	git switch gh-pages
	git rebase main
	just clean-all build
	git add ./docs
	git commit -m "Sync"
	git push --force-with-lease
	git switch -