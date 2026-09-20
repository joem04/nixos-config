{ pkgs, ... }:

{
  home.username = "joe";
  home.homeDirectory = "/home/joe";
  # Do not change this after the first successful build; it tracks Home
  # Manager's own compatibility, not your NixOS version.
  home.stateVersion = "26.05";

  programs.git = {
    enable = true;
    settings.user = {
      name = "Joe M";
      email = "30784663+joem04@users.noreply.github.com";
    };
  };

  programs.bash.enable = true;

  # Add personal CLI tools / GUI apps you want available for your user here.
  home.packages = with pkgs; [
    # ripgrep
    # htop
  ];

  # Let Home Manager manage itself.
  programs.home-manager.enable = true;
}
