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

### Why subagents

The reason to use them is context hygiene. A single agent investigating three unrelated subsystems fills its context window with all three, even though each investigation only needs one. Subagents isolate that: each topic runs in its own window, and only the summary flows back to the orchestrator. The main session stays focused; the intermediate search results, file reads, and dead ends stay contained.

Isolation buys more than a clean context window; it also buys cognitive independence. An agent that wrote the code is a poor judge of its own work — it has seen every intermediate decision, invested tokens in the approach, and when tests fail, is inclined to fix the tests rather than question the implementation. A separate reviewer or tester starts fresh, with no attachment to the approach. It sees only the result, not the effort that produced it.

Both reasons point to the same mental model: a project manager delegating to specialists. The parent agent (the orchestrator) decides what needs to be done, spawns the appropriate specialist, waits for the result, and integrates it into the larger workflow.

### Agent types

Claude Code ships with several built-in subagents: **Explore** (haiku, read-only, for fast codebase search), **Plan** (inherits model, read-only, for context gathering in plan mode), and **General-purpose** (inherits model, full tool access, for complex multi-step tasks). These cover the most common delegation patterns out of the box.

My configuration defines eight additional custom agent types on top of these, each with a specific role, behavioral constraints, and (in some cases) a different model tier. Each agent type is a separate Markdown file. Here is the `tester` agent, which overrides the default model to `sonnet`:

```markdown
---
name: tester
description: |
  Test writing and execution, failure analysis. Use when you need tests written for new code,
  want to run existing tests, or need help diagnosing test failures.
color: magenta
model: sonnet
---

You are a test engineer. Your role is to write tests, execute test suites, and analyze
failures. Focus on meaningful test coverage over quantity.

## Workflow

1. **Understand the target**: What code needs testing? Read the implementation to understand
   behavior, edge cases, and failure modes.
2. **Check existing tests**: Find existing test files and patterns. Match the testing
   framework, style, and conventions already in use.
3. **Write / run tests**: Create new tests or execute existing ones. For test failures,
   investigate root causes.
4. **Report results**: Summarize test coverage and findings.

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

## Workflow

1. **Understand the task**: What needs to be done? Gather enough context to write a clear,
   self-contained prompt for Codex.
2. **Gather context**: Read relevant files to understand existing patterns. Include key
   context in the Codex prompt so it doesn't have to rediscover it.
3. **Delegate to Codex**: Use `mcp__Codex__codex` with a detailed prompt. Set appropriate
   sandbox and approval policy.
4. **Evaluate output**: Verify Codex's claims and code changes.
5. **Iterate if needed**: Use `mcp__Codex__codex-reply` to provide corrections or follow-up.
6. **Report results**: Summarize what Codex produced, what you verified, and any concerns.

...
```

### Model selection

Not every task requires the most powerful (and expensive) model. The `researcher` agent uses **haiku**, the fastest and cheapest model tier. Its job is to search files, read documentation, and return a structured summary — tasks where speed matters more than deep reasoning. The `tester` agent uses **sonnet**, a balanced tier where test writing's pattern-following nature does not justify opus costs, but the task is complex enough that haiku would struggle.

The `codex-worker` is particularly interesting: it is a haiku-tier agent whose sole purpose is to formulate tasks and delegate them to the OpenAI Codex MCP, a separate model running in its own cloud sandbox. It reads enough context to write a clear prompt, delegates the actual work, evaluates the result, and reports back. Two models collaborating, each used for what it does best.

Model selection is not the only lever. The `effort` field (`low`, `medium`, `high`, `max`) controls how much reasoning depth a subagent applies — a fast researcher can run at low effort, while a complex architectural review warrants high or max. Combined with model choice, this gives fine-grained control over the cost-quality tradeoff per task.

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

### Persistent memory

Subagents normally start with a clean context every time they are invoked. The `memory` field changes this: it gives a subagent a persistent directory that survives across sessions, scoped to `user` (all projects), `project` (this codebase, shareable via version control), or `local` (this codebase, not checked in). The subagent reads its accumulated notes at startup and writes new findings back when it finishes. Over time, a reviewer builds a knowledge base of recurring issues in this codebase; a researcher remembers which files contain which subsystems; a debugger logs failed approaches so it does not repeat them. This is institutional knowledge that compounds — the subagent equivalent of a senior engineer's notebook.

### Patterns

The orchestrator uses subagents in several established patterns:

- **Sequential pipeline**: researcher → architect → implementer → reviewer → tester. Each agent's output feeds the next.
- **Parallel exploration**: Spawn multiple researchers to investigate different aspects of a problem simultaneously. Three researchers examining different subsystems finish faster than one examining all three.
- **Parallel review**: Spawn two or three reviewers, each given a distinct lens — security, correctness, test coverage. Each reports independently to the orchestrator. A single reviewer tends to gravitate toward one type of issue at a time; splitting the criteria into independent domains means each gets thorough attention.
- **Review gate**: Always run a reviewer after the implementer completes significant changes. The reviewer's output determines whether the changes are accepted or revised.
- **Codex offloading**: Use the codex-worker for tasks that benefit from a separate context window, orthogonal work that should not pollute the main session's context.
- **Background execution**: Subagents can run concurrently in the background while you continue working in the main session. Press Ctrl+B to background a running task, or set `background: true` in the agent's frontmatter to make it the default. Background subagents pre-approve permissions at launch and auto-deny anything not pre-approved, so they run without interrupting you.

For operations teams, this maps directly to incident response: one researcher traces the timeline, another checks recent deployments, a third examines monitoring data, all in parallel, all reporting to a coordinator who synthesizes the findings.

### What subagents cannot do

Subagents are **isolated**. They cannot:

- **Share findings with each other.** If the researcher discovers something the reviewer needs to know, it must first report to the orchestrator, who then relays it to the reviewer. This round-trip adds latency and consumes the orchestrator's context.
- **Coordinate directly.** The reviewer cannot send issues to the implementer. The researcher cannot ask the architect a clarifying question. Every interaction is mediated.
- **Avoid the bottleneck.** The orchestrator must process every report, make every decision, relay every message. As the number of subagents grows, the orchestrator's context fills up with coordination overhead.

Picture a manager who insists that every message between team members goes through them. Two engineers cannot pull each other into a quick sync; they must each email the manager, who reads both emails, decides what to forward, and relays it. With three reports this is manageable. With eight it is the manager's inbox that catches fire. Subagents delegate, but they do not collaborate. For tasks where agents need to share discoveries, challenge each other, or hand off work directly, you need the final layer.

## Agent Teams

{{< admonition warning "Experimental" >}}

As of this writing (April 2026), agent teams are experimental and disabled by default. Enable them by setting `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in your environment or `settings.json`. The feature has known limitations around session resumption, task coordination, and shutdown behavior.

{{< /admonition >}}

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

### What teams add over subagents

Many of the [subagent patterns](#patterns) — parallel review, parallel exploration — work fine without teams. The orchestrator spawns workers, collects reports, synthesizes. Teams earn their overhead when agents need to coordinate mid-task. The [official documentation](https://code.claude.com/docs/en/agent-teams) highlights several workflows where this matters:

**Multi-hypothesis debugging**: spawn multiple debuggers with different theories. Unlike the subagent version where each reports independently, teammates share confirming and contradicting evidence via `SendMessage`, actively challenging each other's assumptions. Sequential investigation suffers from confirmation bias; parallel adversarial investigation surfaces the root cause faster because agents disprove each other's theories in real time, not after the fact.

**Implement-review loop**: the implementer and reviewer are teammates. After making changes, the implementer sends the reviewer a message with the modified files. The reviewer analyzes, sends issues back. The implementer fixes and messages again. This tight loop bypasses the lead entirely, reducing latency. With subagents, each review cycle would require a full round-trip through the orchestrator.

**Cross-layer coordination**: changes that span frontend, backend, and tests, each owned by a different teammate. Task dependencies enforce the ordering: the backend teammate's API changes must land before the frontend teammate integrates against them. Each teammate works in its own context without the lead relaying messages between them.

**Feature development**: end-to-end pipeline in a single session. One teammate gathers context, another designs the approach, a third implements, a fourth reviews. Task dependencies block the implementer until the design is complete. This is a full delivery pipeline where the lead coordinates but does not do the work itself.

**Research swarm**: multiple researchers investigate different aspects of a problem, sharing findings with each other as they go. "I found the config parsing logic in `src/config/`, relates to the schema change you were tracking." They converge on a comprehensive understanding faster than independent subagents could, because each discovery redirects the others' investigation.

### File ownership

This is the hardest coordination problem in agent teams: **two agents editing the same file interfere with each other**. Agents do not share a filesystem lock. If one implementer modifies `src/auth.ts` while another modifies the same file, the second agent discovers the file has changed underneath it, is forced to re-read before editing, and may not understand why its expected state no longer matches. In the best case this wastes time on unnecessary investigation; in the worst case the agent reverts the other's changes, believing they are unintended.

The lead must partition work so each teammate owns distinct file sets. For a refactor spanning many files, you might assign one implementer to the `src/api/` directory and another to `src/models/`. The partition must be communicated in the task description, and teammates must respect it. Worktree isolation (covered in the next section) offers a stronger guarantee by giving each agent its own working copy of the repository.

The most ambitious public stress test of these patterns is Anthropic's own C compiler experiment[^c-compiler]: 16 parallel agents, running across ~2,000 Claude Code sessions over two weeks, produced a 100,000-line Rust-based C compiler capable of building Linux 6.9 on x86, ARM, and RISC-V. The key lesson was not about the agents themselves but about the harness. Agents work autonomously, so the test suite becomes the steering mechanism — if the verifier is imperfect, the agents solve the wrong problem. The experiment also surfaced a fundamental limitation of parallelism: when all agents hit the same bug in a monolithic task, they overwrite each other's fixes. The solution was to partition work using GCC as an oracle, randomly compiling most files with GCC and only the remainder with the new compiler, so each agent could work on a different failing file in parallel.

[^c-compiler]: Nicholas Carlini, [Building a C compiler with a team of parallel Claudes](https://www.anthropic.com/engineering/building-c-compiler) (Feb 2026). The total cost was approximately $20,000 in API usage.

### Honest limitations

Agent teams are powerful, but they are not free:

- **Cost.** N agents means roughly Nx the token cost. A four-agent team running opus costs four times what a single agent would.
- **Complexity.** Agents can miscommunicate, duplicate work, or claim the same task. The lead must actively manage coordination.
- **Diminishing returns.** Not every task benefits from parallelism. A simple bug fix with a clear root cause calls for one focused session.
- **File conflicts.** Two agents editing the same file leads to confusion, wasted investigation, and potential reverts. Partitioning work across distinct files is the safest approach; worktree isolation offers an alternative at the git level.

The judgment call (when to use a single agent, when to spawn subagents, when to assemble a full team) is a skill that develops with practice. The cost of under-parallelizing is slower delivery. The cost of over-parallelizing is wasted tokens and coordination overhead.

## Worktree Isolation

The file ownership constraint from agent teams has a clean solution at the git level: [worktrees](https://git-scm.com/docs/git-worktree). A git worktree is a separate working directory checked out from the same repository. Multiple worktrees share the same `.git` history, but each has its own branch and its own files. Changes in one worktree do not affect the others until you explicitly merge.

Claude Code uses worktrees to give each agent or session an isolated workspace. The `--worktree` flag starts a new session in its own directory:

```bash
claude --worktree auth-refactor
```

This creates a branch (e.g., `worktree-auth-refactor`), checks it out in a separate directory, and runs the session there. Any file the agent reads or modifies is isolated from the main working tree. Other sessions — or teammates in an agent team — operate on their own branches without conflict.

For subagents, worktree isolation can be declared directly in the agent definition via `isolation: worktree` in the frontmatter. The system automatically creates a temporary worktree when the subagent starts and cleans it up if no changes were made. This bridges the subagent and worktree concepts: a reviewer subagent that needs to test experimental changes can do so in its own branch without affecting the main session.

Agents can also enter and exit worktrees mid-session via the `EnterWorktree` and `ExitWorktree` tools. In a team context, the lead assigns each teammate to a distinct worktree at the start, eliminating the need for careful file partitioning. The implementer working on `src/api/` and the implementer working on `src/models/` no longer need to stay out of each other's way; they each have their own copy of the entire repository.

{{< admonition tip "Parallel sessions" >}}

A common pattern: open three terminals, each with a worktree session. One implements a feature, one fixes a bug, one updates documentation. Each works at full speed with no coordination overhead. The merges happen at the end, on your schedule, through the same PR review process you already use.

{{< /admonition >}}

Worktrees defer conflict resolution rather than eliminating it. Two agents modifying the same function on different branches will produce a merge conflict when those branches converge. But a merge conflict is a controlled, reviewable event — far better than the confusion of mid-session file contention. And for most agent team workflows, where the lead partitions work into independent areas, conflicts are rare. When they do occur, the main agent handles merge resolution well — it can read both sides of the conflict, understand the intent behind each change, and produce a clean merge.

The broader point: worktrees turn a coordination problem (two agents contending for the same file) into a standard git workflow problem (merging branches). It simply reuses what version control already provides.

## Context Management

Worktrees solve file-level coordination. But there is another resource that grows scarce as sessions extend and agents multiply: the context window itself.

Recall from [Part 1](../part-1/#what-is-an-llm) that the context window is the model's working memory. Everything it can "see" — your messages, system instructions, file contents, tool results, agent reports — must fit within this window. A typical multi-step investigation (reading files, running commands, spawning subagents, reviewing their reports) can consume tens of thousands of tokens before the agent begins synthesizing an answer. Without a mechanism to manage this growth, sessions eventually stall or lose track of earlier context.

Claude Code handles this through a compaction pipeline[^compaction] that operates transparently during normal use.

[^compaction]: See the [context management documentation](https://code.claude.com/docs/en/context-window) for details on compaction behavior and configuration.

### Auto-compaction

When the token count approaches the context window limit, the system triggers auto-compaction: a process that summarizes the conversation history and replaces older turns with a compressed representation.

What survives compaction: the system prompt, all CLAUDE.md files, the current task list, recent conversation turns, a summary of modified files, and continuation instructions that help the agent resume where the summary left off. What gets compressed: early conversation turns, old search results, redundant tool outputs, and intermediate reasoning that has already been resolved.

Compaction is lossy but structured. The system prioritizes preserving information the agent needs to continue working — current state, decisions made, files changed — over information that served only the moment, like a search result that has already been processed. The analogy is a project manager's notebook: you keep the current agenda and recent decisions on your desk, but archive older meeting notes. They are findable if needed, but they are not competing for your attention.

### Manual compaction

The `/compact` command triggers compaction on demand, with an optional focus hint:

```text
/compact focus on the auth refactoring decisions and ignore the earlier exploration
```

This is useful at natural task boundaries. After finishing a complex investigation and before starting implementation, a manual compact clears the investigation context and preserves only the conclusions. The focus hint guides the summarizer toward what matters for the next phase.

In practice, manual compaction should be used more aggressively than most people realize. Even though flagship models like Opus 4.6 advertise a 1M-token context window, reasoning quality degrades well before that limit — typically 200-300K tokens is the effective ceiling for reliable work, and beyond 500K performance drops sharply. Compared to the earlier 200K window, the 1M expansion is better understood as breathing room — space to finish what you started without hitting a wall, not an invitation for marathon sessions. Compact when a logical task completes, not when the system forces you to.

That said, compaction itself is not free. Each compaction consumes tokens for the summarization pass, and information is inevitably lost. The better strategy is to avoid needing frequent compaction in the first place: start fresh sessions for genuinely new tasks rather than appending to an aging context, store durable knowledge in CLAUDE.md and auto memory rather than relying on it surviving compaction, and use structured specs as the source of truth that gets re-loaded cleanly each session. Tools like [OpenSpec](https://github.com/Fission-AI/OpenSpec) formalize this approach — specifications live as version-controlled Markdown files in the repository, separating current behavior from proposed changes, so each session loads a clean contract rather than reconstructing intent from a compacted conversation history. Compaction is a safety net, not a workflow.

### Practical implications

Context management is what makes the advanced patterns described in this article viable at scale. A complex debugging session that reads 15 files and runs 10 commands would exhaust a fixed-size context window long before reaching a conclusion. With compaction, the session extends its useful life, periodically compressing old context to make room for new work. But the strongest sessions are the ones that rarely need it — they start focused, stay scoped, and finish before the window fills.

For agent teams, each teammate has its own context window and its own compaction cycle. The orchestrator's context — which accumulates reports from all teammates — compacts independently. This means the orchestrator can coordinate a long-running team without running out of room. The quality of compaction summaries becomes the bottleneck, which is why the [output contract](#the-output-contract) matters: structured reports with clear status lines and concise findings compress better than free-form narratives.

A more resilient approach is to externalize coordination state entirely: maintain a `roadmap.md` or `tasks.md` in the repository that tracks progress, decisions, and remaining work. Each teammate reads and updates this file rather than relying on the lead's context to hold the full picture. If the lead's context compacts and loses details, the file is still there. This is the same principle as specs and memory — prefer git-managed files over ephemeral context. Vibe coding, at scale, turns out to be an exercise in project management: the documentation and communication patterns matter more than the code generation itself.

## The Full Stack

[Part 1](../part-1/#the-stack-so-far) covered layers 1-7 (raw LLM through plugins). This part adds the final two:

| Layer       | What it solves                    | What it cannot do     |
| ----------- | --------------------------------- | --------------------- |
| Subagents   | Focused delegation, parallel work | Peer communication    |
| Agent Teams | Full coordination, shared tasks   | Replace your judgment |

Worktree isolation and context management sit underneath this stack as supporting infrastructure. Worktrees make parallel execution safe; compaction makes long sessions sustainable.

There is a meta-observation worth making: this entire configuration system (the CLAUDE.md files, the hooks, the agents, the permission model) was itself partially built and maintained using Claude Code. The tool is self-hosting in a meaningful sense: agents helped write the definitions of agents. If the configuration surface looks daunting, remember that you do not have to set it up alone — the agent itself can scaffold, iterate, and maintain these files for you.

### The broader ecosystem

These orchestration patterns are not unique to Claude Code. The open-source ecosystem has been converging on the same architecture from different directions — [OpenCode](https://github.com/anomalyco/opencode), which we [compared in Part 1](../part-1/#why-claude-code), implements the same agent concepts decoupled from any specific model provider. The patterns themselves (delegation, isolation, coordination) are sound, independent of which LLM executes them.

The [learn-claude-code](https://github.com/shareAI-lab/learn-claude-code) project (50,000+ stars) reverse-engineered Claude Code's architecture into a 12-session curriculum that mirrors the progression of this article: from a minimal agent loop through tool use, planning, subagents, context compaction, task systems, agent teams, and worktree isolation. Their central framing is worth borrowing: _the model is the agent; the code is the harness_[^harness]. The intelligence lives in the model. Everything we have been calling "context engineering" throughout this article is, in their vocabulary, harness engineering — building the tools, knowledge, permissions, and coordination infrastructure that lets the intelligence operate effectively. The model is half the system; the harness is the other half. Neither is dispensable, and the most capable working systems are the ones that invest in both.

[Oh My OpenAgent](https://github.com/code-yeongyu/oh-my-openagent) (50,000+ stars) demonstrates this on both fronts. On the harness side, its hash-anchored edit tool — where every line carries a content hash that rejects edits against stale file state — reportedly took one model from a 6.7% to 68.3% success rate on a code editing benchmark[^harness-problem]. The model was the same; the edit mechanism changed. On the model side, the project routes different task categories to different providers automatically: visual engineering tasks go to a vision-specialized model, deep reasoning goes to GPT-5.4, fast exploration goes to a lightweight model. This is the [model selection](#model-selection) approach we described for subagents, taken to its logical extreme across provider boundaries.

[^harness]: The "harness engineering" framing originates from the learn-claude-code project. See their [README](https://github.com/shareAI-lab/learn-claude-code) for the full philosophy.

[^harness-problem]: Source: Can Bölük, [The Harness Problem](https://blog.can.ac/2026/02/12/the-harness-problem/). The benchmark was Terminal Bench using Grok Code Fast 1.

### Where this is going

The trajectory from "prompt engineering" (2024) to "context engineering" (2026) points toward something we might call "organization engineering": the skill of decomposing problems into delegable units, assigning them to the right specialist with the right context, and coordinating the results. The ecosystem's move toward multi-model orchestration suggests the next step — not just picking the right specialist, but picking the right _kind_ of intelligence for each task. These are fundamentally human skills, the same skills that make a good project manager, a good research director, a good leader.

The tool is only as good as the person directing it. Understanding the layers is understanding the leverage points. And the leverage, at every level, comes from the same place: knowing what the agent needs to see, when it needs to see it, and what you can safely leave out.
