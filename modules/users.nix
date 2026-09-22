{ ... }:

{
  users.users.joe = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "changeme";

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJMbUYkwEXx5ac3MaXaE4rIievAWDXx5uHGG/xOS+QyG opencode-thinkpad"
    ];
  };
}
