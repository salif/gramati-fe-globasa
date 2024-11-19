// Populate the sidebar
//
// This is a script, and not included directly in the page, to control the total size of the book.
// The TOC contains an entry for each page, so if each page includes a copy of the TOC,
// the total size of the page becomes O(n**2).
class MDBookSidebarScrollbox extends HTMLElement {
    constructor() {
        super();
    }
    connectedCallback() {
        this.innerHTML = '<ol class="chapter"><li class="chapter-item expanded "><a href="gramati.html"><strong aria-hidden="true">1.</strong> Giriş</a></li><li class="chapter-item expanded "><a href="SUMMARY.html"><strong aria-hidden="true">2.</strong> İçindekiler</a></li><li class="chapter-item expanded "><a href="abece-ji-lafuzu.html"><strong aria-hidden="true">3.</strong> Alfabe ve Telaffuz</a></li><li class="chapter-item expanded "><a href="inharelexi.html"><strong aria-hidden="true">4.</strong> İçerik Sözcükleri: İsimler, Fiiller, Sıfatlar ve Zarflar</a></li><li class="chapter-item expanded "><a href="gramatilexi.html"><strong aria-hidden="true">5.</strong> İşlev Sözcükleri: Bağlaçlar, Edatlar ve İşlev Zarfları</a></li><li class="chapter-item expanded "><a href="pornamelexi.html"><strong aria-hidden="true">6.</strong> Zamirler</a></li><li class="chapter-item expanded "><a href="tabellexi.html"><strong aria-hidden="true">7.</strong> İlişki Zamirleri</a></li><li class="chapter-item expanded "><a href="numer-ji-mesi.html"><strong aria-hidden="true">8.</strong> Sayılar ve Yılın Ayları</a></li><li class="chapter-item expanded "><a href="falelexili-morfo.html"><strong aria-hidden="true">9.</strong> Fiil Çekimleri</a></li><li class="chapter-item expanded "><a href="jumlemonli-estrutur.html"><strong aria-hidden="true">10.</strong> Sözcük Sırası: Öbek Yapısı</a></li><li class="chapter-item expanded "><a href="jumleli-estrutur.html"><strong aria-hidden="true">11.</strong> Sözcük Sırası: Cümle Yapısı</a></li><li class="chapter-item expanded "><a href="lexikostrui.html"><strong aria-hidden="true">12.</strong> Kelime Oluşturma</a></li><li class="chapter-item expanded "><a href="ofkatado-morfomon.html"><strong aria-hidden="true">13.</strong> Kısaltılmış Morfemler</a></li><li class="chapter-item expanded "><a href="lexiklase.html"><strong aria-hidden="true">14.</strong> Sözcük Türleri</a></li><li class="chapter-item expanded "><a href="pimpan-logaxey.html"><strong aria-hidden="true">15.</strong> Yaygın Deyimler ve İfadeler</a></li></ol>';
        // Set the current, active page, and reveal it if it's hidden
        let current_page = document.location.href.toString();
        if (current_page.endsWith("/")) {
            current_page += "index.html";
        }
        var links = Array.prototype.slice.call(this.querySelectorAll("a"));
        var l = links.length;
        for (var i = 0; i < l; ++i) {
            var link = links[i];
            var href = link.getAttribute("href");
            if (href && !href.startsWith("#") && !/^(?:[a-z+]+:)?\/\//.test(href)) {
                link.href = path_to_root + href;
            }
            // The "index" page is supposed to alias the first chapter in the book.
            if (link.href === current_page || (i === 0 && path_to_root === "" && current_page.endsWith("/index.html"))) {
                link.classList.add("active");
                var parent = link.parentElement;
                if (parent && parent.classList.contains("chapter-item")) {
                    parent.classList.add("expanded");
                }
                while (parent) {
                    if (parent.tagName === "LI" && parent.previousElementSibling) {
                        if (parent.previousElementSibling.classList.contains("chapter-item")) {
                            parent.previousElementSibling.classList.add("expanded");
                        }
                    }
                    parent = parent.parentElement;
                }
            }
        }
        // Track and set sidebar scroll position
        this.addEventListener('click', function(e) {
            if (e.target.tagName === 'A') {
                sessionStorage.setItem('sidebar-scroll', this.scrollTop);
            }
        }, { passive: true });
        var sidebarScrollTop = sessionStorage.getItem('sidebar-scroll');
        sessionStorage.removeItem('sidebar-scroll');
        if (sidebarScrollTop) {
            // preserve sidebar scroll position when navigating via links within sidebar
            this.scrollTop = sidebarScrollTop;
        } else {
            // scroll sidebar to current active section when navigating via "next/previous chapter" buttons
            var activeSection = document.querySelector('#sidebar .active');
            if (activeSection) {
                activeSection.scrollIntoView({ block: 'center' });
            }
        }
        // Toggle buttons
        var sidebarAnchorToggles = document.querySelectorAll('#sidebar a.toggle');
        function toggleSection(ev) {
            ev.currentTarget.parentElement.classList.toggle('expanded');
        }
        Array.from(sidebarAnchorToggles).forEach(function (el) {
            el.addEventListener('click', toggleSection);
        });
    }
}
window.customElements.define("mdbook-sidebar-scrollbox", MDBookSidebarScrollbox);