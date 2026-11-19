vim.loader.enable()

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

vim.o.number = true
vim.o.mouse = 'a'
vim.o.showmode = false
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.tabstop = 2
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true

vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)
vim.filetype.add { extension = { ejs = 'ejs' } }

vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = { min = vim.diagnostic.severity.ERROR } },
  signs = vim.g.have_nerd_font and {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN] = '󰀪 ',
      [vim.diagnostic.severity.INFO] = '󰋽 ',
      [vim.diagnostic.severity.HINT] = '󰌶 ',
    },
  } or {},
  virtual_text = {
    source = 'if_many',
    spacing = 2,
    format = function(diagnostic) return diagnostic.message end,
  },
}

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('t', '<C-x>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.highlight.on_yank() end,
})

vim.api.nvim_create_autocmd('TermOpen', {
  group = vim.api.nvim_create_augroup('custom-term-open', { clear = true }),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.spell = false
  end,
})

vim.keymap.set('n', '<leader>st', function()
  vim.cmd.vnew()
  vim.cmd.term()
  vim.cmd.wincmd 'J'
  vim.api.nvim_win_set_height(0, 15)
end, { desc = 'Open [s]hort [t]erminal' })

local function gh(repo)
  return 'https://github.com/' .. repo
end

local function run_build(name, cmd, cwd)
  local result = vim.system(cmd, { cwd = cwd }):wait()
  if result.code ~= 0 then
    local stderr = result.stderr or ''
    local stdout = result.stdout or ''
    local output = stderr ~= '' and stderr or stdout
    if output == '' then output = 'No output from build command.' end
    vim.notify(('Build failed for %s:\n%s'):format(name, output), vim.log.levels.ERROR)
  end
end

vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(event)
    local name = event.data.spec.name
    local kind = event.data.kind
    if kind ~= 'install' and kind ~= 'update' then return end

    if name == 'telescope-fzf-native.nvim' and vim.fn.executable 'make' == 1 then
      run_build(name, { 'make' }, event.data.path)
    elseif name == 'LuaSnip' then
      if vim.fn.has 'win32' ~= 1 and vim.fn.executable 'make' == 1 then
        run_build(name, { 'make', 'install_jsregexp' }, event.data.path)
      end
    elseif name == 'nvim-treesitter' then
      if not event.data.active then vim.cmd.packadd 'nvim-treesitter' end
      vim.cmd 'TSUpdate'
    end
  end,
})

vim.pack.add { gh 'tpope/vim-sleuth' }

vim.pack.add { gh 'lewis6991/gitsigns.nvim' }
local gitsigns = require 'gitsigns'
gitsigns.setup {
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
  on_attach = function(bufnr)
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    map('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal { ']c', bang = true }
      else
        gitsigns.nav_hunk 'next'
      end
    end, 'Jump to next git change')
    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal { '[c', bang = true }
      else
        gitsigns.nav_hunk 'prev'
      end
    end, 'Jump to previous git change')
    map('n', '<leader>hs', gitsigns.stage_hunk, 'Git stage hunk')
    map('n', '<leader>hr', gitsigns.reset_hunk, 'Git reset hunk')
    map('n', '<leader>hS', gitsigns.stage_buffer, 'Git stage buffer')
    map('n', '<leader>hR', gitsigns.reset_buffer, 'Git reset buffer')
    map('n', '<leader>hp', gitsigns.preview_hunk, 'Git preview hunk')
    map('n', '<leader>hb', function() gitsigns.blame_line { full = true } end, 'Git blame line')
    map('n', '<leader>hd', gitsigns.diffthis, 'Git diff against index')
    map('n', '<leader>hD', function() gitsigns.diffthis '~' end, 'Git diff against last commit')
    map('n', '<leader>tb', gitsigns.toggle_current_line_blame, 'Toggle git blame')
    map({ 'o', 'x' }, 'ih', gitsigns.select_hunk, 'Select git hunk')
  end,
}

vim.pack.add { gh 'folke/which-key.nvim' }
require('which-key').setup {
  delay = 0,
  icons = { mappings = vim.g.have_nerd_font },
  spec = {
    { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
    { '<leader>d', group = '[D]ocument' },
    { '<leader>r', group = '[R]ename' },
    { '<leader>s', group = '[S]earch' },
    { '<leader>w', group = '[W]orkspace' },
    { '<leader>t', group = '[T]oggle' },
    { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
    { 'gr', group = 'LSP Actions' },
  },
}

vim.pack.add { gh 'folke/todo-comments.nvim', gh 'nvim-lua/plenary.nvim' }
require('todo-comments').setup { signs = false }

vim.pack.add { gh 'nvim-mini/mini.nvim' }
if vim.g.have_nerd_font then
  require('mini.icons').setup()
  MiniIcons.mock_nvim_web_devicons()
end

require('mini.ai').setup {
  mappings = { around_next = 'aa', inside_next = 'ii' },
  n_lines = 500,
}
require('mini.surround').setup()
local statusline = require 'mini.statusline'
statusline.setup { use_icons = vim.g.have_nerd_font }
---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function() return '%2l:%-2v' end

local telescope_plugins = {
  gh 'nvim-telescope/telescope.nvim',
  gh 'nvim-telescope/telescope-ui-select.nvim',
}
if vim.fn.executable 'make' == 1 then
  table.insert(telescope_plugins, gh 'nvim-telescope/telescope-fzf-native.nvim')
end
if vim.g.have_nerd_font then
  table.insert(telescope_plugins, gh 'nvim-tree/nvim-web-devicons')
end
vim.pack.add(telescope_plugins)

if vim.g.have_nerd_font then
  require('nvim-web-devicons').set_icon {
    mdx = { icon = '', name = 'Mdx' },
  }
end

require('telescope').setup {
  extensions = {
    ['ui-select'] = { require('telescope.themes').get_dropdown() },
  },
}
pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')

local telescope = require 'telescope.builtin'
vim.keymap.set('n', '<leader>sh', telescope.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', telescope.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sf', telescope.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>ss', telescope.builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set({ 'n', 'v' }, '<leader>sw', telescope.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', telescope.live_grep, { desc = '[S]earch [G]rep' })
vim.keymap.set('n', '<leader>sd', telescope.diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', telescope.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', telescope.oldfiles, { desc = '[S]earch Recent Files' })
vim.keymap.set('n', '<leader>sc', telescope.commands, { desc = '[S]earch [C]ommands' })
vim.keymap.set('n', '<leader><leader>', telescope.buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  telescope.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown { winblend = 10, previewer = false })
end, { desc = 'Fuzzily search in current buffer' })
vim.keymap.set('n', '<leader>s/', function()
  telescope.live_grep { grep_open_files = true, prompt_title = 'Live Grep in Open Files' }
end, { desc = '[S]earch [/] in Open Files' })
vim.keymap.set('n', '<leader>sn', function()
  telescope.find_files { cwd = vim.fn.stdpath 'config', follow = true }
end, { desc = '[S]earch [N]eovim files' })

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
  callback = function(event)
    local buf = event.buf
    vim.keymap.set('n', 'grr', telescope.lsp_references, { buffer = buf, desc = 'Goto references' })
    vim.keymap.set('n', 'gri', telescope.lsp_implementations, { buffer = buf, desc = 'Goto implementations' })
    vim.keymap.set('n', 'grd', telescope.lsp_definitions, { buffer = buf, desc = 'Goto definitions' })
    vim.keymap.set('n', 'gO', telescope.lsp_document_symbols, { buffer = buf, desc = 'Open document symbols' })
    vim.keymap.set('n', 'gW', telescope.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open workspace symbols' })
    vim.keymap.set('n', 'grt', telescope.lsp_type_definitions, { buffer = buf, desc = 'Goto type definition' })
  end,
})

vim.pack.add {
  gh 'folke/lazydev.nvim',
  gh 'neovim/nvim-lspconfig',
  gh 'mason-org/mason.nvim',
  gh 'mason-org/mason-lspconfig.nvim',
  gh 'WhoIsSethDaniel/mason-tool-installer.nvim',
  gh 'j-hui/fidget.nvim',
  gh 'hrsh7th/cmp-nvim-lsp',
}
require('lazydev').setup {
  library = {
    { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
  },
}
require('fidget').setup {}
require('mason').setup {}
require('mason-lspconfig').setup { automatic_enable = false }

local capabilities = vim.tbl_deep_extend(
  'force',
  vim.lsp.protocol.make_client_capabilities(),
  require('cmp_nvim_lsp').default_capabilities()
)

local servers = {
  lua_ls = {
    on_init = function(client)
      client.server_capabilities.documentFormattingProvider = false
      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then
          return
        end
      end

      client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
        runtime = {
          version = 'LuaJIT',
          path = { 'lua/?.lua', 'lua/?/init.lua' },
        },
        workspace = {
          checkThirdParty = false,
          library = vim.api.nvim_get_runtime_file('', true),
        },
      })
    end,
    settings = {
      Lua = {
        completion = { callSnippet = 'Replace' },
        format = { enable = false },
      },
    },
  },
  harper_ls = { filetypes = { 'mdx', 'yaml' } },
}

local ensure_installed = vim.tbl_keys(servers)
vim.list_extend(ensure_installed, {
  'stylua',
  'css-lsp',
  'eslint-lsp',
  'harper-ls',
  'lua-language-server',
  'prettier',
  'typescript-language-server',
})
require('mason-tool-installer').setup { ensure_installed = ensure_installed }

for name, server in pairs(servers) do
  server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
  vim.lsp.config(name, server)
  vim.lsp.enable(name)
end

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc, mode)
      vim.keymap.set(mode or 'n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    map('gd', telescope.lsp_definitions, '[G]oto [D]efinition')
    map('gr', telescope.lsp_references, '[G]oto [R]eferences')
    map('gI', telescope.lsp_implementations, '[G]oto [I]mplementation')
    map('<leader>D', telescope.lsp_type_definitions, 'Type [D]efinition')
    map('<leader>ds', telescope.lsp_document_symbols, '[D]ocument [S]ymbols')
    map('<leader>ws', telescope.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method('textDocument/documentHighlight', event.buf) then
      local group = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = group,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = group,
        callback = vim.lsp.buf.clear_references,
      })
      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
        callback = function(args)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = args.buf }
        end,
      })
    end

    if client and client:supports_method('textDocument/inlayHint', event.buf) then
      map('<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
      end, '[T]oggle Inlay [H]ints')
    end
  end,
})

vim.pack.add { gh 'stevearc/conform.nvim' }
require('conform').setup {
  notify_on_error = false,
  format_on_save = function(bufnr)
    local disable_filetypes = { c = true, cpp = true }
    if disable_filetypes[vim.bo[bufnr].filetype] then return nil end
    return { timeout_ms = 500, lsp_format = 'fallback' }
  end,
  formatters_by_ft = {
    lua = { 'stylua' },
    svelte = { 'prettier' },
    astro = { 'prettier' },
    markdown = { 'deno_fmt', 'prettier' },
    mdx = { 'deno_fmt', 'prettier' },
    html = { 'deno_fmt', 'prettier' },
    css = { 'deno_fmt', 'prettier' },
    typescript = { 'deno_fmt', 'prettier' },
    javascript = { 'deno_fmt', 'prettier' },
    json = { 'deno_fmt' },
    python = { 'isort', 'black' },
    go = { 'gofumpt', 'gci' },
  },
}
vim.keymap.set({ 'n', 'v' }, '<leader>f', function()
  require('conform').format { async = true }
end, { desc = '[F]ormat buffer' })

vim.pack.add {
  { src = gh 'L3MON4D3/LuaSnip', version = vim.version.range '2.*' },
  gh 'hrsh7th/nvim-cmp',
  gh 'saadparwaiz1/cmp_luasnip',
  gh 'hrsh7th/cmp-path',
  gh 'hrsh7th/cmp-nvim-lsp-signature-help',
}
require('luasnip').setup {}

local cmp = require 'cmp'
local luasnip = require 'luasnip'
cmp.setup {
  snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
  completion = { completeopt = 'menu,menuone,noinsert' },
  mapping = cmp.mapping.preset.insert {
    ['<C-y>'] = cmp.mapping.confirm { select = true },
    ['<CR>'] = cmp.mapping.confirm { select = true },
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<C-l>'] = cmp.mapping(function()
      if luasnip.expand_or_locally_jumpable() then luasnip.expand_or_jump() end
    end, { 'i', 's' }),
    ['<C-h>'] = cmp.mapping(function()
      if luasnip.locally_jumpable(-1) then luasnip.jump(-1) end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'lazydev', group_index = 0 },
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
    { name = 'nvim_lsp_signature_help' },
  },
}

require('custom.plugins')

-- vim: ts=2 sts=2 sw=2 et
