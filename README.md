# pkgs

My nix packages: programs not in nixpkgs, and programs wrapped with their
configuration using
[nix-wrapper-modules](https://github.com/nix-community/nix-wrapper-modules) so
they read nothing from `~/.config`.

Each directory in `packages/` is a package, named after the directory, with the
files it uses next to it:

- `package.nix`: a regular package, built with `callPackage`
- otherwise `default.nix`: a wrapper module

Helpers shared by several packages are in `lib/`.

```sh
nix build .#<name>
nix flake check   # every package builds and the wrapped programs see their config
```

## Using the flake

```nix
# every package, with options shared by the wrapper packages set once
inputs.pkgs.lib.mkPackages {
  inherit pkgs;
  identity = {
    name = "Some One";
    email = "some.one@example.com";
  };
}

# one wrapper package, extended
inputs.pkgs.wrappers.git.wrap {
  inherit pkgs;
  settings.core.editor = "hx";
}
```

`mkPackages` gives each argument other than `pkgs` to the wrapper packages that
have that option, and fails on one no package has.

Outputs: `packages.<system>.<name>`, `lib.mkPackages`, and for wrapper packages
`wrappers.<name>` (evaluated modules) and `wrapperModules.<name>` (importable
modules, also into NixOS/home-manager with `wrappers.lib.getInstallModule`).
