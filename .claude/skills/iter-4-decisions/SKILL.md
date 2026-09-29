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
