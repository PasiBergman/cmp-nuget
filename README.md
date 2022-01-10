# NuGet completion for nvim-cmp

Completion source for [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) helping to
autocomplete NuGet packages and versions on .csproj files.

This plugin is under development and still has a lot of bugs.

![cmp-nuget in action](./assets/cmp-nuget.gif?raw=true)

## Requirements

- [Neovim](https://gitub.com/neovim/neovim)
- [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) plugin
- [plenary](https://github.com/nvim-lua/plenary.nvim) plugin
- [curl](https://curl.se)

## Installation

### LunarVim

In your [LunarVim](https://lunarvim.org) cofiguration file:

```lua
:w

```

### Neovim

For [packer](https://github.com/wbthomason/packer.nvim):

```lua
use {
  'PasiBergman/cmp-nuget',
  requires = {
    'nvim-lua/plenary.nvim'
  },
}
```

For [vim-plug](https://github.com/junegunn/vim-plug):

```lua
Plug 'nvim-lua/plenary.nvim'
Plug 'PasiBergman/cmp-nuget'
```

For [packer](https://github.com/wbthomason/packer.nvim):

Run the `setup` function and add the source

```lua
require('cmp-nuget').setup({})
cmp.setup({
  ...,
  sources = {
    { name = 'nuget', keyword_length = 3 },
    ...
  }
})
```

The `setup` function accepts an config override table. Default config is

```lua
{
  filetypes = {},                  -- on which filetypes cmp-nuget is active
  file_extensions = { "csproj" },  -- on which file extensions cmp-nuget is active
  nuget = {
    packages = {                   -- configuration for searching packages
      limit = 100,                 -- limit package serach to first 100 packages
      prerelease = false,          -- include prerelase (preview, rc, etc.) packages
      sem_ver_level = "2.0.0",     -- semantic version level
      package_type = "",           -- package type
    },
    versions = {
      prerelease = true,           -- include prerelase (preview, rc, etc.) versions
      sem_ver_level = "2.0.0",     -- semantic version level
    },
  },
}
```

## Known bugs and limitations

Requires the `PackageReference` with `Include=` and `Version=` to be on single line. Does not parse the `xml` content.
