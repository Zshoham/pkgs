# starship configured in nix.
{
  config,
  wlib,
  lib,
  pkgs,
  ...
}:
let
  unwrapped = config.wrapperPaths.input;
in
{
  imports = [ wlib.wrapperModules.starship ];

  settings = {
    format = "$all";
    character = {
      success_symbol = "[➜](bold green)";
      error_symbol = "[✗](bold red)";
    };
    hostname = {
      ssh_only = true;
      format = "[$hostname](bold blue) ";
    };
    conda.ignore_base = true;
  };

  # `starship init` prints the path of the running binary, which is the
  # unwrapped one, so the prompt would run without STARSHIP_CONFIG. Point the
  # shell integration at the wrapper instead.
  runShell = [
    ''
      if [ "''${1-}" = init ]; then
        ${unwrapped} "$@" | ${lib.getExe pkgs.gnused} "s|${unwrapped}|${config.wrapperPaths.placeholder}|g"
        exit
      fi
    ''
  ];
}
