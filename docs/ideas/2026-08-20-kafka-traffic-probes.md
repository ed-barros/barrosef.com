# Parked idea — Polyglot Kafka pipeline: buses as traffic probes

**Date:** 2026-08-20
**Status:** **PARKED before implementation.** Design settled through brainstorming; no code, no repo, no spec file, no cloud account created. Nothing to undo.
**Why parked:** the owner chose to start with smaller, simpler articles first. This is a multi-week build; it was the *first* article idea and too large for that slot.

## What it was

A working polyglot streaming pipeline, built to be written about: a Go producer, a Java Kafka Streams transformer, and a Python consumer, computing something genuinely useful from free public data.

**The use case:** treat public buses as a city-wide sensor network and derive a live road-congestion map from their movement — a free traffic map built entirely from open transit data.

**Why it passes the "why Kafka at all" test:** the raw feed gives position and timestamp, nothing more. Speed does not exist in the feed; it only exists as a function of a vehicle's *previous* position, which requires per-vehicle state. Congestion then requires windowed aggregation across many vehicles per place. Neither is obtainable from a single API call, so the streaming machinery is load-bearing rather than decorative. This test is the thing to preserve if the idea is ever revived — an article whose pipeline could be replaced by a cron job deserves the criticism it would get.

## Decisions settled

| Decision | Choice | Reasoning |
|---|---|---|
| Deliverable | The article; the system is its subject | |
| Lifecycle | Build → capture real numbers → `terraform destroy` | Keeps everything inside Confluent's trial credit; no always-on cost |
| Java component | Kafka Streams as its own service | **You cannot deploy a JAR into managed Confluent Cloud.** The original "Java deployed inside Kafka" framing is not possible. Alternatives were managed Flink (genuinely in-platform, Confluent-specific) or ksqlDB |
| Data source | SPTrans Olho Vivo *and* generic GTFS-Realtime, behind one Go adapter interface | São Paulo's ~14k-bus fleet gives the probe density the use case needs; the keyless GTFS-RT path lets readers reproduce it with no signup |
| Spatial aggregation | H3 hex cells at resolution 9 (~174 m), split by bearing octant | Avoids map-matching entirely. H3 has first-class Go, Java and Python libraries producing an identical index — which directly serves the polyglot thesis |
| Contract | Avro + Confluent Schema Registry | The genuinely hard part of three languages is agreeing on a contract across three type systems. This *is* the article's spine: "three languages, one schema, and what breaks when it evolves" |
| Decomposition | A: monorepo + local pipeline · B: cloud infra + deploy · C: bilingual article | A burns no credit — build it entirely offline first, since the 30-day clock starts at account creation |

## Architecture as designed

Go producer polls its source, normalises, and produces to `vehicle.positions.v1` **keyed by vehicle ID** — keyed that way deliberately, so each vehicle's history lands on one partition; the next stage cannot work otherwise.

Java Streams keeps last-position-per-vehicle in a state store, derives speed and bearing from successive positions, **discards implausible readings** (GPS jitter, teleports, gaps too long to interpolate — raw transit feeds are noisy and an unfiltered congestion map is worthless), buckets survivors into an H3 cell plus bearing octant, and aggregates a five-minute window into median speed and sample count. Emits `congestion.cells.v1`.

Python consumer holds the current picture in memory and serves GeoJSON to a MapLibre page drawing the hexes. No database — it is a live view, and storage would be scope with no purpose.

## Honest caveats recorded at design time

- **A hex is not a road.** A resolution-9 cell can contain both a fast avenue and a slow side street, and blends them. Small cells plus bearing splitting mitigate it. The article must say so plainly rather than let a reader discover it.
- **The baseline is the weak point.** "Congestion" needs a reference speed per cell. The design computes it from the run's own observed distribution (~85th percentile) and labels it *observed-during-run*, not historical truth. The map only becomes credible after roughly 24–48 hours of continuous running, so this is not a one-hour demo.
- **Map-matching to real OSM roads was rejected deliberately.** It is the most accurate option and it would have become the project — the article would end up about map-matching rather than about polyglot streaming.

## Verified facts (checked 2026-08-19, re-verify before reviving)

- **Confluent Cloud:** $400 credit for 30 days on new accounts. Basic clusters carry no fixed monthly fee but bill on throughput, storage and partitions — near-zero only when near-idle. "Free forever" is not accurate for a pipeline carrying real traffic. https://www.confluent.io/confluent-cloud/pricing/
- **Cloud Run is request-driven and scales to zero**, which fits Kafka consumers badly: keeping one alive needs `min-instances=1`, which bills continuously and exceeds the free allowance. This is why the build-then-destroy lifecycle was chosen over keeping it running.
- **Mobility Database:** 6,000+ GTFS, GTFS-RT and GBFS feeds across 99 countries, free, many keyless. https://mobilitydatabase.org/
- **SPTrans Olho Vivo:** free token after registration; real-time positions for every São Paulo bus line. https://www.sptrans.com.br/desenvolvedores/

## Testing approach (worth keeping)

`TopologyTestDriver` for the Streams logic — speed derivation, noise filtering, H3 bucketing and windowing all tested with no broker, in milliseconds. Go adapters tested against **recorded fixtures, never the live API**, so the suite runs offline and in CI indefinitely. One `make e2e` target replaying a recorded position stream through compose and asserting congestion cells emerge.

## If reviving

Re-verify the pricing and both feeds first, then resume at sub-project A. The design above is complete enough to go straight to a spec.
