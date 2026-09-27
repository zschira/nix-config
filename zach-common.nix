{ config, pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.libreoffice-qt
    pkgs.hunspell
    pkgs.hunspellDicts.en_US

    pkgs.zathura
    pkgs.signal-desktop
    pkgs.protonmail-bridge-gui
    pkgs.pass
    pkgs.gnupg
    pkgs.pinentry-curses
    pkgs.wakeonlan
    pkgs.fish
    pkgs.neovim
    pkgs.thunderbird
    pkgs.kitty
    pkgs.fishPlugins.done
    pkgs.fishPlugins.fzf-fish
    pkgs.fishPlugins.forgit
    pkgs.fishPlugins.hydro
    pkgs.fzf
    pkgs.fishPlugins.grc
    pkgs.grc
    pkgs.tmux
    pkgs.git
    pkgs.fd
    pkgs.ripgrep
    pkgs.gnumake
    pkgs.podman-compose
    pkgs.google-cloud-sdk
    pkgs.vlc

    # Python tooling
    pkgs.ruff
    pkgs.pyright
    pkgs.pixi
    pkgs.uv
    pkgs.duckdb
    pkgs.nodejs

    # photo stuff
    pkgs.digikam
    pkgs.darktable

    pkgs.inkscape
    pkgs.gimp

  ];
  # Fix ssl issues in python
  environment.etc.certfile = {
    source = "/etc/ssl/certs/ca-bundle.crt";
    target = "ssl/cert.pem";
  };

  # Use flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # For Broadwell (2014) or newer processors. LIBVA_DRIVER_NAME=iHD
    ];
  };
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; }; # Optionally, set the environment variable
  programs.ssh.startAgent = true;
  programs.nix-ld.enable = true;
  programs.kdeconnect.enable = true;

  virtualisation.podman = {
    enable = true;
    # Create the default bridge network for podman
    defaultNetwork.settings.dns_enabled = true;
    dockerCompat = true;
  };
}
