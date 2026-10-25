# gdb with the gdbinit next to it, run instead of the ones in the home
# directory, and gef: the same gdb with the gef extension loaded.
{
  config,
  wlib,
  lib,
  pkgs,
  ...
}:
{
  imports = [ wlib.modules.default ];

  package = lib.mkDefault pkgs.gdb;
  # -nh: not ~/.gdbinit, ~/.config/gdb/gdbinit or their early versions
  flags."-nh" = true;
  flags."-ix" = ./gdbinit;

  # nixpkgs' gef runs gdb with gef.py and the tools and python packages it
  # uses; it gets the flags above too
  wrapperVariants.gef = {
    package = pkgs.gef.override { gdb = config.package; };
    # gef sets the history file after the gdbinit, to this or ~/.gdb_history
    envDefault.GDBHISTFILE = {
      data = "$HOME/.local/share/gdb_history";
      esc-fn = wlib.escapeShellArgWithEnv;
    };
    # `gef save` writes here (not ~/.gef.rc), in a directory that exists
    envDefault.GEF_RC = {
      data = "\${XDG_CONFIG_HOME:-$HOME/.config}/gef.rc";
      esc-fn = wlib.escapeShellArgWithEnv;
    };
  };
}
