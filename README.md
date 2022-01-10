# NuGet completion for nvim-cmp

Completion source for [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) helping to
autocomplete NuGet packages and versions on .csproj files.

**This plugin is in alpha stage, i.e. is under development.**
Feel free to contribute.

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
lvim.plugins = {
  ...
  {
    "PasiBergman/cmp-nuget",
    event = "BufWinEnter",
    config = function()
      local cmp_nuget = require("cmp-nuget")
      cmp_nuget.setup({})
      table.insert(lvim.builtin.cmp.sources, {
        name = "nuget",
        keyword_length = 3,
      })
      lvim.builtin.cmp.formatting.source_names["nuget"] = "(NuGet)"
    end,
  },
  ...
}
```

Remember to `:PackerSync` after changes to plugins.

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

Run the `setup` function and add the source

```lua
require('cmp-nuget').setup({})
require('cmp').setup({
  ...,
  sources = {
    { name = 'nuget', keyword_length = 3 },
    ...
  },
  formatting = {
    source_names = {
      nuget = "(NuGet)",
    },
  },
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
      sem_ver_level = "2.0.0",     -- semantic version level (*
      package_type = "",           -- package type to use to filter packages (*
    },
    versions = {
      prerelease = true,           -- include prerelase (preview, rc, etc.) versions
      sem_ver_level = "2.0.0",     -- semantic version level (*
    },
  },
}
```

(\* more information:

- [SemVer2 support for fuget.org](https://github.com/NuGet/Home/wiki/SemVer2-support-for-nuget.org-%28server-side%29)
- [Package Type](https://github.com/NuGet/Home/wiki/Package-Type-%5BPacking%5D)

## Known bugs and limitations

Requires the `PackageReference` with `Include=` and `Version=` to be on single line.
Does not parse the `xml` content.
