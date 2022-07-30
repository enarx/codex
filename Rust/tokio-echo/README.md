# tokio_echo

This demo is a TCP Echo server for tokio

## Prerequisites

Be sure to update your rust stable toolchain to at least 1.60.0.

Please ensure that you're using the standard toolchain (rustup default).

## Running from Try Enarx

First generate the Wasm file on localhost:

```console
cargo build --target wasm32-wasi 
```

Access the __Try Enarx__ website:

https://try.enarx.dev

Select a platform. Let's try Intel SGX on Equinix.

Upload the generated Wasm file from:

```console
/target/wasm32-wasi/debug/tokio-echo.wasm 
```

Paste the following to the Enarx.toml text area:

```
[[files]]
kind = "stdin"

[[files]]
kind = "stdout"

[[files]]
kind = "stderr"

[[files]]
name = "LISTEN"
kind = "listen"
port = 12345
prot = "tcp"
```

Click on the `Deploy` button. 

Now open a terminal on your machine and enter:

```console
echo hello world | ncat sgx.equinix.try.enarx.dev 12345 
```

In the __Try Enarx__ website, you should see the following output:

```console
hello world
> CONNECTED
> DISCONNECTED
```

Congratulations!

## Running from localhost

### enarx

After installing [enarx](https://github.com/enarx/enarx/) in `$PATH` with `cargo install`

```console
CARGO_TARGET_WASM32_WASI_RUNNER="enarx run --wasmcfgfile Enarx.toml" cargo run --target wasm32-wasi 
```

Open another shell and enter:

```console
echo hello world | ncat 127.0.0.1 12345 
```

You should see the following output from Enarx:

```console
Running enarx run --wasmcfgfile Enarx.toml target/wasm32-wasi/debug/tokio-echo.wasm
> CONNECTED
hello world
> DISCONNECTED
```