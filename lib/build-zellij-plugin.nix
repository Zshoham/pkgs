# Builds a zellij plugin the way pkgs.zellijPlugins does: a Rust package for
# wasm32-wasip1, as a single .wasm file. Takes buildRustPackage's arguments.
{ pkgsCross, zellijPlugins }:
let
  wasmPkgs = pkgsCross.wasm32-wasip1;
in
attrs:
zellijPlugins.wrapper attrs.pname (
  (wasmPkgs.rustPlatform.buildRustPackage attrs).overrideAttrs (old: {
    # the same workaround as pkgs.zellijPlugins
    nativeBuildInputs = old.nativeBuildInputs or [ ] ++ [ wasmPkgs.lld ];
    env = old.env or { } // {
      RUSTFLAGS = old.env.RUSTFLAGS or "" + " -C linker=wasm-ld";
    };
  })
)
