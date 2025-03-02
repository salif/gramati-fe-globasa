set -euo pipefail
cd docs
SITEMAP='sitemap.xml'
URL='https://salif.github.io/gramati-fe-globasa/'
NOW=$(date +%F)
printf "%s\n%s\n" '<?xml version="1.0" encoding="UTF-8"?>' \
'<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' > ${SITEMAP}
find * -type f -name '*.html' ! -name '404.html' ! -name 'print.html' | LC_COLLATE=C sort | \
while read -r line; do
	if git diff --quiet -- "${line}"; then
		LASTMOD=$(git log -1 --pretty="format:%cs" -- "${line}")
	else
		LASTMOD=$(date +%F)
	fi
	# Not sitemap
	sed -i -e 's/content=\"cover.png\"/content=\"https:\/\/salif.github.io\/gramati-fe-globasa\/'$(dirname $line)'\/cover.png\"/' $line
	if [[ "${line}" == *index.html ]]; then
		line="${line::-10}"
	fi
	printf "%s\n%s%s%s\n%s%s%s\n%s\n" '<url>' \
	'<loc>' "${URL}${line}" '</loc>' \
	'<lastmod>' "${LASTMOD:-${NOW}}" '</lastmod>' '</url>' >> ${SITEMAP}
done
printf "%s\n" '</urlset>' >> ${SITEMAP}
