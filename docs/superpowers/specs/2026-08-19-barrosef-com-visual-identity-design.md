# barrosef.com — Visual Identity Design Spec

**Date:** 2026-08-19
**Status:** Approved in brainstorming; pending final spec review
**Sub-project:** 2 of the barrosef.com personal platform (blog v1 → **visual identity** → content strategy → Digital Marketing Hub)
**Supersedes:** the "Custom theme/visual identity (later project)" line in `2026-08-18-barrosef-com-blog-design.md` §Out of Scope

## Purpose

Give barrosef.com a personal visual identity in place of stock PaperMod. The brief, in the owner's words: *unusual and distinctive; modern yet rustic; conservative yet free; conveying confidence and a liberating style; very personal.* "Free" means respect for individual liberty, not the visual idiom of progressive/startup design.

Translated into design terms: **restraint as confidence.** No gradients, no rounded bubbly sans, no playful shapes, no multi-color accent system. Structure, real typography, and materials with weight.

**Success criteria:** a returning reader recognizes the site before reading a word; the same chrome sits comfortably above a post on distributed systems, one on brisket, one on armbars, and one on individual liberty; nothing about it reads as a template; and it introduces no third-party requests.

## Decisions Made

| Decision | Choice | Rationale |
|---|---|---|
| Material world | **Leather & field notes** — aged paper, saddle tan, sepia ink | Most personal of the options considered; a craftsman's working notebook |
| Intensity | **Trace** — palette and type carry it; one handwritten element; CSS grain only, no texture images | The "modern" half of *modern yet rustic*; avoids themed-restaurant kitsch, which is the failure mode of this direction |
| Structural spine | **Margin rail** — asymmetric grid, metadata in a notebook margin | Distinctiveness by shape rather than ornament; costs no bytes; works with or without photography |
| Dark mode | **Lamplight** — dark walnut and cream, never grey or pure black | Identity survives after sundown; ~⅓ of readers force dark mode |
| Typography | **EB Garamond throughout**, small caps in the rail, no display face | Owner chose the most conservative option: ages well, matches "conservative when it comes to myself" |
| Per-pillar color/icons | **None** | Four accent colors would read as a filing taxonomy, not one person's notebook — the fastest route back to templated |
| Font delivery | **Self-hosted, subset** | Preserves the site's zero-third-party-request property; Google Fonts would silently undo it |
| Logotype | **Owner's real signature**, vectorized | The entire "hand" budget at Trace intensity; unfakeably personal; also yields the monogram |

**Rejected alternatives** (recorded so they are not relitigated): *Printed page*, *Forge & ember*, *Stone & frontier* material worlds; *Tactile* and *Full caderno* intensities; *Type specimen* and *Image-forward* spines; *Oficina* (Vollkorn + mono rail) and *Caderno* (Fraunces display) typographic directions.

**Standing risk to design against:** EB Garamond on warm paper is a familiar combination. Distinctiveness must be carried by the margin rail, the lamplight palette, and genuine OpenType usage. An implementation that loads Garamond without enabling its features has missed the point of this spec.

## Design Foundations

### Palette

Warm on both sides. Never grey, never `#000`, never `#fff`.

| Role | Day | Lamplight |
|---|---|---|
| Ground | `#f4ece0` paper | `#1c1714` walnut |
| Raised surface | `#faf5ec` | `#241d19` |
| Text | `#2f2a24` ink | `#e8ddcb` cream |
| Muted (rail, captions) | `#6b6157` | `#a2957f` |
| Rules / borders | `#ddd0bd` | `#3a2f27` |
| Accent (links) | `#7c4a24` saddle | `#c98a4b` amber |

These map onto PaperMod's existing CSS variables (`--theme`, `--entry`, `--primary`, `--secondary`, `--tertiary`, `--content`, `--border`, `--code-bg`, `--code-block-bg`) so the theme's own components inherit the palette without being individually restyled.

Every foreground/background pair must meet **WCAG AA** (4.5:1 body, 3:1 large text and UI). The saddle accent on paper is expected to need darkening for small text; darken it rather than ship a failing pair. Contrast failures block.

### Typography

- **EB Garamond** (SIL OFL) for everything, self-hosted from `assets/fonts/`, `font-display: swap`, roman preloaded.
- Weights subset: **400 roman, 400 italic, 600 semibold**. Nothing else. If a variable build covers this range in one file at lower total weight, prefer it.
- **True small caps must be verified at implementation.** If the obtained EB Garamond build lacks a working `smcp` feature, the correct fix is a dedicated small-caps font file — never browser-synthesized caps via `font-variant: small-caps` fallback, which produces scaled-down capitals with wrong stroke weights and would undermine the one place this design shows craft.
- Body **20px / 1.65** line height. Garamond is optically small; conventional 16px settings make it feeble.
- Prose measure **660px** (roughly 70 characters).
- **OpenType features enabled deliberately** — this is where the design earns its distinctiveness:
  - `font-feature-settings` / `font-variant-numeric: oldstyle-nums` — old-style figures in prose and rail, so dates sit on the baseline instead of standing up like a spreadsheet.
  - `font-variant-caps: small-caps` using the face's **true small caps**, never browser-synthesized capitals.
  - Real italics for emphasis and Portuguese titles.
- **Lamplight weight compensation:** Garamond's 400 weight goes thin and gauzy on a dark ground. Dark mode sets body text to **weight 500** (or the nearest available step) and **+0.01em letter-spacing** so night reading matches day density. Values are a starting point to be tuned during visual review, not a guess to ship unexamined.
- Monospace appears **only inside code blocks**, via the system monospace stack. No third webfont.

## Layout: The Margin Rail

A two-column grid separated by a hairline vertical rule, tinted saddle rather than grey — the notebook's margin line, and the only ornament in the design. Rail contents are right-aligned so they hug the rule.

| Breakpoint | Rail | ToC | Notes |
|---|---|---|---|
| ≥1024px | 180px, full | In rail, sticky on scroll | Prose column 660px |
| 768–1023px | Narrowed | Hidden | Metadata only |
| <768px | Folded above title as one small-caps line (category · date · reading time) | Hidden | Signature moves into header |

**Rail contents (post pages):** category (small caps), date (old-style figures), reading time, language switcher, and — at ≥1024px — the table of contents, sticky, so the section list sits in the margin where a reader would pencil it rather than in a collapsed box above the article. This is the rail earning its keep functionally, not just visually.

On list, taxonomy, and fixed pages the rail may be sparse or empty; the asymmetry persists regardless, because the shape is the identity.

## Components

- **Header:** signature logotype left, navigation in small caps right, hairline rule beneath.
- **Post list:** PaperMod's default card grid (rounded corners, shadows) is **removed** — it is precisely the templated look this project exists to escape. Replaced by a flat list: title, one line of rail metadata, summary, separated by hairline rules.
- **Global:** no rounded corners, no box shadows, no cards anywhere on the site (`--radius: 0`).
- **Post single:** title, rail metadata, prose, then the existing post-footer partials (newsletter form, giscus) restyled onto the palette.
- **Pull quotes:** hanging punctuation, saddle rule, no background fill.
- **Code blocks:** warm tinted surface — `#ece0cd` by day, `#141110` at night — with a **custom Chroma syntax scheme derived from the palette tokens** (saddle, amber, muted, ink) rather than a stock dark editor theme, set in the system monospace stack. A dark editor slab on warm paper reads as a foreign object.
- **Images:** full width of the prose column; captions in small caps italic, muted.
- **Taxonomy, search, 404, newsletter landing:** inherit tokens; pillar names in small caps. The bilingual 404 keeps both languages.

## Identity Assets

- **Signature logotype.** Owner supplies a photograph or scan of a real signature (unlined white paper, fine felt-tip or fountain pen — ballpoint traces poorly). Vectorized to a **single-path SVG** inlined in the header with `fill: currentColor`, so it renders ink-on-paper by day and cream-on-walnut at night from one asset. Requires a text alternative for assistive technology. Fallback if never supplied: the name set in EB Garamond italic.
- **Monogram and favicons.** Derived from the signature. Produces exactly the five files PaperMod references and the site currently 404s on every page: `favicon.ico`, `favicon-16x16.png`, `favicon-32x32.png`, `apple-touch-icon.png`, `safari-pinned-tab.svg`. This closes a known open item and unblocks the deferred lychee `--remap` link-checking upgrade, whose only blocker was those missing files.
- **Social card.** One static 1200×630 default (paper ground, signature, the four pillar words in small caps) so links stop unfurling bare. Posts with a `cover` still use it.

## Implementation Architecture

- All styling in **`assets/css/extended/`**, which PaperMod appends last — no `!important` fights, no theme fork. Four focused files: `01-tokens.css`, `02-typography.css`, `03-layout.css`, `04-components.css`.
- Fonts in `assets/fonts/`, subset woff2.
- **Layout overrides only where structure must change** — header, post metadata/rail wrapper, list item, ToC placement. PaperMod's actual partial paths must be inspected at implementation time (this version uses `layouts/_partials/`).
- `hugo.toml`: keep `defaultTheme = "auto"`, enable ToC, point favicon params at the new assets.
- **`themes/` is never edited.** Upstream updates keep working; the door to a fully custom theme stays open.

## Verification

1. `make check` and CI stay green throughout; no change to the deploy pipeline.
2. **Contrast:** every token pair verified against WCAG AA. Failures block.
3. **Portuguese subsetting:** the font subset must retain `ã õ ç á é í ó ú â ê ô à` and render them correctly in small caps and old-style figures. A subset validated only against English silently breaks half the site — the single most likely failure mode of this work.
4. **No third-party requests:** assert the built HTML contains no reference to `fonts.googleapis.com` or `fonts.gstatic.com`.
5. **Font budget:** ≤120KB total woff2.
6. **Favicons:** all five files exist and return 200.
7. **Visual review by the owner** at three widths in both palettes via `make serve`, then iterate. Text and mockups cannot validate typography or color; the running site is the acceptance test.

## Out of Scope

- Per-post generated OG images (one static card only)
- Per-pillar iconography or color coding
- Animation and transitions beyond browser defaults
- Custom illustration
- A design-token export for the future Digital Marketing Hub
- Replacing PaperMod outright — this layers on top of it

## Dependency

The signature image from the owner. Everything else can proceed without it; the logotype, monogram, favicons, and social card are the only tasks that block on it, and each falls back to EB Garamond italic if it never arrives.
