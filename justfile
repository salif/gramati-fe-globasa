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
			(cd "$d" && mdbook build && mv book/html "../../docs/$d" && mv book/epub/* "../../docs/$d/" \
				&& rm -r ./book && printf "*\n" > "../../docs/$d/.gitignore"); \
		else echo "Skipping $d"; fi; \
	done

[private]
clean-gitignore:
	@cd books && find . -maxdepth 1 -mindepth 1 -type d -exec \
		rm -rf "../docs/{}/.gitignore" \;

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
	git merge main --strategy-option theirs --no-commit
	just clean-all build clean-gitignore
	git add ./docs
	git merge --continue
	git push
	git switch -

[private]
update-book-diff lang="eng":
	@cd "books/{{lang}}/src" && ls *_new.md | xargs -I {} sh -c \
		"diff --unified \$(basename --suffix _new.md {}).md {}"

[private]
update-book lang="eng" action="update":
	#!/usr/bin/env node
	const fs = require("fs")
	const os = require("os")
	const jsdom = require(os.homedir()+"/.local/lib/node_modules/jsdom")
	const beautify_html = require("/usr/lib/node_modules/js-beautify").html
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
		new_content = new_content.replaceAll("<br>", "<br />").replaceAll("pronamelexi", "pornamelexi")
		if (page_name === "abece-ji-lafuzu") {
			new_content = new_content.replaceAll("href=\"/" + lang + "/gramati/abece-ji-lafuzu#",
				"href=\"./abece-ji-lafuzu.html#")
			new_content = new_content.replaceAll("href=\"/" + lang + "/gramati/abece-ji-lafuzu",
				"href=\"https://xwexi.globasa.net/" + lang + "/gramati/abece-ji-lafuzu")
		}
		else {
		page_names.forEach(name => {
			new_content = new_content.replaceAll("href=\"/" + lang + "/gramati/" + name,
				"href=\"./" + name + ".html")
		})
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
	switch ("{{action}}") {
		case "update": main("{{lang}}"); break;
		case "remove": rem("{{lang}}"); break;
		default: console.error("Unknown action: {{action}}"); break;
	}
