local rooter = {}

rooter.on_attach = function(client)
  local root_dir = client.config.root_dir
  vim.api.nvim_set_current_dir(root_dir)
end

return rooter
