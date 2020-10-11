local nvim_lsp = require('nvim_lsp')
local api = vim.api

local rooter = {
  cmd = [[autocmd VimEnter,BufReadPost,BufEnter * ++nested lua require'rooter'.root()]],
  current_working_directory = nil,
  config = {
    manual = false,
    echo = true,
    patterns = {
      '.git',
      'Cargo.toml',
      'go.mod',
    },
    cd_command = 'lcd',
    non_project_files = "current",
    start_path = function()
      return vim.fn.expand [[%:p:h]]
    end,
  }
}

local function get_new_directory()
  local config = rooter.config
  local res = rooter.fn(config.start_path())
  if res then
    return res
  elseif config.non_project_files == "current" then
    return config.start_path()
  elseif config.non_project_files == "home" then
    return "~"
  end
end

function rooter.root()
  local config = rooter.config
  if vim.bo.filetype == config.filetypes_exclude then
    return
  end
  local new_dir = get_new_directory()
  if new_dir ~= rooter.current_working_directory then
    print("[rooter] changing directory to" .. " " .. new_dir)
    vim.cmd(config.cd_command .. " " .. new_dir)
    rooter.current_working_directory = new_dir
  end
end

local function check_config(cfg)
  if cfg.cd_command ~= "lcd" or cfg.cd_command ~= "cd" or cfg.cd_command ~= "tcd" then
    api.nvim_err_writeln(string.format("%s is not a valid cd_command (must be cd, lcd, or tcd)", cd_command))
    return false
  else
    return true
  end
  if cfg.non_project_files ~= 'current' or cfg.non_project_files ~= 'home' then
    api.nvim_err_writeln(string.format("%s is not a valid value to non_project_files (must be home or current)", cfg.non_project_files))
    return false
  else
    return true
  end
end

function rooter.set_config(cfg)
  local new_config = vim.tbl("keep", cfg, rooter.config)
  if check_config(new_config) then
    rooter.config = new_config
  end
end

local function create_function()
  rooter.fn = nvim_lsp.util.root_pattern(rooter.config.patterns)
end

function rooter.setup()
  create_function()
  if not rooter.config.manual then
    vim.cmd [[augroup rooter]]
    vim.cmd [[autocmd!]]
    vim.cmd(rooter.cmd)
    vim.cmd [[augroup END]]
  end
end

return rooter
