{ config, pkgs, ... }:

with pkgs;
let
  myPythonPackages = python-packages: with python-packages; [
    virtualenv
    pip
    pipx
  ];

  myPython = python310.withPackages myPythonPackages;



in {

  home-manager.users.lennon = { pkgs, ... }: {
    nixpkgs.config.allowUnfree = true;

    home.username = "lennon";
    home.homeDirectory = "/home/lennon";

    home.packages = [
      pkgs.tmux
      pkgs.firefox-devedition-bin
      pkgs.tmux
      pkgs.yakuake
      pkgs.git
      pkgs.jetbrains.pycharm-professional
      pkgs.jetbrains.idea-ultimate
      pkgs.direnv
      pkgs.postman
      pkgs.unzip
      pkgs.neofetch
      pkgs.any-nix-shell
      pkgs.libreoffice
      myPython
    ];

    home.shellAliases = {
      ls = "ls -lah --color=auto";
      pycharm_uptime = "cd ~/Projects/uptime/ && pycharm-professional > /dev/null 2>&1 &";
      pycharm_adventure = "cd ~/Projects/adventure/ && pycharm-professional > /dev/null 2>&1 &";
      idea_mtg = "cd ~/Projects/mtg-card-tracker/ && idea-ultimate > /dev/null 2>&1 &";
      idea_uptime_deploy = "cd ~/Projects/uptime-deploy/ && idea-ultimate > /dev/null 2>&1 &";
      idea_uptime_mobile = "cd ~/Projects/uptime-mobile-app/ && idea-ultimate > /dev/null 2>&1 &";
    };

    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        any-nix-shell fish --info-right | source
      '';
    };   

    home.sessionVariables = {
      EDITOR = "vim";
    };

    home.sessionPath = [];

    programs.alacritty = {
      enable = true;
    };


    programs.vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [ vim-nix ];
      extraConfig = ''
        set hidden
        set tabstop=2
        set softtabstop=2
        set expandtab
        set shiftwidth=2
        set backspace=indent,eol,start
        set shiftround
        set ruler
        set hlsearch
        set cursorline
        set number
        set noerrorbells
      '';
    };
  };

}

