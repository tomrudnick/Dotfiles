{ config, pkgs, ... }:

let
  # Custom package imports
  dmenuExtended = import ./pkgs/dmenu_extended.nix { inherit (pkgs) lib python3Packages; };
in
{
  ####################
  # Boot and Filesystems
  ####################
  boot.supportedFilesystems = ["ntfs"];
  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      useOSProber = true; # Detect other OSes
      efiSupport = true;
    };
    systemd-boot.enable = false;
    efi.canTouchEfiVariables = true;
  };

  ####################
  # User / Shell Configuration
  ####################
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh bash ];
  programs.zsh.enable = true;

  # User Accounts
  users.users.tom = {
    isNormalUser = true;
    description = "Tom Rudnick";
    extraGroups = ["networkmanager" "wheel" "dialout" "audio" "docker"];
  };

  ####################
  # Localization
  ####################
  time.timeZone = "Europe/Berlin";
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
  console.keyMap = "de";

  ####################
  # Networking and Firewall
  ####################
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 53317 8080 ];
    allowedUDPPortRanges = [
      { from = 4000; to = 4007; }
      { from = 53315; to = 53318; }
      { from = 8000; to = 8010; }
    ];
  };

  ####################
  # Services
  ####################
  services = {
    # Input
    libinput = {
      enable = true;
      mouse.middleEmulation = false; # Disable left+right=middle
    };

    # Display / X Server / Window Manager
    xserver = {
      enable = true;
      dpi = 120;
      xkb.layout = "de";
      xkb.variant = "";
      desktopManager.xterm.enable = false;
      windowManager.i3 = {
        enable = true;
        package = pkgs.i3-gaps;
        extraPackages = with pkgs; [
          dmenu
          i3lock
        ];
      };
    };

    # Audio: PipeWire
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    # Printing
    printing = {
      enable = true;
      drivers = [
        pkgs.gutenprint
        pkgs.gutenprintBin
        pkgs.epson-escpr
      ];
    };

    # General System Services
    dbus.enable = true;
    gnome.gnome-keyring.enable = true;
    gvfs.enable = true;
    onedrive.enable = true;
    usbmuxd.enable = true;

    # Ollama
    ollama = {
      enable = true;
      acceleration = "cuda";
    };

    # Avahi
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };

  ####################
  # Programs
  ####################
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  programs.steam.enable = true;
  programs.java.enable = true;
  programs.dconf.enable = true; # Store GTK3 application settings

  ####################
  # XDG and Polkit
  ####################
  xdg.portal.enable = true;
  xdg.portal.config.common.default = [ "gtk" ];
  security.polkit.enable = true;
  security.rtkit.enable = true;

  # Polkit gnome authentication agent
  systemd.user.services."polkit-gnome-authentication-agent-1" = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = ["graphical-session.target"];
    wants = ["graphical-session.target"];
    after = ["graphical-session.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # dmenu-extended update service and timer
  systemd.user.services.dmenuExtendedUpdateDb = {
    description = "Update dmenu-extended cache";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${dmenuExtended}/bin/dmenu_extended_cache_build";
      Environment = "PATH=/run/current-system/sw/bin";
    };
    wantedBy = ["multi-user.target"];
  };
  systemd.user.timers.dmenuExtendedUpdateDb = {
    description = "Run dmenu-extended update db service every 5 minutes";
    timerConfig.OnCalendar = "*:0/5";
    wantedBy = ["timers.target"];
    partOf = ["dmenuExtendedUpdateDb.service"];
  };

  ####################
  # Virtualization / Docker
  ####################
  virtualisation.docker.enable = true;

  ####################
  # Allow Unfree Packages and Nixpkgs Config
  ####################
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.chromium.enableWideVine = true;

  # Nix Settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Overlays
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
          wrapProgram $out/bin/mailspring --add-flags "--password-store=gnome-libsecret"
        '';
      });
    })
  ];

  ####################
  # Hardware / Graphics
  ####################
  hardware.pulseaudio.enable = false;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  ####################
  # Fonts
  ####################
  fonts.packages = with pkgs; [
    nerdfonts
    font-awesome
    siji
  ];

  ####################
  # System Packages
  ####################
  environment.systemPackages = with pkgs; [
    # Development Tools - Programming Languages
    gnumake
    gcc
    glibc
    clang
    cmake
    go
    (python3.withPackages (ps: with ps; [ pandas requests dbus-python numpy pip pygobject3 ]))
    nodejs
    uv

    # Development Tools - Utilities
    ripgrep
    fzf
    bat
    eza
    btop
    nh
    patchelf

    # Development Tools - Editors / IDEs
    neovim
    ranger
    marksman
    alejandra
    nixd
    ltex-ls
    lua-language-server
    stylua
    nodePackages.bash-language-server
    texlab
    grpc-tools
    ngrok

    # Browsers
    firefox
    google-chrome
    chromium
    tor-browser-bundle-bin

    # IDEs
    jetbrains.idea-ultimate
    github-copilot-intellij-agent
    jetbrains.rust-rover
    jetbrains.pycharm-professional
    jetbrains.webstorm
    vscode

    # Desktop Tools - Image and Media
    sxiv
    zathura
    picom
    nitrogen
    flameshot
    gimp
    vlc
    ffmpeg
    gpu-screen-recorder
    imagemagickBig
    audacity

    # Desktop Tools - Productivity
    kitty
    _1password-gui
    polkit_gnome
    pcmanfm
    nautilus
    spotify
    discord
    teamspeak_client
    filezilla
    geogebra
    mailspring
    postman
    github-desktop
    gparted
    qjackctl
    prusa-slicer
    rpi-imager

    # Development Tools - Hardware
    arduino
    kicad

    # Office Tools
    libreoffice
    hunspell
    hunspellDicts.de_DE
    texliveFull
    typst
    typst-lsp

    # Desktop Utilities
    mate.engrampa
    waybar
    zip
    unzip
    usbutils
    killall
    tree
    wget
    networkmanagerapplet
    playerctl
    pavucontrol
    shared-mime-info
    lxmenu-data
    arandr
    evince
    baobab
    libnotify
    dunst
    polybar
    lxappearance

    # Fun and Miscellaneous
    sl
    sox
    neofetch
    lolcat

    # Networking
    arp-scan
    localsend

    # Communication Tools
    zoom-us

    # Launcher and Workflow Tools
    dmenuExtended # Imported custom package

    # Mathematical Tools
    sage
  ];


  system.stateVersion = "23.11"; # Do not change
}
