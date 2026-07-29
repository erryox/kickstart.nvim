---Because most plugins are hosted on GitHub, you can use the helper
---function to have less repetition in the following sections.
---@param repo string
---@return string
local function gh(repo) return 'https://github.com/' .. repo end

local neotest_plugins = {
  gh 'nvim-lua/plenary.nvim',
  gh 'antoinemadec/FixCursorHold.nvim',
  gh 'nvim-neotest/nvim-nio',
  gh 'nvim-neotest/neotest',
  gh 'fredrikaverpil/neotest-golang',
}

vim.pack.add(neotest_plugins)

local neotest = require 'neotest'

---@diagnostic disable-next-line: missing-fields
neotest.setup {
  adapters = {
    require 'neotest-golang' {
      runner = 'gotestsum',
      warn_test_name_dupes = false,
      go_test_args = { '-v', '-race', '-tags=integration' },
      env = {
        BOZON_GOGOL_NG_LOCAL_CONFIG_ENABLED = 'true',
        BOZON_GOGOL_NG_LOCAL_CONFIG_PATH = '/Users/maksim_ignatyev/Projects/gogol-ng/.o3/k8s',
        BOZON_GOGOL_NG_LOCAL_CONFIG_NAME = 'values_local.yaml',
      },
      dap_go_opts = {
        delve = {
          build_flags = '-tags=integration',
        },
      },
    },
  },
}

local map = function(keys, func, desc, mode)
  mode = mode or 'n'
  vim.keymap.set(mode, keys, func, { desc = 'Neotest: ' .. desc })
end

local function wrap(f, ...)
  vim.cmd 'wa'
  neotest.output_panel.clear()
  f(...)
end

map('<leader>ta', function() wrap(neotest.run.attach) end, '[t]est [a]ttach')
map('<leader>tf', function() wrap(neotest.run.run, vim.fn.expand '%') end, '[t]est run [f]ile')
map('<leader>tA', function() wrap(neotest.run.run, vim.uv.cwd()) end, '[t]est [A]ll files')
map('<leader>tS', function() wrap(neotest.run.run, { suite = true }) end, '[t]est [S]uite')
map('<leader>tn', function() wrap(neotest.run.run) end, '[t]est [n]earest')
map('<leader>tl', function() wrap(neotest.run.run_last) end, '[t]est [l]ast')
map('<leader>ts', function() neotest.summary.toggle() end, '[t]est [s]ummary')
map('<leader>to', function() neotest.output.open { enter = true, auto_close = true } end, '[t]est [o]utput')
map('<leader>tO', function() neotest.output_panel.toggle() end, '[t]est [O]utput panel')
map('<leader>tt', function() neotest.run.stop() end, '[t]est [t]erminate')
map('<leader>td', function() wrap(neotest.run.run, { suite = false, strategy = 'dap' }) end, 'Debug nearest test')
map('<leader>tD', function() wrap(neotest.run.run, { vim.fn.expand '%', strategy = 'dap' }) end, 'Debug current file') ---@diagnostic disable-line: missing-fields
