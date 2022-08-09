# tokio_echo

This demo is a TCP Echo server for tokio.

## Prerequisites

Be sure to update your rust stable toolchain to at least 1.60.0.

Please ensure that you're using the standard toolchain (if using [`rustup`](https://rustup.rs/): `rustup default`).

## Running from Try Enarx

First generate the Wasm file on localhost:

```sh
cargo build --target wasm32-wasi 
```

Access the __Try Enarx__ website:

https://try.enarx.dev

Select a platform. Let's try Intel SGX on Equinix.

Upload the generated Wasm file from:

```sh
<path-to-tokio-echo>/target/wasm32-wasi/debug/tokio-echo.wasm 
```

Paste the following to the Enarx.toml text area:

```toml
[[files]]
kind = "stdin"

[[files]]
kind = "stdout"

[[files]]
kind = "stderr"

[[files]]
name = "LISTEN"
kind = "listen"
port = 10010
prot = "tcp"
```

Click on the `Deploy` button. 

Now open a terminal on your machine. You are going to connect with the server using either ncat or nc (these are popular networking tools that are usually available out-of-the-box):

```sh
echo hello | ncat sgx.equinix.try.enarx.dev 10010 
```

In the __Try Enarx__ website, you should see the following output:

```sh
hello
> CONNECTED
> DISCONNECTED
```

Congratulations!

## Running from localhost

### enarx

After installing [enarx](https://enarx.dev/docs/Quickstart) run:

```sh
CARGO_TARGET_WASM32_WASI_RUNNER="enarx run --wasmcfgfile Enarx.toml" cargo run --target wasm32-wasi 
```

Open another shell and enter:

```sh
echo hello | ncat 127.0.0.1 10010 
```

You should see the following output from Enarx:

```sh
Running enarx run --wasmcfgfile Enarx.toml target/wasm32-wasi/debug/tokio-echo.wasm
> CONNECTED
hello
> DISCONNECTED
```
