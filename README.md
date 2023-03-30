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
Below is a simple roadmap,
more or less in the order I plan to add functionality.

- [x] GNU FriBidi piping (0c5861ace3e6e807c5ce8300f63572d50318c154)
- [x] `Bidi-Mode` toggleability (331de66c19937c85c7f704b5f7e836a4d356d0ca)
- [x] `Bidi-Mode` statusline option (dcba4dfb430d04da0140cef4ccd391eab1e8c057)
- [ ] Save files only in logical mode
- [ ] Manually choose base direction
- [ ] Switch to `revins` automatically
- [ ] Paste in properly in `Bidi-Mode`
- [ ] Dynamic padding for RTL paragraphs
- [ ] Ability to use exclusively in `rightleft` mode
- [ ] Extensive testing framework

### Testing

There is an [`init.lua`](/test/init.test.lua) in `/test`.
It can also be used as a MWE for interior bugs.
