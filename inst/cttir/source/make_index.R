# Offline review page; every illustration it displays was generated in R.
cttir_make_index <- function(root=".") {
  r<-utils::read.csv(base::file.path(root,"packages.csv"),stringsAsFactors=FALSE)
  r<-r[base::order(r$family,r$name),]
  cards<-base::vapply(base::seq_len(base::nrow(r)),function(i)base::sprintf(
    '<article data-name="%s"><h2>%s</h2><p>%s</p><img src="logos/%s/lockup.svg" alt="%s package identity" width="320" height="411" loading="lazy"><a class="download" href="logos/%s/lockup.svg" download>Download SVG</a></article>',
    r$name[i],r$name[i],cttir_family_labels[[r$family[i]]],r$name[i],r$name[i],r$name[i]),character(1))
  header<-c('<!doctype html><html lang="en" data-bs-theme="light"><head><meta charset="utf-8">',
    '<meta name="viewport" content="width=device-width, initial-scale=1"><title>CTTIR - Coder edition v5</title>',
    '<link rel="stylesheet" href="integration/cttir-fonts.css"><link rel="stylesheet" href="integration/cttir-tokens.css">',
    '<style>',
    '*{box-sizing:border-box}body{margin:0;background:var(--cttir-page);color:var(--cttir-text);font:16px/1.6 var(--cttir-font-body)}',
    'main{max-width:1280px;padding:48px 24px;margin:auto}header{border-bottom:1px solid var(--cttir-border);padding-bottom:24px;margin-bottom:28px}',
    '.eyebrow{font:600 12px var(--cttir-font-code);letter-spacing:.08em;color:var(--cttir-link)}h1{font-size:clamp(28px,5vw,48px);line-height:1.15;margin:16px 0;color:var(--cttir-heading)}',
    'header p{max-width:76ch}nav{display:flex;gap:16px;flex-wrap:wrap;align-items:end}label{font-size:14px;display:grid;gap:4px}select{font:inherit;padding:8px 12px;background:var(--cttir-page);color:var(--cttir-text);border:1px solid var(--cttir-border);border-radius:6px}',
    '.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(min(100%,250px),1fr));gap:24px}article{border:1px solid var(--cttir-border);padding:18px;border-radius:6px;min-width:0}',
    'article h2{font:600 17px var(--cttir-font-brand);overflow-wrap:anywhere;margin:0;color:var(--cttir-heading)}article p{font-size:12px;margin:4px 0 12px;opacity:.8}',
    'article img{display:block;width:100%;height:auto;aspect-ratio:6/6.928;object-fit:contain;background:transparent}a{color:var(--cttir-link);text-underline-offset:3px}.download{display:inline-block;font-size:13px;margin-top:12px}',
    ':focus-visible{outline:3px solid var(--cttir-link);outline-offset:4px}footer{margin-top:32px;font-size:13px}code{font-family:var(--cttir-font-code)}',
    '</style></head><body><main><header><div class="eyebrow">CTTIR / CODE + CRAFT / V5</div>',
    '<h1>One identity. Two compositions.</h1><p>45 scientific identities drawn directly in R. Choose artwork only or a name inside the hex. Every asset has a transparent exterior; this review page supplies the neutral background.</p>',
    '<nav aria-label="Preview controls"><label>Composition<select id="layout"><option value="lockup">Name inside hex</option><option value="hex">Artwork only</option></select></label>',
    '<label>Theme<select id="theme"><option value="light">Light</option><option value="dark">Dark</option><option value="auto">System</option></select></label>',
    '<label>Colour<select id="colour"><option value="colour">Topic colour</option><option value="mono">Grayscale (light)</option></select></label></nav></header><section class="grid" aria-label="All 45 identities">')
  footer<-c('</section><footer>Inter for prose. JetBrains Mono for package names and code. See <a href="integration/ADOPTION.txt">adoption instructions</a>. <a href="CTTIR_R_Hex_Gallery.pdf">Both compositions as PDF</a>.</footer></main>',
    '<script>',
    'const layout=document.getElementById("layout"),theme=document.getElementById("theme"),colour=document.getElementById("colour"),media=matchMedia("(prefers-color-scheme: dark)");',
    'function update(){const mono=colour.value==="mono";const dark=!mono&&(theme.value==="dark"||(theme.value==="auto"&&media.matches));document.documentElement.dataset.bsTheme=dark?"dark":"light";for(const card of document.querySelectorAll("article[data-name]")){const suffix=mono?"-mono":dark?"-dark":"";const src="logos/"+card.dataset.name+"/"+layout.value+suffix+".svg";card.querySelector("img").src=src;card.querySelector("a.download").href=src;}}',
    '[layout,theme,colour].forEach(x=>x.addEventListener("change",update));media.addEventListener("change",update);update();',
    '</script></body></html>')
  base::writeLines(c(header,cards,footer),base::file.path(root,"index.html"))
}
