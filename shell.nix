{ pkgs ? import <nixpkgs> { } }:

let riscv32 = pkgs.pkgsCross.riscv32-embedded;
in
pkgs.mkShell {
  packages = with pkgs; [
    apio
    riscv32.buildPackages.binutils
    riscv32.buildPackages.gcc
    usbutils
  ];
}
