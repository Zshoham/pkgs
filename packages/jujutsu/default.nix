# jujutsu configured in nix, with the user from the `identity` option.
{
  config,
  wlib,
  lib,
  ...
}:
{
  imports = [
    wlib.wrapperModules.jujutsu
    ../../identity.nix
  ];
  # https://docs.jj-vcs.dev/latest/config/
  settings = {
    user = lib.mapAttrs (_: lib.mkDefault) config.identity;
    templates.draft_commit_description = ''
      concat(
        description,
        surround(
          "\nJJ: This commit contains the following changes:\n", "",
          indent("JJ:     ", diff.summary()),
        ),
        surround(
          "\nJJ: This commit contains the following changes:\n", "",
          indent("JJ:     ", diff.stat(72)),
        ),
        "\n",
        "JJ: ignore-rest\n",
        diff.git(),
      )
    '';
  };
}
