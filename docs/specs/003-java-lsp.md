Status: done

## Revisions

- 2026-11-21: Reconfirmed root detection to use `nvim-lspconfig`'s built-in grouped markers for multi-module projects and wrappers, removing the flat `root_markers` override; explicitly exclude `jdtls` from Mason automatic enablement while retaining `vim.lsp.enable`.
- 2026-11-21: Reconfirmed standalone-file support as attachment, syntax diagnostics, and completion; JDT LS does not provide JDK go-to-definition for non-project files.

# Add Java language server to Neovim

**Purpose:** Get Java diagnostics, completion, and navigation working in Neovim so Java files get the same LSP experience as Python and TypeScript.

## Job story

When I open a Java file in Neovim, I want the JDT Language Server to attach automatically, so I can get diagnostics, completion, go-to-definition, rename, and code actions without manual setup.

## Why now

Java files currently have no LSP — no diagnostics, no completion, no navigation. The existing Mason/LSP stack already supports adding a new server with three lines of config.

## Cost of skipping

Every Java edit is blind: no type errors until compile, no symbol navigation, no refactoring.

## In scope

- Install `jdtls` through Mason (`mason-lspconfig` `ensure_installed`).
- Configure root markers so jdtls detects Maven, Gradle, and unmanaged Java projects.
- Enable `jdtls` via `vim.lsp.enable` alongside the existing servers.
- Exclude `jdtls` from `mason-lspconfig`'s automatic `setup` (jdtls needs custom root detection — handled via `vim.lsp.config`).

## Out of scope

- `nvim-jdtls` plugin (richer features like organize-imports command, test runner, debug adapter). Follow-up if needed.
- Debug adapter or test runner setup.
- Lombok support.
- Gradle/Maven wrapper detection tuning beyond default root markers.

## Acceptance criteria

1. **Given** `jdtls` is not yet installed, **when** Neovim starts and a Java file is opened, **then** Mason installs `jdtls` automatically and the LSP client attaches (visible in `:LspInfo` with client name `jdtls`).
2. **Given** a Maven project (contains `pom.xml`), **when** a Java file is opened, **then** diagnostics (compile errors) appear within a few seconds and `gd` jumps to definitions within the project.
3. **Given** a Gradle project (contains `build.gradle` or `build.gradle.kts`), **when** a Java file is opened, **then** the LSP attaches with the project root detected correctly (not the home directory).
4. **Given** a plain Java folder with no build file, **when** a Java file is opened, **then** the LSP attaches in single-file mode and provides at least diagnostics and go-to-definition for the JDK.
5. **Given** completion is triggered (`<C-Space>`) in a Java buffer, **when** the LSP is attached, **then** `nvim-cmp` shows method and class completions sourced from `nvim_lsp`.
6. **Given** Neovim starts on a non-Java file, **when** no Java buffer is opened, **then** `jdtls` is not started and startup time is unaffected.

## Definition of done

- Every acceptance criterion passes a manual check (steps named above).
- The change is limited to `lua/config/plugins.lua`: add `"jdtls"` to `ensure_installed`, add a `vim.lsp.config("jdtls", { ... })` block with root markers, add `"jdtls"` to `vim.lsp.enable`.
- `:LspInfo` in a Java buffer shows `jdtls` attached; in a Python buffer it does not.
- No unrelated edits in the diff.
- A reviewer has checked for regressions against existing servers (ts_ls, pyright, etc. still work).

## Decisions

| Decision | Options considered | Default | Reason |
|---|---|---|---|
| Setup approach | (a) plain `vim.lsp.config` + `vim.lsp.enable`, (b) `nvim-jdtls` plugin | (a) minimal | Matches the existing pattern for every other server; no new lifecycle, no new plugin. `nvim-jdtls` is a follow-up if richer features are needed. |
| Server install | (a) Mason, (b) system package | (a) Mason | Consistent with existing servers; already wired via `mason-lspconfig`. |
| Root detection | (a) rely on `nvim-lspconfig` defaults, (b) explicit `root_markers` list including `pom.xml`, `build.gradle`, `build.gradle.kts`, `.git` | (b) explicit | Defaults are fine for Maven/Gradle but miss plain-Java fallbacks; explicit list is one `vim.lsp.config` line and matches the pattern from the 2025 DEV guide that is known to work. |
| Auto-start behavior | (a) `vim.lsp.enable` (starts on FileType), (b) `nvim-jdtls`'s `start_or_attach` per buffer | (a) | (a) fits the existing config; (b) requires the follow-up plugin. |

## Assumptions

- JDK is installed on the system and `java` / `javac` are on `PATH` (jdtls needs a JDK to run and to resolve project symbols).
- Neovim version is 0.11+ (already true — `vim.lsp.config` / `vim.lsp.enable` are in use).
- Internet access is available the first time so Mason can download jdtls.

## Open questions

- Does the user want `nvim-jdtls` features (organize imports command, code generation, test runner, debug adapter)? If yes, the approach switches to decision row 1 option (b) and the scope grows. Recommend: start minimal, revisit if needed.
- Lombok usage? If yes, `JDTLS_JVM_ARGS` must include the Lombok agent — out of scope for now, easy follow-up.
