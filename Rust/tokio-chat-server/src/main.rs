use std::env;
use std::error::Error;
use std::fmt::Display;
#[cfg(target_os = "wasi")]
use std::os::wasi::io::FromRawFd;
use std::str::FromStr;

use anyhow::{bail, Context};
use futures::{join, select, Stream, StreamExt, TryFutureExt};
use tokio::io::{AsyncBufReadExt, AsyncWriteExt, BufReader};
use tokio::net::{TcpListener, TcpStream};
use tokio::sync::broadcast;
use tokio::sync::broadcast::Sender;
use tokio_stream::wrappers::{BroadcastStream, LinesStream, TcpListenerStream};
use ulid::Ulid;

/// Handles the peer TCP stream I/O.
async fn handle_io(
    peer: &mut TcpStream,
    tx: &Sender<String>,
    rx: impl Stream<Item = Result<String, impl Error>> + Unpin,
    id: impl Display,
) -> anyhow::Result<()> {
    let (input, mut output) = peer.split();
    let mut input = LinesStream::new(BufReader::new(input).lines()).fuse();
    let mut rx = rx.fuse();
    loop {
        select! {
            line = input.next() => match line {
                None => return Ok(()),
                Some(Err(e)) => bail!("failed to receive line from {id}: {e}"),
                Some(Ok(line)) => if let Err(e) = tx.send(format!("{id}: {line}")) {
                    bail!("failed to send line from {id}: {e}")
                },
            },
            line = rx.next() => match line {
                None => return Ok(()),
                Some(Err(e)) => bail!("failed to receive line for {id}: {e}"),
                Some(Ok(line)) => if let Err(e) = output.write_all(format!("{line}\n").as_bytes()).await {
                    bail!("failed to send line to {id}: {e}")
                },
            },
            complete => return Ok(()),
        };
    }
}

/// Handles the peer TCP stream.
async fn handle(peer: &mut TcpStream, tx: &Sender<String>) {
    let id = Ulid::new();

    let rx = BroadcastStream::new(tx.subscribe());
    if let Err(e) = tx.send(format!("{id} joined the chat")) {
        eprintln!("failed to send {id} join event to peers: {e}");
        return;
    }

    _ = handle_io(peer, tx, rx, id)
        .map_err(|e| eprintln!("failed to handle {id} peer I/O: {e}"))
        .await;

    if let Err(e) = tx.send(format!("{id} left the chat")) {
        eprintln!("failed to send {id} leave event to peers: {e}")
    }
}

#[tokio::main(flavor = "current_thread")]
async fn main() -> anyhow::Result<()> {
    let fd_count = env::var("FD_COUNT").context("failed to lookup `FD_COUNT`")?;
    let fd_count = usize::from_str(&fd_count).context("failed to parse `FD_COUNT`")?;
    assert_eq!(
        fd_count,
        4, // STDIN, STDOUT, STDERR and a socket
        "unexpected amount of file descriptors received"
    );
    let listener = match env::var("FD_NAMES")
        .context("failed to lookup `FD_NAMES`")?
        .splitn(fd_count, ':')
        .nth(3)
    {
        None => bail!("failed to parse `FD_NAMES`"),
        Some("ingest") => {
            let l = unsafe { std::net::TcpListener::from_raw_fd(3) };
            l.set_nonblocking(true)
                .context("failed to set non-blocking flag on socket")?;
            TcpListener::from_std(l)
                .context("failed to initialize Tokio listener")
                .map(TcpListenerStream::new)?
        }
        Some(name) => bail!("unknown socket name `{name}`"),
    };

    let (tx, rx) = broadcast::channel(128);
    join!(
        BroadcastStream::new(rx).for_each(|line| async {
            match line {
                Err(e) => eprintln!("failed to receive line: {e}"),
                Ok(line) => println!("> {line}"),
            }
        }),
        listener.for_each_concurrent(None, |peer| async {
            match peer {
                Err(e) => eprintln!("failed to accept connection: {e}"),
                Ok(mut peer) => handle(&mut peer, &tx).await,
            };
        })
    );
    Ok(())
}
