# bat configured in nix. There is no upstream bat module, so this one has a
# `settings` option of its own, written to the config file bat reads from
# BAT_CONFIG_PATH.
{
  config,
  wlib,
  lib,
  pkgs,
  ...
}:
let
  # `name = "value"` is `--name=value`, `name = true` is `--name`
  toArg =
    name: value:
    if value == true then
      "--${name}"
    else if value == false then
      null
    else
      "--${name}=${lib.escapeShellArg value}";
in
{
  imports = [ wlib.modules.default ];

  options.settings = lib.mkOption {
    type = with lib.types; attrsOf (either bool str);
    default = { };
    description = ''
      bat's command line options, without the leading `--`.
      See {manpage}`bat(1)`.
    '';
  };

  config = {
    package = lib.mkDefault pkgs.bat;
    constructFiles.batConfig = {
      relPath = "${config.binName}-config";
      content = lib.concatLines (lib.remove null (lib.mapAttrsToList toArg config.settings));
    };
    env.BAT_CONFIG_PATH = config.constructFiles.batConfig.path;

    # the theme built into bat (and delta)
    settings.theme = "Catppuccin Mocha";
  };
}
