# Zellij options and file generation; concrete preferences live in default.nix.
{
  config,
  wlib,
  lib,
  pkgs,
  ...
}:
let
  # Zellij reads KDL 1.
  toKdl =
    content:
    wlib.toKdl (_: {
      version = 1;
      inherit content;
    });
in
{
  imports = [ wlib.modules.default ];

  options = {
    settings = lib.mkOption {
      type = wlib.types.attrsRecursive;
      default = { };
      description = ''
        config.kdl as `wlib.toKdl` data. Attrsets are written alphabetically;
        use lists of attrsets for repeated nodes or when order matters.
        Nodes with arguments and children use a function returning `props`
        and `content`. See <https://zellij.dev/documentation/configuration>.
      '';
    };
    layouts = lib.mkOption {
      type = with lib.types; attrsOf (either path wlib.types.attrsRecursive);
      default = { };
      description = ''
        Layouts by name, KDL files or `wlib.toKdl` data.
        File-backed layouts are replaced as a whole, not merged internally.
        See <https://zellij.dev/documentation/layouts>.
      '';
    };
  };

  config = {
    package = lib.mkDefault pkgs.zellij;

    constructFiles = {
      config = {
        relPath = "${config.binName}-config.kdl";
        content = toKdl config.settings;
      };
    }
    // lib.mapAttrs' (
      name: layout:
      lib.nameValuePair "layout-${name}" (
        {
          relPath = "${config.binName}-layouts/${name}.kdl";
        }
        // (
          if lib.isStringLike layout then
            { builder = ''cp ${layout} "$2"''; }
          else
            { content = toKdl layout; }
        )
      )
    ) config.layouts;

    env.ZELLIJ_CONFIG_FILE = config.constructFiles.config.path;

    settings.layout_dir = lib.mkIf (
      config.layouts != { }
    ) "${placeholder config.outputName}/${config.binName}-layouts";
  };
}
