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
