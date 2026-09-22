{ pkgs, ... }:

{
  home.username = "joe";
  home.homeDirectory = "/home/joe";
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
