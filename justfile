#!/usr/bin/env -S just -f

export PATH := "./node_modules/.bin:" + env_var('PATH')
export NODE_PATH := justfile_directory() / "node_modules"

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
		fs.removeSync(path.resolve("dest", book, ".gitignore"))
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
		books = zx.fs.readdirSync(zx.path.resolve("docs"))
	} else {
		books = [bookName]
	}
	for (const book of books) {
		const dest = zx.path.resolve("docs", book)
		if (zx.fs.pathExistsSync(zx.path.join(dest, "toc.html"))) {
			zx.fs.removeSync(dest)
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
	const os = require('os');
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
orig_diff lang="eng":
	@cd "books/{{ lang }}/src" && { \
		ls *_new.md | xargs -I {} sh -c \
			"diff --unified \$(basename --suffix _new.md {}).md {}"; \
	}

[group('pull-orig')]
orig_pull lang action="update":
	#!/usr/bin/env node
	"use strict"
	const fs = require("fs")
	const os = require("os")
	const jsdom = require("jsdom")
	const beautify_html = require("js-beautify").html
	const beautify_options = {
		"indent_size": "1", "indent_char": "\t", "max_preserve_newlines": "-1", "preserve_newlines": false,
		"end_with_newline": true, "wrap_line_length": 120}
	const glb_site = "https://xwexi.globasa.net/"
	let page_names = [
		"abece-ji-lafuzu", "falelexili-morfo", "gramatilexi", "inharelexi",
		"jumleli-estrutur", "jumlemonli-estrutur", "kurtogixey", "lexiklase", "lexikostrui",
		"numer-ji-mesi", "ofkatado-morfomon", "pimpan-logaxey", "pornamelexi", "tabellexi"]
	async function get_page(url) {
		const res = await fetch(url)
		const page = await res.text()
		return new jsdom.JSDOM(page).window.document
	}
	function fix_elements(page, page_name) {
		if (page_name === "pimpan-logaxey") {
			const audioElements = page.querySelectorAll("audio")
			audioElements.forEach(e=>e.remove())
		}
		const anchorElements = page.querySelectorAll('a[id]');
		anchorElements.forEach(anchor => {
			const span = page.createElement('span');
			span.id = anchor.id;
			anchor.parentNode.replaceChild(span, anchor);
		});
	}
	function fix_content(content, page_name, lang) {
		let new_content = content
		new_content = new_content.replaceAll("<br>", "<br />").
			replaceAll("pronamelexi", "pornamelexi").
			replaceAll('style="ancho:100%"', 'style="width:100%"').
			replace("Glosaba", "Globasa")
		if (page_name === "abece-ji-lafuzu") {
			if (lang === "spa") {
				new_content = new_content.replaceAll(
					'href="/' + lang + "/grammar/abece-ji-lafuzu#",
					'href="./abece-ji-lafuzu.html#')
			} else {
				new_content = new_content.replaceAll(
					'href="/' + lang + "/gramati/abece-ji-lafuzu#",
					'href="./abece-ji-lafuzu.html#')
			}
			new_content = new_content.replaceAll(
				'href="/' + lang + "/gramati/abece-ji-lafuzu",
				'href="https://xwexi.globasa.net/' + lang + "/gramati/abece-ji-lafuzu")
		}
		else {
			page_names.forEach(name => {
				new_content = new_content.replaceAll(
					'href="/' + lang + "/gramati/" + name,
					'href="./' + name + ".html")
			})
		}
		if (page_name === "tabellexi") {
			new_content = new_content.replace(
				'<table style="width:100%">',
				'<table style="width:100%" class="large-table">')
		}
		if (page_name === "jumleli-estrutur") {
			new_content = new_content.replace(
				'<td colspan="2" style="font-size:125%;"><b>Myaw sen in sanduku.',
				'<td colspan="3" style="font-size:125%;"><b>Myaw sen in sanduku.').replace(
				'<td colspan="3" style="font-size:125%;"><b>Mi jixi ki yu le xuli mobil.',
				'<td colspan="2" style="font-size:125%;"><b>Mi jixi ki yu le xuli mobil.').replace(
				'<td colspan="3" style="font-size:125%;"><b>Ki yu le xuli mobil no surprisa mi.',
				'<td colspan="2" style="font-size:125%;"><b>Ki yu le xuli mobil no surprisa mi.').replace(
				'<strong>To sen problem, na sen nensabar.',
				'<strong>To sen problema, na sen nensabar.')
		}
		if (page_name === "jumlemonli-estrutur") {
			new_content = new_content.replace(
				'<table style="width:100%">',
				'<table style="width:100%" class="large-table">').replace(
					'<table style="width:100%">',
					'<table style="width:100%" class="large-table">')
		}
		new_content = beautify_html(beautify_html(new_content, beautify_options), beautify_options)
		return new_content
	}
	async function main(lang) {
		for (let i = 0; i < page_names.length; i++) {
			const page_name = page_names[i]
			const new_name = "./books/" + lang + "/src/" + page_name + "_new.md"
			if (fs.existsSync(new_name)) {
				console.log("Skipping " + page_name)
				continue
			}
			const page = await get_page(page_name === "pimpan-logaxey" ?
				(glb_site + lang + "/" + page_name) :
				(glb_site + lang + "/gramati/" + page_name))
			fix_elements(page, page_name)
			const content = fix_content(page.getElementById("body-inner").innerHTML, page_name, lang)
			fs.writeFileSync(new_name, content)
		}
	}
	function rem(lang) {
		for (let i = 0; i < page_names.length; i++) {
			const page_name = page_names[i]
			const new_name = "./books/" + lang + "/src/" + page_name + "_new.md"
			if (!fs.existsSync(new_name)) {
				console.log("Skipping " + page_name)
				continue
			}
			fs.rmSync(new_name)
		}
	}
	switch ("{{ action }}") {
		case "update": main("{{ lang }}"); break;
		case "remove": rem("{{ lang }}"); break;
		default: console.error("Unknown action: {{ action }}"); break;
	}
