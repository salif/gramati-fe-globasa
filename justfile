#!/usr/bin/env -S just -f

set unstable
just_scripts := justfile_directory() / "scripts"
export PATH := just_scripts / "node_modules" / ".bin" + ":" + env_var('PATH')
export NODE_PATH := just_scripts / "node_modules"

_: && check_requirements
	@just --list --unsorted

[private]
check_requirements:
	@COMMANDS=("node" "zx" "mdbook" "mdbook-epub"); \
	for COMMAND in "${COMMANDS[@]}"; do \
		if ! command -v "${COMMAND}" 2>&1 >/dev/null; then \
			printf "%sWarning: '%s' is not installed or not in PATH%s\n" \
				"{{ style("warning") }}" "${COMMAND}" "{{ NORMAL }}" >&2; \
		fi; \
	done;

[group('make')]
[doc('Build books')]
[extension(".mjs"), script("node")]
build:
	import {build} from "{{ just_scripts }}/make.js"; build();	

[group('make')]
[doc('Delete a built book')]
[extension(".mjs"), script("node")]
del book:
	import {del} from "{{ just_scripts }}/make.js"; del("{{ book }}");	

[confirm]
[group('make')]
[doc('Apply theme changes to all books')]
sync_theme:
	@cd books && { \
		for d in */; do \
			rm -rf "./${d}theme"; \
			mkdir -p "./${d}theme/fonts/"; \
			touch "./${d}theme/fonts/fonts.css"; \
			cp -rft "./${d}theme/" ../theme/*; \
		done; \
	}

[group('test')]
[doc('Serve')]
serve port='4000':
	#!/usr/bin/env node
	"use strict"
	const express = require('express');
	const path = require('path');
	const app = express();
	const basePath = '/gramati-fe-globasa/';
	app.use(basePath, express.static(path.join('.', 'docs')));
	const server = app.listen({{ port }}, () => {
		const addr = server.address();
		console.log(`Server is listening on http://localhost:${addr.port}${basePath}`);
	});

[private]
[group('push')]
del_all_gitignore:
	#!/usr/bin/env node
	"use strict"
	const {fs, path} = require("zx")
	const books = fs.readdirSync(path.resolve("books"))
	for (const book of books) {
		fs.removeSync(path.resolve("docs", book, ".gitignore"))
	}

[confirm]
[group('push')]
[doc('Publish to GitHub Pages')]
gh_pages: && (del "all") build del_all_gitignore update_sitemap gh_pages_2
	git diff --cached --quiet
	git switch gh-pages
	git merge main -X theirs --no-ff --no-commit

[group('push')]
[private]
gh_pages_2:
	git add docs
	git merge --continue
	git push
	git switch -

[private]
[group('push')]
update_sitemap:
	#!/usr/bin/env bash
	set -euo pipefail
	cd docs
	SITEMAP='sitemap.xml'
	URL='https://salif.github.io/gramati-fe-globasa/'
	NOW=$(date +%F)
	printf "%s\n%s\n" '<?xml version="1.0" encoding="UTF-8"?>' \
	'<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' > ${SITEMAP}
	find * -type f -name '*.html' ! -name '404.html' ! -name 'print.html' | LC_COLLATE=C sort | \
	while read -r line; do
		LASTMOD=$(git log -1 --pretty="format:%cs" "${line}")
		if [[ "${line}" == *index.html ]]; then
			line="${line::-10}"
		fi
		printf "%s\n%s%s%s\n%s%s%s\n%s\n" '<url>' \
		'<loc>' "${URL}${line}" '</loc>' \
		'<lastmod>' "${LASTMOD:-${NOW}}" '</lastmod>' '</url>' >> ${SITEMAP}
	done
	printf "%s\n" '</urlset>' >> ${SITEMAP}

[group('pull-orig')]
[extension(".mjs"), script("node")]
orig_pull book:
	import {update} from "{{ just_scripts }}/orig_pull.js"; update("{{ book }}");

[group('pull-orig')]
[extension(".mjs"), script("node")]
orig_remove book:
	import {remove} from "{{ just_scripts }}/orig_pull.js"; remove("{{ book }}");

[group('pull-orig')]
[extension(".mjs"), script("node")]
orig_diff book out="orig.diff":
	import {diff} from "{{ just_scripts }}/orig_pull.js"; diff("{{ book }}", "{{ out }}");
