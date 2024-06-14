{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv/1e4701fb1f51f8e6fe3b0318fc2b80aed0761914";
  };

  outputs = { self, nixpkgs, devenv, systems, ... } @ inputs:
    let
      forEachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      devShells = forEachSystem
        (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
          in
          {
            default = devenv.lib.mkShell {
              inherit inputs pkgs;
              modules = [
                {
                  languages.go = {
                    enable = true;
                  };

                  packages = with pkgs; [ flyctl ];

                  enterShell = ''
                    echo "fly-flake-example shell activated!"
                  '';
                }
              ];
            };
          });
      packages = forEachSystem
        (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
          in
          {
            default = pkgs.buildGoModule {
              name = "fly-flake-example";

              src = ./.;
              vendorHash = "sha256-Ef2XLxGq8TO3WVh9EvLE30Is2CBwH4pqXxkq1tcuR0Q=";

              doCheck = false;
            };
          });
    };
}
