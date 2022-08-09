# wasi_tokio_http

This is a modified version of the
[`tinyhttp.rs`](https://github.com/tokio-rs/tokio/blob/5288e1e144d33ace0070325b16029523b1db0ffe/examples/tinyhttp.rs)
example in the tokio repository.

## Prerequisites

Be sure to use a stable Rust toolchain that is no older than Rust 1.60.0. You can use `cargo --version` to view the version of your default Rust toolchain.

## Running

### wasmtime

```console
❯ CARGO_TARGET_WASM32_WASI_RUNNER="wasmtime run --tcplisten 127.0.0.1:10020" cargo run --target wasm32-wasi  
```

Server is running on [`http://127.0.0.1:10020`](http://127.0.0.1:10020).

### enarx

after installing [enarx](https://github.com/enarx/enarx/) in `$PATH` with `cargo install`

```console
❯ CARGO_TARGET_WASM32_WASI_RUNNER="enarx run --wasmcfgfile Enarx.toml" cargo run --target wasm32-wasi 
```

Server is running on [`https://127.0.0.1:10020`](https://127.0.0.1:10020).
