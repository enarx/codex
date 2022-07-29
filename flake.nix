{
  description = "Enarx Cod(e) Ex(amples)";

  inputs.cryptle.url = github:enarx/cryptle;
  inputs.enarx.url = github:enarx/enarx/v0.6.1;
  inputs.fenix.url = github:nix-community/fenix;
  inputs.flake-utils.url = github:numtide/flake-utils;
  inputs.naersk.inputs.nixpkgs.follows = "nixpkgs";
  inputs.naersk.url = github:nix-community/naersk;
  inputs.nixpkgs.url = github:profianinc/nixpkgs;

  outputs = {
    self,
    cryptle,
    enarx,
    fenix,
    flake-utils,
    naersk,
    nixpkgs,
  }: let
    cargoPackage = toml: (builtins.fromTOML (builtins.readFile toml)).package;

    defaultConf = pkgs:
      pkgs.writeText "Enarx.toml" ''
        [[files]]
        kind = "stdin"

        [[files]]
        kind = "stdout"

        [[files]]
        kind = "stderr"
      '';

    buildEnarxPackage = {
      pkgs,
      name,
      version,
      wasm,
      conf ? null,
    }:
      pkgs.stdenv.mkDerivation {
        inherit version;

        pname = name;

        dontUnpack = true;
        installPhase =
          ''
            mkdir -p $out
            cp ${wasm} $out/main.wasm
          ''
          + pkgs.lib.optionalString (conf != null) ''
            cp ${conf} $out/Enarx.toml
          '';
      };

    codex = final: prev: let
      rust = with fenix.packages.${final.system};
        combine [
          stable.rustc
          stable.cargo
          targets.wasm32-wasi.stable.rust-std
        ];

      naersk-lib = naersk.lib.${final.system}.override {
        cargo = rust;
        rustc = rust;
      };
    in {
      fibonacci-c-wasm =
        final.pkgsCross.wasi32.runCommandCC "fibonacci" {
          pname = "fibonacci";
          version = "0.1.0";
        }
        ''
          mkdir -p "$out/bin"
          $CC -Wall -pedantic ${self}/C/fibonacci/fibonacci.c \
            -o "$out/bin/fibonacci.wasm"
        '';

      fibonacci-c = buildEnarxPackage {
        inherit (final) pkgs;
        inherit (final.fibonacci-c-wasm) version;
        name = final.fibonacci-c-wasm.pname;

        wasm = "${final.fibonacci-c-wasm}/bin/fibonacci.wasm";
        # TODO: Read this from repo
        conf = defaultConf final;
      };

      fibonacci-cpp-wasm =
        final.pkgsCross.wasi32.runCommandCC "fibonacci" {
          pname = "fibonacci";
          version = "0.1.0";
        }
        ''
          mkdir -p "$out/bin"
          $CXX -Wall -pedantic ${self}/C++/fibonacci/fibonacci.cpp \
            -o "$out/bin/fibonacci.wasm"
        '';

      fibonacci-cpp = buildEnarxPackage {
        inherit (final) pkgs;
        inherit (final.fibonacci-cpp-wasm) version;
        name = final.fibonacci-cpp-wasm.pname;

        wasm = "${final.fibonacci-cpp-wasm}/bin/fibonacci.wasm";
        # TODO: Read this from repo
        conf = defaultConf final;
      };

      fibonacci-go-wasm = final.stdenv.mkDerivation rec {
        pname = "fibonacci";
        version = "0.1.0";

        src = "${self}/Go/fibonacci";

        nativeBuildInputs = with final; [tinygo];

        configurePhase = ''
          export HOME=$TMPDIR
          export GOCACHE=$TMPDIR/go-cache
        '';

        buildPhase = ''
          tinygo build -target wasi main.go
        '';

        installPhase = ''
          mkdir -p $out/bin
          cp main.wasm $out/bin/${pname}.wasm
        '';
      };

      fibonacci-go = buildEnarxPackage {
        inherit (final) pkgs;
        inherit (final.fibonacci-go-wasm) version;
        name = final.fibonacci-go-wasm.pname;

        wasm = "${final.fibonacci-go-wasm}/bin/fibonacci.wasm";
        # TODO: Read this from repo
        conf = defaultConf final;
      };

      fibonacci-rust-wasm = naersk-lib.buildPackage {
        src = "${self}/Rust/fibonacci";
        CARGO_BUILD_TARGET = "wasm32-wasi";
      };

      fibonacci-rust = buildEnarxPackage {
        inherit (final) pkgs;
        inherit (cargoPackage "${self}/Rust/fibonacci/Cargo.toml") name version;

        wasm = "${final.fibonacci-rust-wasm}/bin/fibonacci.wasm";
        # TODO: Read this from repo
        conf = defaultConf final;
      };

      fibonacci-zig-wasm = final.stdenv.mkDerivation {
        pname = "fibonacci";
        version = "0.3.0";

        src = "${self}/Zig/fibonacci";

        nativeBuildInputs = with final; [zig];

        configurePhase = ''
          export HOME=$TMPDIR
        '';

        installPhase = ''
          zig build -Dtarget=wasm32-wasi -Drelease-safe -Dcpu=baseline --prefix $out install
        '';
      };

      fibonacci-zig = buildEnarxPackage {
        inherit (final) pkgs;
        inherit (final.fibonacci-zig-wasm) version;
        name = final.fibonacci-zig-wasm.pname;

        wasm = "${final.fibonacci-zig-wasm}/bin/fibonacci.wasm";
        conf = "${self}/Zig/fibonacci/Enarx.toml";
      };

      echo-tcp-rust-mio-wasm = naersk-lib.buildPackage {
        src = "${self}/Rust/mio-echo-tcp";
        CARGO_BUILD_TARGET = "wasm32-wasi";
      };

      echo-tcp-rust-mio = buildEnarxPackage {
        inherit (final) pkgs;
        inherit (cargoPackage "${self}/Rust/mio-echo-tcp/Cargo.toml") name version;

        wasm = "${final.echo-tcp-rust-mio-wasm}/bin/mio-echo-tcp.wasm";
        conf = "${self}/Rust/mio-echo-tcp/Enarx.toml";
      };

      http-rust-tokio-wasm = naersk-lib.buildPackage {
        src = "${self}/Rust/tokio-http";
        CARGO_BUILD_TARGET = "wasm32-wasi";
      };

      http-rust-tokio = buildEnarxPackage {
        inherit (final) pkgs;
        inherit (cargoPackage "${self}/Rust/tokio-http/Cargo.toml") name version;

        wasm = "${final.http-rust-tokio-wasm}/bin/tokio-http.wasm";
        conf = "${self}/Rust/tokio-http/Enarx.toml";
      };
    };

    credentialHelpers = final: prev: {
      enarx-credential-helper-gopass = final.writeShellScriptBin "enarx-credential-helper-gopass" ''
        set -e
        if [ "''${1}" = "insert" ]; then
            exec ${final.gopass}/bin/gopass insert -f "misc/enarx/''${2}"
        elif [ "''${1}" = "show" ]; then
            ${final.gopass}/bin/gopass find misc/enarx 1>/dev/null 2>/dev/null
            exec ${final.gopass}/bin/gopass show -n -o "misc/enarx/''${2}"
        else
            echo "Unknown command `''${1}`"
            exit 1
        fi
      '';

      enarx-credential-helper-pass = final.writeShellScriptBin "enarx-credential-helper-pass" ''
        set -e
        if [ "''${1}" = "insert" ]; then
            exec ${final.pass}/bin/pass insert -f -m "misc/enarx/''${2}" 1> /dev/null
        elif [ "''${1}" = "show" ]; then
            exec ${final.pass}/bin/pass show "misc/enarx/''${2}"
        else
            echo "Unknown command `''${1}`"
            exit 1
        fi
      '';
    };
  in
    with flake-utils.lib.system;
      {
        overlays.codex = codex;
        overlays.credentialHelpers = credentialHelpers;

        overlays.default = codex;
      }
      // flake-utils.lib.eachSystem [
        aarch64-darwin
        aarch64-linux
        x86_64-darwin
        x86_64-linux
      ] (system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            codex
            credentialHelpers
            cryptle.overlays.default
          ];
        };

        packages = with pkgs;
          {
            inherit
              echo-tcp-rust-mio
              echo-tcp-rust-mio-wasm
              enarx-credential-helper-gopass
              enarx-credential-helper-pass
              fibonacci-c
              fibonacci-c-wasm
              fibonacci-cpp
              fibonacci-cpp-wasm
              fibonacci-rust
              fibonacci-rust-wasm
              http-rust-tokio
              http-rust-tokio-wasm
              ;

            cryptle-rust = cryptle-enarx;
            cryptle-rust-wasm = cryptle-wasm;
          }
          // lib.optionalAttrs (!tinygo.meta.broken) {
            # NOTE: TinyGo is broken on some platforms, only add Go packages on platforms where it works
            inherit
              fibonacci-go
              fibonacci-go-wasm
              ;
          }
          // lib.optionalAttrs (!zig.meta.broken) {
            # NOTE: Zig is broken on some platforms, only add Zig packages on platforms where it works
            inherit
              fibonacci-zig
              fibonacci-zig-wasm
              ;
          };
      in {
        inherit packages;

        formatter = pkgs.alejandra;

        devShells.default = pkgs.mkShell {
          buildInputs = [
            enarx.packages.${system}.enarx-static
          ];
        };
      });
}
