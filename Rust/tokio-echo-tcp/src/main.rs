use std::io::Write;
use std::os::wasi::prelude::FromRawFd;

use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::net::{TcpListener, TcpStream};

#[tokio::main(flavor = "current_thread")]

async fn main() -> std::io::Result<()> {
    // Set up pre-established listening socket.
    let standard = unsafe { std::net::TcpListener::from_raw_fd(3) };
    standard.set_nonblocking(true).unwrap();
    let listener = TcpListener::from_std(standard)?;

    loop {
        // Accept new sockets in a loop.
        let socket = match listener.accept().await {
            Ok(s) => s.0,
            Err(e) => {
                eprintln!("> ERROR: {}", e);
                continue;
            }
        };

        // Spawn a background task for each new connection.
        tokio::spawn(async move {
            eprintln!("> CONNECTED");
            match handle(socket).await {
                Ok(()) => eprintln!("> DISCONNECTED"),
                Err(e) => eprintln!("> ERROR: {}", e),
            }
        });
    }
}

async fn handle(mut socket: TcpStream) -> std::io::Result<()> {
    loop {
        let mut buf = [0u8; 4096];

        // Read some bytes from the socket.
        let read = socket.read(&mut buf).await?;

        // Handle a clean disconnection.
        if read == 0 {
            return Ok(());
        }

        // Write bytes both locally and remotely.
        std::io::stdout().write_all(&buf[..read])?;
        socket.write_all(&buf[..read]).await?;
    }
}
