# rooter.nvim

*rooter.nvim* sets the working directory of neovim based on root patterns.
Heavily inspired by vim-rooter except writen in lua and uses nvim-lspconfig to
find the root directory.

## Pros

- Uses the same root patterns as language servers if using nvim-lspconfig
- written in lua
- fast

## Installation

If using vim-plug:

`Plug 'oberblastmeister/rooter.nvim'`

[Packer.nvim](https://github.com/wbthomason/packer.nvim):

`use 'oberblastmeister/rooter.nvim'`

## Configuration

*Note: the configuration is written in lua, not vimscript*

Initialize with default values and setup autocommand:

```lua
require'rooter'.setup()
```

To use different configuration values, call `rooter.set_config(cfg)` before calling `rooter.setup()`

Example:

```lua
local rooter = require("rooter")

-- these are all of the default values
rooter.set_config {
    manual = false, -- weather to setup autocommand to root every time a file is opened
    echo = true, -- echo every time rooter is triggered
    patterns = { -- the patterns to find
      '.git',    -- same as patterns passed to nvim_lsp.util.root_pattern(patterns...)
      'Cargo.toml',
      'go.mod',
    },
    cd_command = 'lcd', -- the cd command to use, possible values are 'lcd', 'cd', and 'tcd'
    -- what to do when the rooter pattern is not found
    -- if this is 'current', will cd to the parent directory of current file
    -- if this is 'home', will cd to the home directory
    -- if this is 'none', will not do anything
    non_project_files = 'current',

    -- the start path to pass to nvim_lsp.util.root_pattern(patterns...)
    start_path = function()
      return vim.fn.expand [[%:p:h]]
    end,
}

-- setup the rooter, will not setup autocommand if manual = true
rooter.setup()
```

You can also root manually. You can do `:Root` which is a wrapper around `:lua require'rooter'.root()`
