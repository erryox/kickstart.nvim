---Because most plugins are hosted on GitHub, you can use the helper
---function to have less repetition in the following sections.
---@param repo string
---@return string
local function gh(repo) return 'https://github.com/' .. repo end

local map = function(keys, func, desc, mode)
  mode = mode or 'n'
  vim.keymap.set(mode, keys, func, { desc = 'Neotest: ' .. desc })
end

local plugins = {
  gh 'folke/snacks.nvim',
  { src = gh 'erryox/edgy.nvim', version = 'feat/mouse-resize' },
  { src = gh 'erryox/love2d.nvim', version = 'fix/detection' }, -- TODO: вернуть на S1M0N38/love2d.nvim после вливания PR #27
}

vim.pack.add(plugins)

require('snacks').setup {
  scroll = {
    enabled = true,
    animate = {
      easing = 'inOutCubic',
    },
    animate_repeat = {
      easing = 'inOutCubic',
    },
  },
}

require('edgy').setup {
  left = {
    {
      ft = 'neo-tree',
      title = 'Neo-Tree',
      size = { width = 30 },
      filter = function(buf) return vim.b[buf].neo_tree_source == 'filesystem' end,
    },
  },
  bottom = {
    {
      ft = 'toggleterm',
      size = { height = 0.3 },
      -- toggleterm can also open as a float; only dock split terminals
      filter = function(_, win) return vim.api.nvim_win_get_config(win).relative == '' end,
    },
  },
  animate = { enabled = false },
  wo = {
    winbar = false,
    winfixwidth = false,
    winfixheight = false,
  },
  mouse_resize = true,
}

local love_term = nil

vim.api.nvim_create_autocmd('User', {
  pattern = 'LoveProjectEnter',
  callback = function(ev)
    local src = vim.fn.fnamemodify(ev.data.path_to_main_lua, ':h')
    map('<leader>r', function()
      local Terminal = require('toggleterm.terminal').Terminal
      if love_term then love_term:shutdown() end
      love_term = Terminal:new { cmd = 'love ' .. src, close_on_exit = false }
      love_term:open()
    end, 'Run LÖVE')
  end,
})

vim.api.nvim_create_autocmd('User', {
  pattern = 'LoveProjectLeave',
  callback = function()
    love_term = nil
    pcall(vim.keymap.del, 'n', '<leader>r')
  end,
})

require('love2d').setup {
  output = false,
}
