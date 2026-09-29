# Design workbench — system design challenge

I'm the architect. You're my sparring partner: I make the calls, you pressure-test them.
Label every number as given, measured, or assumed. No choice without the trade-off it costs.

## Who we're designing for (fill this in before the brief lands)
- The organisation: what they do, how their engagements run (phases, timelines), what they believe
  about delivery. Use their public material and note the source and date.
- Reference cases to mirror in scope and pacing: 2-3 of their past projects, each with what was built,
  the stack, and how long the proof of concept and the MVP took.

## Default stack — deviate only with a stated reason
Replace with the target team's stack (their job postings are a good source). This one is an example.
- Languages: TypeScript/Node, Python, Java/JVM, Golang.
- Data: PostgreSQL, ClickHouse, Redis, Airflow, ElasticSearch. Messaging/workflows: Kafka, Temporal/Camunda.
- Cloud: AWS, Azure, Kubernetes (on-prem). Infra: Docker, GitHub Actions, Terraform.
- Model access in client estates: OpenRouter, Azure OpenAI, AWS Bedrock, or direct APIs. Before relying on a Claude
  feature, invoke the `claude-api` skill and use its platform-availability table (e.g. Managed Agents,
  MCP connector, programmatic tool calling, Batches and inference_geo are not on Bedrock).
- Starting positions to challenge, not answers: pgvector + Postgres full-text before a dedicated
  vector/search engine; Temporal/Camunda for long-running and human-in-the-loop agent workflows; Kafka for
  ingestion/change events; ClickHouse for traces, eval results, usage/cost analytics; Redis for cache/rate limits.

## Rules
- Use skills through the Skill tool, never by finding and reading their files under ~/.claude.
  If a skill you need isn't in your list, stop and tell me.
- Never drop or swap a default-stack component silently: propose it as a decision with its cost and wait for me.
- For any pilot or MVP, state the minimal stack first, then what gets added at scale and what triggers it.
- The shell is zsh: quote globs (`--include='*.md'`).

## Writing style for design files
Reader: a principal engineer with 2 minutes per file. I must be able to explain every file out loud.
- Every file in docs/design/ opens with a summary block: 3-5 plain sentences on what this part does
  and why, one diagram, and a decisions table
  (decision | choice | why | what it costs). Then a `## Details` heading; everything else goes below it.
- The summary block must make sense on its own. Plain words, sentences under 25 words, spell out an
  acronym the first time. When a skill brings its own document template, its sections go under Details.
- Every diagram is drawn with the `diagram-design` skill (via `/diagrams`), never Mermaid. Source HTML in
  docs/design/diagrams/<doc-prefix>-<slug>.html (e.g. 03-ontology.html, adr-002.html; context, flow and
  delivery keep their names), exported to PNG by `node scripts/export-diagram.mjs`, embedded as
  `![alt that says what it shows](diagrams/<name>.png)`. When a file's content changes, redraw its diagram.
- The /iter-* prompts and the skills list what to consider, not headings to fill. If an item doesn't
  matter for this brief, give it one line or leave it out. Never paste a skill's checklist into a file.
- End every iteration by updating docs/design/README.md (the one-page overview below), then reply in
  chat with at most 5 bullets: what changed, decisions waiting for me, open questions.

### Overview template: docs/design/README.md, one page at most
1. The system in one sentence.
2. Context diagram: users, the system, external systems (at most 8 nodes), as its PNG:
   `![System context](diagrams/context.png)`.
3. Main components: component | what it does | runs on (at most 8 rows).
4. How a request flows: at most 6 numbered steps.
5. Key decisions: decision | choice | main trade-off (at most 5 rows, link the ADRs).
6. Open questions (at most 3).

## Workflow once the brief (brief.md) is in
Run every step inline in this session, so you can ask me before load-bearing choices. Don't delegate
design steps to the `system-design-orchestrator` agent: a subagent can't ask me anything mid-run.
1. **Frame**: invoke `system-design-skills:requirements-scoping` and `architectural-characteristics`.
   Functional reqs, NFRs (latency, scale, cost, EU data residency, compliance), stakeholders, what's
   implicitly asked. Log assumptions + questions for the stakeholders.
2. **Backbone**: invoke `system-design-skills:system-design` first (the method and building-block index),
   then `back-of-the-envelope`, `api-design`, and each building-block skill as its concern comes up
   (`data-storage`, `messaging-streaming`, `caching`, `consistency-coordination`, `resilience-failure`, …).
   Invoke skills, don't paraphrase them. Finish with `architecture-diagram` for the content and the skill's
   quality-bar score; draw the picture with `diagram-design`.
3. **Knowledge layer** (most briefs here have one): sources/connectors → change capture (webhooks/CDC → Kafka)
   → parse & chunk (structure-aware; code via tree-sitter/AST) → enrich (ontology, entity/relation extraction,
   entity resolution, provenance: `graph-engineering`) → index (hybrid lexical + dense, contextual retrieval)
   → retrieve (query rewriting, rerank, permission filtering at query time) → serve as MCP tools.
   Plus: freshness/incremental re-index, multi-tenancy, memory (session vs long-term: `memory-systems`),
   retrieval evals (`evals:evaluate-rag`, `rag-architect`). Mechanics: `llm-application-dev:*`.
   Build-vs-buy for code knowledge: codebase-memory-mcp (MIT), repowise (AGPL/commercial),
   GitNexus (PolyForm Noncommercial — not usable for client work).
4. **AI layer**: workflow vs agent vs multi-agent (`multi-agent-patterns`), tool/MCP surface (`tool-design`,
   `mcp-server-dev`), context management (`context-*`), evals offline + online (`evals:*`, `evaluation`),
   guardrails & HITL, observability, cost/latency budget (`claude-api`), hosting/sandboxing (`hosted-agents`).
5. **Decisions**: top 3–5 through `architectural-trade-offs` → ADR-style: context / options / choice / what we give up.
6. **Delivery plan (FDE lens)**: map to Discover → Pilot → Scale. What ships in weeks 1–4, team shape,
   how value is proven early, how the client team takes over, risks.
7. **Red team**: `the-fool` pre-mortem, then the 15 hardest questions a principal engineer would ask in
   the 30-min Q&A, with my best answer and the weak spot for each.
8. **Deliverable**: run `/diagrams` first. Take the story from docs/design/README.md, details from the other
   files. Every diagram slide shows a PNG from deck/public/diagrams/ (`<img src="/diagrams/context.png">`).
   ~13 slides for a 30-min talk as a Slidev deck in `deck/` (`slidev` skill; not `document-skills:pptx`),
   Dracula theme. Style comes only from `deck/STYLE.md`, applied via `deck/styles/index.css` — never inline colours.

## Sources of truth
- MCP: `refs/modelcontextprotocol/docs/specification/2026-07-28` beats any skill. That revision made MCP
  stateless (no sessions, no initialize handshake) — skills written earlier may still describe sessions.
- Claude platform facts: the `claude-api` skill. Agent patterns: `refs/claude-cookbooks/patterns/agents`.
  Retrieval: `refs/claude-cookbooks/capabilities/{retrieval_augmented_generation,contextual-embeddings,knowledge_graph}`,
  `refs/RAG_Techniques/README.md`.
- Everything else in `refs/` is secondary reading; use DeepWiki MCP for repos not cloned here.
