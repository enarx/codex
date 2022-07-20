# wasi_tokio_http

This is a modified version of the
[`tinyhttp.rs`](https://github.com/tokio-rs/tokio/blob/5288e1e144d33ace0070325b16029523b1db0ffe/examples/tinyhttp.rs)
example in the tokio repository.

## Prerequisites

Be sure to update your rust stable toolchain to at least 1.60.0.

## Running

### wasmtime

```console
❯ CARGO_TARGET_WASM32_WASI_RUNNER="wasmtime run --tcplisten 127.0.0.1:8080" cargo run --target wasm32-wasi  
```

Server is running on [`http://127.0.0.1:8080`](http://127.0.0.1:8080).

### enarx

after installing [enarx](https://github.com/enarx/enarx/) in `$PATH` with `cargo install`

```console
❯ CARGO_TARGET_WASM32_WASI_RUNNER="enarx run --wasmcfgfile Enarx.toml" cargo run --target wasm32-wasi 
```

Server is running on [`https://127.0.0.1:3000`](https://127.0.0.1:3000).
