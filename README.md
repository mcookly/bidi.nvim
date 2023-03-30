# bidi.nvim

Bidirectional (bidi) text support in neovim.

## Introduction

`bidi.nvim` aims to be a simple, easy-to-configure, and lightweight
plugin which adds a bidirectional display mode to neovim
on a per-buffer basis.
**Currently, this is in early development.
I recommend using [`rosetta.nvim`](https://github.com/mcookly/rosetta.nvim)
in the meantime.**

## Depedencies

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

## Usage

### Toggle `Bidi-Mode`

Use `:BidiEnable<cr>` to enable `Bidi-Mode` 
and `:BidiDisable<cr>` to disable `Bidi-Mode`.
**Note: I have yet to add the ability to choose a base direction.
Currently, these commands default to `MX` base direction.**

### Statusline Indicator

I highly recommend adding this to your statusline
so that you know when `Bidi-Mode` is enabled and in what base direction.
It will display `LR` (LTR), `RL` (RTL), or `MX` (mixed/auto) depending on the base direction.
Add the following to your statusline:

```vim
%!luaeval('require("bidi").buf_get_bidi_mode(vim.api.nvim_win_get_buf(0))')
```

```lua
-- For example (if ALL you want is the Bidi-Mode status)
vim.o.statusline = [[%!luaeval('require("bidi").buf_get_bidi_mode(vim.api.nvim_win_get_buf(0))')]]
```

## Roadmap

I plan to work extensively on `bidi.nvim` this summer,
but feel free to suggest features or mention concerns before then.
Below is a simple roadmap,
more or less in the order I plan to add functionality.

- [x] GNU FriBidi piping ([0c5861a](https://github.com/mcookly/bidi.nvim/commit/0c5861ace3e6e807c5ce8300f63572d50318c154))
- [x] `Bidi-Mode` toggleability ([331de66](https://github.com/mcookly/bidi.nvim/commit/331de66c19937c85c7f704b5f7e836a4d356d0ca))
- [x] `Bidi-Mode` statusline option ([dcba4df](https://github.com/mcookly/bidi.nvim/commit/dcba4dfb430d04da0140cef4ccd391eab1e8c057))
- [ ] Save files only in logical mode
- [ ] Manually choose base direction
- [ ] Switch to `revins` automatically
- [ ] Paste in properly in `Bidi-Mode`
- [ ] Dynamic padding for RTL paragraphs
- [ ] Ability to use exclusively in `rightleft` mode
- [ ] Extensive testing framework

### Testing

There is an [`init.lua`](/test/init.test.lua) in [`/test`](/test).
It can also be used as a MWE.
