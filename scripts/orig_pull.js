import fs from "fs"
import path from "path"
import jsdom from "jsdom"
import js_beautify from "js-beautify"

const
	beautifyOptions = {
		"indent_size": "1", "indent_char": "\t", "max_preserve_newlines": "-1",
		"preserve_newlines": false, "end_with_newline": true, "wrap_line_length": 120
	},
	origAddress = "https://xwexi.globasa.net/",
	pageNames = [
		"abece-ji-lafuzu", "falelexili-morfo", "gramatilexi", "inharelexi",
		"jumleli-estrutur", "jumlemonli-estrutur", "kurtogixey", "lexiklase", "lexikostrui",
		"numer-ji-mesi", "ofkatado-morfomon", "pimpan-logaxey", "pornamelexi", "tabellexi"]

async function fetchPage(url) {
	console.log(`Fetching ${url}`)
	const res = await fetch(url)
	return await res.text()
}

function fixPageElements(page, pageName) {
	if (pageName === "pimpan-logaxey") {
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

function fixPageContent(content, pageName, bookName) {
	let newContent = content
	newContent = newContent.replaceAll("<br>", "<br />").replaceAll(String.fromCharCode(8203), "")
	if (!newContent.includes("pronamelexi")) console.log(`No 'pronamelexi' on ${pageName}`)
	newContent = newContent.replaceAll("pronamelexi", "pornamelexi")
	if (bookName === "spa") {
		if (newContent.includes('style="ancho:100%"')) console.log(`Found 'style="ancho:100%"' on ${pageName}`)
		newContent = newContent.replaceAll('style="ancho:100%"', 'style="width:100%"')
	}
	if (pageName === "abece-ji-lafuzu") {
		if (bookName === "spa") {
			newContent = newContent.replaceAll(
				'href="/' + bookName + "/grammar/abece-ji-lafuzu#",
				'href="./abece-ji-lafuzu.html#')
		} else {
			newContent = newContent.replaceAll(
				'href="/' + bookName + "/gramati/abece-ji-lafuzu#",
				'href="./abece-ji-lafuzu.html#')
		}
		newContent = newContent.replaceAll(
			'href="/' + bookName + "/gramati/abece-ji-lafuzu",
			'href="https://xwexi.globasa.net/' + bookName + "/gramati/abece-ji-lafuzu")
	}
	else {
		pageNames.forEach(name => {
			newContent = newContent.replaceAll(
				'href="/' + bookName + "/gramati/" + name,
				'href="./' + name + ".html")
		})
	}
	if (pageName === "inharelexi") {
		if (!newContent.includes("Glosaba")) console.log(`No 'Glosaba' on ${pageName}`)
		newContent = newContent.replace("Glosaba", "Globasa")
	}
	if (pageName === "tabellexi") {
		if (!newContent.includes('<table style="width:100%">')) console.log(`No '<table style="width:100%">' on ${pageName}`)
		newContent = newContent.replace(
			'<table style="width:100%">',
			'<table style="width:100%" class="large-table">')
		if (bookName === "spa") {
			newContent = newContent.replace(
				"_¡Qué día!</p>", "¡<em>Qué</em> día!</p>").replace(
					"_¡Qué hermoso!</p>", "¡<em>Qué</em> hermoso!</p>").replace(
						"_¡Qué hermoso día!</p>", "¡<em>Qué</em> hermoso día!</p>"
					)
		}
	}
	if (pageName === "jumleli-estrutur") {
		if (!newContent.includes('<td colspan="2" style="font-size:125%;"><b>Myaw sen in sanduku.'))
			console.log(`No '<td colspan="2" style="font-size:125%;"><b>Myaw sen in sanduku.' on ${pageName}`)
		newContent = newContent.replace(
			'<td colspan="2" style="font-size:125%;"><b>Myaw sen in sanduku.',
			'<td colspan="3" style="font-size:125%;"><b>Myaw sen in sanduku.').replace(
				'<td colspan="3" style="font-size:125%;"><b>Mi jixi ki yu le xuli mobil.',
				'<td colspan="2" style="font-size:125%;"><b>Mi jixi ki yu le xuli mobil.').replace(
					'<td colspan="3" style="font-size:125%;"><b>Ki yu le xuli mobil no surprisa mi.',
					'<td colspan="2" style="font-size:125%;"><b>Ki yu le xuli mobil no surprisa mi.').replace(
						'<strong>To sen problem, na sen nensabar.',
						'<strong>To sen problema, na sen nensabar.')
	}
	if (pageName === "jumlemonli-estrutur") {
		if (!newContent.includes('<table style="width:100%">')) console.log(`No '<table style="width:100%">' on ${pageName}`)
		newContent = newContent.replace(
			'<table style="width:100%">',
			'<table style="width:100%" class="large-table">').replace(
				'<table style="width:100%">',
				'<table style="width:100%" class="large-table">')
	}
	if (pageName === "ofkatado-morfomon") {
		newContent = newContent.replace(
			"https://www.amazon.com/Unfolding-Language-Evolutionary-Mankinds-Invention/dp/0805080120/ref=sr_1_1?keywords=unfolding%2Bof%2Blanguage&amp;qid=1565409086&amp;s=gateway&amp;sr=8-1",
			"https://www.amazon.com/Unfolding-Language-Evolutionary-Mankinds-Invention/dp/0805080120/ref=sr_1_1"
		)
	}
	for (let i = 0; i < 2; i++) {
		newContent = js_beautify.html(newContent, beautifyOptions)
	}
	return newContent
}

export async function update(bookName) {
	const bookSrcPath = path.resolve("books", bookName, "src")
	for (const pageName of pageNames) {
		const origPagePath = path.join(bookSrcPath, `${pageName}_orig.html`)
		const origSrcPagePath = path.join(bookSrcPath, `${pageName}_orig_src.html`)
		if (fs.existsSync(origPagePath)) {
			console.log(`Skipping ${pageName}`)
			continue
		}
		let pageSrc = ""
		if (fs.existsSync(origSrcPagePath)) {
			pageSrc = fs.readFileSync(origSrcPagePath, "utf-8")
		} else {
			const pageAddress = pageName === "pimpan-logaxey" ?
				`${origAddress}${bookName}/${pageName}` :
				`${origAddress}${bookName}/gramati/${pageName}`
			pageSrc = await fetchPage(pageAddress)
			fs.writeFileSync(origSrcPagePath, pageSrc)
		}
		const page = new jsdom.JSDOM(pageSrc).window.document
		fixPageElements(page, pageName)
		const content = fixPageContent(page.getElementById("body-inner").innerHTML, pageName, bookName)
		fs.writeFileSync(origPagePath, content)
	}
}

export function remove(bookName) {
	const removed = { orig: 0, origSrc: 0 }
	const booksSrcPath = path.resolve("books", bookName, "src")
	for (const pageName of pageNames) {
		const origPagePath = path.join(booksSrcPath, `${pageName}_orig.html`)
		const origSrcPagePath = path.join(booksSrcPath, `${pageName}_orig_src.html`)
		if (fs.existsSync(origPagePath)) {
			fs.rmSync(origPagePath)
			removed.orig += 1
		}
		if (fs.existsSync(origSrcPagePath)) {
			fs.rmSync(origSrcPagePath)
			removed.origSrc += 1
		}
	}
	if (removed.orig + removed.origSrc == 0) {
		console.warn("No removed files")
	}
}

export async function diff(bookName, outFileName) {
	const zx = await import("zx")
	const fs = zx.fs, path = zx.path
	const bookSrcPath = path.resolve("books", bookName, "src")
	const srcFiles = fs.readdirSync(bookSrcPath).filter(e => e.endsWith("_orig.html"))
	const allDiff = []
	for (const srcFile of srcFiles) {
		const srcFileBase = srcFile.substring(0, srcFile.length - 10)
		const diffOldFile = path.join(bookSrcPath, srcFileBase + ".md")
		const diffNewFile = path.join(bookSrcPath, srcFile)
		const diff = await zx.$`diff --unified ${diffOldFile} ${diffNewFile}`.nothrow()
		if (diff.exitCode !== 0) {
			allDiff.push(diff.stdout)
		}
	}
	if (srcFiles.length === 0) {
		console.warn("No orig files")
	} else if (outFileName.length > 0) {
		fs.outputFileSync(path.resolve(outFileName), allDiff.join("\n"))
		console.log("See " + outFileName)
	}
}
