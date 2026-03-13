---
title: "MCP Server Guide: Building a Documentation Server for LLM Agents"
date: 2026-03-13T15:55:00+08:00

tags: [AI, LLM, MCP, Claude Code, FastMCP, Python]
categories: [tutorial]
license: CC BY-NC-SA 4.0
---

A practical, end-to-end guide to building a custom MCP server that turns your documentation site into structured tools for LLM agents. Covers the llms.txt standard, FastMCP, caching, search, packaging, and LLM agents integration. Written for teams that have internal docs (Confluence pages, Markdown files) and want their agents to read them instead of hallucinating.

<!--more-->

## Introduction

In [Part 1](../part-1/) of the LLM Intro series, we introduced MCP as the protocol that gives LLM agents structured access to external tools. The problem it solves is specific and common. Your team has internal documentation — API references, guides, changelogs, maybe hundreds of pages across a Confluence or MkDocs site — and your LLM agent has no clean way to access it. The agent can technically fetch pages and parse the raw HTML, but this is fragile (navigation menus, sidebars, and JavaScript-rendered content all pollute the result) and expensive (a single page dump can consume thousands of tokens of noise). As a result, the agent ends up guessing: hallucinating class names, inventing parameters, producing code that looks plausible but does not compile.

The solution is an MCP server that wraps your documentation site with typed tool definitions: list available versions, browse the page index, read a specific page, search by keyword. The agent discovers these tools at startup and uses them the same way it uses Git or Context7 — by calling structured functions that return clean data instead of parsing raw HTML.

This article walks through a real MCP server, generalized from an internal deployment, that does exactly this. By the end, you will have a working server you can adapt to any MkDocs-based documentation site, packaged for distribution with `uvx` and optionally bundled as a Claude Code plugin.

## The llms.txt Standard

Before building the server, we need to understand _what_ the agent reads. The answer is **llms.txt**, a convention (proposed by Jeremy Howard in late 2024[^llms-txt]) for making websites LLM-accessible, analogous to how `robots.txt` and `sitemap.xml` work for search engine crawlers — one signals what content exists, the other makes it navigable. `llms.txt` does both for LLMs.

[^llms-txt]: See [llmstxt.org](https://llmstxt.org) for the specification and the growing list of adopters.

The idea is simple. A website places a file at `/llms.txt` that contains a structured summary of its content: page titles, URLs, and brief descriptions, all in Markdown. A companion file `/llms-full.txt` concatenates the full content of every page into a single document. Together, these two files give an LLM everything it needs to navigate and read the site — without parsing HTML, executing JavaScript, or dealing with navigation menus and sidebars.

Here is what a typical `llms.txt` looks like:

```markdown
# My API Documentation

> API reference and guides for the My API platform.

- [Getting Started](https://docs.example.com/latest/guides/getting-started/index.md): Quick start guide
- [Python API](https://docs.example.com/latest/python/index.md): Python API reference
- [C++ API](https://docs.example.com/latest/cpp/index.md): C++ API reference
- [Release Notes](https://docs.example.com/latest/release-notes/index.md): Version history
```

And `llms-full.txt` is simply every page's content, concatenated with `# Title` headings as separators:

```markdown
# Getting Started

Welcome to the API. This guide walks you through...

# Python API

The Python API exposes the core functionality through...
```

### Generating llms.txt for your docs

If your docs are already on [MkDocs](https://www.mkdocs.org), generating these files is a one-line plugin addition. The [mkdocs-llmstxt](https://github.com/pawamoy/mkdocs-llmstxt) plugin scans your pages at build time and produces both files automatically. Add it to `mkdocs.yml`:

```yaml
plugins:
  - llmstxt
```

If you have scattered Markdown files that are not part of any site, organize them into a MkDocs project (with [Material for MkDocs](https://squidfunk.github.io/mkdocs-material) as the theme, which is the de facto standard) — you get a hosted site _and_ llms.txt for free. The MCP server we build below only cares that the text files are reachable at a URL.

### Migrating from Confluence

If your docs live in Confluence, the path is longer but well-trodden. The overall flow: export Confluence pages to Markdown, organize them into a MkDocs project, then let the llmstxt plugin generate the LLM-readable files.

#### Export

Install [confluence-markdown-exporter](https://github.com/Spenhouet/confluence-markdown-exporter) and configure it with your instance URL and credentials:

```bash
pip install confluence-markdown-exporter
confluence-markdown-exporter config
# Prompts for: Instance URL (https://wiki.your-domain.com), Email, PAT
# Generate a PAT at: https://wiki.your-domain.com/plugins/personalaccesstokens/usertokens.action
```

You can export at two granularities. To export an entire space:

```bash
confluence-markdown-exporter spaces YOUR_SPACE_KEY
```

To export a single page, find its page ID by clicking **⋯** (top-right corner of the page) → **Page Information** — the `pageId` appears in the URL. Then run:

```bash
confluence-markdown-exporter pages PAGE_ID
```

Either way, the tool pulls pages into Markdown files, preserving the page hierarchy as a directory structure.

#### Clean up for MkDocs

The raw export will not be MkDocs-ready. Expect to fix:

- **Link formats.** Confluence uses page titles as links; MkDocs needs relative file paths. Anchor links (`#section-name`) also need adjustment — Confluence generates different fragment IDs than MkDocs.
- **Index pages.** MkDocs uses `index.md` as the landing page for each directory. You may need to rename or create these to match your desired navigation hierarchy.
- **List indentation.** MkDocs requires **4-space** indentation for nested lists, while Confluence exports often use 2 or 3 spaces.
- **Code blocks.** Verify that exported code examples actually run. Confluence pages tend to accumulate stale snippets that no one has tested in months — the migration is a good opportunity to clean these up.

Start with a minimal working demo (a handful of pages, correct links, proper formatting) before migrating the full space. Quality over coverage: a small set of verified, well-formatted pages is more useful to the agent than a bulk import full of broken links and garbled formatting.

{{< admonition tip "Markdown linting" >}}

Install [markdownlint](https://github.com/DavidAnson/markdownlint) (or its CLI / IDE plugin) and configure a `.markdownlint.json` at the project root. This catches formatting issues (inconsistent list markers, missing blank lines, trailing spaces) before they reach the build. The specific rules are worth discussing with your team — what matters is that _some_ standard is enforced consistently.

{{< /admonition >}}

{{< admonition tip "Why not just dump files into context?" >}}

You _could_ skip all of this and paste your entire documentation into the user prompt, or have the agent read every file at the start of each session. For small doc sets (< 50 pages), this might even work, but it scales terribly. A 200-page API reference might consume most of the context window before the agent starts doing actual work. The MCP approach is surgical: the agent loads only the pages it needs, when it needs them, and the rest stays out of context. This is the context engineering principle from [Part 1](../part-1/#what-is-an-llm): the window is finite, and every token you load displaces something else.

{{< /admonition >}}

### Beyond MkDocs

The llms.txt convention is not tied to MkDocs. Any static site generator (Docusaurus, Sphinx, Hugo, Jekyll) can produce these files, and many already have plugins or community integrations. The MCP server we build below only cares about the _output_ — the text files at known URLs — not the tool that generated them.

## What We Are Building

The server exposes four tools:

| Tool                           | Description                                      |
| ------------------------------ | ------------------------------------------------ |
| `list_versions()`              | List all available doc versions with aliases     |
| `get_docs_index(version?)`     | Get the page index (titles + URLs) for a version |
| `get_page(path, version?)`     | Read a single page's content in Markdown         |
| `search_docs(query, version?)` | Full-text keyword search across all pages        |

All tools default to the `latest` version when `version` is omitted, which covers the common case where users just want the current docs.

The architecture is three modules:

- **`server.py`** — Tool definitions and page extraction logic. This is where FastMCP lives.
- **`fetcher.py`** — An async HTTP client with TTL caching. Fetches `llms.txt`, `llms-full.txt`, `versions.json`, and the MkDocs search index from your docs site.
- **`search.py`** — A keyword search engine that operates over the MkDocs `search_index.json`.

The data flow is: agent calls a tool → server delegates to fetcher (which caches responses for 5 minutes) → fetcher returns structured data → server processes and returns to agent.

## Project Setup

We use [uv](https://docs.astral.sh/uv/) for dependency management and [hatchling](https://hatch.pypa.io/) as the build backend. The project layout:

```text
my-docs-mcp/
├── src/
│   └── my_docs_mcp/
│       ├── __init__.py
│       ├── server.py
│       ├── fetcher.py
│       └── search.py
├── pyproject.toml
└── .gitignore
```

The `pyproject.toml`:

```toml
[project]
name = "my-docs-mcp"
version = "0.1.0"
description = "MCP server for querying API documentation"
requires-python = ">=3.10"
dependencies = [
  "fastmcp>=3.1,<4",
  "httpx>=0.27",
]

[project.scripts]
my-docs-mcp = "my_docs_mcp.server:main"

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.hatch.build.targets.wheel]
packages = ["src/my_docs_mcp"]
```

`★ Insight ─────────────────────────────────────`
Two dependencies, and one of them (`httpx`) is already a transitive dependency of FastMCP. The `[project.scripts]` entry creates a CLI command `my-docs-mcp` that calls `server:main`, which is how `uvx` and Claude Code will launch the server. The `hatch.build.targets.wheel.packages` line tells hatchling where to find the source — necessary because we use the `src/` layout rather than having the package at the project root.
`─────────────────────────────────────────────────`

Initialize the project:

```bash
uv init my-docs-mcp
cd my-docs-mcp
uv add "fastmcp>=3.1,<4" "httpx>=0.27"
```

## The Server

Here is `server.py`, the core of the MCP server. We will walk through it piece by piece.

### FastMCP instantiation

```python
from fastmcp import FastMCP

mcp = FastMCP(
    "My Docs",
    instructions=(
        "Provides access to API documentation. "
        "Use list_versions() to see available versions, "
        "get_docs_index() to browse the page index, "
        "get_page() to read a specific page, "
        "and search_docs() to find relevant content."
    ),
)
```

The first argument is the server name (shown in Claude Code's MCP server list). The `instructions` string is injected into the agent's context at startup — it is how the agent learns _what_ this server does and _how_ to use its tools. Write these instructions for the model, not for humans: be explicit about the intended workflow.

### Defining tools

Each tool is an async function decorated with `@mcp.tool`. FastMCP reads the function's type hints and docstring to generate the JSON Schema that the agent sees. This means your docstring _is_ the tool's documentation — if it is vague, the agent will use the tool incorrectly.

```python
@mcp.tool
async def list_versions() -> list[dict[str, Any]]:
    """List all available documentation versions with their aliases."""
    return await fetcher.get_versions()


@mcp.tool
async def get_docs_index(version: str = "latest") -> str:
    """Get the documentation index (page titles and URLs) for a version.

    Parameters
    ----------
    version : str, optional
        Documentation version or alias (e.g., "2.6.0", "latest").
        Defaults to "latest".

    Returns
    -------
    str
        The llms.txt index listing all pages with summaries.
    """
    return await fetcher.get_llms_txt(version)
```

The pattern is the same for all four tools: a thin wrapper that delegates to the fetcher or search module. The server layer handles tool registration and any post-processing (like page extraction); the fetcher handles I/O and caching; the search module handles query logic. Keeping these concerns separate makes each module independently testable.

### Page extraction

The most complex tool is `get_page`, because it needs to resolve a URL path to actual content. The strategy has two layers:

1. **Primary**: Look up the page title from `llms.txt` (which maps paths to titles), then find the corresponding `# Title` section in `llms-full.txt`.
2. **Fallback**: If the page is not in `llms.txt` (some pages, like auto-generated API references, may be excluded), assemble it from the MkDocs search index, which stores one entry per section.

```python
@mcp.tool
async def get_page(path: str, version: str = "latest") -> str:
    """Get a single documentation page's content in markdown.

    Parameters
    ----------
    path : str
        Page path relative to the version root
        (e.g., "guides/getting-started/", "Python/tabular/").
    version : str, optional
        Documentation version or alias. Defaults to "latest".
    """
    llms_txt = await fetcher.get_llms_txt(version)
    full_text = await fetcher.get_llms_full_txt(version)
    result = _extract_page(llms_txt, full_text, path)
    if not result.startswith("Page not found"):
        return result

    # Fallback: assemble from search index
    index = await fetcher.get_search_index(version)
    assembled = _assemble_from_search_index(index, path)
    if assembled:
        return assembled

    return result
```

The extraction helpers are straightforward string operations:

```python
def _normalize_path(path: str) -> str:
    """Normalize a page path for consistent comparison."""
    path = path.strip("/")
    path = re.sub(r"/?index\.md$", "", path)
    return path


def _resolve_title(llms_txt: str, path: str) -> str | None:
    """Resolve a page path to its title using llms.txt entries."""
    for match in re.finditer(
        r"- \[(.+?)]\(https?://[^)]+?/[^/]+/([^)]+)\)", llms_txt
    ):
        title, url_path = match.group(1), match.group(2)
        if _normalize_path(url_path) == path:
            return title
    return None


def _extract_page(llms_txt: str, full_text: str, path: str) -> str:
    """Extract a single page from llms-full.txt by matching its title."""
    path = _normalize_path(path)
    title = _resolve_title(llms_txt, path)
    if title is None:
        return f"Page not found: {path}"

    sections = re.split(r"(?m)^(?=# )", full_text)
    for section in sections:
        first_line = section.split("\n", 1)[0]
        if first_line == f"# {title}":
            return section.strip()

    return f"Page not found: {path} (title '{title}' not in llms-full.txt)"
```

The path normalization matters because agents are inconsistent about trailing slashes and `index.md` suffixes. The regex in `_resolve_title` parses the Markdown link format that `llms.txt` uses: `- [Title](https://host/version/path/index.md)`.

{{< admonition note "The search index fallback" >}}

MkDocs generates a `search_index.json` that contains one entry per _section_ (each heading within a page). When a page is missing from `llms-full.txt`, the fallback collects all search index entries whose base path matches the requested page and concatenates them into a synthetic document. The result is not as clean as the original Markdown, but it is good enough that the agent can extract the information it needs. This is particularly useful for auto-generated API reference pages that some MkDocs setups exclude from `llms.txt`.

{{< /admonition >}}

```python
def _assemble_from_search_index(
    index: list[dict[str, Any]], path: str
) -> str | None:
    """Assemble a page from search index entries matching the given path."""
    path = _normalize_path(path)
    entries: list[dict[str, Any]] = []
    for entry in index:
        loc = entry.get("location", "").strip("/")
        base = loc.split("#")[0].strip("/")
        if base == path:
            entries.append(entry)
    if not entries:
        return None

    parts: list[str] = []
    for entry in entries:
        title = entry.get("title", "")
        text = entry.get("text", "")
        text = html.unescape(re.sub(r"<[^>]+>", "", text)).strip()
        loc = entry.get("location", "")
        is_page_root = "#" not in loc
        if is_page_root:
            parts.append(f"# {title}\n\n{text}" if text else f"# {title}")
        elif text:
            parts.append(f"## {title}\n\n{text}" if title else text)

    return "\n\n".join(parts) if parts else None
```

### The entry point

```python
def main() -> None:
    parser = argparse.ArgumentParser(description="My Docs MCP Server")
    parser.add_argument(
        "--base-url",
        default=os.environ.get("MY_DOCS_URL", DEFAULT_BASE_URL),
        help=f"Base URL for the docs site (default: {DEFAULT_BASE_URL})",
    )
    args = parser.parse_args()

    global fetcher
    fetcher = CachedFetcher(base_url=args.base_url)
    mcp.run()
```

The base URL is configurable through a CLI argument or an environment variable, with a hardcoded default as the last fallback. This three-tier resolution (CLI > env > default) is a standard pattern for MCP servers: the same binary works in development (pass `--base-url` to point at a local server), in CI (set the env var), and in production (rely on the default).

## Fetching and Caching

The fetcher is a thin async HTTP client that caches responses for 5 minutes. Every tool call hits the fetcher, and without caching, a typical agent session (which might call `search_docs`, then `get_page` three times, then `get_docs_index`) would make a dozen HTTP requests to the same URLs within seconds.

```python
DEFAULT_BASE_URL = "https://docs.example.com"
CACHE_TTL = 300  # 5 minutes


class CachedFetcher:
    def __init__(
        self, base_url: str = DEFAULT_BASE_URL, *, verify_ssl: bool = False
    ) -> None:
        self.base_url = base_url.rstrip("/")
        self._verify_ssl = verify_ssl
        self._cache: dict[str, tuple[float, Any]] = {}
        self._client: httpx.AsyncClient | None = None

    async def _get_client(self) -> httpx.AsyncClient:
        if self._client is None or self._client.is_closed:
            self._client = httpx.AsyncClient(
                timeout=30, verify=self._verify_ssl
            )
        return self._client

    async def _fetch(self, path: str) -> str:
        url = f"{self.base_url}/{path.lstrip('/')}"
        now = time.monotonic()

        cached = self._cache.get(url)
        if cached and (now - cached[0]) < CACHE_TTL:
            return cast(str, cached[1])

        client = await self._get_client()
        resp = await client.get(url)
        resp.raise_for_status()
        text = resp.text
        self._cache[url] = (now, text)
        return text
```

The cache is a plain dictionary mapping URLs to `(timestamp, value)` tuples. `time.monotonic()` is used instead of `time.time()` because it is not affected by system clock adjustments — a minor detail that prevents subtle bugs in long-running server processes.

`★ Insight ─────────────────────────────────────`
The `verify_ssl=False` default is intentional for internal deployments where docs sit behind corporate proxies with self-signed certificates. For public-facing servers, you should set this to `True`. A production version might accept a CA bundle path instead of a boolean.
`─────────────────────────────────────────────────`

### Version resolution

MkDocs with [mike](https://github.com/jimporter/mike) (the versioning plugin) publishes a `versions.json` that maps version numbers to aliases:

```json
[
  {"version": "2.6.0", "title": "2.6.0", "aliases": ["latest"]},
  {"version": "2.5.1", "title": "2.5.1", "aliases": []}
]
```

The fetcher resolves aliases before fetching:

```python
async def resolve_version(self, version: str) -> str:
    """Resolve 'latest' or other aliases to actual version identifiers."""
    versions = await self.get_versions()
    for entry in versions:
        if version == entry.get("version"):
            return version
        if version in entry.get("aliases", []):
            return cast(str, entry["version"])
    return version
```

This means `get_page("guides/intro/", version="latest")` transparently resolves to the correct version directory. The agent never needs to know the actual version number.

## Search

The search module is deliberately simple: keyword matching with title weighting. No vector embeddings, no semantic search, no external dependencies.

```python
def search(
    docs: list[dict[str, Any]],
    query: str,
    *,
    max_results: int = 10,
) -> list[dict[str, Any]]:
    """Keyword search over MkDocs search_index.json docs."""
    keywords = query.lower().split()
    if not keywords:
        return []

    scored: list[tuple[int, dict[str, Any]]] = []
    for doc in docs:
        title = doc.get("title", "").lower()
        text = doc.get("text", "").lower()
        score = sum(3 for kw in keywords if kw in title)
        score += sum(1 for kw in keywords if kw in text)
        if score > 0:
            excerpt = _excerpt(doc.get("text", ""), keywords)
            scored.append((
                score,
                {
                    "location": doc.get("location", ""),
                    "title": doc.get("title", ""),
                    "excerpt": excerpt,
                    "score": score,
                },
            ))

    scored.sort(key=lambda x: x[0], reverse=True)
    return [item for _, item in scored[:max_results]]
```

Title matches get a 3x weight because a keyword appearing in the title is a much stronger signal than the same keyword buried in body text. The excerpt function finds the first keyword match and returns a window of surrounding text, giving the agent enough context to decide whether to read the full page.

Why not use a proper search engine? Because the MkDocs search index is small enough (typically a few MB) that brute-force keyword matching is instant, and the agent's real job is _reading_ pages, not searching. The search tool narrows down which page to read; the agent does the understanding. A fancier search engine would be overengineering for this use case.

## Packaging and Distribution

### Building a wheel

```bash
uv build
```

This produces `dist/my_docs_mcp-0.1.0-py3-none-any.whl`, a standard Python wheel that can be installed anywhere.

### Running with uvx

The key insight for distribution is [uvx](https://docs.astral.sh/uv/guides/tools/) (part of the `uv` toolchain): it downloads, installs, and runs a Python package in an isolated environment, all in one command. No virtual environments to manage, no system-wide installs, no dependency conflicts.

```bash
uvx my-docs-mcp
```

If your package is hosted on an internal PyPI registry:

```bash
UV_EXTRA_INDEX_URL=https://pypi.internal.example.com/simple uvx my-docs-mcp
```

This is the same command that Claude Code will use to launch the server, which means you can test locally with the exact same invocation the agent will use in production.

### Publishing

Publish to your PyPI registry (internal or public):

```bash
uv publish --publish-url https://pypi.internal.example.com/upload
```

For internal teams, the private registry avoids exposing documentation tools publicly while keeping the distribution workflow identical to open-source packages.

## Claude Code Integration

There are three levels of integration, from simplest to most capable.

### Level 1: Standalone MCP server

Add the server to your Claude Code settings (`~/.claude/settings.json` for global, `.claude/settings.json` for project):

```json
{
  "mcpServers": {
    "my-docs": {
      "command": "uvx",
      "args": ["my-docs-mcp"],
      "env": {
        "UV_EXTRA_INDEX_URL": "https://pypi.internal.example.com/simple"
      }
    }
  }
}
```

Claude Code launches the server at session start via `uvx`, which handles installation and environment isolation automatically. The agent discovers the four tools and can use them immediately.

### Level 2: Claude Code plugin

A [plugin](https://code.claude.com/docs/en/discover-plugins) bundles the MCP server with metadata so it can be installed with a single command. Create a `.claude-plugin/` directory:

```text
.claude-plugin/
├── plugin.json
└── skills/
    └── my-docs.md
```

The `plugin.json`:

```json
{
  "name": "my-docs",
  "version": "0.1.0",
  "description": "Query API documentation from within Claude Code",
  "mcpServers": {
    "my-docs": {
      "command": "uvx",
      "args": ["my-docs-mcp==0.1.0"],
      "env": {
        "UV_EXTRA_INDEX_URL": "https://pypi.internal.example.com/simple"
      }
    }
  },
  "skills": ["skills/my-docs.md"]
}
```

Install with:

```bash
claude plugin install .claude-plugin
```

The plugin pins the MCP server version in `args` so that all team members run the same version, avoiding the "works on my machine" problem.

### Level 3: Bundled skill

The plugin can include a skill file that teaches the agent _how_ to use the tools effectively. This is the difference between giving someone a set of wrenches and giving them a repair manual.

```markdown
---
name: my-docs
description: >-
  Query API documentation using MCP tools. Use when answering questions
  about the API, looking up classes and methods, reading guides, or
  checking release notes and changelogs.
user_invocable: true
---

# API Docs

You have access to documentation through MCP tools.

## Tool Selection

- **`list_versions()`** — See all available doc versions and their aliases.
- **`get_docs_index(version?)`** — Browse the full page index. Start here
  when unsure which page to read.
- **`get_page(path, version?)`** — Read a specific page in Markdown. Use
  when you know the page path (from the index or search results).
- **`search_docs(query, version?)`** — Full-text keyword search. Use when
  looking for a specific topic, class, function, or concept.

## Workflow

1. If the user asks about a **specific version**, pass it as `version`.
   Otherwise, omit it (defaults to `latest`).
2. For **broad questions**, start with `search_docs` to find relevant pages,
   then `get_page` to read the most relevant results.
3. For **API reference lookups**, search first, then read the specific page.
4. For **"what changed" questions**, check release notes pages.
5. **Always cite** the page path when referencing documentation content.
```

The `description` field drives auto-invocation: when a user asks "how do I create a dataset?", the model matches the question to this skill's description and loads the full instructions into context, without the user needing to type `/my-docs`. The `user_invocable: true` flag also lets users invoke it manually with `/my-docs` when they want to be explicit.

`★ Insight ─────────────────────────────────────`
The three levels compose: a plugin includes the MCP server config _and_ the skill, so a single `claude plugin install` gives the team everything. But each level also works independently — you can run the MCP server without a plugin, or write a skill without packaging it as a plugin. Start with Level 1, add complexity only when the team needs it.
`─────────────────────────────────────────────────`

## Testing

### MCP Inspector

The [MCP Inspector](https://modelcontextprotocol.io/docs/tools/inspector) is a web-based testing UI that connects to your server and lets you call tools interactively:

```bash
npx @modelcontextprotocol/inspector uvx my-docs-mcp
```

This launches the server and opens a browser where you can call each tool, inspect the JSON Schema, and see the raw responses. It is the fastest way to verify that your tools work before connecting them to an actual agent.

### Direct testing

For quick iteration, run the server directly and pipe JSON-RPC messages manually:

```bash
MY_DOCS_URL=https://docs.example.com uvx my-docs-mcp
```

Or test the underlying logic without MCP at all — import the modules and call the functions directly in a Python REPL:

```python
import asyncio
from my_docs_mcp.fetcher import CachedFetcher
from my_docs_mcp.search import search

async def test():
    f = CachedFetcher(base_url="https://docs.example.com")
    index = await f.get_search_index("latest")
    results = search(index, "dataset creation")
    for r in results[:3]:
        print(r["title"], r["score"])

asyncio.run(test())
```

### In Claude Code

The real test is using it. Start a Claude Code session with the MCP server configured, and ask the agent a question that requires documentation:

```text
> What parameters does the MarketDataset constructor accept?
```

Watch the tool calls in the output. The agent should call `search_docs("MarketDataset constructor")`, identify the relevant page from the results, then call `get_page` to read it. If it hallucinates instead of calling the tools, your skill's `description` might not be triggering auto-invocation — make the description more specific about when the skill applies.

{{< admonition warning "STDIO transport and stdout" >}}

When running as a local MCP server (which is the default for Claude Code), the server communicates with the agent over stdin / stdout using JSON-RPC. Any `print()` statements, logging to stdout, or library output on stdout will corrupt the protocol and crash the server. Use `logging` (which defaults to stderr) or explicitly write to `sys.stderr`. This is the single most common cause of "MCP server failed to start" errors.

{{< /admonition >}}

## Adapting to Your Docs

The server as presented assumes MkDocs with `llms.txt` and a search index. If your setup differs, here is where to adjust:

- **Different static site generator**: As long as it produces `llms.txt` and `llms-full.txt`, the server works unchanged. If it does not, you only need to modify `_resolve_title` and `_extract_page` to match your file format.
- **No search index**: Remove the `search_docs` tool and the search index fallback in `get_page`. The remaining three tools work with just `llms.txt` and `llms-full.txt`.
- **No versioning**: Remove `list_versions` and the version parameter from the other tools. Hardcode the URL paths instead of resolving through `versions.json`.
- **Authentication**: If your docs require auth, add headers to the httpx client in `CachedFetcher.__init__`. Bearer tokens, API keys, and mTLS all work with httpx's standard configuration.

The code is intentionally minimal (under 200 lines across all three modules) so that adapting it is a matter of editing, not understanding a framework.

## What Comes Next

With an MCP server in place, your agent reads documentation instead of guessing. But the server is one piece of a larger system. [Part 1](../part-1/) covers the full stack — CLAUDE.md for persistent instructions, hooks for enforcement, skills for reusable procedures, plugins for distribution. An MCP server gives the agent _access_ to your docs; a skill tells it _when and how_ to use that access; a hook can _enforce_ that it always checks documentation before answering questions about your API. The layers compose.

The full source code for this server is available as a template you can fork and adapt. Change the base URL, adjust the path resolution to match your site structure, publish to your internal registry, and your entire team has structured documentation access in every agent session.
