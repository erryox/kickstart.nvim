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
  gh 'S1M0N38/love2d.nvim',
  gh 'folke/edgy.nvim',
  gh 'lucobellic/edgy-group.nvim',
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
      title = 'Neo-Tree',
      ft = 'neo-tree',
      filter = function(buf) return vim.b[buf].neo_tree_source == 'filesystem' end,
      size = { width = 40 },
      -- open = 'Neotree position=left filesystem',
    },
    {
      title = 'Neo-Tree Git',
      ft = 'neo-tree',
      filter = function(buf) return vim.b[buf].neo_tree_source == 'git_status' end,
      size = { width = 40 },
      -- open = 'Neotree position=right git_status',
    },
  },
  right = {
    {
      ft = 'dapui_scopes',
      title = 'Debug Scopes',
      size = { width = 40 },
      -- open = function() require('dapui').open() end,
    },
    {
      ft = 'dapui_breakpoints',
      title = 'Debug Breakpoints',
      size = { width = 40 },
      -- open = function() require('dapui').open() end,
    },
    {
      ft = 'dapui_stacks',
      title = 'Debug Stacks',
      size = { width = 40 },
      -- open = function() require('dapui').open() end,
    },
    {
      ft = 'dapui_watches',
      title = 'Debug Watches',
      size = { width = 40 },
      -- open = function() require('dapui').open() end,
    },
    {
      ft = 'neotest-summary',
      title = 'Neotest Summary',
      size = { width = 40 },
      open = function() require('neotest').summary.open() end,
    },
  },
  bottom = {
    {
      ft = 'toggleterm',
      title = 'Toggleterm',
      size = { height = 0.2 },
      filter = function(_, win) return vim.api.nvim_win_get_config(win).relative == '' end,
    },
    -- {
    --   ft = 'dap-repl',
    --   title = 'Debug REPL',
    --   size = { height = 0.2 },
    --   open = function() require('dapui').open() end,
    -- },
    -- {
    --   ft = 'dapui_console',
    --   title = 'Debug Console',
    --   size = { height = 0.2 },
    --   open = function() require('dapui').open() end,
    -- },
  },
  animate = { enabled = false },
  wo = {
    winbar = false,
    winfixwidth = false,
    winfixheight = false,
  },
  -- mouse_resize = true,
}

---@diagnostic disable: missing-fields
require('edgy-group').setup {
  groups = {
    left = {
      { icon = '', titles = { 'Neo-Tree' } },
      { icon = '', titles = { 'Neo-Tree Git' } },
      { icon = '', titles = { 'Outline' } },
    },
    right = {
      { titles = { 'Neotest Summary' } },
      { titles = { 'Debug Scopes', 'Debug Breakpoints', 'Debug Stack', 'Debug Watches' } },
    },
  },
  statusline = {
    separators = { ' ', ' ' },
    clickable = true,
    colored = true,
    colors = {
      active = 'PmenuSel',
      inactive = 'Pmenu',
    },
  },
}

map('<leader>el', function() require('edgy-group').open_group_offset('right', 1) end, '')
map('<leader>eh', function() require('edgy-group').open_group_offset('right', -1) end, '')

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
