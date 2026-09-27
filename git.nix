{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name  = "Zach Schira";
        email = "zach.schira@proton.me";
      };
      init.defaultBranch = "main";
      safe.directory = "/etc/nixos";
    };
  };
}
