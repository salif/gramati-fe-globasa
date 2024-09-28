#!/usr/bin/env -S just -f

args := ""
express_path := 'os.homedir()+"/.local/lib/node_modules/express"'
jsdom_path := 'os.homedir()+"/.local/lib/node_modules/jsdom"'
js_beautify_path := '"/usr/lib/node_modules/js-beautify"'

_:
	@just --list

[doc('Build books')]
build:
	#!/usr/bin/env bash
	set -euo pipefail
	cd books
	for d in *; do
		if ! test -d "../docs/$d"; then
			printf "Building %s\n" "$d"
			(cd "$d" && {
				mdbook build
				mv book/html "../../docs/$d"
				if test -d book/ze; then
					mv book/ze/* "../../docs/$d/"; fi
				rm -r ./book
				printf "*\n" > "../../docs/$d/.gitignore"
			})
		else
			printf "Skipping %s\n" "$d"; fi
	done

[no-cd]
[private]
build-ze f:
	@if test -d ../epub; then \
		cp ../epub/* ./{{ f }}.epub; fi
	@if test -d ../pdf; then \
		cp ../pdf/* ./{{ f }}.pdf; fi

# Prevents mdbook warning
[no-cd]
[private]
build-ze-ignore:
	@while read -r _ ; do :; done

[private]
clean-gitignore:
	@cd books && { \
		find . -maxdepth 1 -mindepth 1 -type d -exec \
			rm -rf "../docs/{}/.gitignore" \; ; \
	}

[doc('Delete built books')]
clean-all:
	@cd books && { \
		find . -maxdepth 1 -mindepth 1 -type d -exec \
			rm -rf "../docs/{}" \; ; \
	}

[doc('Delete a built book')]
clean book:
	@if ! test -d "./docs/{{ book }}"; then \
		printf "%s%s%s\n" "Skipping docs/" "{{ book }}" "; not a directory."; \
	else rm -r "./docs/{{ book }}"; fi

[confirm]
[doc('Apply theme changes to all books')]
sync-theme:
	@cd books && { \
		for d in */; do \
			rm -rf "./${d}theme"; \
			mkdir -p "./${d}theme/fonts/"; \
			touch "./${d}theme/fonts/fonts.css"; \
			cp -rft "./${d}theme/" ../theme/*; \
		done; \
	}

[doc('Serve')]
serve port='4000':
	#!/usr/bin/env node
	const os = require('os');
	const express = require({{ express_path }});
	const path = require('path');
	const app = express();
	const basePath = '/gramati-fe-globasa/';
	app.use(basePath, express.static(path.join('.', 'docs')));
	const server = app.listen({{ port }}, () => {
		const addr = server.address();
	    console.log(`Server is listening on http://localhost:${addr.port}${basePath}`);
	});

[confirm]
[doc('Publish to GitHub Pages')]
gh-pages:
	git diff --cached --quiet
	git switch gh-pages
	git merge main -X theirs --no-commit
	just clean-all build clean-gitignore update-sitemap
	git add ./docs
	git merge --continue
	git push
	git switch -

[private]
update-sitemap:
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

[private]
update-book-diff lang="eng":
	@cd "books/{{ lang }}/src" && { \
		ls *_new.md | xargs -I {} sh -c \
			"diff --unified \$(basename --suffix _new.md {}).md {}"; \
	}

[private]
update-book lang="eng" action="update":
	#!/usr/bin/env node
	const fs = require("fs")
	const os = require("os")
	const jsdom = require({{ jsdom_path }})
	const beautify_html = require({{ js_beautify_path }}).html
	const beautify_options = {
		"indent_size": "1", "indent_char": "\t", "max_preserve_newlines": "-1", "preserve_newlines": false,
		"end_with_newline": true, "wrap_line_length": 120}
	const glb_site = "https://xwexi.globasa.net/"
	let page_names = [
		"abece-ji-lafuzu", "falelexili-morfo", "gramatilexi", "inharelexi",
		"jumleli-estrutur", "jumlemonli-estrutur", "lexiklase", "lexikostrui",
		"numer-ji-mesi", "ofkatado-morfomon", "pimpan-logaxey", "pornamelexi", "tabellexi"]
	// page_names = ["jumlemonli-estrutur"]
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
		new_content = new_content.replaceAll("<br>", "<br />").replaceAll("pronamelexi", "pornamelexi").
		replaceAll('style="ancho:100%"', 'style="width:100%"').replace("Glosaba", "Globasa")
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
		new_content = beautify_html(new_content, beautify_options)
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
