# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, home-manager, ... }:


{

  imports =
    [
      ./hardware-configuration.nix
      ../default.nix
    ];

  networking.hostName = "nixos"; # Define your hostname.


  services.xserver.videoDrivers = ["nvidia"];
  
  hardware.nvidia = {
   modesetting.enable = true;
   nvidiaSettings = true;
   package = config.boot.kernelPackages.nvidiaPackages.stable;
   open = false;
  };

}
