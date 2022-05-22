{ pkgs ? import <nixpkgs> { } }:

with pkgs;

let riscv32 = pkgsCross.riscv32-embedded;
in
pkgs.mkShell {
  packages = [
    apio
    minicom
    picocom
    riscv32.buildPackages.binutils
    riscv32.buildPackages.gcc
  ] ++ lib.optionals (!stdenv.isDarwin) [
    usbutils
  ];

  NIX_LD = lib.fileContents "${stdenv.cc}/nix-support/dynamic-linker";

  shellHook = ''
    # this creates issues for cross-compiling into riscv32
    unset NIX_CFLAGS_COMPILE
  '';
}
