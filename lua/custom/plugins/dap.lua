---Because most plugins are hosted on GitHub, you can use the helper
---function to have less repetition in the following sections.
---@param repo string
---@return string
local function gh(repo) return 'https://github.com/' .. repo end

local dap_plugins = {
  gh 'mfussenegger/nvim-dap',
  gh 'rcarriga/nvim-dap-ui',
  gh 'leoluz/nvim-dap-go',
}

vim.pack.add(dap_plugins)

local dap = require 'dap'
local dapui = require 'dapui'

dapui.setup()

dap.listeners.before.attach.dapui_config = function() dapui.open() end
dap.listeners.before.launch.dapui_config = function() dapui.open() end
dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

local map = function(keys, func, desc, mode)
  mode = mode or 'n'
  vim.keymap.set(mode, keys, func, { desc = 'Neotest: ' .. desc })
end

map('<down>', dap.step_over, 'debug: step over')
map('<right>', dap.step_into, 'debug: step into')
map('<left>', dap.step_out, 'debug: step out')

map('<leader>db', function() dap.toggle_breakpoint() end, 'toggle [d]ebug [b]reakpoint')
map('<leader>dB', function() dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, '[d]ebug conditional [B]reakpoint')
map('<leader>dc', function() dap.continue() end, '[d]ebug [c]ontinue (start here)')
map('<leader>dC', function() dap.run_to_cursor() end, '[d]ebug [C]ursor')
map('<leader>do', function() dap.step_over() end, '[d]ebug step [o]ver')
map('<leader>dO', function() dap.step_out() end, '[d]ebug step [O]ut')
map('<leader>di', function() dap.step_into() end, '[d]ebug [i]nto')
map('<leader>dj', function() dap.down() end, '[d]ebug [j]ump down')
-- map('<leader>dk', function() dap.up() end, '[d]ebug [k]ump up')
map('<leader>dl', function() dap.run_last() end, '[d]ebug [l]ast')
map('<leader>dp', function() dap.pause() end, '[d]ebug [p]ause')
map('<leader>dr', function() dap.repl.toggle() end, '[d]ebug [r]epl')
map('<leader>dR', function() dap.clear_breakpoints() end, '[d]ebug [R]emove breakpoints')
map('<leader>ds', function() dap.session() end, '[d]ebug [s]ession')
map('<leader>dt', function() dap.terminate() end, '[d]ebug [t]erminate')

map('<leader>du', function() dapui.toggle() end, 'toggle [d]ebug [u]i')
map('<leader>dw', function() require('dap.ui.widgets').hover() end, '[d]ebug [w]idgets')

require('dap-go').setup()
