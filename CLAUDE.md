# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A personal Neovim configuration forked from [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim). It uses `vim.pack`, the plugin manager built into Neovim (≥0.11), rather than lazy.nvim or packer.

## Managing plugins

```
:lua vim.pack.update()                        -- update all plugins
:lua vim.pack.update(nil, { offline = true }) -- inspect state without fetching
:Mason                                         -- manage LSP servers / DAP adapters / linters
:TSUpdate                                      -- update treesitter parsers
:checkhealth                                   -- diagnose issues
```

## Formatting

Lua files are formatted with **stylua** (config: `.stylua.toml`). Go files use **goimports** then **gofmt**. Both run automatically on save via `conform.nvim`. Manual format: `<leader>f`.

To run stylua outside Neovim:
```
stylua lua/ init.lua
```

## Architecture

### `init.lua` — single main file, 10 numbered sections

| Section | Content |
|---------|---------|
| 1 | Core options (`vim.o`, `vim.opt`) |
| 2 | Basic keymaps and autocommands |
| 3 | `vim.pack` intro + `PackChanged` build hooks (runs `make` for fzf-native, `TSUpdate` for treesitter, etc.) |
| 4 | UI plugins: gitsigns, which-key, kanagawa colorscheme, todo-comments, mini.nvim (icons, ai, surround, statusline) |
| 5 | Telescope setup + all `<leader>s*` search keymaps + LSP picker keymaps (wired on `LspAttach`) |
| 6 | LSP: fidget, nvim-lspconfig, Mason, configured servers (gopls, graphql, stylua, lua_ls) |
| 7 | conform.nvim formatting (auto-format on save for `lua` and `go`) |
| 8 | blink.cmp + LuaSnip autocomplete |
| 9 | nvim-treesitter (auto-installs parsers on `FileType`) |
| 10 | Loads kickstart example plugins and the custom plugin directory |

### `lua/kickstart/plugins/` — opt-in example plugins

Each file is `require`d explicitly in section 10 of `init.lua`. Currently active:
- `debug.lua` — nvim-dap + dapui + mason-nvim-dap + dap-go (F5/F1/F2/F3/F7 keymaps)
- `lint.lua` — nvim-lint (markdownlint on markdown files)
- `autopairs.lua` — mini.pairs or nvim-autopairs
- `neo-tree.lua` — file tree, toggle with `\`
- `gitsigns.lua` — additional gitsigns keymaps

### `lua/custom/plugins/` — user's own plugins

`lua/custom/plugins/init.lua` auto-discovers and loads every `*.lua` file in this directory (follows symlinks). Add new plugins here without touching `init.lua`.

Current custom plugins:
- `dap.lua` — extended DAP setup with arrow-key step bindings and `<leader>dc`
- `neotest.lua` — neotest with `neotest-golang` (uses `gotestsum`, `-tags=integration`, `<leader>t*` keymaps)
- `toggleterm.lua` — toggleterm with `<C-\>` to open

## LSP configuration pattern

Servers are declared in the `servers` table in section 6 as `name → vim.lsp.Config`. Adding a server:
1. Add an entry to `servers` (empty table `{}` for defaults)
2. Mason will install it automatically via `mason-tool-installer`
3. Call `vim.lsp.config(name, opts)` + `vim.lsp.enable(name)` — already handled by the loop at the end of section 6

## Primary language focus

Go is the main language: `gopls` (with `-tags=integration` build flags), `dap-go` + `delve`, `neotest-golang` (runner: `gotestsum`), and `goimports`/`gofmt` formatting. The neotest adapter is configured with specific environment variables for a local project (`BOZON_GOGOL_NG_*`).
