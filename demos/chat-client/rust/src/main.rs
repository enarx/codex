use std::env;
#[cfg(unix)]
use std::os::unix::io::FromRawFd;
#[cfg(target_os = "wasi")]
use std::os::wasi::io::FromRawFd;
use std::str::FromStr;

use anyhow::{bail, Context};
use futures::StreamExt;
use tokio::io::{AsyncBufReadExt, AsyncWriteExt, BufReader};
use tokio::net::TcpStream;
use tokio_stream::wrappers::LinesStream;

#[tokio::main(flavor = "current_thread")]
async fn main() -> anyhow::Result<()> {
    let fd_count = env::var("FD_COUNT").context("failed to lookup `FD_COUNT`")?;
    let fd_count = usize::from_str(&fd_count).context("failed to parse `FD_COUNT`")?;
    assert_eq!(
        fd_count,
        5, // STDIN, STDOUT, STDERR and 2 sockets
        "unexpected amount of file descriptors received"
    );
    let mut stream = match env::var("FD_NAMES")
        .context("failed to lookup `FD_NAMES`")?
        .splitn(fd_count, ':')
        .nth(3)
    {
        None => bail!("failed to parse `FD_NAMES`"),
        Some("server") => {
            let s = unsafe { std::net::TcpStream::from_raw_fd(3) };
            s.set_nonblocking(true)
                .context("failed to set non-blocking flag on socket")?;
            TcpStream::from_std(s).context("failed to initialize Tokio stream")?
        }
        Some(name) => bail!("unknown socket name `{name}`"),
    };

    // TODO: Send and receive multiple messages concurrently once async reads from stdin are possible
    for line in std::io::stdin().lines() {
        let line = line.context("failed to read line from STDIN")?;
        stream
            .write_all(format!("{line}\n").as_bytes())
            .await
            .context("failed to send line")?;
    }
    LinesStream::new(BufReader::new(stream).lines())
        .for_each(|line| async {
            match line {
                Err(e) => eprintln!("* failed to receive line: {e}"),
                Ok(line) => println!("{line}"),
            }
        })
        .await;
    Ok(())
}
