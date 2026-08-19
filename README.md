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

Run `make test` to exercise the translation checker's own test suite.

## Configuration knobs (`hugo.toml`)

- `params.analytics.ga4` — GA4 measurement ID (loads only after cookie consent).
- `params.newsletter.kitFormId` — Kit embed form UID (empty hides all forms).
- `params.giscus.*` — from https://giscus.app after enabling repo Discussions.

Categories: Technology/Tecnologia, Barbecue/Churrasco, Jiu-Jitsu, Liberty/Liberdade.
