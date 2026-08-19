# barrosef.com Bilingual Blog Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship the bilingual (EN root / PT at `/pt/`) Hugo + PaperMod blog to GitHub Pages at barrosef.com, with CI that blocks half-translated or broken posts.

**Architecture:** A single Hugo site in the `ed-barros/barrosef.com` repo. PaperMod is a git submodule, customized only via `layouts/` overrides and config. Two content trees (`content/en`, `content/pt`) linked per post by `translationKey`. GitHub Actions builds, runs a translation-mirror check and lychee link check, and deploys to GitHub Pages on push to `main`.

**Tech Stack:** Hugo extended 0.148.2 (pinned locally and in CI), PaperMod theme, Python 3 (stdlib only) for the mirror check, GNU Make for the writing workflow, GitHub Actions + Pages, lychee (CI only).

**Spec:** `docs/superpowers/specs/2026-08-18-barrosef-com-blog-design.md` (in this repo — read it first).

## Global Constraints

- Hugo version pinned to **0.148.2 extended** everywhere (local install and CI `HUGO_VERSION`); never rely on a distro package.
- **English at root (`/`), Portuguese at `/pt/`** — `defaultContentLanguage = "en"`, `defaultContentLanguageInSubdir = false`.
- PaperMod is a **git submodule at `themes/PaperMod`** — never edit files under `themes/`; all customization goes in `layouts/`, `assets/`, or config.
- Categories are exactly: EN **Technology, Barbecue, Jiu-Jitsu, Liberty**; PT **Tecnologia, Churrasco, Jiu-Jitsu, Liberdade**.
- Post front matter must carry: `title`, `date`, `categories`, `tags`, `translationKey`, `description`, optional `cover`, `draft` (YAML, `---` delimiters).
- Third-party scripts: GA4 loads **only after consent acceptance**; Instagram/TikTok embed scripts load **only on pages using the shortcode**; no other trackers.
- All user-facing partial strings must exist in both `i18n/en.toml` and `i18n/pt.toml` — no hardcoded English in shared partials (the bilingual 404 is the one page that intentionally hardcodes both languages).
- Every commit leaves `hugo --minify --gc` passing and `python3 scripts/check_translations.py content` passing (from Task 3 onward).
- Run all commands from the repo root: `/opt/wks/personal/barrosef-workspace/barrosef.com`. After each commit here, the parent workspace repo's submodule pointer moves — do **not** commit the workspace repo until the final task.

## File Structure

| Path | Responsibility |
|---|---|
| `hugo.toml` | Site config: languages, menus, taxonomies, PaperMod params, feature params (GA4/Kit/giscus IDs, empty by default) |
| `.gitignore` | `public/`, `resources/_gen/`, `.hugo_build.lock` |
| `themes/PaperMod` | Theme submodule (untouched) |
| `archetypes/posts.md` | Front-matter template for `hugo new` (both languages; sets `translationKey` from filename) |
| `content/en/…`, `content/pt/…` | Mirrored content: posts, about/sobre, newsletter, search |
| `i18n/en.toml`, `i18n/pt.toml` | Strings for consent banner and newsletter partials |
| `layouts/partials/extend_head.html` | Conditional GA4 loader (consent-gated) |
| `layouts/partials/extend_footer.html` | Cookie-consent banner |
| `layouts/partials/newsletter-form.html` | Kit signup form (param-gated) |
| `layouts/partials/comments.html` | Post-footer injection point PaperMod provides: newsletter form + giscus |
| `layouts/shortcodes/instagram.html`, `layouts/shortcodes/tiktok.html` | Official-embed wrappers |
| `layouts/404.html` | Bilingual 404 |
| `scripts/check_translations.py` | Mirror-completeness check |
| `tests/check_translations_test.sh` | Fixture-based test for the check script |
| `Makefile` | `make post SLUG=…`, `make serve`, `make build`, `make check` |
| `.github/workflows/deploy.yml` | CI: build → mirror check → lychee → Pages deploy |
| `static/CNAME` | `barrosef.com` |
| `README.md` | 5-line writing-workflow cheat sheet + setup notes |

---

### Task 1: Toolchain and Hugo site skeleton

**Files:**
- Create: `hugo.toml`, `.gitignore`
- Create: `themes/PaperMod` (git submodule)
- Tool install: Hugo 0.148.2 extended into `~/.local/bin`

**Interfaces:**
- Produces: a building Hugo site; `hugo.toml` param names later tasks read: `params.analytics.ga4`, `params.newsletter.kitFormId`, `params.giscus.{repo,repoId,category,categoryId}`, `params.comments`.

- [ ] **Step 1: Install pinned Hugo locally**

```bash
mkdir -p ~/.local/bin
curl -sSL https://github.com/gohugoio/hugo/releases/download/v0.148.2/hugo_extended_0.148.2_linux-amd64.tar.gz | tar -xz -C ~/.local/bin hugo
hugo version
```

Expected: `hugo v0.148.2-…+extended linux/amd64`. If `hugo` is not found, `~/.local/bin` is not on PATH — use the full path `~/.local/bin/hugo` in every later step.

- [ ] **Step 2: Add PaperMod submodule and .gitignore**

```bash
cd /opt/wks/personal/barrosef-workspace/barrosef.com
git submodule add --depth=1 https://github.com/adityatelange/hugo-PaperMod.git themes/PaperMod
printf 'public/\nresources/_gen/\n.hugo_build.lock\n' > .gitignore
```

- [ ] **Step 3: Write `hugo.toml`**

```toml
baseURL = "https://barrosef.com/"
title = "Ed Barros"
theme = "PaperMod"
defaultContentLanguage = "en"
defaultContentLanguageInSubdir = false
enableRobotsTXT = true
enableEmoji = true

[pagination]
  pagerSize = 10

[taxonomies]
  category = "categories"
  tag = "tags"

[outputs]
  home = ["HTML", "RSS", "JSON"] # JSON feeds PaperMod's built-in fuzzy search

[params]
  defaultTheme = "auto"
  ShowReadingTime = true
  ShowShareButtons = true
  ShowBreadCrumbs = true
  ShowCodeCopyButtons = true
  ShowToc = true
  comments = true

  [params.analytics]
    ga4 = "" # e.g. "G-XXXXXXXXXX"; empty disables GA entirely

  [params.newsletter]
    kitFormId = "" # Kit (ConvertKit) embed form UID; empty hides the form

  [params.giscus]
    repo = ""       # "ed-barros/barrosef.com" once Discussions is enabled
    repoId = ""
    category = ""
    categoryId = ""

[languages]
  [languages.en]
    languageName = "English"
    languageCode = "en-us"
    contentDir = "content/en"
    weight = 1
    [languages.en.params]
      homeInfoParams = { Title = "Ed Barros", Content = "Technology, barbecue, jiu-jitsu, and liberty." }
    [[languages.en.menus.main]]
      name = "Categories"
      url = "/categories/"
      weight = 10
    [[languages.en.menus.main]]
      name = "Tags"
      url = "/tags/"
      weight = 20
    [[languages.en.menus.main]]
      name = "About"
      url = "/about/"
      weight = 30
    [[languages.en.menus.main]]
      name = "Newsletter"
      url = "/newsletter/"
      weight = 40
    [[languages.en.menus.main]]
      name = "Search"
      url = "/search/"
      weight = 50

  [languages.pt]
    languageName = "Português"
    languageCode = "pt-br"
    contentDir = "content/pt"
    weight = 2
    [languages.pt.params]
      homeInfoParams = { Title = "Ed Barros", Content = "Tecnologia, churrasco, jiu-jitsu e liberdade." }
    [[languages.pt.menus.main]]
      name = "Categorias"
      url = "/pt/categories/"
      weight = 10
    [[languages.pt.menus.main]]
      name = "Tags"
      url = "/pt/tags/"
      weight = 20
    [[languages.pt.menus.main]]
      name = "Sobre"
      url = "/pt/sobre/"
      weight = 30
    [[languages.pt.menus.main]]
      name = "Newsletter"
      url = "/pt/newsletter/"
      weight = 40
    [[languages.pt.menus.main]]
      name = "Busca"
      url = "/pt/search/"
      weight = 50
```

- [ ] **Step 4: Verify the site builds with EN at root and PT under /pt/**

```bash
mkdir -p content/en content/pt
hugo --minify --gc
test -f public/index.html && test -f public/pt/index.html && echo OK
```

Expected: build succeeds (warnings about no content are fine), prints `OK`.

- [ ] **Step 5: Commit**

```bash
git add .gitignore .gitmodules themes/PaperMod hugo.toml
git commit -m "feat: Hugo site skeleton with PaperMod and en/pt language config"
```

---

### Task 2: Content structure — archetype, first post pair, fixed pages, i18n strings

**Files:**
- Create: `archetypes/posts.md`
- Create: `content/en/posts/hello-world.md`, `content/pt/posts/hello-world.md`
- Create: `content/en/about.md`, `content/pt/sobre.md`
- Create: `content/en/newsletter.md`, `content/pt/newsletter.md`
- Create: `content/en/search.md`, `content/pt/search.md`
- Create: `i18n/en.toml`, `i18n/pt.toml`

**Interfaces:**
- Consumes: `hugo.toml` from Task 1.
- Produces: front-matter shape all later tasks rely on; `translationKey` values the Task 3 checker parses; i18n keys `consentText`, `consentAccept`, `consentDecline`, `newsletterTitle` used by Task 5/6 partials. PT posts live in `content/pt/posts/` with the **same filename** as the EN post; fixed-page pairs are linked by explicit `translationKey` (`about`, `newsletter`, `search`).

- [ ] **Step 1: Write the archetype**

`archetypes/posts.md`:

```markdown
---
title: "{{ replace .File.ContentBaseName "-" " " | title }}"
date: {{ .Date }}
draft: true
translationKey: "{{ .File.ContentBaseName }}"
categories: []
tags: []
description: ""
cover:
  image: ""
  alt: ""
---
```

- [ ] **Step 2: Write the first post pair**

`content/en/posts/hello-world.md`:

```markdown
---
title: "Hello, World"
date: 2026-08-18T21:00:00-04:00
draft: false
translationKey: "hello-world"
categories: ["Technology"]
tags: ["meta"]
description: "Why this blog exists: technology, barbecue, jiu-jitsu, and liberty — in two languages."
---

Welcome. This blog covers four things I care about: technology, barbecue,
jiu-jitsu, and liberty. Every post is published in English and Portuguese —
use the language switcher in the header.
```

`content/pt/posts/hello-world.md`:

```markdown
---
title: "Olá, Mundo"
date: 2026-08-18T21:00:00-04:00
draft: false
translationKey: "hello-world"
categories: ["Tecnologia"]
tags: ["meta"]
description: "Por que este blog existe: tecnologia, churrasco, jiu-jitsu e liberdade — em dois idiomas."
---

Bem-vindo. Este blog cobre quatro coisas que me importam: tecnologia,
churrasco, jiu-jitsu e liberdade. Todo post é publicado em inglês e
português — use o seletor de idioma no cabeçalho.
```

- [ ] **Step 3: Write the fixed pages**

`content/en/about.md`:

```markdown
---
title: "About"
translationKey: "about"
description: "Who Ed Barros is and what this site is about."
---

I'm Ed Barros. I write about technology, barbecue, jiu-jitsu, and liberty.
```

`content/pt/sobre.md`:

```markdown
---
title: "Sobre"
translationKey: "about"
url: "/sobre/"
description: "Quem é Ed Barros e do que trata este site."
---

Sou Ed Barros. Escrevo sobre tecnologia, churrasco, jiu-jitsu e liberdade.
```

`content/en/newsletter.md`:

```markdown
---
title: "Newsletter"
translationKey: "newsletter"
description: "Get new posts by email."
---

New posts in your inbox. No spam, unsubscribe anytime.
```

`content/pt/newsletter.md`:

```markdown
---
title: "Newsletter"
translationKey: "newsletter"
description: "Receba novos posts por e-mail."
---

Novos posts na sua caixa de entrada. Sem spam, cancele quando quiser.
```

Note: the newsletter pages are prose-only for now — Hugo fails the build on unknown shortcodes, so Task 6 appends its `newsletter` shortcode line to both files only after creating the shortcode.

`content/en/search.md`:

```markdown
---
title: "Search"
translationKey: "search"
layout: "search"
placeholder: "Search posts…"
---
```

`content/pt/search.md`:

```markdown
---
title: "Busca"
translationKey: "search"
layout: "search"
placeholder: "Buscar posts…"
---
```

- [ ] **Step 4: Write the i18n string tables**

`i18n/en.toml`:

```toml
[consentText]
other = "This site uses cookies for anonymous analytics only if you accept."

[consentAccept]
other = "Accept"

[consentDecline]
other = "Decline"

[newsletterTitle]
other = "Get new posts by email"
```

`i18n/pt.toml`:

```toml
[consentText]
other = "Este site usa cookies para análises anônimas somente se você aceitar."

[consentAccept]
other = "Aceitar"

[consentDecline]
other = "Recusar"

[newsletterTitle]
other = "Receba novos posts por e-mail"
```

- [ ] **Step 5: Verify build, mirror pages, and translation links**

```bash
hugo --minify --gc
test -f public/posts/hello-world/index.html && test -f public/pt/posts/hello-world/index.html && echo POSTS-OK
test -f public/about/index.html && test -f public/pt/sobre/index.html && echo PAGES-OK
grep -o 'hreflang="pt-br"' public/posts/hello-world/index.html | head -1
grep -o 'categories/technology' public/index.html | head -1
```

Expected: `POSTS-OK`, `PAGES-OK`, one `hreflang="pt-br"` match (proves the pair is linked and the language switcher will render), one `categories/technology` match.

- [ ] **Step 6: Verify the archetype produces correct front matter**

```bash
hugo new content/en/posts/archetype-smoke-test.md
grep 'translationKey: "archetype-smoke-test"' content/en/posts/archetype-smoke-test.md && grep 'draft: true' content/en/posts/archetype-smoke-test.md && echo ARCHETYPE-OK
rm content/en/posts/archetype-smoke-test.md
```

Expected: `ARCHETYPE-OK`.

- [ ] **Step 7: Commit**

```bash
git add archetypes content i18n
git commit -m "feat: archetype, first bilingual post pair, fixed pages, i18n strings"
```

---

### Task 3: Translation mirror check (TDD)

**Files:**
- Create: `scripts/check_translations.py`
- Test: `tests/check_translations_test.sh`

**Interfaces:**
- Consumes: post front-matter shape from Task 2 (YAML between `---` fences, keys `translationKey`, `draft`).
- Produces: `python3 scripts/check_translations.py <content-dir>` — exit 0 when every non-draft post's `translationKey` exists in both `<content-dir>/en/posts` and `<content-dir>/pt/posts`; exit 1 with a listing otherwise. Task 4's `make check` and Task 9's CI call it exactly as `python3 scripts/check_translations.py content`.

- [ ] **Step 1: Write the failing test**

`tests/check_translations_test.sh`:

```bash
#!/usr/bin/env bash
# Fixture-based tests for scripts/check_translations.py
set -u
cd "$(dirname "$0")/.."
PASS=0; FAIL=0

make_fixture() { # $1=dir
  mkdir -p "$1/en/posts" "$1/pt/posts"
}
write_post() { # $1=path $2=key $3=draft
  printf -- '---\ntitle: "T"\ndate: 2026-08-18\ndraft: %s\ntranslationKey: "%s"\n---\nbody\n' "$3" "$2" > "$1"
}
check() { # $1=name $2=expected_exit $3=fixture_dir
  python3 scripts/check_translations.py "$3" > /tmp/ct_out 2>&1
  local got=$?
  if [ "$got" -eq "$2" ]; then PASS=$((PASS+1)); echo "ok: $1"
  else FAIL=$((FAIL+1)); echo "FAIL: $1 (expected exit $2, got $got)"; cat /tmp/ct_out; fi
}

FX=$(mktemp -d)

# 1. Complete mirror passes
make_fixture "$FX/complete"
write_post "$FX/complete/en/posts/a.md" "a" false
write_post "$FX/complete/pt/posts/a.md" "a" false
check "complete mirror passes" 0 "$FX/complete"

# 2. Missing PT pair fails
make_fixture "$FX/missing-pt"
write_post "$FX/missing-pt/en/posts/a.md" "a" false
check "missing PT pair fails" 1 "$FX/missing-pt"

# 3. Missing EN pair fails
make_fixture "$FX/missing-en"
write_post "$FX/missing-en/pt/posts/a.md" "a" false
check "missing EN pair fails" 1 "$FX/missing-en"

# 4. Draft without pair passes (drafts exempt)
make_fixture "$FX/draft"
write_post "$FX/draft/en/posts/a.md" "a" true
check "draft without pair passes" 0 "$FX/draft"

# 5. Non-draft post missing translationKey fails
make_fixture "$FX/nokey"
printf -- '---\ntitle: "T"\ndate: 2026-08-18\ndraft: false\n---\nbody\n' > "$FX/nokey/en/posts/a.md"
check "missing translationKey fails" 1 "$FX/nokey"

# 6. Duplicate translationKey in one language fails
make_fixture "$FX/dupe"
write_post "$FX/dupe/en/posts/a.md" "a" false
write_post "$FX/dupe/en/posts/b.md" "a" false
write_post "$FX/dupe/pt/posts/a.md" "a" false
check "duplicate key in one language fails" 1 "$FX/dupe"

rm -rf "$FX"
echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
```

```bash
chmod +x tests/check_translations_test.sh
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
./tests/check_translations_test.sh
```

Expected: all cases FAIL (python exits 2 with "No such file" — script doesn't exist yet), summary shows `0 passed, 6 failed`, script exits non-zero.

- [ ] **Step 3: Write the implementation**

`scripts/check_translations.py`:

```python
#!/usr/bin/env python3
"""Assert every non-draft post's translationKey exists in both content/en and content/pt.

Usage: python3 scripts/check_translations.py <content-dir>
Exit 0 on a complete mirror, 1 (with a listing) otherwise.
Stdlib only — no PyYAML; front matter is parsed with a line regex, which is
sufficient for the flat keys this site uses (translationKey, draft).
"""
import re
import sys
from pathlib import Path

FRONT_MATTER = re.compile(r"^---\s*\n(.*?)\n---\s*\n", re.DOTALL)
KEY_VALUE = re.compile(r"^(\w+):\s*(.*)$")


def parse_front_matter(path: Path) -> dict:
    match = FRONT_MATTER.match(path.read_text(encoding="utf-8"))
    if not match:
        sys.exit(f"ERROR: {path}: missing YAML front matter")
    fields = {}
    for line in match.group(1).splitlines():
        kv = KEY_VALUE.match(line)
        if kv:
            fields[kv.group(1)] = kv.group(2).strip().strip('"').strip("'")
    return fields


def collect_keys(content_dir: Path, lang: str) -> dict:
    """Map translationKey -> post path for non-draft posts in one language."""
    keys = {}
    posts_dir = content_dir / lang / "posts"
    for post in sorted(posts_dir.glob("*.md")) if posts_dir.is_dir() else []:
        if post.name == "_index.md":
            continue
        fm = parse_front_matter(post)
        if fm.get("draft", "false").lower() == "true":
            continue
        key = fm.get("translationKey", "")
        if not key:
            sys.exit(f"ERROR: {post}: non-draft post has no translationKey")
        if key in keys:
            sys.exit(f"ERROR: duplicate translationKey '{key}' in {lang}: {post} and {keys[key]}")
        keys[key] = post
    return keys


def main() -> None:
    content = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("content")
    en, pt = collect_keys(content, "en"), collect_keys(content, "pt")
    problems = [f"EN post {en[k]} has no PT pair (translationKey: {k})" for k in sorted(en.keys() - pt.keys())]
    problems += [f"PT post {pt[k]} has no EN pair (translationKey: {k})" for k in sorted(pt.keys() - en.keys())]
    if problems:
        print("Translation mirror check FAILED:")
        for problem in problems:
            print(f"  - {problem}")
        sys.exit(1)
    print(f"Translation mirror check OK: {len(en)} post pair(s).")


if __name__ == "__main__":
    main()
```

- [ ] **Step 4: Run the tests to verify they pass**

```bash
./tests/check_translations_test.sh
python3 scripts/check_translations.py content
```

Expected: `6 passed, 0 failed`; then `Translation mirror check OK: 1 post pair(s).`

- [ ] **Step 5: Commit**

```bash
git add scripts/check_translations.py tests/check_translations_test.sh
git commit -m "feat: translation mirror check with fixture tests"
```

---

### Task 4: Makefile writing workflow

**Files:**
- Create: `Makefile`

**Interfaces:**
- Consumes: archetype from Task 2, checker from Task 3.
- Produces: `make post SLUG=<slug>` (scaffolds the EN+PT pair), `make serve`, `make build`, `make check`. Task 9's README documents exactly these targets.

- [ ] **Step 1: Write the Makefile**

```make
HUGO ?= hugo

.PHONY: post serve build check test

## make post SLUG=my-post-slug — scaffold the EN+PT pair with a shared translationKey
post:
ifndef SLUG
	$(error Usage: make post SLUG=my-post-slug)
endif
	$(HUGO) new content/en/posts/$(SLUG).md
	$(HUGO) new content/pt/posts/$(SLUG).md
	@echo "Created EN+PT pair for '$(SLUG)'. Write both, set draft: false on both, push."

## Live preview including drafts
serve:
	$(HUGO) server -D

## Production build (what CI runs)
build:
	$(HUGO) --minify --gc

## Full local gate: build + translation mirror
check: build
	python3 scripts/check_translations.py content

## Run the script test suite
test:
	./tests/check_translations_test.sh
```

(Recipe lines are tab-indented — Make requires tabs.)

- [ ] **Step 2: Verify scaffolding produces a linked, draft pair**

```bash
make post SLUG=make-smoke-test
grep -c 'translationKey: "make-smoke-test"' content/en/posts/make-smoke-test.md content/pt/posts/make-smoke-test.md
make check
rm content/en/posts/make-smoke-test.md content/pt/posts/make-smoke-test.md
```

Expected: both greps report `1`; `make check` passes (the new pair is draft, so the mirror check ignores it and `hugo` doesn't build it).

- [ ] **Step 3: Verify the guard rail**

```bash
make post 2>&1 | grep 'Usage: make post SLUG=' && echo GUARD-OK
```

Expected: `GUARD-OK`.

- [ ] **Step 4: Commit**

```bash
git add Makefile
git commit -m "feat: make targets for post scaffolding, preview, build, and checks"
```

---

### Task 5: GA4 with consent banner

**Files:**
- Create: `layouts/partials/extend_head.html`
- Create: `layouts/partials/extend_footer.html`

**Interfaces:**
- Consumes: `params.analytics.ga4` (Task 1), i18n keys `consentText`/`consentAccept`/`consentDecline` (Task 2).
- Produces: GA4 loads only when `params.analytics.ga4` is non-empty AND `localStorage["cookie-consent"] == "accepted"`. PaperMod includes `extend_head.html`/`extend_footer.html` on every page automatically — no other wiring needed.

- [ ] **Step 1: Write the consent-gated GA loader**

`layouts/partials/extend_head.html`:

```html
{{- with .Site.Params.analytics.ga4 }}
<script>
  (function () {
    if (localStorage.getItem("cookie-consent") !== "accepted") return;
    var s = document.createElement("script");
    s.async = true;
    s.src = "https://www.googletagmanager.com/gtag/js?id={{ . }}";
    document.head.appendChild(s);
    window.dataLayer = window.dataLayer || [];
    function gtag() { dataLayer.push(arguments); }
    window.gtag = gtag;
    gtag("js", new Date());
    gtag("config", "{{ . }}", { anonymize_ip: true });
  })();
</script>
{{- end }}
```

- [ ] **Step 2: Write the consent banner**

`layouts/partials/extend_footer.html`:

```html
{{- if .Site.Params.analytics.ga4 }}
<div id="cookie-consent" style="display:none;position:fixed;bottom:0;left:0;right:0;z-index:100;padding:1rem;text-align:center;background:var(--entry);border-top:1px solid var(--border);">
  <span>{{ i18n "consentText" }}</span>
  <button id="consent-accept" style="margin:0 .5rem;padding:.3rem 1rem;cursor:pointer;">{{ i18n "consentAccept" }}</button>
  <button id="consent-decline" style="padding:.3rem 1rem;cursor:pointer;">{{ i18n "consentDecline" }}</button>
</div>
<script>
  (function () {
    var banner = document.getElementById("cookie-consent");
    if (!localStorage.getItem("cookie-consent")) banner.style.display = "block";
    document.getElementById("consent-accept").addEventListener("click", function () {
      localStorage.setItem("cookie-consent", "accepted");
      banner.style.display = "none";
      location.reload(); // reload so the head loader picks up consent
    });
    document.getElementById("consent-decline").addEventListener("click", function () {
      localStorage.setItem("cookie-consent", "declined");
      banner.style.display = "none";
    });
  })();
</script>
{{- end }}
```

- [ ] **Step 3: Verify both states of the param gate**

```bash
hugo --minify --gc && ! grep -q googletagmanager public/index.html && echo OFF-OK
printf '[params.analytics]\nga4 = "G-TESTTEST"\n' > /tmp/test-ga.toml
hugo --minify --gc --config hugo.toml,/tmp/test-ga.toml
grep -q "googletagmanager.com/gtag/js?id=G-TESTTEST" public/index.html && grep -q 'cookie-consent' public/index.html && echo ON-OK
grep -q "Aceitar" public/pt/index.html && echo PT-I18N-OK
hugo --minify --gc
```

(`--config hugo.toml,/tmp/test-ga.toml` merges the overlay on top of the real config — later files win. Same technique in Task 6.)

Expected: `OFF-OK`, `ON-OK`, `PT-I18N-OK` (PT pages get the Portuguese banner strings). Final rebuild restores the clean (GA-off) output.

- [ ] **Step 4: Commit**

```bash
git add layouts/partials/extend_head.html layouts/partials/extend_footer.html
git commit -m "feat: consent-gated GA4 analytics with bilingual cookie banner"
```

---

### Task 6: Post-footer partials — Kit newsletter form and giscus comments

**Files:**
- Create: `layouts/partials/newsletter-form.html`
- Create: `layouts/partials/comments.html`
- Create: `layouts/shortcodes/newsletter.html`
- Modify: `content/en/newsletter.md`, `content/pt/newsletter.md` (append the shortcode line)

**Interfaces:**
- Consumes: `params.newsletter.kitFormId`, `params.giscus.*`, `params.comments = true` (Task 1); i18n key `newsletterTitle` (Task 2).
- Produces: PaperMod renders `partials/comments.html` at the bottom of every post when `params.comments` is true — our override injects newsletter form + giscus there. The `{{</* newsletter */>}}` shortcode renders the same form on the landing pages.

- [ ] **Step 1: Write the newsletter form partial**

`layouts/partials/newsletter-form.html`:

```html
{{- with .Site.Params.newsletter.kitFormId }}
<div class="newsletter-signup" style="margin:2rem 0;padding:1rem;border:1px solid var(--border);border-radius:8px;">
  <h3>{{ i18n "newsletterTitle" }}</h3>
  <script async data-uid="{{ . }}" src="https://barrosef.kit.com/{{ . }}/index.js"></script>
</div>
{{- end }}
```

(When the Kit account exists, paste the exact `src` host from Kit's embed snippet if it differs — only this file changes.)

- [ ] **Step 2: Write the newsletter shortcode**

`layouts/shortcodes/newsletter.html`:

```html
{{ partial "newsletter-form.html" . }}
```

Append `{{</* newsletter */>}}` as the last line of `content/en/newsletter.md` and `content/pt/newsletter.md` (Task 2 left them prose-only).

- [ ] **Step 3: Write the comments partial (newsletter + giscus)**

`layouts/partials/comments.html`:

```html
{{ partial "newsletter-form.html" . }}
{{- if .Site.Params.giscus.repo }}
<div class="giscus" style="margin-top:2rem;">
  <script src="https://giscus.app/client.js"
          data-repo="{{ .Site.Params.giscus.repo }}"
          data-repo-id="{{ .Site.Params.giscus.repoId }}"
          data-category="{{ .Site.Params.giscus.category }}"
          data-category-id="{{ .Site.Params.giscus.categoryId }}"
          data-mapping="pathname"
          data-reactions-enabled="1"
          data-input-position="top"
          data-theme="preferred_color_scheme"
          data-lang="{{ .Site.Language.Lang }}"
          crossorigin="anonymous"
          async></script>
</div>
{{- end }}
```

- [ ] **Step 4: Verify param gating in both directions**

```bash
hugo --minify --gc
! grep -q giscus.app public/posts/hello-world/index.html && ! grep -q kit.com public/posts/hello-world/index.html && echo OFF-OK
printf '[params.newsletter]\nkitFormId = "testuid"\n[params.giscus]\nrepo = "ed-barros/barrosef.com"\n' > /tmp/test-social.toml
hugo --minify --gc --config hugo.toml,/tmp/test-social.toml
grep -q "data-uid=\"testuid\"" public/posts/hello-world/index.html && grep -q "giscus.app/client.js" public/posts/hello-world/index.html && echo ON-OK
grep -q "data-lang=\"pt\"" public/pt/posts/hello-world/index.html && echo PT-OK
grep -q "data-uid=\"testuid\"" public/newsletter/index.html && echo LANDING-OK
hugo --minify --gc
```

Expected: `OFF-OK`, `ON-OK`, `PT-OK` (giscus follows page language), `LANDING-OK`.

- [ ] **Step 5: Commit**

```bash
git add layouts/partials/newsletter-form.html layouts/partials/comments.html layouts/shortcodes/newsletter.html content/en/newsletter.md content/pt/newsletter.md
git commit -m "feat: Kit newsletter form and giscus comments on post footers"
```

---

### Task 7: Social — OG/Twitter meta verification and IG/TikTok embed shortcodes

**Files:**
- Create: `layouts/shortcodes/instagram.html`
- Create: `layouts/shortcodes/tiktok.html`

**Interfaces:**
- Consumes: front-matter `description`/`cover` (Task 2). PaperMod already emits OG + Twitter Card meta and share buttons (`ShowShareButtons = true` from Task 1) — this task verifies rather than builds them.
- Produces: `{{</* instagram <shortcode> */>}}` (the post ID from an instagram.com/p/<ID>/ URL) and `{{</* tiktok <username> <video-id> */>}}` for use in any post body.

- [ ] **Step 1: Verify PaperMod's built-in social meta**

```bash
hugo --minify --gc
grep -o '<meta property="og:title"[^>]*>' public/posts/hello-world/index.html
grep -o '<meta name="twitter:card"[^>]*>' public/posts/hello-world/index.html
grep -o 'property="og:description" content="Why this blog exists[^"]*"' public/posts/hello-world/index.html
grep -c 'class="share-buttons"' public/posts/hello-world/index.html
```

Expected: one match each for og:title, twitter:card, the front-matter description flowing into og:description, and the share-buttons block. If any is missing, fix `hugo.toml` params — do not write custom meta partials (PaperMod provides them).

- [ ] **Step 2: Write the embed shortcodes**

`layouts/shortcodes/instagram.html`:

```html
<blockquote class="instagram-media"
            data-instgrm-permalink="https://www.instagram.com/p/{{ .Get 0 }}/"
            data-instgrm-version="14"
            style="margin:1rem auto;max-width:540px;">
  <a href="https://www.instagram.com/p/{{ .Get 0 }}/">instagram.com/p/{{ .Get 0 }}</a>
</blockquote>
<script async src="https://www.instagram.com/embed.js"></script>
```

`layouts/shortcodes/tiktok.html`:

```html
<blockquote class="tiktok-embed"
            cite="https://www.tiktok.com/@{{ .Get 0 }}/video/{{ .Get 1 }}"
            data-video-id="{{ .Get 1 }}"
            style="margin:1rem auto;max-width:605px;">
  <a href="https://www.tiktok.com/@{{ .Get 0 }}/video/{{ .Get 1 }}">@{{ .Get 0 }}</a>
</blockquote>
<script async src="https://www.tiktok.com/embed.js"></script>
```

- [ ] **Step 3: Verify shortcodes render only where used**

```bash
mkdir -p /tmp/sc-test && cp content/en/posts/hello-world.md /tmp/sc-test/backup.md
printf '\n{{</* instagram ABC123 */>}}\n{{</* tiktok edbarros 12345 */>}}\n' >> content/en/posts/hello-world.md
hugo --minify --gc
grep -q "instagram.com/p/ABC123" public/posts/hello-world/index.html && grep -q "tiktok.com/@edbarros/video/12345" public/posts/hello-world/index.html && echo EMBED-OK
! grep -q "instagram.com/embed.js" public/index.html && echo SCOPED-OK
cp /tmp/sc-test/backup.md content/en/posts/hello-world.md && hugo --minify --gc
```

Expected: `EMBED-OK`, `SCOPED-OK` (embed script only on the page using the shortcode), post restored, clean rebuild.

(Write the shortcode calls in the test exactly as Hugo syntax — the `/* */` markers in this plan only escape rendering inside this document; the real lines are `{{< instagram ABC123 >}}` and `{{< tiktok edbarros 12345 >}}`. The same applies to the `newsletter` shortcode lines in Tasks 2 and 6.)

- [ ] **Step 4: Commit**

```bash
git add layouts/shortcodes/instagram.html layouts/shortcodes/tiktok.html
git commit -m "feat: Instagram and TikTok embed shortcodes"
```

---

### Task 8: Bilingual 404 page

**Files:**
- Create: `layouts/404.html`

**Interfaces:**
- Consumes: PaperMod's `baseof.html` blocks. GitHub Pages serves a single `/404.html` for every missing URL, so this one page carries both languages (the one sanctioned exception to the i18n rule).

- [ ] **Step 1: Write the 404 override**

`layouts/404.html`:

```html
{{- define "main" }}
<div class="not-found" style="text-align:center;padding:4rem 1rem;">
  <h1 style="font-size:4rem;">404</h1>
  <p><strong>Page not found.</strong> The page you're looking for doesn't exist or has moved.</p>
  <p><a href="{{ "/" | absURL }}">Go to the home page →</a></p>
  <hr style="margin:2rem auto;max-width:20rem;">
  <p lang="pt-br"><strong>Página não encontrada.</strong> A página que você procura não existe ou foi movida.</p>
  <p lang="pt-br"><a href="{{ "pt/" | absURL }}">Ir para a página inicial →</a></p>
</div>
{{- end }}
```

- [ ] **Step 2: Verify both languages render in the built 404**

```bash
hugo --minify --gc
grep -q "Page not found" public/404.html && grep -q "Página não encontrada" public/404.html && echo 404-OK
```

Expected: `404-OK`.

- [ ] **Step 3: Commit**

```bash
git add layouts/404.html
git commit -m "feat: bilingual 404 page"
```

---

### Task 9: CI/CD workflow, CNAME, and README

**Files:**
- Create: `.github/workflows/deploy.yml`
- Create: `static/CNAME`
- Create: `README.md`

**Interfaces:**
- Consumes: `scripts/check_translations.py` CLI contract (Task 3), Make targets (Task 4).
- Produces: on push to `main` — build, mirror check, link check, deploy to Pages. On PRs — same checks, no deploy.

- [ ] **Step 1: Write the CNAME file**

```bash
printf 'barrosef.com\n' > static/CNAME
```

(Hugo copies `static/CNAME` to `public/CNAME`; Pages reads it from the deployed artifact so the custom domain survives every deploy.)

- [ ] **Step 2: Write the workflow**

`.github/workflows/deploy.yml`:

```yaml
name: Build and Deploy

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: false

env:
  HUGO_VERSION: 0.148.2

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: recursive
          fetch-depth: 0

      - name: Install Hugo
        run: |
          curl -sSL "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz" | tar -xz hugo
          sudo mv hugo /usr/local/bin/hugo

      - name: Translation mirror check
        run: python3 scripts/check_translations.py content

      - name: Build
        run: hugo --minify --gc

      - name: Internal link check (blocking)
        uses: lycheeverse/lychee-action@v2
        with:
          args: --offline --no-progress --include-fragments public/
          fail: true

      - name: External link check (warn only)
        continue-on-error: true
        uses: lycheeverse/lychee-action@v2
        with:
          args: --no-progress --scheme https --scheme http public/
          fail: true

      - name: Upload site artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: ./public

  deploy:
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

- [ ] **Step 3: Write the README**

`README.md`:

```markdown
# barrosef.com

Bilingual (EN at `/`, PT at `/pt/`) Hugo blog. Theme: PaperMod (submodule —
run `git submodule update --init` after cloning). Deployed to GitHub Pages
by `.github/workflows/deploy.yml` on push to `main`.

## Writing a post (cheat sheet)

1. `make post SLUG=my-post-slug` — scaffolds the EN+PT pair.
2. Write `content/en/posts/my-post-slug.md` and `content/pt/posts/my-post-slug.md`.
3. `make serve` — live preview (drafts included) at http://localhost:1313.
4. Set `draft: false` in **both** files; `make check` to verify locally.
5. Push to `main` — live in ~1 minute. CI blocks half-translated pairs.

## Configuration knobs (`hugo.toml`)

- `params.analytics.ga4` — GA4 measurement ID (loads only after cookie consent).
- `params.newsletter.kitFormId` — Kit embed form UID (empty hides all forms).
- `params.giscus.*` — from https://giscus.app after enabling repo Discussions.

Categories: Technology/Tecnologia, Barbecue/Churrasco, Jiu-Jitsu, Liberty/Liberdade.
```

- [ ] **Step 4: Verify locally**

```bash
make check
actionlint .github/workflows/deploy.yml 2>/dev/null || python3 -c "import yaml,sys; yaml.safe_load(open('.github/workflows/deploy.yml')); print('YAML-OK')"
```

Expected: `make check` passes; `actionlint` clean if installed, otherwise `YAML-OK` (PyYAML ships with Fedora; if neither tool is present, skip — CI itself validates in Task 10).

- [ ] **Step 5: Commit**

```bash
git add .github/workflows/deploy.yml static/CNAME README.md
git commit -m "feat: CI build/check/deploy workflow, CNAME, and README cheat sheet"
```

---

### Task 10: Ship — push, enable Pages, verify deploy, update workspace

**Files:**
- Modify: GitHub repo settings via `gh` (Pages source = Actions)
- Modify: parent workspace repo submodule pointer

**Interfaces:**
- Consumes: everything. This task has no code — it is the release gate.

- [ ] **Step 1: Push and enable Pages (Actions build)**

```bash
cd /opt/wks/personal/barrosef-workspace/barrosef.com
git push origin main
gh api repos/ed-barros/barrosef.com/pages -X POST -f build_type=workflow 2>/dev/null || gh api repos/ed-barros/barrosef.com/pages -X PUT -f build_type=workflow
```

Expected: push succeeds; Pages API returns the pages object (POST for first-time enable, PUT if it already exists).

- [ ] **Step 2: Watch the workflow to completion**

```bash
gh run watch --repo ed-barros/barrosef.com --exit-status $(gh run list --repo ed-barros/barrosef.com --branch main --limit 1 --json databaseId -q '.[0].databaseId')
```

Expected: exit 0 with both `build` and `deploy` jobs green. If it fails, read the log (`gh run view --log-failed`), fix, commit, push, repeat — do not proceed until green.

- [ ] **Step 3: Set the custom domain and verify the deployed site**

```bash
gh api repos/ed-barros/barrosef.com/pages -X PUT -f cname=barrosef.com
curl -sI https://ed-barros.github.io/barrosef.com/ | head -3
```

Expected: the pages API accepts the cname. **User action required (cannot be automated):** at the domain registrar, point `barrosef.com` apex A records to `185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153` (and optionally `www` CNAME → `ed-barros.github.io`). Once DNS propagates, tick "Enforce HTTPS" in repo Settings → Pages (or `gh api repos/ed-barros/barrosef.com/pages -X PUT -F https_enforced=true`). Until then the site is live at the github.io URL — report this handoff clearly instead of blocking on it.

- [ ] **Step 4: Post-deploy smoke check**

```bash
BASE=$(gh api repos/ed-barros/barrosef.com/pages -q .html_url)
curl -s "$BASE" | grep -q "Ed Barros" && echo EN-OK
curl -s "${BASE}pt/" | grep -q "Ed Barros" && echo PT-OK
curl -s "${BASE}posts/hello-world/" | grep -q "Hello, World" && echo POST-OK
```

Expected: `EN-OK`, `PT-OK`, `POST-OK`.

- [ ] **Step 5: Update the workspace repo's submodule pointer**

```bash
cd /opt/wks/personal/barrosef-workspace
git add barrosef.com
git commit -m "chore: bump barrosef.com submodule — blog v1 shipped"
git push origin main
```

- [ ] **Step 6: Final full-suite verification**

```bash
cd /opt/wks/personal/barrosef-workspace/barrosef.com
make check && make test && echo ALL-GREEN
```

Expected: `ALL-GREEN`.

---

## Deferred configuration (post-ship, needs user accounts — not part of this plan)

Each is a one-line config change once the user provides the value:
1. **GA4**: create the GA4 property → set `params.analytics.ga4`.
2. **Kit**: create the account + form → set `params.newsletter.kitFormId` (and correct the embed `src` host in `layouts/partials/newsletter-form.html` if Kit's snippet differs).
3. **Giscus**: enable Discussions on the repo, install the giscus app, get IDs from giscus.app → fill `params.giscus.*`.
4. **DNS**: registrar A records (Task 10 Step 3) → then enforce HTTPS.
