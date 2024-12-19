import fs from "fs"
import path from "path"
import jsdom from "jsdom"
import js_beautify from "js-beautify"

const html_beautify = js_beautify.html
const beautify_options = {
	"indent_size": "1", "indent_char": "\t", "max_preserve_newlines": "-1", "preserve_newlines": false,
	"end_with_newline": true, "wrap_line_length": 120
}
const glb_site = "https://xwexi.globasa.net/"
let page_names = [
	"abece-ji-lafuzu", "falelexili-morfo", "gramatilexi", "inharelexi",
	"jumleli-estrutur", "jumlemonli-estrutur", "kurtogixey", "lexiklase", "lexikostrui",
	"numer-ji-mesi", "ofkatado-morfomon", "pimpan-logaxey", "pornamelexi", "tabellexi"]

async function fetch_page(url) {
	console.log(`Fetching ${url}`)
	const res = await fetch(url)
	const html = await res.text()
	return html
}
function fix_elements(page, page_name) {
	if (page_name === "pimpan-logaxey") {
		const audioElements = page.querySelectorAll("audio")
		audioElements.forEach(e => e.remove())
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
	new_content = html_beautify(html_beautify(new_content, beautify_options), beautify_options)
	return new_content
}

export async function update(lang) {
	for (let i = 0; i < page_names.length; i++) {
		const page_name = page_names[i]
		const orig_name = path.resolve("books", lang, "src", `${page_name}_orig.html`)
		const orig_src_name = path.resolve("books", lang, "src", `${page_name}_orig_src.html`)
		if (fs.existsSync(orig_name)) {
			console.log("Skipping " + page_name)
			continue
		}
		let page_src
		if (fs.existsSync(orig_src_name)) {
			page_src = fs.readFileSync(orig_src_name, "utf-8")
		} else {
			page_src = await fetch_page(page_name === "pimpan-logaxey" ?
				(glb_site + lang + "/" + page_name) :
				(glb_site + lang + "/gramati/" + page_name))
			fs.writeFileSync(orig_src_name, page_src)
		}
		const page = new jsdom.JSDOM(page_src).window.document
		fix_elements(page, page_name)
		const content = fix_content(page.getElementById("body-inner").innerHTML, page_name, lang)
		fs.writeFileSync(orig_name, content)
	}
}

export function remove(lang) {
	for (let i = 0; i < page_names.length; i++) {
		const page_name = page_names[i]
		const orig_name = path.resolve("books", lang, "src", `${page_name}_orig.html`)
		const orig_src_name = path.resolve("books", lang, "src", `${page_name}_orig_src.html`)
		if (fs.existsSync(orig_name)) fs.rmSync(orig_name)
		if (fs.existsSync(orig_src_name)) fs.rmSync(orig_src_name)
	}
}

export async function diff(lang, out) {
	const zx = await import("zx")
	const fs = zx.fs, path = zx.path
	const fileDir = path.resolve("books", lang, "src")
	const files = fs.readdirSync(fileDir)
	const allDiff = []
	for (const file of files) {
		if (file.endsWith("_orig.html")) {
			const f = file.substring(0, file.length - 10)
			const diff = await zx.$`diff --unified ${path.join(fileDir, f + ".md")} ${path.join(fileDir, file)}`.nothrow()
			if (diff.exitCode !== 0) allDiff.push(diff.stdout)
		}
	}
	if (out.length > 0) {
		fs.outputFileSync(path.resolve(out), allDiff.join("\n"))
		console.log("See " + out)
	}
}
