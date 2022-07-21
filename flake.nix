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
      flake-utils.lib.eachSystem [
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
      in {
        formatter = pkgs.alejandra;

        packages.enarx-credential-helper-gopass = pkgs.enarx-credential-helper-gopass;
        packages.enarx-credential-helper-pass = pkgs.enarx-credential-helper-pass;

        packages.cryptle-rust = pkgs.cryptle-enarx;
        packages.cryptle-rust-wasm = pkgs.cryptle-wasm;

        packages.echo-tcp-rust-mio = pkgs.echo-tcp-rust-mio;
        packages.echo-tcp-rust-mio-wasm = pkgs.echo-tcp-rust-mio-wasm;

        packages.fibonacci-rust = pkgs.fibonacci-rust;
        packages.fibonacci-rust-wasm = pkgs.fibonacci-rust-wasm;

        packages.http-rust-tokio = pkgs.http-rust-tokio;
        packages.http-rust-tokio-wasm = pkgs.http-rust-tokio-wasm;

        devShells.default = pkgs.mkShell {
          buildInputs = [
            enarx.packages.${system}.enarx-static
          ];
        };
      });
}
