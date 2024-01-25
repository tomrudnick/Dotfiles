{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "tom";
  home.homeDirectory = "/home/tom";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.palenight-theme
    pkgs.papirus-icon-theme
    pkgs.capitaine-cursors
    
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    ".config/polybar/config.ini".source = ./polybar.conf;
    ".config/kitty/kitty.conf".source = ./kitty.conf;
    ".config/kitty/current-theme.conf".source = ./kitty-theme.conf;
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/tom/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
    SSH_ASKPASS = "";  #this prevents from starting the x11-ssh-askpass (who the fuck would want that anyway)
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "ls -l";
      ".." = "cd ..";
      "nrs" = "sudo nixos-rebuild switch --flake /home/tom/.dotfiles/";
      "hrs" = "home-manager switch --flake /home/tom/.dotfiles/";
      "cat" = "bat";
      "ls" = "eza -l --icons";
      "scannet" = "sudo arp-scan --localnet";
      "s" = "kitten ssh";
      "open" = "xdg-open";
    };

    zplug = {
      enable = true;
      plugins = [
        { name = "zsh-users/zsh-autosuggestions"; } # Simple plugin installation
      ];
    };
  };

  xdg = {
    mime.enable = true;
    mimeApps.enable = true;
    mimeApps = {
      defaultApplications = {
        "inode/directory" = "pcmanfm.desktop";
        "application/pdf" = "org.gnome.Evince.desktop";
        "x-scheme-handler/mailspring" = "Mailspring.desktop";
        "text/html" = "google-chrome.desktop";
        "x-scheme-handler/http" = "google-chrome.desktop";
        "x-scheme-handler/https" = "google-chrome.desktop";
        "x-scheme-handler/about" = "google-chrome.desktop";
        "x-scheme-handler/unknown" = "google-chrome.desktop";
      };
    };
  };

  
  programs.git = {
    enable = true;
    userName = "Tom Rudnick";
    extraConfig = {
      credential.helper = "${
          pkgs.git.override { withLibsecret = true; }
        }/bin/git-credential-libsecret";
    };
  };


  programs.starship.enable = true;
  programs.starship.settings = {
    add_newline = false;
    format = "$username$hostname$git_branch$git_state$git_status$directory$jobs$cmd_duration$character";
    username = {
      style_user = "bright-white bold";
      style_root = "bright-red bold";
    };

    fill = {
      symbol = " ";
    };

    hostname = {
      style = "bright-green bold";
      ssh_only = true;
    };
    git_branch = {
      only_attached = true;
      format = "[$symbol$branch]($style) ";
      symbol = " ";
      style = "bright-yellow bold";
    };
    git_state = {
      style = "bright-purple bold";
    };
    git_status = {
      style = "bright-green bold";
    };
    directory = {
      read_only = " ";
      truncation_length = 0;
    };
    cmd_duration = {
      format = "[$duration]($style) ";
      style = "bright-blue";
    };
    jobs = {
      symbol = "";
      style = "bold red";
      number_threshold = 1;
      format = "[$symbol]($style)";
    };
    character = {
      success_symbol = "[❯](purple)";
      error_symbol = "[❯](red)";
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
