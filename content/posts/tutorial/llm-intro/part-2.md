---
title: "LLM Intro: From the Basics to Context Engineering (Part 2)"
date: 2026-04-03T14:08:00+08:00

tags: [AI, LLM, Claude Code, Agent, Subagent, Agent Team]
categories: [tutorial]
license: CC BY-NC-SA 4.0
---

The second part of the context engineering series. [Part 1](../part-1/) covered the foundations: what an LLM is, how it becomes an agent, and the seven layers of configuration (CLAUDE.md, hooks, MCP, skills, plugins) that make it production-ready. This part picks up where we left off — with subagents, agent teams, worktree isolation, and the context management machinery that keeps it all running as sessions scale. We close with a look at how the broader open-source ecosystem is converging on the same orchestration patterns from different directions.

<!--more-->

## Subagents

Throughout [Part 1](../part-1/), we saw subagents appear in passing: the `/code-review` skill [launches five in parallel](../part-1/#skill-anatomy), the `pr-review-toolkit` plugin ships specialized review agents. But what _are_ subagents, exactly?

[Subagents](https://code.claude.com/docs/en/sub-agents) are child agent instances spawned by a parent agent to handle focused tasks. Each gets its own context window, runs the same agent loop as the parent (plan → tool call → observe → iterate), and reports results back when done. No communication between subagents; everything routes through the orchestrator.

The mental model is a project manager delegating to specialists. The parent agent (the orchestrator) decides what needs to be done, spawns the appropriate specialist, waits for the result, and integrates it into the larger workflow.

### Agent types

My configuration defines 8 custom agent types, each with a specific role, behavioral constraints, and (in some cases) a different model tier. Each agent type is a separate Markdown file. Here is the `researcher` agent, which overrides the default model to `haiku`:

```markdown
---
name: researcher
description: |
  Fast codebase exploration and documentation lookup. Use when you need to gather context from
  multiple files, search for patterns, or look up external documentation.
color: blue
model: haiku
---

You are a research agent. Your role is to quickly gather information from the codebase and
external sources, then return a focused summary. You do NOT write or modify code.
...
```

The overall orchestration rules — when to use agents, model selection guidelines, coordination patterns, team presets, and the output contract — all live in the global CLAUDE.md, so the agent reads them at the start of every session:

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

Access constraints here are behavioral: agents are instructed to operate read-only through their system prompts, not through hard tool restrictions. This lets an agent break the boundary when genuinely needed — a read-only researcher might need to create a temporary file for an intermediate computation. The exception is the `codex-worker`, whose narrower tool set physically prevents it from doing work directly, forcing it to delegate to Codex instead:

```markdown
---
name: codex-worker
description: |
  Delegates self-contained tasks to OpenAI Codex MCP for independent parallel execution.
  Use for orthogonal tasks that benefit from a separate context window and autonomous work.
color: white
model: haiku
tools:
  - Read
  - Grep
  - Glob
  - Bash
  - mcp__Codex
  - mcp__Git
  - mcp__ide__getDiagnostics
---

You are a Codex delegation agent. Your role is to formulate clear task descriptions, delegate
them to the Codex MCP, evaluate the output, and return a validated summary. You do NOT write
code directly — you delegate to Codex and verify its work.
...
```

### Model selection

Not every task requires the most powerful (and expensive) model. The `researcher` agent uses **haiku**, the fastest and cheapest model tier. Its job is to search files, read documentation, and return a structured summary. The `tester` agent uses **sonnet**, a balanced tier where test writing's pattern-following nature does not justify opus costs, but the task is complex enough that haiku would struggle.

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

Under the hood, teammates can run as separate processes in tmux panes, giving each agent a visible terminal where you can watch its work in real time. The coordination happens through a filesystem-based protocol — task state and messages are exchanged as files in a shared directory, which keeps the mechanism simple and inspectable.

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

The lead must partition work so each teammate owns distinct file sets. For a refactor spanning many files, you might assign one implementer to the `src/api/` directory and another to `src/models/`. The partition must be communicated in the task description, and teammates must respect it. Worktree isolation (covered in the next section) offers a stronger guarantee by giving each agent its own working copy of the repository.

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
- **Diminishing returns.** Not every task benefits from parallelism. A simple bug fix with a clear root cause calls for one focused session.
- **File conflicts.** Two agents editing the same file leads to overwrites. Partitioning work across distinct files is the safest approach; worktree isolation offers an alternative at the git level.

The judgment call (when to use a single agent, when to spawn subagents, when to assemble a full team) is a skill that develops with practice. The cost of under-parallelizing is slower delivery. The cost of over-parallelizing is wasted tokens and coordination overhead.

## Worktree Isolation

The file ownership constraint from agent teams has a clean solution at the git level: [worktrees](https://git-scm.com/docs/git-worktree). A git worktree is a separate working directory checked out from the same repository. Multiple worktrees share the same `.git` history, but each has its own branch and its own files. Changes in one worktree do not affect the others until you explicitly merge.

Claude Code uses worktrees to give each agent or session an isolated workspace. The `--worktree` flag starts a new session in its own directory:

```bash
claude --worktree auth-refactor
```

This creates a branch (e.g., `worktree-auth-refactor`), checks it out in a separate directory, and runs the session there. Any file the agent reads or modifies is isolated from the main working tree. Other sessions — or teammates in an agent team — operate on their own branches without conflict.

Agents can also enter and exit worktrees mid-session via the `EnterWorktree` and `ExitWorktree` tools. In a team context, the lead assigns each teammate to a distinct worktree at the start, eliminating the need for careful file partitioning. The implementer working on `src/api/` and the implementer working on `src/models/` no longer need to stay out of each other's way; they each have their own copy of the entire repository.

{{< admonition tip "Parallel sessions" >}}

A common pattern: open three terminals, each with a worktree session. One implements a feature, one fixes a bug, one updates documentation. Each works at full speed with no coordination overhead. The merges happen at the end, on your schedule, through the same PR review process you already use.

{{< /admonition >}}

Worktrees defer conflict resolution rather than eliminating it. Two agents modifying the same function on different branches will produce a merge conflict when those branches converge. But a merge conflict is a controlled, reviewable event — far better than a silent overwrite mid-session. And for most agent team workflows, where the lead partitions work into independent areas, conflicts are rare.

The broader point: worktrees turn a coordination problem (two agents contending for the same file) into a standard git workflow problem (merging branches). It simply reuses what version control already provides.

## Context Management

Worktrees solve file-level coordination. But there is another resource that grows scarce as sessions extend and agents multiply: the context window itself.

Recall from [Part 1](../part-1/#what-is-an-llm) that the context window is the model's working memory. Everything it can "see" — your messages, system instructions, file contents, tool results, agent reports — must fit within this window. A typical multi-step investigation (reading files, running commands, spawning subagents, reviewing their reports) can consume tens of thousands of tokens before the agent begins synthesizing an answer. Without a mechanism to manage this growth, sessions eventually stall or lose track of earlier context.

Claude Code handles this through a compaction pipeline[^compaction] that operates transparently during normal use.

[^compaction]: See the [context management documentation](https://code.claude.com/docs/en/context-window) for details on compaction behavior and configuration.

### Auto-compaction

When the token count approaches the context window limit, the system triggers auto-compaction: a process that summarizes the conversation history and replaces older turns with a compressed representation. The trigger threshold is configurable; my configuration sets it to 95% of the window capacity[^autocompact-override], which maximizes usable context while leaving enough headroom for the compaction process itself.

[^autocompact-override]: Via `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE = "95"` in the environment configuration. The default threshold is lower, but a well-structured session can safely run closer to the limit.

What survives compaction: the system prompt, all CLAUDE.md files, the current task list, recent conversation turns, a summary of modified files, and continuation instructions that help the agent resume where the summary left off. What gets compressed: early conversation turns, old search results, redundant tool outputs, and intermediate reasoning that has already been resolved.

Compaction is lossy but structured. The system prioritizes preserving information the agent needs to continue working — current state, decisions made, files changed — over information that served only the moment, like a search result that has already been processed. The analogy is a project manager's notebook: you keep the current agenda and recent decisions on your desk, but archive older meeting notes. They are findable if needed, but they are not competing for your attention.

### Manual compaction

The `/compact` command triggers compaction on demand, with an optional focus hint:

```text
/compact focus on the auth refactoring decisions and ignore the earlier exploration
```

This is useful at natural task boundaries. After finishing a complex investigation and before starting implementation, a manual compact clears the investigation context and preserves only the conclusions. The focus hint guides the summarizer toward what matters for the next phase.

### Practical implications

Context management is what makes the advanced patterns described in this article viable at scale. A 30-minute debugging session that reads 15 files and runs 10 commands would exhaust a fixed-size context window long before reaching a conclusion. With compaction, the session runs for hours, periodically compressing old context to make room for new work.

For agent teams, each teammate has its own context window and its own compaction cycle. The orchestrator's context — which accumulates reports from all teammates — compacts independently. This means the orchestrator can coordinate a long-running team without running out of room. The quality of compaction summaries becomes the bottleneck, which is why the [output contract](#the-output-contract) matters: structured reports with clear status lines and concise findings compress better than free-form narratives.

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

Each row exists because the row above it has a specific limitation. The progression is driven by real problems encountered in real usage: "I keep repeating myself" → CLAUDE.md. "The model ignores my preferences" → hooks. "The model needs structured tool access" → MCP. "I need the same procedure every week" → skills. "I want to share procedures across the team" → plugins. "One agent cannot do this alone" → subagents. "Agents need to talk to each other" → teams.

Worktree isolation and context management sit underneath this stack as supporting infrastructure. Worktrees make parallel execution safe; compaction makes long sessions sustainable. Neither adds a new orchestration capability — they make the existing capabilities viable at scale.

There is a meta-observation worth making: this entire configuration system (the CLAUDE.md files, the hooks, the agents, the permission model) was itself partially built and maintained using Claude Code. The tool is self-hosting in a meaningful sense: agents helped write the definitions of agents.

### The broader ecosystem

These orchestration patterns are not unique to Claude Code. The open-source ecosystem has been converging on the same architecture from different directions, and the convergence itself is informative.

[OpenCode](https://github.com/anomalyco/opencode), the most popular open-source coding agent with over 136,000 GitHub stars at the time of this writing, implements the same agent concepts — a build agent with full access, a plan agent in read-only mode, a general subagent for complex tasks — but decoupled from any specific model provider[^opencode]. It works with Claude, GPT, Gemini, and local models interchangeably. The lesson: the orchestration patterns described in this article do not depend on Claude being the underlying model. They work because the patterns themselves (delegation, isolation, coordination) are sound, independent of which LLM executes them.

[^opencode]: OpenCode is developed by Anomaly Innovations. See [opencode.ai](https://opencode.ai) for documentation and downloads.

The [learn-claude-code](https://github.com/shareAI-lab/learn-claude-code) project (47,000+ stars) reverse-engineered Claude Code's architecture into a 12-session curriculum that mirrors the progression of this article: from a minimal agent loop through tool use, planning, subagents, context compaction, task systems, agent teams, and worktree isolation. Their central framing is worth borrowing: _the model is the agent; the code is the harness_[^harness]. The intelligence lives in the model. Everything we have been calling "context engineering" throughout this article is, in their vocabulary, harness engineering — building the tools, knowledge, permissions, and coordination infrastructure that lets the intelligence operate effectively. Both framings point at the same thing.

[^harness]: The "harness engineering" framing originates from the learn-claude-code project. See their [README](https://github.com/shareAI-lab/learn-claude-code) for the full philosophy.

[Oh My OpenAgent](https://github.com/code-yeongyu/oh-my-openagent) (47,000+ stars) pushes into multi-model orchestration: different task categories route to different model providers automatically. Visual engineering tasks go to a vision-specialized model; deep reasoning goes to GPT-5.4; fast exploration goes to a lightweight model. The system treats model selection as another dimension of context engineering — choosing not just what context to load, but which model processes it. This is an extension of the [model selection](#model-selection-as-context-engineering) approach we described for subagents, taken to its logical extreme across provider boundaries.

A recurring insight across all three projects: the most impactful improvements to agent performance come not from the model but from the harness. Oh My OpenAgent's hash-anchored edit tool — where every line carries a content hash that rejects edits against stale file state — reportedly took one model from a 6.7% to 68.3% success rate on a code editing benchmark[^harness-problem]. The model was the same; the edit mechanism changed. This aligns with what we have observed throughout: hooks, skills, output contracts, and worktree isolation do not make the model smarter. They make the model's environment more structured, which lets existing intelligence express itself more effectively.

[^harness-problem]: Source: Can Bölük, [The Harness Problem](https://blog.can.ac/2026/02/12/the-harness-problem/). The benchmark was Terminal Bench using Grok Code Fast 1.

### Who benefits and how

The layers apply differently depending on your role, but the underlying mechanism is the same: managing what is in the agent's context window to get the output you need.

**Engineers** get multi-file refactoring where the agent understands your entire codebase's patterns, parallel code review with security and correctness lenses running simultaneously, and automated test generation that follows your existing test conventions.

**Quant researchers** get automated literature surveys that search, read, and synthesize papers; strategy documentation that reads backtest results and generates structured analysis; and data pipeline debugging where the agent traces data flow through multiple transformation stages.

**Data teams** get automated data quality checks that run against defined schemas and flag anomalies, report generation that pulls data from multiple sources and formats it per team conventions, and ETL pipeline monitoring where the agent watches for schema drift and transformation errors.

**Legal and compliance** get regulatory change tracking where the agent monitors document updates and extracts new obligations, contract clause extraction against structured checklists, and policy audit workflows that compare current procedures against regulatory requirements.

**Operations** get runbook automation where the agent follows (and improves) existing runbooks step by step, incident response coordination where multiple agents investigate in parallel, and onboarding material generation that reads the codebase and produces walkthroughs.

### Where this is going

The trajectory from "prompt engineering" (2024) to "context engineering" (2026) points toward something we might call "organization engineering": the skill of decomposing problems into delegable units, assigning them to the right specialist with the right context, and coordinating the results. The ecosystem's move toward multi-model orchestration suggests the next step — not just picking the right specialist, but picking the right _kind_ of intelligence for each task. These are fundamentally human skills, the same skills that make a good engineering manager or a good research director.

The tool is only as good as the person directing it. Understanding the layers is understanding the leverage points. And the leverage, at every level, comes from the same place: knowing what the agent needs to see, when it needs to see it, and what you can safely leave out.
