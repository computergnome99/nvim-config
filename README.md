# Neovim configuration

A personalized Kickstart-based configuration using Neovim's built-in `vim.pack`
plugin manager. It requires Neovim 0.12 or newer.

## Requirements

- `git`, `make`, `tar`, `curl`, and a C compiler
- `ripgrep` for Telescope's live grep
- `tree-sitter-cli` 0.26.1 or newer to build and update Tree-sitter parsers
- Language tools for the languages you use (Mason installs the configured LSP
  servers and formatters)
- A Nerd Font is optional; set `vim.g.have_nerd_font` in `init.lua` accordingly

On systems with Cargo, install the Tree-sitter CLI with:

```sh
cargo install tree-sitter-cli
```

## Install

Clone this repository into Neovim's config directory and start Neovim:

```sh
git clone https://github.com/computergnome99/nvim-config.git "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
nvim
```

`vim.pack` installs the configured plugins on first startup. To inspect pending
updates, run `:lua vim.pack.update(nil, { offline = true })`; to update plugins,
run `:lua vim.pack.update()`.
The generated `nvim-pack-lock.json` records installed revisions; keep it under
version control to reproduce your plugin versions.

## Organization

- `init.lua` contains core options, keymaps, and the Kickstart plugin setup.
- `lua/custom/plugins/` contains personal plugin modules loaded by
  `require('custom.plugins')`.
- `lua/kickstart/plugins/` contains optional examples. Load one explicitly from
  `init.lua`, for example `require('kickstart.plugins.indent_line')`.

Treesitter uses its current `main` branch. The MDX plugin maps `.mdx` buffers to
the Markdown parser, with TSX/TypeScript injections enabled.
