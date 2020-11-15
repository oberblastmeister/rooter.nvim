local nvim_lsp = require('lspconfig')
local api = vim.api

local M = {}

local current_working_directory
local root_fn
local config
local setup_config

do
  local default_config = {
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

  local function create_root_fn()
    root_fn = nvim_lsp.util.root_pattern(config.patterns)
  end

  local function check_config(cfg)
    if not (cfg.cd_command == "lcd" or cfg.cd_command == "cd" or cfg.cd_command == "tcd") then
      api.nvim_err_writeln(string.format("%s is not a valid cd_command (must be cd, lcd, or tcd)", cfg.cd_command))
      return false
    else
      return true
    end

    if not (cfg.non_project_files == 'current' or cfg.non_project_files == 'home') then
      api.nvim_err_writeln(string.format("%s is not a valid value to non_project_files (must be home or current)", cfg.non_project_files))
      return false
    else
      return true
    end
  end

  setup_config = function(user_config)
    local new_config = vim.tbl_extend("keep", user_config, default_config)
    if check_config(new_config) then
      config = new_config
    else
      api.nvim_err_writeln("There were errors when setting the config. Keeping default values.")
      config = default_config
    end
    create_root_fn()
  end
end

function M.setup(user_config)
  setup_config(user_config)
  if not config.manual then
    vim.cmd [[augroup rooter]]
    vim.cmd [[autocmd!]]
    vim.cmd [[autocmd VimEnter,BufReadPost,BufEnter * lua require'rooter'.root()]]
    vim.cmd [[augroup END]]
  end
end

local function get_new_directory()
  local res = root_fn(config.start_path())
  if res then
    return res
  elseif config.non_project_files == "current" then
    return config.start_path()
  elseif config.non_project_files == "home" then
    return "~"
  end
end

function M.root()
  -- do not root if in excluded filetypes
  if vim.bo.filetype == config.filetypes_exclude then
    return
  end

  -- do not root on terminal buffers
  if vim.bo.buftype == "terminal" then
    return
  end

  local new_dir = get_new_directory()

  if new_dir == current_working_directory then
    return
  end

  if config.echo then
    print("[rooter] changing directory to" .. " " .. new_dir)
  end

  vim.cmd(config.cd_command .. " " .. new_dir)
  current_working_directory = new_dir
end

return M
