local nvim_lsp = require('nvim_lsp')
local api = vim.api

local rooter = {
  cmd = [[autocmd VimEnter,BufReadPost,BufEnter * ++nested lua require'rooter'.root()]],
  config = {
    manual = false,
    echo = true,
    patterns = nvim_lsp.util.root_pattern('.git', 'Cargo.toml', 'go.mod'),
    cd_command = 'lcd',
    non_project_files == "current",
    start_path = function()
      return vim.fn.expand [[%:p:h]]
    end,
  }
}

function rooter.root()
  local config = rooter.config
  if vim.bo.filetype == config.filetypes_exclude then
    return
  end
  local res = config.patterns(config.start_path())
  if res then
    if config.echo then
      print("[rooter] changing directory to" .. " " .. res)
    end
    vim.cmd(config.cd_command .. " " .. res)
  elseif config.non_project_files == "current" then
    if config.echo then
      print("[rooter] changing directory to current file")
    end
    local current = vim.fn.expand [[%:p:h]]
    vim.cmd(config.cd_command .. " " .. current)
  elseif config.non_project_files == "home" then
    if config.echo then
      print("[rooter] changing directory to home")
    end
    vim.cmd(config.cd_command .. " " .. "~")
  end
end

function rooter.set_config(cfg)
  rooter.config = vim.tbl("keep", cfg, rooter.config)
end

function rooter.setup()
  if not rooter.config.manual then
    vim.cmd [[augroup rooter]]
    vim.cmd [[autocmd!]]
    vim.cmd(rooter.cmd)
    vim.cmd [[augroup END]]
  end
end

return rooter
