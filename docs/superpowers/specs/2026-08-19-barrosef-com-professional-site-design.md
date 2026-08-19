# barrosef.com — Professional Authority Site Design Spec

**Date:** 2026-08-19
**Status:** Approved (owner authorised autonomous execution through deploy)
**Sub-project:** 3 of the barrosef.com platform
**Supersedes:** `2026-08-19-barrosef-com-visual-identity-design.md` in full. That identity (leather/field-notes palette, EB Garamond, margin rail) shipped and was rejected by the owner as reading amateurish; it is removed by this work, not extended.

## Why the previous design failed

Recorded so it is not repeated. The first identity was chosen by asking about *materials and mood* before asking what the site is **for**. Those questions can only produce an aesthetic, and the one they produced optimised for *distinctive* at the expense of *credible*. Three things made it read amateurish, and only one was colour:

1. **No structure.** The homepage was a greeting plus a post list — the default shape of a hobby blog.
2. **No substance.** One placeholder post. Emptiness reads as amateur regardless of styling.
3. **Register mismatch.** Warm cream, saddle brown and Garamond is the language of a personal essay collection, not of someone trusted with a technology organisation.

The lesson encoded in this spec: **purpose and audience first, aesthetics second.**

## Purpose

barrosef.com is a **professional authority site** for Ed Barros. The homepage is about him, not about the feed — which is also what lets it look complete while few posts exist.

**Audience:** recruiters and executives. **Goal:** they approach him. **Register:** formal, restrained, credential-forward, technically fluent.

**Success criteria:** a recruiter landing cold understands within seconds what he does, at what level, and how to reach him; the site looks finished with three posts; and nothing about it reads as a template or a hobby blog.

## Decisions Made

| Decision | Choice | Rationale |
|---|---|---|
| What the site is | Professional authority site; blog is a section | Survives having few posts — the homepage is about him |
| Audience | Recruiters and executives | Owner's choice; drives register and hierarchy |
| Visual direction | **"Modern Systems"** — dark navy ground, IBM Plex, white reading surfaces | Owner picked it from three rendered prototypes; signals engineer rather than ex-engineer manager |
| Four pillars | **All four, clearly ranked** — Technology dominant, Liberty second, Barbecue and Jiu-Jitsu in a Personal section | Keeps the whole person and the existing social-content strategy without cluttering the front door |
| Languages | **Full EN/PT mirror retained**, CI-enforced | Owner's choice; unchanged from the original blog spec |
| Theme | **PaperMod removed**; own Hugo templates | We would be overriding its homepage, list, nav, footer and card aesthetic — at that point the theme costs more than it gives, and its CSS specificity was the source of most identity bugs |
| Light/dark toggle | **None.** One deliberate appearance: navy chrome, white reading surfaces | The design already uses both purposefully; a toggle means maintaining two palettes and was where most prior bugs originated |
| Owner's facts | **Config-driven, block renders only when filled** | The site can ship before the bio exists, is never broken, and never shows a placeholder to a visitor |
| Site search | **Removed** | PaperMod-provided; unnecessary at this size (YAGNI) |

## Structure

Five page types, fully mirrored. Portuguese paths are localised.

| English | Portuguese | Purpose |
|---|---|---|
| `/` | `/pt/` | Authority homepage |
| `/writing/` | `/pt/artigos/` | Writing index, grouped by pillar |
| `/writing/<slug>/` | `/pt/artigos/<slug>/` | Post pages |
| `/about/` | `/pt/sobre/` | Full background |
| `/contact/` | `/pt/contato/` | How to reach him |
| `/newsletter/` | `/pt/newsletter/` | Retained from the blog build, restyled |
| `/404.html` | — | Bilingual, single page (GitHub Pages serves one) |

Posts move from `/posts/` to `/writing/`. Done now while exactly one post exists and no inbound links break.

**Homepage anatomy**, top to bottom: header (name, nav, language switch) · positioning headline and one-sentence summary with two calls to action · track-record figures · three practice areas · featured writing · one line acknowledging life outside work, linking onward · footer with contact and social links.

**Writing index:** Technology section first, Liberty second, then a visually subordinate Personal section carrying Barbecue and Jiu-Jitsu.

## Config-Driven Facts

The owner's professional facts live in `hugo.toml` under `params.profile`, and **each homepage block renders only when its values are non-empty**. An unfilled field means the block is absent, never a bracket on screen.

| Param | Feeds |
|---|---|
| `currentRole`, `company`, `location` | Hero summary line |
| `priorRoles` | Hero summary line |
| `positioning` | Hero headline override (falls back to a default) |
| `metrics` (list of `{value, label}`) | Track-record band — the whole band hides when the list is empty |
| `email` | Contact page and footer |

Practice-area copy is authored content, not config.

## Design System

### Palette

Fixed appearance; no user-facing theme switch.

| Role | Value |
|---|---|
| Ground | `#0b1622` |
| Panel | `#111f30` |
| Hairline / border | `#1b2b3d` |
| Text on ground | `#dce6f2` |
| Muted on ground | `#9db3cc` |
| Dim on ground | `#6e8299` |
| Accent | `#5b8fd6` |
| Reading surface | `#ffffff` |
| Text on white | `#16233a` |
| Muted on white | `#5d6b7d` |
| Link on white | `#1d4e89` |

Every foreground/background pair must meet **WCAG AA** (4.5:1 body, 3:1 large text and UI). Failures block; darken or lighten the token rather than shipping a failing pair. The accent on ground and the dim-on-ground pair are the two expected to need checking.

### Typography

- **IBM Plex Sans** (400/500/600) for everything; **IBM Plex Mono** (400/500) for figures, labels and eyebrow text. Both SIL OFL.
- **Self-hosted and subset** from `static/fonts/`, published to `/fonts/`. No request may reach `fonts.googleapis.com` or `fonts.gstatic.com` — the site's zero-third-party-request property is a hard constraint, and a redesign is exactly when it gets lost by accident.
- The SIL OFL requires the license to travel with redistributed binaries: ship `static/fonts/OFL.txt`.
- Budget: **≤140KB** total woff2 across both families.
- **Portuguese coverage is a blocking check.** The subset must retain `ã õ ç á é í ó ú â ê ô à` and render them correctly. A subset validated only in English silently breaks half the site — this is the single most likely failure mode of the work.
- Body 17px/1.65 on white reading surfaces; headline scale per the approved prototype (58px hero, tightened tracking at large sizes).

### Components

- **No rounded corners, no drop shadows.** Structure comes from hairline borders and panels.
- Buttons: solid accent for the primary action, hairline-bordered for the secondary. One primary action per page.
- Track-record figures in IBM Plex Mono, separated by vertical hairlines.
- Practice areas: panels on the ground colour with a 2px accent top border.
- Writing entries: category eyebrow in mono, title, one-line summary. No cards.
- Code blocks: light surface with a palette-derived syntax scheme, set in the system monospace stack. **Hugo's `noClasses` default emits inline Monokai and makes every custom syntax rule dead CSS — `[markup.highlight] noClasses = false` is required.**
- Post pages: single readable column on white, no margin rail.

## Templates

PaperMod is removed as a submodule. We author a small template set:

`baseof.html` · `home.html` · `list.html` (writing index) · `single.html` (post) · `page.html` (about, contact, newsletter) · `404.html` · `taxonomy.html` / `terms.html`, plus partials for head/meta, header, footer, language switcher, social icons, and the retained analytics-consent, newsletter-form, comments and embed partials.

Hugo's built-in RSS and sitemap templates are used. The `JSON` home output (PaperMod's search index) is dropped.

## What Is Removed and What Is Kept

**Removed:** the `themes/PaperMod` submodule; EB Garamond and its OFL; all four `assets/css/extended/*.css` files; the `layouts/single.html` margin-rail override; the saddle monogram favicons and social card; the notebook palette params; `TocOpen`, `ShowToc` and PaperMod-specific params; the search page and JSON output.

**Kept untouched:** Hugo and its version pin; the bilingual configuration and content model; `translationKey` front matter; `scripts/check_translations.py` and its test suite; the Makefile workflow; the CI pipeline and Pages deploy; `static/CNAME` and the custom domain; the consent-gated GA4 loader; the Kit newsletter form; Giscus comments; the Instagram and TikTok shortcodes.

## Content

Existing post content and front matter are preserved. New content required: **Contact** pages in both languages, and a rewritten **About** in both languages in the professional register. Practice-area copy is authored in templates or page content, not invented as biography — anything that asserts a fact about the owner's history must come from `params.profile` or from content he supplies.

## Verification

1. `make check` and `make test` stay green; CI unchanged and passing.
2. **Contrast:** every token pair verified against WCAG AA. Failures block.
3. **Portuguese subsetting:** diacritic coverage verified against the actual font files.
4. **No third-party requests:** built HTML contains no reference to Google's font hosts.
5. **Config-driven blocks:** verified in both states — with `params.profile` populated and with it empty. Empty must render a clean page with those blocks absent, never a bracket or an orphaned heading.
6. **Rendered verification, not source reading.** Both critical bugs in the previous identity were invisible to reading the CSS and only appeared in a browser. Dark/light surface rendering, code-block contrast and the responsive layout are verified from rendered output.
7. Both languages checked at desktop, tablet and phone widths.

## Out of Scope

- The owner's biography, metrics and contact address (config, supplied by him)
- A CV or résumé page
- Case studies or a portfolio section
- Per-post generated social images (one static card only)
- Light/dark theme switching
- Site search
- The Digital Marketing Hub and any CRM or ads integration
