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
