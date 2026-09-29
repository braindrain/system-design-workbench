#!/usr/bin/env bash
# System-design workbench for Claude Code: design challenges, architecture reviews, client pilots.
# Creates ~/design-workbench with project-scoped plugins, cherry-picked skills,
# read-only reference repos, the DeepWiki MCP server, a CLAUDE.md, iteration commands and a Slidev deck.
# Usage:  bash setup-design-workbench.sh [target-dir]      (macOS bash 3.2 compatible; safe to re-run)
set -euo pipefail

WB="${1:-$HOME/design-workbench}"
mkdir -p "$WB/.claude/skills" "$WB/refs" "$WB/docs/design"
cd "$WB"
[ -d .git ] || git init -q
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# ---------- 1. Marketplaces (user-level registry) ----------
M() { claude plugin marketplace add "$1" >/dev/null 2>&1 && echo "  + marketplace $1" || echo "  = marketplace $1 (already added?)"; }
M anthropics/claude-plugins-official
claude plugin marketplace update claude-plugins-official >/dev/null 2>&1 || true
M proyecto26/system-design-skills
M ai-evals-course/evals-skills
M anthropics/skills
M wshobson/agents
M cathrynlavery/diagram-design

# ---------- 2. Plugins, project scope (only active inside this workbench) ----------
P() { claude plugin install "$1" --scope project || echo "!! FAILED: $1 — check the name with /plugin"; }
P system-design-skills@system-design-skills      # /design loop + 22 building blocks (queues, storage, caching, search, consistency…)
P evals@ai-evals-course                          # Hamel Husain & Shreya Shankar eval skills (incl. evaluate-rag)
P claude-api@anthropic-agent-skills              # agent design, Managed Agents, memory, caching, cost, platform availability
P document-skills@anthropic-agent-skills         # docx/pdf/xlsx (the deck itself is Slidev, see section 8)
P mcp-server-dev@claude-plugins-official         # MCP deployment models, auth, tool design
P backend-development@claude-code-workflows      # saga, CQRS, event store, workflow orchestration
P llm-application-dev@claude-code-workflows      # RAG mechanics: hybrid search, reranking, embeddings, vector index tuning
P diagram-design@diagram-design                  # every diagram: editorial HTML/SVG, no Mermaid (skin: section 3)
# Optional — enable after reading the brief:
# P code-modernization@claude-plugins-official   # brownfield / "N legacy repos" briefs: assess → map → extract-rules → brief
# P c4-architecture@claude-code-workflows        # C4 context/container/component agents

# ---------- 3. Cherry-picked skills (copied, not whole repos, to keep the skill list lean) ----------
pick() {  # pick <owner/repo> <skills-subdir> <skill>...   (sparse clone: only the picked folders)
  local repo="$1" sub="$2"; shift 2
  local dir="$TMP/$(echo "$repo" | tr / _)" paths="" s
  for s in "$@"; do [ "$sub" = "." ] && paths="$paths $s" || paths="$paths $sub/$s"; done
  git clone -q --depth 1 --filter=blob:none --sparse "https://github.com/$repo" "$dir"
  git -C "$dir" sparse-checkout set $paths
  for s in "$@"; do
    rm -rf ".claude/skills/$s"; cp -R "$dir/$sub/$s" ".claude/skills/$s"
    echo "  + $s  ($repo)"
  done
}
echo "Copying skills…"
pick muratcankoylan/Agent-Skills-for-Context-Engineering skills \
  multi-agent-patterns tool-design memory-systems evaluation advanced-evaluation \
  harness-engineering hosted-agents context-fundamentals context-degradation context-optimization
pick Jeffallan/claude-skills skills the-fool rag-architect
pick Integral-Productivity/software-architecture-claude-plugin skills \
  architectural-trade-offs architectural-characteristics
pick codejunkie99/graph-engineering . graph-engineering   # enrichment: ontology, extraction, entity resolution, GraphRAG
pick slidevjs/slidev skills slidev                        # official Slidev skill: the deck (section 8)
# diagram-design project skin: Dracula, dark only. It lives in a named profile outside the plugin, so plugin
# updates keep it; the .diagram-design marker selects it (see the skill's references/profiles.md).
# Rewritten on every run from the current upstream style guide.
[ -d .claude/skills/diagram-design ] && rm -rf .claude/skills/diagram-design \
  && echo "  - .claude/skills/diagram-design (old copy; the plugin replaces it)" || true
DD="$TMP/diagram-design"
git clone -q --depth 1 --filter=blob:none --sparse https://github.com/cathrynlavery/diagram-design "$DD"
git -C "$DD" sparse-checkout set skills/diagram-design/references
PROFILE="$HOME/.diagram-design/profiles/workbench-dracula.md"
mkdir -p "$HOME/.diagram-design/profiles"
{ cat <<EOF
<!-- diagram-design-profile
name: Design workbench (Dracula)
slug: workbench-dracula
source-url: https://github.com/braindrain/system-design-workbench
created: $(date +%F)
updated: $(date +%F)
notes: Written by scripts/setup-design-workbench.sh; re-run it to refresh
-->
EOF
cat <<'EOF'
# PROJECT OVERRIDE — read this first

This repo uses one skin: **dark only, Dracula colours**. Start every diagram from `assets/template-dark.html`.
These values replace the "Default (dark)" column in the Tokens table below; everything else in this file
(typography, rules, series usage) still applies.

| Role | Value |
|---|---|
| `paper` | `#282A36` |
| `paper-2` | `#44475A` |
| `ink` | `#F8F8F2` |
| `ink-strong` | `#282A36` |
| `muted` | `#A4ADCB` |
| `soft` | `#6272A4` |
| `rule` | `rgba(248,248,242,0.12)` |
| `rule-solid` | `#6272A4` |
| `accent` | `#FF79C6` |
| `accent-tint` | `rgba(255,121,198,0.12)` |
| `link` | `#8BE9FD` |
| `series-1..5` | `#50FA7B`, `#BD93F9`, `#FFB86C`, `#8BE9FD`, `#F1FA8C` |

Node roles, the same in every diagram of this repo (the Node type table in SKILL.md §5, in these colours):
- What we build: `paper-2` fill, `ink` stroke. AI or model steps: the same with a `series-1` stroke and an
  `AI` tag. Data stores: `ink` at 0.05 fill, `muted` stroke.
- Client or vendor systems: `ink` at 0.03 fill, `ink` at 0.30 stroke. People: `muted` at 0.10 fill,
  `soft` stroke. Boundaries and failure domains: dashed `ink` at 0.30.
- Risks, failure points, go/no-go gates: `#FF5555` stroke, sparingly.
- Arrows: `muted` by default, dashed for async, `link` for calls to external APIs.
- `accent` on 1-2 elements: the thing the diagram is about.

Files: `docs/design/diagrams/<doc-prefix>-<slug>.html` (e.g. `03-ontology.html`, `adr-002.html`; `context`,
`flow` and `delivery` keep their names). Prefix SVG ids with the file name.
Export with `node scripts/export-diagram.mjs <file.html>` from the repo root (Node + the deck's Playwright),
not the Python procedure in export.md.

---

EOF
cat "$DD/skills/diagram-design/references/style-guide.md"; } > "$PROFILE.tmp" && mv "$PROFILE.tmp" "$PROFILE"
printf 'profile: workbench-dracula\n' > .diagram-design
echo "  + diagram-design skin: $PROFILE, selected by .diagram-design"

# ---------- 4. Reference repos (sparse, read-only; Claude reads them on demand) ----------
ref() {  # ref <owner/repo> <path>...   (re-run adds missing paths)
  local repo="$1"; shift
  local dir="refs/$(basename "$repo")"
  [ -d "$dir" ] || git clone -q --depth 1 --filter=blob:none --sparse "https://github.com/$repo" "$dir"
  git -C "$dir" sparse-checkout set "$@"
  echo "  + $dir"
}
echo "Cloning references…"
ref modelcontextprotocol/modelcontextprotocol docs/specification/2026-07-28 docs/docs/2026-07-28
ref anthropics/claude-cookbooks patterns/agents managed_agents claude_agent_sdk tool_use \
  capabilities/retrieval_augmented_generation capabilities/contextual-embeddings capabilities/knowledge_graph
ref NirDiamant/RAG_Techniques all_rag_techniques   # README = catalogue of ~40 retrieval techniques
ref humanlayer/12-factor-agents content
ref donnemartin/system-design-primer solutions     # root README (the primer itself) comes with cone mode
ref alexeygrigorev/ai-engineering-field-guide interview
ref alirezadir/Agentic-AI-Systems 03_system_design

# ---------- 5. MCP: ask questions about any public GitHub repo ----------
claude mcp add --scope project --transport http deepwiki https://mcp.deepwiki.com/mcp >/dev/null 2>&1 \
  && echo "  + mcp deepwiki" || echo "  = mcp deepwiki (already added?)"

# ---------- 6. Project memory (existing CLAUDE.md is backed up, not lost) ----------
[ -f CLAUDE.md ] && cp CLAUDE.md "CLAUDE.md.bak.$(date +%Y%m%d%H%M%S)"
cat > CLAUDE.md <<'EOF'
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
EOF

# ---------- 7. Iteration commands (/iter-0-frame … /diagrams, /overview, /checkpoint), user-invoked only ----------
# Written only if missing, so your edits survive re-runs. Delete a file to regenerate it.
cmd() {  # cmd <name>  (content on stdin)
  local f=".claude/skills/$1/SKILL.md"
  if [ -f "$f" ]; then cat >/dev/null; echo "  = /$1 (kept yours)"; return; fi
  mkdir -p ".claude/skills/$1"; cat > "$f"; echo "  + /$1"
}
echo "Writing iteration commands…"
cmd iter-0-frame <<'EOF'
---
description: Iteration 0 — frame the brief into requirements, NFRs, assumptions and questions
disable-model-invocation: true
---
Read brief.md and docs/design/00-my-take.md. Do CLAUDE.md step 1 only and write
docs/design/01-framing.md: functional requirements; NFRs with numbers, each marked given / assumed;
stakeholders; what the brief is implicitly testing; out of scope; assumptions; and at most 5
clarifying questions, ranked by how much the answer changes the design.
Do not design anything yet. Where you disagree with my take, say so.

Exit check (report what's missing): every NFR has a number and a given/assumed label; questions are ranked.
EOF
cmd iter-1-backbone <<'EOF'
---
description: Iteration 1 — backbone architecture with the system-design skills
disable-model-invocation: true
---
Read docs/design/01-framing.md. Do CLAUDE.md step 2 and write docs/design/02-backbone.md with one
diagram. Ask me before any load-bearing choice (consistency model, sync vs async, single vs multi-region).

Exit check (report what's missing): scale numbers exist; every component says why it's there and what it costs.
EOF
cmd iter-2-knowledge <<'EOF'
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
EOF
cmd iter-3-ai <<'EOF'
---
description: Iteration 3 — AI layer (agent vs workflow, tools/MCP, memory, evals, HITL, cost)
disable-model-invocation: true
---
Read docs/design/01-03. Do CLAUDE.md step 4 and write docs/design/04-ai-layer.md.
First answer: does this need an agent, or is a deterministic workflow enough? Then: topology; the
tool/MCP surface as a table (tool, inputs, outputs, side effects); context and memory strategy;
guardrails and human approval points; evals (offline set, online signals, judge validation);
observability; cost and latency per request with numbers; model hosting on the client's cloud
(invoke claude-api for platform availability). Ask me before load-bearing choices.

Exit check (report what's missing): agent-or-workflow answered; tool table; HITL points; cost per request.
EOF
cmd iter-4-decisions <<'EOF'
---
description: Iteration 4 — ADRs for the decisions I pick, then the delivery plan
argument-hint: "[decision -> my choice; decision; ...]"
disable-model-invocation: true
---
Decisions I picked: $ARGUMENTS

If that list is empty: read docs/design/, list every decision made so far ranked by cost to reverse,
with your recommended option for each, and stop. I pick the 3-5 that get ADRs, not you.

Otherwise, for each decision, invoke architectural-trade-offs and write
docs/design/adr/ADR-00N-<slug>.md: status, context, options, choice, what we give up, and what would
make us change it. Where I gave a choice after "->", the ADR records my choice (status: Accepted) and
argues it honestly, costs included; if you think I'm wrong, say so in the ADR's last line. Where I gave
no choice, recommend one and mark it status: Proposed for me to confirm. Then write docs/design/05-delivery-plan.md per CLAUDE.md step 6: Discover -> Pilot -> Scale,
weeks 1-4 in detail, team shape, how value is proven, handover, top 5 risks with mitigations.

Exit check (report what's missing): each ADR has a reversal trigger; week 1 is concrete.
EOF
cmd iter-5-redteam <<'EOF'
---
description: Iteration 5 — red team the design and list the hardest Q&A questions
disable-model-invocation: true
---
You are a principal engineer on the delivery team reviewing this design before it goes to a client.
Read brief.md and docs/design/. Invoke the-fool: run a pre-mortem ("six months later this failed,
why?"), then list the 15 hardest questions you would ask in the Q&A. For each: my best answer from the
docs, the weak spot, and whether the design should change. Write docs/design/06-red-team.md.
Do not edit any other design file: I decide which changes to accept.
EOF
cmd deck <<'EOF'
---
description: Build the 30-minute Slidev deck from the design docs, with visual QA and exports
disable-model-invocation: true
allowed-tools: Bash(npm --prefix deck run *)
---
Invoke the slidev skill. Read docs/design/ and deck/STYLE.md, then write deck/slides.md for a
30-minute talk. Keep the existing headmatter (first frontmatter block) unless STYLE.md changed.
1 Title + the design in one sentence · 2 Problem as understood + assumptions · 3 Success criteria and
NFRs with numbers · 4 Architecture overview (one diagram) · 5 Knowledge layer data flow · 6 AI layer:
agent or workflow, tools, human approval points · 7 Evals and observability · 8 Cost and latency budget
· 9-10 Key decisions (ADRs, with what we give up) · 11 Delivery: Discover -> Pilot -> Scale, week 1 ·
12 Risks and mitigations · 13 Open questions and next steps. Backup slide: how I produced this (the workbench).

Rules: follow deck/STYLE.md (Dracula theme). Use the theme's layouts where STYLE.md says so. Styling
only through deck/styles/index.css, never inline colours; if STYLE.md changed, update it first.
Diagrams: every diagram is a diagram-design PNG from deck/public/diagrams/
(`<img src="/diagrams/context.png" class="diagram">`), never Mermaid. If a slide needs a diagram that
doesn't exist, one is older than its docs/design file, or the doc's PNG has more than 12 nodes, stop and
tell me which `/diagrams <name>` to run. Speaker notes as an HTML comment at the
end of each slide (~2 min of talk). Every number must match docs/design.

QA: run `npm --prefix deck run export:png`, look at every PNG in deck/png/, fix overflow, overlaps and
unreadable diagrams, and re-export until clean. Then `npm --prefix deck run export` (PDF) and
`npm --prefix deck run export:pptx`. Report the slide count and anything you couldn't fix.
EOF

cmd qa-drill <<'EOF'
---
description: Q&A rehearsal — interview me with the red-team questions
disable-model-invocation: true
---
Interview me with the questions in docs/design/06-red-team.md, one at a time, in random order.
Wait for my answer. Push back once on each answer, then move on. After 10 questions, tell me which
answers were weak and why, and what a stronger 30-second answer would contain.
EOF
cmd diagrams <<'EOF'
---
description: Draw or redraw diagrams with diagram-design and export them as PNGs for docs and deck
argument-hint: "[docs/design file or diagram name; empty = the high-level diagrams]"
disable-model-invocation: true
allowed-tools: Bash(node scripts/export-diagram.mjs *) Bash(python3 *)
---
Invoke the `diagram-design:diagram-design` skill. The `.diagram-design` marker selects the
`workbench-dracula` profile (~/.diagram-design/profiles/); read the PROJECT OVERRIDE at its top first:
dark template, Dracula skin, the project's colour roles and file naming. If the profile is missing,
stop and tell me to re-run scripts/setup-design-workbench.sh.

What to draw: $ARGUMENTS
- A docs/design file: its summary diagram, plus any diagram under Details that the text now contradicts.
- A diagram name (e.g. 03-ontology, adr-002): that one, from the text around its image in docs/design.
- Nothing: the high-level diagrams, from brief.md and docs/design/ (README.md first):
  1. context.html: users, the system, external systems, the boundary we own.
  2. flow.html: the end-to-end flow in 4-7 steps, with human decision points marked.
  3. delivery.html: Discover -> Pilot -> Scale, what ships when.
  4. Only if the design has one: the core concept as a layer stack or funnel.

Save them in docs/design/diagrams/. Pick each diagram type with the skill's own guide; one accent per
diagram, on the element it is about. Labels must match the names used in the design docs.
Export: `node scripts/export-diagram.mjs docs/design/diagrams/<name>.html`. Look at every PNG, fix
clipping, overlaps and unreadable text, re-export until clean. Then make sure each file embeds its PNG
(`![…](diagrams/<name>.png)`, `../diagrams/` from adr/).
EOF
cmd overview <<'EOF'
---
description: Rewrite the one-page architecture overview (docs/design/README.md) in plain language
disable-model-invocation: true
---
Read brief.md and every file in docs/design/. Rewrite docs/design/README.md following the overview
template in CLAUDE.md: one page at most, plain language, for someone who hasn't read the other files.
Add nothing that isn't already in the design files. If files contradict each other, list the
contradictions at the end instead of resolving them. Then show me the overview in chat.
EOF
cmd checkpoint <<'EOF'
---
description: Commit, tag and push the current iteration after I've reviewed the diff
argument-hint: "[iteration-number] [focus]"
disable-model-invocation: true
allowed-tools: Bash(git *)
---
Show `git status --short` and `git diff --stat`. Then run:
git add -A && git commit -m "Iteration $ARGUMENTS" && git tag iter-$0 && git push && git push --tags
Report the commit hash and tag. Do not modify any files.
EOF


# ---------- 8. Slidev deck scaffold in deck/ (files written only if missing) ----------
echo "Scaffolding the Slidev deck…"
mkdir -p deck/styles
rm -f deck/setup/mermaid.ts && rmdir deck/setup 2>/dev/null \
  && echo "  - deck/setup/mermaid.ts (diagrams are diagram-design PNGs)" || true
put() {  # put <path>  (content on stdin; kept if it exists)
  if [ -f "$1" ]; then cat >/dev/null; echo "  = $1 (kept yours)"; else cat > "$1"; echo "  + $1"; fi
}
put deck/package.json <<'EOF'
{
  "name": "design-deck",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "slidev --open",
    "export": "slidev export --output design.pdf",
    "export:pptx": "slidev export --format pptx-editable --output design.pptx",
    "export:png": "slidev export --format png --output png"
  },
  "devDependencies": {
    "@slidev/cli": "^53.0.0",
    "@slidev/types": "^53.0.0",
    "@vue/compiler-sfc": "^3.5.43",
    "playwright-chromium": "^1.63.0",
    "slidev-theme-dracula": "^0.2.5"
  }
}
EOF
put deck/STYLE.md <<'EOF'
# Deck style — edit this, then run /deck

Theme: [slidev-theme-dracula](https://github.com/jd-solanki/slidev-theme-dracula) (dark, Nunito Sans + JetBrains Mono).
The theme styles text, headings and code. `/deck` applies the rest of this file through
`styles/index.css` (small overrides only).

## Palette (Dracula)
| Token        | Hex     | Use |
|--------------|---------|-----|
| background   | #282A36 | slide background (theme) |
| current-line | #44475A | diagram node fill, panels |
| foreground   | #F8F8F2 | body text |
| comment      | #6272A4 | captions, diagram lines, external systems |
| purple       | #BD93F9 | titles (theme), data stores |
| cyan         | #8BE9FD | core components |
| green        | #50FA7B | AI / agent components |
| orange       | #FFB86C | emphasis, key numbers (theme's bold) |
| pink         | #FF79C6 | sparingly: the one thing to remember on a slide |
| red          | #FF5555 | risks |
| yellow       | #F1FA8C | inline code (theme) |

## Layouts to use (from the theme)
`cover` for slide 1 · `section` between parts · `statement` for the one-line design summary ·
`fact` for a headline number · `quote` only for a client/brief quote. Everything else: default layout.

## Diagrams
Every diagram is a diagram-design PNG from /diagrams (source in docs/design/diagrams/, copied to
public/diagrams/), shown with `<img src="/diagrams/<name>.png" class="diagram">` (`diagram-sm` under a
heading plus caption). No Mermaid. Colours, shapes and the one accent come from the PROJECT OVERRIDE in
the diagram-design skill. At most 12 nodes on a slide; check the slide PNG for clipping.

## Slide rules
- Title states the takeaway ("Permissions are enforced at query time"), not the topic ("Permissions").
- One idea per slide: at most 25 words of body, or one diagram plus a one-line caption.
- Every number also appears in docs/design; mark assumed numbers "(assumed)".
- Dark theme: no text in comment colour smaller than body size; check contrast in the PNG export.
EOF
put deck/styles/index.css <<'EOF'
/* Generated from deck/STYLE.md. The Dracula theme does the heavy lifting; keep overrides minimal. */
.slidev-layout em { color: #6272a4; }
.slidev-layout table { border-color: #44475a; }
EOF
put deck/slides.md <<'EOF'
---
theme: dracula
title: System design
aspectRatio: 16/9
transition: fade
---

# System design

Run /deck to build this deck from docs/design/

<!--
Speaker notes go in an HTML comment at the end of each slide.
-->
EOF
mkdir -p scripts docs/design/diagrams deck/public/diagrams
put scripts/export-diagram.mjs <<'EOF'
// Renders diagram-design HTML files in headless Chromium (the deck's Playwright) and saves the diagram's
// <svg> as a 2x PNG with a transparent background, next to the source and in deck/public/diagrams/.
// Usage (repo root): node scripts/export-diagram.mjs docs/design/diagrams/*.html
import { mkdirSync, copyFileSync } from 'node:fs'
import { resolve, basename, dirname, join } from 'node:path'
import { pathToFileURL } from 'node:url'
import { chromium } from '../deck/node_modules/playwright-chromium/index.mjs'

const files = process.argv.slice(2)
if (!files.length) { console.error('usage: node scripts/export-diagram.mjs <diagram.html>...'); process.exit(1) }
const browser = await chromium.launch(process.env.CHROME_PATH ? { executablePath: process.env.CHROME_PATH } : {})
const page = await browser.newPage({ deviceScaleFactor: 2, viewport: { width: 1600, height: 1000 } })
mkdirSync('deck/public/diagrams', { recursive: true })
for (const f of files) {
  await page.goto(pathToFileURL(resolve(f)).href + '?motion=static', { waitUntil: 'networkidle' })
  await page.evaluate(() => document.fonts.ready)
  const out = join(dirname(f), basename(f, '.html') + '.png')
  await page.locator('svg').first().screenshot({ path: out, omitBackground: true })
  copyFileSync(out, join('deck/public/diagrams', basename(out)))
  console.log('✓', out, '-> deck/public/diagrams/' + basename(out))
}
await browser.close()
EOF
for line in "deck/node_modules/" "deck/dist/" "deck/png/" "refs/" "CLAUDE.md.bak.*"; do
  [ -f .gitignore ] && grep -qxF "$line" .gitignore || echo "$line" >> .gitignore
done
if [ "${SKIP_DECK_INSTALL:-0}" = "1" ]; then
  echo "  = deck install skipped (SKIP_DECK_INSTALL=1)"
elif command -v node >/dev/null 2>&1 && \
   node -e 'const [a,b]=process.versions.node.split(".").map(Number); process.exit(a>22||(a===22&&b>=12)?0:1)'; then
  echo "Installing Slidev in deck/ (a few minutes the first time)…"
  (cd deck && npm install --no-fund --no-audit --loglevel=error) && echo "  + deck/node_modules" \
    || echo "!! npm install failed in deck/ — run it by hand: cd deck && npm install"
else
  echo "!! Slidev needs Node >= 22.12. Install it (brew install node), then: cd deck && npm install"
fi
for ext in antfu.slidev; do   # Slidev preview
  command -v code >/dev/null 2>&1 && code --install-extension "$ext" >/dev/null 2>&1 \
    && echo "  + VS Code extension $ext" || true
done

echo
echo "Done → $WB"
echo "Next: cd \"$WB\" && claude   — then /plugin → Installed to check what loaded and its context cost."
echo "Deck preview: npm --prefix deck run dev   (or the Slidev VS Code extension)"