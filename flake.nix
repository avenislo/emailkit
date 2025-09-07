{
  description = "emailkit";

  inputs.devshell.url = "github:numtide/devshell";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url =
    "github:NixOS/nixpkgs/nixos-unstable";

  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  outputs = { self, flake-utils, devshell, nixpkgs, ... }:
    flake-utils.lib.eachDefaultSystem (system: {
      devShells.default = let
        pkgs = import nixpkgs {
          inherit system;

          overlays = [ devshell.overlays.default ];

          config.permittedInsecurePackages = [ ];
        };
      in pkgs.devshell.mkShell {
        name = "emailkit.dev";
        packages = [
          pkgs.pkg-config
          pkgs.pnpm
          pkgs.nodejs_22
          pkgs.openssl_3_5.dev
        ];
        env = [
          {
            name = "PKG_CONFIG_PATH";
            value =
              "${pkgs.pkg-config}:${pkgs.openssl_3_5.dev}/lib/pkgconfig";
          }
          {
            name = "NIXPKGS_ALLOW_INSECURE";
            value = "1";
          }
          {
            name = "PNPM_PATH";
            value = "${pkgs.pnpm}/bin/pnpm";
          }
        ];
        commands = [
          {
            name = "run";
            category = "devshell";
            help = "Run the application";
            command = "pnpm run dev";
          }
        ];
      };
    });
}
