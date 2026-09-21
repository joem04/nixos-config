{ config, lib, pkgs, ... }:

{
  imports = [
    ../../modules
    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  networking.hostName = "thinkpad";

  # Set once at install time from the NixOS version used to install this
  # machine. Do not change this when upgrading NixOS later — it controls
  # on-disk data format defaults, not which NixOS version you're running.
  system.stateVersion = "26.05";
}
