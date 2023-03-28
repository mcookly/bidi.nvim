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

- [Neovim](https://neovim.io)
- [GNU FriBidi](https://github.com/fribidi/fribidi)
- A terminal/GUI with bidi capabilities *disabled*
- (A good font for multi-lingual typing is [Cousine](https://fonts.google.com/specimen/Cousine))

## Roadmap

I plan to work extensively on `bidi.nvim` this summer,
but feel free to suggest features or mention concerns before then.

- [ ] Ability to use exclusively in `rightleft` mode
- [ ] Dynamic padding for RTL paragraphs
- [x] GNU FriBidi piping
- [x] `Bidi-Mode` toggleability
- [ ] `Bidi-Mode` statusline option
- [ ] Switch to `revins` automatically
- [ ] Manually choose base direction
- [ ] Extensive testing
- [ ] Paste in properly in `Bidi-Mode`
- [ ] Save files only in logical mode

### Testing

There is an [`init.lua`](/test/init.test.lua) in `/test`.
It can also be used as a MWE for interior bugs.
