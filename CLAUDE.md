# CLAUDE.md

A searchable in-browser index of Quick Access Toolbar (QAT) and ribbon
command identifiers for every major Microsoft Office app. Pulls live
`*controls.xlsx` files at runtime from Microsoft's official
[`OfficeDev/office-fluent-ui-command-identifiers`](https://github.com/OfficeDev/office-fluent-ui-command-identifiers)
repo — **no stale snapshots are stored here**. The legacy static
workbooks (`Excel-Command-Index.xlsm`, `PowerPoint-Command-Index.xlsm`)
are preserved for historical / offline use only.

## Repo map

- `web/` — the live in-browser command browser. Canonical implementation.
  Powers the GitHub Pages live page.
- `Excel-Command-Index.xlsm`, `PowerPoint-Command-Index.xlsm` — original
  static workbooks (Office 2007/2010 era). Reference only — do not
  modify to reflect new Office versions; the web app does that
  dynamically from Microsoft's source.
- `releases/` — pre-packaged release archives committed to the repo.
- `.github/workflows/pages.yml` — deploys `web/` to GitHub Pages on push
  to `main`.

Note: this repo intentionally has **no `release.yml`** — there are no
per-platform binaries to build. Releases (if any) are made by hand.

## Branch policy

Work on the assigned feature branch:

1. Commit and push the feature branch.
2. **Open a PR from the feature branch to `main`** using the GitHub MCP
   tools (`mcp__github__create_pull_request`). Do not merge directly —
   the maintainer reviews and merges.
3. The Pages deploy fires from `main` — nothing reaches the live page
   until the PR lands.

## Verifying changes

There is no test suite. After touching `web/`:

1. Serve locally (`python3 -m http.server` from inside `web/`) or open
   `web/index.html` directly.
2. Confirm at least one Office app loads its controls (it fetches from
   GitHub raw — you need network).
3. Spot-check search, the deep-linkable URL params
   (`?app=excel&q=cell&tab=Home`), and the `⌘K` / `/` shortcuts.

## Gotchas

- The app fetches XLSX files from `raw.githubusercontent.com` at runtime
  — if you add CORS-sensitive code, test against the actual host, not a
  local mirror.
- Excel files are parsed in-browser. Keep the parser lazy / streamed —
  some `controls.xlsx` files are large and blocking the main thread will
  visibly stall the UI.
- URL state is the source of truth for `app`, `q`, `tab`, and `type`
  filters. Don't add UI state that isn't reflected in the query string,
  or deep links break.
- The Excel/PowerPoint `.xlsm` files at the repo root are intentionally
  frozen historical artifacts. Don't "update" them — that's the web
  app's job, dynamically.
