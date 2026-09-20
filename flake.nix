{
  description = "Joe's NixOS machine configs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, disko, home-manager, ... }: {
    nixosConfigurations.thinkpad = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        disko.nixosModules.disko
        ./hosts/thinkpad/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.joe = import ./home/joe.nix;
        }
      ];
    };

    # To add another machine later:
    #   1. cp -r hosts/thinkpad hosts/NEW-NAME
    #   2. Replace hosts/NEW-NAME/hardware-configuration.nix and
    #      disk-config.nix with ones generated for that machine.
    #   3. Add a nixosConfigurations.NEW-NAME block above, copying the
    #      thinkpad one and swapping the host path.
  };
}
