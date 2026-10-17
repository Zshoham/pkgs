# git configured in nix, with the user from the `identity` option and delta
# (the pager) on its PATH.
{
  config,
  wlib,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    wlib.wrapperModules.git
    ../../identity.nix
  ];
  runtimePkgs = [ pkgs.delta ];
  settings = {
    user = lib.mapAttrs (_: lib.mkDefault) config.identity;

    core = {
      editor = "nvim";
      # Delta does not honor the wrapper's GIT_CONFIG_GLOBAL automatically.
      pager = ''delta --config "$GIT_CONFIG_GLOBAL"'';
    };

    # the theme isn't built into delta
    include.path = "${./delta-catppuccin-mocha.gitconfig}";
    delta.features = "catppuccin-mocha";

    alias.sdiff = "-c delta.side-by-side=true diff";

    column.ui = "auto";
    branch.sort = "-committerdate";
    tag.sort = "version:refname";

    diff = {
      algorithm = "histogram";
      colorMoved = "plain";
      renames = true;
    };

    push = {
      default = "simple";
      autoSetupRemote = true;
    };

    fetch = {
      prune = true;
      pruneTags = true;
      all = true;
    };

    help.autocorrect = "prompt";
    commit.verbose = true;

    rerere = {
      enabled = true;
      autoupdate = true;
    };

    rebase = {
      autoSquash = true;
      autoStash = true;
      updateRefs = true;
    };
  };
}
