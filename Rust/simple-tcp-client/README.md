Simple TCP client for the tokio-echo-tcp server 
-----------------------------------------------

This demo is a TCP client which connects to tokio-echo-tcp server.

# You need to lauch the server

Follow README.md documentation under codex/Rust/tokio-echo-tcp and execute the server:

```sh
cargo build --target wasm32-wasi --release
enarx run --backend=nil --wasmcfgfile Enarx.toml target/wasm32-wasi/release/tokio-echo-tcp.wasm
```

Now when the TCP echo server is running you can build this TCP client and test it:

Run release without Enarx:

```sh
cargo run
```

Run inside Enarx Keep:

```sh
cargo build --release --target=wasm32-wasi
enarx run --backend=nil --wasmcfgfile Enarx.toml target/wasm32-wasi/release/entropyclient.wasm
```

Expected result following:

```sh
Successfully connected to server.
request_data = "GET / HTTP/1.0\r\n\r\n"
"GET / HTTP/1.0\r\n\r\n"
Finished.
```
