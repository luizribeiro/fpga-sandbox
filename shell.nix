{ pkgs ? import <nixpkgs> { } }:

with pkgs;

let riscv32 = pkgsCross.riscv32-embedded;
in
pkgs.mkShell {
  packages = [
    apio
    riscv32.buildPackages.binutils
    riscv32.buildPackages.gcc
    usbutils
  ];

  NIX_LD = lib.fileContents "${stdenv.cc}/nix-support/dynamic-linker";
}
