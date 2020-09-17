local rooter = {}

local nvim_lsp = require('nvim_lsp')
local configs = require('nvim_lsp/configs')

-- local clients = vim.tbl_values(vim.lsp.buf_get_clients())
-- print(vim.inspect(clients))

-- put this in on attach for each lsp client
rooter.on_attach = function(client, options)
  -- print(vim.inspect(client))
  local root_dir = client.config.root_dir
  vim.api.nvim_set_current_dir(root_dir)

  if options ~= nil then
    if options.rooter_echo == true then
      print('[rooter] changing to directory', root_dir)
    end
  end
end

rooter.root = function()
  local configs = require('nvim_lsp/configs')
  print(vim.inspect(configs))
end

return rooter
