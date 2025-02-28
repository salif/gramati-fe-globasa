import * as zx from 'zx'
const fs = zx.fs, path = zx.path

export async function build() {
	const booksPath = path.resolve("books")
	const skippedBooks = []
	const books = fs.readdirSync(booksPath)
	for (const book of books) {
		const bookDir = path.join(booksPath, book)
		const destDir = path.resolve("docs", book)
		if (fs.pathExistsSync(destDir)) {
			skippedBooks.push(book)
			continue
		}
		await buildBook(book, bookDir, destDir)
	}
	if (skippedBooks.length > 0)
		console.log(`Skipping ${skippedBooks.join(', ')}`)
}

async function buildBook(book, bookDir, destDir) {
	console.log(`Building ${book}`)
	try {
		await zx.$({ cwd: bookDir })`mdbook build`
		fs.ensureDirSync(destDir)
		fs.copySync(path.join(bookDir, "book", "html"), destDir, { recursive: true })
		copyEpubFile(bookDir, destDir)
		fs.outputFileSync(path.join(destDir, ".gitignore"), "*")
		await zx.$({ cwd: bookDir })`mdbook clean`
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
	const nindex = md.indexOf("[epub-link]:")
	if (nindex > -1) {
		return md.substring(nindex + 12, md.indexOf("\n", nindex))
	}
	else {
		const lindex = md.indexOf(".epub)")
		if (lindex === -1) {
			throw new Error("No epub name")
		}
		return md.substring(md.lastIndexOf("(", lindex) + 1, lindex + 5)
	}
}

export function del(bookName) {
	const docsPath = path.resolve("docs")
	let books = []
	if (bookName === "all") {
		books = fs.readdirSync(docsPath, { withFileTypes: true }).filter(
			e => e.isDirectory() && e.name !== "fonts").map(e => e.name)
	} else {
		books = [bookName]
	}
	for (const book of books) {
		const bookPath = path.join(docsPath, book)
		if (fs.pathExistsSync(bookPath)) {
			fs.removeSync(bookPath)
		} else {
			console.warn(`${book} is already deleted`)
		}
	}
}

export function syncTheme() {
	const booksPath = path.resolve("books")
	const books = fs.readdirSync(booksPath)
	for (const book of books) {
		const themePath = path.join(booksPath, book, "theme")
		if (fs.pathExistsSync(themePath)) {
			fs.removeSync(themePath)
		}
		fs.mkdirSync(themePath)
		fs.copySync(path.resolve("theme"), themePath, { recursive: true })
		fs.mkdirSync(path.join(themePath, "fonts"))
		fs.writeFileSync(path.join(themePath, "fonts", "fonts.css"), "")
	}
}
