# Zellij preferences, built on the reusable options and file-generation module.
{ pkgs, ... }:
let
  room = pkgs.callPackage ../zellij-room/package.nix { };
  zellij-forgot = pkgs.callPackage ../zellij-forgot/package.nix { };
  zjstatus = pkgs.zellijPlugins.zjstatus;

  pluginBinding = key: plugin: options: {
    bind = _: {
      props = key;
      content.LaunchOrFocusPlugin = _: {
        props = "file:${plugin}";
        content = options;
      };
    };
  };
in
{
  imports = [ ./module.nix ];

  settings = {
    default_layout = "base";
    pane_frames = false;
    theme = "catppuccin-mocha";

    keybinds.shared = [
      (pluginBinding "Alt Enter" room {
        floating = true;
        ignore_case = true;
        quick_jump = true;
      })
      (pluginBinding "Alt y" zellij-forgot {
        LOAD_ZELLIJ_BINDINGS = "true";
        floating = true;
      })
    ];
  };

  layouts.base = pkgs.replaceVars ./base.kdl { inherit zjstatus; };
}
