# barrosef.com Visual Identity Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace stock PaperMod styling with the approved personal identity — notebook palette, margin rail, lamplight dark mode, EB Garamond with real OpenType features — and ship it live.

**Architecture:** Pure layering. All styling lives in `assets/css/extended/*.css`, which PaperMod concatenates *after* its own core CSS (`layouts/_partials/head.html:59`), so tokens override cleanly without `!important`. Exactly one template override (`layouts/single.html`) restructures post pages into the rail grid. Fonts are self-hosted from `assets/fonts/`. `themes/` is never edited.

**Tech Stack:** Hugo extended 0.148.2, PaperMod (submodule), EB Garamond (SIL OFL), plain CSS with custom properties.

**Spec:** `docs/superpowers/specs/2026-08-19-barrosef-com-visual-identity-design.md` — read it before Task 1.

## Global Constraints

- **Never edit anything under `themes/`.** All work happens in `assets/`, `layouts/`, `static/`, `hugo.toml`.
- Extended CSS files are concatenated in **glob-sorted order**, so the `01-`…`04-` prefixes are load-bearing. Keep them.
- **No third-party requests.** The built HTML must never reference `fonts.googleapis.com` or `fonts.gstatic.com`. Fonts are downloaded once at build-authoring time and committed to `assets/fonts/`.
- **Palette (day):** paper `#f4ece0`, surface `#faf5ec`, ink `#2f2a24`, muted `#6b6157`, rule `#ddd0bd`, accent `#6d3f1d`, code surface `#ece0cd`.
- **Palette (lamplight):** walnut `#1c1714`, surface `#241d19`, cream `#e8ddcb`, muted `#a2957f`, rule `#3a2f27`, amber `#c98a4b`, code surface `#141110`.
- **Geometry:** prose column `660px`, rail `180px`, rail gap `40px`, container `880px`, **`--radius: 0` everywhere** — no rounded corners, no shadows, no cards.
- Body text **20px / 1.65**. Dark mode bumps body to weight 500 and `+0.01em` tracking.
- **No per-pillar colors or icons.** One accent only.
- Every commit leaves `make check` passing.
- Work in the repo root: `/opt/wks/personal/barrosef-workspace/barrosef.com`.

## File Structure

| Path | Responsibility |
|---|---|
| `assets/css/extended/01-tokens.css` | Palette for both modes, mapped onto PaperMod's variables; geometry |
| `assets/css/extended/02-typography.css` | `@font-face`, type scale, OpenType features, dark-mode weight compensation |
| `assets/css/extended/03-layout.css` | Rail grid, breakpoints, sticky ToC, persistent asymmetry on non-post pages |
| `assets/css/extended/04-components.css` | Flattened list, header logotype, quotes, code/Chroma, images, taxonomy, search, 404, post-footer |
| `static/fonts/*.woff2` | Self-hosted EB Garamond subset (published to `/fonts/`) |
| `layouts/single.html` | The one template override: rail + prose structure |
| `static/favicon*`, `static/apple-touch-icon.png`, `static/safari-pinned-tab.svg` | The five icons PaperMod references |
| `static/og-default.png` | 1200×630 social card |
| `hugo.toml` | `assets.theme_color`, ToC on |

---

### Task 1: Design tokens and palette

**Files:**
- Create: `assets/css/extended/01-tokens.css`
- Modify: `hugo.toml` (add `assets.theme_color` / `assets.msapplication_TileColor` under `[params]`)

**Interfaces:**
- Produces: every custom property later tasks consume — `--paper --surface --ink --muted --rule --accent --code-surface --rail-width --rail-gap --prose-width`, plus PaperMod's own `--theme --entry --primary --secondary --tertiary --content --border --code-bg --code-block-bg --radius --main-width --nav-width`.

- [ ] **Step 1: Write the token file**

`assets/css/extended/01-tokens.css`:

```css
/* Design tokens. Loaded after PaperMod core, so these win.
   Dark mode is declared twice on purpose: PaperMod's inline script sets
   data-theme, but a no-JS reader must still get lamplight from the media query. */

:root {
  --paper: #f4ece0;
  --surface: #faf5ec;
  --ink: #2f2a24;
  --muted: #6b6157;
  --rule: #ddd0bd;
  --accent: #6d3f1d;
  --code-surface: #ece0cd;

  --prose-width: 660px;
  --rail-width: 180px;
  --rail-gap: 40px;

  --theme: var(--paper);
  --entry: var(--surface);
  --primary: var(--ink);
  --secondary: var(--muted);
  --tertiary: var(--rule);
  --content: var(--ink);
  --border: var(--rule);
  --code-bg: var(--code-surface);
  --code-block-bg: var(--code-surface);

  --radius: 0;
  --main-width: 880px;
  --nav-width: 880px;
  color-scheme: light;
}

@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) {
    --paper: #1c1714;
    --surface: #241d19;
    --ink: #e8ddcb;
    --muted: #a2957f;
    --rule: #3a2f27;
    --accent: #c98a4b;
    --code-surface: #141110;
    color-scheme: dark;
  }
}

:root[data-theme="dark"] {
  --paper: #1c1714;
  --surface: #241d19;
  --ink: #e8ddcb;
  --muted: #a2957f;
  --rule: #3a2f27;
  --accent: #c98a4b;
  --code-surface: #141110;
  color-scheme: dark;
}

body {
  background: var(--theme);
  color: var(--content);
}

a { color: var(--accent); }
```

- [ ] **Step 2: Add the theme-color params**

In `hugo.toml`, inside the existing `[params]` block (alongside `defaultTheme`), add:

```toml
  [params.assets]
    theme_color = "#f4ece0"
    msapplication_TileColor = "#f4ece0"
```

- [ ] **Step 3: Verify the palette reaches the built CSS**

```bash
hugo --minify --gc
grep -o '\--paper:#f4ece0' public/assets/css/stylesheet.*.css | head -1
grep -o '\--radius:0' public/assets/css/stylesheet.*.css | head -1
grep -c 'theme-color" content="#f4ece0"' public/index.html
```

Expected: one match for each grep, and `1` for the theme-color count. If the stylesheet filename differs, list `public/assets/css/` to find it.

- [ ] **Step 4: Verify contrast meets WCAG AA**

Run this checker (stdlib only) and require every pair to pass:

```bash
python3 - <<'PY'
def lin(c):
    c/=255
    return c/12.92 if c<=.03928 else ((c+.055)/1.055)**2.4
def lum(h):
    h=h.lstrip('#'); r,g,b=(int(h[i:i+2],16) for i in (0,2,4))
    return .2126*lin(r)+.7152*lin(g)+.0722*lin(b)
def ratio(a,b):
    la,lb=lum(a),lum(b); la,lb=max(la,lb),min(la,lb)
    return (la+.05)/(lb+.05)
pairs=[("day body","#2f2a24","#f4ece0",4.5),("day muted","#6b6157","#f4ece0",4.5),
       ("day link","#6d3f1d","#f4ece0",4.5),("day rule","#ddd0bd","#f4ece0",1.0),
       ("night body","#e8ddcb","#1c1714",4.5),("night muted","#a2957f","#1c1714",4.5),
       ("night link","#c98a4b","#1c1714",4.5)]
bad=0
for name,fg,bg,need in pairs:
    r=ratio(fg,bg); ok=r>=need
    print(f"{'ok ' if ok else 'FAIL'} {name}: {r:.2f} (need {need})")
    bad+=not ok
raise SystemExit(1 if bad else 0)
PY
```

Expected: exit 0, every line `ok`. **If any pair fails, darken (day) or lighten (night) that token until it passes, update `01-tokens.css` and the Global Constraints values, and re-run.** Do not proceed with a failing pair.

- [ ] **Step 5: Commit**

```bash
git add assets/css/extended/01-tokens.css hugo.toml
git commit -m "feat(identity): notebook palette tokens for day and lamplight modes"
```

---

### Task 2: Self-hosted EB Garamond and the type system

**Files:**
- Create: `static/fonts/*.woff2` (published to `/fonts/`, which is what the `@font-face` `src` resolves against)
- Create: `assets/css/extended/02-typography.css`

**Interfaces:**
- Consumes: tokens from Task 1.
- Produces: `--font-serif` custom property; a `.smallcaps` utility class used by Tasks 3 and 4 for rail and nav text.

- [ ] **Step 1: Obtain the fonts**

EB Garamond is SIL OFL, so redistribution is fine. Fetch the woff2 files and commit them — **never link to Google at runtime.**

```bash
mkdir -p static/fonts
UA='Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120 Safari/537.36'
curl -sH "User-Agent: $UA" \
  'https://fonts.googleapis.com/css2?family=EB+Garamond:ital,wght@0,400;0,600;1,400&display=swap&subset=latin,latin-ext' \
  -o /tmp/ebg.css
grep -o 'https://fonts.gstatic.com[^)]*\.woff2' /tmp/ebg.css | sort -u
```

Download each distinct URL into `static/fonts/` with a descriptive name (`ebgaramond-400.woff2`, `ebgaramond-400-italic.woff2`, `ebgaramond-600.woff2`). If a URL set is larger than three files (Google splits by unicode-range), keep the `latin` and `latin-ext` ranges and discard the rest — those two cover Portuguese.

- [ ] **Step 2: Verify Portuguese coverage before building anything on top**

This is the highest-risk step in the plan: a subset validated only in English breaks the entire PT half of the site invisibly.

```bash
python3 - <<'PY'
import glob,sys
try:
    from fontTools.ttLib import TTFont
except ImportError:
    sys.exit("fonttools not installed — run: pip install --user fonttools brotli")
need="ãõçáéíóúâêôàüÃÕÇÁÉÍÓÚÂÊÔÀ"
bad=0
for f in sorted(glob.glob("static/fonts/*.woff2")):
    cmap=set()
    for t in TTFont(f,fontNumber=0).getBestCmap(): cmap.add(chr(t))
    missing=[c for c in need if c not in cmap]
    print(("FAIL " if missing else "ok   ")+f+(f"  missing: {''.join(missing)}" if missing else ""))
    bad+=bool(missing)
raise SystemExit(1 if bad else 0)
PY
```

Expected: exit 0. If `fonttools` cannot be installed, fall back to the visual check in Step 5 and say so in your report. **If glyphs are missing, re-fetch including the `latin-ext` subset before continuing.**

- [ ] **Step 3: Determine whether true small caps exist**

```bash
python3 - <<'PY'
import glob
from fontTools.ttLib import TTFont
for f in sorted(glob.glob("static/fonts/*.woff2")):
    ft=TTFont(f,fontNumber=0)
    feats=set()
    if "GSUB" in ft:
        for r in ft["GSUB"].table.FeatureList.FeatureRecord: feats.add(r.FeatureTag)
    print(f, "smcp" in feats and "HAS smcp" or "no smcp", "|", "onum" in feats and "HAS onum" or "no onum")
PY
```

Record the result in your report — Task 3 and 4 depend on it.

- **If `smcp` is present:** use `font-variant-caps: small-caps` and let the face do it.
- **If absent:** the spec forbids browser-synthesized caps. Fetch the upstream OFL build that includes small caps from `https://github.com/octaviopardo/EBGaramond12/tree/master/fonts/webfonts` (look for an `EBGaramond*SC*` or `-SC` webfont), commit it as `ebgaramond-sc.woff2`, and register it as a separate `@font-face` family `EB Garamond SC` used by the `.smallcaps` class. If neither route yields real small caps, **stop and report BLOCKED** rather than shipping fake ones.

- [ ] **Step 4: Write the typography file**

`assets/css/extended/02-typography.css` (adjust the `@font-face` src filenames to what you actually downloaded; add the SC family only if Step 3 required it):

```css
@font-face {
  font-family: "EB Garamond";
  font-style: normal;
  font-weight: 400;
  font-display: swap;
  src: url("/fonts/ebgaramond-400.woff2") format("woff2");
}
@font-face {
  font-family: "EB Garamond";
  font-style: italic;
  font-weight: 400;
  font-display: swap;
  src: url("/fonts/ebgaramond-400-italic.woff2") format("woff2");
}
@font-face {
  font-family: "EB Garamond";
  font-style: normal;
  font-weight: 600;
  font-display: swap;
  src: url("/fonts/ebgaramond-600.woff2") format("woff2");
}

:root {
  --font-serif: "EB Garamond", Garamond, Georgia, "Times New Roman", serif;
  --font-mono: ui-monospace, SFMono-Regular, "SF Mono", Menlo, Consolas, monospace;
}

body,
.post-content,
.post-title,
.entry-header h2,
.page-header h1 {
  font-family: var(--font-serif);
}

body {
  font-size: 20px;
  line-height: 1.65;
  /* Old-style figures: dates sit on the baseline instead of standing up. */
  font-variant-numeric: oldstyle-nums;
  -webkit-font-feature-settings: "onum" 1, "kern" 1, "liga" 1;
  font-feature-settings: "onum" 1, "kern" 1, "liga" 1;
  text-rendering: optimizeLegibility;
}

/* Garamond goes thin and gauzy on a dark ground. */
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) body { font-weight: 500; letter-spacing: 0.01em; }
}
:root[data-theme="dark"] body { font-weight: 500; letter-spacing: 0.01em; }

.post-title { font-size: 2.2rem; font-weight: 600; line-height: 1.2; letter-spacing: -0.01em; }
.post-content h2 { font-size: 1.6rem; font-weight: 600; }
.post-content h3 { font-size: 1.3rem; font-weight: 600; }

.smallcaps {
  font-variant-caps: small-caps;
  font-feature-settings: "smcp" 1, "onum" 1;
  letter-spacing: 0.06em;
  text-transform: lowercase;
}

.post-content blockquote { font-style: italic; }
code, pre, kbd { font-family: var(--font-mono); font-size: 0.85em; }
```

- [ ] **Step 5: Verify the fonts load locally, render Portuguese, and stay within budget**

```bash
hugo --minify --gc
du -ch static/fonts/*.woff2 | tail -1
ls public/fonts/
! grep -rq 'fonts.googleapis.com\|fonts.gstatic.com' public/ && echo NO-THIRD-PARTY-OK
grep -o 'EB Garamond' public/assets/css/stylesheet.*.css | head -1
```

Expected: total font size **≤120KB**; `public/fonts/` lists the same woff2 files (this is what makes the `url("/fonts/…")` in the `@font-face` resolve); `NO-THIRD-PARTY-OK`; the family name present in the stylesheet.

A 404 font fails silently — the browser falls back to Georgia and the whole design quietly collapses — so treat an empty `public/fonts/` as a hard failure, not a warning.

- [ ] **Step 6: Commit**

```bash
git add assets/css/extended/02-typography.css static/fonts
git commit -m "feat(identity): self-hosted EB Garamond with old-style figures and true small caps"
```

---

### Task 3: The margin rail

**Files:**
- Create: `layouts/single.html` (override — copy PaperMod's and restructure)
- Create: `assets/css/extended/03-layout.css`

**Interfaces:**
- Consumes: `--rail-width`, `--rail-gap`, `--prose-width`, `--rule`, `.smallcaps`.
- Produces: markup contract `article.post-single.railed > aside.rail + div.prose` that Task 4 styles against.

- [ ] **Step 1: Write the single-page override**

Copy `themes/PaperMod/layouts/single.html` to `layouts/single.html`, then restructure so the metadata and ToC sit in an aside and everything else in a prose div. The result:

```html
{{- define "main" }}

<article class="post-single railed">

  <aside class="rail">
    {{- if not (.Param "hideMeta") }}
    <div class="rail-meta smallcaps">
      {{- partial "post_meta.html" . -}}
    </div>
    {{- end }}
    <div class="rail-translations smallcaps">{{- partial "translation_list.html" . -}}</div>
    {{- if (.Param "ShowToc") }}
    <div class="rail-toc">{{- partial "toc.html" . }}</div>
    {{- end }}
  </aside>

  <div class="prose">
    <header class="post-header">
      {{ partial "breadcrumbs.html" . }}
      <h1 class="post-title entry-hint-parent">{{ .Title }}</h1>
      {{- if .Description }}<div class="post-description">{{ .Description }}</div>{{- end }}
    </header>

    {{- $isHidden := (.Param "cover.hiddenInSingle") | default (.Param "cover.hidden") | default false }}
    {{- partial "cover.html" (dict "cxt" . "IsSingle" true "isHidden" $isHidden) }}

    {{- if .Content }}
    <div class="post-content md-content">
      {{- if not (.Param "disableAnchoredHeadings") }}
      {{- partial "anchored_headings.html" .Content -}}
      {{- else }}{{ .Content }}{{ end }}
    </div>
    {{- end }}

    {{- partial "extend_post_content.html" . }}

    <footer class="post-footer">
      {{- $tags := .Language.Params.Taxonomies.tag | default "tags" }}
      <ul class="post-tags">
        {{- range ($.GetTerms $tags) }}
        <li><a href="{{ .Permalink }}">{{ .LinkTitle }}</a></li>
        {{- end }}
      </ul>
      {{- if (.Param "ShowPostNavLinks") }}{{- partial "post_nav_links.html" . }}{{- end }}
      {{- if (and site.Params.ShowShareButtons (ne .Params.disableShare true)) }}
      {{- partial "share_icons.html" . -}}
      {{- end }}
    </footer>

    {{- if (.Param "comments") }}{{- partial "comments.html" . }}{{- end }}
  </div>

</article>

{{- end }}{{/* end main */}}
```

Note the draft-badge SVG from the theme's version is intentionally dropped — drafts never build in this project.

- [ ] **Step 2: Write the layout CSS**

`assets/css/extended/03-layout.css`:

```css
/* Mobile-first: rail folds above the title as one line. */
.post-single.railed .rail {
  display: flex;
  flex-wrap: wrap;
  gap: 0 1rem;
  align-items: baseline;
  color: var(--muted);
  font-size: 0.8rem;
  padding-bottom: 0.6rem;
  border-bottom: 1px solid var(--rule);
  margin-bottom: 1.4rem;
}
.post-single.railed .rail-toc { display: none; }

@media (min-width: 1024px) {
  .post-single.railed {
    display: grid;
    grid-template-columns: var(--rail-width) minmax(0, var(--prose-width));
    column-gap: var(--rail-gap);
    align-items: start;
  }
  .post-single.railed .rail {
    display: block;
    grid-column: 1;
    text-align: right;
    /* The notebook's margin line — the only ornament in the design. */
    border-right: 1px solid var(--rule);
    border-bottom: 0;
    padding-right: calc(var(--rail-gap) / 2);
    margin-bottom: 0;
    position: sticky;
    top: calc(var(--header-height) + 1.5rem);
  }
  .post-single.railed .prose { grid-column: 2; }
  .post-single.railed .rail-toc { display: block; margin-top: 1.2rem; }
  .post-single.railed .rail-toc ul { list-style: none; margin: 0; padding: 0; }
  .post-single.railed .rail-toc li { margin: 0.3rem 0; line-height: 1.3; }

  /* The asymmetry persists on non-post pages: content aligns to the prose
     column even where the rail is empty, because the shape IS the identity. */
  .main .page-header,
  .main .post-entry,
  .main .archive-posts,
  .main .terms-tags,
  .main .search-header,
  .main #searchResults {
    max-width: var(--prose-width);
    margin-left: calc(var(--rail-width) + var(--rail-gap));
  }
}

@media (min-width: 768px) and (max-width: 1023px) {
  .post-single.railed .rail-toc { display: none; }
}
```

- [ ] **Step 3: Verify the structure and the breakpoints**

```bash
hugo --minify --gc
grep -o 'class="post-single railed"' public/posts/hello-world/index.html
grep -o '<aside class="rail">' public/posts/hello-world/index.html
grep -o 'class="prose"' public/posts/hello-world/index.html
grep -o 'grid-template-columns:var(--rail-width)' public/assets/css/stylesheet.*.css | head -1
grep -o 'position:sticky' public/assets/css/stylesheet.*.css | head -1
python3 scripts/check_translations.py content
```

Expected: one match for each. Then confirm the PT page has the same structure:

```bash
grep -c 'class="post-single railed"' public/pt/posts/hello-world/index.html
```

Expected: `1`.

- [ ] **Step 4: Commit**

```bash
git add layouts/single.html assets/css/extended/03-layout.css
git commit -m "feat(identity): margin rail layout with sticky table of contents"
```

---

### Task 4: Components

**Files:**
- Create: `assets/css/extended/04-components.css`

**Interfaces:**
- Consumes: all tokens, `--font-serif`, `.smallcaps`, and the rail markup contract from Task 3.

- [ ] **Step 1: Write the components file**

`assets/css/extended/04-components.css`:

```css
/* --- Global: nothing is a card. ------------------------------------ */
.post-entry,
.first-entry,
.entry-cover,
.post-single,
.paginav,
.terms-tags a,
.post-tags a,
.social-icons a,
button,
input,
pre,
code {
  border-radius: 0 !important;
  box-shadow: none !important;
}

/* --- Header: the logotype ------------------------------------------ */
.header .logo a {
  font-family: var(--font-serif);
  font-style: italic;
  font-weight: 400;
  font-size: 1.55rem;
  letter-spacing: 0.01em;
  color: var(--ink);
}
.header nav .menu a {
  font-variant-caps: small-caps;
  font-feature-settings: "smcp" 1;
  letter-spacing: 0.06em;
  font-size: 0.95rem;
  color: var(--muted);
}
.header nav .menu a:hover { color: var(--accent); }
.header { border-bottom: 1px solid var(--rule); }

/* --- Post list: a flat list, not a grid of cards -------------------- */
.post-entry {
  background: none;
  border: 0;
  border-bottom: 1px solid var(--rule);
  padding: 1.6rem 0;
  transition: none;
}
.post-entry:hover { background: none; transform: none; }
.entry-header h2 { font-size: 1.7rem; font-weight: 600; line-height: 1.25; }
.entry-content { color: var(--muted); font-size: 1rem; }
.entry-footer {
  color: var(--muted);
  font-variant-caps: small-caps;
  font-feature-settings: "smcp" 1, "onum" 1;
  letter-spacing: 0.06em;
}

/* --- Rail contents -------------------------------------------------- */
.rail-meta, .rail-translations { line-height: 1.5; }
.rail-toc a { color: var(--muted); text-decoration: none; }
.rail-toc a:hover { color: var(--accent); }
.rail-toc .details, .rail-toc summary { display: none; } /* PaperMod's ToC chrome */

/* --- Prose ---------------------------------------------------------- */
.post-content a { color: var(--accent); text-decoration-thickness: 1px; text-underline-offset: 2px; }
.post-content blockquote {
  border-inline-start: 2px solid var(--accent);
  background: none;
  padding-inline-start: 1.2rem;
  color: var(--ink);
  hanging-punctuation: first;
}
.post-content figure figcaption,
.post-content img + em {
  color: var(--muted);
  font-style: italic;
  font-variant-caps: small-caps;
  font-size: 0.85rem;
}
.post-content img { max-width: 100%; height: auto; }
.post-content hr { border: 0; border-top: 1px solid var(--rule); }

/* --- Code: ink on parchment, never a dark editor slab --------------- */
.post-content pre,
.post-content code,
.highlight pre {
  background: var(--code-surface) !important;
  color: var(--ink);
  border: 1px solid var(--rule);
}
.chroma .k, .chroma .kd, .chroma .kn { color: var(--accent); font-weight: 600; }
.chroma .s, .chroma .s1, .chroma .s2 { color: var(--accent); }
.chroma .c, .chroma .c1, .chroma .cm { color: var(--muted); font-style: italic; }
.chroma .nf, .chroma .nx { color: var(--ink); }
.chroma .m, .chroma .mi { color: var(--muted); }

/* --- Tags, taxonomy, pagination ------------------------------------- */
.post-tags a, .terms-tags a {
  background: none;
  border: 1px solid var(--rule);
  color: var(--muted);
  font-variant-caps: small-caps;
  font-feature-settings: "smcp" 1;
  letter-spacing: 0.06em;
}
.post-tags a:hover, .terms-tags a:hover { color: var(--accent); border-color: var(--accent); }
.paginav { border: 0; border-top: 1px solid var(--rule); }
.paginav a { color: var(--muted); }

/* --- Post footer surfaces (newsletter + giscus) --------------------- */
.newsletter-signup {
  border: 1px solid var(--rule) !important;
  border-radius: 0 !important;
  background: var(--surface);
}
.newsletter-signup h3 { font-family: var(--font-serif); font-weight: 600; }

/* --- 404, search ---------------------------------------------------- */
.not-found { color: var(--ink); }
#searchbox input {
  background: var(--surface);
  border: 1px solid var(--rule);
  color: var(--ink);
  font-family: var(--font-serif);
}

/* --- Cookie consent banner (from the blog build) -------------------- */
#cookie-consent {
  background: var(--surface) !important;
  border-top: 1px solid var(--rule) !important;
  color: var(--ink);
}
#cookie-consent button {
  background: none;
  border: 1px solid var(--rule);
  color: var(--ink);
  font-family: var(--font-serif);
}
```

- [ ] **Step 2: Verify the card look is gone and components are styled**

```bash
hugo --minify --gc
grep -o 'border-radius:0' public/assets/css/stylesheet.*.css | head -1
grep -o '\.post-entry{background:none' public/assets/css/stylesheet.*.css | head -1
grep -o 'code-surface' public/assets/css/stylesheet.*.css | head -1
make check
```

Expected: matches for each grep, `make check` green.

- [ ] **Step 3: Commit**

```bash
git add assets/css/extended/04-components.css
git commit -m "feat(identity): flatten cards and restyle components onto the notebook palette"
```

---

### Task 5: Identity assets — favicons and social card

**Files:**
- Create: `static/favicon.ico`, `static/favicon-16x16.png`, `static/favicon-32x32.png`, `static/apple-touch-icon.png`, `static/safari-pinned-tab.svg`
- Create: `static/og-default.png`
- Modify: `hugo.toml` (point `params.assets.*` at them only if the default root paths don't resolve)

**Interfaces:**
- Consumes: palette tokens. PaperMod already references all five icon paths at `themes/PaperMod/layouts/_partials/head.html:88-92`, defaulting to root-relative names — so files dropped in `static/` are picked up with no config change.
- Produces: the five icons whose absence currently 404s on every page, unblocking the deferred lychee `--remap` upgrade.

- [ ] **Step 1: Generate the monogram source**

Create an `EB` monogram SVG: saddle `#6d3f1d` ground, paper `#f4ece0` letterforms, set in a Garamond-family serif italic, 512×512 with the glyphs converted to a centered text element. Write it to `/tmp/monogram.svg`:

```bash
cat > /tmp/monogram.svg <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <rect width="512" height="512" fill="#6d3f1d"/>
  <text x="256" y="256" fill="#f4ece0" font-family="EB Garamond, Garamond, Georgia, serif"
        font-style="italic" font-size="300" text-anchor="middle" dominant-baseline="central">EB</text>
</svg>
SVG
```

- [ ] **Step 2: Render the raster icons**

Use whichever renderer is available; check in this order and report which you used:

```bash
command -v rsvg-convert || command -v inkscape || command -v magick || command -v convert || echo "NONE — use the Python fallback below"
```

With `rsvg-convert`:

```bash
mkdir -p static
rsvg-convert -w 16  -h 16  /tmp/monogram.svg -o static/favicon-16x16.png
rsvg-convert -w 32  -h 32  /tmp/monogram.svg -o static/favicon-32x32.png
rsvg-convert -w 180 -h 180 /tmp/monogram.svg -o static/apple-touch-icon.png
rsvg-convert -w 48  -h 48  /tmp/monogram.svg -o /tmp/favicon-48.png
python3 -c "from PIL import Image; Image.open('/tmp/favicon-48.png').save('static/favicon.ico', sizes=[(16,16),(32,32),(48,48)])"
```

If no SVG renderer exists, draw the monogram directly with Pillow (`pip install --user pillow`) using a serif TrueType from the system, or as a last resort render the letterforms as filled rectangles — but **report that as a concern**, since a degraded monogram is a visible flaw.

- [ ] **Step 3: Write the pinned-tab SVG (monochrome, as Safari requires)**

```bash
cat > static/safari-pinned-tab.svg <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
  <text x="256" y="256" font-family="Garamond, Georgia, serif" font-style="italic"
        font-size="300" text-anchor="middle" dominant-baseline="central">EB</text>
</svg>
SVG
```

- [ ] **Step 4: Build the social card**

1200×630, paper ground, ink rule, the name in Garamond italic, the four pillars in small caps beneath. Render `/tmp/og.svg` the same way as the monogram and save to `static/og-default.png`:

```bash
cat > /tmp/og.svg <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="630" viewBox="0 0 1200 630">
  <rect width="1200" height="630" fill="#f4ece0"/>
  <line x1="120" y1="300" x2="1080" y2="300" stroke="#ddd0bd" stroke-width="2"/>
  <text x="120" y="270" fill="#2f2a24" font-family="EB Garamond, Garamond, Georgia, serif"
        font-style="italic" font-size="96">Ed Barros</text>
  <text x="120" y="370" fill="#6b6157" font-family="EB Garamond, Garamond, Georgia, serif"
        font-size="40" letter-spacing="6">TECHNOLOGY · BARBECUE · JIU-JITSU · LIBERTY</text>
</svg>
SVG
```

Then reference it as the site-wide fallback image by adding to `hugo.toml` under `[params]`:

```toml
  images = ["og-default.png"]
```

- [ ] **Step 5: Verify every icon exists and is served**

```bash
hugo --minify --gc
for f in favicon.ico favicon-16x16.png favicon-32x32.png apple-touch-icon.png safari-pinned-tab.svg og-default.png; do
  test -f "public/$f" && echo "ok   $f" || echo "MISS $f"
done
grep -o 'og-default.png' public/index.html | head -1
```

Expected: six `ok` lines and one `og-default.png` match. Any `MISS` is a failure — these are exactly the files the site currently 404s on.

- [ ] **Step 6: Commit**

```bash
git add static hugo.toml
git commit -m "feat(identity): monogram favicons and default social card"
```

---

### Task 6: Verify and ship

**Files:** none created — this is the release gate.

- [ ] **Step 1: Full local verification**

```bash
make test
make check
! grep -rq 'fonts.googleapis.com\|fonts.gstatic.com' public/ && echo NO-THIRD-PARTY-OK
du -ch static/fonts/*.woff2 2>/dev/null | tail -1
grep -c 'class="post-single railed"' public/posts/hello-world/index.html public/pt/posts/hello-world/index.html
```

Expected: tests 6/6, `make check` green, `NO-THIRD-PARTY-OK`, fonts ≤120KB, `1` for both post pages.

- [ ] **Step 2: Confirm Portuguese renders with the real font**

```bash
grep -o 'Olá, Mundo' public/pt/posts/hello-world/index.html
grep -o 'não encontrada' public/404.html
grep -o 'Tecnologia' public/pt/index.html | head -1
```

Expected: one match each. Combined with Task 2 Step 2's glyph check, this confirms the PT half survives subsetting.

- [ ] **Step 3: Owner visual review**

Start the preview and report the URL to the owner, listing exactly what to look at: `http://localhost:1313/` and `/pt/`, a post page at three widths (mobile ≈375px, tablet ≈800px, desktop ≥1280px), and both palettes via the theme toggle.

```bash
make serve
```

**Stop here and wait for the owner's verdict.** Typography and color cannot be validated any other way. Apply whatever they ask for, re-run Step 1, and only then continue.

- [ ] **Step 4: Push**

```bash
git push origin main
```

- [ ] **Step 5: Watch CI to green**

```bash
gh run watch --repo ed-barros/barrosef.com --exit-status \
  $(gh run list --repo ed-barros/barrosef.com --branch main --limit 1 --json databaseId -q '.[0].databaseId')
```

Expected: exit 0. The external link check may report failures and is warn-only by design — the internal check and deploy must both be green.

- [ ] **Step 6: Smoke-test the live site**

```bash
for u in "https://barrosef.com/" "https://barrosef.com/pt/" "https://barrosef.com/posts/hello-world/" "https://barrosef.com/favicon-32x32.png" "https://barrosef.com/og-default.png"; do
  printf "%s -> %s\n" "$u" "$(curl -s -o /dev/null -w '%{http_code}' --max-time 20 "$u")"
done
curl -s https://barrosef.com/posts/hello-world/ | grep -o 'class="post-single railed"'
curl -s https://barrosef.com/ | grep -c 'fonts.gstatic.com'
```

Expected: `200` for all five URLs, one `railed` match, and `0` Google font references on the live site.

- [ ] **Step 7: Update the workspace submodule pointer**

```bash
cd /opt/wks/personal/barrosef-workspace
git add barrosef.com
git commit -m "chore: bump barrosef.com submodule — visual identity live"
git push origin main
```

---

## Deferred (not part of this plan)

1. **Real signature logotype.** When the owner supplies a signature image, vectorize it to a single-path SVG and set `params.label.iconSVG` in `hugo.toml` — PaperMod inlines it at `themes/PaperMod/layouts/_partials/header.html:26`. Regenerate the monogram from it. Until then the Garamond-italic wordmark stands.
2. **lychee `--remap`** internal-link coverage upgrade — unblocked by Task 5, since the missing favicons were its only blocker.
3. **Consent-revisit UI** — still required before any GA4 measurement ID is set.
4. `rglob` in `check_translations.py` for page-bundle posts; Node 20 action version bumps.
