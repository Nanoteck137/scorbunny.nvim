# scorbunny.nvim

Neovim plugin to easily execute compile command and see the result

## Getting Started

### Installation
Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use 'nanoteck137/scorbunny.nvim'
```

Using [vim-plug](https://github.com/junegunn/vim-plug)

```viml
Plug 'nanoteck137/scorbunny.nvim'
```

## Usage

### Setup

```lua
-- Default options
require('scorbunny').setup {}

-- Options
require('scorbunny').setup {
    zindex = 49, -- The zindex of the window, we use 49 so that notifications from the 'rcarriga/nvim-notify' plugin show on top of command window

    notify = true, -- Disable notifications from the plugin, doesn't disable error notifications
}
```

### Example Usage

```lua
-- Execute any command and open the window with the command output
require('scorbunny').execute_cmd(cmd)

-- Kill the current executing command
require('scorbunny').kill()

-- Open the window with the command output 
require('scorbunny').open_window()
```

Examples

```lua
require('scorbunny').execute_cmd('cargo build')
```

TODO(patrik): Add better examples

## Authors

Patrik Millvik Rosenström <patrik.millvik@gmail.com>

## License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details
