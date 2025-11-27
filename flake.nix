{
  description = "Vanadium build environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      depotToolsPath = "$PWD/.depot_tools";
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          git
          gitRepo
          curl
          gnupg

          ninja
          gn
          gnumake
          pkg-config

          (python3.withPackages (
            ps: with ps; [
              httplib2
              six
            ]
          ))

          jdk17
          androidenv.androidPkgs.platform-tools

          perl
          bison
          flex
          gperf
          zip
          unzip
          m4
          openssl
          zlib
          ncurses5
          nspr
          nss
          expat
        ];

        ALLOW_NINJA_ENV = "true";

        shellHook = ''
          export LD_LIBRARY_PATH="${
            pkgs.lib.makeLibraryPath [
              pkgs.nspr
              pkgs.nss
              pkgs.expat
            ]
          }:$LD_LIBRARY_PATH"

          # Ensure depot_tools is available
          if [ ! -d "${depotToolsPath}" ]; then
            echo "Cloning depot_tools..."
            git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git "${depotToolsPath}"
          fi

          # Add depot_tools to PATH (prepend so its gn/ninja take priority if needed)
          export PATH="${depotToolsPath}:$PATH"

          # Disable depot_tools auto-update prompts
          export DEPOT_TOOLS_UPDATE=0

          echo "depot_tools available: fetch, gclient, gn, autoninja"
        '';
      };
    };
}
