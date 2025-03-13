return {
  'brenoprata10/nvim-highlight-colors',
  config = function()
    require('nvim-highlight-colors').setup {
      render = 'virtual',
      virtual_symbol = '■',
      enable_hex = true,
      enable_rgb = true,
      enable_named_colors = true,
      enable_tailwind = true,
    }
  end,
}
