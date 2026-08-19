# barrosef.com Professional Site Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the rejected notebook identity and the PaperMod theme with a self-authored professional authority site — dark navy chrome, white reading surfaces, IBM Plex — and ship it live.

**Architecture:** PaperMod is removed entirely. We author a small Hugo template set (`layouts/`) plus one stylesheet directory (`assets/css/`), so nothing fights theme CSS on specificity. Fonts self-hosted. The owner's professional facts live in `hugo.toml` under `params.profile` and each homepage block renders only when its values are non-empty, so the site is complete-looking before the bio exists.

**Tech Stack:** Hugo extended 0.148.2, plain CSS (grid/flex, custom properties), IBM Plex Sans + Mono (SIL OFL, self-hosted), Python 3 stdlib for the existing translation checker.

**Spec:** `docs/superpowers/specs/2026-08-19-barrosef-com-professional-site-design.md` — read it before Task 1, especially "Why the previous design failed".

## Global Constraints

- **`themes/` is deleted.** After Task 1 there is no theme submodule; every template is ours. Never re-add one.
- **No third-party requests.** Built HTML must never reference `fonts.googleapis.com` or `fonts.gstatic.com`. Fonts are downloaded once, subset, and committed with `static/fonts/OFL.txt`.
- **Palette (fixed, no theme toggle):** ground `#0b1622`, panel `#111f30`, border `#1b2b3d`, text `#dce6f2`, muted `#9db3cc`, dim `#5d7086`, accent `#5b8fd6`, reading surface `#ffffff`, text-on-white `#16233a`, muted-on-white `#5d6b7d`, link-on-white `#1d4e89`.
- **No rounded corners, no drop shadows** anywhere. Structure comes from hairlines and panels.
- Body 17px/1.65 on reading surfaces. IBM Plex Sans for text, IBM Plex Mono for figures/labels/eyebrows.
- Font budget **≤140KB** total woff2; Portuguese diacritics (`ã õ ç á é í ó ú â ê ô à`) verified in the subset — blocking.
- Every colour pair meets **WCAG AA** — blocking.
- **Full EN/PT mirror.** Every page exists in both languages; `scripts/check_translations.py` must keep passing.
- `make check` passes at every commit.
- Work from the repo root: `/opt/wks/personal/barrosef-workspace/barrosef.com`.

## File Structure

| Path | Responsibility |
|---|---|
| `hugo.toml` | Languages, menus, `params.profile`, `[markup.highlight] noClasses=false`, outputs |
| `layouts/baseof.html` | Document shell: head, header, main block, footer |
| `layouts/home.html` | Authority homepage; every fact block conditional |
| `layouts/list.html` | Writing index grouped by pillar |
| `layouts/single.html` | Post page — single readable column on white |
| `layouts/page.html` | About / Contact / Newsletter |
| `layouts/404.html` | Bilingual 404 |
| `layouts/taxonomy.html`, `layouts/terms.html` | Category and tag listings |
| `layouts/_partials/head.html` | Meta, OG/Twitter cards, favicons, font preload |
| `layouts/_partials/header.html` | Name, nav, language switch |
| `layouts/_partials/footer.html` | Contact, social icons |
| `layouts/_partials/lang-switch.html` | EN/PT switcher |
| `layouts/_partials/social-icons.html` | Inline SVG social links |
| `layouts/_partials/post-card.html` | One writing-index entry |
| `assets/css/main.css` | Whole stylesheet: tokens, base, components |
| `static/fonts/*.woff2`, `static/fonts/OFL.txt` | Self-hosted IBM Plex |
| `content/{en,pt}/…` | Posts plus about, contact, newsletter |

Retained from the blog build and re-wired, not rewritten: `layouts/_partials/extend_head.html` (consent-gated GA4), `extend_footer.html` (consent banner), `newsletter-form.html`, `comments.html`, `layouts/shortcodes/{instagram,tiktok,newsletter}.html`, `scripts/`, `tests/`, `Makefile`, `.github/`, `static/CNAME`.

---

### Task 1: Demolition and a building skeleton

**Files:**
- Delete: `themes/PaperMod` submodule, `.gitmodules`, `assets/css/extended/` (all four), `static/fonts/ebgaramond-*.woff2`, `static/fonts/OFL.txt`, `layouts/single.html`, `layouts/404.html`, `content/en/search.md`, `content/pt/search.md`, `static/favicon*`, `static/apple-touch-icon.png`, `static/safari-pinned-tab.svg`, `static/og-default.png`
- Create: `layouts/baseof.html`, `layouts/home.html`, `layouts/list.html`, `layouts/single.html`, `layouts/page.html`, `layouts/404.html`, `layouts/_partials/head.html`, `layouts/_partials/header.html`, `layouts/_partials/footer.html`, `assets/css/main.css`
- Modify: `hugo.toml`

**Interfaces:**
- Produces: a site that builds and serves both languages with our own templates and zero theme. Later tasks fill in design and content.

- [ ] **Step 1: Remove the theme and the old identity**

```bash
git rm -r --cached themes/PaperMod
rm -rf themes/PaperMod .gitmodules
rm -rf assets/css/extended
rm -f static/fonts/ebgaramond-*.woff2 static/fonts/OFL.txt
rm -f layouts/single.html layouts/404.html
rm -f content/en/search.md content/pt/search.md
rm -f static/favicon.ico static/favicon-16x16.png static/favicon-32x32.png static/apple-touch-icon.png static/safari-pinned-tab.svg static/og-default.png
git rm -f .gitmodules 2>/dev/null || true
```

Keep `layouts/_partials/extend_head.html`, `extend_footer.html`, `newsletter-form.html`, `comments.html` and `layouts/shortcodes/` — they are re-wired, not replaced.

- [ ] **Step 2: Rewrite `hugo.toml`**

Replace the whole file:

```toml
baseURL = "https://barrosef.com/"
title = "Ed Barros"
defaultContentLanguage = "en"
defaultContentLanguageInSubdir = false
enableRobotsTXT = true

[pagination]
  pagerSize = 20

[taxonomies]
  category = "categories"
  tag = "tags"

[markup]
  [markup.highlight]
    noClasses = false
    lineNos = false
  [markup.goldmark.renderer]
    unsafe = true

[outputs]
  home = ["HTML", "RSS"]

[params]
  description = "Technology leadership — writing on engineering, systems and liberty."
  comments = true

  # Owner's professional facts. EVERY homepage block that uses these renders
  # only when its value is non-empty, so blanks are invisible, never brackets.
  [params.profile]
    positioning = ""      # hero headline; falls back to the default in home.html
    summary = ""          # one sentence under the headline
    currentRole = ""
    company = ""
    location = ""
    priorRoles = ""
    email = ""
    linkedin = "https://www.linkedin.com/in/barrosef/"

  # Track record. Empty list hides the whole band.
  # [[params.profile.metrics]]
  #   value = "12"
  #   label = "years leading engineering teams"

  [params.analytics]
    ga4 = ""

  [params.newsletter]
    kitFormId = ""

  [params.giscus]
    repo = ""
    repoId = ""
    category = ""
    categoryId = ""

  [[params.socialIcons]]
    name = "linkedin"
    url = "https://www.linkedin.com/in/barrosef/"
  [[params.socialIcons]]
    name = "github"
    url = "https://github.com/barrosef"
  [[params.socialIcons]]
    name = "x"
    url = "https://x.com/barrosef2"
  [[params.socialIcons]]
    name = "instagram"
    url = "https://www.instagram.com/barrosef/"
  [[params.socialIcons]]
    name = "tiktok"
    url = "https://www.tiktok.com/@barrosef"
  [[params.socialIcons]]
    name = "facebook"
    url = "https://www.facebook.com/ed.barros.9231"

[languages]
  [languages.en]
    languageName = "English"
    languageCode = "en-us"
    contentDir = "content/en"
    weight = 1
    [[languages.en.menus.main]]
      name = "Writing"
      url = "/writing/"
      weight = 10
    [[languages.en.menus.main]]
      name = "About"
      url = "/about/"
      weight = 20
    [[languages.en.menus.main]]
      name = "Contact"
      url = "/contact/"
      weight = 30

  [languages.pt]
    languageName = "Português"
    languageCode = "pt-br"
    contentDir = "content/pt"
    weight = 2
    [[languages.pt.menus.main]]
      name = "Artigos"
      url = "/pt/artigos/"
      weight = 10
    [[languages.pt.menus.main]]
      name = "Sobre"
      url = "/pt/sobre/"
      weight = 20
    [[languages.pt.menus.main]]
      name = "Contato"
      url = "/pt/contato/"
      weight = 30
```

- [ ] **Step 3: Move posts to `/writing/` and add the section index pages**

```bash
mkdir -p content/en/writing content/pt/artigos
git mv content/en/posts/hello-world.md content/en/writing/hello-world.md
git mv content/pt/posts/hello-world.md content/pt/artigos/hello-world.md
rmdir content/en/posts content/pt/posts 2>/dev/null || true
```

`content/en/writing/_index.md`:

```markdown
---
title: "Writing"
translationKey: "writing-index"
description: "Essays on engineering leadership, systems, and liberty."
---
```

`content/pt/artigos/_index.md`:

```markdown
---
title: "Artigos"
translationKey: "writing-index"
description: "Ensaios sobre liderança em engenharia, sistemas e liberdade."
---
```

**Note for the implementer:** `scripts/check_translations.py` globs `content/<lang>/posts/*.md`. It must be updated in Task 4 to look at the new directories; until then it reports zero pairs, which passes. Do not "fix" it here.

- [ ] **Step 4: Write the document shell**

`layouts/baseof.html`:

```html
<!DOCTYPE html>
<html lang="{{ .Site.Language.LanguageCode | default .Site.Language.Lang }}">
<head>
  {{ partial "head.html" . }}
</head>
<body>
  {{ partial "header.html" . }}
  <main id="main">
    {{ block "main" . }}{{ end }}
  </main>
  {{ partial "footer.html" . }}
  {{ partial "extend_footer.html" . }}
</body>
</html>
```

`layouts/_partials/head.html`:

```html
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{{ if .IsHome }}{{ .Site.Title }}{{ else }}{{ .Title }} · {{ .Site.Title }}{{ end }}</title>
<meta name="description" content="{{ with .Description }}{{ . }}{{ else }}{{ .Site.Params.description }}{{ end }}">
<link rel="canonical" href="{{ .Permalink }}">

<link rel="preload" href="/fonts/ibmplexsans-400.woff2" as="font" type="font/woff2" crossorigin>

{{ $css := resources.Get "css/main.css" | resources.Minify | resources.Fingerprint }}
<link rel="stylesheet" href="{{ $css.RelPermalink }}" integrity="{{ $css.Data.Integrity }}">

<meta property="og:type" content="{{ if .IsPage }}article{{ else }}website{{ end }}">
<meta property="og:title" content="{{ if .IsHome }}{{ .Site.Title }}{{ else }}{{ .Title }}{{ end }}">
<meta property="og:description" content="{{ with .Description }}{{ . }}{{ else }}{{ .Site.Params.description }}{{ end }}">
<meta property="og:url" content="{{ .Permalink }}">
<meta property="og:image" content="{{ "og-default.png" | absURL }}">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:image" content="{{ "og-default.png" | absURL }}">

<link rel="icon" href="/favicon.ico">
<link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">
<link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png">
<link rel="apple-touch-icon" href="/apple-touch-icon.png">
<meta name="theme-color" content="#0b1622">

{{ range .AlternativeOutputFormats -}}
<link rel="{{ .Rel }}" type="{{ .MediaType.Type }}" href="{{ .Permalink }}">
{{ end -}}
{{ range .AllTranslations -}}
<link rel="alternate" hreflang="{{ .Language.LanguageCode }}" href="{{ .Permalink }}">
{{ end -}}

{{ partial "extend_head.html" . }}
```

`layouts/_partials/header.html`:

```html
<header class="site-header">
  <div class="wrap header-inner">
    <a class="wordmark" href="{{ "" | absLangURL }}">{{ .Site.Title }}</a>
    <nav class="site-nav">
      {{ range .Site.Menus.main }}<a href="{{ .URL | absURL }}">{{ .Name }}</a>{{ end }}
      {{ partial "lang-switch.html" . }}
    </nav>
  </div>
</header>
```

`layouts/_partials/lang-switch.html`:

```html
<span class="lang-switch">
  {{- range .Site.Languages }}
  {{- if eq . $.Site.Language }}<span class="lang-on">{{ .Lang | upper }}</span>
  {{- else }}{{ with $.Site.GetPage "/" }}{{ end }}<a href="{{ if eq .Lang "en" }}/{{ else }}/{{ .Lang }}/{{ end }}">{{ .Lang | upper }}</a>
  {{- end }}
  {{- end }}
</span>
```

`layouts/_partials/footer.html`:

```html
<footer class="site-footer">
  <div class="wrap footer-inner">
    <div>
      <div class="footer-name">{{ .Site.Title }}</div>
      {{ with .Site.Params.profile.email }}<a class="footer-email" href="mailto:{{ . }}">{{ . }}</a>{{ end }}
    </div>
    {{ partial "social-icons.html" . }}
  </div>
</footer>
```

- [ ] **Step 5: Minimal templates so every page type builds**

Write `layouts/home.html`, `layouts/list.html`, `layouts/single.html`, `layouts/page.html`, `layouts/404.html` as thin placeholders that each define `{{ define "main" }}` and render the page title and content. Tasks 3–5 replace their bodies. `layouts/404.html` keeps both languages (English then Portuguese) since GitHub Pages serves one file.

- [ ] **Step 6: Stylesheet skeleton with the tokens**

`assets/css/main.css` — tokens plus a reset. Components arrive in later tasks.

```css
:root {
  --ground: #0b1622;
  --panel: #111f30;
  --border: #1b2b3d;
  --text: #dce6f2;
  --muted: #9db3cc;
  --dim: #5d7086;
  --accent: #5b8fd6;
  --surface: #ffffff;
  --text-dark: #16233a;
  --muted-dark: #5d6b7d;
  --link-dark: #1d4e89;
  --wrap: 1120px;
  --reading: 680px;
  --font-sans: "IBM Plex Sans", system-ui, -apple-system, "Segoe UI", sans-serif;
  --font-mono: "IBM Plex Mono", ui-monospace, SFMono-Regular, Menlo, monospace;
}

*, *::before, *::after { box-sizing: border-box; }
html { -webkit-text-size-adjust: 100%; }
body {
  margin: 0;
  background: var(--ground);
  color: var(--text);
  font-family: var(--font-sans);
  font-size: 17px;
  line-height: 1.65;
}
img { max-width: 100%; height: auto; }
a { color: var(--accent); text-decoration: none; }
a:hover { text-decoration: underline; }
.wrap { max-width: var(--wrap); margin: 0 auto; padding: 0 32px; }
```

- [ ] **Step 7: Verify the site builds without a theme**

```bash
hugo --minify --gc
test -f public/index.html && test -f public/pt/index.html && echo BUILD-OK
test -f public/writing/hello-world/index.html && echo EN-POST-OK
test -f public/pt/artigos/hello-world/index.html && echo PT-POST-OK
test -f public/writing/index.html && echo EN-INDEX-OK
! grep -rq 'PaperMod' public/ && echo NO-THEME-OK
```

Expected: all five markers. If Hugo complains about a missing layout, add the thin template rather than reinstating a theme.

- [ ] **Step 8: Commit**

```bash
git add -A
git commit -m "feat(site): remove PaperMod and the notebook identity, add own template skeleton"
```

---

### Task 2: Self-hosted IBM Plex and the type system

**Files:**
- Create: `static/fonts/ibmplexsans-{400,500,600}.woff2`, `static/fonts/ibmplexmono-{400,500}.woff2`, `static/fonts/OFL.txt`
- Modify: `assets/css/main.css`

**Interfaces:**
- Consumes: `--font-sans`, `--font-mono` from Task 1.
- Produces: loaded webfonts and the type scale every later task uses.

- [ ] **Step 1: Fetch the fonts**

IBM Plex is SIL OFL. Download once and commit — never link to Google at runtime.

```bash
mkdir -p static/fonts
UA='Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120 Safari/537.36'
curl -sH "User-Agent: $UA" 'https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@400;500;600&family=IBM+Plex+Mono:wght@400;500&display=swap&subset=latin,latin-ext' -o /tmp/plex.css
grep -o 'https://fonts.gstatic.com[^)]*\.woff2' /tmp/plex.css | sort -u
```

Download each URL to the filenames above. Keep only the `latin` and `latin-ext` ranges — together they cover Portuguese. Fetch the license text from the IBM Plex repository (`https://raw.githubusercontent.com/IBM/plex/master/LICENSE.txt`) and save it as `static/fonts/OFL.txt`; if that path 404s, locate the OFL text in the repo and save that.

- [ ] **Step 2: Verify Portuguese coverage — blocking**

```bash
python3 - <<'PY'
import glob, sys
try:
    from fontTools.ttLib import TTFont
except ImportError:
    sys.exit("fonttools missing — run: pip install --user fonttools brotli")
need = "ãõçáéíóúâêôàÃÕÇÁÉÍÓÚÂÊÔÀ"
bad = 0
for f in sorted(glob.glob("static/fonts/*.woff2")):
    cmap = {chr(c) for c in TTFont(f, fontNumber=0).getBestCmap()}
    missing = [c for c in need if c not in cmap]
    print(("FAIL " if missing else "ok   ") + f + (f"  missing: {''.join(missing)}" if missing else ""))
    bad += bool(missing)
raise SystemExit(1 if bad else 0)
PY
du -ch static/fonts/*.woff2 | tail -1
```

Expected: exit 0 and total **≤140KB**. If glyphs are missing, re-fetch including `latin-ext`.

- [ ] **Step 3: Add `@font-face` and the type scale to `main.css`**

```css
@font-face { font-family: "IBM Plex Sans"; font-style: normal; font-weight: 400; font-display: swap; src: url("/fonts/ibmplexsans-400.woff2") format("woff2"); }
@font-face { font-family: "IBM Plex Sans"; font-style: normal; font-weight: 500; font-display: swap; src: url("/fonts/ibmplexsans-500.woff2") format("woff2"); }
@font-face { font-family: "IBM Plex Sans"; font-style: normal; font-weight: 600; font-display: swap; src: url("/fonts/ibmplexsans-600.woff2") format("woff2"); }
@font-face { font-family: "IBM Plex Mono"; font-style: normal; font-weight: 400; font-display: swap; src: url("/fonts/ibmplexmono-400.woff2") format("woff2"); }
@font-face { font-family: "IBM Plex Mono"; font-style: normal; font-weight: 500; font-display: swap; src: url("/fonts/ibmplexmono-500.woff2") format("woff2"); }

h1, h2, h3, h4 { font-weight: 600; line-height: 1.15; letter-spacing: -0.02em; margin: 0 0 16px 0; }
h1 { font-size: 46px; }
h2 { font-size: 28px; letter-spacing: -0.015em; }
h3 { font-size: 20px; letter-spacing: -0.01em; }
p { margin: 0 0 18px 0; }

.eyebrow {
  font-family: var(--font-mono);
  font-size: 12px;
  font-weight: 500;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  color: var(--accent);
}
.lede { font-size: 20px; line-height: 1.6; color: var(--muted); }
```

- [ ] **Step 4: Verify the fonts load locally with no third-party request**

```bash
hugo --minify --gc
ls public/fonts/
! grep -rq 'fonts.googleapis.com\|fonts.gstatic.com' public/ && echo NO-THIRD-PARTY-OK
grep -o 'IBM Plex Sans' public/assets/css/*.css | head -1
```

Expected: the woff2 files listed under `public/fonts/` (an empty listing is a hard failure — a 404 font falls back silently and the design collapses), `NO-THIRD-PARTY-OK`, and the family present in the built CSS.

- [ ] **Step 5: Commit**

```bash
git add static/fonts assets/css/main.css
git commit -m "feat(site): self-hosted IBM Plex Sans and Mono with the type scale"
```

---

### Task 3: The authority homepage

**Files:**
- Modify: `layouts/home.html`, `assets/css/main.css`

**Interfaces:**
- Consumes: `params.profile.*` and `params.profile.metrics` from Task 1; tokens and type scale from Tasks 1–2.
- Produces: the homepage. **Every fact-dependent block is wrapped in a conditional** — with an empty profile the page must render cleanly with those blocks absent, never a bracket, an empty panel, or an orphaned heading.

- [ ] **Step 1: Write `layouts/home.html`**

```html
{{ define "main" }}
{{ $p := .Site.Params.profile }}

<section class="hero wrap">
  <div class="eyebrow">{{ i18n "kicker" }}</div>
  <h1 class="hero-title">{{ with $p.positioning }}{{ . }}{{ else }}{{ i18n "heroDefault" }}{{ end }}</h1>
  {{ with $p.summary }}<p class="lede hero-lede">{{ . }}</p>{{ end }}
  {{ if or $p.currentRole $p.priorRoles }}
  <p class="hero-role">
    {{- with $p.currentRole }}{{ . }}{{ with $p.company }} · {{ . }}{{ end }}{{ with $p.location }} · {{ . }}{{ end }}{{ end -}}
    {{- with $p.priorRoles }}<span class="hero-prior">{{ i18n "previously" }} {{ . }}</span>{{ end -}}
  </p>
  {{ end }}
  <div class="hero-actions">
    <a class="btn btn-primary" href="{{ "contact/" | absLangURL }}">{{ i18n "getInTouch" }}</a>
    {{ with $p.linkedin }}<a class="btn btn-ghost" href="{{ . }}">LinkedIn</a>{{ end }}
  </div>
</section>

{{ with $p.metrics }}
<section class="metrics">
  <div class="wrap metrics-grid">
    {{ range . }}
    <div class="metric">
      <div class="metric-value">{{ .value }}</div>
      <div class="metric-label">{{ .label }}</div>
    </div>
    {{ end }}
  </div>
</section>
{{ end }}

<section class="practice wrap">
  <div class="eyebrow">{{ i18n "capabilities" }}</div>
  <div class="practice-grid">
    {{ range .Site.Data.practice.items }}
    <article class="practice-card">
      <h3>{{ index . (printf "title_%s" $.Site.Language.Lang) }}</h3>
      <p>{{ index . (printf "body_%s" $.Site.Language.Lang) }}</p>
    </article>
    {{ end }}
  </div>
</section>

<section class="featured">
  <div class="wrap">
    <div class="featured-head">
      <div class="eyebrow eyebrow-dark">{{ i18n "writing" }}</div>
      <a class="featured-all" href="{{ (index .Site.Menus.main 0).URL | absURL }}">{{ i18n "allWriting" }} →</a>
    </div>
    <div class="featured-grid">
      {{ range first 3 (where .Site.RegularPages "Section" "in" (slice "writing" "artigos")) }}
      {{ partial "post-card.html" . }}
      {{ end }}
    </div>
  </div>
</section>

<section class="wrap personal-note">
  <p>{{ i18n "personalNote" }} <a href="{{ "about/" | absLangURL }}">{{ i18n "moreAboutThat" }}</a>.</p>
</section>
{{ end }}
```

- [ ] **Step 2: Add the practice-area data file**

`data/practice.yaml` — content, not invented biography:

```yaml
items:
  - title_en: "Engineering leadership"
    body_en: "Hiring, structure, and the operating cadence that makes delivery predictable instead of heroic."
    title_pt: "Liderança em engenharia"
    body_pt: "Contratação, estrutura e a cadência operacional que torna a entrega previsível em vez de heroica."
  - title_en: "Platform & architecture"
    body_en: "Systems designed for the load they will actually carry, with the trade-offs written down rather than assumed."
    title_pt: "Plataforma e arquitetura"
    body_pt: "Sistemas projetados para a carga real, com os trade-offs documentados em vez de presumidos."
  - title_en: "Technology strategy"
    body_en: "Turning business constraints into direction a board can follow and a team can execute."
    title_pt: "Estratégia de tecnologia"
    body_pt: "Traduzir restrições de negócio em direção que o conselho acompanha e o time executa."
```

- [ ] **Step 3: Add the i18n strings**

Extend `i18n/en.toml` and `i18n/pt.toml` with every key used above — `kicker`, `heroDefault`, `previously`, `getInTouch`, `capabilities`, `writing`, `allWriting`, `personalNote`, `moreAboutThat` — plus the existing consent and newsletter keys. English `heroDefault`: "I build engineering organisations that ship." Portuguese: "Construo organizações de engenharia que entregam." Both files must define the identical key set.

- [ ] **Step 4: Write `layouts/_partials/post-card.html`**

```html
<article class="post-card">
  <div class="post-card-cat">{{ with (index (.GetTerms "categories") 0) }}{{ .LinkTitle }}{{ end }}</div>
  <h3 class="post-card-title"><a href="{{ .RelPermalink }}">{{ .Title }}</a></h3>
  {{ with .Description }}<p class="post-card-desc">{{ . }}</p>{{ end }}
</article>
```

- [ ] **Step 5: Style the homepage**

Add to `main.css`: `.hero` (104px top padding, 58px title at desktop, max 20ch), `.hero-actions` (flex, 14px gap), `.btn` (no radius; `.btn-primary` accent background with `#08121d` text; `.btn-ghost` 1px `--border`), `.metrics` (grid of four, vertical hairline dividers, values in mono at 30px), `.practice-grid` (three columns, `--panel` background, 2px `--accent` top border, 32px padding), `.featured` (white surface, `--text-dark` text, three-column grid, `.eyebrow-dark` uses `--link-dark`), `.personal-note` (muted, hairline above). All grids `repeat(N, minmax(0, 1fr))` with `gap`. Responsive: below 900px the metric and practice grids collapse to one column; hero title drops to 38px.

- [ ] **Step 6: Verify both profile states — this is the point of the task**

```bash
hugo --minify --gc
grep -c 'metric-value' public/index.html   # expect 0 — metrics are commented out in hugo.toml
grep -o '\[YOUR\|\[N\]\|\[COMPANY' public/index.html | head -1   # expect NO output
grep -c 'practice-card' public/index.html  # expect 3
grep -c 'hero-title' public/index.html public/pt/index.html

printf '\n[[params.profile.metrics]]\n  value = "12"\n  label = "years leading engineering teams"\n' > /tmp/profile-test.toml
hugo --minify --gc --config hugo.toml,/tmp/profile-test.toml
grep -c 'metric-value' public/index.html   # expect 1
hugo --minify --gc
```

Expected: with the profile empty, **no bracket text and no empty metrics band**, three practice cards, a hero on both languages; with a metric configured, the band appears. Paste all output.

- [ ] **Step 7: Commit**

```bash
git add layouts data i18n assets/css/main.css
git commit -m "feat(site): authority homepage with config-gated fact blocks"
```

---

### Task 4: Writing index, post pages, and the checker

**Files:**
- Modify: `layouts/list.html`, `layouts/single.html`, `layouts/taxonomy.html`, `layouts/terms.html`, `assets/css/main.css`, `scripts/check_translations.py`, `tests/check_translations_test.sh`

**Interfaces:**
- Consumes: `post-card.html`, tokens, type scale.
- Produces: `/writing/` grouped by pillar; readable post pages; a checker that looks at the new directories.

- [ ] **Step 1: Update the translation checker for the new paths**

In `scripts/check_translations.py`, `collect_keys` currently reads `content_dir / lang / "posts"`. Change it to accept the per-language section name: English posts live in `content/en/writing`, Portuguese in `content/pt/artigos`. Implement as a mapping inside the function:

```python
SECTION = {"en": "writing", "pt": "artigos"}
```

and use `content_dir / lang / SECTION[lang]`. Update `tests/check_translations_test.sh` fixtures to create `en/writing` and `pt/artigos` instead of `en/posts` and `pt/posts`. All six cases must still pass, and the live check must report one pair.

- [ ] **Step 2: Write `layouts/list.html` — grouped by pillar**

The index renders three groups in order: Technology, Liberty, then a subordinate Personal group holding Barbecue and Jiu-Jitsu. Match on the language-appropriate category names — EN `Technology`/`Liberty`/`Barbecue`/`Jiu-Jitsu`, PT `Tecnologia`/`Liberdade`/`Churrasco`/`Jiu-Jitsu`. Any post whose category matches none of these falls into a final "Other" group so nothing is silently dropped. Each group renders a heading and its entries via `post-card.html`; a group with no posts renders nothing.

- [ ] **Step 3: Write `layouts/single.html`**

White reading surface, single column at `--reading` width, title, category and date in mono eyebrow, then `.Content`. Retain the existing post-footer partials by including `newsletter-form.html` and `comments.html` after the content, gated as they are today (`comments` param, non-empty giscus repo, non-empty Kit id).

- [ ] **Step 4: Write `layouts/page.html`, `taxonomy.html`, `terms.html`**

`page.html`: same reading surface as `single.html`, no date or category. `taxonomy.html` and `terms.html`: simple lists on the ground colour.

- [ ] **Step 5: Verify**

```bash
make test
hugo --minify --gc
python3 scripts/check_translations.py content
test -f public/writing/index.html && test -f public/pt/artigos/index.html && echo INDEX-OK
grep -c 'post-card' public/writing/index.html
grep -o 'reading' public/writing/hello-world/index.html | head -1
grep -c 'hreflang' public/writing/hello-world/index.html
```

Expected: 6/6 tests, checker reports 1 pair, both indexes exist, the post renders, hreflang present.

- [ ] **Step 6: Commit**

```bash
git add layouts scripts tests assets/css/main.css
git commit -m "feat(site): writing index grouped by pillar, post and page templates"
```

---

### Task 5: About, Contact, and the retained partials

**Files:**
- Modify: `content/en/about.md`, `content/pt/sobre.md`
- Create: `content/en/contact.md`, `content/pt/contato.md`
- Modify: `layouts/_partials/newsletter-form.html`, `comments.html`, `extend_footer.html` (restyle only), `assets/css/main.css`
- Create: `layouts/_partials/social-icons.html`

**Interfaces:**
- Consumes: `params.profile.email`, `params.socialIcons`.

- [ ] **Step 1: Write the social icons partial**

Inline stroke SVGs on a 20px grid for linkedin, github, x, instagram, tiktok, facebook, keyed off `.Site.Params.socialIcons` `name`. `currentColor` fill/stroke so they inherit. No emoji, no icon font, no third-party request. An unknown name renders nothing rather than a broken glyph.

- [ ] **Step 2: Write Contact in both languages**

`content/en/contact.md` (`translationKey: "contact"`, `url: "/contact/"`): a short professional paragraph, then the email and LinkedIn rendered from config by the template — no hardcoded address in content. `content/pt/contato.md` mirrors it with `url: "/contato/"` (Hugo prefixes `/pt/` automatically for the non-default language — verify the built path is `public/pt/contato/index.html`).

- [ ] **Step 3: Rewrite About in both languages**

Professional register, three short paragraphs: what he does; how he works; a closing line acknowledging barbecue, jiu-jitsu and liberty as the things outside work. **Assert no biographical fact not already in `params.profile`** — no invented employers, dates, or scale. Keep `translationKey: "about"`; keep `url: "/sobre/"` off the PT file (the filename yields the right path).

- [ ] **Step 4: Restyle the retained partials**

Update the inline styles in `newsletter-form.html`, `comments.html` and `extend_footer.html` to the new palette — panel background, hairline border, no radius. Keep every param gate exactly as it is; these partials must still render nothing when their config is empty.

- [ ] **Step 5: Verify**

```bash
hugo --minify --gc
for f in about contact writing pt/sobre pt/contato pt/artigos; do test -f "public/$f/index.html" && echo "ok   $f" || echo "MISS $f"; done
! grep -q 'giscus\|kit.com\|googletagmanager' public/writing/hello-world/index.html && echo GATES-CLOSED-OK
grep -c 'svg' public/index.html
make check
```

Expected: all six pages, `GATES-CLOSED-OK` (all integrations still off by default), social SVGs present, `make check` green.

- [ ] **Step 6: Commit**

```bash
git add content layouts assets/css/main.css
git commit -m "feat(site): about and contact pages, social icons, restyled partials"
```

---

### Task 6: Identity assets in the new palette

**Files:**
- Create: `static/favicon.ico`, `static/favicon-16x16.png`, `static/favicon-32x32.png`, `static/apple-touch-icon.png`, `static/og-default.png`

**Interfaces:**
- Consumes: the palette. Replaces the deleted saddle-brown monogram set.

- [ ] **Step 1: Build the monogram**

Navy ground `#0b1622`, letters `#dce6f2`, an accent `#5b8fd6` rule — "EB" set in IBM Plex Sans SemiBold. Convert the committed woff2 to TTF with fontTools and install it via fontconfig so the rasteriser uses the real face rather than a substitute; remove that scaffolding afterwards so nothing stray is committed.

- [ ] **Step 2: Rasterise the icons**

Probe for `rsvg-convert`, `inkscape`, then ImageMagick `magick`; report which you used. Produce 16×16, 32×32, 180×180 and a multi-size `favicon.ico` (16/32/48). No `safari-pinned-tab.svg` this time — the head partial no longer references it, so do not create one.

- [ ] **Step 3: Build the social card**

1200×630: navy ground, "Ed Barros" in IBM Plex SemiBold, a one-line descriptor beneath in mono, an accent rule. Keep the text inside the canvas — the previous card clipped its last word; measure before rasterising.

- [ ] **Step 4: Verify**

```bash
hugo --minify --gc
for f in favicon.ico favicon-16x16.png favicon-32x32.png apple-touch-icon.png og-default.png; do test -f "public/$f" && echo "ok   $f" || echo "MISS $f"; done
python3 -c "from PIL import Image; im=Image.open('static/og-default.png'); print('og size', im.size)"
```

Expected: five `ok` lines and `og size (1200, 630)`.

- [ ] **Step 5: Commit**

```bash
git add static
git commit -m "feat(site): navy monogram favicons and social card"
```

---

### Task 7: Verify and ship

**Files:** none — the release gate.

- [ ] **Step 1: Full local verification**

```bash
make test
make check
! grep -rq 'fonts.googleapis.com\|fonts.gstatic.com' public/ && echo NO-THIRD-PARTY-OK
! grep -rq 'PaperMod' public/ && echo NO-THEME-OK
du -ch static/fonts/*.woff2 | tail -1
grep -o '\[YOUR\|\[COMPANY\|\[N\]\|\[EMAIL' -r public/ | head -1   # expect NO output
```

- [ ] **Step 2: Contrast audit — blocking**

Check every pair used: text/muted/dim/accent on ground and on panel; text-dark/muted-dark/link-dark on white; and the primary button's `#08121d` on `--accent`. Body pairs need 4.5:1, large text and UI 3:1. Fix any failure by adjusting the token, then re-run and update the spec's palette table.

- [ ] **Step 3: Rendered verification**

Reading the CSS is not sufficient — both critical bugs in the previous identity were invisible to source reading. Render the built site (headless browser if available, otherwise `hugo server` plus a page fetch) and confirm: the ground is navy `#0b1622` and not a fallback; body text renders in IBM Plex and not a system fallback; the writing section is a genuine white surface; a code fence renders with Chroma classes and legible contrast, not inline Monokai; and layout holds at 1280px, 800px and 375px in both languages.

- [ ] **Step 4: Merge, push, deploy**

```bash
git checkout main
git merge <feature-branch> --no-ff
make test && make check
git push origin main
gh run watch --repo barrosef/barrosef.com --exit-status $(gh run list --repo barrosef/barrosef.com --branch main --limit 1 --json databaseId -q '.[0].databaseId')
```

The external link check is warn-only by design; the internal check and the deploy must both be green.

- [ ] **Step 5: Live smoke test**

```bash
for u in "" "pt/" "writing/" "pt/artigos/" "writing/hello-world/" "about/" "pt/sobre/" "contact/" "pt/contato/" "404.html" "favicon-32x32.png" "og-default.png" "fonts/ibmplexsans-400.woff2"; do
  printf "%-28s %s\n" "/$u" "$(curl -s -o /dev/null -w '%{http_code}' --max-time 20 "https://barrosef.com/$u")"
done
curl -s https://barrosef.com/ | grep -c 'gstatic\|googleapis'   # expect 0
```

Expected: 200 everywhere, 0 third-party font references.

- [ ] **Step 6: Bump the workspace submodule pointer**

```bash
cd /opt/wks/personal/barrosef-workspace
git add barrosef.com
git commit -m "chore: bump barrosef.com submodule — professional site live"
git push origin main
```

---

## Deferred (not part of this plan)

1. The owner's real facts — filling `params.profile` and its `metrics` list.
2. Consent-revisit UI, required before any GA4 measurement ID is set.
3. Giscus configuration (`barrosef/barrosef.com`, once Discussions is enabled).
4. The lychee `--remap` internal-link coverage upgrade; Node 20 action version bumps.
5. `www` certificate and the three missing apex A records — DNS-side, tracked separately.
