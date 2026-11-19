vim.pack.add {
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
}

local treesitter = require 'nvim-treesitter'
treesitter.setup { install_dir = vim.fn.stdpath 'data' .. '/site' }
vim.treesitter.language.register('embedded_template', 'ejs')

local parsers = {
  'bash',
  'c',
  'diff',
  'embedded_template',
  'html',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'query',
  'tsx',
  'typescript',
  'vim',
  'vimdoc',
}
treesitter.install(parsers)

local available_parsers = treesitter.get_available()
local group = vim.api.nvim_create_augroup('custom-treesitter', { clear = true })

local function start_treesitter(buf, language)
  if not vim.api.nvim_buf_is_valid(buf) or not vim.treesitter.language.add(language) then return end

  vim.treesitter.start(buf, language)
  if vim.treesitter.query.get(language, 'indents') then
    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end
end

vim.api.nvim_create_autocmd('FileType', {
  group = group,
  callback = function(args)
    if args.match == 'markdown' then
      vim.treesitter.stop(args.buf)
      vim.bo[args.buf].syntax = 'markdown'
      return
    end

    local language = vim.treesitter.language.get_lang(args.match)
    if not language then return end

    local installed_parsers = treesitter.get_installed 'parsers'
    if vim.tbl_contains(installed_parsers, language) then
      start_treesitter(args.buf, language)
    elseif vim.tbl_contains(available_parsers, language) then
      treesitter.install(language):await(function() start_treesitter(args.buf, language) end)
    else
      start_treesitter(args.buf, language)
    end
  end,
})
