{ config, pkgs, ... }:

let
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-26.05.tar.gz;
in
{
  imports =
    [
      (import "${home-manager}/nixos")
    ];

  users.users.zach.isNormalUser = true;
  users.users.zach = {
    extraGroups = [
      "podman"
    ];
  };
  # home-manager.useGlobalPkgs = true;
  # home-manager.useUserPackages = true;
  home-manager.users.zach = { pkgs, ... }: {
    home.packages = [
    ];
    imports = [
      ./nvim.nix
      ./tmux.nix
      ./git.nix
      ./emulators.nix
    ];
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
	    if not set -q TMUX
          tmux new-session -A -s main
        end
        alias wake-desktop="wakeonlan fc:34:97:a6:43:85"
      '';
    };
    programs.kitty = {
      enable = true;
      shellIntegration.enableFishIntegration = true;
      settings = {
        shell = "fish";
      };
    };
    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentry.package = pkgs.pinentry-curses;
    };
    services.podman.settings.containers = {
      compose_warning_logs = false;
    };
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "26.05";
  };
}
