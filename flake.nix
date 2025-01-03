{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs"; # avoids duplicating nixpkgs
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, fenix, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        rustToolchain = fenix.packages.${system}.fromToolchainFile {
          file = ./rust-toolchain.toml;
          sha256 = "sha256-s1RPtyvDGJaX/BisLT+ifVfuhDT1nZkZ1NcK8sbwELM=";
        };
        rustPlatform = pkgs.makeRustPlatform {
          # inherit (rustToolchain) cargo rustc;
          cargo = rustToolchain.cargo;
          rustc = rustToolchain.rustc;
        };
      in
      {

        packages.hello = pkgs.hello;
        packages.default = self.packages.hello;

        devShells.default = pkgs.mkShell {
          buildInputs = (with pkgs; [
	    # dependencies go here
	    llvmPackages_19.libllvm
	    llvmPackages_19.mlir
	  ]) ++ [
            rustToolchain
            rustPlatform.bindgenHook
          ];
        };

        formatter = pkgs.nixpkgs-fmt;
      }
    );
}
