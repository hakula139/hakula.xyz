---
title: "LLM Intro: From the Basics to Context Engineering (Part 1)"
date: 2026-03-13T15:25:00+08:00

tags: [AI, LLM, Claude Code, MCP, Skill, Plugin]
categories: [tutorial]
license: CC BY-NC-SA 4.0
---

A practical guide to LLM agents, from foundational concepts to building a production-ready agent configuration. Part 1 of a two-part series: what an LLM actually is, how it becomes an agent, and the layered system (CLAUDE.md, hooks, MCP, skills, plugins) that makes it useful in practice. [Part 2](../part-2/) covers subagents, agent teams, and more advanced topics. Written for everyone, regardless of technical background.

<!--more-->

## Introduction

Picture this scenario. You're deploying a hotfix to the data pipeline on a Friday afternoon. In one terminal, an agent team is reviewing the pull request, three reviewers working in parallel, each focused on a different angle: correctness, security, and consistency with existing patterns. In another terminal, a researcher agent is tracing a regression in the ETL pipeline that surfaced this morning, cross-referencing logs with recent schema changes. A third session has an implementer drafting API documentation for the new endpoint your team shipped this week. All of this is happening simultaneously, coordinated through shared task lists and direct messaging between agents, while you focus on the deployment itself.

This is not science fiction, and it is not a product demo. The system that enables it, Claude Code with its full agent orchestration stack, is what this two-part series is about.

The thesis is straightforward: LLM agents are a **layered system of context engineering**. Each layer solves a specific problem the previous layer could not. The progression is natural and, once you see it, almost inevitable:

1. A raw LLM predicts text. It cannot act on the world.
2. Give it tools, and it becomes an agent, but it forgets everything between sessions. You have to repeat yourself every time.
3. Persistent instructions solve the memory problem. The agent reads your preferences at the start of every session, but these are suggestions, not constraints: nothing prevents the agent from ignoring them.
4. Hooks enforce at the system level, operating outside the model's reasoning entirely. They are reactive, though, and cannot teach the agent new procedures or give it structured access to external systems.
5. MCP servers provide that structured access: typed interfaces to Git, GitHub, databases, and thousands of other tools. Raw capabilities still need packaging into reusable workflows.
6. Skills combine instructions and tools into on-demand procedures, loaded only when invoked instead of sitting in context permanently. But someone has to author and maintain each one.
7. Plugins turn skills into a shareable ecosystem. Still, everything runs in a single context window.
8. Subagents give each task its own context, but their summaries still flow back and fill the main agent's window. They cannot communicate with each other.
9. Agent teams close that loop with shared task lists, direct messaging, and full parallel coordination, which is the state of the art by the time of this writing (March 2026).

This article covers layers 1–7. [Part 2](../part-2/) continues with subagents and agent teams.

Whether you write code, build models, review contracts, or manage operations, the underlying principles are the same. The context window is working memory. Everything that goes into it costs something. The art is in managing what gets loaded, when, and for how long. This is what the field now calls **context engineering**, and it is the central framework for this entire article.

## What Is an LLM

A large language model (LLM) predicts the next token. That single sentence describes what happens at inference time, and everything else (the apparent reasoning, the code generation, the ability to summarize a 50-page contract) is emergent behavior from this one mechanism.

A token is not a word. LLMs use **subword tokenization**: common words map to single tokens, but rarer words get split into pieces. The word "quantitative" might be three tokens; "the" is one. Code tokenizes differently from prose: a Python function signature is a dense sequence of small tokens, while natural language flows in longer chunks. This matters because the model's context window is measured in tokens, not words, and understanding the unit of measurement helps you reason about capacity.

Training is pattern extraction at massive scale. The model processes billions of documents (books, code, papers, web pages) and learns statistical relationships between tokens. It is not storing a database of facts, nor is it searching the Internet. It has learned _patterns_ of how text follows text, and it applies those patterns to generate continuations that are statistically plausible given what came before. This distinction matters: a database retrieves facts, while a language model _generates_ text that resembles factual language, which is a fundamentally different operation.

The **context window** is the fundamental constraint, and the concept that frames everything in this article. Think of it as working memory, or RAM. When you interact with an LLM, everything it can "see" (your message, the system instructions, any files it has read, any tool results it has received) must fit within this window. The window has grown dramatically (from 4K tokens in early GPT 3 to 1M in today's flagship models), but it remains finite, and the advertised number overstates what you actually get. A model with a 1M-token input capacity does not reason equally well over all of it: effective attention degrades well before the limit, with most models losing track of instructions and details beyond roughly 128K tokens. The input window is wide, but the reasoning window is narrow. Every piece of context you load displaces something else. This is the bottleneck for everything that follows.

{{< admonition warning "Known limitations" >}}

LLMs hallucinate: they generate confident-sounding text that is factually wrong. Their knowledge has a training cutoff date. They have no mechanism for verifying their own output against ground truth. These are not bugs to be fixed in the next release; they are structural properties of the architecture. Any serious use of LLMs must account for them.

{{< /admonition >}}

So we have a powerful text predictor. It can generate code, summarize documents, analyze arguments. But it has no memory between sessions, no tools, no ability to act on the world. It is a brain in a jar.

## From Chat to Agent

The default interaction model is chat: you write a message, the model responds, you write another. System prompt sets the behavior, user message provides the input, assistant message is the output. Each conversation is stateless; the model has no memory of previous sessions.

The conceptual leap that turns a chatbot into an agent is **tool use**. Instead of only generating text, the model can decide to call functions: read a file, run a shell command, search a codebase, query a database, fetch a web page. The model outputs a structured request ("I want to read `src/config.ts`"), the system executes it, and the result goes back into the context window for the model to process. Then it decides what to do next.

This changes everything. Instead of asking "how do I fix this test?" and getting a generic answer, an engineer can ask the model to _read_ the failing test, and it actually reads it. Then you ask it to find where the function under test is defined, and it searches the codebase and shows you. You ask it to propose a fix, it edits the file. You ask it to run the test again, it does. Each step still involves human judgment (you decide what to ask next), but the model is no longer answering questions _about_ code; it is working on the codebase directly. And this pattern extends well beyond software engineering.

The mechanism by which agents discover and use tools is the **Model Context Protocol** (MCP), an open standard that Anthropic donated to the Linux Foundation in 2025. MCP defines a structured interface: a server exposes tools with typed inputs and outputs, and the agent learns to use them from their descriptions, analogous to reading `--help` output. By the time of this writing (March 2026), the ecosystem has grown to over 18,000 MCP servers[^mcp-servers] covering Git, GitHub, Slack, databases, cloud infrastructure, web search, and anything else that exposes an MCP interface. The analogy to humans is direct: a person is bad at multiplying large numbers, but a person with a calculator is not. The tool compensates for the limitation. LLMs hallucinate facts, but an LLM with a search tool can look things up; an LLM with a code execution tool can run the computation instead of guessing the answer. The model does not need to _know_ everything, it needs to know _how to get_ the answer. We will return to MCP in detail later; for now, the point is that tools are how an LLM stops being a chatbot and starts being an agent.

[^mcp-servers]: Source: [mcp.so](https://mcp.so), the community registry for MCP servers.

### The agentic loop

Take the human out of the loop and you get what practitioners call the **agentic loop**: the model plans an approach, makes a tool call, observes the result, and decides what to do next, autonomously, until the task is done. A quant researcher does not need to guide each step; they describe the goal ("find what drove last quarter's drawdown") and the agent pulls factor exposures, runs correlation analysis, reads the output, spots an anomaly in momentum exposure, and keeps digging. A data engineer says "figure out why nulls spiked in the orders table" and the agent queries the table, traces the spike to a schema migration in the ETL logs, and drafts a fix. The pattern is always the same: plan, act, observe, adapt.

But there is a cost. Every tool call result, every file read, every command output goes into the context window. A ten-step investigation that reads five files and runs three commands has consumed a significant chunk of the model's working memory before it even starts reasoning about the answer. This is where the concept of **context engineering** becomes central. "Prompt engineering" (writing good instructions) is one piece. But managing the full contents of the context window across a multi-step agentic session, deciding what to load and what to discard, keeping the model focused on relevant information as the window fills up. That is the whole game. The 2025 framing of this field was "prompt engineering". The 2026 framing is "context engineering".

{{< admonition quote "Context Engineering" >}}

Andrej Karpathy, the former head of AI at Tesla, coined the shift: "The hottest new programming language is English." By 2026, the community has refined this further: it is not just about the words you type, but about the entire information environment the model operates in. Context engineering is the discipline of constructing and managing that environment.

{{< /admonition >}}

The question is no longer "can an LLM do this?". Most things that can be expressed as a sequence of tool calls, it can attempt. The question is which agent to use, and how to set up the procedure for maximum efficiency.

## Why Claude Code

The 2026 landscape for AI coding tools is crowded. Here is an opinionated comparison of the major options[^tool-ratings]:

|              | Claude Code | Codex CLI | Gemini CLI | OpenCode | Cursor     |
| ------------ | ----------- | --------- | ---------- | -------- | ---------- |
| Intelligence | ★★★★★       | ★★★★★     | ★★★        | ★★★★     | ★★★★       |
| Tool Using   | ★★★★★       | ★★★★      | ★★         | ★★★      | ★★★        |
| Reliability  | ★★★★★       | ★★★★      | ★★★        | ★★★      | ★★★        |
| Ecosystem    | ★★★★★       | ★★        | ★★         | ★★★★     | ★★★★       |
| Speed        | ★★★★★       | ★★★       | ★★★★       | ★★★★★    | ★★★★★      |
| Cost         | ＄＄＄＄    | ＄        | ＄         | Depends  | ＄＄＄＄＄ |

[^tool-ratings]: Ratings reflect practical experience across multiple production setups. Intelligence and reliability depend on the model: OpenCode with Opus 4.6 or GPT 5.4 approaches top-tier reasoning, but tool calling reliability suffers compared to native integrations. Gemini's model is capable on paper, but tool calling and code generation lag behind in practice.

The tools differ not just in capability but in philosophy. **Claude Code** advocates full automation: you describe the goal, the agent executes end-to-end, and you review the result. Anthropic calls this "vibe coding" and it is the default interaction model for CLI agents. **Codex CLI** takes a more supervised approach: the agent runs locally with OS-level sandboxing and checks in at key decision points, emphasizing human oversight over full autonomy. **Cursor** has agentic capabilities too, but its design philosophy centers on the programmer reviewing diffs: the agent proposes changes, you read the diff, accept or reject, and iterate. It also has the best tab completion on the market, which alone makes it nearly the only viable IDE choice alongside Copilot for developers who rely on inline suggestions while typing. **OpenCode** has a different philosophy: decouple the agent from the model. The tool is provider-agnostic, so you can swap models without switching workflows. But this decoupling comes at a cost: tool calling reliability varies across providers, and the plugin ecosystem is sparse compared to first-party integrations. **Gemini CLI** has the most generous free tier, but the tool calling and code editing quality are far enough behind that it is difficult to recommend for production work.

Claude Code is arguably the best CLI agent on the market today, so it is where we will spend the rest of this article. It operates on your local filesystem with the permissions you grant it. There is no IDE dependency, no cloud sandbox, no intermediate layer between the agent and your codebase. This has consequences, both positive and negative.

The positive side is depth of control. Claude Code supports a full configuration hierarchy (CLAUDE.md files at global, project, and directory levels), lifecycle hooks that enforce rules through shell commands, reusable skill definitions, a subagent system for focused delegation, and full agent teams with peer-to-peer communication and shared task management. It supports multiple model tiers (opus for deep reasoning, sonnet for balanced tasks, haiku for fast lookups) and lets you assign different models to different agents based on task complexity. In an independent benchmark from August 2025[^token-efficiency], the same Next.js task consumed 33K tokens in Claude Code (Opus 4.1), 102K in Codex (GPT 5, which failed to compile), and 188K in Cursor Agent (GPT 5) — making Claude Code 3x more token-efficient than Codex and 5.5x more than Cursor. This is a single task with different underlying models, and both the models (now Opus 4.6 and GPT 5.4) and the tools have evolved rapidly since, so the exact numbers may no longer hold. Still, it points to a real advantage in how Claude Code manages context programmatically.

[^token-efficiency]: Source: [Ian Nuttall on X](https://x.com/iannuttall/status/1953833034794651649).

The negative side is real. The learning curve is steeper than an IDE plugin. The CLI interface is a barrier for people who live in graphical editors. Costs scale with usage; opus-tier models are expensive, and running agent teams multiplies that cost by the number of agents. If your primary need is inline code completion while typing, Cursor or Copilot will serve you better with less friction. That said, the learning curve is not as steep as it looks — the core workflow (type a prompt, review the diff, accept or reject) is something most people internalize within a few sessions, and the productivity gain from full agentic automation compounds fast enough to justify the investment.

{{< admonition tip "Tool selection" >}}

These tools are not mutually exclusive. Many practitioners use Cursor for line-level completion in their editor and Claude Code for multi-file tasks, architecture decisions, and agent orchestration from the terminal. The question is not "which one" but "which one for what". If Claude Code access is difficult to obtain, Codex CLI is a strong fallback with comparable reasoning; OpenCode with a capable model (GPT or open-source models like GLM 5) is another option, though with weaker tool calling reliability.

{{< /admonition >}}

The reason this article focuses on Claude Code specifically is that it exposes the full stack of context engineering layers, from raw chat through to coordinated agent teams. Understanding these layers is useful regardless of which tool you end up using, because the underlying concepts (persistent instructions, lifecycle hooks, focused delegation, team coordination) apply to any serious agent system.

You have chosen your tool. Now what? You start chatting.

## Prompt Engineering and Its Limits

The first layer of context engineering is the prompt itself, the text you type into the chat. Good prompts are specific, contextual, and iterative. The difference between a useful and useless interaction often comes down to how much relevant context you provide upfront.

### Good prompts vs. bad prompts

Consider a few examples across different roles:

**Software engineer:**

- Weak: "fix the bug"
- Strong: "The function `parseConfig` on line 47 of `src/config.ts` throws a TypeError when the input JSON has a missing `name` field. Add a null check with a descriptive error message."

The strong version gives the model everything it needs to act without searching: the file, the line, the symptom, the expected fix.

**Quant researcher:**

- Weak: "analyze this strategy"
- Strong: "Read the backtest results in `results/momentum_v3.csv`, identify the three largest drawdown periods, and cross-reference each with the VIX level on those dates. Use the data in `data/vix_daily.csv`."

The strong version specifies the files, the analysis, and the data sources. The model can execute this as a concrete workflow.

**Legal / compliance:**

- Weak: "summarize the regulation"
- Strong: "Extract all reporting obligations from SEC Rule 10b-5 that apply to a fund with AUM > \$1B, organized by deadline frequency (daily, quarterly, annual)."

Specificity transforms a vague reading assignment into a structured extraction task.

### Why chat alone breaks down

Even with excellent prompts, the chat paradigm has a structural problem: **every session starts from zero**. The model does not remember your previous conversations. It does not know your project structure, your coding conventions, your team's terminology, or where your data lives. So you find yourself repeating the same context over and over:

- "We use TypeScript with strict mode."
- "Our data pipeline config is in `config/etl/`."
- "Always use the MCP Git tools instead of the `git` CLI."

Each repetition consumes context window space that could be used for actual work. You are hand-loading the RAM every session, copying the same instructions into the same machine, burning tokens on boilerplate instead of analysis.

There has to be a better way. What if you could write your preferences down once and have the agent read them automatically every time it starts?

## CLAUDE.md, Rules, and Memory

[CLAUDE.md](https://code.claude.com/docs/en/memory) is the answer to the repetition problem. It is a Markdown file (which is a type of plain text) that the agent reads at the start of every session, automatically. No need to paste instructions; they are always in context.

### The CLAUDE.md hierarchy

The system supports a cascading hierarchy, similar to CSS specificity:

1. **Global** (`~/.claude/CLAUDE.md`): applies to every project, every session.
2. **Project** (`CLAUDE.md` at project root): applies to this specific codebase.
3. **Directory-level** (`CLAUDE.md` in any subdirectory): applies when working in that directory.

Each level inherits from the one above and can override or extend it. A global file might define your communication style and tool preferences; a project file adds codebase-specific conventions; a directory file adds section-specific writing rules.

### What goes in each level

Here is a concrete example from my own configuration.

**Global** (`~/.claude/CLAUDE.md`) covers communication style, code quality principles, commenting guidelines, and MCP server usage patterns:

```markdown
## Communication Style

Be direct, honest, and skeptical. Criticism is valuable.

- **Challenge my assumptions.** Point out when I'm wrong, mistaken, or appear to be heading in
  the wrong direction.
- **Suggest better approaches.** If you see a more efficient, cleaner, or more standard way to
  solve something, speak up.
- **Educate on standards.** Highlight relevant conventions, best practices, or standards I might
  be missing.
- **Be concise by default.** Short summaries are fine. Save extended explanations for when we're
  actively working through implementation details or complex plans.
- **Ask rather than assume.** If my intent is unclear, ask questions. Don't guess and proceed.
  Clarify first.
- **No unnecessary flattery.** Skip compliments and praise unless I specifically ask for your
  judgment on something.

## Code Quality Principles

Follow the DRY (Don't Repeat Yourself) principle.

Always look for opportunities to reuse code rather than duplicate logic. Factor out common
patterns into reusable functions, modules, or abstractions.

## Documentation Philosophy

Create documentation only when explicitly requested.

Do not proactively generate documentation files (README, API docs, etc.) after routine code
changes. Documentation should be intentional, not automatic.

When documentation is requested, make it:

- Clear and actionable
- Focused on "why" and "how to use" rather than "what" (which code should show)
- Up-to-date with the actual implementation

## Commenting Guidelines

Comment the WHY, not the WHAT.

Code should be self-explanatory through clear naming and structure. Add comments only when the
code itself cannot convey important context:

When to add comments:

- **Complex algorithms** - Non-obvious logic that requires explanation of the approach
- **Business rules** - Domain-specific constraints or decisions that aren't apparent from code alone
- **Magic numbers** - Hardcoded values that need justification
- **Workarounds** - Temporary fixes, hacks, or solutions to known issues (explain why and link to
  issues if possible)
- **Performance / security considerations** - Critical optimizations or security-sensitive sections

When editing existing code:

- Preserve existing comments unless they're outdated or wrong
- Update comments if the code logic changes

Avoid:

- Comments that simply restate what the code does
- Obvious explanations that clutter the code
- Commented-out code (use version control instead)

## MCP Server Usage

Prefer MCP tools over equivalent Bash commands or web searches. MCPs provide structured
interfaces, better error handling, and work within the configured permission model.
```

The global file also defines the entire agent team workflow: available agent types, model selection guidelines, coordination patterns, team presets, and the output contract all agents must follow. This is roughly 300 lines that establish the operational framework for every session. We will cover this in detail in [Part 2](../part-2/).

**Project** (`CLAUDE.md` in a Rust static site generator repo) covers project structure, coding conventions, and verification workflow:

````markdown
## Project Overview

kiln is a custom static site generator (SSG) written in Rust.

### CLI

```bash
kiln build [--root <dir>]        # Build the site (default root: cwd)
kiln init-theme <name> [--root]  # Scaffold a new theme under themes/<name>/
```

### Project Layout

```text
.
├── config.toml   # Site configuration (TOML)
├── content/      # Markdown content (posts, standalone pages)
├── static/       # Static files copied to output root (favicons, images)
├── templates/    # MiniJinja templates (site overrides theme)
├── themes/       # Themes (git submodules), each with templates/ + static/
├── crates/kiln/  # SSG engine — library (lib.rs) + CLI binary (main.rs)
└── public/       # Build output (configurable via output_dir)
```

## Coding Conventions

### Error Handling

- Application code: `anyhow::Result` with `.context()` for actionable messages.
- Library error types: `thiserror::Error` derive for errors that callers need to match on.

### Lint Suppression

- Use `#[expect(lint)]` instead of `#[allow(lint)]`. `#[expect]` warns when the suppressed lint
  is no longer triggered, preventing stale suppressions from accumulating.

### Module Organization

- New-style module paths: `foo.rs` alongside `foo/` directory, not `foo/mod.rs`.
- Keep files focused: one primary type or concern per file.
- Place functions and types in the module that reflects their conceptual domain — import paths
  should not mislead about what the item does.
- Avoid deep `pub use` re-export chains that obscure where items are defined.
- Order helper functions by their caller.

### String Literals

- Prefer raw strings (`r#"..."#`) when the string contains characters that would need escaping.

### Enum String Mappings

- Use `strum` derives (`AsRefStr`, `EnumString`, `EnumIter`) for enum ↔ string conversions
  instead of handwritten matches.
- Keep manual `Display` impls when the display form differs from the serialized form.

### Dependencies

- Versions centralized in `[workspace.dependencies]` in the root `Cargo.toml`. Member crates
  reference them with `dep.workspace = true`.
- Only add dependencies to the workspace when a PR first needs them.
- Prefer crates with minimal transitive dependencies.

### Git Conventions

- Commit messages: `type(scope): description`
  - Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `style`, `perf`
  - Scope: crate or module name (e.g., `kiln`, `config`, `render`)
- Feature branches: `feat/<feature-name>`
- Keep commits atomic — one logical change per commit.

### Testing

- Unit tests in the same file as the code they test (`#[cfg(test)]` module).
- Integration tests in `tests/` directory for cross-module behavior.
- Group tests by function under `// -- function_name --` section headers. Within each section,
  order: happy path → variants → error cases.
- Test name prefixes should match the section's function name.
- Error-case test names use a return-type suffix: `_returns_error` (`Result`), `_returns_none`
  (`Option`), `_returns_false` (`bool`).
- Use `indoc!` for multi-line test inputs whenever possible.

## Verification

Run after implementation and before review:

```bash
cargo build
cargo clippy --all-targets -- -D warnings  # zero warnings (pedantic lints)
cargo test
cargo llvm-cov --ignore-filename-regex 'main\.rs'  # check test coverage
```

## Code Review

After verification passes, run a dual review using both a reviewer subagent and a Codex MCP
reviewer in parallel. Focus on:

- Correctness and edge cases
- Adherence to project conventions (this file)
- Conciseness — prefer the simplest idiomatic solution
- Existing crates — flag hand-written logic that an established crate already handles
- Test coverage gaps
````

### Settings and permissions

Beyond CLAUDE.md, the agent's behavior is governed by `settings.json`, which includes a permission model: **allow** (auto-approved), **ask** (requires confirmation), and **deny** (always blocked).

My configuration defines over 250 auto-approved patterns spanning filesystem navigation, text processing, Git operations, development tools, network utilities, and container management. Destructive operations (`rm`, `kill`, `git push`) require explicit confirmation. Some operations are unconditionally blocked. Here is an excerpt:

```json
{
  "permissions": {
    "defaultMode": "acceptEdits",
    "allow": [
      "Bash(* --version)", "Bash(* --help)", "Bash(man *)",
      "Bash(cat *)", "Bash(head *)", "Bash(tail *)", "Bash(stat *)",
      "Bash(fd *)", "Bash(find *)", "Bash(grep *)", "Bash(rg *)",
      "Bash(cp *)", "Bash(mkdir *)", "Bash(mv *)", "Bash(touch *)",
      "Bash(awk *)", "Bash(jq *)", "Bash(sed *)", "Bash(sort *)",
      "Bash(curl *)", "Bash(dig *)", "Bash(ping *)", "Bash(wget *)",
      "Bash(git add *)", "Bash(git diff *)", "Bash(git log *)", "Bash(git status *)",
      "Bash(cargo *)", "Bash(node *)", "Bash(python3 *)", "Bash(go *)",
      "Bash(docker ps *)", "Bash(kubectl get *)", "Bash(systemctl status *)",
      "mcp__Filesystem", "mcp__Git",
      "WebFetch", "WebSearch"
    ],
    "ask": [
      "Bash(rm *)", "Bash(kill *)", "Bash(sudo *)",
      "Bash(git push *)", "Bash(git reset *)", "Bash(git branch -D *)",
      "Bash(docker push *)",
      "mcp__Git__git_reset"
    ],
    "deny": [
      "Bash(agenix -r *)", "Bash(agenix --rekey *)"
    ]
  }
}
```

The key insight is the layering: safe read operations are auto-approved, destructive writes require confirmation, and catastrophic operations are blocked entirely. This is context engineering at the system level — you are pre-loading the agent's environment with constraints that prevent categories of mistakes, without consuming context window space on repeated warnings.

### Memory

Claude Code's **auto memory** system (introduced in 2026) lets the agent save useful context across sessions. When the agent discovers something important (a debugging pattern, a user preference, a project convention), it can write it to a persistent memory directory. These memories are loaded into context at the start of future sessions, like a personal knowledge base that grows over time.

This is the machine equivalent of a senior engineer's institutional knowledge: "we tried X last quarter and it broke because of Y" or "the data team prefers Parquet over CSV for anything over 100MB".

{{< admonition tip "CLAUDE.md best practice" >}}

A community best practice that has emerged through 2026: keep CLAUDE.md under 150 lines. If Claude already does something correctly without being told, do not document it. Do not duplicate what linters and formatters already enforce; use hooks for that instead (covered in the next section). Every line in CLAUDE.md is a line that cannot be used for actual work.

{{< /admonition >}}

### What CLAUDE.md cannot do

CLAUDE.md is static text. It is loaded at session start and sits in the context window. It cannot:

- **React to runtime events.** If the agent writes a shell script with a syntax error, CLAUDE.md cannot trigger a linter.
- **Enforce anything.** CLAUDE.md is advisory: the model reads it, but it can choose to ignore it. There is no mechanism to block a non-compliant action.
- **Take action.** It cannot auto-format a file, send a notification, or reject a dangerous command.
- **Scale without cost.** A 2,000-line CLAUDE.md means 2,000 lines less for actual work in every session.

CLAUDE.md tells the agent what to do, but these are instructions, not constraints. The model reads them and generally follows them, but nothing _prevents_ it from doing otherwise. Every instruction in CLAUDE.md is advisory. For actual enforcement, you need mechanisms that operate outside the model's reasoning, at the system level.

## Hooks

[Hooks](https://docs.anthropic.com/en/docs/claude-code/hooks) are actions triggered at specific lifecycle events in the agent's operation — shell commands, HTTP endpoints, or even LLM prompts. They run _outside_ the model: the model does not decide whether a hook fires, and it cannot override a hook's decision. This is the difference between a suggestion and an enforcement mechanism.

### Hook events

Claude Code defines 17 lifecycle events. Here are the ones you will use most often:

- **PreToolUse**: fires before a tool is executed. Can approve, deny, or modify the call.
- **PostToolUse** / **PostToolUseFailure**: fires after a tool call succeeds or fails. Can inspect and act on the result.
- **UserPromptSubmit**: fires when you submit a prompt, before Claude processes it. Can block or transform it.
- **PermissionRequest**: fires when the agent requests permission for a restricted operation.
- **Stop**: fires when the agent finishes responding.
- **SessionStart** / **SessionEnd**: fires at the beginning or end of a session.
- **Notification**: fires when the agent needs user attention.

And these are more specialized:

- **SubagentStart** / **SubagentStop**: fires when a subagent is spawned or finishes.
- **TeammateIdle** / **TaskCompleted**: fires when a teammate goes idle or marks a task as completed (agent teams).
- **InstructionsLoaded**: fires when a CLAUDE.md or rules file is loaded into context.
- **ConfigChange**: fires when a configuration file changes during a session.
- **WorktreeCreate** / **WorktreeRemove**: fires when a git worktree is created or removed (for subagent isolation).
- **PreCompact**: fires before context compaction.

### Real examples

Hooks can be defined at global scope (`~/.claude/settings.json`) or project scope (`.claude/settings.json`). Project-scope hooks can be committed to the repo and shared with your team. Here are three examples from my configuration.

**Auto-formatting (PostToolUse):** After every file edit or write, this hook runs [Prettier](https://prettier.io) on the changed file:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write"
          }
        ]
      }
    ]
  }
}
```

The model never needs to think about formatting; it happens automatically, every time, with zero context window cost.

This is context engineering through subtraction: instead of writing "always format your code", duplicating the formatting logic in CLAUDE.md and hoping the model complies, the hook makes formatting automatic and invisible. The instruction is replaced by infrastructure.

**Enforce MCP (PreToolUse):** This hook blocks Bash commands that have MCP equivalents (like `git status` or `gh pr list`), forcing the agent to use structured MCP tools instead. We will see this in detail in the [MCP enforcement through hooks](#mcp-enforcement-through-hooks) section — it is a good example of how hooks and MCP reinforce each other.

**Notification (PermissionRequest):** When the agent needs user attention (a permission prompt or a question), this hook sends a desktop notification so you are not blocked waiting:

```json
{
  "hooks": {
    "PermissionRequest": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/notify-permission.sh"
          }
        ]
      }
    ]
  }
}
```

```bash
#!/usr/bin/env bash
# .claude/hooks/notify-permission.sh
tool_name="$(jq -r '.tool_name // empty')"
case "$tool_name" in
  AskUserQuestion)
    notify-send 'Claude Code' 'Question asked' ;;
  mcp__*)
    mcp_name="${tool_name#mcp__}"
    mcp_name="${mcp_name%%__*}"
    notify-send 'Claude Code' "$mcp_name permission requested" ;;
  *)
    notify-send 'Claude Code' "$tool_name permission requested" ;;
esac
```

The script parses `tool_name` from the JSON input on stdin and sends a desktop notification with `notify-send`. On macOS, replace with `osascript`; on WSL, you need a Windows-side toast tool since `notify-send` has no display server to talk to — my implementation uses [toasty](https://github.com/shanselman/toasty) and auto-detects the platform ([source](https://github.com/hakula139/nixos-config/blob/main/home/modules/notify/default.nix)). For complex hooks like this, extracting the logic into a separate script is cleaner than inlining escaped shell in JSON.

### Beyond shell commands

The examples above are all command hooks (`type: "command"`), but Claude Code supports three other handler types.

**HTTP hooks** (`type: "http"`) POST the event's JSON to a URL instead of running a shell command. This enables webhook integrations: send a Slack message when a task completes, log tool usage to an observability platform, trigger a CI pipeline when the agent modifies certain files.

**Prompt hooks** (`type: "prompt"`) send the event context to an LLM for single-turn evaluation. The LLM returns `{"ok": true}` to allow or `{"ok": false, "reason": "..."}` to block. This is useful when the decision requires judgment rather than a deterministic script check. A common pattern is a `Stop` hook that evaluates whether all tasks are actually complete before allowing the agent to finish:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Analyze the conversation: $ARGUMENTS\n\nDetermine if:\n1. All user-requested tasks are complete\n2. No errors need to be addressed\n3. No follow-up work is needed\n\nRespond with JSON: {\"ok\": true} or {\"ok\": false, \"reason\": \"...\"}",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

`$ARGUMENTS` is replaced with the hook's JSON input — the full conversation context. If the LLM returns `"ok": false`, Claude continues working with the provided reason as its next instruction. This is a lightweight way to keep the agent on track without writing complex validation scripts.

**Agent hooks** (`type: "agent"`) go one step further: they spawn a subagent that can use tools like Read, Grep, and Glob to verify conditions before returning a decision. Useful when verification requires inspecting actual files or test output, not just evaluating conversation context.

### The analogy

If CLAUDE.md is the employee handbook ("here is how we do things"), then hooks are the CI pipeline. The handbook tells you to write tests; the CI pipeline blocks the merge if you do not. Both are necessary. One is advisory; the other is enforced.

### What hooks cannot do

Hooks are **reactive**: they respond to events that the model initiates. They cannot:

- **Initiate workflows.** A hook cannot say "every Monday at 9 AM, run a code quality report". It can only react to tool calls, completions, and permissions.
- **Access model reasoning.** Hooks receive structured event data (tool name, input, output), but they have no visibility into _why_ the model made a decision.
- **Define reusable procedures.** A hook that triggers on every file write can format code, but it cannot define a 20-step deployment workflow that the agent can invoke on demand.

Hooks also cannot give the agent structured access to external systems. The agent still talks to Git, GitHub, databases, and every other service through raw shell commands, parsing unstructured terminal output. For typed, structured tool access, here comes the MCP (Model Context Protocol).

## MCP

We introduced [MCP](https://docs.anthropic.com/en/docs/claude-code/mcp) briefly in the agent section. Now it is time to look at it properly, because MCP is the infrastructure that makes everything else useful. Without MCP, an agent's only tool is a raw Bash shell, powerful but unstructured, with no type safety. Every command's output is dumped as raw text into the context window.

### What MCP actually provides

The **Model Context Protocol** defines a client-server architecture for tool use. An MCP server is a process that exposes a set of tools, each with a name, description, typed input schema, and typed output. The agent reads these definitions at startup and learns to call the tools by name. The key insight is that MCP tools return _structured_ data, not raw terminal output. When the agent calls `mcp__Git__git_status`, it gets a parsed status object, not a wall of colored text that it has to interpret with self-written Bash or Python scripts.

This matters for context engineering. Structured output is denser and more predictable than raw shell output. A `git diff` piped through Bash might produce 200 lines of noisy terminal output; the MCP equivalent returns the same information in a structured format that the model can parse reliably. Less noise means more room for actual work in the context window.

### Configuring MCP servers

MCP servers are configured in `~/.claude/settings.json` (global) or `.claude/settings.json` (project). Here is an excerpt from my configuration:

```json
{
  "mcpServers": {
    "Git": {
      "command": "uvx",
      "args": ["mcp-server-git"],
      "type": "stdio"
    },
    "Fetcher": {
      "command": "npx",
      "args": ["-y", "fetcher-mcp"],
      "type": "stdio"
    },
    "Context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"],
      "type": "stdio"
    },
    "DeepWiki": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "https://mcp.deepwiki.com/mcp", "--transport", "http-first"],
      "type": "stdio"
    },
    "Codex": {
      "command": "codex",
      "args": ["mcp-server"],
      "type": "stdio"
    }
  }
}
```

Each server brings capabilities that would be awkward or unreliable through raw shell commands:

- **Git MCP** returns structured data (diffs, logs, status) instead of raw terminal output. A `git diff` through Bash might dump 200 lines of colored text into the context window; the MCP equivalent returns the same information in a parsed format the model can consume reliably — denser and cheaper.
- **Fetcher MCP** runs a headless Playwright browser behind the scenes. Claude Code's built-in `WebFetch` tool uses a simple HTTP client that many sites block (Reddit, Wikipedia, etc. all return 403). Fetcher bypasses this by rendering the page in a real Chromium instance, so the agent can actually read the content. It is slower and heavier, but invaluable as a fallback.
- [**Context7**](https://context7.com) and [**DeepWiki**](https://deepwiki.com) are documentation servers. Context7 provides up-to-date library docs with code examples; DeepWiki builds AI-powered documentation for any GitHub repository and lets the agent ask questions about it interactively. These are direct countermeasures against hallucination. When the agent can look up the actual API instead of guessing from training data, it generates code that actually works.
- **Codex MCP** is a bridge to OpenAI's Codex CLI. The agent can delegate self-contained tasks to a GPT model with its own context window. What makes this most valuable is that it gives you a genuine second opinion from a different model family. Claude and GPT have different blind spots, and their disagreements are where the interesting insights live. The back-and-forth between them frequently produces better results than either model alone.

### MCP enforcement through hooks

With both hooks and MCP in place, they reinforce each other. Here is a `PreToolUse` hook that blocks Bash commands whenever an MCP equivalent exists, forcing the agent to use the structured tool instead:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/enforce-mcp.sh"
          }
        ]
      }
    ]
  }
}
```

The script reads the JSON input from stdin, checks the command, and returns a `permissionDecision` of `"deny"` with a redirect message:

```bash
#!/usr/bin/env bash
# .claude/hooks/enforce-mcp.sh
COMMAND=$(jq -r '.tool_input.command')

deny() {
  jq -n --arg reason "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
  exit 0
}

# Block gh CLI — use MCP GitHub tools
if [[ "$COMMAND" =~ ^[[:space:]]*gh[[:space:]] ]]; then
  deny "Use MCP GitHub tools (mcp__GitHub__*) instead of the gh CLI."
fi

# Block git subcommands that have MCP equivalents
if [[ "$COMMAND" =~ ^[[:space:]]*git[[:space:]]+(.*) ]]; then
  SUBCMD="${BASH_REMATCH[1]%% *}"
  case "$SUBCMD" in
    status) deny "Use mcp__Git__git_status instead." ;;
    diff)   deny "Use mcp__Git__git_diff instead." ;;
    log)    deny "Use mcp__Git__git_log instead." ;;
    add)    deny "Use mcp__Git__git_add instead." ;;
    # ... other subcommands with MCP equivalents
  esac
fi

exit 0  # allow everything else
```

The hook allows through git subcommands _without_ MCP equivalents (`git blame`, `git stash`, `git ls-files`) and special cases like `git commit --amend` and `git reset --hard` that the MCP tools do not cover.

This is where the two layers converge: hooks enforce _what_ the agent should use, MCP provides _how_ to use it properly. Instead of writing "always use MCP tools" in CLAUDE.md and hoping the model complies, the hook makes non-compliance impossible.

### The ecosystem

The ecosystem we [introduced earlier](#from-chat-to-agent) extends to internal tooling. Any team can build an MCP server for their own systems (e.g., an internal knowledge base), and the agent gains the ability to use it without any model fine-tuning. The agent does not need to know how your systems work at a protocol level; it needs an MCP server that wraps them with typed tool definitions. We will cover how to build a custom MCP server in a future article.

### What MCP cannot do

MCP gives the agent structured access to tools, but it does not tell the agent _when_ or _in what order_ to use them. The agent can call `mcp__Git__git_status` and `mcp__GitHub__create_pull_request`, but nothing defines a reusable procedure that chains these calls together with decision logic ("if tests pass, create a PR; if they fail, run the debugger"). Each session, the agent reasons from scratch about how to combine tools. For repeatable, multi-step workflows that persist across sessions, you need skills.

## Skills

[Skills](https://docs.anthropic.com/en/docs/claude-code/slash-commands) are Markdown files that define on-demand procedures. They live in `.claude/skills/`, and their descriptions are always loaded so the model knows what is available, but the full content only enters the context window when invoked — either explicitly via `/skill-name` or automatically when the model determines the skill is relevant to the current task.

### Skill anatomy

Here is the official `/commit` skill from Anthropic's [commit-commands](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/commit-commands) plugin:

```markdown
---
description: Create a git commit
allowed-tools:
  - Bash(git add *)
  - Bash(git status *)
  - Bash(git commit *)
---

## Context

- Current git status: !`git status`
- Current git diff: !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Your task

Based on the above changes, create a single git commit.
```

The key elements:

- **`description`** drives auto-invocation. When a user says "commit these changes", the model matches it to this skill without needing an explicit `/commit` command.
- **`allowed-tools`** restricts the agent to only specific Bash commands during execution. The pattern `Bash(git add *)` means the agent can run `git add` with any arguments, but cannot touch any other tool. This is defense in depth: even if the procedure says "just commit", the tool restriction makes it impossible to drift.
- **`!` backtick syntax** injects live context at invocation time. When the skill loads, `` !`git status` `` is replaced by the actual output of `git status`. The agent sees the current state of the repository, not a stale description. These commands execute _before_ the agent starts following the procedure, so they are not subject to `allowed-tools` restrictions — that is why `git diff` and `git log` work here even though only `git add`, `git status`, and `git commit` are allowed. All read operations happen during loading; the tool restrictions only govern what the agent does during execution.

Skills scale from simple (this one is 18 lines) to complex. The official [`/code-review`](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/code-review) skill is ~90 lines: it launches five parallel agents to review a PR from different angles (CLAUDE.md compliance, bugs, git history, prior PR comments, code comment adherence), scores each finding on a 0–100 confidence scale, filters out anything below 80, and posts a structured comment on the PR. A team-specific skill might create boilerplate across multiple files, register components in several different locations, and run a verification checklist — the kind of 30-minute manual runbook that the agent executes in one pass.

### How skills differ from CLAUDE.md

| Aspect           | CLAUDE.md                   | Skills                       |
| ---------------- | --------------------------- | ---------------------------- |
| Loading          | Always in context           | On-demand (explicit or auto) |
| Purpose          | Preferences and conventions | Specific procedures          |
| Tool access      | Unrestricted                | Can be restricted per skill  |
| Parameterization | Static                      | Can accept arguments         |

Skills are the agent's equivalent of runbooks. A compliance team could have a `/regulatory-review` skill that walks the agent through a structured analysis of a new regulation: extract obligations, map to existing controls, identify gaps, generate a summary for the legal team. An operations team could have a `/incident-postmortem` skill that guides the agent through timeline construction, root cause analysis, and action item generation from incident logs.

### What skills cannot do

Within a project, skills share naturally — commit them to `.claude/skills/` and everyone on the team has them. But for skills that live _outside_ your project (e.g., a documentation lookup skill, a general code review workflow), sharing means copying Markdown files from someone else's repo into yours. When the skill's author releases an improved version, you need to copy again. There is no way to subscribe to upstream changes.

Skills also cannot bundle related capabilities together. A code review workflow might need a skill, a set of specialized agents, custom hooks, and output style preferences. A standalone skill file cannot package all of these as a single installable unit.

## Plugins

[Plugins](https://code.claude.com/docs/en/discover-plugins) fill this gap. They are installable packages that bundle skills, agents, hooks, output styles, and settings together, distributed through a marketplace and auto-updated on each session. You enable a plugin once; it stays current.

### Why this matters

This is arguably Claude Code's strongest competitive advantage. Just as Anthropic created MCP and grew an ecosystem of thousands of servers[^mcp-servers], they are now doing the same for plugins: defining the standard for how plugins are structured, distributed, and discovered, and building the marketplace around it. The [official plugin directory](https://github.com/anthropics/claude-plugins-official) already hosts 40+ plugins (including third-party integrations like GitHub, Playwright, and Slack), [community-maintained registries](https://claudemarketplaces.com) aggregate thousands more across nearly 3,000 marketplaces (by the time of this writing), and any GitHub repository can serve as a plugin source.

### What plugins provide

My configuration enables 18+ plugins across three categories:

**Official**, Anthropic-maintained skill bundles and workflow extensions:

```json
{
  "enabledPlugins": {
    "document-skills@anthropic-agent-skills": true,
    "example-skills@anthropic-agent-skills": true,
    "code-review@claude-plugins-official": true,
    "feature-dev@claude-plugins-official": true,
    "pr-review-toolkit@claude-plugins-official": true,
    "hookify@claude-plugins-official": true,
    "security-guidance@claude-plugins-official": true
  }
}
```

The skill bundles add dozens of invocable skills: `/pdf` for PDF manipulation, `/pptx` for presentation creation, `/frontend-design` for production-grade UI generation, `/mcp-builder` for creating new MCP servers. Each skill carries its own tool restrictions and step-by-step procedures. The workflow plugins go further: `pr-review-toolkit` adds specialized review agents (type design analyzer, comment analyzer, silent failure hunter, test coverage analyzer) that go beyond what a generic reviewer provides; `hookify` lets you analyze a conversation for mistakes and automatically generate hooks to prevent them in the future.

**LSP integrations**, language server protocol plugins:

```json
{
  "enabledPlugins": {
    "clangd-lsp@claude-plugins-official": true,
    "gopls-lsp@claude-plugins-official": true,
    "pyright-lsp@claude-plugins-official": true,
    "rust-analyzer-lsp@claude-plugins-official": true,
    "typescript-lsp@claude-plugins-official": true
  }
}
```

These give the agent access to real-time language diagnostics (type errors, unused imports, lint warnings) from the same language servers your IDE uses. Without LSP, the agent writes code and discovers type errors only when you run the build — or worse, when you read the code and notice something wrong. With LSP, the agent gets the same red-squiggle feedback loop that a human developer gets in VS Code, except it can query diagnostics programmatically after every edit. It catches its own mistakes before you even look at the diff.

**Third-party plugins**, community contributions:

```json
{
  "enabledPlugins": {
    "context7-plugin@context7-marketplace": true,
    "agent-browser@agent-browser": true
  }
}
```

We [already saw](#configuring-mcp-servers) Context7 as an MCP server for documentation lookup, but the MCP server alone does not tell the agent _how_ to use it well. The plugin bundles a skill with proper instructions on top of the server, so the agent knows when and how to query docs effectively. [Agent-browser](https://github.com/vercel-labs/agent-browser) (by Vercel Labs) is a lightweight alternative to Playwright for browser automation: it uses accessibility snapshots with semantic element references (`@e1`, `@e2`) instead of full HTML, and a persistent Rust CLI + Node.js daemon architecture that avoids reinitializing the browser on every call. The result is significantly less context consumed per interaction compared to a raw Playwright MCP.

### Marketplaces

Plugins are distributed through **marketplaces**, GitHub repositories that serve as registries. Anthropic maintains two official marketplaces (`anthropics/skills` and `anthropics/claude-plugins-official`), and third parties can create their own. The configuration is explicit: you declare which marketplaces to trust and which plugins to enable.

```json
{
  "extraKnownMarketplaces": {
    "anthropic-agent-skills": {
      "source": { "source": "github", "repo": "anthropics/skills" }
    },
    "claude-plugins-official": {
      "source": { "source": "github", "repo": "anthropics/claude-plugins-official" }
    },
    "context7-marketplace": {
      "source": { "source": "github", "repo": "upstash/context7" }
    }
  }
}
```

## The Stack So Far

Here is what we have covered, each layer, what it solves, and what it cannot do:

| Layer        | What it solves                           | What it cannot do          |
| ------------ | ---------------------------------------- | -------------------------- |
| Raw LLM      | Text generation, pattern matching        | Act on the world           |
| Chat + Tools | Interactive Q&A, agentic loops           | Remember between sessions  |
| CLAUDE.md    | Persistent preferences, conventions      | Enforce rules              |
| Hooks        | Automated enforcement, formatting        | Structured tool access     |
| MCP          | Structured tool access, typed interfaces | Define reusable procedures |
| Skills       | Reusable on-demand procedures            | Share or scale             |
| Plugins      | Distributable capability packages        | Parallelize                |

Each row exists because the row above it has a specific limitation. The progression is not arbitrary; it is driven by real problems encountered in real usage: "I keep repeating myself" → CLAUDE.md. "The model ignores my preferences" → hooks. "The model needs structured tool access" → MCP. "I need the same procedure every week" → skills. "I want to share procedures across the team" → plugins.

With these seven layers, you have a fully configured, production-ready agent. It knows your project conventions, enforces your rules, has structured access to external tools, can execute reusable procedures, and stays current through a plugin ecosystem. For many workflows, this is all you need.

But everything so far runs in a single context window. One agent, one task at a time. When a problem is complex enough to benefit from parallel work, when you need a researcher gathering context while a reviewer checks the last set of changes, when three security lenses should examine the same code simultaneously — that is where the next layer begins.

In [Part 2](../part-2/), we will cover **subagents** (focused delegation to child processes with their own context windows), **agent teams** (full peer-to-peer coordination with shared task lists and direct messaging), and the orchestration patterns that tie them together. That is where the opening scenario — three reviewers, a researcher, and an implementer all working in parallel — becomes reality.
