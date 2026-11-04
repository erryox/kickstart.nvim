-- The shared DAP setup is loaded by kickstart.plugins.debug before this module.
local dap = require 'dap'
local dapui = require 'dapui'

local map = function(keys, func, desc, mode)
  mode = mode or 'n'
  vim.keymap.set(mode, keys, func, { desc = 'Debug: ' .. desc })
end

-- Preserve the user's normal-mode mappings outside a debug session.
local saved_arrows = nil
local function enable_debug_arrows()
  if saved_arrows then return end
  saved_arrows = {}
  for key, action in pairs { ['<Down>'] = dap.step_over, ['<Right>'] = dap.step_into, ['<Left>'] = dap.step_out } do
    saved_arrows[key] = {}
    for _, mapping in ipairs(vim.api.nvim_get_keymap 'n') do
      if mapping.lhs == key then saved_arrows[key] = mapping end
    end
    vim.keymap.set('n', key, action, { desc = 'Debug: step' })
  end
end
local function restore_arrows()
  if not saved_arrows then return end
  for key, mapping in pairs(saved_arrows) do
    vim.keymap.del('n', key)
    if next(mapping) then vim.fn.mapset('n', false, mapping) end
  end
  saved_arrows = nil
end
dap.listeners.after.event_initialized.custom_arrows = enable_debug_arrows
dap.listeners.before.event_terminated.custom_arrows = restore_arrows
dap.listeners.before.event_exited.custom_arrows = restore_arrows
dap.listeners.after.disconnect.custom_arrows = restore_arrows

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

map('<leader>du', function() dapui.toggle { reset = true } end, 'toggle [d]ebug [u]i')
map('<leader>dw', function() require('dap.ui.widgets').hover() end, '[d]ebug [w]idgets')
