---
description: Iteration 2 — knowledge layer (ingestion, enrichment, index, retrieval, permissions)
disable-model-invocation: true
---
Read docs/design/01-framing.md and 02-backbone.md. Do CLAUDE.md step 3 and write
docs/design/03-knowledge-layer.md: sources + change capture; parse/chunk per source type; enrichment
ontology (graph-engineering: 5-15 entity types, provenance on every fact); index design; retrieval
pipeline with permission filtering at query time; freshness target; multi-tenancy; retrieval eval plan
with metrics. For each stage: build vs buy, and why. Ask me before load-bearing choices.

Exit check (report what's missing): permission model explicit; freshness target set; retrieval metrics named.
