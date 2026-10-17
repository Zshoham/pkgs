{
  description = "Custom packages: programs wrapped with their configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    wrappers = {
      url = "github:nix-community/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      wrappers,
    }:
    let
      inherit (nixpkgs) lib;
      forAllSystems = lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ];

      # Every directory in packages/ is a package, named after the directory:
      # built with callPackage from its package.nix, or else a wrapper module
      # (its default.nix). Both keep the files they use next to them.
      packageDirs = lib.attrNames (
        lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./packages)
      );
      isPlain = name: builtins.pathExists ./packages/${name}/package.nix;
      plainPackages = lib.filter isPlain packageDirs;
    in
    {
      wrapperModules = lib.genAttrs (lib.filter (name: !isPlain name) packageDirs) (
        name: ./packages/${name}
      );

      # Evaluated modules, extendable with `.wrap { inherit pkgs; ... }`.
      wrappers = lib.mapAttrs (_: module: (wrappers.lib.evalModule module).config) self.wrapperModules;

      # Every package, with options shared between packages set once:
      #
      #   inputs.pkgs.lib.mkPackages { inherit pkgs; identity.email = "me@work.com"; }
      #
      # Each option is given to the wrapper packages that have it, and an option
      # no package has is an error (rather than silently ignored).
      lib.mkPackages =
        { pkgs, ... }@args:
        let
          shared = removeAttrs args [ "pkgs" ];
          sharedFor = wrapper: lib.intersectAttrs wrapper shared;
          known = lib.concatMap (wrapper: lib.attrNames (sharedFor wrapper)) (lib.attrValues self.wrappers);
          unknown = lib.subtractLists known (lib.attrNames shared);
        in
        assert lib.assertMsg (
          unknown == [ ]
        ) "mkPackages: no package has the option(s) ${lib.concatStringsSep ", " unknown}";
        lib.mapAttrs (_: wrapper: wrapper.wrap ({ inherit pkgs; } // sharedFor wrapper)) self.wrappers
        // lib.genAttrs plainPackages (name: pkgs.callPackage ./packages/${name}/package.nix { });

      packages = forAllSystems (system: self.lib.mkPackages { pkgs = nixpkgs.legacyPackages.${system}; });

      checks = forAllSystems (
        system:
        import ./checks.nix {
          pkgs = nixpkgs.legacyPackages.${system};
          packages = self.packages.${system};
          inherit (self.lib) mkPackages;
        }
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}
