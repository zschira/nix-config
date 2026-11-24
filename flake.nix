{
  description = "Zach's NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
      mkHost = configuration: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs pkgs-unstable; };
        modules = [
          home-manager.nixosModules.home-manager
          configuration
        ];
      };
    in
    {
      # Hostnames match the output names, so `nixos-rebuild switch --flake .`
      # picks the right configuration automatically.
      nixosConfigurations = {
        zach-desktop = mkHost ./desktop-configuration.nix;
        zach-laptop = mkHost ./laptop-configuration.nix;
      };
    };
}
