# The user of git and jujutsu, an `identity` option shared by their modules:
#
#   inputs.pkgs.wrappers.git.wrap { inherit pkgs; identity.email = "me@work.com"; }
{ lib, ... }:
{
  options.identity = {
    name = lib.mkOption {
      type = lib.types.str;
      default = "Zshoham";
      description = "The user's name.";
    };
    email = lib.mkOption {
      type = lib.types.str;
      default = "ShohamZarfti@gmail.com";
      description = "The user's email.";
    };
  };
}
