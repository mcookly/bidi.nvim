with (import <nixpkgs> {});

mkShell {
  buildInputs = [
    alacritty
    fribidi
    neovim
    stylua
  ];
}