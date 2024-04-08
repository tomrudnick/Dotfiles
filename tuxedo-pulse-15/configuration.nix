# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:


{

  imports =
    [
      ./hardware-configuration.nix
      ../default.nix
      ../modules/cleanup.nix
    ];

  networking.hostName = "nixos-tux-tom"; # Define your hostname.


  services.blueman.enable = true;
  
  environment.systemPackages = with pkgs; [
    brightnessctl
  ];

  services.xserver.videoDrivers = ["amdgpu"];

  hardware.bluetooth.settings = {
    General = {
      Disable = "Headset";
    };
  };

  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;
  
  hardware.usb.wakeupDisabled = [
   {
     # Logitech wireless mouse receiver
     vendor = "046d";
     product = "c539";
   }
  ];

}
