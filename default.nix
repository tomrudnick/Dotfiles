# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  dmenuExtended = (import ./pkgs/dmenu_extended.nix { inherit (pkgs) lib python3Packages; });
in
{

  boot.supportedFilesystems = [ "ntfs" ];
 
  # Bootloader.
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.useOSProber = true; #finds other system like linux or windows while booting
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.shells = with pkgs; [ zsh bash ];
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };


  #services.displayManager.defaultSession = "none+i3"; #default is lightdm
  # Configure keymap in X11
  services.xserver = {
    enable = true;
    xkb = {
      layout = "de";
      variant = "";
    };
    dpi = 120;
    desktopManager = {
      xterm.enable = false;
    };

    displayManager.defaultSession = "none+i3"; #default is lightdm

    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
      extraPackages = with pkgs; [
        dmenu
        i3lock
      ];
    };

    libinput = {
      enable = true;
      mouse = {
        middleEmulation = false; #disable left + right click = middle click (gaming)
      };
    };
  };

  programs.steam = {
    enable = true;
  };

  programs.java = {
    enable = true;
  };  

  services = {
    dbus.enable = true;
    gnome.gnome-keyring.enable = true;
    gvfs.enable = true;
    onedrive.enable = true;
  };

  xdg.portal.enable = true;
  xdg.portal.config = {
    common = { 
      default = [
        "gtk"
      ];
    };
  };
  
  programs.dconf.enable = true; #store settings from gtk3 applications like size of file selection dialogs
  
  security.polkit.enable = true;  

  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
    user.services.dmenuExtendedUpdateDb = {
      description = "Update dmenu-extended cache";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${dmenuExtended}/bin/dmenu_extended_cache_build"; 
        Environment = "PATH=/run/current-system/sw/bin";
      };
      wantedBy = [ "multi-user.target" ];
    };
    user.timers.dmenuExtendedUpdateDb = {
      description = "Run dmenu-extended update db service every 5 minutes"; # Adjust the interval as necessary
      timerConfig.OnCalendar = "*:0/5";
      wantedBy = [ "timers.target" ];
      partOf = [ "dmenuExtendedUpdateDb.service" ];
    };
  };

  # Configure console keymap
  console.keyMap = "de";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.gutenprint pkgs.gutenprintBin pkgs.epson-escpr ];

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Enable sound with pipewire.
  #sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };


  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tom = {
    isNormalUser = true;
    description = "Tom Rudnick";
    extraGroups = [ "networkmanager" "wheel" "dialout" "audio" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  nixpkgs.config.permittedInsecurePackages = [
    "mailspring-1.12.0"
  ];

  # a few customizations for nixpkgs
  nixpkgs.overlays = [
    (self: super: {
      polybar = super.polybar.override {
        i3Support = true;
        pulseSupport = true;
      };
    })
    (self: super: {
      mailspring = super.mailspring.overrideAttrs (oldAttrs: {
        postInstall = ''
          wrapProgram $out/bin/mailspring --add-flags "--password-store=gnome-libsecret" #otherwise passwords can't be stored
        '';
      });
    })
    (self: super: {
      rstudioWrapper = super.rstudioWrapper.override {
        packages = with self.rPackages; [ tidyverse learnr remotes ];
      };
    })
  ];

  nixpkgs.config.chromium.enableWideVine = true; 
  
  environment.systemPackages = with pkgs; [
    gnumake
    gcc
    glibc
    clang
    cmake
    zip
    unzip
    usbutils
    killall
    tree
    go
    wget
    firefox
    kitty
    sxiv #replacement for feh
    networkmanagerapplet
    picom
    nitrogen
    google-chrome
    _1password-gui
    polkit_gnome
    pcmanfm
    pulseaudio # to get command line tools (pactl)
    pavucontrol
    playerctl
    gparted # best disk formatter
    spotify
    discord
    arandr
    evince
    shared-mime-info
    lxmenu-data
    (python3.withPackages(ps: with ps; [ pandas requests dbus-python numpy pip ]))
    jetbrains.idea-ultimate
    jetbrains.rust-rover
    texliveFull
    libreoffice
    hunspell
    hunspellDicts.de_DE
    vscode
    baobab
    libnotify
    dunst
    polybar
    lxappearance
    btop
    eza
    bat
    fzf
    neofetch
    ranger
    (import ./pkgs/dmenu_extended.nix { inherit (pkgs) lib python3Packages; })
    flameshot #best screenshot tool
    teamspeak_client
    neovim
    jetbrains.goland
    arp-scan
    arduino
    kicad
    prusa-slicer
    zoom-us
    sl
    sox
    lolcat
    gpu-screen-recorder-gtk
    gpu-screen-recorder
    vlc
    gimp
    mate.engrampa #compressed file viewer (good integration with pcmanfm)
    chromium
    filezilla
    rpi-imager
    sage
    qjackctl
    ffmpeg
    yt-dlp
    audacity
    mailspring
    localsend
    #geogebra6
    geogebra
    gurk-rs
    qpwgraph
    manim
    pika-backup
    rstudioWrapper
    tor-browser-bundle-bin
    nh
    lua-language-server
    ripgrep
  ];

  
  fonts.packages = with pkgs; [
    nerdfonts
    font-awesome
    siji 
  ];

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    #extraPackages = with pkgs; [
    #  vaapiVdpau #enables video acceleration
    #];
  };

  
  virtualisation.vmware.host = {
    enable = true;
  };

  #this is neccessary cause of localsend
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 53317 ];
      allowedUDPPortRanges = [
        { from = 4000; to = 4007; }
        { from = 53315; to = 53318; }
        { from = 8000; to = 8010; }
      ];
    };
  };
    
  system.stateVersion = "23.11"; # Don't change
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
