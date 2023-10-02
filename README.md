# bidi.nvim

Bidirectional (bidi) text support in neovim.

## Introduction

`bidi.nvim` aims to be a simple, easy-to-configure, and lightweight
plugin which adds a bidirectional display mode to neovim
on a per-buffer basis.

**NOTE:
I no longer use neovim,
so I won't be adding any extra features to this plugin
unless someone else (you?) puts in the work.
I will try my best to fix bugs and other issues, however.**

## Dependencies

### Required

- [Neovim](https://neovim.io)
- [GNU FriBidi](https://github.com/fribidi/fribidi)
- A terminal/GUI with bidi capabilities *disabled*[^alacritty]

[^alacritty]: [Alacritty](https://github.com/alacritty/alacritty)
  cannot render Hebrew diacritical marks properly
  for fonts with those characters (issue [#3830](https://github.com/alacritty/alacritty/issues/3830)),
  so I recommend choosing another terminal if you want
  to see niqqud and te'amim.

### Optional

- A good font for multi-lingual typing.
  I recommend [Cousine](https://fonts.google.com/specimen/Cousine)
  or [GNU FreeMono](https://www.gnu.org/software/freefont/).

## Configuration

```lua
-- Default plugin options
local default_opts = {
  create_user_commands = true, -- Generate user commands to enable and disable bidi-mode
  default_base_direction = 'LR', -- Options: 'LR' and 'RL'
  intuitive_delete = true, -- Swap <DEL> and <BS> when using a keymap contra base direction
}
```

## Installation

Use any standard neovim-compatible plugin manager.
Then add somewhere in your `init.lua`:

```lua
-- Either
require("bidi").setup()

-- Or (if you want to customize options)
require("bidi").setup({
  create_user_commands = false,
})
```

## Usage

**I would recommend backing up important documents beforehand.**

### Toggle `Bidi-Mode`

Use `:BidiEnable <base direction>` to enable `Bidi-Mode`.
The base direction is case insensitive.

```vim
" Example: Enable RTL Bidi-Mode
:BidiEnable RL

" Or
:BidiEnable rl
```

If no base direction is supplied (`:BidiEnable`),
Bidi-Mode will activate using the default base direction.

Use `:BidiDisable` to disable `Bidi-Mode`.

### Paste bidi'd contents using `:BidiPaste`

Paste in `Bidi-Mode` with `:BidiPaste`.
For example,

```vim
" Paste from register `b`
:BidiPaste b
```

You can also assign `:BidiPaste` to a keymap by using its lua function:

```lua
-- You can specify a buffer to use OR pass in `nil`,
-- which will ask for a register.
vim.keymap.set('n', '<leader>bp', function() require('bidi').paste(nil), {})
```

Sometimes content will be out of sync with the rest of the bidi'd buffer.
To correct this,
delete the contents to a register and paste using `:BidiPaste`.

### Statusline Indicator

I highly recommend adding this to your statusline
so that you know when `Bidi-Mode` is enabled and in what base direction.
It will display `LR` (LTR) or `RL` (RTL)
depending on the base direction you choose.
Add the following to your statusline:

```vim
%!luaeval('require("bidi").buf_get_bidi_mode(vim.api.nvim_win_get_buf(0))')
```

```lua
-- For example (if ALL you want is the Bidi-Mode status)
vim.o.statusline = [[%!luaeval('require("bidi").buf_get_bidi_mode(vim.api.nvim_win_get_buf(0))')]]
```

## Roadmap

Below is a simple roadmap,
more or less in the order I plan to add functionality.

- :white_check_mark: GNU FriBidi piping ([0c5861a](https://github.com/mcookly/bidi.nvim/commit/0c5861ace3e6e807c5ce8300f63572d50318c154))
- :white_check_mark: `Bidi-Mode` toggleability ([331de66](https://github.com/mcookly/bidi.nvim/commit/331de66c19937c85c7f704b5f7e836a4d356d0ca))
- :white_check_mark: `Bidi-Mode` statusline option ([dcba4df](https://github.com/mcookly/bidi.nvim/commit/dcba4dfb430d04da0140cef4ccd391eab1e8c057))
- :white_check_mark: Manually choose base direction ([5b16429](https://github.com/mcookly/bidi.nvim/commit/5b16429101d09a8f5e3bfb4da8e6ca67672a4ec3))
- :white_check_mark: Save files only in logical mode ([85b77d2](https://github.com/mcookly/bidi.nvim/commit/85b77d2293e6d30f3f3462489d47c3dfa7c868a3))
- :white_check_mark: Switch to `revins` automatically ([83ca8a8](https://github.com/mcookly/bidi.nvim/commit/83ca8a8de1995fa70413b5e771f9decc5e4054b7))
- :white_check_mark: Paste in properly in `Bidi-Mode` ([8fc5741](https://github.com/mcookly/bidi.nvim/commit/8fc5741f3015f2e7d9510426e52273044223afe0))
- :x: ~Dynamic padding for RTL paragraphs~ (see issue [#8](https://github.com/mcookly/bidi.nvim/issues/8))
- :white_check_mark: Ability to use exclusively in `rightleft` mode ([5b16429](https://github.com/mcookly/bidi.nvim/commit/5b16429101d09a8f5e3bfb4da8e6ca67672a4ec3))
- :x: ~Extensive testing framework~

### Testing

There is an [`init.lua`](/test/init.test.lua) in [`/test`](/test).
It can also be used as a MWE.
