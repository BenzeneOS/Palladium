{
  description = "Vanadium build environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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
          libx11
          libxext
          libxcb
        ];

        ALLOW_NINJA_ENV = "true";

        shellHook = /* sh */ ''
          export LD_LIBRARY_PATH="${
            pkgs.lib.makeLibraryPath [
              pkgs.nspr
              pkgs.nss
              pkgs.expat
              pkgs.libx11
              pkgs.libxext
              pkgs.libxcb
            ]
          }:$LD_LIBRARY_PATH"

          if [ ! -d "${depotToolsPath}" ]; then
            git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git "${depotToolsPath}"
          fi

          export PATH="$PWD/bin:${depotToolsPath}:$PATH"
          export DEPOT_TOOLS_UPDATE=0

          unset LD_PRELOAD
          unset _JAVA_OPTIONS

          export VANADIUM_MALLOC="${pkgs.mimalloc}/lib/libmimalloc.so"

          export ALLOW_NINJA_ENV="true"
          export NINJA_STATUS="[%p %f/%t %e] "

          # Point siso's remote cache at our self-hosted CAS
          export SISO_REAPI_ADDRESS=scarp:50051
          export SISO_REAPI_INSTANCE=chromium

          export VANADIUM_ROOT="$PWD"
          export VANADIUM_DEVICE="''${VANADIUM_DEVICE:-33271FDH3001RW}"
          export VANADIUM_KEYSTORE="''${VANADIUM_KEYSTORE:-$HOME/.android/debug.keystore}"
          export VANADIUM_KS_ALIAS="''${VANADIUM_KS_ALIAS:-androiddebugkey}"
          export VANADIUM_KS_PASS="''${VANADIUM_KS_PASS:-android}"
          export VANADIUM_SIGNED_DIR="''${VANADIUM_SIGNED_DIR:-/tmp/signed_apks}"
          export VANADIUM_JAVA="''${VANADIUM_JAVA:-/home/amaanq/projects/grapheneos/prebuilts/jdk/jdk21/linux-x86/bin/java}"
          export VANADIUM_APKSIGNER="''${VANADIUM_APKSIGNER:-/home/amaanq/projects/grapheneos/out_adevtool_deps/host/linux-x86/framework/apksigner.jar}"
        '';
      };
    };
}
