#!/bin/bash

# WASI_SDK_PATH defined in https://github.com/WebAssembly/wasi-sdk
$WASI_SDK_PATH/bin/clang++ main.cpp --sysroot $WASI_SDK_PATH/share/wasi-sysroot -o main.wasm && 
enarx run --wasmcfgfile Enarx.toml main.wasm