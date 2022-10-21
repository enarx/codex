{
  description = "Enarx Cod(e) Ex(amples)";

  inputs.cryptle.url = github:enarx/cryptle;
  inputs.enarx.url = github:enarx/enarx;
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

    demos.chat-client.conf = ./demos/chat-client/Enarx.toml;

    demos.chat-client.cpp.src = ./demos/chat-client/c++/main.cpp;
    demos.chat-client.rust.src = ./demos/chat-client/rust;
    demos.chat-client.rust.package = cargoPackage ./demos/chat-client/rust/Cargo.toml;

    demos.chat-server.conf = ./demos/chat-server/Enarx.toml;

    demos.chat-server.rust.src = ./demos/chat-server/rust;
    demos.chat-server.rust.package = cargoPackage ./demos/chat-server/rust/Cargo.toml;

    demos.fibonacci.conf = ./demos/fibonacci/Enarx.toml;

    demos.fibonacci.c.src = ./demos/fibonacci/c/fibonacci.c;
    demos.fibonacci.cpp.src = ./demos/fibonacci/c++/fibonacci.cpp;
    demos.fibonacci.go.src = ./demos/fibonacci/go;
    demos.fibonacci.rust.package = cargoPackage ./demos/fibonacci/rust/Cargo.toml;
    demos.fibonacci.rust.src = ./demos/fibonacci/rust;
    demos.fibonacci.zig.src = ./demos/fibonacci/zig;

    CARGO_BUILD_TARGET = "wasm32-wasi";

    buildEnarxPackage = {
      pkgs,
      pname,
      version,
      wasm,
      conf,
    }:
      pkgs.stdenv.mkDerivation {
        inherit pname version;

        dontUnpack = true;
        installPhase = ''
          mkdir -p $out
          cp ${conf} $out/Enarx.toml
          cp ${wasm} $out/main.wasm
        '';
      };

    buildFibonacciPackage = {
      pkgs,
      wasm,
      ...
    } @ args: let
      args' =
        args
        // {
          inherit (demos.fibonacci) conf;
          inherit (wasm) version;

          wasm = "${wasm}/bin/fibonacci.wasm";
          pname = "fibonacci";
        };
    in
      (buildEnarxPackage args').overrideAttrs (attrs: {
        doCheck = true;

        checkInputs = [
          enarx.packages.${pkgs.system}.enarx
        ];

        checkPhase = ''
          ${self}/tests/run.sh ${self}/tests/fibonacci/golden/default --wasmcfgfile ${demos.fibonacci.conf} ${wasm}/bin/fibonacci.wasm
          cat ${self}/tests/fibonacci/stdin | ${self}/tests/run.sh ${self}/tests/fibonacci/golden/stdin ${wasm}/bin/fibonacci.wasm
        '';
      });

    codex = final: prev: let
      rust = with fenix.packages.${final.system};
        combine [
          stable.cargo
          stable.rustc
          targets.wasm32-wasi.stable.rust-std
        ];

      naersk-lib = naersk.lib.${final.system}.override {
        cargo = rust;
        rustc = rust;
      };
    in {
      chat-client-cpp-wasm =
        final.pkgsCross.wasi32.runCommandCC "chat-client" {
          pname = "chat-client-cpp";
          version = "0.1.0";
        }
        ''
          mkdir -p "$out/bin"
          $CXX -Wall -pedantic ${demos.chat-client.cpp.src} \
            -o "$out/bin/chat-client.wasm"
        '';

      chat-client-cpp = buildEnarxPackage {
        inherit (demos.chat-client) conf;
        inherit (final) pkgs;
        inherit (final.chat-client-cpp-wasm) pname version;

        wasm = "${final.chat-client-cpp-wasm}/bin/chat-client.wasm";
      };

      chat-client-rust-wasm = naersk-lib.buildPackage {
        inherit (demos.chat-client.rust) src;
        inherit (demos.chat-client.rust.package) version;
        inherit CARGO_BUILD_TARGET;

        pname = "chat-client-rust";
      };

      chat-client-rust = buildEnarxPackage {
        inherit (demos.chat-client) conf;
        inherit (final) pkgs;
        inherit (final.chat-client-rust-wasm) pname version;

        wasm = "${final.chat-client-rust-wasm}/bin/${demos.chat-client.rust.package.name}.wasm";
      };

      chat-server-rust-wasm = naersk-lib.buildPackage {
        inherit (demos.chat-server.rust) src;
        inherit (demos.chat-server.rust.package) version;
        inherit CARGO_BUILD_TARGET;

        pname = "chat-server-rust";
      };

      chat-server-rust = buildEnarxPackage {
        inherit (demos.chat-server) conf;
        inherit (final) pkgs;
        inherit (final.chat-server-rust-wasm) pname version;

        wasm = "${final.chat-server-rust-wasm}/bin/${demos.chat-server.rust.package.name}.wasm";
      };

      fibonacci-c-wasm =
        final.pkgsCross.wasi32.runCommandCC "fibonacci" {
          pname = "fibonacci-c";
          version = "0.3.0";
        }
        ''
          mkdir -p "$out/bin"
          $CC -Wall -pedantic ${demos.fibonacci.c.src} \
            -o "$out/bin/fibonacci.wasm"
        '';

      fibonacci-c = buildFibonacciPackage {
        inherit (final) pkgs;

        wasm = final.fibonacci-c-wasm;
      };

      fibonacci-cpp-wasm =
        final.pkgsCross.wasi32.runCommandCC "fibonacci" {
          pname = "fibonacci-cpp";
          version = "0.3.0";
        }
        ''
          mkdir -p "$out/bin"
          $CXX -Wall -pedantic ${demos.fibonacci.cpp.src} \
            -o "$out/bin/fibonacci.wasm"
        '';

      fibonacci-cpp = buildFibonacciPackage {
        inherit (final) pkgs;

        wasm = final.fibonacci-cpp-wasm;
      };

      fibonacci-go-wasm = final.stdenv.mkDerivation rec {
        inherit (demos.fibonacci.go) src;

        pname = "fibonacci-go";
        version = "0.3.0";

        nativeBuildInputs = with final; [tinygo];

        configurePhase = ''
          export HOME=$TMPDIR/home
          export GOCACHE=$TMPDIR/go-cache
        '';

        buildPhase = ''
          tinygo build -target wasi main.go
        '';

        installPhase = ''
          mkdir -p $out/bin
          cp main.wasm $out/bin/fibonacci.wasm
        '';
      };

      fibonacci-go = buildFibonacciPackage {
        inherit (final) pkgs;

        wasm = final.fibonacci-go-wasm;
      };

      fibonacci-rust-wasm = naersk-lib.buildPackage {
        inherit (demos.fibonacci.rust) src;
        inherit (demos.fibonacci.rust.package) version;
        inherit CARGO_BUILD_TARGET;

        pname = "fibonacci-rust";
      };

      fibonacci-rust = buildFibonacciPackage {
        inherit (final) pkgs;

        wasm = final.fibonacci-rust-wasm;
      };

      fibonacci-zig-wasm = final.stdenv.mkDerivation {
        inherit (demos.fibonacci.zig) src;

        pname = "fibonacci-zig";
        version = "0.4.0";

        nativeBuildInputs = with final; [zig];

        configurePhase = ''
          export HOME=$TMPDIR
        '';

        installPhase = ''
          zig build -Dtarget=wasm32-wasi -Drelease-safe -Dcpu=baseline --prefix $out install
        '';
      };

      fibonacci-zig = buildFibonacciPackage {
        inherit (final) pkgs;

        wasm = final.fibonacci-zig-wasm;
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
            fenix.overlay
          ];
        };

        packages = with pkgs;
          {
            inherit
              chat-client-cpp
              chat-client-cpp-wasm
              chat-client-rust
              chat-client-rust-wasm
              chat-server-rust
              chat-server-rust-wasm
              enarx-credential-helper-gopass
              enarx-credential-helper-pass
              fibonacci-c
              fibonacci-c-wasm
              fibonacci-cpp
              fibonacci-cpp-wasm
              fibonacci-rust
              fibonacci-rust-wasm
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

        devShells = let
          rust = with pkgs.fenix;
            combine [
              stable.cargo
              stable.clippy
              stable.rustc
              stable.rustfmt
              targets.wasm32-wasi.stable.rust-std
            ];
        in
          {
            default = pkgs.mkShell {
              buildInputs = [
                enarx.packages.${system}.enarx

                rust
              ];
            };

            rust = devShells.default.overrideAttrs (attrs: {
              buildInputs = attrs.buildInputs ++ [rust];
            });
          }
          // pkgs.lib.optionalAttrs (!pkgs.tinygo.meta.broken) {
            # NOTE: TinyGo is broken on some platforms, only add Go shell on platforms where it works
            go = devShells.default.overrideAttrs (attrs: {
              buildInputs = attrs.buildInputs ++ [pkgs.tinygo];
            });
          }
          // pkgs.lib.optionalAttrs (!pkgs.zig.meta.broken) {
            # NOTE: Zig is broken on some platforms, only add Zig shell on platforms where it works
            zig = devShells.default.overrideAttrs (attrs: {
              buildInputs = attrs.buildInputs ++ [pkgs.zig];
            });
          };
      in {
        inherit
          devShells
          packages
          ;

        checks = packages;

        formatter = pkgs.alejandra;
      });
}
