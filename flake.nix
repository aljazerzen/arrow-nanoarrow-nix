{
  description = "Apache Arrow nanoarrow";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.defaults = pkgs.mkShell {
          buildInputs = [pkgs.cmake];
        };

        packages.default = pkgs.stdenv.mkDerivation rec {
          name = "nanoarrow-${version}";
          version = "0.3.0";

          src = pkgs.fetchFromGitHub {
            owner = "apache";
            repo = "arrow-nanoarrow";
            rev = "apache-arrow-nanoarrow-${version}";
            sha256 = "sha256-MA8e/68SA25IiCsdpdbN/sjcLkVnS66vzOju6GzFK30=";
          };
          patches = [ ./0001-patch.patch ];

          nativeBuildInputs = [ pkgs.cmake ];

          configurePhase = ''
            mkdir build/
            cd build
            CMAKE_BUILD_TYPE=Release cmake ..
            cd ..
          '';

          buildPhase = ''
            make -C build
          '';

          installPhase = ''
            cmake --install build --prefix $out
            mv $out/include/nanoarrow/* $out/include
            rm -r $out/include/nanoarrow/
          '';
        };
      });
}
