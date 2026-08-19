# barrosef.com — Bilingual Blog Design Spec

**Date:** 2026-08-18
**Status:** Approved (2026-08-18)
**Sub-project:** 1 of the barrosef.com personal platform (blog → content strategy → Digital Marketing Hub → derived products)

## Purpose

Personal blog for Ed Barros at `barrosef.com`, covering technology, barbecue, jiu-jitsu, and libertarian ideas. It is the anchor of a larger content ecosystem: posts feed LinkedIn (tech/business, EN) and Instagram/TikTok (BBQ, jiu-jitsu, liberty, PT), and the site is deliberately structured so a future Digital Marketing Hub can consume its content as structured assets.

**Success criteria:** site live at barrosef.com with $0 hosting cost; writing a bilingual post takes one command to scaffold and one push to publish; CI prevents a half-translated or broken post from shipping.

## Decisions Made

| Decision | Choice | Rationale |
|---|---|---|
| Order of sub-projects | Blog first | Ships in days; generates the real content and workflow data the hub design needs |
| Languages | Bilingual, full mirror | Every post exists in PT and EN, linked as a translation pair |
| Default language | **English at root** (`/`), Portuguese at `/pt/` | User choice |
| Stack | **Hugo** + PaperMod theme | Only major SSG with native multilingual support; Markdown workflow; no runtime toolchain |
| Hosting | GitHub Pages via GitHub Actions | $0, custom domain + HTTPS, content stays portable Markdown (no lock-in) |
| Analytics | Google Analytics 4 + consent banner | Integrates with Google Ads and the future hub's reporting APIs; LGPD/GDPR consent required |
| Newsletter | Kit (ConvertKit) free tier | Free to 10k subscribers, embeddable forms, full CSV export (no lock-in) |
| Comments | Giscus (GitHub Discussions) | Free, no ads/tracking, data in own repo. Known trade-off: requires GitHub account — acceptable for v1, swappable later |
| Sharing | OG/Twitter Card meta from front matter; plain share links; IG/TikTok embed shortcodes | Proper unfurls on LinkedIn/WhatsApp/X without tracking scripts |

## Architecture

Single GitHub repository containing the Hugo site.

```
barrosef.com/
├── hugo.toml                 # site config: languages en (default, root) + pt (/pt/)
├── content/
│   ├── en/
│   │   ├── posts/…           # one file per post
│   │   ├── about.md
│   │   └── newsletter.md
│   └── pt/
│       ├── posts/…
│       ├── sobre.md
│       └── newsletter.md
├── archetypes/               # templates for `hugo new` (both languages)
├── assets/ | static/         # images, CNAME, custom CSS
├── layouts/                  # overrides on top of PaperMod (partials: analytics+consent, giscus, newsletter form, embed shortcodes)
├── themes/PaperMod           # git submodule
├── scripts/check-translations.*  # mirror-completeness check
└── .github/workflows/deploy.yml  # CI + Pages deploy
```

**Deployment:** push to `main` → GitHub Actions runs build + checks → publishes to GitHub Pages. `barrosef.com` CNAME → Pages, HTTPS enforced. Failed CI leaves the previous version live.

**Theme:** PaperMod as base, customized (colors/branding) via overrides, never forked edits. A fully custom design is a possible later project.

## Content Model

Four categories, each a browsable section with per-language RSS:

| EN | PT |
|---|---|
| Technology | Tecnologia |
| Barbecue | Churrasco |
| Jiu-Jitsu | Jiu-Jitsu |
| Liberty | Liberdade |

Free-form tags for specifics. Fixed pages mirrored in both languages: About/Sobre, Newsletter.

**Post front matter (hub-ready):** `title`, `date`, `categories`, `tags`, `translationKey` (links the PT/EN pair; drives the language switcher), `summary`/`description` (feeds OG cards + SEO), optional `cover` image, `draft`. Structured so the future hub can parse the repo and treat each post as a content asset without rework.

Editorial stance: the site chrome stays neutral; arguments (data-grounded, per the project's principles) live in the posts.

## Features (v1)

- **GA4** loaded only after cookie-consent acceptance (LGPD/GDPR); measurement ID in site config.
- **Kit newsletter**: embedded signup form partial on every post footer + dedicated landing page per language.
- **Giscus** comments partial on posts, mapped to GitHub Discussions in the site repo.
- **Social**: OG + Twitter Card meta generated from front matter; static share links (no JS trackers); Hugo shortcodes wrapping official Instagram and TikTok embeds (embeds load third-party scripts only on pages that use them).
- **Bilingual 404 page.**

## Testing / CI

On every push, before deploy:
1. `hugo --minify` — fails on template/front-matter errors.
2. **Translation mirror check** — script asserts every non-draft post's `translationKey` exists in both `content/en` and `content/pt`; CI fails otherwise.
3. **lychee** link checker over the built site (internal + external links; external failures warn, internal failures block).

Drafts (`draft: true`) never build. Local preview via `hugo server`.

## Writing Workflow

1. One command (make target or small script wrapping `hugo new`) scaffolds the EN+PT file pair with matching `translationKey` and pre-filled front matter.
2. Write both versions; `hugo server -D` for live preview.
3. Push to `main` → live in ~1 minute.
4. README carries a 5-line cheat sheet of this workflow.

## Out of Scope (v1)

- Custom theme/visual identity (later project)
- Content strategy & editorial calendar (next sub-project)
- Digital Marketing Hub and any ads/CRM integration (separate project; this design only guarantees hub-parseable front matter)
- Comment system replacement for non-GitHub audiences
- Search beyond PaperMod's built-in fuzzy search
