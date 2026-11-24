# NixOS flake maintenance. Host defaults to the current hostname
# (zach-desktop / zach-laptop); override with `make switch HOST=zach-laptop`.
HOST ?= $(shell hostname)
FLAKE := .\#$(HOST)

.PHONY: help build test switch boot update upgrade check gc

help:
	@echo "Targets (HOST=$(HOST)):"
	@echo "  build    Build the configuration without activating it"
	@echo "  test     Activate without adding a boot entry"
	@echo "  switch   Build, activate, and add a boot entry"
	@echo "  boot     Build and use at next boot only"
	@echo "  update   Update flake.lock (all inputs)"
	@echo "  upgrade  update + switch"
	@echo "  check    Run nix flake check"
	@echo "  gc       Delete generations older than 14 days and collect garbage"

build:
	nixos-rebuild build --flake $(FLAKE)

test:
	sudo nixos-rebuild test --flake $(FLAKE)

switch:
	sudo nixos-rebuild switch --flake $(FLAKE)

boot:
	sudo nixos-rebuild boot --flake $(FLAKE)

update:
	nix flake update

upgrade: update switch

check:
	nix flake check

gc:
	sudo nix-collect-garbage --delete-older-than 14d
