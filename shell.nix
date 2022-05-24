{ pkgs ? import <nixpkgs> {
    overlays = [
      (self: super: {
        bzip2lib = super.bzip2.overrideAttrs (drv: {
          postInstall = ''
            ln -s $out/lib/libbz2.so.1.0.* $out/lib/libbz2.so.1.0
          '';
        });
      })
      (self: super: {
        zliblib = super.zlib.overrideAttrs (drv: {
          postInstall = drv.postInstall + ''
            ln -s $out/lib/libz.so.1.0.* $out/lib/libz.so.1.0
          '';
        });
      })
    ];
  }
}:

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

  NIX_LD_LIBRARY_PATH = lib.optionals stdenv.isLinux lib.makeLibraryPath [
    # nixpkgs doesn't have libz.so.1.0 or libbz2.so.1.0, only nixpkgs-unstable
    # TODO: remove these once those patches make to nixpkgs
    bzip2lib
    zliblib
  ];

  NIX_LD = lib.fileContents "${stdenv.cc}/nix-support/dynamic-linker";

  shellHook = ''
    # this creates issues for cross-compiling into riscv32
    unset NIX_CFLAGS_COMPILE
  '';
}
