vim.pack.add { 'https://github.com/lewis6991/gitsigns.nvim' }

require('gitsigns').setup {
  on_attach = function(bufnr)
    local gitsigns = require 'gitsigns'
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
    map('v', '<leader>hs', function() gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' } end, 'Git stage hunk')
    map('v', '<leader>hr', function() gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' } end, 'Git reset hunk')
    map('n', '<leader>hs', gitsigns.stage_hunk, 'Git stage hunk')
    map('n', '<leader>hr', gitsigns.reset_hunk, 'Git reset hunk')
    map('n', '<leader>hS', gitsigns.stage_buffer, 'Git stage buffer')
    map('n', '<leader>hu', gitsigns.stage_hunk, 'Git undo stage hunk')
    map('n', '<leader>hR', gitsigns.reset_buffer, 'Git reset buffer')
    map('n', '<leader>hp', gitsigns.preview_hunk, 'Git preview hunk')
    map('n', '<leader>hb', gitsigns.blame_line, 'Git blame line')
    map('n', '<leader>hd', gitsigns.diffthis, 'Git diff against index')
    map('n', '<leader>hD', function() gitsigns.diffthis '@' end, 'Git diff against last commit')
    map('n', '<leader>tb', gitsigns.toggle_current_line_blame, 'Toggle git blame')
    map('n', '<leader>tD', gitsigns.preview_hunk_inline, 'Toggle deleted lines')
  end,
}
