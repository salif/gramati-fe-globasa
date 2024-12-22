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
build:
	#!/usr/bin/env node
	"use strict"
	const zx = require("zx")
	const fs = zx.fs, path = zx.path
	const skippedBooks = []
	;(async () => {
		const jfDir = process.cwd()
		const books = fs.readdirSync("./books")
		for (const book of books) {
			const bookDir = path.join(jfDir, "books", book)
			const destDir = path.join(jfDir, "docs", book)
			if (fs.pathExistsSync(destDir)) {
				skippedBooks.push(book)
				continue
			}
			zx.cd(bookDir)
			await buildBook(book, bookDir, destDir)
		}
		if (skippedBooks.length > 0)
			console.log(`Skipping ${skippedBooks.join(', ')}`)
	})()
	async function buildBook(book, bookDir, destDir) {
		console.log(`Building ${book}`)
		try {
			await zx.$`mdbook build`
			fs.ensureDirSync(destDir)
			fs.copySync(path.join(bookDir, "book", "html"), destDir, {recursive: true})
			copyEpubFile(bookDir, destDir)
			fs.outputFileSync(path.join(destDir, ".gitignore"), "*")
			await zx.$`mdbook clean`
		} catch (error) {
			console.error(`Error building ${book}: ${error}`)
			process.exitCode = 1
		}
	}
	function copyEpubFile(bookDir, destDir) {
		const destEpubName = parseEpubFileName(path.join(bookDir, "src", "gramati.md"))
		const epubDir = path.join(bookDir, "book", "epub")
		const epubs = fs.readdirSync(epubDir)
		if (epubs.length === 1) {
			fs.copyFileSync(path.join(epubDir, epubs[0]), path.join(destDir, destEpubName))
		} else {
			console.error("Epub files not one:", epubs)
		}
	}
	function parseEpubFileName(mdFile) {
		const md = fs.readFileSync(mdFile, "utf-8")
		const lindex = md.indexOf(".epub)")
		return md.substring(md.lastIndexOf("(", lindex)+1, lindex+5)
	}

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

[group('make')]
[doc('Delete a built book')]
del book:
	#!/usr/bin/env node
	"use strict"
	const zx = require("zx")
	const bookName = "{{ book }}"
	let books = []
	if (bookName === "all") {
		books = zx.fs.readdirSync(zx.path.resolve("docs"),
			{ withFileTypes: true }).filter(e => e.isDirectory() && e.name !== "fonts").map(e => zx.path.resolve("docs", e.name))
	} else {
		books = [bookName]
	}
	for (const book of books) {
		if (zx.fs.pathExistsSync(book)) {
			zx.fs.removeSync(book)
		} else if (bookName !== "all") {
			console.log(`Skipping ${book}`)
		}
	}

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
