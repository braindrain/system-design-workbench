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
