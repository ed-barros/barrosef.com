# Idea — the CV on the site, with a business focus

**Date:** 2026-08-21
**Status:** Registered, not designed. A conversation to have, not a task to start.
**Trigger:** the Brazilian Portuguese CV was translated to English (kept privately in `~/Documents/`, not in this repo). Reading it surfaced a gap between how the CV presents him and what the site is now positioned to claim.

## The observation worth keeping

The CV opens as a **technology list**: "Java / Angular Architect | 23 years in IT | PJe Integrations | PostgreSQL and Oracle | JBoss/WildFly | DevOps/CI-CD | Kafka | Spring Boot."

That is a practitioner's framing, and it puts him in a keyword contest he does not need to enter. Someone screening on "Spring Boot" is not the audience this site was built for.

What the CV actually contains, once read properly, is much less common:

- **Ten years inside Brazil's justice sector**, including two Ministério Público offices — advising a Strategic IT Committee (CETI) on technology planning, running public procurement end to end, and aligning technology with executive leadership. That is governance and institutional navigation, not implementation.
- **Integration across institutions**, connecting Ministério Público systems to PJe and exchanging data with the judiciary across several states — the hard part of which is organisational, not technical.
- **Regulated and mission-critical breadth**: justice, public security, public finance, electricity, then financial services and crypto-asset exchanges at BEE4.
- **Building the team, then handing it over**: at Sogni Sports he designed the architecture, ran the hiring that formed the team, and is leading a structured handover — which is a leadership arc, not a delivery ticket.

The business-focused version of this CV leads with **the ability to operate between technology and institutions in environments where being wrong is expensive**, and treats the stack as evidence rather than as the headline.

## Why this matters to the site specifically

The site (`docs/superpowers/specs/2026-08-19-barrosef-com-professional-site-design.md`) was deliberately built so the owner's facts live in `hugo.toml` under `params.profile`, with every dependent homepage block rendering only when populated. **Those fields are currently all empty, which is the single biggest thing holding the site back** — a visitor learns his name and that he works in technology leadership, and little else.

The CV supplies exactly what is missing: current role and company, prior roles, years in the field, and the material for the track-record figures. Filling them is a config edit.

The default hero headline is currently the generic *"I build engineering organisations that ship."* The CV suggests something more specific and more defensible is available.

## Open questions for that conversation

1. **Is he job-seeking?** The CV says he is transitioning out of Sogni Sports. If so, the site's recruiter framing is timely and the CV page matters more, not less.
2. **A CV page, or a rewritten About?** A dedicated `/cv/` (mirrored `/pt/curriculo/`) is conventional and skimmable; folding it into About keeps the site smaller. Both need a decision, not a default.
3. **Downloadable PDF, or web only?** A PDF is what recruiters ask for; a web page is what search engines read. Probably both, generated from one source so they cannot drift.
4. **How much of the justice-sector detail is an asset versus a niche?** It is genuinely distinctive, and it is also very Brazil-specific — worth deciding whether the English site leads with it or contextualises it.
5. **Bilingual reality.** A CV page must exist in both languages under the site's mirror rule, and the Portuguese version is the one that can name institutions without explanation.

## What exists now

- Original: `~/Documents/curriculo -arch.pdf` (pt-BR)
- Translation: `~/Documents/curriculo-arch-EN.md` and `.pdf` — Brazilian institutional names kept in the original with a gloss, because Ministério Público, PJe and the CNJ Judiciary Targets have no accurate English equivalent

Both are kept **outside this public repository** deliberately; they carry personal contact details that should not be published without a decision to publish them.
