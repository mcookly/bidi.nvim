with (import <nixpkgs> {});

mkShell {
  buildInputs = [
    fribidi
    neovim
    stylua
  ];
}