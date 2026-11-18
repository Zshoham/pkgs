# bat configured in nix, on top of the upstream wrapper module.
{ wlib, ... }:
{
  imports = [ wlib.wrapperModules.bat ];

  # the theme built into bat (and delta)
  settings.theme = "Catppuccin Mocha";
}
