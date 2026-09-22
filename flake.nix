{
  description = "My NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, disko, home-manager, ... }:
    let
      # Every directory under hosts/ is automatically a machine you can
      # install/rebuild — no need to hand-edit this file to add one.
      hostNames = builtins.attrNames
        (nixpkgs.lib.filterAttrs (_: type: type == "directory")
          (builtins.readDir ./hosts));

      mkHost = name: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          (./hosts + "/${name}/configuration.nix")
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # Every host gets home/default.nix. If a host also has its own
            # file under home/hosts/<name>.nix, that gets layered on top —
            # a host with no override file just gets the defaults.
            home-manager.users.joe.imports = [ ./home/default.nix ]
              ++ nixpkgs.lib.optional
                   (builtins.pathExists (./home/hosts + "/${name}.nix"))
                   (./home/hosts + "/${name}.nix");
          }
        ];
      };
    in
    {
      nixosConfigurations = nixpkgs.lib.genAttrs hostNames mkHost;
    };
}
