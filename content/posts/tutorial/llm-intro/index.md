---
title: "LLM Intro: From the Basics to Context Engineering"
date: 2026-03-03T11:24:00+08:00

tags: [AI, LLM, Claude Code, MCP, Skill, Agent, Subagent, Agent Team]
categories: [tutorial]
license: CC BY-NC-SA 4.0
---

A practical guide to LLM agents, from foundational concepts to orchestrating teams of specialized AI agents that work in parallel. This article traces the full stack of context engineering: what an LLM actually is, how it becomes an agent, and the layered system of configuration (CLAUDE.md, hooks, skills, subagents, agent teams) that makes it useful in production. Written for everyone at the firm, regardless of technical background.

<!--more-->

## Introduction

Picture this scenario. You're deploying a hotfix to the data pipeline on a Friday afternoon. In one terminal, an agent team is reviewing the pull request, three reviewers working in parallel, each focused on a different angle: correctness, security, and consistency with existing patterns. In another terminal, a researcher agent is tracing a regression in the ETL pipeline that surfaced this morning, cross-referencing logs with recent schema changes. A third session has an implementer drafting API documentation for the new endpoint your team shipped this week. All of this is happening simultaneously, coordinated through shared task lists and direct messaging between agents, while you focus on the deployment itself.

This is not science fiction, and it is not a product demo. The system that enables it, Claude Code with its full agent orchestration stack, is what this article is about.

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

The global file also defines the entire agent team workflow: available agent types, model selection guidelines, coordination patterns, team presets, and the output contract all agents must follow. This is roughly 300 lines that establish the operational framework for every session. We will cover this in detail in the [Subagents](#subagents) and [Agent Teams](#agent-teams) sections.

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

[Hooks](https://docs.anthropic.com/en/docs/claude-code/hooks) are shell commands triggered at specific lifecycle events in the agent's operation. They run _outside_ the model: the model does not decide whether a hook fires, and it cannot override a hook's decision. This is the difference between a suggestion and an enforcement mechanism.

### Hook types

- **PreToolUse**: fires before a tool is executed. Can approve, deny, or modify the call.
- **PostToolUse**: fires after a tool completes. Can inspect and act on the result.
- **Notification**: fires when the agent needs user attention.
- **PermissionRequest**: fires when the agent requests permission for a restricted operation.
- **Stop**: fires when the agent finishes responding.
- **SessionStart**: fires at the beginning of a session.
- **TeammateIdle**: fires when a teammate goes idle (agent teams).
- **TaskCompleted**: fires when a teammate marks a task as completed.

### Real examples

Here are two hooks from my production configuration, implemented in NixOS[^hooks-nix].

[^hooks-nix]: Full source at [hooks/default.nix](https://github.com/hakula139/nixos-config/blob/main/home/modules/claude-code/hooks/default.nix).

**Auto-formatting (PostToolUse):** After every file edit or write, this hook automatically runs formatters on the changed files:

```nix
PostToolUse = [
  {
    matcher = "Edit|Write";
    hooks = [{
      type = "command";
      command = ''
        for file in $CLAUDE_FILE_PATHS; do
          if [[ "$file" == *.sh ]]; then
            shfmt -w "$file" 2>/dev/null || true
            shellcheck "$file" || true
          fi
        done
      '';
    }];
  }
  {
    matcher = "Edit|Write";
    hooks = [{
      type = "command";
      command = ''
        for file in $CLAUDE_FILE_PATHS; do
          if [[ "$file" == *.nix ]]; then
            nix fmt "$file" 2>/dev/null || true
          fi
        done
      '';
    }];
  }
];
```

Shell scripts get formatted with `shfmt` and linted with `shellcheck`. Nix files get formatted with `nix fmt`. The model never needs to think about formatting; it happens automatically, every time, with zero context window cost.

This is context engineering through subtraction: instead of writing "always format your code" in CLAUDE.md and hoping the model complies, the hook makes formatting automatic and invisible. The instruction is replaced by infrastructure.

**Notification (PermissionRequest):** When the agent needs user attention (a permission prompt or a question), this hook sends a desktop notification so you are not blocked waiting:

```nix
PermissionRequest = [{
  hooks = [{
    type = "command";
    command = ''
      tool_name="$(jq -r '.tool_name // empty')"
      case "$tool_name" in
        AskUserQuestion) notify "Question asked" ;;
        mcp__*)
          mcp_name="''${tool_name#mcp__}"
          mcp_name="''${mcp_name%%__*}"
          notify "$mcp_name permission requested"
          ;;
        *) notify "$tool_name permission requested" ;;
      esac
    '';
  }];
}];
```

{{< admonition info "HTTP hooks" >}}

In 2026, Claude Code added support for HTTP hooks. Instead of running a shell command, a hook can POST JSON to a URL. This enables webhook integrations: send a Slack message when a task completes, log tool usage to an observability platform, trigger a CI pipeline when the agent modifies certain files.

{{< /admonition >}}

### The analogy

If CLAUDE.md is the employee handbook ("here is how we do things"), then hooks are the CI pipeline. The handbook tells you to write tests; the CI pipeline blocks the merge if you do not. Both are necessary. One is advisory; the other is enforced.

### What hooks cannot do

Hooks are **reactive**: they respond to events that the model initiates. They cannot:

- **Initiate workflows.** A hook cannot say "every Monday at 9 AM, run a code quality report". It can only react to tool calls, completions, and permissions.
- **Access model reasoning.** Hooks receive structured event data (tool name, input, output), but they have no visibility into _why_ the model made a decision.
- **Define reusable procedures.** A hook that triggers on every file write can format code, but it cannot define a 20-step deployment workflow that the agent can invoke on demand.

Hooks also cannot give the agent structured access to external systems. The agent still talks to Git, GitHub, databases, and every other service through raw shell commands, parsing unstructured terminal output. For typed, structured tool access, there is MCP.

## MCP

We introduced [MCP](https://docs.anthropic.com/en/docs/claude-code/mcp) briefly in the agent section. Now it is time to look at it properly, because MCP is the infrastructure that makes everything else useful. Without MCP, an agent's only tool is a raw Bash shell, powerful but unstructured, with no type safety, no permission model, and every command's output dumped as raw text into the context window.

### What MCP actually provides

The **Model Context Protocol** defines a client-server architecture for tool use. An MCP server is a process that exposes a set of tools, each with a name, description, typed input schema, and typed output. The agent reads these definitions at startup and learns to call the tools by name. The key insight is that MCP tools return _structured_ data, not raw terminal output. When the agent calls `mcp__Git__git_status`, it gets a parsed status object, not a wall of colored text that it has to interpret.

This matters for context engineering. Structured output is denser and more predictable than raw shell output. A `git diff` piped through Bash might produce 200 lines of noisy terminal output; the MCP equivalent returns the same information in a structured format that the model can parse reliably. Less noise means more room for actual work in the context window.

### Configuring MCP servers

My configuration connects seven MCP servers, each serving a distinct purpose[^mcp-config]:

[^mcp-config]: MCP server definitions are centralized in [mcp/](https://github.com/hakula139/nixos-config/tree/main/home/modules/mcp) and shared across Claude Code and Codex CLI configurations.

```nix
mcpServers = {
  DeepWiki = mcp.servers.deepwiki;     # AI-powered docs for any GitHub repo
  Fetcher  = mcp.servers.fetcher;      # Playwright headless browser (fallback)
  Filesystem = mcp.servers.filesystem; # Sandboxed file operations
  Git      = mcp.servers.git;          # Structured git operations
  GitHub   = mcp.servers.github;       # Issues, PRs, code search, reviews
  Codex    = mcp.servers.codex;        # Delegate tasks to OpenAI Codex
};
```

Each server brings capabilities that would be awkward or unreliable through raw shell commands:

- **Git MCP** accepts a `repo_path` parameter, so the agent can operate on any repository without `cd`-ing around. Every operation returns structured data (diffs, logs, status), not terminal output.
- **GitHub MCP** provides direct API access to issues, pull requests, code search, and reviews. Pagination is handled automatically. The alternative, parsing `gh` CLI output, is fragile and verbose.
- **Filesystem MCP** adds sandboxing: the server defines which directories the agent can access. This is defense in depth on top of the permission model.
- **DeepWiki** and **Context7** are documentation servers. DeepWiki generates AI-powered documentation for any GitHub repository on the fly; Context7 provides up-to-date library docs with code examples. For a data scientist working with a new library, these eliminate the "let me Google the API" cycle entirely.
- **Codex MCP** is a bridge to OpenAI's Codex model running in a cloud sandbox. The agent can delegate self-contained tasks to a different model with its own context window.

### MCP and the permission model

MCP tools integrate directly into the permission system. In my configuration, all MCP read operations are auto-approved:

```nix
allow = [
  "mcp__DeepWiki"
  "mcp__Filesystem"
  "mcp__Git__git_status"
  "mcp__Git__git_diff"
  "mcp__Git__git_log"
  "mcp__GitHub"
  "mcp__Codex"
  # ...
];
```

Write operations require confirmation:

```nix
ask = [
  "mcp__Git__git_commit"
  "mcp__Git__git_checkout"
  "mcp__Git__git_create_branch"
  "mcp__GitHub__create_pull_request"
  "mcp__GitHub__merge_pull_request"
  # ...
];
```

This is granular, tool-level access control, something impossible with raw Bash commands, where `git commit` and `git log` are both just "Bash commands that start with `git`". MCP makes the permission boundary match the semantic boundary.

### MCP enforcement through hooks

With both hooks and MCP in place, they reinforce each other. Here is a `PreToolUse` hook that blocks Bash commands whenever an MCP equivalent exists, forcing the agent to use the structured tool instead[^enforce-mcp]:

[^enforce-mcp]: Full source at [hooks/enforce-mcp.sh](https://github.com/hakula139/nixos-config/blob/main/home/modules/claude-code/hooks/enforce-mcp.sh).

```bash
# Block git subcommands that have MCP equivalents
if [[ "$COMMAND" =~ ^[[:space:]]*git[[:space:]]+(.*) ]]; then
  REST="${BASH_REMATCH[1]}"
  SUBCMD="${REST%% *}"

  case "$SUBCMD" in
    add) deny "Use mcp__Git__git_add instead." ;;
    diff) deny "Use mcp__Git__git_diff instead." ;;
    log) deny "Use mcp__Git__git_log instead." ;;
    status) deny "Use mcp__Git__git_status instead." ;;
    # ... other subcommands with MCP equivalents
  esac
fi
```

The hook also blocks the `gh` CLI (use MCP GitHub tools), shell comment prefixes on Bash commands (use the description parameter), and `git -C` (use the MCP Git `repo_path` parameter). It allows through git subcommands _without_ MCP equivalents (`git blame`, `git stash`, `git ls-files`) and special cases like `git commit --amend` and `git reset --hard` that the MCP tools do not cover.

This is where the two layers converge: hooks enforce _what_ the agent should use, MCP provides _how_ to use it properly. Instead of writing "always use MCP tools" in CLAUDE.md and hoping the model complies, the hook makes non-compliance impossible. The context window is not consumed by the instruction at all.

### The ecosystem

Anthropic donated MCP to the Linux Foundation in 2025, making it an open standard rather than a proprietary protocol. By 2026, the ecosystem includes servers for Slack, PostgreSQL, Redis, AWS, Kubernetes, Jira, Confluence, and thousands more. Any team can build an MCP server for their internal tools (a compliance database, a trading system API, an internal knowledge base), and the agent gains the ability to use it without any model fine-tuning.

For a firm with diverse tooling (Bloomberg terminals, internal risk systems, compliance databases), MCP is the integration layer. The agent does not need to know how your systems work at a protocol level; it needs an MCP server that wraps them with typed tool definitions.

CLAUDE.md gives the agent preferences. Hooks enforce them. MCP gives it structured capabilities. But none of these layers let the agent learn a reusable, multi-step procedure that combines preferences and tools on demand. For that, you need skills.

## Skills

[Skills](https://docs.anthropic.com/en/docs/claude-code/slash-commands) are Markdown files that define on-demand procedures. They live in `.claude/skills/` and are loaded into the context window only when explicitly invoked via `/skill-name`, not ambient like CLAUDE.md, not reactive like hooks.

### Skill anatomy

Here is a simplified example based on a real skill for combining anime screenshots[^skill-example]:

[^skill-example]: The full skill is available through the plugin system. Skills can range from simple (10 lines) to complex (hundreds of lines with conditional logic).

```markdown
---
name: combine-screenshots
description: Combine multiple HDR AVIF screenshots into one
  by keeping the first image in full and appending the subtitle
  strip from each subsequent image below it.
allowed_tools:
  - Bash
  - Read
  - Write
---

## Procedure

1. Read the first image to determine dimensions.
2. For each subsequent image, extract only the bottom
   subtitle strip (last 15% of height).
3. Use ImageMagick to vertically concatenate:
   first full image + all subtitle strips.
4. Output as HDR AVIF with quality 85.
```

The key elements:

- **Frontmatter** defines metadata: name, description, and critically, **allowed tools**. A skill can restrict the agent to only use specific tools during execution, preventing scope creep.
- **Body** is the procedure itself, step-by-step instructions in Markdown. The agent follows these as a structured workflow.

### How skills differ from CLAUDE.md

| Aspect           | CLAUDE.md                   | Skills                      |
| ---------------- | --------------------------- | --------------------------- |
| Loading          | Always in context           | On-demand (`/skill-name`)   |
| Purpose          | Preferences and conventions | Specific procedures         |
| Tool access      | Unrestricted                | Can be restricted per skill |
| Parameterization | Static                      | Can accept arguments        |

Skills are the agent's equivalent of runbooks. A compliance team could have a `/regulatory-review` skill that walks the agent through a structured analysis of a new regulation: extract obligations, map to existing controls, identify gaps, generate a summary for the legal team. An operations team could have a `/incident-postmortem` skill that guides the agent through timeline construction, root cause analysis, and action item generation from incident logs.

Skills are distributable: they can be shared, versioned, and installed through a plugin ecosystem (covered in the next section). You write a skill once, and anyone on the team can invoke it. This is the package manager of AI capabilities.

### What skills cannot do

Skills are **single-agent procedures**. One agent follows one skill at a time. They cannot:

- **Delegate sub-tasks.** A skill cannot spawn a separate agent to handle one step while it continues with another.
- **Parallelize.** If a skill involves research, implementation, and review, these happen sequentially within one agent's context.
- **Provide multiple perspectives.** A code review skill gives you one agent's opinion. There is no mechanism within a skill for a second agent to challenge or augment the first agent's findings.
- **Escape context pressure.** A long skill procedure (say, a 200-line deployment checklist) eats into the context window for the duration of the task.

One agent, one procedure, one perspective. But before we move to multi-agent orchestration, there is an important layer that makes Claude Code's single-agent capabilities significantly broader than its competitors: the plugin ecosystem.

## Plugins

Skills on their own are local files. [Plugins](https://docs.anthropic.com/en/docs/claude-code/mcp) are the distribution and extension mechanism that turns individual skills into a shared ecosystem: installable packages that add new skills, output styles, code review workflows, language server integrations, and third-party tool connections.

### Why this matters

This is arguably Claude Code's strongest competitive advantage over alternatives like OpenAI Codex CLI or Cursor. Anthropic defines the standard for how plugins are structured, distributed, and discovered. The result is a growing ecosystem where capabilities compound: installing a plugin does not just add a skill; it can add hooks, custom agents, output modes, and MCP server integrations in a single package.

OpenAI's Codex CLI has powerful cloud sandboxes but no plugin ecosystem. Cursor has extensions through VS Code's marketplace, but those are IDE extensions, not agent capability extensions. Claude Code's plugin system operates at the agent level: it extends what the model can _do_, not just what the editor can display.

### What plugins provide

My configuration enables 18+ plugins across four categories[^plugins]:

[^plugins]: Managed declaratively in [plugins.nix](https://github.com/hakula139/nixos-config/blob/main/home/modules/claude-code/plugins.nix). Plugins auto-update on each session.

**Official skills**, Anthropic-maintained skill bundles:

```nix
"document-skills@anthropic-agent-skills" = true; # PDF, DOCX, PPTX, XLSX creation
"example-skills@anthropic-agent-skills" = true;  # Frontend design, algorithmic art, MCP builder
```

These add dozens of invocable skills: `/pdf` for PDF manipulation, `/pptx` for presentation creation, `/frontend-design` for production-grade UI generation, `/mcp-builder` for creating new MCP servers. Each skill carries its own tool restrictions and step-by-step procedures.

**Official plugins**, workflow extensions:

```nix
"code-review@claude-plugins-official" = true;       # Structured code review workflow
"feature-dev@claude-plugins-official" = true;       # Guided feature development
"pr-review-toolkit@claude-plugins-official" = true; # Multi-agent PR review
"hookify@claude-plugins-official" = true;           # Create hooks from conversation analysis
"security-guidance@claude-plugins-official" = true; # Security-focused guidance
```

The `pr-review-toolkit` is notable: it adds specialized review agents (type design analyzer, comment analyzer, silent failure hunter, test coverage analyzer) that go beyond what a generic reviewer provides. `hookify` lets you analyze a conversation for mistakes and automatically generate hooks to prevent them in the future.

**LSP integrations**, language server protocol plugins:

```nix
"typescript-lsp@claude-plugins-official" = true;
"pyright-lsp@claude-plugins-official" = true;
"rust-analyzer-lsp@claude-plugins-official" = true;
"clangd-lsp@claude-plugins-official" = true;
"gopls-lsp@claude-plugins-official" = true;
```

These give the agent access to real-time language diagnostics (type errors, unused imports, lint warnings) from the same language servers your IDE uses. The agent can check its own work against the compiler before you even look at it.

**Third-party plugins**, community contributions:

```nix
"context7-plugin@context7-marketplace" = true; # Up-to-date library documentation
"agent-browser@agent-browser" = true;          # Playwright browser automation
"claude-code-wakatime@wakatime" = true;        # Time tracking
```

### Marketplaces

Plugins are distributed through **marketplaces**, GitHub repositories that serve as registries. Anthropic maintains two official marketplaces (`anthropics/skills` and `anthropics/claude-plugins-official`), and third parties can create their own. The configuration is explicit: you declare which marketplaces to trust and which plugins to enable.

```nix
extraKnownMarketplaces = {
  anthropic-agent-skills.source = {
    source = "github";
    repo = "anthropics/skills";
  };
  claude-plugins-official.source = {
    source = "github";
    repo = "anthropics/claude-plugins-official";
  };
  context7-marketplace.source = {
    source = "github";
    repo = "upstash/context7";
  };
};
```

This is a controlled ecosystem, not a free-for-all. You choose your sources, you choose your plugins, and the agent gains capabilities without any model retraining.

### What plugins cannot do

Plugins extend a single agent's capabilities: more skills, more tools, more integrations. But they do not change the fundamental limitation: one agent, one context window, one task at a time. A plugin cannot spawn a second agent to work in parallel, delegate a sub-task to a specialist, or coordinate multiple perspectives on the same problem. For that, you need agents that can delegate and collaborate.

## Subagents

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

Here is the complete picture, each layer, what it solves, and what it cannot do:

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
