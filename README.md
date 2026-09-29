# System Design Workbench for Claude Code

A Claude Code project that turns a design brief into a reviewed architecture. It runs in explicit
iterations: framing, backbone, knowledge layer, AI layer, decision records, delivery plan and red team.
It ends with a 30-minute Slidev deck and a Q&A rehearsal.

You make the calls. Claude acts as a sparring partner: it pressure-tests each choice and stops to ask
before load-bearing ones.

It was built for system-design challenges and architecture reviews of AI-heavy systems: retrieval
and knowledge layers, agents, Model Context Protocol (MCP) tools and evals. The iteration commands and
conventions also work for any backend design.

## Why a workbench instead of "design X for me"

A single prompt produces a plausible architecture nobody has argued with. This workbench adds the
friction a real design review has:

- **Every number is labelled** *given*, *measured* or *assumed*.
- **Every choice names its cost.** Decision tables have a "what it costs" column, and ADRs have a
  "what we give up" section plus a trigger that would make you reverse the decision.
- **You decide load-bearing choices.** Design steps run inline in your session, never in a subagent,
  so Claude can stop and ask you about consistency, sync vs async, or region layout.
- **Every file is readable in two minutes.** Each design doc opens with a plain-language summary, one
  diagram, and a decisions table. Depth goes under `## Details`.
- **One visual language.** Every diagram comes from the `diagram-design` skill in one dark skin
  (Dracula colours), exported to PNG for both docs and slides. No Mermaid.
- **Facts come from pinned sources.** Claude platform facts come from the `claude-api` skill. MCP facts
  come from the spec revision cloned into `refs/`, and it overrides any skill.

## Workflow

```text
brief.md ─► /iter-0-frame ─► /iter-1-backbone ─► /iter-2-knowledge ─► /iter-3-ai
                                                                          │
   /qa-drill ◄─ /deck ◄─ /diagrams ◄─ /iter-5-redteam ◄─ /iter-4-decisions ◄┘

   after each iteration: review the diff, then /checkpoint <n>      any time: /overview
```

| Command | What it does | Writes | Exit check |
|---|---|---|---|
| `/iter-0-frame` | Functional requirements, non-functional requirements (NFRs) with numbers, stakeholders, assumptions, ranked questions | `01-framing.md` | Every NFR has a number and a given/assumed label |
| `/iter-1-backbone` | Back-of-the-envelope numbers, APIs, storage, messaging, caching, resilience | `02-backbone.md` | Scale numbers exist; every component says why and what it costs |
| `/iter-2-knowledge` | Sources → change capture → chunk → enrich (ontology, provenance) → hybrid index → permission-filtered retrieval → MCP tools | `03-knowledge-layer.md` | Permission model, freshness target and retrieval metrics are set |
| `/iter-3-ai` | Agent or workflow, tool/MCP surface, memory, guardrails, human approval points, evals, cost per request | `04-ai-layer.md` | Agent-or-workflow answered; tool table; cost per request |
| `/iter-4-decisions [d -> choice; …]` | With no arguments, ranks decisions by cost to reverse. With arguments, writes ADRs, then the delivery plan | `adr/ADR-00N-*.md`, `05-delivery-plan.md` | Each ADR has a reversal trigger; week 1 is concrete |
| `/iter-5-redteam` | Pre-mortem plus the 15 hardest reviewer questions, each with your best answer and its weak spot | `06-red-team.md` | Edits no other file: you pick which changes to accept |
| `/diagrams [file\|name]` | Draws or redraws diagrams and exports PNGs to docs and deck | `diagrams/*.html`, `*.png` | Checks every PNG for clipping and overlaps |
| `/overview` | Rewrites the one-page overview and lists contradictions between files | `docs/design/README.md` | Adds nothing that isn't in the design files |
| `/deck` | Builds a 13-slide, 30-minute Slidev talk with speaker notes, then does a visual pass and exports | `deck/slides.md`, PDF, PPTX | Every number matches `docs/design` |
| `/qa-drill` | Asks you the red-team questions one at a time and pushes back once on each answer | — | Scores your weak answers after 10 questions |
| `/checkpoint <n>` | Commits, tags `iter-<n>` and pushes | git | Changes no files |

All commands are user-invoked only (`disable-model-invocation`), so Claude never starts an iteration on
its own. `CLAUDE.md` holds the full method: role, rules, writing style and the eight workflow steps
with the skills each one uses.

## Quick start

**Requirements:** [Claude Code](https://claude.com/claude-code), git, Node.js ≥ 22.12
(Slidev and diagram export), Python 3 (diagram-design helper scripts), and network access to GitHub
and npm.

```bash
git clone https://github.com/braindrain/system-design-framework.git
cd system-design-framework
bash scripts/setup-design-workbench.sh .     # or: bash scripts/setup-design-workbench.sh ~/my-design
```

The setup script is safe to re-run and works with macOS bash 3.2. It does the following:

1. Adds six plugin marketplaces at user level and installs eight plugins at **project** scope, so they
   only load inside the workbench.
2. Refreshes the third-party skills from upstream (sparse clones) and writes the Dracula diagram skin as
   a diagram-design profile in `~/.diagram-design/profiles/`, selected by the repo's `.diagram-design` marker.
3. Sparse-clones the reference repos into `refs/`, which git ignores.
4. Adds the [DeepWiki](https://deepwiki.com) MCP server, used to ask questions about any public GitHub repo.
5. Writes `CLAUDE.md`, backing up an existing one to `CLAUDE.md.bak.<timestamp>`, then writes the iteration
   commands and the deck scaffold. It keeps any command or deck file that already exists.
6. Runs `npm install` in `deck/`. Set `SKIP_DECK_INSTALL=1` to skip it.

Then do these steps:

1. Fill in **"Who we're designing for"** and **"Default stack"** in `CLAUDE.md`.
2. Put the problem statement in `brief.md`.
3. Optionally, write your own first take in `docs/design/00-my-take.md`. `/iter-0-frame` reads it and
   tells you where it disagrees.
4. Run `claude`, check `/plugin` → *Installed*, then run `/iter-0-frame`.

## What you end up with

```text
brief.md                     the problem, as given
docs/design/
  README.md                  one-page overview: sentence, context diagram, components, flow, decisions
  00-my-take.md              your first take (optional)
  01-framing.md … 06-red-team.md
  adr/ADR-00N-<slug>.md      decision records: context, options, choice, what we give up, reversal trigger
  diagrams/<name>.html|.png  diagram-design sources and exports
deck/
  slides.md                  Slidev source (Dracula theme, speaker notes per slide)
  design.pdf, design.pptx    exports
```

Deck commands: `npm --prefix deck run dev` (live preview), `export`, `export:pptx` and `export:png`.
To export a diagram by hand, run `node scripts/export-diagram.mjs docs/design/diagrams/<name>.html`.
It uses the deck's Playwright Chromium; set `CHROME_PATH` to use another browser.

## Repository layout

| Path | Contents |
|---|---|
| `CLAUDE.md` | The operating manual: role, rules, writing style, workflow, sources of truth |
| `.claude/skills/iter-*`, `diagrams`, `deck`, `overview`, `qa-drill`, `checkpoint` | The 11 workbench commands |
| `.claude/skills/*` (others) | 16 third-party skills: architecture trade-offs, context engineering, evals, RAG, graph engineering, Slidev. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) |
| `.claude/settings.json` | Project-scoped plugins: system-design building blocks, evals, Claude API, MCP server dev, backend and LLM-app patterns, document skills, diagram-design |
| `.diagram-design` | Selects the `workbench-dracula` diagram-design profile, written by the setup script |
| `.mcp.json` | DeepWiki MCP server |
| `scripts/setup-design-workbench.sh` | Bootstraps or refreshes a workbench. It is the source for every generated file |
| `scripts/export-diagram.mjs` | Exports a diagram's SVG to a 2× PNG in `docs/design/diagrams/` and `deck/public/diagrams/` |
| `deck/` | Slidev scaffold, `STYLE.md` (palette, layouts, slide rules) and `styles/index.css` |
| `refs/` *(not committed)* | Sparse clones: MCP spec 2026-07-28, Claude cookbooks, RAG_Techniques, 12-factor-agents, system-design-primer and others |

## Customising

- **Target organisation and stack.** Edit the two sections at the top of `CLAUDE.md`. The default stack
  is a starting position: Claude must propose any change to it as a decision with its cost.
- **Deck look.** Edit `deck/STYLE.md`, then run `/deck`. Styling goes only through `deck/styles/index.css`,
  never inline colours.
- **Diagram skin.** Edit the `PROJECT OVERRIDE` block in section 3 of the setup script. It is re-applied
  on every run.
- **Plugins and references.** Edit sections 2 and 4 of the setup script. Two optional plugins are
  commented out: `code-modernization` for brownfield briefs and `c4-architecture`.
- **Re-running setup.** The script is the source of truth for new workbenches. A re-run overwrites
  `CLAUDE.md` (with a backup) and refreshes third-party skills. It keeps your iteration commands and
  deck files. Copy any `CLAUDE.md` edits you want to keep into the script's heredoc.

## Caveats

- `/checkpoint` pushes to your git remote. Point `origin` somewhere private while a design is confidential.
- Claude feature availability differs between the direct API and cloud providers such as AWS Bedrock.
  The workflow sends platform questions to the `claude-api` skill rather than to memory.
- The MCP revision in `refs/` (2026-07-28) is stateless. Skills written earlier may still describe
  sessions; `CLAUDE.md` tells Claude to trust the spec.

## License

[MIT](LICENSE). The bundled third-party skills keep their own MIT licenses; see
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md). Plugins are installed from their marketplaces and
reference repos are cloned at setup time; neither is redistributed here.
