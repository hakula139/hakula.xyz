---
title: "LLM Intro: From the Basics to Context Engineering (Part 2)"
date: 2026-03-13T15:30:00+08:00

tags: [AI, LLM, Claude Code, Agent, Subagent, Agent Team]
categories: [tutorial]
license: CC BY-NC-SA 4.0
draft: true
---

The second part of the context engineering series. [Part 1](../part-1/) covered the foundations: what an LLM is, how it becomes an agent, and the seven layers of configuration (CLAUDE.md, hooks, MCP, skills, plugins) that make it production-ready. This part picks up where we left off — with subagents, agent teams, and the orchestration patterns that enable full parallel coordination.

<!--more-->

## Subagents

Throughout [Part 1](../part-1/), we saw subagents appear in passing: the `/code-review` skill [launches five in parallel](../part-1/#skill-anatomy), the `pr-review-toolkit` plugin ships specialized review agents, and CLAUDE.md [defines orchestration rules](../part-1/#claudemd) for when and how to delegate. But what _are_ subagents, exactly?

[Subagents](https://docs.anthropic.com/en/docs/claude-code/sub-agents) are child processes spawned by a parent agent to handle focused tasks. Each subagent gets its own context window, runs independently, and reports results back to the parent. No communication between subagents; everything routes through the orchestrator.

The mental model is a project manager delegating to specialists. The parent agent (the orchestrator) decides what needs to be done, spawns the appropriate specialist, waits for the result, and integrates it into the larger workflow.

### Agent types

My configuration defines eight custom agent types, each with a specific role, behavioral constraints, and (in some cases) a different model tier[^agent-definitions]. Each agent type is a separate Markdown file, but the overall orchestration rules — when to use agents, model selection guidelines, coordination patterns, team presets, and the output contract — all live in the global CLAUDE.md, so the agent reads them at the start of every session:

[^agent-definitions]: Full agent definitions at [agents/](https://github.com/hakula139/nixos-config/tree/main/home/modules/claude-code/agents). Each is a Markdown file with frontmatter (name, description, model, tool restrictions) and a behavioral prompt.

| Agent                | Role                                  | Model  | Access     |
| -------------------- | ------------------------------------- | ------ | ---------- |
| `architect`          | Design review, pattern analysis       | opus   | Read-only  |
| `researcher`         | Fast codebase exploration, doc lookup | haiku  | Read-only  |
| `implementer`        | Code writing, refactoring             | opus   | Full       |
| `reviewer`           | Code quality, security, bugs          | opus   | Read-only  |
| `tester`             | Test writing and execution            | sonnet | Full       |
| `debugger`           | Hypothesis-driven root cause analysis | opus   | Read-only  |
| `usability-reviewer` | UX clarity for user-facing surfaces   | opus   | Read-only  |
| `codex-worker`       | Delegates to OpenAI Codex MCP         | haiku  | Restricted |

### Model selection as context engineering

Not every task requires the most powerful (and expensive) model. The `researcher` agent uses **haiku**, the fastest and cheapest model tier. Its job is to search files, read documentation, and return a structured summary. It does not need deep reasoning; it needs speed. The `tester` agent uses **sonnet**, a balanced tier where test writing's pattern-following nature does not justify opus costs, but the task is complex enough that haiku would struggle.

The `codex-worker` is particularly interesting: it is a haiku-tier agent whose sole purpose is to formulate tasks and delegate them to the OpenAI Codex MCP, a separate model running in its own cloud sandbox. It reads enough context to write a clear prompt, delegates the actual work, evaluates the result, and reports back. Two models collaborating, each used for what it does best.

This is cost-aware context engineering. You are not just managing what goes into the context window, but _which_ context window a task runs in, and at what price point.

### The output contract

All agents follow a shared output contract that keeps communication efficient:

```markdown
- **Status line**: Every report ends with
  `Status: completed | partial (<what remains>) | blocked (<what's needed>)`
- **Output budget**: 150-200 lines maximum
- **File references**: All code-reading agents include `file:line` references
- **Escalation**: Report blockers rather than producing low-quality output
- **Prior context**: Build on upstream findings instead of re-investigating
```

The status line is critical. When the orchestrator receives a report ending with "Status: blocked (need access to production logs)", it knows immediately to either provide the missing context or reassign the task. No ambiguity, no wasted cycles.

### Patterns

The orchestrator uses subagents in several established patterns:

- **Sequential pipeline**: researcher → architect → implementer → reviewer → tester. Each agent's output feeds the next.
- **Parallel exploration**: Spawn multiple researchers to investigate different aspects of a problem simultaneously. Three researchers examining different subsystems finish faster than one examining all three.
- **Review gate**: Always run a reviewer after the implementer completes significant changes. The reviewer's output determines whether the changes are accepted or revised.
- **Codex offloading**: Use the codex-worker for tasks that benefit from a separate context window, orthogonal work that should not pollute the main session's context.

For operations teams, this maps directly to incident response: one researcher traces the timeline, another checks recent deployments, a third examines monitoring data, all in parallel, all reporting to a coordinator who synthesizes the findings.

### What subagents cannot do

Subagents are **isolated**. They cannot:

- **Share findings with each other.** If the researcher discovers something the reviewer needs to know, it must first report to the orchestrator, who then relays it to the reviewer. This round-trip adds latency and consumes the orchestrator's context.
- **Coordinate directly.** The reviewer cannot send issues to the implementer. The researcher cannot ask the architect a clarifying question. Every interaction is mediated.
- **Avoid the bottleneck.** The orchestrator must process every report, make every decision, relay every message. As the number of subagents grows, the orchestrator's context fills up with coordination overhead.

Subagents delegate, but they do not collaborate. For tasks where agents need to share discoveries, challenge each other, or hand off work directly, you need the final layer.

## Agent Teams

Agent Teams are the full coordination model: multiple agents with a shared task list, direct peer-to-peer messaging, task dependencies, and file ownership rules. The orchestrator creates the team, defines tasks, spawns teammates, and steps back. Teammates claim work, execute it, communicate findings to each other, and report back without routing everything through the lead.

### The key difference from subagents

The decision rule is simple: if agents need to talk to each other, use an Agent Team. If they just report back, use subagents.

| Capability                       | Subagents | Agent Teams |
| -------------------------------- | --------- | ----------- |
| Own context window               | Yes       | Yes         |
| Report to orchestrator           | Yes       | Yes         |
| Shared task list                 | No        | Yes         |
| Direct messaging (`SendMessage`) | No        | Yes         |
| Task dependencies                | No        | Yes         |
| File ownership                   | Implicit  | Explicit    |

### Team lifecycle

A typical team session follows this sequence:

1. **Create the team** (`TeamCreate`): establishes a team with a shared task directory.
2. **Create tasks** (`TaskCreate`): define work items with descriptions, dependencies, and status tracking.
3. **Spawn teammates**: launch agents with the `team_name` parameter so they join the team.
4. **Teammates claim and work**: each teammate checks the task list, claims available work, and executes it.
5. **Peer communication** (`SendMessage`): teammates share findings, flag issues, and coordinate directly.
6. **Task completion**: teammates mark tasks done and check for more work.
7. **Shutdown**: the lead sends shutdown requests when all work is complete, then deletes the team.

### Team presets

My configuration defines four team presets for common workflows:

**Review team**: multi-angle code review. Two or three reviewer instances, each given a specific lens:

- "Security focus: check for OWASP top 10 vulnerabilities, authentication bypasses, data exposure."
- "Correctness focus: verify logic, edge cases, error handling paths."
- "Style focus: check naming, patterns, consistency with existing codebase."

For user-facing changes, a usability-reviewer joins alongside the code reviewers. The lead synthesizes all findings into a unified report. Three perspectives on the same code, delivered in parallel rather than sequentially.

**Debug team**: parallel hypothesis investigation. Two or three debugger instances, each assigned a different hypothesis about the root cause. Debuggers share confirming and contradicting evidence with each other via `SendMessage`, gradually converging on an answer, much like how experienced engineers debug complex issues by exploring multiple theories simultaneously rather than committing to one path.

**Feature team**: end-to-end development pipeline. Researcher gathers context, architect designs the approach, implementer writes code, reviewer validates. Task dependencies enforce the ordering: the implementer's task is blocked until the architect completes their design. This is a full delivery pipeline in a single session.

**Refactor team**: safe large-scale restructuring. Architect analyzes current structure, implementer executes changes, reviewer verifies no regressions. File ownership is critical here.

### File ownership

This is the hardest constraint in agent teams: **two agents editing the same file leads to overwrites**. Agents do not share a filesystem lock. If the implementer is modifying `src/auth.ts` while another implementer modifies the same file, one set of changes gets lost.

The lead must partition work so each teammate owns distinct file sets. For a refactor spanning many files, you might assign one implementer to the `src/api/` directory and another to `src/models/`. The partition must be communicated in the task description, and teammates must respect it.

### Advanced patterns

Beyond the presets, several advanced patterns have emerged from production use:

**Implement-review loop:** The implementer and reviewer are teammates. After making changes, the implementer sends the reviewer a message with the modified files. The reviewer analyzes, sends issues back. The implementer fixes and messages again. This tight loop bypasses the lead entirely, reducing latency.

**Research swarm:** Multiple researchers investigate different aspects of a problem, sharing findings with each other. "I found the config parsing logic in `src/config/`, relates to the schema change you were tracking." They converge on a comprehensive understanding faster than a single researcher could.

**Multi-hypothesis debugging:** Multiple debuggers investigate different theories, exchanging evidence. When one debugger finds something that contradicts another's hypothesis, they message each other directly. The lead evaluates convergence and reports the most likely root cause.

For a quant research team, an analogous pattern might involve spawning multiple researchers to investigate a strategy's drawdown from different angles: one examining market microstructure, another reviewing factor exposure shifts, a third checking data quality around the relevant dates. Each investigates independently and shares evidence with the others.

### Honest limitations

Agent teams are powerful, but they are not free:

- **Cost.** N agents means roughly Nx the token cost. A four-agent team running opus costs four times what a single agent would.
- **Complexity.** Agents can miscommunicate, duplicate work, or claim the same task. The lead must actively manage coordination.
- **Diminishing returns.** Not every task benefits from parallelism. A simple bug fix with a clear root cause does not need a debug team; it needs one focused session.
- **File conflicts.** The ownership constraint is real and annoying. Until agent frameworks support true collaborative editing, partitioning is the only safe approach.

The judgment call (when to use a single agent, when to spawn subagents, when to assemble a full team) is a skill that develops with practice. The cost of under-parallelizing is slower delivery. The cost of over-parallelizing is wasted tokens and coordination overhead.

## The Full Stack

Here is the complete picture across both parts of this series:

| Layer        | What it solves                           | What it cannot do          |
| ------------ | ---------------------------------------- | -------------------------- |
| Raw LLM      | Text generation, pattern matching        | Act on the world           |
| Chat + Tools | Interactive Q&A, agentic loops           | Remember between sessions  |
| CLAUDE.md    | Persistent preferences, conventions      | Enforce rules              |
| Hooks        | Automated enforcement, formatting        | Structured tool access     |
| MCP          | Structured tool access, typed interfaces | Define reusable procedures |
| Skills       | Reusable on-demand procedures            | Share or scale             |
| Plugins      | Distributable capability packages        | Parallelize                |
| Subagents    | Focused delegation, parallel work        | Peer communication         |
| Agent Teams  | Full coordination, shared tasks          | Replace your judgment      |

Each row exists because the row above it has a specific limitation. The progression is not arbitrary; it is driven by real problems encountered in real usage: "I keep repeating myself" → CLAUDE.md. "The model ignores my preferences" → hooks. "The model needs structured tool access" → MCP. "I need the same procedure every week" → skills. "I want to share procedures across the team" → plugins. "One agent cannot do this alone" → subagents. "Agents need to talk to each other" → teams.

There is a meta-observation worth making: this entire configuration system (the CLAUDE.md files, the hooks, the agents, the permission model) was itself partially built and maintained using Claude Code. The tool is self-hosting in a meaningful sense: agents helped write the definitions of agents.

### Who benefits and how

The layers apply differently depending on your role, but the underlying mechanism is the same: managing what is in the agent's context window to get the output you need.

**Engineers** get multi-file refactoring where the agent understands your entire codebase's patterns, parallel code review with security and correctness lenses running simultaneously, and automated test generation that follows your existing test conventions.

**Quant researchers** get automated literature surveys that search, read, and synthesize papers; strategy documentation that reads backtest results and generates structured analysis; and data pipeline debugging where the agent traces data flow through multiple transformation stages.

**Data teams** get automated data quality checks that run against defined schemas and flag anomalies, report generation that pulls data from multiple sources and formats it per team conventions, and ETL pipeline monitoring where the agent watches for schema drift and transformation errors.

**Legal and compliance** get regulatory change tracking where the agent monitors document updates and extracts new obligations, contract clause extraction against structured checklists, and policy audit workflows that compare current procedures against regulatory requirements.

**Operations** get runbook automation where the agent follows (and improves) existing runbooks step by step, incident response coordination where multiple agents investigate in parallel, and onboarding material generation that reads the codebase and produces walkthroughs.

### Where this is going

The trajectory from "prompt engineering" (2024) to "context engineering" (2026) points toward something we might call "organization engineering": the skill of decomposing problems into delegable units, assigning them to the right specialist with the right context, and coordinating the results. These are fundamentally human skills. The best way to use these tools is to think about them the way you would think about managing a team of specialists: clear briefs, appropriate delegation, parallel workstreams, and synthesis of results.

The tool is only as good as the person directing it. Understanding the layers is understanding the leverage points. And the leverage, at every level, comes from the same place: knowing what the agent needs to see, when it needs to see it, and what you can safely leave out.
