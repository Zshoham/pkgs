# kitty configured in nix.
#
# kitty reads the config from KITTY_CONFIG_DIRECTORY instead of the upstream
# module's --config, which breaks `kitty +kitten ...` and is not inherited by
# kittens started from kitty.
{
  config,
  wlib,
  lib,
  ...
}:
let
  # the Nerd Fonts symbol ranges, drawn with Symbols Nerd Font Mono
  nerdFontSymbols = [
    "U+E000-U+E00D" # Pomicons
    "U+E0A0-U+E0A2,U+E0B0-U+E0B3" # Powerline
    "U+E0A3-U+E0A3,U+E0B4-U+E0C8,U+E0CC-U+E0D2,U+E0D4-U+E0D4" # Powerline Extra
    "U+E5FA-U+E6B2" # Symbols original
    "U+E700-U+E7C5" # Devicons
    "U+F000-U+F2E0" # Font awesome
    "U+E200-U+E2A9" # Font awesome extension
    "U+F400-U+F533,U+2665-U+2665,U+26A1-U+26A1,U+f27C-U+F27C" # Octicons
    "U+F300-U+F372" # Font Logos
    "U+23FB-U+23FE,U+2B58-U+2B58" # Font Power Symbols
    "U+F0001-U+F1AF0" # Material Design Icons
    "U+E300-U+E3EB" # Weather Icons
    "U+EA60-U+EBEB" # Additional Symbols
  ];
in
{
  imports = [ wlib.wrapperModules.kitty ];

  font = {
    name = "Jetbrains Mono";
    size = 13;
  };
  themeFile = "Catppuccin-Mocha";

  # https://sw.kovidgoyal.net/kitty/conf.html
  settings = {
    disable_ligatures = "never";
    background_opacity = "0.95";
    tab_bar_style = "fade";
    tab_fade = 1;
    active_tab_font_style = "bold";
    inactive_tab_font_style = "bold";
    shell = "fish";
    hide_window_decorations = true;
  };

  keybindings = lib.genAttrs [
    "ctrl+shift+up"
    "ctrl+shift+down"
    "ctrl+shift+left"
    "ctrl+shift+right"
  ] (_: "no_op");

  extraConfig = lib.concatMapStrings (
    range: "symbol_map ${range} Symbols Nerd Font Mono\n"
  ) nerdFontSymbols;

  constructFiles.kittyConfig.relPath = lib.mkForce "kitty-config/kitty.conf";
  flags."--config" = lib.mkForce false;
  env.KITTY_CONFIG_DIRECTORY = dirOf config.constructFiles.kittyConfig.path;
}
